#:local 2G ([/interface wireless print as-value where band~"2ghz*"]->0->"name");
#:local 5G ([/interface wireless print as-value where band~"5ghz*"]->0->"name");

#/interface wireless
#set [ find default-name=$5G ] band=5ghz-a/n/ac channel-width=20/40/80mhz-Ceee \
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=@SonosLibraControl2G
#set [ find default-name=$2G ] band=2ghz-g/n channel-width=20mhz\
#    country=thailand antenna-gain=2 disabled=no mode=ap-bridge wmm-support=enabled wps-mode=disabled \
#    ssid=@SonosLibraControl2.4G

#/interface wireless security-profiles
#set [ find default=yes ] supplicant-identity=EngineerRack
#/interface wireless security-profiles
#set [ find default=yes ] supplicant-identity=MikroTik
#add authentication-types=wpa2-psk mode=dynamic-keys name=sonos supplicant-identity=""
#/interface wireless
#set [ find default-name=wlan2 ] band=5ghz-a/n/ac country=thailand disabled=no frequency=auto mode=\
#   ap-bridge security-profile=sonos ssid=@SonosControl5G wps-mode=disabled

## Example Setting
# /interface wireless security-profiles
#set [ find default=yes ] supplicant-identity=MikroTik
#add authentication-types=wpa-psk,wpa2-psk eap-methods="" group-key-update=1h management-protection=allowed mode=dynamic-keys name=profile1 supplicant-identity="" wpa-pre-shared-key="CHANGEME" wpa2-pre-shared-key="CHANGEME"
#/interface wireless
#set [ find default-name=wlan1 ] band=2ghz-b/g/n comment=2.4GHz country=ireland distance=indoors frequency=2437 mac-address=C4:AD:34:06:B0:2D mode=ap-bridge radio-name="CHANGEME" security-profile=profile1 ssid="CHANGEME" station-roaming=enabled tx-power=10 tx-power-mode=all-rates-fixed \
#    wireless-protocol=802.11 wps-mode=disabled
#set [ find default-name=wlan2 ] adaptive-noise-immunity=ap-and-client-mode band=5ghz-a/n/ac channel-width=20/40mhz-eC comment=5GHz country=no_country_set distance=indoors frequency=5300 frequency-mode=manual-txpower installation=indoor mode=ap-bridge multicast-buffering=disabled multicast-helper=disabled radio-name=test security-profile=Freebacon_WiFi ssid=CHANGEME station-roaming=enabled wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled
#/interface wireless manual-tx-power-table
#set wlan1 comment=2.4GHz
#set wlan2 comment=5GHz
#/interface wireless nstreme
#set wlan1 comment=2.4GHz
#set wlan2 comment=5GHz enable-polling=no


/interface bridge
add name=BRI-TEST protocol-mode=none vlan-filtering=yes

/interface vlan
add comment=ServerZone interface=BRI-TEST name=VLAN10 vlan-id=10 
add comment=Engineer interface=BRI-TEST name=VLAN11 vlan-id=11
add comment=Guest interface=BRI-TEST name=VLAN12 vlan-id=12
add comment=DantePRI interface=BRI-TEST name=VLAN100 vlan-id=100

/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=InterfaceListVlan100
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan11,InterfaceListVlan12 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE

/ip pool
add name=POOL10 ranges=192.168.10.110-192.168.10.200
add name=POOL11 ranges=192.168.11.110-192.168.11.200
add name=POOL12 ranges=192.168.12.110-192.168.12.200
add name=POOL100 ranges=192.168.100.110-192.168.100.200

/ip dhcp-server
add address-pool=POOL11 interface=VLAN11 name=DHCP11
add address-pool=POOL12 interface=VLAN12 name=DHCP12
add address-pool=POOL10 interface=VLAN10 name=DHCP10
add address-pool=POOL100 interface=VLAN100 name=DHCP100

/interface bridge port
add bridge=BRI-TEST interface=InterfaceListVlan10 pvid=10
add bridge=BRI-TEST interface=InterfaceListVlan11 pvid=11
add bridge=BRI-TEST interface=InterfaceListVlan12 pvid=12
add bridge=BRI-TEST interface=InterfaceListVlan100 pvid=100

/ip neighbor discovery-settings
set discover-interface-list=!dynamic

/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=11
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=12
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100

/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=InterfaceListVlan100
add interface=ether3 list=InterfaceListVlan100
add interface=ether4 list=InterfaceListVlan11
add interface=ether5 list=InterfaceListVlan11
add interface=VLAN11 list=FREE-ZONE
add interface=VLAN12 list=LIMITED-ZONE
add interface=VLAN100 list=SERVER-ZONE
#add interface=wlan1 list=InterfaceListVlan101
#add interface=wlan2 list=InterfaceListVlan11

/ip address
add address=192.168.11.1/24 interface=VLAN11 network=192.168.11.0
add address=192.168.12.1/24 interface=VLAN12 network=192.168.12.0
add address=192.168.10.1/24 interface=VLAN10 network=192.168.10.0
add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0

/ip dhcp-client
add interface=ether1

/ip dhcp-server network
add address=192.168.10.0/24 dns-server=192.168.10.1 gateway=192.168.10.1
add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
add address=192.168.12.0/24 dns-server=192.168.12.1 gateway=192.168.12.1
add address=192.168.100.0/24 dns-server=192.168.100.1 gateway=192.168.100.1

/ip dns
set allow-remote-requests=yes

/ip firewall filter
add action=jump chain=forward in-interface-list=LOCAL-BRIDGE jump-target=ChainForwardAll out-interface-list=SERVER-ZONE
add action=jump chain=forward in-interface-list=SERVER-ZONE jump-target=ChainForwardAll out-interface-list=LOCAL-BRIDGE
add action=jump chain=forward in-interface-list=LIMITED-ZONE jump-target=ChainForwardLimited out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardLimited out-interface-list=LIMITED-ZONE
add action=jump chain=forward in-interface-list=FREE-ZONE jump-target=ChainForwardAll out-interface-list=WAN
add action=jump chain=forward in-interface-list=WAN jump-target=ChainForwardAll out-interface-list=FREE-ZONE
add action=drop chain=forward
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput protocol=udp src-port=53
add action=accept chain=ChainForwardLimited dst-port=80,443,8080 protocol=tcp
add action=accept chain=ChainForwardLimited protocol=tcp src-port=80,443,8080
add action=accept chain=ChainForwardLimited protocol=icmp
add action=accept chain=ChainForwardAll
add action=accept chain=AcceptInput

/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN

#/system clock
#set time-zone-name=Asia/Bangkok
#/system ntp client
#set enabled=yes
#/system ntp client servers
#add address=162.159.200.123
#add address=103.47.76.177

#clean up
#disable bandwidth server
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/system identity set name=SonosControlAP
/user remove 0

/ip cloud set ddns-enabled=yes update-time=yes
/system clock set time-zone-autodetect=yes