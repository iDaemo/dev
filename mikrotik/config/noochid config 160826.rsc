# 2025-07-27 17:07:22 by RouterOS 7.19.4
# software id = 94VR-PHQ3
#
# model = RBD52G-5HacD2HnD
# serial number = HH90A0WAG72
/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard
add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan
add interface=BRI-TEST name=VLAN32 vlan-id=32
/interface list
add name=LAN
add name=WAN
add name=InterfaceListVlan32
/interface wifi channel
add band=2ghz-n frequency=2412,2437,2462 name=ch-2ghz width=20mhz
add band=5ghz-ac frequency=5500,5580,5745 name=ch-5ghz width=20/40mhz-Ce
/interface wifi security
add authentication-types=wpa2-psk name=common-auth wps=disable
/interface wifi configuration
add country=Thailand name=common-conf security=common-auth ssid=\
    NooChid
/interface wifi
set [ find default-name=wifi1 ] channel=ch-2ghz configuration=common-conf \
    configuration.mode=ap .ssid=NooChid2G disabled=no
set [ find default-name=wifi2 ] channel=ch-5ghz configuration=common-conf \
    configuration.mode=ap .ssid=NooChid5G disabled=no
/ip pool
add name=POOL32 ranges=192.168.32.10-192.168.32.200
/ip dhcp-server
add address-pool=POOL32 interface=VLAN32 lease-time=1d name=DHCP32
/interface bridge port
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan32 pvid=32
/ipv6 settings
set disable-ipv6=yes
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=32
/interface detect-internet
set detect-interface-list=WAN
/interface list member
add interface=ether1 list=WAN
add interface=VLAN32 list=LAN
add interface=ether2 list=InterfaceListVlan32
add interface=ether3 list=InterfaceListVlan32
add interface=ether4 list=InterfaceListVlan32
add interface=ether5 list=InterfaceListVlan32
add interface=wifi1 list=InterfaceListVlan32
add interface=wifi2 list=InterfaceListVlan32
/ip address
add address=10.32.32.1/24 interface=wireguard1 network=10.0.0.0
add address=192.168.32.1/24 interface=VLAN32 network=192.168.32.0
/ip dhcp-client
# Interface not active
add interface=ether1
/ip dhcp-server network
add address=192.168.32.0/24 dns-server=192.168.32.1 domain=.lan gateway=\
    192.168.32.1
/ip dns
set allow-remote-requests=yes
/ip firewall filter
add action=accept chain=input comment="Allow Estab & Related" \
    connection-state=established,related,untracked
add action=drop chain=input comment="Drop invalid input" connection-state=\
    invalid
add action=accept chain=input comment=ICMP in-interface=all-vlan protocol=\
    icmp
add action=accept chain=input comment="DNS UDP" dst-port=53 in-interface=\
    all-vlan protocol=udp
add action=accept chain=input comment="DNS TCP" dst-port=53 in-interface=\
    all-vlan protocol=tcp
add action=accept chain=input comment=WireGuard dst-port=13231 protocol=udp
add action=accept chain=input comment=Winbox dst-port=8291 protocol=tcp
add action=accept chain=input comment="Allow VLAN" in-interface-list=LAN
add action=drop chain=input comment="Drop else INPUT"
add action=fasttrack-connection chain=forward comment="Fast Track" \
    connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="Allow Established & Related" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="Drop invalid in forward chain" \
    connection-state=invalid
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 \
    out-interface-list=LAN
add action=accept chain=forward comment="LAN to WG" in-interface-list=LAN \
    out-interface=wireguard1
add action=accept chain=forward comment="Allow internet" in-interface-list=\
    LAN out-interface-list=WAN
add action=drop chain=forward comment="Drop ALL"
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
/ip service
set ftp disabled=yes
set telnet disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh disabled=yes port=22022
/ip ssh
set strong-crypto=yes
/ipv6 nd
set [ find default=yes ] disabled=yes
/system clock
set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity
set name=NooChid
/system logging
add topics=wireless,debug
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
/tool bandwidth-server
set enabled=no
