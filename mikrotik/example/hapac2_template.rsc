#######################################
# HAP ac2 Config file MUST INSTALL EXTRA PACKAGE wifi-qcom-ac.apk
# Notes:		Start with a reset (/system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=flash/router-config.rsc)
#######################################

:delay 30s

#######################################
# Housekeeping
#######################################

# name the device being configured
/system identity set name=COCOTAM

#######################################
# Bridge
#######################################

# create one bridge, set VLAN mode off while we configure
/interface bridge add name=BRI-TEST protocol-mode=none vlan-filtering=no

#######################################
# WIFI Setup
#######################################
/interface wifi security
add name=common-auth authentication-types=wpa2-psk passphrase="33338888" wps=disable

/interface wifi configuration
add name=common-conf ssid=@SOUDCONTROLsonosxaura country=Thailand security=common-auth

/interface wifi channel
add name=ch-2ghz frequency=2412,2437,2462 band=2ghz-n width=20mhz
add name=ch-5ghz frequency=5500,5580,5745 band=5ghz-ac width=20/40/80mhz

# Assign wifi with common config
/interface wifi
set wifi1 channel=2ghz configuration=common-conf disabled=no
set wifi2 channel=5ghz configuration=common-conf disabled=no

/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik 
/interface wireless security-profiles add authentication-types=wpa2-psk mode=dynamic-keys name=sonos supplicant-identity="sonos" wpa2-pre-shared-key=33338888
/interface wireless    
set [ find default-name=wlan1 ] adaptive-noise-immunity=ap-and-client-mode antenna-gain=3 band=2ghz-onlyn \
    channel-width=20mhz country=thailand disabled=no frequency=2462 frequency-mode=regulatory-domain installation=indoor \
    mode=ap-bridge multicast-buffering=disabled multicast-helper=full skip-dfs-channels=all \
    ssid=@SOUDCONTROLsonosxaura wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled security-profile=sonos
set [ find default-name=wlan2 ] adaptive-noise-immunity=ap-and-client-mode antenna-gain=3 band=5ghz-onlyac \
    channel-width=20/40/80mhz country=thailand disabled=no frequency=5500 frequency-mode=regulatory-domain installation=indoor \
    mode=ap-bridge multicast-buffering=disabled multicast-helper=full skip-dfs-channels=all \
    ssid=@SOUDCONTROLsonosxaura wireless-protocol=802.11 wmm-support=enabled wps-mode=disabled security-profile=sonos
/interface wireless access-list
add interface=wlan2 signal-range=-80..120 allow-signal-out-of-range=30s comment="5GHz Preferred"
add interface=wlan1 signal-range=-90..-71 allow-signal-out-of-range=15s comment="2.4GHz Fallback Only"

/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan add interface=BRI-TEST name=VLAN40 vlan-id=40
/interface list add name=LAN
/interface list add name=WAN
/interface list add name=InterfaceListVlan40

/ip pool add name=POOL40 ranges=192.168.40.40-192.168.40.240

/ip dhcp-server add address-pool=POOL40 interface=VLAN40 lease-time=1d name=DHCP40

/interface enable wlan1
/interface enable wlan2
:foreach i in=[/interface ethernet find where name~"ether" and name!="ether1"] do={
  /interface bridge port add interface=$i bridge=BRI-TEST pvid=40 frame-types=admit-only-untagged-and-priority-tagged
}
/interface bridge port add interface=wlan1 bridge=BRI-TEST pvid=40 frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add interface=wlan2 bridge=BRI-TEST pvid=40 frame-types=admit-only-untagged-and-priority-tagged

/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=40
/interface list member add interface=VLAN40 list=LAN
/interface list member add interface=ether1 list=WAN
/interface list member add interface=ether2 list=InterfaceListVlan40
/interface list member add interface=ether3 list=InterfaceListVlan40
/interface list member add interface=ether4 list=InterfaceListVlan40
/interface list member add interface=ether5 list=InterfaceListVlan40
/interface list member add interface=wlan1 list=InterfaceListVlan40
/interface list member add interface=wlan2 list=InterfaceListVlan40


/ip address add address=192.168.40.1/24 interface=VLAN40 network=192.168.40.0
/ip cloud set ddns-enabled=no ddns-update-interval=1d update-time=no

/ip dhcp-client add disabled=no interface=ether1
/ip dhcp-server network add address=192.168.40.0/24 dns-server=192.168.40.1 gateway=192.168.40.1
/ip dns set allow-remote-requests=yes

/ip firewall filter
# INPUT Chain
add action=accept chain=input comment="Allow Established/Related/Untracked" connection-state=established,related,untracked
add action=drop chain=input comment="Drop Invalid" connection-state=invalid
add action=accept chain=input comment="Allow ICMP (limited)" protocol=icmp limit=10,5
add action=accept chain=input comment="Allow WireGuard handshake" dst-port=13231 protocol=udp
add action=accept chain=input comment="Allow traffic from WireGuard interface" in-interface=wireguard1
add action=accept chain=input comment="Allow DNS (UDP from LAN)" in-interface-list=LAN dst-port=53 protocol=udp
add action=accept chain=input comment="Allow DNS and Winbox (TCP from LAN)" in-interface-list=LAN dst-port=53,8291 protocol=tcp
add action=accept chain=input comment="Rate limit Winbox (new TCP)" protocol=tcp dst-port=8291 in-interface-list=LAN connection-state=new limit=10,5
add action=drop chain=input comment="Drop All Other Input" log-prefix=drop-input:

# FORWARD Chain
add action=fasttrack-connection chain=forward comment="Fasttrack Established Connections" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="Allow Established/Related/Untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="Drop Invalid" connection-state=invalid
add action=accept chain=forward comment="Allow LAN to WAN" in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="Allow WireGuard to LAN" in-interface=wireguard1 out-interface-list=LAN
add action=drop chain=forward comment="Drop All Other Forwarded Traffic"
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN


/system clock set time-zone-name=Asia/Bangkok
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/ip service disable telnet,ftp,www,api
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
/interface bridge set BRI-TEST vlan-filtering=yes frame-types=admit-only-vlan-tagged