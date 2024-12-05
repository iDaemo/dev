/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik 
/interface wireless security-profiles add authentication-types=wpa2-psk mode=dynamic-keys name=platform supplicant-identity="platform" wpa2-pre-shared-key=33338888

/interface wireless    
set [ find default-name=wlan1 ] antenna-gain=2 band=2ghz-b/g/n channel-width=\
    20/40mhz-eC country=thailand disabled=no frequency=2457 ssid="@ControlSonos2G" \
    wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
set [ find default-name=wlan2 ] antenna-gain=2 band=5ghz-n/ac channel-width=\
    20/40mhz-XX country=thailand disabled=no frequency=auto installation=\
    indoor mode=ap-bridge radio-name=platform security-profile=platform ssid=\
    @ControlSonos wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled

/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN26 vlan-id=26
/interface vlan add interface=BRI-TEST name=VLAN27 vlan-id=27
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan26
/interface list add name=InterfaceListVlan27


/ip pool add name=POOL26 ranges=192.168.26.10-192.168.26.200
/ip pool add name=POOL27 ranges=192.168.27.10-192.168.27.200

/ip dhcp-server add address-pool=POOL26 interface=VLAN26 lease-time=1d name=DHCP26
/ip dhcp-server add address-pool=POOL27 interface=VLAN27 lease-time=1d name=DHCP27
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan26 pvid=26
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan27 pvid=27
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=26
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=27
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan26
/interface list member add interface=ether3 list=InterfaceListVlan26
/interface list member add interface=ether4 list=InterfaceListVlan26
/interface list member add interface=ether5 list=InterfaceListVlan26
/interface list member add interface=VLAN26 list=LAN
/interface list member add interface=VLAN26 list=LAN
/interface list member add interface=wlan1 list=InterfaceListVlan26
/interface list member add interface=wlan2 list=InterfaceListVlan26

/ip address add address=192.168.26.1/24 interface=VLAN26 network=192.168.26.0
/ip address add address=192.168.27.1/24 interface=VLAN27 network=192.168.27.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.26.0/24 dns-server=192.168.26.1 gateway=192.168.26.1
/ip dhcp-server network add address=192.168.27.0/24 dns-server=192.168.27.1 gateway=192.168.27.1
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
/system identity set name=PlatformCM
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/user add name=sonos group=full password=33338888
/user remove 0