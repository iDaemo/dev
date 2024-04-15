# Notes:		Start with a reset (/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/router.rsc)

#######################################
# VLAN Overview For SLGroup HQ 
#######################################

# 10 = TRUSTED LAN
# 11 = TRUSTED WIFI
# 20 = GUEST 
# 100 = DANTE AV
# 200 = LIGHTING
# 99 = BASE (MGMT) VLAN1

#######################################

:delay 30s

# setup bridge filter set no
/interface bridge add igmp-snooping=yes igmp-version=3 name=BRI-TEST protocol-mode=none query-interval=30s vlan-filtering=no

# assign ethernet ports
/interface ethernet set [ find default-name=ether1 ] name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] name=ether2-oob
/interface ethernet set [ find default-name=ether12 ] name=ether12-apfl2
/interface ethernet set [ find default-name=ether13 ] name=ether13-dvs
/interface ethernet set [ find default-name=ether15 ] name=ether15-trunk
/interface ethernet set [ find default-name=ether16 ] name=ether16-apfl3

# DNS server, set to cache for LAN
/ip dns set allow-remote-requests=yes cache-max-ttl=7d cache-size=4096KiB servers="1.1.1.1,1.0.0.1"

# add connection to internet
/interface pppoe-client add add-default-route=yes disabled=no interface=ether1-wan name=Trueonline password=Password service-name=Trueonline use-peer-dns=no user=9605418601@fiberhome

##### add wireguard
/interface wireguard add listen-port=13231 mtu=1420 name=wg-sonoshq private-key="0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="
#### Peers
/interface wireguard peers add allowed-address=10.0.0.2/32 comment=Gle interface=wg-sonoshq public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
/interface wireguard peers add allowed-address=10.0.0.3/32 interface=wg-sonoshq public-key="MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
/interface wireguard peers add allowed-address=10.0.0.4/32 interface=wg-sonoshq public-key="4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
/interface wireguard peers add allowed-address=10.0.0.5/32 interface=wg-sonoshq public-key="TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
/interface wireguard peers add allowed-address=10.0.0.6/32 interface=wg-sonoshq public-key="VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
/interface wireguard peers add allowed-address=10.0.0.7/32 interface=wg-sonoshq public-key="FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
/interface wireguard peers add allowed-address=10.0.0.8/32 interface=wg-sonoshq public-key="kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
/interface wireguard peers add allowed-address=10.0.0.9/32 interface=wg-sonoshq public-key="5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
/interface wireguard peers add allowed-address=10.0.0.10/32 interface=wg-sonoshq public-key="sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
/interface wireguard peers add allowed-address=10.0.0.11/32 interface=wg-sonoshq public-key="Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
/interface wireguard peers add allowed-address=10.0.0.12/32 comment=hrc-kl interface=wg-sonoshq public-key="yAi/YI2Xj4AJRihUDRiW1muySqOK7gifIMYA4SKlgAg="
/interface wireguard peers add allowed-address=10.0.0.13/32,192.168.20.0/24 comment="Hap ac2 mobile" interface=wg-sonoshq public-key="ACW5Tee4YtTaud/5gEdvjjN/p+jUgi4ts+RiszjXvUo="
/interface wireguard peers add allowed-address=10.0.0.40/32,192.168.40.0/24 comment="Raynue 192.168.40.0/24" interface=wg-sonoshq public-key="bZjIr4w5B8LsOO0onCK1ZmFthCygs23aQvTSXemV/B4="

# start to segment vlan
/interface list add name=WAN
/interface list add name=LAN
/interface list add name=MGMT
/interface vlan add interface=BRI-TEST name=VLAN10-LAN vlan-id=10
/interface vlan add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
/interface vlan add interface=BRI-TEST name=VLAN100-DANTE vlan-id=100
/interface vlan add interface=BRI-TEST name=VLAN200-LIGHTING vlan-id=200
/interface vlan add interface=BRI-TEST name=VLAN99-MGMT vlan-id=99
/interface list add name=InterfaceListVlan10
/interface list add name=InterfaceListVlan11
/interface list add name=InterfaceListVlan100
/interface list add name=InterfaceListVlan200
/interface detect-internet set detect-interface-list=WAN

# Assign IP just for Management OOB port
#/ip address add address=192.168.99.1/24 interface=MGMT
# IP Pool
/ip pool add name=POOL10 ranges=192.168.10.101-192.168.10.249
/ip pool add name=POOL11 ranges=192.168.11.101-192.168.11.249
/ip pool add name=POOL100 ranges=192.168.100.101-192.168.100.249
/ip pool add name=POOL200 ranges=192.168.200.101-192.168.200.249
/ip pool add name=POOL99 ranges=192.168.99.101-192.168.99.120

# DHCP Server
/ip dhcp-server add address-pool=POOL10 add-arp=yes interface=VLAN10-LAN lease-time=1d name=dhcp-vlan10 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL11 add-arp=yes interface=VLAN11-WIFI lease-time=1d name=dhcp-vlan11 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL100 add-arp=yes interface=VLAN100-DANTE  lease-time=1d name=dhcp-vlan100 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL200 add-arp=yes interface=VLAN200-LIGHTING lease-time=1d name=dhcp-vlan200 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL99 add-arp=yes interface=VLAN99-MGMT lease-time=1d name=dhcp-vlan99 lease-script=dhcpleasestatic
# DHCP Server Network
/ip dhcp-server network add address=192.168.10.0/24 dns-server=192.168.10.1 domain=hq.lan gateway=192.168.10.1
/ip dhcp-server network add address=192.168.11.0/24 dns-server=192.168.11.1 domain=hq.lan gateway=192.168.11.1
/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 domain=hq.lan gateway=192.168.100.1
/ip dhcp-server network add address=192.168.200.0/24 dns-server=192.168.200.1 domain=hq.lan gateway=192.168.200.1
/ip dhcp-server network add address=192.168.99.0/24 dns-server=192.168.99.11 domain=hq.lan gateway=192.168.99.1



# Firewall disable or not mdms ipv6
/interface bridge filter add action=drop chain=forward comment="Drop all IPv6 mDNS" disabled=yes dst-mac-address=33:33:00:00:00:FB/FF:FF:FF:FF:FF:FF log=yes log-prefix=drop.mdns.ipv6 mac-protocol=ipv6

# Add bridge port selective to access vlan
/interface bridge port add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether15-trunk trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 pvid=10 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan11 pvid=11 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan100 pvid=100 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan200 pvid=200 trusted=yes

/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=100
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=200
/interface list member add interface=ether1-wan list=WAN
/interface list member add interface=ether2-oob list=MGMT
/interface list member add interface=ether3 list=InterfaceListVlan10
/interface list member add interface=ether4 list=InterfaceListVlan10
/interface list member add interface=ether5 list=InterfaceListVlan10
/interface list member add interface=ether6 list=InterfaceListVlan10
/interface list member add interface=ether7 list=InterfaceListVlan10
/interface list member add interface=ether8 list=InterfaceListVlan10
/interface list member add interface=ether9 list=InterfaceListVlan10
/interface list member add interface=ether10 list=InterfaceListVlan10
/interface list member add interface=ether11 list=InterfaceListVlan10
/interface list member add interface=ether13-dvs list=InterfaceListVlan10
/interface list member add interface=ether14 list=InterfaceListVlan10
/interface list member add interface=ether12-apfl2 list=InterfaceListVlan10
/interface list member add interface=ether16-apfl3 list=InterfaceListVlan10
#/interface list member add interface=VLAN10-LAN list=LAN
#/interface list member add interface=VLAN11-WIFI list=LAN
#/interface list member add interface=VLAN100-DANTE list=LAN
#/interface list member add interface=VLAN200-LIGHTING list=LAN
/interface list member add interface=BRI-TEST list=LAN


## IP interfaces
/ip address add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip address add address=192.168.10.1/24 interface=VLAN10-LAN network=192.168.10.0
/ip address add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
/ip address add address=192.168.100.1/24 interface=VLAN100-DANTE network=192.168.100.0
/ip address add address=192.168.200.1/24 interface=VLAN200-LIGHTING network=192.168.200.0
/ip address add address=192.168.99.1/24 interface=ether2-oob network=192.168.99.0
#/ip address add address=192.168.0.1/24 interface=BRI-TEST network=192.168.0.0

###############################
## Firewall Filter
/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="defconf: multicast" list=no_forward_ipv4
add address=255.255.255.255/32 comment="defconf: RFC6890" list=no_forward_ipv4

/ip firewall address-list
add address=127.0.0.0/8 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="defconf: RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=198.51.100.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=203.0.113.0/24 comment="defconf: RFC6890 documentation" list=bad_ipv4
add address=240.0.0.0/4 comment="defconf: RFC6890 reserved" list=bad_ipv4

/ip firewall address-list
add address=0.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="defconf: RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="defconf: RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="defconf: RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="defconf: RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="defconf: RFC6890 benchmark" list=not_global_ipv4
add address=255.255.255.255/32 comment="defconf: RFC6890" list=not_global_ipv4

/ip firewall address-list
add address=224.0.0.0/4 comment="defconf: multicast" list=bad_src_ipv4
add address=255.255.255.255/32 comment="defconf: RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="defconf: RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="defconf: RFC6890" list=bad_dst_ipv4

# Firewall Raw rule
/ip firewall raw
add action=accept chain=prerouting comment="defconf: enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="defconf: accept DHCP discover" dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=udp src-address=0.0.0.0 src-port=68
add action=drop chain=prerouting comment="defconf: drop bogon IP's" src-address-list=bad_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" dst-address-list=bad_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" src-address-list=bad_src_ipv4
add action=drop chain=prerouting comment="defconf: drop bogon IP's" dst-address-list=bad_dst_ipv4
add action=drop chain=prerouting comment="defconf: drop non global from WAN" src-address-list=not_global_ipv4 in-interface-list=WAN

add action=drop chain=prerouting comment="defconf: drop forward to local lan from WAN" in-interface-list=WAN dst-address=192.168.88.0/24
add action=drop chain=prerouting comment="defconf: drop local if not from default IP range" in-interface-list=LAN src-address=!192.168.88.0/24

add action=drop chain=prerouting comment="defconf: drop bad UDP" port=0 protocol=udp
add action=jump chain=prerouting comment="defconf: jump to TCP chain" jump-target=bad_tcp protocol=tcp
add action=accept chain=prerouting comment="defconf: accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment="defconf: accept everything else from WAN" in-interface-list=WAN
add action=drop chain=prerouting comment="defconf: drop the rest"

/ip firewall raw
add action=drop chain=bad_tcp comment="defconf: TCP flag filter" protocol=tcp tcp-flags=!fin,!syn,!rst,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,syn
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,urg
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=syn,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=rst,urg
add action=drop chain=bad_tcp comment="defconf: TCP port 0 drop" port=0 protocol=tcp

# Filter
/ip firewall filter
add action=accept chain=input comment="defconf: accept ICMP after RAW" protocol=icmp
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN

/ip firewall filter
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward src-address-list=no_forward_ipv4 comment="defconf: drop bad forward IPs"
add action=drop chain=forward dst-address-list=no_forward_ipv4 comment="defconf: drop bad forward IPs"

/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" out-interface-list=WAN


#######################################
# System Tidy
#######################################

/ip neighbor discovery-settings set discover-interface-list=LAN
/system logging action add bsd-syslog=yes name=syslog remote=192.168.10.250 syslog-facility=syslog target=remote
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no
/system ntp client servers add address=time.cloudflare.com
/system ntp client set enabled=yes
/system clock set time-zone-name=Asia/Bangkok
/system note set show-at-login=no
/ip service disable telnet,ftp,www,www-ssl,api,ssh,api-ssl
/ip service set ssh port=22022
/ip ssh set strong-crypto=yes
/ip proxy set enabled=no
/ip upnp set enabled=no
/ip socks set enabled=no
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/user remove 0

#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BRI-TEST vlan-filtering=yes