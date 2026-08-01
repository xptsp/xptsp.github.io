#************************************************************************************
#******************************* ROUTER SERIES: PART 1 ******************************
#************************************************************************************
# Set the Root password
(echo MoeLarryCurly; echo MoeLarryCurly) | passwd

# Enable Upgrade Checking
uci set attendedsysupgrade.client.login_check_for_upgrades='1'

# Setup 2.4GHz Wifi interface:
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

# Setup 5GHz Wifi interface:
uci -q del wireless.radio1.disabled
uci set wireless.radio1.htmode='VHT20'
uci set wireless.radio1.cell_density='0'
uci set wireless.radio1.country='US'
uci set wireless.radio1.channel='36'

uci -q del wireless.default_radio1.disabled
uci set wireless.default_radio1.ssid='Four Stooges 5GHz'
uci set wireless.default_radio1.encryption='sae'
uci set wireless.default_radio1.key='MoeLarryCurlyShemp4'
uci set wireless.default_radio1.ocv='0'
uci set wireless.default_radio1.ifname="wlan-5g"

# Change br-lan IP address to "192.168.10.1":
uci -q del dhcp.lan.ra_slaac
uci set dhcp.lan.ra_preference='medium'
uci del network.lan.ipaddr
uci add_list network.lan.ipaddr='192.168.20.1/24'
uci set network.lan.multipath='off'

# Add our static IP assignments:
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

# Reconfigure router IPv4 and IPv6 DNS provider to CloudFlare upstream:
uci set network.wan.peerdns="0"
uci -q delete network.wan.dns
uci add_list network.wan.dns="1.1.1.1"
uci add_list network.wan.dns="1.0.0.1"

uci set network.wan6.peerdns="0"
uci -q delete network.wan6.dns
uci add_list network.wan6.dns="2606:4700:4700::1111"
uci add_list network.wan6.dns="2606:4700:4700::1001"

# Add routing to 192.168.4.0/24:
uci add network route # =cfg0cc8b4
uci set network.@route[-1].interface='lan'
uci set network.@route[-1].target='192.168.4.0/24'
uci set network.@route[-1].gateway='192.168.20.101'

# Add routing to 192.168.5.0/24:
uci add network route # =cfg0dc8b4
uci set network.@route[-1].interface='lan'
uci set network.@route[-1].target='192.168.5.0/24'
uci set network.@route[-1].gateway='192.168.20.101'

# Drop invalid packets and enable software and hardware flow offloading:
uci set firewall.@defaults[0].drop_invalid='1'
uci set firewall.@defaults[0].flow_offloading='1'
uci set firewall.@defaults[0].flow_offloading_hw='1'

#####################################################################################
# Install bash and change default shell:
#####################################################################################
apk update
apk add bash wget-ssl
sed -i "s|/bin/ash|/bin/bash|g" /etc/passwd

# Download bash startup script:
FILE=/root/.shinit
wget https://xptsp.github.io/assets/files/bashrc.sh -O ${FILE}
sed -i "s|32m|31m|" ${FILE}
chmod +x ${FILE}
echo "alias cls=clear" >> ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf

#####################################################################################
# Add Universal Plug-And-Play (uPnP)
#####################################################################################
apk add luci-app-upnp
uci set upnpd.config.enabled="1"
uci commit
service miniupnpd restart

#************************************************************************************
#******************************* ROUTER SERIES: PART 2 ******************************
#************************************************************************************
# Customize LUCI
echo "https://xptsp.github.io/openwrt-repo/apk/aarch64_cortex-a53/packages.adb" > /etc/apk/repositories.d/xptsp.list
wget http://xptsp.github.io/openwrt-repo/apk/aarch64_cortex-a53/xptsp.pem -O /etc/apk/keys/xptsp.pem

# Install Argon theme:
apk add luci-theme-argon luci-app-argon-config luci-lib-ipkg
uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='none'
uci commit

# Replace Background:
FILE=/www/luci-static/argon/img/router/bg1.jpg
wget https://xptsp.github.io/assets/img/router/bg1.jpg -O ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf

#####################################################################################
# Install AdGuardHome:
#####################################################################################
apk add adguardhome luci-app-adguardhome
wget https://github.com/xptsp/xptsp.github.io/raw/refs/heads/main/assets/files/adguardhome.yaml -O /etc/adguardhome/adguardhome.yaml

# Move DNSMASQ to port 54:
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

# Redirect all DNS queries from LAN to AGH:
uci -q del firewall.dns_int
uci set firewall.dns_int='redirect'
uci set firewall.dns_int.family='any'
uci set firewall.dns_int.name='DNS to AdGuardHome'
uci set firewall.dns_int.src='lan'
uci set firewall.dns_int.src_dport='53'
uci set firewall.dns_int.proto='tcp udp'
uci set firewall.dns_int.target='DNAT'
uci set firewall.dns_int.dest_port='53'

# Block all DoT queries from LAN:
uci set firewall.block_dot=rule
uci set firewall.block_dot.name='Block DoT from LAN'
uci set firewall.block_dot.src='lan'
uci set firewall.block_dot.dest='wan'
uci set firewall.block_dot.proto='tcp udp'
uci set firewall.block_dot.dest_port='853'
uci set firewall.block_dot.target='REJECT'

# Commit changes and restart services:
uci commit
service firewall restart
service dnsmasq restart
service adguardhome restart

#####################################################################################
# Network-wide Network Time
#####################################################################################
uci set system.ntp.enable_server='1'
uci set system.@system[0].zonename='America/Chicago'
uci set system.@system[0].timezone='CST6CDT,M3.2.0,M11.1.0'

# Add DHCP option to tell clients to use our NTP server:
NET_ADDR=$(uci get network.lan.ipaddr | cut -d\/ -f 1)
uci add_list dhcp.lan.dhcp_option="42,${NET_ADDR}"

# Force clients that don't wanna listen to use our NTP server anyway:
uci set firewall.ntp="redirect"
uci set firewall.ntp.family='any'
uci set firewall.ntp.name='Redirect NTP'
uci set firewall.ntp.target='DNAT'
uci set firewall.ntp.src='lan'
uci set firewall.ntp.src_dport='123'
uci set firewall.ntp.proto='udp'
uci set firewall.ntp.dest_port='123'

# Commit changes and restart service:
uci commit
service sysntpd restart
service dnsmasq restart

#####################################################################################
# Wake-On-Lan
#####################################################################################
apk add luci-app-wol
uci set etherwake.setup.interface='br-lan'
uci commit

# Add targets so that the machines are easier to wake:
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

#************************************************************************************
#******************************* ROUTER SERIES: PART 3 ******************************
#************************************************************************************
# Install USB device support
apk add kmod-usb-storage kmod-usb-ohci kmod-usb-uhci kmod-usb2 usb-modeswitch

# Install File System support
apk add block-mount kmod-fs-vfat kmod-fs-ext4 kmod-fs-exfat kmod-fs-ntfs3 ntfs-3g ntfs-3g-utils blkid e2fsprogs fdisk usbutils

# Add File Systems to Automatically Mount:
# Mount Windows partition:
uci set fstab.ubuntu=mount
uci set fstab.ubuntu.target='/mnt/windows'
uci set fstab.ubuntu.uuid='8B9D-69AC'
uci set fstab.ubuntu.enabled='1'

# Mount Ubuntu partition:
uci set fstab.windows=mount
uci set fstab.windows.target='/mnt/pxeboot/disks'
uci set fstab.windows.uuid='dd52e197-72db-4569-88e3-da5c3717f305'
uci set fstab.windows.enabled='1'

# Mount AGH partition:
uci set fstab.adguardhome=mount
uci set stab.adguardhome.target='/tmp/lib/adguardhome'
uci set fstab.adguardhome.uuid='f8c6384b-87c8-45c1-8d63-c158ddb8eb5b'
uci set fstab.adguardhome.enabled='1'

# Commit changes and restart AGH:
uci commit
block mount
service adguardhome restart

#####################################################################################
# Install Samba Support and bind to all addresses:
#####################################################################################
apk add luci-app-samba4
sed -i "s|bind interfaces only = yes|bind interfaces only = no|" /etc/samba/smb.conf.template

# Add Samba share:
uci -q delete samba4.mnt
uci set samba4.mnt='sambashare'
uci set samba4.mnt.name='mnt'
uci set samba4.mnt.path='/mnt'
uci set samba4.mnt.read_only='no'
uci set samba4.mnt.force_root='1'
uci set samba4.mnt.guest_ok='yes'
uci set samba4.mnt.create_mask='0666'
uci set samba4.mnt.dir_mask='0777'

# Commit changes and restart Samba:
uci commit
service samba4 restart

#####################################################################################
# Install and Configure Network File System (NFS):
#####################################################################################
apk add nfs-kernel-server nfs-kernel-server-utils
echo '/mnt/pxeboot/disks 192.168.20.0/24(rw,all_squash,insecure,no_subtree_check,fsid=0)' > /etc/exports
echo '/mnt/windows 192.168.20.0/24(rw,all_squash,insecure,no_subtree_check,fsid=0)' >> /etc/exports
service nfsd restart

#####################################################################################
# Set up our PXE Boot Server
#####################################################################################
uci set dhcp.@dnsmasq[0].enable_tftp='1'
uci set dhcp.@dnsmasq[0].tftp_root='/mnt/pxeboot'
uci set dhcp.@dnsmasq[0].dhcp_boot='pxelinux.0'

# PXEboot profile: BIOS
uci set dhcp.linux=boot
uci set dhcp.linux.filename='pxelinux.0'
uci set dhcp.linux.serveraddress='192.168.20.1'
uci set dhcp.linux.servername='OpenWrt'
uci add_list dhcp.linux.dhcp_option='209,pxelinux.cfg/default'
uci set dhcp.linux.force='1'
uci set dhcp.pxe_match=match
uci set dhcp.pxe_match.networkid='bios'
uci set dhcp.pxe_match.match='60,PXEClient:Arch:00000'
uci set dhcp.pxe_boot=boot
uci set dhcp.pxe_boot.filename='tag:bios,pxelinux.0,,192.168.20.1'
uci set dhcp.pxe_boot.serveraddress='192.168.20.1'
uci set dhcp.pxe_boot.servername='OpenWrt'

# PXEboot profile: UEFI x64
uci set dhcp.pxe_x64_eefi_match1=match
uci set dhcp.pxe_x64_eefi_match1.networkid='efi64'
uci set dhcp.pxe_x64_eefi_match1.match='60,PXEClient:Arch:00007'
uci set dhcp.pxe_x64_uefi_match2=match
uci set dhcp.pxe_x64_uefi_match2.networkid='efi64'
uci set dhcp.pxe_x64_uefi_match2.match='60,PXEClient:Arch:00009'
uci set dhcp.pxe_x64_uefi_boot=boot
uci set dhcp.pxe_x64_uefi_boot.filename='tag:efi64,syslinux64.efi,,192.168.20.1'
uci set dhcp.pxe_x64_uefi_boot.serveraddress='192.168.20.1'
uci set dhcp.pxe_x64_uefi_boot.servername='OpenWrt'

# PXEboot profile: UEFI x86
uci set dhcp.pxe_x86_uefi_match1=match
uci set dhcp.pxe_x86_uefi_match1.networkid='efi64'
uci set dhcp.pxe_x86_uefi_match1.match='60,PXEClient:Arch:00002'
uci set dhcp.pxe_x86_uefi_match2=match
uci set dhcp.pxe_x86_uefi_match2.networkid='efi64'
uci set dhcp.pxe_x86_uefi_match2.match='60,PXEClient:Arch:00006'
uci set dhcp.pxe_x86_uefi_boot=boot
uci set dhcp.pxe_x86_uefi_boot.filename='tag:efi32,syslinux32.efi,,192.168.20.1'
uci set dhcp.pxe_x86_uefi_boot.serveraddress='192.168.20.1'
uci set dhcp.pxe_x86_uefi_boot.servername='OpenWrt'

# Commit changes and restart DNSMASQ:
uci commit
service dnsmasq restart

# Retrieve PXE Boot files from the internet and add to backed up file list:
cd /tmp
wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz
tar -xzf syslinux-6.03.tar.gz
mkdir -p /mnt/pxeboot
cd /tmp/syslinux-6.03
cp efi64/com32/elflink/ldlinux/ldlinux.e64 bios/core/pxelinux.0 bios/com32/elflink/ldlinux/ldlinux.c32 bios/com32/menu/vesamenu.c32 bios/com32/lib/libcom32.c32 bios/com32/libutil/libutil.c32 /mnt/pxeboot/
cp efi64/efi/syslinux.efi /mnt/pxeboot/syslinux64.efi
cp efi32/efi/syslinux.efi /mnt/pxeboot/syslinux32.efi
ln -sf /mnt/pxeboot/disks /mnt/pxeboot/pxelinux.cfg 
ls /mnt/pxeboot | grep -v disks | while read FILE; do echo /mnt/pxeboot/$FILE; done >> /etc/sysupgrade.conf

#************************************************************************************
#******************************* ROUTER SERIES: PART 4 ******************************
#************************************************************************************
# Set our variables in advance:
export DOMAIN=example.com
export USERNAME=username
export PASSWORD=password
export DYNU_CLIENT_ID=REDACTED
export DYNU_SECRET=REDACTED
export EMAIL=username@example.com

#####################################################################################
# Install Dynamic DNS (DDNS) service:
#####################################################################################
apk add luci-app-ddns bind-host

# Configure DDNS:
uci -q del ddns.global.upd_privateip
uci set ddns.global.ddns_rundir='/var/run/ddns'
uci set ddns.global.ddns_logdir='/var/log/ddns'
uci -q del ddns.myddns_ipv4
uci -q del ddns.myddns_ipv6

uci set ddns.Home=service
uci set ddns.Home.enabled='1'
uci set ddns.Home.lookup_host=${DOMAIN}
uci set ddns.Home.domain=${DOMAIN}
uci set ddns.Home.username=${USERNAME}
uci set ddns.Home.password=${PASSWORD}
uci set ddns.Home.use_https='1'
uci set ddns.Home.cacert='/etc/ssl/certs'
uci set ddns.Home.use_logfile='0'
uci set ddns.Home.check_interval='1'
uci set ddns.Home.update_url='http://api.dynu.com/nic/update?hostname=[DOMAIN]&myip=[IP]&username=[USERNAME]&password=[PASSWORD]'
uci set ddns.Home.force_interval='2'
uci set ddns.Home.ip_source='network'
uci set ddns.Home.ip_network='wan'
uci set ddns.Home.interface='wan'
uci set ddns.Home.use_syslog='2'
uci set ddns.Home.check_unit='minutes'
uci set ddns.Home.force_unit='minutes'
uci set ddns.Home.retry_unit='seconds'
uci commit
service ddns restart

#####################################################################################
# Install ACME service for SSL certificates:
#####################################################################################
apk add luci-app-acme acme-acmesh-dnsapi

# Configure ACME service:
cp /dev/null /etc/config/acme
uci set acme.server=acme
uci set acme.server.account_email=${EMAIL}
uci set acme.server.debug='0'
export SECTION=${DOMAIN//\./_}
uci set acme.${SECTION}=cert
uci set acme.${SECTION}.enabled='1'
uci add_list acme.${SECTION}.domains=${DOMAIN}
uci add_list acme.${SECTION}.domains='*.'${DOMAIN}
uci set acme.${SECTION}.validation_method='dns'
uci set acme.${SECTION}.dns='dns_dynu'
uci add_list acme.${SECTION}.credentials='Dynu_ClientId="'${DYNU_CLIENT_ID}'"'
uci add_list acme.${SECTION}.credentials='Dynu_Secret="'${DYNU_SECRET}'"'
uci commit
service acme restart

# Run the ACME.SH script for the first time.  "service acme renew" always 
# fails on first run for some reason:
/usr/lib/acme/client/acme.sh --ecc -d ${DOMAIN} -d *.${DOMAIN} --keylength ec-256 --accountemail ${EMAIL} --server letsencrypt --dns dns_dynu --issue --home /etc/acme

# Create hooks that get executed when SSL is updated:
echo "[ \"\${ACTION}\" = \"renewed\" ] && service adguardhome restart" > /etc/hotplug.d/acme/00-adguardhome
echo "[ \"\${ACTION}\" = \"renewed\" ] && service nginx reload" > /etc/hotplug.d/acme/00-nginx
chmod +x /etc/hotplug.d/acme/*
echo "/etc/hotplug.d/acme/00-adguardhome" >> /etc/sysupgrade.conf
echo "/etc/hotplug.d/acme/00-nginx" >> /etc/sysupgrade.conf

#####################################################################################
# AdGuardHome using SSL certificate
#####################################################################################
# Add directory to AGH jail mounts and change ownership and permissions:
chown root:adguardhome /etc/acme/*/*.key
chmod 640 /etc/acme/*/*.key
uci add_list adguardhome.config.jail_mount='/etc/acme/'${DOMAIN}'_ecc/'
uci commit

# Modify AGH to use the SSL certificate, then restart AGH:
FILE=/etc/adguardhome/adguardhome.yaml
sed -i "s|server_name: .*|server_name: ${DOMAIN}|g" ${FILE}
sed -i "s|certificate_path: .*|certificate_path: /etc/acme/${DOMAIN}_ecc/fullchain.cer|g" ${FILE}
sed -i "s|private_key_path: .*|private_key_path: /etc/acme/${DOMAIN}_ecc/${DOMAIN}.key|g" ${FILE}
sed -i "s|port_https: .*|port_https: 3001|g" ${FILE}
sed -i '/^tls:/{n;s/.*/  enabled: true/}' ${FILE}
service adguardhome restart

# Allow DoT requests through the WAN firewall:
uci -q del firewall.dot
uci set firewall.dot="rule"
uci set firewall.dot.family='any'
uci set firewall.dot.name='Allow-DoT'
uci set firewall.dot.src='wan'
uci set firewall.dot.dest_port='853'
uci set firewall.dot.proto='udp'
uci set firewall.dot.target='ACCEPT'
uci commit
service firewall restart

#####################################################################################
# Replace UHTTPD with NGINX
#####################################################################################
# Remove UHTTPD and install NGINX:
apk del luci-light uhttpd-mod-ubus luci luci-ssl
apk add nginx-full nginx-mod-luci luci-nginx luci-nginx

# Start from scratch for NGINX configuration file:
cp /dev/null /etc/config/nginx
uci set nginx.global=main
uci set nginx.global.uci_enable='true'

# Define default HTTPS server, which redirects HTTPS requests to router site:
uci set nginx.https_default=server
uci add_list nginx.https_default.listen='443 ssl default_server'
uci add_list nginx.https_default.listen='[::]:443 ssl default_server'
uci set nginx.https_default.server_name='_lan'
uci add_list nginx.https_default.include='restrict_locally'
uci add_list nginx.https_default.include='conf.d/*.locations'
uci set nginx.https_default.ssl_certificate='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.cer'
uci set nginx.https_default.ssl_certificate_key='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.key'
uci set nginx.https_default.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_default.ssl_session_timeout='64m'
uci set nginx.https_default.access_log='off; # logd openwrt'
uci set nginx.https_default.return='302 https://router.'${DOMAIN}'$request_uri'

# Define HTTPS server serving UCI on the router:
uci set nginx.https_router=server
uci add_list nginx.https_router.listen='443 ssl'
uci add_list nginx.https_router.listen='[::]:443 ssl'
uci set nginx.https_router.server_name='router.'${DOMAIN}
uci add_list nginx.https_router.include='restrict_locally'
uci add_list nginx.https_router.include='conf.d/*.locations'
uci set nginx.https_router.ssl_certificate='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.cer'
uci set nginx.https_router.ssl_certificate_key='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.key'
uci set nginx.https_router.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_router.ssl_session_timeout='64m'
uci set nginx.https_router.access_log='off; # logd openwrt'

# Define a HTTPS server serving Adguard Home:
uci set nginx.https_webdav=server
uci add_list nginx.https_webdav.listen='443 ssl'
uci add_list nginx.https_webdav.listen='[::]:443 ssl'
uci add_list nginx.https_webdav.include='restrict_locally'
uci set nginx.https_webdav.server_name='webdav.'${DOMAIN}
uci set nginx.https_webdav.ssl_certificate='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.cer'
uci set nginx.https_webdav.ssl_certificate_key='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.key'
uci set nginx.https_webdav.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_webdav.ssl_session_timeout='64m'
uci set nginx.https_webdav.access_log='off; # logd openwrt'
uci set nginx.https_webdav.location='/ { proxy_pass https://127.0.0.1:3001; } # webdav'

# Define an default HTTP server that redirects HTTP requests to HTTPS:
uci set nginx.http_default=server
uci add_list nginx.http_default.listen='80 default_server'
uci add_list nginx.http_default.listen='[::]:80 default_server'
uci set nginx.http_default.server_name='_redirect2ssl'
uci set nginx.http_default.return='302 https://$host$request_uri'

# Define HTTP server that redirects http://openwrt/, http://openwrt.lan, and 
# http://openwrt.local to our router site:
uci set nginx.http_router=server
uci add_list nginx.http_router.listen='80'
uci add_list nginx.http_router.listen='[::]:80'
uci set nginx.http_router.server_name='openwrt.lan openwrt.local openwrt'
uci set nginx.http_router.return='302 https://router.'${DOMAIN}'$request_uri'

# Patch the nginx template so that long domain names are handled properly:
FILE=/etc/nginx/uci.conf.template
grep -q server_names_hash_bucket_size ${FILE} || sed -i "s|client_max_body_size 128M;|client_max_body_size 128M;\n        server_names_hash_bucket_size 128;|g" ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf

# Commit our changes and restart NGINX:
uci commit
service nginx restart

#####################################################################################
# Set up access to the Linksys CM3008 Cable Modem:
#####################################################################################
uci -q del network.modem
uci set network.modem="interface"
uci set network.modem.proto="static"
uci set network.modem.device="@wan"
uci set network.modem.ipaddr="192.168.100.2"
uci set network.modem.netmask="255.255.255.0"
uci commit network
service network restart

uci del_list firewall.@zone[1].network="modem"
uci add_list firewall.@zone[1].network="modem"
uci commit firewall
service firewall restart

# Create a new HTTPS server definition for the cable modem:
uci set nginx.https_modem=server
uci set nginx.https_modem.listen='443 ssl' '[::]:443 ssl'
uci set nginx.https_modem.include='restrict_locally'
uci set nginx.https_modem.server_name='modem.almostparadise.freeddns.org'
uci set nginx.https_modem.ssl_certificate='/etc/acme/almostparadise.freeddns.org_ecc/almostparadise.freeddns.org.cer'
uci set nginx.https_modem.ssl_certificate_key='/etc/acme/almostparadise.freeddns.org_ecc/almostparadise.freeddns.org.key'
uci set nginx.https_modem.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_modem.ssl_session_timeout='64m'
uci set nginx.https_modem.access_log='off; # logd openwrt'
uci set nginx.https_modem.location='/ { proxy_pass https://192.168.100.1; } # Cable Modem'
uci commit
service nginx restart

#####################################################################################
# Set up our basic WebDAV server:
#####################################################################################
apk add nginx-mod-dav-ext

# Once again, UCI configuration must be patched for lock zone definition:
FILE=/etc/nginx/uci.conf.template
grep -q dav_ext_lock_zone ${FILE} || sed -i "s|client_max_body_size 128M;|dav_ext_lock_zone zone=dav_locks:10m;\n        client_max_body_size 128M;|g" ${FILE}

# Create our WebDAV server on port 8080:
FILE=/etc/nginx/conf.d/pxeboot.conf
cat << EOF > ${FILE}
server {
	listen 8080 default_server;
	listen [::]:8080 default_server;
	include restrict_locally;
	server_name _;
	sub_filter '</head>' '<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"><link rel="stylesheet" href="/autoindex.css"></head>';
	sub_filter '</body>' '<script src="/autoindex.js"></script></body>';
	sub_filter_once on;
	autoindex on;
	location / {
		root /mnt/pxeboot/disks;
		dav_methods PUT DELETE MKCOL COPY MOVE;
		dav_ext_methods PROPFIND OPTIONS LOCK UNLOCK;
		dav_access user:rw group:rw all:r;
		dav_ext_lock zone=dav_locks;
		client_max_body_size 0;
		create_full_put_path on;
	}
	location ~ /autoindex.(css|js) {
		root /mnt/pxeboot;
	}
}
EOF
echo "${FILE}" >> /etc/sysupgrade.conf

# Download a few css and js files for this to work 
FILE=/mnt/pxeboot/autoindex.css
wget https://github.com/julcap/nginx-style-autoindex/raw/refs/heads/master/.autoindex.js -O "${FILE/css/js}"
wget https://github.com/julcap/nginx-style-autoindex/raw/refs/heads/master/.autoindex.css -O ${FILE}
echo "${FILE}" >> /etc/sysupgrade.conf
echo "${FILE/css/js}" >> /etc/sysupgrade.conf

# Define a HTTPS service that serves our WebDAV server:
uci set nginx.https_webdav=server
uci add_list nginx.https_webdav.listen='443 ssl'
uci add_list nginx.https_webdav.listen='[::]:443 ssl'
uci add_list nginx.https_webdav.include='restrict_locally'
uci set nginx.https_webdav.server_name='webdav.'${DOMAIN}
uci set nginx.https_webdav.ssl_certificate='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.cer'
uci set nginx.https_webdav.ssl_certificate_key='/etc/acme/'${DOMAIN}'_ecc/'${DOMAIN}'.key'
uci set nginx.https_webdav.ssl_session_cache='shared:SSL:32k'
uci set nginx.https_webdav.ssl_session_timeout='64m'
uci set nginx.https_webdav.access_log='off; # logd openwrt'
uci set nginx.https_webdav.location='/ { proxy_pass http://127.0.0.1:8080; } # WebDAV'

# Commit changes and restart service:
uci commit
service nginx restart

#************************************************************************************
#******************************* ROUTER SERIES: PART 5 ******************************
#************************************************************************************
#####################################################################################
# Guest Wifi
#####################################################################################
# Create new guest interface for network:
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

# Configure wireless interfaces on guest interface:
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
uci commit wireless
wifi reload

# Configure DHCP for guest interface:
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

# Configure firewall to allow DNS and DHCP for Guest network:
uci -q delete firewall.guest
uci set firewall.guest="zone"
uci set firewall.guest.name="guest"
uci add_list firewall.guest.network='guest'
uci set firewall.guest.input="REJECT"
uci set firewall.guest.output="ACCEPT"
uci set firewall.guest.forward="REJECT"
uci -q delete firewall.guest_wan
uci set firewall.guest_wan="forwarding"
uci set firewall.guest_wan.src="guest"
uci set firewall.guest_wan.dest="wan"
uci -q delete firewall.guest_dns
uci set firewall.guest_dns="rule"
uci set firewall.guest_dns.name="Allow-DNS-Guest"
uci set firewall.guest_dns.src="guest"
uci set firewall.guest_dns.dest_port="53"
uci set firewall.guest_dns.proto="tcp udp"
uci set firewall.guest_dns.target="ACCEPT"
uci -q delete firewall.guest_dhcp
uci set firewall.guest_dhcp="rule"
uci set firewall.guest_dhcp.name="Allow-DHCP-Guest"
uci set firewall.guest_dhcp.src="guest"
uci set firewall.guest_dhcp.dest_port="67"
uci set firewall.guest_dhcp.proto="udp"
uci set firewall.guest_dhcp.family="ipv4"
uci set firewall.guest_dhcp.target="ACCEPT"

# Configure firewall to allow LAN devices to access GUEST devices:	
uci set firewall.lan_guest="forwarding"
uci set firewall.lan_guest.src='lan'
uci set firewall.lan_guest.dest='guest'

# Commit changes and restart firewall:
uci commit
service firewall restart

#####################################################################################
# Install NoDogSplash:
#####################################################################################
apk add nodogsplash #luci-app-nodogsplash
sed -i "s|option gatewayinterface .*|option gatewayinterface 'br-guest'|" /etc/config/nodogsplash
service nodogsplash restart

# Replace the Guest Splash page with something better!
FILE=/etc/nodogsplash/htdocs/splash.html
wget https://xptsp.github.io/assets/files/splash.html -O /etc/nodogsplash/htdocs/splash.html
echo "${FILE}" >> /etc/sysupgrade.conf

#####################################################################################
# Install MWAN3:
#####################################################################################
# Install RNDIS kernel modules:
apk add kmod-usb-net-rndis kmod-usb-net-cdc-ether usb-modeswitch 

# Modify the WAN interface to have a metric of 10:
uci set network.wan.metric='10'
uci set network.wan.multipath='off'

# Define USB0 interface and set a metric of 20:
uci set network.usb0=interface
uci set network.usb0.ifname='usb0'
uci set network.usb0.proto='dhcp'
uci set network.usb0.metric='20'
uci set network.usb0.multipath='off'

# Install MWAN3 scripts and LUCI app:
apk add luci-app-mwan3

# Cleanup MWAN3 interface list and install our own:
uci show mwan3 | grep interface | cut -d\. -f 2 | cut -d= -f 1 | while read ID; do uci del mwan3.${ID}; done
uci set mwan3.usb0=interface
uci set mwan3.usb0.enabled='1'
uci set mwan3.usb0.initial_state='online'
uci set mwan3.usb0.family='ipv4'
uci set mwan3.usb0.track_method='ping'
uci set mwan3.usb0.reliability='1'
uci set mwan3.usb0.count='1'
uci set mwan3.usb0.size='56'
uci set mwan3.usb0.max_ttl='60'
uci set mwan3.usb0.timeout='4'
uci set mwan3.usb0.interval='10'
uci set mwan3.usb0.failure_interval='5'
uci set mwan3.usb0.recovery_interval='5'
uci set mwan3.usb0.down='5'
uci set mwan3.usb0.up='5'

# Cleanup MWAN3 member list and install our own:
uci show mwan3 | grep member | cut -d\. -f 2 | cut -d= -f 1 | while read ID; do uci del mwan3.${ID}; done
uci set mwan3.wan_m1_w1=member
uci set mwan3.wan_m1_w1.interface='wan'
uci set mwan3.wan_m1_w1.metric='1'
uci set mwan3.wan_m1_w1.weight='1'
uci set mwan3.usb0_m2_w2=member
uci set mwan3.usb0_m2_w2.interface='usb0'
uci set mwan3.usb0_m2_w2.metric='2'
uci set mwan3.usb0_m2_w2.weight='2'

# Install our single MWAN3 policy:
uci set mwan3.wan_usb0=policy
uci add_list mwan3.wan_usb0.use_member='wan_m1_w1'
uci add_list mwan3.wan_usb0.use_member='usb0_m2_w2'
uci set mwan3.wan_usb0.last_resort='unreachable'

# Cleanup MWAN3 rules list and install our own:
uci del mwan3.default_rule_v4
uci del mwan3.default_rule_v6
uci del mwan3.https
uci set mwan3.default=rule
uci set mwan3.default.proto='all'
uci set mwan3.default.sticky='0'
uci set mwan3.default.use_policy='wan_usb0'

# Commit all the changes and restart services:
uci commit
service mwan3 restart
service network restart
service firewall restart

#************************************************************************************
#******************************* ROUTER SERIES: PART 6 ******************************
#************************************************************************************
#####################################################################################
# Tang
#####################################################################################
apk add tang
uci set tang.config.enabled='1'
uci commit
service tang restart

