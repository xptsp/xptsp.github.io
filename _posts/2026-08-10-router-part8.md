---
title: My Router - Part 8
description: Accessing SSH from Internet over HTTPS Port
date: 2026-08-10 0:00:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

I'd like to multiplex **TCP port 443** so that I can passwordlessly SSH into my network
without needing a VPN.

I've explored different multiplexers, such SSLH, HAProxy, all of didn't work for some reason,
probably due to incorrectly configured firewall rules that I couldn't figure out how to
configure properly.

With the help of Google, I finally figured out the NGINX stream configuration to pass the
real client IP address to the HTTPS server, and strip the proxy header out of the stream for
SSH and OpenVPN connections, all without the firewall rules that SSLH and HAProxy
required for transparent mode that broke things in the router...

----

## Setting up SSH Passwordless access

Let's modify our DropBear configuration in order to restrict our first DropBear instance to
the ```lan``` network, and create another DropBear instance where our passwordless SSH
server will reside, accessible via the guest network:
```shell
uci rename dropbear.@dropbear[0]="lan"
uci set dropbear.lan=dropbear
uci set dropbear.lan.PasswordAuth='on'
uci set dropbear.lan.RootPasswordAuth='on'
uci set dropbear.lan.Interface='lan'

uci set dropbear.guest=dropbear
uci set dropbear.guest.RootPasswordAuth='off'
uci set dropbear.guest.PasswordAuth='off'
uci set dropbear.guest.Interface='guest'
uci commit
service dropbear restart
```

----

## Some Prep Work

First, we need to install the NGINX stream module:
```shell
apk add nginx-mod-stream
```

We need to change the ports that NGINX listens on in the ```/etc/config/nginx``` file:
```shell
sed -i "s|443 ssl|8443 ssl proxy_protocol|g" /etc/config/nginx
```

We need to add a new configuration file under ```/etc/nginx/conf.d```:
```shell
FILE=/etc/nginx/conf.d/misc.conf
cat << EOF > ${FILE}
set_real_ip_from  127.0.0.1;
real_ip_header    proxy_protocol;
server_names_hash_bucket_size 128;
EOF
echo ${FILE} >> /etc/sysupgrade.conf
```

The first 2 lines in ```/etc/nginx/conf.d/misc.conf``` allows NGINX to pull the client IP address
from the calling stream block, while the last line allows me to use really long domain names.  I
don't feel like buying a domain name at this point.... :p

---

## Our Awesome Multiplexer!

Let's add the stream block to ```/etc/nginx/uci.conf.template``` to handle the multiplexing,
then restart NGINX to make the magic work:
```shell
cat << EOF >> /etc/nginx/uci.conf.template
stream {
	ssl_preread on;
	map_hash_bucket_size 128;

	upstream ssh {
		server 127.0.0.1:8022;
	}
	upstream tls_router {
		server 127.0.0.1:8443;
	}
	upstream tls_moe {
		server 192.168.20.100:443;
	}
	upstream tls_larry {
		server 192.168.20.101:443;
	}
	upstream tls_default {
		server 127.0.0.1:8443;	# <= Change to OpenVPN server block at port 8194 if desired
	}

	map \$ssl_preread_protocol \$upstream_backend {
		"TLSv1.0"       \$host;
		"TLSv1.1"       \$host;
		"TLSv1.2"       \$host;
		"TLSv1.3"       \$host;
		default         ssh;
	}
	map \$ssl_preread_server_name \$host {
		"openwrt"             tls_router;
		"openwrt.lan"         tls_router;
		"router.example.com"  tls_router;
		"moe.example.com"     tls_moe;
		"larry.example.com"   tls_larry;
		default               tls_default;
	}

	server {
		listen 443;
		proxy_protocol on;
		proxy_pass \$upstream_backend;
	}
	server {
		listen 127.0.0.1:8022 proxy_protocol;
		proxy_pass 192.168.3.1:22;
		proxy_protocol off;  # << DO NOT CHANGE!  Breaks SSH if you do! >>
	}
}
EOF
service nginx restart
```

----

## HTTPS from WAN Firewall Rule

We also need to add a firewall rule to allow access to TCP port 443 from the internet,
then restart the firewall:
```shell
uci set firewall.https_from_wan=rule
uci set firewall.https_from_wan.src='wan'
uci set firewall.https_from_wan.name='Allow-HTTPS-from-WAN'
uci set firewall.https_from_wan.proto='tcp'
uci set firewall.https_from_wan.dest_port='443'
uci set firewall.https_from_wan.target='ACCEPT'
uci commit
service firewall restart
```

----

## What The Stream Block Does

### <u>Upstream definitions</u>
- ```upstream ssh``` points to our passwordless SSH server at **127.0.0.1:8022**.
- ```upstream tls_router``` points to our alternative port HTTPS stack on **port 8443**.
- ```upstream tls_moe``` points to our PC with hostname **moe** at **192.168.20.100:443**.
- ```upstream tls_larry``` points to our PC with hostname **larry** at **192.168.20.101:443**.
- ```upstream tls_default``` points to our alternative port HTTPS stack on **port 8443**.

### <u>Map blocks</u>
- First map contains protocol detection.  Protocols beginning with ``TLSv1.`` gets directed to second
map.  No protocol detected gets directed to ```upstream ssh```.

- Second map contains routing for proxy server destination based on SNI (Server Name Indication).
No recognized SNI means it gets directed to ```upstream tls_default```, which points to the same
destination as ```upstream tls_router```.

### <u>Server blocks</u>
- First block listens to **port 443**, passing control to the specified proxy server. Note
that ``proxy_protocol on`` is set, preserving client IP address for the receiving server.

- Second block listens to **127.0.0.1 port 8022** with ```proxy_protocol off```, which **DOES NOT**
pass the client IP address to the proxy server, enabling SSH to work properly.  It proxies to 
**192.168.3.1:22**, which is the passwordless SSH server we set up earlier in this post.

----

## <u>Special Notes</u>

- OpenVPN should be able to be added by adding a new server block with a new port number
(aka ```127.0.0.1:8194```), like so:
```
	server {
		listen 127.0.0.1:8194 proxy_protocol;
		proxy_pass 127.0.0.1:1194;
		proxy_protocol off;  # << DO NOT CHANGE!  Breaks OpenVPN if you do! >>
	}
```
Also, ```upstream tls_default``` must be changed to point to the IP/port of your new server block, like so:
```
	upstream tls_default {
		server 127.0.0.1:8194;	# OpenVPN server
	}
```

- Hostnames are not recommended to be used within the ```stream``` block.  Some of the articles
that I've read seem to indicate that NGNIX doesn't resolve hostnames inside the ```stream``` block.  I
personally haven't tried using hostnames because the servers that I have are assigned IP addresses
within OpenWrt.

- Each of the proxy servers upstreams should have a static IP address assigned, either by
OpenWrt or within the server OS itself.  Assigning static IP addresses in OpenWrt was covered in
[My Router - Part 1: Static IP Addresses](http://localhost:4000/posts/router-part1/#static-ip-assignments).
It is beyond the scope of this post to assist with assigning static IP address within non-OpenWrt OSes.

----

## Summary

We've successfully set up our HTTPS port (port 443) multiplexer, enabling SSH and potentially 
OpenVPN to communcate on TCP port 443 alongside normal HTTPS traffic.  

Because we are preserving the client IP address on HTTPS communcation, all HTTPS communcation 
(if not modified) with the router domain name generates a 403 error code when accessed from 
outside our network, thus protecting our router setup from outside interference. 

SSH from the internet is protected by cryptographic public-private key pairs and does not
accept passwords, while leaving the in-network SSH able to log in using passwords.

OpenVPN on TCP ports should work, but this hasn't been tested as of this time since I have a 
WireGuard VPN configuration.

### Additional Information

- [Passwordless SSH Setup for OpenWrt with Dropbear](https://www.systutorials.com/how-to-passwordless-ssh-to-an-openwrt-router/)
- [How Does SSH Passwordless Login Work?](https://www.portnox.com/cybersecurity-101/authentication/ssh-passwordless-login/)
- [Using Nginx Stream Directive to Host SSH and Multiple HTTPS Servers On the Same Port](https://blog.thewalr.us/2019/04/05/using-nginx-stream-directive-to-host-ssh-and-multiple-https-servers-on-the-same-port/)
- [Can nginx serve SSH and HTTP(S) at the same time on the same port?](https://superuser.com/questions/1135208/can-nginx-serve-ssh-and-https-at-the-same-time-on-the-same-port/1328474#1328474)
- [Nginx stream - proxying OpenVPN](https://forum.opnsense.org/index.php?msg=113546)
- [Nginx TLS SNI routing, based on subdomain pattern](https://gist.github.com/kekru/c09dbab5e78bf76402966b13fa72b9d2)
