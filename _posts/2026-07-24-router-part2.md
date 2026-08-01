---
title: My Router - Part 2
description: Adding Adblocking, plus other OpenWrt customization for my Router!
date: 2026-07-24 22:56:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

We created an acceptable factory-equivant router in [the first part of this journey](/posts/router-part1/), but I know we can do better!
So let's add some essential services to our router!

---------

## Customize LUCI

> Note that all packages in my repo are compiled for the **aarch64_cortex-a53** architechiture, with exception of themes
> and config apps.  They may or may not work on other architechitures.  You have been warned!
{: .prompt-warning }

First, we need to add the XPtsp OpenWrt repo to the mix.
```shell
echo "https://xptsp.github.io/openwrt-repo/apk/aarch64_cortex-a53/packages.adb" >> /etc/apk/repositories.d/xptsp.list
wget http://xptsp.github.io/openwrt-repo/apk/aarch64_cortex-a53/xptsp.pem -O /etc/apk/keys/xptsp.pem
```

I frankly think the default theme for LUCI is terrible, so I'm installing a new theme.
I'm also configuring the wallpaper to use the on-device background present in the
theme package, as well as forcing dark mode:
```shell
apk add luci-theme-argon luci-app-argon-config luci-lib-ipkg
uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='none'
uci commit
```

I'm also replacing the default login wallpaper:
```shell
FILE=/www/luci-static/argon/img/bg1.jpg
wget https://xptsp.github.io/assets/img/router/bg1.jpg -O ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf
```
> All Images used are property of their respective trademark and/or copyright holders.
{: .prompt-tip }

Background used (found at [backiee.com](https://backiee.com/wallpaper/fiery-dragon-emblem-on-dark-leather/294394)):
![Wallpaper](/assets/img/router/bg1.jpg){: lqip="data:image/webp;base64,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OnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOkdJTVA9Imh0dHA6Ly93d3cuZ2ltcC5vcmcveG1wLyIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bXBNTTpEb2N1bWVudElEPSJnaW1wOmRvY2lkOmdpbXA6YzFjNmI2NjgtN2Y3NC00MjAxLThiN2EtMzBmY2U4NzAxNjQ1IiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjJkZTlmMjFiLWM1MmYtNDhmMS1hNjE3LThkYzlhMjc4NDZiOSIgeG1wTU06T3JpZ2luYWxEb2N1bWVudElEPSJ4bXAuZGlkOjQzOWNlYzk2LTQwODAtNDVjYi1hYmMxLWRjODlkNDc1ZDk1YyIgZGM6Rm9ybWF0PSJpbWFnZS9qcGVnIiBHSU1QOkFQST0iMi4wIiBHSU1QOlBsYXRmb3JtPSJMaW51eCIgR0lNUDpUaW1lU3RhbXA9IjE3NDUxOTQzNjAwNDIxMTEiIEdJTVA6VmVyc2lvbj0iMi4xMC4zMCIgeG1wOkNyZWF0b3JUb29sPSJHSU1QIDIuMTAiPiA8eG1wTU06SGlzdG9yeT4gPHJkZjpTZXE+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6Y2hhbmdlZD0iLyIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo5ZjVmYWE5ZS02MWNhLTQ1Y2MtYTMxOC05NzUyNDYyZTc1MWYiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkdpbXAgMi4xMCAoTGludXgpIiBzdEV2dDp3aGVuPSIyMDI1LTA0LTIwVDE5OjEyOjQwLTA1OjAwIi8+IDwvcmRmOlNlcT4gPC94bXBNTTpIaXN0b3J5PiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICA8P3hwYWNrZXQgZW5kPSJ3Ij8+"}

OpenWrt Login screenshot:
![Login Screen](/assets/img/router/login.webp){: lqip="data:image/webp;base64,UklGRjIAAABXRUJQVlA4ICYAAACwAgCdASoYAA4AP3Gixli0rCejsAgCkC4JaQAAeyAA/u1MrlAAAA=="}

OpenWrt Status page screenshot using Argon theme:
![Login Screen](/assets/img/router/status.webp){: lqip="data:image/webp;base64,UklGRjIAAABXRUJQVlA4ICYAAACwAgCdASoYAA4AP3Gixlk0rCejsAgCkC4JaQAAeyAA/uoDj8AAAA=="}

---------

## Network-wide Ad Blocking

We need to install and configure AdGuardHome.  I am sharing my AGH configuration file,
slighty modified to change the password held within.
```shell
apk add adguardhome luci-app-adguardhome
wget https://xptsp.github.io/assets/files/adguardhome.yaml -O /etc/adguardhome/adguardhome.yaml
```

We need to move dnsmasq to port 54 so AdGuardHome can use port 53:
```shell
NET_ADDR=$(uci get network.lan.ipaddr | cut -d\/ -f 1)
uci set dhcp.@dnsmasq[0].noresolv='0'
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].rebind_protection='0'
uci set dhcp.@dnsmasq[0].port='54'
uci set dhcp.@dnsmasq[0].nonwildcard='0'
uci -q delete dhcp.@dnsmasq[0].server
uci set dhcp.lan.leasetime='24h'
uci -q delete dhcp.lan.dhcp_option
uci -q delete dhcp.lan.dns
uci add_list dhcp.lan.dhcp_option='3,'"${NET_ADDR}"
uci add_list dhcp.lan.dhcp_option='6,'"${NET_ADDR}"
```

We need to set up the firewall rule to redirect all DNS requests (port 53) to
the router.  This way, devices can't access other DNS services, bypassing AGH.
```shell
uci -q del firewall.dns_int
uci set firewall.dns_int='redirect'
uci set firewall.dns_int.family='any'
uci set firewall.dns_int.name='DNS to AdGuardHome'
uci set firewall.dns_int.src='lan'
uci set firewall.dns_int.src_dport='53'
uci set firewall.dns_int.proto='tcp udp'
uci set firewall.dns_int.target='DNAT'
uci set firewall.dns_int.dest_port='53'
```

We also need to set up a firewall rule to block DNS-over-TLS (DoT - port 853).
This is another way for devices to avoid using AGH.
```shell
uci set firewall.block_dot=rule
uci set firewall.block_dot.name='Block DoT from LAN'
uci set firewall.block_dot.src='lan'
uci set firewall.block_dot.dest='wan'
uci set firewall.block_dot.proto='tcp udp'
uci set firewall.block_dot.dest_port='853'
uci set firewall.block_dot.target='REJECT'
```

Now restart services so we can enjoy far less ads on our network!
```shell
uci commit
service firewall restart
service dnsmasq restart
service adguardhome restart
```

The web address for the AGH on your router is ```http://openwrt.lan:3000/```
(unless you've changed the hostname).  Username is **root**, password is **admin**.

I highly recommend changing the username/password credentials.  I recommend reading the page at
[https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#password-reset](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#password-reset)
for advice on how to do this.

Restarting the **adguardhome** service after making changes to **/etc/adguardhome/adguardhome.yml** is
necessary.

---------

## Network-wide Network Time

Let's enable the built-in NTP server for OpenWrt.  I'm in the **America/Chicago** timezone,
so these settings are appropriate for me.
```shell
uci set system.ntp.enable_server='1'
uci set system.@system[0].zonename='America/Chicago'
uci set system.@system[0].timezone='CST6CDT,M3.2.0,M11.1.0'
```

We need to add a DHCP option for clients to use the NTP server on the router:
```shell
NET_ADDR=$(uci get network.lan.ipaddr | cut -d\/ -f 1)
uci add_list dhcp.lan.dhcp_option="42,${NET_ADDR}"
```

Let's configure firewall to force clients to use our NTP server.  According to Google,
```Redirecting NTP requests through a firewall is essential to ensure that internal devices
synchronize their time with a designated NTP server, rather than relying on potentially
unreliable external servers. This helps maintain network security and time accuracy across devices.```
```shell
uci set firewall.ntp="redirect"
uci set firewall.ntp.family='any'
uci set firewall.ntp.name='Redirect NTP'
uci set firewall.ntp.target='DNAT'
uci set firewall.ntp.src='lan'
uci set firewall.ntp.src_dport='123'
uci set firewall.ntp.proto='udp'
uci set firewall.ntp.dest_port='123'
```

Finally, we need to commit changes and restart services:
```shell
uci commit
service sysntpd restart
service dnsmasq restart
```

----

## Wake-On-LAN

I need this so I can power on a machine if I need to access it remotely:
```shell
apk add luci-app-wol
uci set etherwake.setup.interface='br-lan'
uci commit
```

Let's add some targets so we can easily wake my machines over the network:
```shell
uci add luci-wol.moe_pc=target
uci set luci-wol.moe_pc.name='Moe'
uci set luci-wol.moe_pc.mac='F2:B0:C4:87:4A:13'
uci set luci-wol.moe_pc.iface='br-lan'
uci set luci-wol.moe_pc.broadcast='1'

uci add luci-wol.larry_pc=target
uci set luci-wol.larry_pc.name='Larry'
uci set luci-wol.larry_pc.mac='12:BE:29:E0:97:CC'
uci set luci-wol.larry_pc.iface='br-lan'
uci set luci-wol.larry_pc.broadcast='1'

uci add luci-wol.curly_pc=target
uci set luci-wol.curly_pc.name='Curly'
uci set luci-wol.curly_pc.mac='CA:70:26:36:EF:31'
uci set luci-wol.curly_pc.iface='br-lan'
uci set luci-wol.curly_pc.broadcast='1'

uci add luci-wol.shemp_pc=target
uci set luci-wol.shemp_pc.name='Shemp'
uci set luci-wol.shemp_pc.mac='66:1C:C8:CC:AD:43'
uci set luci-wol.shemp_pc.iface='br-lan'
uci set luci-wol.shemp_pc.broadcast='1'
```
----

## Summary

Now that we are done instaling some additional services on our router, let's install
USB support, as well as file sharing programs and a PXE Boot server.
[Onwards to Part 3!](https://xptsp.github.io/posts/router-part3/)

### Additional Information

- [OpenWrt Wiki: AdGuard Home](https://openwrt.org/docs/guide-user/services/dns/adguard-home)
- [OpenWrt Wiki: NTP Client / NTP Server](https://openwrt.org/docs/guide-user/services/ntp/client-server)
- [OpenWrt Wiki: Wake-On-Lan](https://openwrt.org/docs/guide-user/services/w_o_l/wol)
