---
title: My Router
description: Beginning the Customization of OpenWrt on my Router!
date: 2026-07-23 02:08:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
force_url: /tags/router/
pin: true
---

# The Purchase

About 3 years ago, I purchased a [Linksys E8450 Router](https://www.amazon.com/dp/B08LMQLG7X)
from Amazon.  I [did my research](https://openwrt.org/toh/linksys/e8450) and decided on this router
because it was upgradable to OpenWrt.  Looked easy enough to upgrade...  Nervous as hell, though.
After getting brave enough to modify my new toy, I executed the 
[OpenWRT upgrade instructions](https://openwrt.org/toh/linksys/e8450#how_to_convert_to_ubi_layout).
I will not duplicate these instructions, as the linked page contains everything that is needed to
upgrade this router to OpenWRT.  It is also meant to be done only once per device, and
mine has been done the first time for many years, and again to upgrade to **24.10**....

I've also documented the changes I've made to my OpenWrt installation, and this series
is meant to reflect the documentation I've made.

# The Expected Destination

By the end of this series, we will have customized our installation of
[OpenWRT 25.12.5](https://downloads.openwrt.org/releases/25.12.5/targets/mediatek/mt7622/)
for this router, then created and flashed our custom firmware to flash to it.  This will
enable us to reset to our defaults easily (as opposed to the unmodified firmware defaults),
in the event we screw something up royally (which I've done **WAY** too many times)...

# Router Basics

> This is a **ONE-SIZE FITS MINE** documentation!  It should be noted that these
> instructions work for this specific router, and adjustments for other routers should
> be made.
{: .prompt-warning }

Okay, I'm going to start listing the basic settings that I feel are a requirement for my router.  Please note,
any MAC addresses, credentials, and domain names listed are **NOT** the ones I use, so don't think I'm handing
out the keys to my kingdom.  I'm not stoopid...

We need to SSH into our router.  Note that these instructions assume an unmodified
installation.  If you've already modified the router IP address, use that instead.
```shell
ssh root@192.168.1.1
```

We need to set root password to **MoeLarryCurly**.  This prevents unauthorized access:
```shell
(echo MoeLarryCurly; echo MoeLarryCurly) | passwd
```

We're enabling the setting to check for upgrades to the firmware.  This should be set to
**0** if you don't want to be reminded that there is an upgrade available.  IMHO, I'm
trying to stay secure as possible, so it's always **1** for me:
```shell
uci set attendedsysupgrade.client.login_check_for_upgrades='1'
```

Next, we're configuring my 2.4GHz Wifi access point:
```shell
uci -q del wireless.radio0.disabled
uci set wireless.radio0.htmode='HT40'
uci set wireless.radio0.cell_density='0'
uci set wireless.radio0.country='US'
uci set wireless.radio0.channel='6'

uci -q del wireless.default_radio0.disabled
uci set wireless.default_radio0.ssid='Four Stooges'
uci set wireless.default_radio0.encryption='psk-mixed'
uci set wireless.default_radio0.key='MoeLarryCurlyShemp4'
uci set wireless.default_radio0.ocv='0'
uci set wireless.default_radio0.ifname="wlan-24g"
```

Can't forget the 5GHz Wifi access point:
```shell
uci -q del wireless.radio1.disabled
uci set wireless.radio1.htmode='VHT20'
uci set wireless.radio1.cell_density='0'
uci set wireless.radio1.country='US'
uci set wireless.radio1.channel='36'

uci del wireless.default_radio1
uci set wireless.wifinet1=wifi-iface
uci set wireless.wifinet1.device='radio1'
uci set wireless.wifinet1.mode='ap'
uci set wireless.wifinet1.ssid='Four Stooges 5GHz'
uci set wireless.wifinet1.encryption='sae'
uci set wireless.wifinet1.ifname='wlan-5G'
uci set wireless.wifinet1.key='MoeLarryCurlyShemp4'
uci set wireless.wifinet1.ocv='0'
```

We're changing the default router address to **192.168.20.1**.  This should help prevent
expected future conflicts with our planned VPN on other networks:
```shell
uci -q del dhcp.lan.ra_slaac
uci set dhcp.lan.ra_preference='medium'
uci del network.lan.ipaddr
uci add_list network.lan.ipaddr='192.168.20.1/24'
uci set network.lan.multipath='off'
```

Gotta add our static IP assignments, so that my equipment ends up where I expect them
to be.  And no, these are **NOT** my machine names!  (Notice a theme?)
```shell
uci set dhcp.moe_pc=host
uci set dhcp.moe_pc.name='Moe'
uci set dhcp.moe_pc.dns='1'
uci set dhcp.moe_pc.ip='192.168.20.100'
uci set dhcp.moe_pc.mac='F2:B0:C4:87:4A:13'

uci set dhcp.larry_pc=host
uci set dhcp.larry_pc.name='Larry'
uci set dhcp.larry_pc.dns='1'
uci set dhcp.larry_pc.mac='12:BE:29:E0:97:CC'
uci set dhcp.larry_pc.ip='192.168.20.101'

uci set dhcp.curly_pc=host
uci set dhcp.curly_pc.name='Curly'
uci set dhcp.curly_pc.dns='1'
uci set dhcp.curly_pc.mac='CA:70:26:36:EF:31'
uci set dhcp.curly_pc.ip='192.168.20.102'

uci set dhcp.shemp_pc=host
uci set dhcp.shemp_pc.name='Shemp'
uci set dhcp.shemp_pc.dns='1'
uci set dhcp.shemp_pc.mac='66:1C:C8:CC:AD:43'
uci set dhcp.shemp_pc.ip='192.168.20.103'
```

We're changing my router's IPv4 and IPv6 DNS providers to CloudFlare:
```shell
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"

uci set network.wan6.peerdns="0"
uci -q delete network.wan6.dns
uci add_list network.wan6.dns="2606:4700:4700::1111"
uci add_list network.wan6.dns="2606:4700:4700::1001"
```

Computer **Larry** is a Raspberry Pi with 2 access points.  Since they are not a part of
the planned network for **THIS** router, we have to add routing for those devices so I can
access them from my main machine:
```shell
uci add network route
uci set network.@route[-1].interface='lan'
uci set network.@route[-1].target='192.168.4.0/24'
uci set network.@route[-1].gateway='192.168.20.101'

uci add network route
uci set network.@route[-1].interface='lan'
uci set network.@route[-1].target='192.168.5.0/24'
uci set network.@route[-1].gateway='192.168.20.101'
```

We need to enable dropping invalid packets and enable software and hardware flow offloading:
```shell
uci set firewall.@defaults[0].drop_invalid='1'
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'
```

We need to disable binding dnsmasq's DNS to interfaces and fix race condition for DHCP.
```shell
uci set dhcp.@dnsmasq[0].nonwildcard='0'
uci set dhcp.lan.force="1"
```

We need to commit these changes now, but we're not going to reboot the router yet:
```shell
uci commit
```

We need a better shell than what busybox offers, so we're going to install **bash**, change
the default shell for **root**, then upgrade **wget** to the full version that supports
HTTPS.  We also need to download the bash initialization script, and create a dos-equivalant
**cls** command using the built-in **clear** command:
```shell
# Install bash, change default shell
apk update
apk add bash wget-ssl
sed -i "s|/bin/ash|/bin/bash|g" /etc/passwd

# Download bash startup script:
FILE=/root/.shinit
wget https://github.com/xptsp/bpiwrt-builder/raw/master/files/root/.bashrc -O ${FILE}
sed -i "s|32m|31m|" ${FILE}
chmod +x ${FILE}
echo "alias cls=clear" >> ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf
```

We also want uPnP services installed on this router:
```shell
apk add luci-app-upnp
uci set upnpd.config.enabled="1"
uci commit
service miniupnpd restart
```

Okay, now we're ready to reboot the router....
```shell
reboot
```
What we've configured is is an acceptable factory-equivant router, sans possible USB
support (unknown if factory firmware has this).  This is okay, but I know we can do
better than factory-equivant router firmware!  After all, we installed OpenWRT!!!

Once the router has rebooted, the new IP address is **192.168.20.1**...  Onwards!
