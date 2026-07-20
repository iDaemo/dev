# 2026-07-20 21:18:34 by RouterOS 7.23.2
# software id = J3MH-9KLG
#
# model = C52iG-5HaxD2HaxD
# serial number = HDK08VN3F8D
# custom default configuration script installed
# see /system/default-configuration/custom-script/print
#
/interface bridge
add igmp-snooping=yes name=BRI-TEST protocol-mode=none vlan-filtering=yes
/interface wireguard
add listen-port=13231 mtu=1420 name=wireguard1
/interface vlan
add interface=BRI-TEST name=VLAN100 vlan-id=100
add interface=BRI-TEST name=VLAN111 vlan-id=111
/interface ethernet switch
set switch1 cpu-flow-control=yes
/interface list
add name=MANAGE
add name=LAN
add name=WAN
add name=InterfaceListVlan100
add name=InterfaceListVlan111
/interface wifi channel
add band=5ghz-ac disabled=no frequency=5500,5580,5745 name=ch-5ghz \
    skip-dfs-channels=all width=20/40mhz-Ce
add band=2ghz-n frequency=2412,2437,2462 name=ch-2ghz width=20mhz
/interface wifi security
add authentication-types=wpa2-psk name=common-auth wps=disable
/interface wifi configuration
add country=Thailand name=common-conf security=common-auth ssid=iDaemon
/interface wifi
set [ find default-name=wifi1 ] channel=ch-5ghz configuration=common-conf \
    configuration.mode=ap disabled=no
set [ find default-name=wifi2 ] channel=ch-2ghz channel.frequency=\
    2412,2437,2462 configuration=common-conf configuration.mode=ap .ssid=\
    iDaemon-2G disabled=no
/ip pool
add name=POOL100 ranges=192.168.100.10-192.168.100.200
add name=POOL111 ranges=192.168.111.10-192.168.111.200
/ip dhcp-server
add address-pool=POOL100 interface=VLAN100 lease-time=1d name=DHCP100
add address-pool=POOL111 interface=VLAN111 lease-time=1d name=DHCP111
/ip smb users
set [ find default=yes ] disabled=yes
/system script
add dont-require-permissions=no name=auto_web_login owner=gle policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_\E0\B8\AA\E0\B8\84\E0\B8\A3\E0\B8\B4\E0\B8\9B\E0\B8\95\E0\B9\8C Auto Log\
    in \E0\B8\AA\E0\B8\B3\E0\B8\AB\E0\B8\A3\E0\B8\B1\E0\B8\9A\E0\B8\A3\E0\B8\
    \B0\E0\B8\9A\E0\B8\9A Easy2WiFi (\E0\B8\AB\E0\B9\89\E0\B8\AD\E0\B8\87 310)\
    \n:local TargetPing \"8.8.8.8\";\
    \n:local LoginURL \"http://172.16.0.1/login\";\
    \n# \E0\B9\83\E0\B8\AA\E0\B9\88\E0\B8\A3\E0\B8\AB\E0\B8\B1\E0\B8\AA\E0\B8\
    \9C\E0\B9\88\E0\B8\B2\E0\B8\99\E0\B8\82\E0\B8\AD\E0\B8\87\E0\B8\84\E0\B8\
    \B8\E0\B8\93\E0\B9\81\E0\B8\97\E0\B8\99\E0\B8\97\E0\B8\B5\E0\B9\88\E0\B8\
    \82\E0\B9\89\E0\B8\AD\E0\B8\84\E0\B8\A7\E0\B8\B2\E0\B8\A1\E0\B8\94\E0\B9\
    \89\E0\B8\B2\E0\B8\99\E0\B8\A5\E0\B9\88\E0\B8\B2\E0\B8\87\E0\B8\99\E0\B8\
    \B5\E0\B9\89\
    \n:local LoginData \"username=310&password=8679\";\
    \n\
    \n# \E0\B8\95\E0\B8\A3\E0\B8\A7\E0\B8\88\E0\B8\AA\E0\B8\AD\E0\B8\9A\E0\B8\
    \A7\E0\B9\88\E0\B8\B2\E0\B8\AD\E0\B8\B4\E0\B8\99\E0\B9\80\E0\B8\97\E0\B8\
    \AD\E0\B8\A3\E0\B9\8C\E0\B9\80\E0\B8\99\E0\B9\87\E0\B8\95\E0\B9\83\E0\B8\
    \8A\E0\B9\89\E0\B8\87\E0\B8\B2\E0\B8\99\E0\B9\84\E0\B8\94\E0\B9\89\E0\B8\
    \9B\E0\B8\81\E0\B8\95\E0\B8\B4\E0\B9\84\E0\B8\AB\E0\B8\A1\
    \n:if ([:ping \$TargetPing count=3] = 0) do={\
    \n    :log warning \"Internet is down (Web Auth required). Attempting to l\
    ogin to Easy2WiFi...\";\
    \n    \
    \n    :do {\
    \n        # \E0\B8\A2\E0\B8\B4\E0\B8\87\E0\B8\84\E0\B8\B3\E0\B8\AA\E0\B8\
    \B1\E0\B9\88\E0\B8\87 POST \E0\B8\A5\E0\B9\87\E0\B8\AD\E0\B8\81\E0\B8\AD\
    \E0\B8\B4\E0\B8\99\E0\B9\80\E0\B8\82\E0\B9\89\E0\B8\B2 Hotspot\
    \n        /tool fetch http-method=post url=\$LoginURL http-data=\$LoginDat\
    a keep-result=no;\
    \n        :log info \"Easy2WiFi Auto-login packet sent.\";\
    \n    } on-error={\
    \n        :log error \"Cannot connect to Easy2WiFi server (172.16.0.1)\";\
    \n    }\
    \n}"
/interface bridge port
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan100 pvid=100
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan111 pvid=111
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=100
add bridge=BRI-TEST tagged=BRI-TEST vlan-ids=111
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=MANAGE
add interface=ether3 list=InterfaceListVlan100
add interface=ether4 list=InterfaceListVlan100
add interface=ether5 list=InterfaceListVlan100
add interface=VLAN100 list=LAN
add interface=VLAN111 list=LAN
add interface=wifi1 list=InterfaceListVlan100
add interface=wifi2 list=InterfaceListVlan100
/interface ovpn-server server
add mac-address=FE:BB:E8:69:A1:DA name=ovpn-server1
/interface wireguard peers
add allowed-address=10.0.0.1/32,192.168.10.0/24 disabled=yes \
    endpoint-address=hq.sonoslibra.com endpoint-port=13231 interface=\
    wireguard1 name=sonoshq public-key=\
    "hzWlAOAdla+xUtbMeJxZ7FkESNkCy4uojBdEWRnIvQo="
/ip address
add address=192.168.99.1/30 interface=ether2 network=192.168.99.0
add address=192.168.100.1/24 interface=VLAN100 network=192.168.100.0
add address=192.168.111.1/24 interface=VLAN111 network=192.168.111.0
add address=10.0.0.100/24 interface=wireguard1 network=10.0.0.0
/ip cloud
set ddns-update-interval=1d update-time=no
/ip dhcp-client
add interface=ether1 name=ether1 use-peer-dns=no
/ip dhcp-server network
add address=192.168.100.0/24 dns-server=192.168.100.1 domain=lan.local \
    gateway=192.168.100.1
add address=192.168.111.0/24 dns-server=192.168.111.1 gateway=192.168.111.1
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,8.8.8.8
/ip firewall filter
add action=accept chain=input comment="Allow Established/Related/Untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="Drop Invalid" connection-state=invalid
add action=accept chain=input comment="Allow ICMP (limited)" limit=\
    10,5:packet protocol=icmp
add action=accept chain=input comment="Allow WireGuard handshake" dst-port=\
    13231 protocol=udp
add action=accept chain=input comment=\
    "Allow traffic from WireGuard interface" in-interface=wireguard1
add action=accept chain=input comment="Allow DNS (UDP from LAN)" dst-port=53 \
    in-interface-list=LAN protocol=udp
add action=accept chain=input comment="Allow DNS (TCP from LAN)" dst-port=53 \
    in-interface-list=LAN protocol=tcp
add action=accept chain=input comment="Rate limit Winbox (new TCP)" \
    connection-state=new dst-port=8291 in-interface-list=LAN limit=\
    10,5:packet protocol=tcp
add action=accept chain=input comment="Rate limit Winbox (new TCP)" \
    connection-state=new dst-port=3389 in-interface-list=LAN limit=\
    10,5:packet protocol=tcp
add action=drop chain=input comment="Block WAN to Router Services" \
    in-interface-list=WAN log-prefix="DROP-WAN: "
add action=fasttrack-connection chain=forward comment=\
    "Fasttrack Established Connections" connection-state=established,related
add action=accept chain=forward comment="Allow Established/Related/Untracked" \
    connection-state=established,related,untracked
add action=drop chain=forward comment="Drop Invalid" connection-state=invalid \
    log-prefix="DROP-FWD-INVALID: "
add action=accept chain=forward comment="Allow LAN to WAN" in-interface-list=\
    LAN out-interface-list=WAN
add action=accept chain=forward comment="Allow WireGuard to LAN" \
    in-interface=wireguard1 out-interface-list=LAN
add action=accept chain=forward comment="LAN to WireGuard" in-interface-list=\
    LAN out-interface=wireguard1
add action=drop chain=forward comment="Drop All Else" log-prefix=\
    "DROP-FWD-DEFAULT: "
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
/ip route
add disabled=no dst-address=192.168.10.0/24 gateway=10.0.0.1 routing-table=\
    main
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www-ssl disabled=no
set api disabled=yes
set api-ssl disabled=yes
/system clock
set time-zone-autodetect=no time-zone-name=Asia/Bangkok
/system identity
set name=iDaemonROOM
/system logging
add topics=wireless,debug
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
/system scheduler
add interval=5m name=check_internet on-event=auto_web_login policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
