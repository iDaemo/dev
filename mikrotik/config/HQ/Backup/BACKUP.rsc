# 2023-07-09 23:35:48 by RouterOS 7.10.1
# software id = 04H0-FDC6
#
# model = CCR2004-16G-2S+
# serial number = HD0084APN5W
/interface bridge
add igmp-snooping=yes igmp-version=3 ingress-filtering=no name=BRI-TEST \
    protocol-mode=none query-interval=30s vlan-filtering=yes
/interface ethernet
set [ find default-name=sfp-sfpplus1 ] disabled=yes
set [ find default-name=sfp-sfpplus2 ] disabled=yes
/interface pppoe-client
add add-default-route=yes disabled=no interface=ether1 name=Trueonline \
    password=Password service-name=Trueonline use-peer-dns=yes user=\
    9605418601@fiberhome
/interface wireguard
add listen-port=13231 mtu=1420 name=wg-sonoshq private-key=\
    "0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="
/interface vlan
add interface=BRI-TEST name=VLAN10 vlan-id=10
add interface=BRI-TEST name=VLAN11 vlan-id=11
add interface=BRI-TEST name=VLAN12 vlan-id=256
/interface bonding
add mode=802.3ad name=nas-bonding slaves=ether9,ether10 transmit-hash-policy=\
    layer-2-and-3
/interface list
add name=WAN
add name=InterfaceListVlan10
add name=InterfaceListVlan11
add name=InterfaceListVlan12
add name=LIMITED-ZONE
add name=SERVER-ZONE
add include=InterfaceListVlan10,InterfaceListVlan11 name=LOCAL-BRIDGE
add include=SERVER-ZONE name=FREE-ZONE
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=POOL10 ranges=192.168.1.101-192.168.1.249
add name=POOL11 ranges=192.168.11.101-192.168.11.249
add name=POOL12 ranges=192.168.12.101-192.168.12.249
/ip dhcp-server
add address-pool=POOL10 interface=VLAN10 lease-script="\$[:put [/ip/dhcp-serve\
    r/lease/get value-name=host-name [find where mac-address=\$leaseActMAC]]]" \
    lease-time=1d name=dhcp1
add address-pool=POOL11 interface=VLAN11 lease-time=1d name=dhcp2
add address-pool=POOL12 interface=VLAN12 lease-time=1d name=dhcp3
/port
set 0 name=serial0
set 1 name=serial1
/zerotier
set zt1 comment="ZeroTier Central controller - https://my.zerotier.com/" \
    disabled=yes disabled=yes name=zt1 port=9993
/interface bridge port
add bridge=BRI-TEST ingress-filtering=no interface=ether15
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan10 pvid=10
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan11 pvid=11
add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged \
    interface=InterfaceListVlan12 pvid=12
/interface bridge vlan
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=10
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=11
add bridge=BRI-TEST tagged=BRI-TEST,ether15 vlan-ids=12
/interface list member
add interface=Trueonline list=WAN
add interface=ether3 list=InterfaceListVlan10
add interface=ether4 list=InterfaceListVlan10
add interface=ether5 list=InterfaceListVlan10
add interface=VLAN10 list=FREE-ZONE
add interface=VLAN12 list=LIMITED-ZONE
add interface=ether6 list=InterfaceListVlan10
add interface=ether7 list=InterfaceListVlan10
add interface=ether8 list=InterfaceListVlan10
add interface=ether11 list=InterfaceListVlan10
add interface=ether13 list=InterfaceListVlan10
add interface=ether14 list=InterfaceListVlan10
add interface=ether12 list=InterfaceListVlan10
add interface=ether16 list=InterfaceListVlan10
add interface=nas-bonding list=InterfaceListVlan10
add interface=VLAN11 list=SERVER-ZONE
add interface=wg-sonoshq list=InterfaceListVlan10
/interface wireguard peers
add allowed-address=10.0.0.2/32 interface=wg-sonoshq public-key=\
    "MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
add allowed-address=10.0.0.3/32 interface=wg-sonoshq public-key=\
    "MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
add allowed-address=10.0.0.4/32 interface=wg-sonoshq public-key=\
    "4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
add allowed-address=10.0.0.5/32 interface=wg-sonoshq public-key=\
    "TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
add allowed-address=10.0.0.6/32 interface=wg-sonoshq public-key=\
    "VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
add allowed-address=10.0.0.7/32 interface=wg-sonoshq public-key=\
    "FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
add allowed-address=10.0.0.8/32 interface=wg-sonoshq public-key=\
    "kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
add allowed-address=10.0.0.9/32 interface=wg-sonoshq public-key=\
    "5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
add allowed-address=10.0.0.10/32 interface=wg-sonoshq public-key=\
    "sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
add allowed-address=10.0.0.11/32 interface=wg-sonoshq public-key=\
    "Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
/ip address
add address=192.168.1.1/24 interface=VLAN10 network=192.168.1.0
add address=192.168.11.1/24 interface=VLAN11 network=192.168.11.0
add address=192.168.12.1/24 interface=VLAN12 network=192.168.12.0
add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip arp
add address=192.168.1.20 interface=VLAN10 mac-address=00:8A:76:F0:E5:19
/ip cloud
set ddns-enabled=yes ddns-update-interval=1d update-time=no
/ip dhcp-client
add disabled=yes interface=ether1
/ip dhcp-server lease
add address=192.168.1.11 client-id=1:b0:1f:8c:c7:d7:c2 mac-address=\
    B0:1F:8C:C7:D7:C2 server=dhcp1
add address=192.168.1.16 client-id=1:9c:3e:53:e:4:9e mac-address=\
    9C:3E:53:0E:04:9E server=dhcp1
add address=192.168.1.12 client-id=1:b0:1f:8c:c7:cd:c4 mac-address=\
    B0:1F:8C:C7:CD:C4 server=dhcp1
add address=192.168.1.20 client-id=1:0:8a:76:f0:e5:19 mac-address=\
    00:8A:76:F0:E5:19 server=dhcp1
add address=192.168.1.17 client-id=1:f0:b3:ec:80:37:b6 mac-address=\
    F0:B3:EC:80:37:B6 server=dhcp1
add address=192.168.1.19 client-id=1:44:d2:44:fb:6b:1b mac-address=\
    44:D2:44:FB:6B:1B server=dhcp1
add address=192.168.1.18 client-id=1:dc:cd:2f:79:32:8d mac-address=\
    DC:CD:2F:79:32:8D server=dhcp1
/ip dhcp-server network
add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
add address=192.168.12.0/24 dns-server=192.168.12.1 gateway=192.168.12.1
/ip dns
set allow-remote-requests=yes
/ip firewall filter
add action=jump chain=forward disabled=yes in-interface-list=LIMITED-ZONE \
    jump-target=ChainForwardLimited out-interface-list=WAN
add action=jump chain=forward disabled=yes in-interface-list=WAN jump-target=\
    ChainForwardLimited out-interface-list=LIMITED-ZONE
add action=jump chain=forward disabled=yes in-interface-list=FREE-ZONE \
    jump-target=ChainForwardAll out-interface-list=WAN
add action=jump chain=forward disabled=yes in-interface-list=WAN jump-target=\
    ChainForwardAll out-interface-list=FREE-ZONE
add action=jump chain=forward disabled=yes in-interface=wg-sonoshq \
    jump-target=ChainForwardAll out-interface=VLAN10
add action=drop chain=forward disabled=yes
add action=jump chain=input dst-port=13231 in-interface-list=WAN jump-target=\
    AcceptInput protocol=udp
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput \
    protocol=udp src-port=53,123
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput \
    protocol=tcp src-port=80,443
add action=jump chain=input dst-port=8291,5900 in-interface-list=WAN \
    jump-target=AcceptInput protocol=tcp
add action=jump chain=input in-interface-list=WAN jump-target=AcceptInput \
    protocol=icmp
add action=drop chain=input in-interface-list=WAN
add action=accept chain=ChainForwardLimited dst-port=80,443,8080 protocol=tcp
add action=accept chain=ChainForwardLimited protocol=tcp src-port=80,443,8080
add action=accept chain=ChainForwardLimited protocol=icmp
add action=accept chain=ChainForwardAll
add action=accept chain=AcceptInput
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
/ip service
set telnet disabled=yes
set ssh disabled=yes
set www-ssl disabled=no
/system clock
set time-zone-name=Asia/Bangkok
/system identity
set name=SonosLibraHQ
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
/system scheduler
add interval=5m name=cf-updater on-event="/system script run cf_update" \
    policy=ftp,read,write,test start-date=2023-07-09 start-time=00:49:03
/system script
add dont-require-permissions=no name=cf_update owner=admin policy=\
    ftp,read,write,test source="################# CloudFlare variables #######\
    ##########\r\
    \n:local CFDebug \"false\"\r\
    \n:local CFcloud \"false\"\r\
    \n\r\
    \n:global WANInterface \"Trueonline\"\r\
    \n\r\
    \n:local CFdomain \"hq.sonoslibra.com\"\r\
    \n\r\
    \n:local CFtkn \"0Wig2bVDagpecrDPqfkRKoxbLedTeE_KAnnKuOxF\"\r\
    \n\r\
    \n:local CFzoneid \"99b45096ed0908a2216d066429fc2fb9\"\r\
    \n:local CFid \"1368e72a5a6f9dc560572df630334038\"\r\
    \n\r\
    \n:local CFrecordType \"\"\r\
    \n:set CFrecordType \"A\"\r\
    \n\r\
    \n:local CFrecordTTL \"\"\r\
    \n:set CFrecordTTL \"300\"\r\
    \n\r\
    \n########################################################################\
    #\r\
    \n########################  DO NOT EDIT BELOW  ###########################\
    #\r\
    \n########################################################################\
    #\r\
    \n\r\
    \n##:log info \"Updating \$CFDomain ...\"\r\
    \n\r\
    \n################# Internal variables #################\r\
    \n:local previousIP \"\"\r\
    \n:global WANip \"\"\r\
    \n\r\
    \n################# Build CF API Url (v4) #################\r\
    \n:local CFurl \"https://api.cloudflare.com/client/v4/zones/\"\r\
    \n:set CFurl (\$CFurl . \"\$CFzoneid/dns_records/\$CFid\");\r\
    \n \r\
    \n################# Get or set previous IP-variables #################\r\
    \n:if (\$CFcloud = \"true\") do={\r\
    \n    :set WANip [/ip cloud get public-address]\r\
    \n};\r\
    \n\r\
    \n:if (\$CFcloud = \"false\") do={\r\
    \n    :local currentIP [/ip address get [/ip address find interface=\$WANI\
    nterface ] address];\r\
    \n    :set WANip [:pick \$currentIP 0 [:find \$currentIP \"/\"]];\r\
    \n};\r\
    \n\r\
    \n:if ([/file find name=ddns.tmp.txt] = \"\") do={\r\
    \n    :log error \"No previous ip address file found, createing...\"\r\
    \n    :set previousIP \$WANip;\r\
    \n    :execute script=\":put \$WANip\" file=\"ddns.tmp\";\r\
    \n    :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n    /tool fetch http-method=put mode=https output=none url=\"\$CFurl\" h\
    ttp-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/j\
    son\" http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$\
    CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\
    \r\
    \n    :error message=\"No previous ip address file found.\"\r\
    \n} else={\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={ \r\
    \n    :global content [/file get [/file find name=\"ddns.tmp.txt\"] conten\
    ts] ;\r\
    \n    :global contentLen [ :len \$content ] ;  \r\
    \n    :global lineEnd 0;\r\
    \n    :global line \"\";\r\
    \n    :global lastEnd 0;   \r\
    \n            :set lineEnd [:find \$content \"\\n\" \$lastEnd ] ;\r\
    \n            :set line [:pick \$content \$lastEnd \$lineEnd] ;\r\
    \n            :set lastEnd ( \$lineEnd + 1 ) ;   \r\
    \n            :if ( [:pick \$line 0 1] != \"#\" ) do={   \r\
    \n                #:local previousIP [:pick \$line 0 \$lineEnd ]\r\
    \n                :set previousIP [:pick \$line 0 \$lineEnd ];\r\
    \n                :set previousIP [:pick \$previousIP 0 [:find \$previousI\
    P \"\\r\"]];\r\
    \n            }\r\
    \n    }\r\
    \n}\r\
    \n\r\
    \n######## Write debug info to log #################\r\
    \n:if (\$CFDebug = \"true\") do={\r\
    \n :log info (\"CF: hostname = \$CFdomain\")\r\
    \n :log info (\"CF: previousIP = \$previousIP\")\r\
    \n :log info (\"CF: currentIP = \$currentIP\")\r\
    \n :log info (\"CF: WANip = \$WANip\")\r\
    \n :log info (\"CF: CFurl = \$CFurl&content=\$WANip\")\r\
    \n :log info (\"CF: Command = \\\"/tool fetch http-method=put mode=https u\
    rl=\\\"\$CFurl\\\" http-header-field=\"Authorization:Bearer \$CFtkn,conten\
    t-type:application/json\" output=none http-data=\\\"{\\\"type\\\":\\\"\$CF\
    recordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\
    \\\"content\\\":\\\"\$WANip\\\"}\\\"\")\r\
    \n};\r\
    \n  \r\
    \n######## Compare and update CF if necessary #####\r\
    \n:if (\$previousIP != \$WANip) do={\r\
    \n :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n /tool fetch http-method=put mode=https url=\"\$CFurl\" http-header-fiel\
    d=\"Authorization:Bearer \$CFtkn,content-type:application/json\" output=no\
    ne http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFd\
    omain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\r\
    \n /ip dns cache flush\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={\r\
    \n        /file remove ddns.tmp.txt\r\
    \n        :execute script=\":put \$WANip\" file=\"ddns.tmp\"\r\
    \n    }\r\
    \n} else={\r\
    \n# :log info \"CF: No Update Needed!\"\r\
    \n}"
add dont-require-permissions=no name=updatearp owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":\
    local wanInterfaceName \"Trueonline\";\r\
    \n# Remove ARP entries that do not have static DHCP leases or are disabled\
    \r\
    \n:foreach arpId in=[/ip arp find] do={\r\
    \n#Don't remove the dynamic entry on the WAN side\r\
    \n  :if ([/ip arp get \$arpId interface] != \$wanInterfaceName) do={\r\
    \n#If there is no matching entry in the lease table remove it\r\
    \n:local mac [/ip arp get \$arpId mac-address];\r\
    \n:local leaseId [/ip dhcp-server lease find where mac-address=\$mac];\r\
    \n:if (\$leaseId=\"\") do={\r\
    \n/ip arp remove \$arpId;\r\
    \n:log info (\"Removing old ARP entry\");\r\
    \n} else={\r\
    \n:if ([/ip dhcp-server lease get \$leaseId disabled]) do={\r\
    \n/ip arp remove \$arpId;\r\
    \n:log info (\"Removing disabled ARP entry\");\r\
    \n}}}}\r\
    \n:foreach leaseId in=[/ip dhcp-server lease find where !dynamic] do={\r\
    \n:local mac  [/ip dhcp-server lease get \$leaseId mac-address];\r\
    \n:local arpId [/ip arp find where mac-address=\$mac];\r\
    \n:if (\$arpId=\"\" && ![/ip dhcp-server lease get \$leaseId disabled]) do\
    ={\r\
    \n:local ip [/ip dhcp-server lease get \$leaseId address];\r\
    \n:local comment  [/ip dhcp-server lease get \$leaseId comment];\r\
    \n#interface should not be hard coded but couldn't figure out what to do\r\
    \n:local interface lan_wlan_bridge;\r\
    \n/ip arp add address= \$ip mac-address= \$mac comment= \$comment interfac\
    e= \$interface;\r\
    \n:log info (\"Adding new ARP entry\");\r\
    \n}\r\
    \n}"
