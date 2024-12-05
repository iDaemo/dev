# jul/12/2023 17:38:00 by RouterOS 7.9.1
# software id = MIVQ-7AKA
#
# model = RBD52G-5HacD2HnD
# serial number = E5780FD77CCB
/interface bridge add ingress-filtering=yes name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 private-key="QJo9Ca+u8U2YQS2cBWZGsLBu2oN/1DkjeyOs7gwLhU0="
/interface vlan add interface=BRI-TEST name=VLAN10 vlan-id=10
/interface vlan add interface=BRI-TEST name=VLAN11 vlan-id=11
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa2-psk mode=dynamic-keys name=idaemon supplicant-identity="iDaemon" wpa2-pre-shared-key=thaigaming
/interface wireless    
set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-b/g/n channel-width=\
    20/40mhz-eC country=thailand disabled=no frequency=2457 ssid="smart 3-3" \
    wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-n/ac channel-width=\
    20/40mhz-XX country=thailand disabled=no frequency=auto installation=\
    indoor mode=ap-bridge radio-name=iDaemon security-profile=idaemon ssid=\
    iDaemon wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
add disabled=no keepalive-frames=disabled mac-address=DE:2C:6E:2F:63:70 \
    master-interface=wlan1 multicast-buffering=disabled name=wlan3 \
    security-profile=idaemon ssid=iDaemon2.4G wds-cost-range=0 \
    wds-default-cost=0 wps-mode=disabled
/interface list
add name=BASE
add name=WAN
add name=LAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
/interface list member
add interface=wlan1 list=WAN
add interface=VLAN10 list=LAN
add interface=VLAN11 list=LAN
add interface=wlan2 list=InterfaceListVlan10
add interface=wlan3 list=InterfaceListVlan10
add interface=ether5 list=InterfaceListVlan10


/ip pool
add name=POOL10 ranges=192.168.10.10-192.168.10.200
add name=POOL11 ranges=192.168.11.10-192.168.11.200
add name=POOL1 ranges=10.0.0.10-10.0.0.20
/ip dhcp-server add address-pool=POOL10 interface=VLAN10 lease-time=1d name=DHCP10
/ip dhcp-server add address-pool=POOL11 interface=VLAN11 lease-time=1d name=DHCP11
/ip dhcp-server add address-pool=POOL1 interface=BRI-TEST lease-time=1d name=DHCP1

/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 pvid=10
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 pvid=11

/ipv6 settings
set disable-ipv6=yes

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=11


/ip address
add address=192.168.10.1/24 interface=VLAN10 network=192.168.10.0
add address=192.168.11.1/24 interface=VLAN11 network=192.168.11.0
add address=10.0.0.1/24 interface=BRI-TEST network=10.0.0.0
/ip dhcp-client
add interface=wlan1
/ip dhcp-server network
add address=192.168.10.0/24 dns-server=192.168.10.1 gateway=192.168.10.1
add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
add address=10.0.0.1/24 dns-server=10.0.0.1 gateway=10.0.0.1
/ip dns
set allow-remote-requests=yes

/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp 
add action=accept chain=input comment="allow WireGuard traffic" in-interface=wireguard1 
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53 protocol=tcp
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53 protocol=udp
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
add action=drop chain=forward comment="Drop all else"

/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www-ssl disabled=no
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-name=Asia/Bangkok
/system identity
set name=iDaemonROOM
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=162.159.200.123
add address=103.47.76.177
/tool bandwidth-server
set enabled=no
