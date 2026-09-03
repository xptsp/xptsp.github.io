---
title: My Router - Part 9
description: DoT and DoH Services
date: 2026-08-29 0:00:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

## Adding SSL certificates to AdGuardHome

Since we installed AdGuardHome in [Part 2 of this series](/posts/router-part2/#network-wide-ad-blocking),
and both ACME and DDNS in [Part 4 of this series](/posts/router-part4/), we can modify the AdguardHome
configuration to enable DoH and DoT:
```shell
FILE=/etc/adguardhome/adguardhome.yaml
sed -i "s|server_name: .*|server_name: dns.${DOMAIN}|g" ${FILE}
sed -i "s|certificate_path: .*|certificate_path: /etc/acme/${DOMAIN}_ecc/fullchain.cer|g" ${FILE}
sed -i "s|private_key_path: .*|private_key_path: /etc/acme/${DOMAIN}_ecc/${DOMAIN}.key|g" ${FILE}
sed -i "s|port_https: .*|port_https: 3001|g" ${FILE}
sed -i '/^tls:/{n;s/.*/  enabled: true/}' ${FILE}
sed -i 's|insecure_enabled:.*|insecure_enabled: true|g' ${FILE}
```

we need to add the directory to the jail mounts so the AGH can actually read the certificate
and key, and change ownership and permissions:
```shell
chown root:adguardhome /etc/acme/*/*.key
chmod 640 /etc/acme/*/*.key
uci add_list adguardhome.config.jail_mount='/etc/acme/'
uci commit
```

Finally, we need to restart AdGuardHome so it can listen for DNS requests from
DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH).
```
service adguardhome restart
```

Now AGH is available at ```https://router.example.com:3001```, fully excrypted!
Note that ```https://openwrt.lan:3001``` will give errors, but that's because the name
in the SSL certificate doesn't match the hostname used.

Is it possible to fix this particular issue?  Nope, no way to build a SSL certificate
through Let's Encrypt for these domain names....

---

## DNS-over-HTTPS (DoH) Access

AdGuardHome is now "secured" at ```https://openwrt.lan:3001```.  However, the SSL certificate
cannot match the hostname because the certificate will never be able to include the hostname,
so accessing it through that name is impractical for common use.

Since we installed Nginx in [Part 4 of this series](/posts/router-part4/#replace-uhttpd-with-nginx),
we need to add a Nginx configuration section to pass any DNS requests over DoH to AdGuardHome:
```shell
uci set nginx.https_dns=server
uci add_list nginx.https_dns.listen='443 ssl'
uci add_list nginx.https_dns.listen='[::]:443 ssl'
uci add_list nginx.https_dns.include='conf.d/error_403.locations'
uci set nginx.https_dns.server_name='dns.'${DOMAIN}
uci set nginx.https_dns.ssl_certificate='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.cer'
uci set nginx.https_dns.ssl_certificate_key='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.key'
uci set nginx.https_dns.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_dns.ssl_session_timeout='64m'
uci set nginx.https_dns.access_log='off; # logd openwrt'
uci set nginx.https_dns.location='/ { deny all; } # dns'
uci add_list nginx.https_dns.location='/dns-proxy { proxy_pass https://127.0.0.1:3001; allow all; proxy_set_header X-Real-IP $proxy_protocol_addr; proxy_set_header X-Forwarded-For $proxy_protocol_addr; proxy_set_header Host $host; } # dns'
uci commit
service nginx restart
```

Now your new DNS-over-HTTPS server is available at ```https://dns.example.com```!

---

## Allowing DNS-over-TLS (DoT) from WAN

If access to your DoT server from outside your intranet is desired, then we
have to configure firewall to allow port 853 through:
```shell
uci -q del firewall.dot
uci set firewall.dot="rule"
uci set firewall.dot.name='Allow DoT from WAN'
uci set firewall.dot.src='wan'
uci set firewall.dot.dest_port='853'
uci add_list firewall.dot.proto='tcp'
uci set firewall.dot.target='ACCEPT'
uci commit
service firewall restart
```

----

## Blocking DNS-over-TLS from LAN

We honestly don't want our connected devices to communcate outside our network using DoT.

Unfortunately, we can't redirect port 853 to the router because all requests would then fail
the SSL certificate test.  We can't fix this particular situation, so lets just block DoT
(port 853) from LAN using a firewall rule.  This will force the client to failback to regular
DNS requests, which we can redirect!
```shell
uci set firewall.block_dot=rule
uci set firewall.block_dot.name='Block DoT from LAN'
uci set firewall.block_dot.src='lan'
uci set firewall.block_dot.dest='wan'
uci set firewall.block_dot.proto='tcp udp'
uci set firewall.block_dot.dest_port='853'
uci set firewall.block_dot.target='REJECT'
uci commit
service firewall restart
```

---

## Fixing DNS requests from LAN and WAN

We have a situation now.  DNS requests from the WAN should obivously reach the WAN interface.
This is expected and good!  However, traffic from the LAN might make our data transfer over
the WAN interface increase dramatically.  I do not want to pay higher internet bills simply
because I can't keep the LAN from communication with services exposed via WAN from using WAN
bandwidth....  What can I do, what can I do?

I know!  We can rewrite the DNS requests to our services coming from our LAN interfaces!  We
need to edit ```/etc/adguardhome/adguardhome.yaml```.  Scroll down to the line that reads
```clients``` and insert this block:
```
clients:
  runtime_sources:
    whois: true
    arp: true
    rdns: true
    dhcp: true
    hosts: true
  persistent:
    - safe_search:
        enabled: false
        bing: true
        duckduckgo: true
        ecosia: true
        google: true
        pixabay: true
        yandex: true
        youtube: true
      blocked_services:
        schedule:
          time_zone: UTC
        ids: []
      name: LAN
      ids:
        - 192.168.20.0/24
        - 192.168.8.0/24
      tags: []
      upstreams:
        - '[/pool.ntp.org/]1.1.1.2'
        - '[/pool.ntp.org/]1.0.0.2'
        - '[/pool.ntp.org/]2606:4700:4700::1112'
        - '[/pool.ntp.org/]2606:4700:4700::1002'
        - '[/lan/]127.0.0.1:54'
        - '[//]127.0.0.1:54'
        - tls://security.cloudflare-dns.com
      uid: 01a05025-0a8b-73e0-91fa-7d0ee5b11fb2
      upstreams_cache_size: 0
      upstreams_cache_enabled: false
      use_global_settings: true
      filtering_enabled: false
      parental_enabled: false
      safebrowsing_enabled: false
      use_global_blocked_services: true
      ignore_querylog: false
      ignore_statistics: false
    - safe_search:
        enabled: true
        bing: true
        duckduckgo: true
        ecosia: true
        google: true
        pixabay: true
        yandex: true
        youtube: true
      blocked_services:
        schedule:
          time_zone: UTC
        ids: []
      name: Guests
      ids:
        - 192.168.3.0/24
      tags: []
      upstreams:
        - tls://1.1.1.3
        - tls://1.0.0.3
        - tls://2606:4700:4700::1113
        - tls://2606:4700:4700::1003
      uid: 01a01b8e-b089-779d-84db-d6eca8e77ba1
      upstreams_cache_size: 0
      upstreams_cache_enabled: false
      use_global_settings: false
      filtering_enabled: true
      parental_enabled: true
      safebrowsing_enabled: true
      use_global_blocked_services: true
      ignore_querylog: false
      ignore_statistics: false
```

---

### AGH Clients: 192.168.20.0/24 and 192.168.8.0/24

What does this do?  Well, the first block defines the LAN interface as ```192.168.20.0/24``` (our 
LAN interface) and ```192.168.8.0/24``` (our trusted Wireguard interface).  Global settings are
used, but DNS servers are copied from global settings.

---

### AGH Clients: 192.168.3.0/23

This IP address range defines our Wifi Guest network.  We want this network to use CloudFlare's
[Malware and adult content blocking](https://adguard-dns.io/kb/general/dns-providers/#malware-and-adult-content-blocking)
DNS servers.

These client settings do the following:
- Uncheck ```Use global settings``` for these clients
- Enable ```Block domains using filters and hosts files``` for these clients
- Enable ```Use AdGuard browsing security web service``` for these clients, which checks to
see if domain is blocked by the browsing security web service.
- Enable ```Use AdGuard parental control web service``` for these clients, which checks if
domain contains adult materials.
- Enable ```Use Safe Search``` to enforce Safe Search on Google, YouTube, Bing, DuckDuckGo,
Ecosia, Yandex, and Pixabay.
- Keep ```Ignore this client in query log``` unchecked
- Keep ```Ignore this client in statistics``` unchecked

Our guests don't like this?  Awwww, I don't care, they can use their mobile data for web browsing.  Don't
have that?  Too bad...

---

## Custom Filtering Rules

Now that we have our LAN clients clearly defined, we can add some custom filtering rules to aid
in solving the problem.  Let's edit ```/etc/adguardhome/adguardhome.yaml``` again:
```
user_rules:
  - '||*.example.com^$client=LAN,dnsrewrite=192.168.20.1'
```
This forces LAN DNS requests to our external domain name to have the LAN IP address of our
router.  So executing ```nslookup meh.example.com``` on our router would return ```192.168.20.1```,
but a DNS request from outside our network would return the proper WAN IP address that our
router uses.

The filtering rule must **ALWAYS** have ONLY subdomains specified (aka ```*.example.com```), 
**NEVER** the top-level domain (aka ```example.com```).  Doing otherwise will keep server 
connections, for example WireGuard and HTTPS, from working properly, especially if you have 
the Private DNS setting on your phone/tablet set!  

----

## Summary

We've set up DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH), as well as shared both with the
Internet.  We've also restricted Guest clients to "safer" DNS service, while keeping the
regular LAN-side DNS service normal.  What else can we do?
