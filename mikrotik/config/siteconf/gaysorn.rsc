/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik 
/interface wireless security-profiles add authentication-types=wpa2-psk mode=dynamic-keys name=sonos supplicant-identity="sonos" wpa2-pre-shared-key=33338888

/interface wireless    
set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-onlyg channel-width=\
    20mhz country=thailand disabled=yes frequency=auto ssid=".AURA@SoundControl" \
    wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-n/ac channel-width=\
    20/40mhz-XX country=thailand disabled=yes frequency=auto installation=\
    indoor mode=ap-bridge radio-name=sonos security-profile=sonos ssid=\
    SoundControl@Aura wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled

/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN37 vlan-id=37
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan37

/ip pool add name=POOL37 ranges=192.168.37.10-192.168.37.220

/ip dhcp-server add address-pool=POOL37 interface=VLAN37 lease-time=1d name=DHCP37
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan37 pvid=37
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=37
/interface list member add interface=wlan1 list=WAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan37
/interface list member add interface=ether3 list=InterfaceListVlan37
/interface list member add interface=ether4 list=InterfaceListVlan37
/interface list member add interface=ether5 list=InterfaceListVlan37
/interface list member add interface=VLAN37 list=LAN
/interface list member add interface=wlan2 list=InterfaceListVlan37

/ip address add address=192.168.37.1/24 interface=VLAN37 network=192.168.37.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.37.0/24 dns-server=192.168.37.1 gateway=192.168.37.1
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
/system identity set name=muin
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=sonos group=full password=33338888
/user remove 0