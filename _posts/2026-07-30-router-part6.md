---
title: My Router - Part 6
description: Tang, DropBear mods, VLMCSD, Peanut and ZRAM Swap
date: 2026-07-30 12:05:00 -0600
categories: [Router]
tags: [Router]
image:
  path: /assets/img/router/e8450_side.webp
  lqip: data:image/webp;base64,UklGRhYBAABXRUJQVlA4WAoAAAAQAAAAFwAAFwAAQUxQSMQAAAAJuS5E9D80lBLZlm1bvCfg8f37/PxWfQsN8QUMZn+RYiImYAJ+/cMPg7/87e76k5qfzO9s7z3P/OZ01ZXeRq+H1RRaqJbFzmC9QtpR9IGbe3XmQxGZdq/bTfq4o3u123KfqGC3bjdDHKJbt9zOx4Q26OZ8XVtncNiHsJg+fHO4EaFPxplBKJ/eWG7YicScZWtqp4T/53Xrhp0+0m63MU3ro1rrXt0eXKp0tlVvTbaDW6uinnaiWoLQZo0RFoLC2JaZbcYAVlA4ICwAAADwAgCdASoYABgAP3Gszl20rSokqAqqkC4JaQAAO30RAAD+5hLzFFTzMvgAAA==
  width: 190
  height: 190
---

## Tang

Running a Tang server on OpenWrt allows you to set up Network-Bound Disk Encryption (NBDE)
using a lightweight router instead of a full Linux server.  Let's install and configure Tang:
```shell
apk add tang
uci set tang.config.enabled='1'
uci commit
service tang restart
```
> Note that the keys to your Tang server are stored in ```/usr/share/tang/db``` and are automatically
> backed up when creating a configuration backup.
{: .prompt-info }

That's all you need for the server side.  For client side instructions, I suggest reading
[Network Bound Disk Encryption with clevis and tang on OpenWRT](https://zaage.it/tutorials/network-bound-disk-encryption-with-clevis-and-tang-on-openwrt/),
as that website is very helpful.

----

## OpenSSH SFTP server

For some reason, the package ```openssh-sftp-server``` seems to be missing from the
default OpenWRT 25.12.x install (at least on mine it is missing).  As a result, I
can't ```scp``` from my computer to anywhere in the router.

Let's fix this:
```shell
apk add openssh-sftp-server
```

----

## Fixing DropBear Passwordless Access

It seems that ```ssh-copy-id``` fails because it appends to ```$HOME/.ssh/authorized_keys```
instead of ```/etc/dropbear/authorized_keys```.  We can fix this by symlinking the two files
so that ```ssh-copy-id``` will work properly:
```shell
mkdir -p /root/.ssh
ln -sf /etc/dropbear/authorized_keys /root/.ssh/authorized_keys
echo "/root/.ssh/authorized_keys" >> /etc/sysupgrade.conf
```

----

## SSH Passwordless access from Guest Network

Using passwordless SSH access (key-based authentication) over the guest network stops 
brute-force password hacks and makes logging in safer and easier.  It uses math keys
instead of typed words.

Why Use Passwordless SSH:
- No Brute-Force Risks: “Since there is no password to guess, attackers cannot perform
brute-force attacks to gain access,” as explained by [Portnox](https://www.portnox.com/cybersecurity-101/authentication/ssh-passwordless-login/).
- Stronger Security: Cryptographic key pairs (like Ed25519) are much longer and harder to
break than standard human-typed words.
- Stops Phishing: You never type a secret word on a fake login page, which removes the risk
of credential theft.

Let's change the DropBear configuration to block password logins on our Guest network and 
allow on LAN network:
```shell
uci set dropbear.@dropbear[0]=dropbear
uci set dropbear.@dropbear[0].PasswordAuth='on'
uci set dropbear.@dropbear[0].RootPasswordAuth='on'
uci set dropbear.@dropbear[0].Interface='lan'

uci set dropbear.@dropbear[1]=dropbear
uci set dropbear.@dropbear[1].Interface='guest'
uci set dropbear.@dropbear[1].RootPasswordAuth='off'
uci set dropbear.@dropbear[1].PasswordAuth='off'
uci commit
service dropbear restart
```
You should be able to log in to your router using the Guest network, but only if you have
install your SSH public key on the router.  Once again, note that using passwords is 
disabled on the guest network, but not on the main network.

This may seem useless, but it will have a use in a future part of this series....

----

## VLMCSD

KMS Emulator for OpenWRT.  Do some research.  Let's install and configure it:
```shell
apk add vlmcsd
uci add_list dhcp.@dnsmasq[0].srv_host='_vlmcs._tcp.lan,OpenWrt.lan,1688,0,100'
uci commit
service dnsmasq restart
```

----

## Peanut

Peanut is a bash script that I wrote which sorts the IP address:port combos by ports for all
services that are listening via TCP.  Here is a screenshot of the output of the script, which
lists the services running on my router at this point in time:
![/assets/img/router/peanut.webp](/assets/img/router/peanut.webp){: lqip="data:image/webp;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAANABgDAREAAhEBAxEB/8QAFwAAAwEAAAAAAAAAAAAAAAAAAQIDCP/EABoQAAMBAQEBAAAAAAAAAAAAAAABAgNhEVH/xAAYAQADAQEAAAAAAAAAAAAAAAAAAQQCA//EABYRAQEBAAAAAAAAAAAAAAAAAAAREv/aAAwDAQACEQMRAD8AwLe/S7Keo1qvo8lQWnQydRq2dZGCumwgGX6KB//Z"}

If you don't have the XPtsp repository installed, [go here](/posts/router-part2/#customize-luci) and
add it before executing this next command.  Let's install it:
```shell
apk add peanut
```

----

## ZRAM-swap

Zram-swap is a Linux feature that compresses data and stores it in your memory (RAM) instead
of a slow hard drive. It helps your computer run faster, use less power, and handle more apps
when you are low on physical memory.

Let's install it!
```shell
apk add zram-swap
```

----

## Summary

We've managed to increase the functionality of our router.  Is there anything else we can do?

### Additional Information

- [Network Bound Disk Encryption with clevis and tang on OpenWRT](https://zaage.it/tutorials/network-bound-disk-encryption-with-clevis-and-tang-on-openwrt/)
- [OpenWrt Wiki: SFTP server](https://openwrt.org/docs/guide-user/services/nas/sftp.server)
- [Passwordless SSH Setup for OpenWrt with Dropbear](https://www.systutorials.com/how-to-passwordless-ssh-to-an-openwrt-router/)
- [How Does SSH Passwordless Login Work?](https://www.portnox.com/cybersecurity-101/authentication/ssh-passwordless-login/)
- [GitHub: vlmcsd package for OpenWRT](https://github.com/xptsp/openwrt-vlmcsd)
- [GitHub: Peanut package for OpenWRT](https://github.com/xptsp/openwrt-peanut)
