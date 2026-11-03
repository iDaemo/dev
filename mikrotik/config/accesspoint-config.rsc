#######################################
# HAP ac2 Access Point Config (Flat Bridge)
# Requires package: wifi-qcom-ac
# Reset command: /system reset-configuration no-defaults=yes skip-backup=yes run-after-reset=router-config.rsc
#######################################

:delay 30s

#######################################
# Housekeeping
#######################################
/system identity set name=SonosAP

#######################################
# Bridge Setup
#######################################
# Create one flat bridge for all ports and Wi-Fi
/interface bridge add name=BRI-TEST protocol-mode=rstp vlan-filtering=no

#######################################
# WIFI Setup
#######################################
/interface wifi security add name=common-auth authentication-types=wpa2-psk passphrase="33338888" wps=disable
/interface wifi configuration add name=common-conf ssid=@CONTROLsonosxaura country=Thailand security=common-auth

/interface wifi channel add name=ch-2ghz frequency=2412,2437,2462 band=2ghz-n width=20mhz
/interface wifi channel add name=ch-5ghz frequency=5500,5580,5745 band=5ghz-ac width=20/40mhz-Ce

/interface wifi set wifi1 channel=ch-2ghz configuration=common-conf disabled=no 
/interface wifi set wifi2 channel=ch-5ghz configuration=common-conf disabled=no

/system logging add topics=wireless,debug action=memory

#######################################
# Interface & Bridge Port Setup
#######################################
/interface list add name=LAN

# Group all physical ports (including ether1) and Wi-Fi into the LAN list
/interface list member add interface=BRI-TEST list=LAN
/interface list member add interface=ether1 list=LAN
/interface list member add interface=ether2 list=LAN
/interface list member add interface=ether3 list=LAN
/interface list member add interface=ether4 list=LAN
/interface list member add interface=ether5 list=LAN
/interface list member add interface=wifi1 list=LAN
/interface list member add interface=wifi2 list=LAN

# Add all ports (ether1-5 and wifi1-2) to the bridge
/interface bridge port add bridge=BRI-TEST interface=ether1
/interface bridge port add bridge=BRI-TEST interface=ether2
/interface bridge port add bridge=BRI-TEST interface=ether3
/interface bridge port add bridge=BRI-TEST interface=ether4
/interface bridge port add bridge=BRI-TEST interface=ether5
/interface bridge port add bridge=BRI-TEST interface=wifi1
/interface bridge port add bridge=BRI-TEST interface=wifi2

# Get management IP, Gateway, and DNS from the main router via ether1 (on the bridge)
/ip dhcp-client add interface=BRI-TEST disabled=no

# WireGuard (Optional - Note: Requires port forward 13231/UDP on your main router to work)
/interface wireguard add listen-port=13231 mtu=1420 name=wireguard1
/ip address add address=10.0.0.40/24 interface=wireguard1 network=10.0.0.0

#######################################
# FIREWALL (Lightened for AP Mode)
#######################################
# NAT and Forward drops are removed because the upstream router handles firewalling.
/ip firewall filter
add chain=input action=accept comment="Allow Estab & Related" connection-state=established,related,untracked
add chain=input action=drop comment="Drop invalid input" connection-state=invalid
add chain=input action=accept comment="ICMP" protocol=icmp
add chain=input action=accept comment="WireGuard" dst-port=13231 protocol=udp
add chain=input action=accept comment="Winbox" dst-port=8291 protocol=tcp 
add chain=input action=accept comment="Allow LAN" in-interface-list=LAN 
add chain=input action=drop comment="Drop else INPUT"

#######################################
# SYSTEM SETUP
#######################################
/ipv6 settings set disable-ipv6=yes
/ipv6 nd set [ find default=yes ] disabled=yes
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system clock set time-zone-autodetect=no
/system clock set time-zone-name=Asia/Bangkok
/system note set show-at-login=no
/ip service disable telnet,ftp,api,ssh,api-ssl
/ip service set ssh port=22022
/ip ssh set strong-crypto=yes
/ip proxy set enabled=no
/ip upnp set enabled=no
/ip socks set enabled=no
/tool bandwidth-server set enabled=no
/user add name=sonos group=full password=33338888
/user remove [find name=admin]