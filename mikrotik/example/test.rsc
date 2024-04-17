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

# name the device being configured
/system identity set name=SonosHQ

# setup bridge filter set no
/interface bridge add igmp-snooping=yes igmp-version=3 name=BRI-TEST protocol-mode=none query-interval=30s vlan-filtering=no

# assign ethernet ports
/interface ethernet set [ find default-name=ether1 ] name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] name=ether2-oob
/interface ethernet set [ find default-name=ether3 ] name=ether3
/interface ethernet set [ find default-name=ether4 ] name=ether4
/interface ethernet set [ find default-name=ether5 ] name=ether5
#/interface ethernet set [ find default-name=ether12 ] name=ether12-apfl2
#/interface ethernet set [ find default-name=ether13 ] name=ether13-dvs
#/interface ethernet set [ find default-name=ether15 ] name=ether5 
#/interface ethernet set [ find default-name=ether16 ] name=ether16-apfl3

# DNS server, set to cache for LAN
/ip dns set allow-remote-requests=yes cache-max-ttl=7d cache-size=4096KiB servers="1.1.1.1,1.0.0.1"

# add connection to internet
#/interface pppoe-client add add-default-route=yes disabled=no interface=ether1-wan name=Trueonline password=Password service-name=Trueonline use-peer-dns=no user=9605418601@fiberhome

##### add wireguard ## Dont forget to put public key here
/interface wireguard add listen-port=13231 mtu=1420 name=wg-sonoshq 
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

# IP Pool
/ip pool add name=POOL10 ranges=192.168.10.101-192.168.10.249
/ip pool add name=POOL11 ranges=192.168.11.101-192.168.11.249
/ip pool add name=POOL100 ranges=192.168.100.101-192.168.100.249
/ip pool add name=POOL200 ranges=192.168.200.101-192.168.200.249
/ip pool add name=POOL99 ranges=192.168.99.101-192.168.99.120

# DHCP Server
/ip dhcp-server add address-pool=POOL10 interface=VLAN10-LAN lease-time=1d name=dhcp-vlan10 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL11 interface=VLAN11-WIFI lease-time=1d name=dhcp-vlan11 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL100 interface=VLAN100-DANTE  lease-time=1d name=dhcp-vlan100 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL200 interface=VLAN200-LIGHTING lease-time=1d name=dhcp-vlan200 lease-script=dhcpleasestatic
/ip dhcp-server add address-pool=POOL99 interface=VLAN99-MGMT lease-time=1d name=dhcp-vlan99 lease-script=dhcpleasestatic
# DHCP Server Network
/ip dhcp-server network add address=192.168.10.0/24 dns-server=192.168.10.1 domain=.sonoshq.lan gateway=192.168.10.1
/ip dhcp-server network add address=192.168.11.0/24 dns-server=192.168.11.1 domain=.sonoshqhq.lan gateway=192.168.11.1
/ip dhcp-server network add address=192.168.100.0/24 dns-server=192.168.100.1 domain=.sonoshqhq.lan gateway=192.168.100.1
/ip dhcp-server network add address=192.168.200.0/24 dns-server=192.168.200.1 domain=.sonoshqhq.lan gateway=192.168.200.1
/ip dhcp-server network add address=192.168.99.0/24 dns-server=192.168.99.11 domain=.sonoshqhq.lan gateway=192.168.99.1

/ip dhcp-client add disabled=no interface=ether1-wan add-default-route=yes use-peer-dns=no 

# Firewall disable or not mdms ipv6
/interface bridge filter add action=drop chain=forward comment="Drop all IPv6 mDNS" disabled=no dst-mac-address=33:33:00:00:00:FB/FF:FF:FF:FF:FF:FF log=yes log-prefix=drop.mdns.ipv6 mac-protocol=ipv6

# Add bridge port selective to access vlan
/interface bridge port add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether5
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes interface=InterfaceListVlan10 pvid=10
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes interface=InterfaceListVlan11 pvid=11
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes interface=InterfaceListVlan100 pvid=100
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes interface=InterfaceListVlan200 pvid=200
/interface bridge port add bridge=BRI-TEST frame-types=admin-all [find interface=ether2]


/interface bridge vlan add bridge=BRI-TEST vlan-ids=10 tagged=BRI-TEST,ether5 untagged=ether3
/interface bridge vlan add bridge=BRI-TEST vlan-ids=11 tagged=BRI-TEST,ether5  untagged=ether4
/interface bridge vlan add bridge=BRI-TEST vlan-ids=100 tagged=BRI-TEST,ether5  
/interface bridge vlan add bridge=BRI-TEST  vlan-ids=200 tagged=BRI-TEST,ether5 
/interface list member add interface=BRI-TEST list=LAN
/interface list member add interface=ether1-wan list=WAN
/interface list member add interface=ether2-oob list=MGMT
/interface list member add interface=ether3 list=InterfaceListVlan10
/interface list member add interface=ether4 list=InterfaceListVlan11
#/interface list member add interface=ether5 list=InterfaceListVlan10
#/interface list member add interface=VLAN10-LAN list=LAN
#/interface list member add interface=VLAN11-WIFI list=LAN
#/interface list member add interface=VLAN100-DANTE list=LAN
#/interface list member add interface=VLAN200-LIGHTING list=LAN

## IP interfaces

/ip address add address=192.168.99.1/24 interface=VLAN99-MGMT network=192.168.99.0
/ip address add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip address add address=192.168.10.1/24 interface=VLAN10-LAN network=192.168.10.0
/ip address add address=192.168.11.1/24 interface=VLAN11-WIFI network=192.168.11.0
/ip address add address=192.168.100.1/24 interface=VLAN100-DANTE network=192.168.100.0
/ip address add address=192.168.200.1/24 interface=VLAN200-LIGHTING network=192.168.200.0
#/ip address add address=192.168.99.1/24 interface=VLAN99-MGMT network=192.168.99.0
#/ip address add address=192.168.0.1/24 interface=BRI-TEST network=192.168.0.0

# Filter
/ip firewall filter
add action=accept chain=input comment="accept ICMP after RAW" protocol=icmp
add action=accept chain=input comment="to the world" dst-port=53 in-interface=all-vlan protocol=udp
add action=accept chain=input comment="to the world" dst-port=53 in-interface=all-vlan protocol=tcp
add action=accept chain=input comment="accept established,related,untracked" connection-state=established,related,untracked

add chain=input action=accept in-interface=wg-sonoshq  comment="Allow Wireguard"
add chain=input action=accept in-interface=VLAN99-MGMT  comment="Allow Base_Vlan Full Access"
#add chain=input action=accept in-interface-list=LAN comment="Allow Base_Vlan Full Access"

add action=drop chain=input comment="Drop everything else in input"


/ip firewall filter
add action=fasttrack-connection chain=forward comment="fasttrack" connection-state=established,related 
add action=accept chain=forward comment="accept established,related, untracked" connection-state=established,related,untracked

add action=accept chain=forward comment="Allow BASE / mgmt to connect all VLANs" in-interface=VLAN99-MGMT out-interface=all-vlan
add action=accept chain=forward disabled=no in-interface-list=InterfaceListVlan10 out-interface-list=InterfaceListVlan11
add action=accept chain=forward disabled=no in-interface-list=InterfaceListVlan11 out-interface-list=InterfaceListVlan10

add action=drop chain=forward comment="Drop all" disabled=yes

/ip firewall nat
add action=masquerade chain=srcnat comment="masquerade" out-interface-list=WAN



#######################################
# MAC Server settings
#######################################

# Ensure only visibility and availability from BASE_VLAN, the MGMT network
/ip neighbor discovery-settings set discover-interface-list=LAN
/tool mac-server mac-winbox set allowed-interface-list=LAN
/tool mac-server set allowed-interface-list=LAN

#######################################
# System Tidy
#######################################

/ip service disable telnet,ftp,www,www-ssl,api,ssh,api-ssl
/ip service set ssh port=22022
/ip ssh set strong-crypto=yes

/system logging action add bsd-syslog=yes name=syslog remote=192.168.10.250 syslog-facility=syslog target=remote
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no
/system ntp client servers add address=time.cloudflare.com
/system ntp client set enabled=yes
/system clock set time-zone-name=Asia/Bangkok
/system note set show-at-login=no
/ip proxy set enabled=no
/ip upnp set enabled=no
/ip socks set enabled=no
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/user remove 0

#######################################
# Manage some scripts
#######################################
/system script add dont-require-permissions=no name=dhcp_leadstatic owner=sonos policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local lanDomain;\r\
    \n:local lanHostname;\r\
    \n\r\
    \n:set lanDomain \".lan\";\r\
    \n\r\
    \n:local tHostname;\r\
    \n:local tAddress;\r\
    \n\r\
    \n:if (\$leaseBound = 1) do={\r\
    \n    :set lanHostname (\$\"lease-hostname\" . \$lanDomain);\r\
    \n\r\
    \n    /ip dns static;\r\
    \n    :foreach k,v in=[find] do={\r\
    \n        :set tHostname [get \$v \"name\"];\r\
    \n        :set tAddress [get \$v \"address\"];\r\
    \n        :if (\$tHostname = \$lanHostname) do={\r\
    \n            remove \$v ;\r\
    \n            :log info \"Removed old static DNS entry: \$tHostname => \$tAddress\" ;\r\
    \n        };\r\
    \n    };\r\
    \n    /ip dns static add name=\"\$lanHostname\" address=\"\$leaseActIP\" ;\r\
    \n    :log info \"Added new static DNS entry: \$lanHostname => \$leaseActIP\" ;\r\
    \n};"

#######################################
# Turn on VLAN mode
#######################################
/interface bridge set BRI-TEST vlan-filtering=yes