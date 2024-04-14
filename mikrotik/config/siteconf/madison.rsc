/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik 
/interface wireless security-profiles add authentication-types=wpa2-psk mode=dynamic-keys name=madison supplicant-identity="madison" wpa2-pre-shared-key=33338888

/interface wireless    
set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-b/g/n channel-width=\
    20/40mhz-eC country=thailand disabled=no frequency=2457 ssid="Sound@Madison" \
    wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-n/ac channel-width=\
    20/40mhz-XX country=thailand disabled=no frequency=auto installation=\
    indoor mode=ap-bridge radio-name=iDaemon security-profile=madison ssid=\
    iDaemon wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled

/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1 
/interface vlan add interface=BRI-TEST name=VLAN40 vlan-id=40
/interface vlan add interface=BRI-TEST name=VLAN41 vlan-id=41
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan40
/interface list add name=InterfaceListVlan41


/ip pool add name=POOL40 ranges=192.168.40.10-192.168.40.200
/ip pool add name=POOL41 ranges=192.168.41.10-192.168.41.200

/ip dhcp-server add address-pool=POOL40 interface=VLAN40 lease-time=1d name=DHCP40
/ip dhcp-server add address-pool=POOL41 interface=VLAN41 lease-time=1d name=DHCP41
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan40 pvid=40
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan41 pvid=41
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=40
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=41
/interface list member add interface=wlan1 list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan40
/interface list member add interface=ether3 list=InterfaceListVlan40
/interface list member add interface=ether4 list=InterfaceListVlan40
/interface list member add interface=ether5 list=InterfaceListVlan40
/interface list member add interface=VLAN40 list=LAN
/interface list member add interface=VLAN41 list=LAN
/interface list member add interface=wlan2 list=InterfaceListVlan40

/ip address add address=192.168.40.1/24 interface=VLAN40 network=192.168.40.0
/ip address add address=192.168.41.1/24 interface=VLAN41 network=192.168.41.0
/ip address add address=10.11.11.1/24 interface=wireguard1 network=10.11.11.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add disabled=no interface=wlan1
/ip dhcp-server network add address=192.168.40.0/24 dns-server=192.168.40.1 gateway=192.168.40.1
/ip dhcp-server network add address=192.168.41.0/24 dns-server=192.168.41.1 gateway=192.168.41.1
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
/system identity set name=madison
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=sonos group=full password=33338888
/user remove 0