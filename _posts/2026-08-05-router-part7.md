---
title: My Router - Part 7
description: WireGuard Setup
date: 2026-08-05 10:50:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

Okay, we"ve created a "super" router, but is it really super if we can"t access our services
from **OUTSIDE** the network?  After all, we might need to fix issues from afar, and as long
as we have internet access, I should and want to be able to do so.

We will create 2 types of wireguard servers, one trusted and one untrusted.  We will also create
client configurations for each server, as well as set up a firewall rule for ***UDP port 443***.

Finally, we will create firewall rules to expose ***UDP port 443*** to the internet.

----

## Preparation

We need to install the packages:
```shell
apk add luci-proto-wireguard qrencode
```

We also need to give the default zones proper names so it is easier to refer to them:
```shell
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
```

## Trusted Wireguard Interface

In this example, I will be creating a server with 2 clients in the trusted zone.  Let"s
define a wireguard server that listens on **port 51820** with an IPv4 range of
**192.168.9.1/24** and an IPv6 address of **fd00:9::1/64**.

### Create trusted Interface

```shell
VPN_IF=trusted
VPN_ADDR="192.168.9.1/24"
VPN_ADDR6="fd00:9::1/64"
VPN_SERVER=$(uci get ddns.@service[0].domain)
VPN_PORT=51820

uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}=interface
uci set network.${VPN_IF}.description="Trusted"
uci set network.${VPN_IF}.proto="wireguard"
uci set network.${VPN_IF}.private_key="$(wg genkey)"
uci set network.${VPN_IF}.multipath="off"
uci set network.${VPN_IF}.listen_port="${VPN_PORT}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR6}"
```

### Generate 2 Clients for trusted

> Change the **2** in **{1..2}** loop statement to the number of clients you want to generate.
{: .prompt-tip }

```shell
for i in {1..2}; do
	IP=$(( ${i} + 1 ))
	PRV_KEY="$(wg genkey)"
	uci -q delete network.${VPN_IF}_client${i}
	uci set network.${VPN_IF}_client${i}=wireguard_${VPN_IF}
	uci set network.${VPN_IF}_client${i}.description="Client ${i}"
	uci set network.${VPN_IF}_client${i}.private_key="${PRV_KEY}"
	uci set network.${VPN_IF}_client${i}.public_key="$(echo ${PRV_KEY} | wg pubkey)"
	uci set network.${VPN_IF}_client${i}.preshared_key="$(wg genpsk)"
	uci add_list network.${VPN_IF}_client${i}.allowed_ips="${VPN_ADDR%.*}.${IP}/32"
	uci add_list network.${VPN_IF}_client${i}.allowed_ips="${VPN_ADDR6%:*}:${IP}/128"
	uci set network.${VPN_IF}_client${i}.endpoint_host="${VPN_SERVER}"
	uci set network.${VPN_IF}_client${i}.endpoint_port="443"
	uci set network.${VPN_IF}_client${i}.dns="${VPN_ADDR}"
done
```

### Add trusted interface to LAN zone

```shell
uci del_list firewall.lan.network="trusted"
uci add_list firewall.lan.network="trusted"
```

----

## Untrusted Wireguard Interface

In this example, I will be creating a server with 3 clients in an untrusted zone.  Let"s
define a wireguard server that listens on **port 51821** with an IPv4 range of
**192.168.8.1/24** and an IPv6 address of **fd00:8::1/64**.  Devices in the LAN zone will
be allowed to communicate with any devices in the untrusted zone, but devices from the
untrusted zone cannot initiate communication with anything else.

### Create untrusted Interface

```shell
VPN_IF=untrusted
VPN_ADDR="192.168.8.1/24"
VPN_ADDR6="fd00:8::1/64"
VPN_SERVER=$(uci get ddns.@service[0].domain)
VPN_PORT=51821

uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}=interface
uci set network.${VPN_IF}.description="Untrusted"
uci set network.${VPN_IF}.proto="wireguard"
uci set network.${VPN_IF}.private_key="$(wg genkey)"
uci set network.${VPN_IF}.multipath="off"
uci set network.${VPN_IF}.listen_port="${VPN_PORT}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR6}"
```

### Generate 3 Clients for untrusted

> Change the **3** in **{1..3}** loop statement to the number of clients you want to generate.
{: .prompt-info }

```shell
for i in {1..3}; do
	IP=$(( ${i} + 1 ))
	PRV_KEY="$(wg genkey)"
	uci -q delete network.${VPN_IF}_client${i}
	uci set network.${VPN_IF}_client${i}=wireguard_${VPN_IF}
	uci set network.${VPN_IF}_client${i}.description="Client ${i}"
	uci set network.${VPN_IF}_client${i}.private_key="${PRV_KEY}"
	uci set network.${VPN_IF}_client${i}.public_key="$(echo ${PRV_KEY} | wg pubkey)"
	uci set network.${VPN_IF}_client${i}.preshared_key="$(wg genpsk)"
	uci add_list network.${VPN_IF}_client${i}.allowed_ips="${VPN_ADDR%.*}.${IP}/32"
	uci add_list network.${VPN_IF}_client${i}.allowed_ips="${VPN_ADDR6%:*}:${IP}/128"
	uci set network.${VPN_IF}_client${i}.endpoint_host="${VPN_SERVER}"
	uci set network.${VPN_IF}_client${i}.endpoint_port="443"
done
```

### Create new untrusted firewall zone

```shell
uci set firewall.untrusted_zone=zone
uci set firewall.untrusted_zone.name="untrusted"
uci set firewall.untrusted_zone.input="REJECT"
uci set firewall.untrusted_zone.output="ACCEPT"
uci set firewall.untrusted_zone.forward="REJECT"
uci set firewall.untrusted_zone.network="${VPN_IF}"
```

### Allow LAN to communicate with untrusted zone:

```shell
uci set firewall.lan_untrusted=forwarding
uci set firewall.lan_untrusted.src="lan"
uci set firewall.lan_untrusted.dest="untrusted"
```

Let's commit our changes and restart affected services:
```shell
uci commit
service network restart
service firewall restart
```

-----

## Multiple Wireguard Proxy (MWGP)

If you've noticed, all the clients have an endpoint port of 443.  This is not a mistake.  Since all
incoming Wireguard communication is going to come in on port 443, we need a proxy to figure out where
to send it.  That's where MWGP comes into play.  MWGP generates its ```config.json``` from the wireguard
configuration in ```/etc/config/network```.

Unfortunately, I have had trouble creating an OpenWrt APK package for MWGP.  So instead, let's download
the binary that I built:
```shell
wget https://xptsp.github.io/assets/files/mwgp.arm64 -O /usr/bin/mwgp
```
Or you can compile this program yourself for our router.  It'll probably have to be done on a host
PC, since storage on the router is very constrainted.  We also have to transfer it to the router:
```shell
git clone https://github.com/apernet/mwgp /tmp/mwgp
cd /tmp/mwgp
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w" -trimpath -o mwgp ./cmd/mwgp
scp mwgp root@openwrt.lan:/usr/bin/
```

I've written a init.d service for MWGP, which (by default) listens on **UDP port 1000**, which we're
going to modify to listen on **UDP port 443**.  At this time, no MWRP configuration options are available
within the init script.
```shell
FILE=/etc/init.d/mwgp
wget https://raw.githubusercontent.com/xptsp/openwrt-mwgp/refs/heads/main/files/mwgp.init -O ${FILE}
sed -i "s|1000|443|g" ${FILE}
chmod +x ${FILE}
echo ${FILE} >> /etc/sysupgrade.conf

chmod +x /usr/bin/mwgp
echo /usr/bin/mwgp >> /etc/sysupgrade.conf

service mwgp enable
service mwgp start
```

----

## Wireguard Firewall Rule

We need to expose the **UDP port 443** to the internet so we can connect to it:
```shell
uci set firewall.wg_from_wan='rule'
uci set firewall.wg_from_wan.src='wan'
uci set firewall.wg_from_wan.name='Allow-Wireguard-from-WAN'
uci set firewall.wg_from_wan.proto='udp'
uci set firewall.wg_from_wan.dest_port='443'
uci set firewall.wg_from_wan.target='ACCEPT'
uci commit
 service firewall restart
```

---

## Summary

Yay!  We've got a trusted wireguard server for Android phones, plus an untrusted wireguard server
for devices that I want to keep tabs on if they ever disappear, then get connected to the internet....

What else can we do?

### Additional Information

- [OpenWrt Wiki: WireGuard server](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)
- [GitHub: Multiple Wireguard Proxy](https://github.com/apernet/mwgp)
- [[CodePen: Gandalf 403 Error Page](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://codepen.io/anjanas_dh/pen/ZMqKwb&ved=2ahUKEwiKnJ6Bw5uWAxWN4skDHUKHIzwQFnoECCMQAQ&usg=AOvVaw0g-_P-8LUBizQNCQoDnTkj).]
