#/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik 
#/interface wireless security-profiles add authentication-types=wpa2-psk mode=dynamic-keys name=sonos supplicant-identity="carlos" wpa2-pre-shared-key=7777777

#/interface wireless    
#set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-b/g/n channel-width=\
#    20/40mhz-eC country=thailand disabled=no frequency=2457 ssid="carlos2G" \
#    wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
#set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-n/ac channel-width=\
#    20/40mhz-XX country=thailand disabled=no frequency=auto installation=\
#    indoor mode=ap-bridge radio-name=sonos security-profile=carlos ssid=\
#    carlos5G wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled

/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 
/interface vlan add interface=BRI-TEST name=VLAN7 vlan-id=7
/interface vlan add interface=BRI-TEST name=VLAN77 vlan-id=77
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan7
/interface list add name=InterfaceListVlan77


/ip pool add name=POOL7 ranges=192.168.7.10-192.168.7.220
/ip pool add name=POOL77 ranges=192.168.77.10-192.168.77.220

/ip dhcp-server add address-pool=POOL7 interface=VLAN7 lease-time=1d name=DHCP7
/ip dhcp-server add address-pool=POOL77 interface=VLAN77 lease-time=1d name=DHCP77
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan7 pvid=7
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan77 pvid=77
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=7
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=77
#/interface list member add interface=wlan1 list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan7
/interface list member add interface=ether3 list=InterfaceListVlan7
/interface list member add interface=ether4 list=InterfaceListVlan7
/interface list member add interface=ether5 list=InterfaceListVlan7
/interface list member add interface=VLAN7 list=LAN
/interface list member add interface=VLAN77 list=LAN
#/interface list member add interface=wlan2 list=InterfaceListVlan40

/ip address add address=192.168.7.1/24 interface=VLAN7 network=192.168.7.0
/ip address add address=192.168.77.1/24 interface=VLAN77 network=192.168.77.0
/ip address add address=10.11.11.1/24 interface=wireguard1 network=10.11.11.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

#/ip dhcp-client add disabled=no interface=wlan1
/ip dhcp-server network add address=192.168.7.0/24 dns-server=192.168.7.1 gateway=192.168.7.1
/ip dhcp-server network add address=192.168.77.0/24 dns-server=192.168.77.1 gateway=192.168.77.1
/ip dns set allow-remote-requests=yes
/ip firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="allow WireGuard" dst-port=13231 protocol=udp 
add action=accept chain=input comment="allow WireGuard traffic" in-interface=wireguard1 
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53,8291 protocol=tcp
add action=accept chain=input comment="users to Router services" in-interface-list=LAN dst-port=53 protocol=udp
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=forward comment="allow internet" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="WG to LAN" in-interface=wireguard1 out-interface-list=LAN
add action=drop chain=forward comment="Drop all else"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=Carlos
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=admin group=full password=33338888
/user remove 0