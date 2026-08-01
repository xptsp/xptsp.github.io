---
title: My Router - Part 5
description: Guest WiFi and Captive Portals
date: 2026-07-30 01:05:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

We're going to set up our Guest wifi, NoDogSplash as our captive portal, and install RNDIS
support so that we can connect our phone to the router so we have internet access when the
WAN device goes down.

Let's get to it!

----

## Guest Wifi

We need to create new guest network interface ```br-guest```:
```shell
uci -q delete network.guest_dev
uci set network.guest_dev="device"
uci set network.guest_dev.type="bridge"
uci set network.guest_dev.name="br-guest"
uci set network.guest_dev.bridge_empty='1'
uci -q delete network.guest
uci set network.guest="interface"
uci set network.guest.proto="static"
uci set network.guest.device="br-guest"
uci add_list network.guest.ipaddr='192.168.3.1/24'
uci add_list network.guest.dns='192.168.3.1'
uci commit network
service network restart
```

Next, we need to configure our wireless interfaces for the guest Wifi.  I am going to set
up a 2.4GHz guest access point called ```Nacho Wifi```.  Note that it is disabled at this
point.
```shell
WIFI_DEV="$(uci get wireless.@wifi-iface[0].device)"
uci -q delete wireless.guest
uci set wireless.guest="wifi-iface"
uci set wireless.guest.device="${WIFI_DEV}"
uci set wireless.guest.mode="ap"
uci set wireless.guest.network="guest"
uci set wireless.guest.ssid="Nacho Wifi"
uci set wireless.guest.encryption="none"
uci set wireless.guest.isolate='1'
uci set wireless.guest.ifname='wguest-24g'
uci set wireless.guest.disabled='1'
```

We also will set up a 5GHz guest access point called ```Nacho Wifi 5GHz```.  Note that
it is disabled at this point.
```shell
WIFI_DEV="$(uci get wireless.@wifi-iface[1].device)"
uci -q delete wireless.guest2
uci set wireless.guest2="wifi-iface"
uci set wireless.guest2.device="${WIFI_DEV}"
uci set wireless.guest2.mode="ap"
uci set wireless.guest2.network="guest"
uci set wireless.guest2.ssid="Nacho Wifi 5GHz"
uci set wireless.guest2.encryption="none"
uci set wireless.guest2.isolate='1'
uci set wireless.guest2.ifname='wguest-5ghz'
uci set wireless.guest2.disabled='1'
```

We need to commit the changes and reload the wifi configuration:
```shell
uci commit wireless
wifi reload
```

We need to create a DHCP pool for our new guest wifi.  It starts at ```192.168.3.100``` thru
```192.168.3.250```.  Restarting DNSMASQ is necessary once completed.
```shell
uci -q delete dhcp.guest
uci set dhcp.guest="dhcp"
uci set dhcp.guest.interface="guest"
uci set dhcp.guest.start="100"
uci set dhcp.guest.limit="150"
uci set dhcp.guest.leasetime="1h"
uci add_list dhcp.guest.dhcp_option='3,192.168.3.1'
uci add_list dhcp.guest.dhcp_option='6,192.168.3.1'
uci add_list dhcp.guest.dhcp_option='42,192.168.3.1'
uci set dhcp.guest.force="1"
uci commit dhcp
service dnsmasq restart
```
I'm specifying DHCP **option 3** to specify the router's Default Gateway, **option 6** to
specify the DNS servers, and **option 42** to specify the Network Time Protocol servers.

Default firewall for the "guest" zone is to reject input and forwarded packets, and allow
output packets.
```shell
uci -q delete firewall.guest
uci set firewall.guest="zone"
uci set firewall.guest.name="guest"
uci set firewall.guest.network="guest"
uci set firewall.guest.input="REJECT"
uci set firewall.guest.output="ACCEPT"
uci set firewall.guest.forward="REJECT"
```

We will allow forwarding between the guest network and WAN:
```shell
uci -q delete firewall.guest_wan
uci set firewall.guest_wan="forwarding"
uci set firewall.guest_wan.src="guest"
uci set firewall.guest_wan.dest="wan"
```

We have to always allow DNS requests, because otherwise any guest internet access to
useless without the ability to resolve DNS queries:
```shell
uci -q delete firewall.guest_dns
uci set firewall.guest_dns="rule"
uci set firewall.guest_dns.name="Allow-DNS-Guest"
uci set firewall.guest_dns.src="guest"
uci set firewall.guest_dns.dest_port="53"
uci set firewall.guest_dns.proto="tcp udp"
uci set firewall.guest_dns.target="ACCEPT"
```

We also have to always allow DHCP requests, because otherwise clients have to set their
static IP addresses.  Life is difficult enough: we don't want our guests to have to do this!
```shell
uci -q delete firewall.guest_dhcp
uci set firewall.guest_dhcp="rule"
uci set firewall.guest_dhcp.name="Allow-DHCP-Guest"
uci set firewall.guest_dhcp.src="guest"
uci set firewall.guest_dhcp.dest_port="67"
uci set firewall.guest_dhcp.proto="udp"
uci set firewall.guest_dhcp.family="ipv4"
uci set firewall.guest_dhcp.target="ACCEPT"
```

Lastly, I want to be able to access devices on the guest network from the LAN network,
but not the other way around.  You know, for the sake of Network Security:
```shell
uci set firewall.lan_guest="forwarding"
uci set firewall.lan_guest.src='lan'
uci set firewall.lan_guest.dest='guest'
```

We need to commit changes and restart firewall:
```shell
uci commit
service firewall restart
```

----

## Captive Portal

Nodogsplash is a Captive Portal that offers a simple way to provide restricted access
to the Internet by showing a splash page to the user before Internet access is granted.

Let's install it!
```shell
apk add nodogsplash
```

We need to change the gateway interface from ```br-lan``` to ```br-guest```.
Otherwise, the captive portal will be on the main network, and this will drive everybody
crazy!  Restarting the service is necessary once completed:
```shell
sed -i "s|option gatewayinterface .*|option gatewayinterface 'br-guest'|" /etc/config/nodogsplash
service nodogsplash restart
```

Now, when we go to ```http://openwrt.lan:2050/```, we see this (IMHO) ugly page:
![nodogsplash_before.webp](/assets/img/router/nodogsplash_before.webp){: lqip="data:image/webp;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAAOABgDAREAAhEBAxEB/8QAFwAAAwEAAAAAAAAAAAAAAAAAAAIDCP/EABkQAQEBAAMAAAAAAAAAAAAAAAEAEQIhMf/EABUBAQEAAAAAAAAAAAAAAAAAAAAB/8QAFREBAQAAAAAAAAAAAAAAAAAAABH/2gAMAwEAAhEDEQA/ANvcfa0UHqUC5QTHGBoCD//Z"}
This page is ugly and basic.  Then again, maybe that's what the author was going for.
Who knows....  Let's replace it:
```shell
FILE=/etc/nodogsplash/htdocs/splash.html
wget https://xptsp.github.io/assets/files/splash.template -O ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf
```
Now we get this:
![nodogsplash_after.webp](/assets/img/router/nodogsplash_after.webp){: lqip="data:image/webp;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAAOABgDAREAAhEBAxEB/8QAFwABAAMAAAAAAAAAAAAAAAAABQEECf/EABwQAAIDAAMBAAAAAAAAAAAAAAECAAQRAxIhMf/EABkBAAIDAQAAAAAAAAAAAAAAAAECAAMFB//EABcRAQEBAQAAAAAAAAAAAAAAAAEAEQL/2gAMAwEAAhEDEQA/AM+6iq+EzonXW2BzzldauvXclC1xE3UCQDRNooWT5G3YJkobBKfIEpsPf5id8is5f//Z"}
IMHO, much better!  Naturally, the background and wifi symbol image is a SVG image, so
replacing it in the ```splash.html``` is rather easy to do.  I got my background SVG file
from [SVG Backgrounds](https://www.svgbackgrounds.com/set/free-svg-backgrounds-and-patterns/).

You can customize this splash page to suit your needs, if desired.  Keep in mind that some
devices will not allow you to pull JS, CSS or images from the web server, so it is best to
have everything in one file to serve to the client.

Eventually, I'll explore how to do authenticated access through the captive portal.  I
don't think it'll be hard to do, but I haven't worked on that aspect yet....

----

## Summary

We have set up our Guest Wifi access points, plus a nifty looking captive portal!

Pretty sure we can still add things to our router!  [Onwards to Part 6!](http://localhost:4000/posts/router-part6/)

### Additional Information

- [OpenWrt Wiki: Guest Wi-Fi basics](https://openwrt.org/docs/guide-user/network/wifi/guestwifi/guest-wlan)
- [OpenWrt Wiki: NoDogSplash Captive Portal](https://openwrt.org/docs/guide-user/services/captive-portal/nodogsplash)
- [OpenWRT Wiki: Use RNDIS USB Dongle for WAN connection](https://openwrt.org/docs/guide-user/network/wan/wwan/ethernetoverusb_rndis)
