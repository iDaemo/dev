
#######################################
# HAP ac2 Config file MUST INSTALL EXTRA PACKAGE wifi-qcom-ac.apk
# FILE NAME router-config.rsc upload to router
# Notes: Start with a reset /system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=router-config.rsc
#######################################

:delay 30s


#######################################
# Housekeeping
#######################################

# name the device being configured
/system identity set name=SonosControl38


#######################################
# VLAN Overview
#######################################

# 38 = AV (ControlNetwork+DanteNetwork))
# 39 = AV (DanteNetwork1))
# 40 = AV (DanteNetwork2))
# 99 = BASE (MGMT) VLAN


#######################################
# Bridge
#######################################

# create one bridge, set VLAN mode off while we configure
/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes


#######################################
# WIFI Setup
# 2G - 1-2412 6-2437 11-2462
# 5G - 36-5180 52-5260 100-5500 116-5580 149-5745
#######################################

/interface wifi security add name=common-auth authentication-types=wpa2-psk passphrase="33338888" wps=disable
/interface wifi configuration add name=common-conf ssid=@CONTROLsonosxaura country=Thailand security=common-auth

/interface wifi channel add name=ch-2ghz frequency=2412,2437,2462 band=2ghz-n width=20mhz
/interface wifi channel add name=ch-5ghz frequency=5500,5580,5745 band=5ghz-ac width=20/40mhz-Ce

/interface wifi set wifi1 channel=ch-2ghz configuration=common-conf disabled=no 
/interface wifi set wifi2 channel=ch-5ghz configuration=common-conf disabled=no

# For FUTURE IMPLEMENT
#/interface wireless access-list
#add allow-signal-out-of-range=30s comment="5G Wifi" interface=wifi2 signal-range=-80..120 vlan-mode=no-tag
#add allow-signal-out-of-range=30s comment="2.4G Wifi" interface=wifi1 signal-range=-120..-70 vlan-mode=no-tag

# create logging for wifi system
/system logging add topics=wireless,debug action=memory


#######################################
# Interface Setup
#######################################

# list and service
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=MGMT
/interface detect-internet set detect-interface-list=WAN
/ip dhcp-client add interface=ether1 disabled=no 
/interface list member add interface=ether1 list=WAN 
/ip dns set allow-remote-requests=yes

# Wireguard 
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/ip address add address=10.0.0.38/24 interface=wireguard1 network=10.0.0.0

/interface/wireguard/peers add allowed-address=192.168.10.0/24,10.0.0.0/24 endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 \
persistent-keepalive=10s public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="
#/interface wireguard peers add allowed-address=10.0.0.1/32,192.168.10.0/24 disabled=no \
#    endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=wireguard1 persistent-keepalive=25s \
#    public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="
#sonosHQ public-key="hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo=" address=10.0.0.1/24

# main VLAN38
/interface vlan add interface=BRI-TEST name=VLAN38 vlan-id=38
/interface list add name=InterfaceListVlan38
/ip address add address=192.168.38.1/24 interface=VLAN38 network=192.168.38.0
/ip pool add name=POOL38 ranges=192.168.38.161-192.168.38.240
/ip dhcp-server network add address=192.168.38.0/24 dns-server=192.168.38.1 gateway=192.168.38.1 domain=.local
/ip dhcp-server add address-pool=POOL38 interface=VLAN38 lease-time=1d name=DHCP38 disabled=no
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=38
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan38 pvid=38
/interface list member add interface=VLAN38 list=LAN

# VLAN39
/interface vlan add interface=BRI-TEST name=VLAN39 vlan-id=39
/interface list add name=InterfaceListVlan39
/ip address add address=192.168.39.1/24 interface=VLAN39 network=192.168.39.0
/ip pool add name=POOL39 ranges=192.168.39.161-192.168.39.240
/ip dhcp-server network add address=192.168.39.0/24 dns-server=192.168.39.1 gateway=192.168.39.1 domain=.local
/ip dhcp-server add address-pool=POOL39 interface=VLAN39 lease-time=1d name=DHCP39 disabled=no
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=39
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan39 pvid=39
/interface list member add interface=VLAN39 list=LAN


# Assign interface member to Vlan
/interface list member add interface=ether2 list=InterfaceListVlan38
/interface list member add interface=ether3 list=InterfaceListVlan38
/interface list member add interface=ether4 list=InterfaceListVlan38
#/interface list member add interface=ether5 list=InterfaceListVlan38
/interface list member add interface=wifi1 list=InterfaceListVlan38
/interface list member add interface=wifi2 list=InterfaceListVlan38


#######################################
# FIREWALL
#######################################

/ip firewall filter

add chain=input action=accept comment="Allow Estab & Related" connection-state=established,related 
add action=drop chain=input comment="Drop invalid input" connection-state=invalid
add action=accept chain=input comment="DNS UDP" dst-port=53 in-interface=all-vlan protocol=udp
add action=accept chain=input comment="DNS TCP" dst-port=53 in-interface=all-vlan protocol=tcp
add action=accept chain=input comment="ICMP" in-interface=all-vlan protocol=icmp
add action=accept chain=input comment="WireGuard" dst-port=13231 protocol=udp
add action=accept chain=input comment="Winbox" dst-port=8291 protocol=tcp 
add chain=input action=accept comment="Allow VLAN" in-interface-list=LAN 
add action=drop chain=input comment="Drop else INPUT"

add action=fasttrack-connection chain=forward comment="Fast Track" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="Allow Established & Related" connection-state=established,related,untracked
add action=drop chain=forward comment="Drop invalid in forward chain" connection-state=invalid
add action=accept chain=forward comment="Allow internet" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
add chain=forward action=drop comment="Drop ALL"

/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN

#######################################
# SYSTEM SETUP
#######################################

#/ipv6 settings set disable-ipv6=yes
#/ipv6 nd set [ find default=yes ] disabled=yes
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no
/system ntp client servers add address=time.cloudflare.com
/system ntp client set enabled=yes
/system clock set time-zone-name=Asia/Bangkok
/system note set show-at-login=no
/ip service disable telnet,ftp,api,api-ssl
/ip service set ssh port=22022
/ip ssh set strong-crypto=yes
/ip proxy set enabled=no
/ip upnp set enabled=no
/ip socks set enabled=no
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/user remove 0

#######################################
# IMPLEMENT LIST
#######################################
#/ip settings set rp-filter=loose tcp-syncookies=yes
#/ip neighbor discovery-settings set discover-interface-list=LAN

# This rule is associated with the rule below about stopping inter-VLAN
# communication (or drop all). If VLAN communication between certain VLANs
# is required, one can add something like the examples below.
# Notice that one can also only allow one direction of communication.
# In this example communication is allowed in both directions between
# BLUE and GREEN VLANs.
# Notice that the rules are disabled by default.
#add action=accept chain=forward comment="Allow communication from BLUE to GREEN VLAN" disabled=yes in-interface=BLUE_VLAN out-interface=GREEN_VLAN
#add action=accept chain=forward comment="Allow communication from GREEN to BLUE VLAN" disabled=yes in-interface=GREEN_VLAN out-interface=BLUE_VLAN


##############################
# Reduce Airtime traffic
#/interface bridge settings
#set use-ip-firewall=yes use-ip-firewall-for-vlan=yes
#/interface bridge filter
#add action=drop chain=forward comment="Drop all IPv6 mDNS" dst-mac-address=\
#    33:33:00:00:00:FB/FF:FF:FF:FF:FF:FF mac-protocol=ipv6
#/ip firewall mangle
#add action=change-ttl chain=forward comment="Sanitise mDNS TTL to 1" \
#    dst-address=224.0.0.251 dst-port=5353 log-prefix=ttl new-ttl=set:1 \
#    passthrough=yes protocol=udp src-port=5353 ttl=not-equal:1
#add action=change-dscp chain=forward comment="Sanitise mDNS DSCP to 0" dscp=!0 \
#    dst-address=224.0.0.251 dst-port=5353 log-prefix=ttl new-dscp=0 \
#    passthrough=yes protocol=udp src-port=5353
#/ip firewall mangle
#add action=set-priority chain=postrouting comment="Set Prio outbound on Wifi" \
#    new-priority=from-dscp-high-3-bits out-bridge-port=all-wireless \
#    passthrough=yes