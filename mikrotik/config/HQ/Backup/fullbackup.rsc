# 2023-07-11 23:15:42 by RouterOS 7.10.1
# software id = 04H0-FDC6
#
# model = CCR2004-16G-2S+
# serial number = HD0084APN5W
/interface bridge add igmp-snooping=yes igmp-version=3 name=BRI-TEST protocol-mode=none query-interval=30s vlan-filtering=yes
/interface ethernet set [ find default-name=ether1 ] name=ether1-wan
/interface ethernet set [ find default-name=ether2 ] name=ether2-oob
/interface ethernet set [ find default-name=ether9 ] name=ether9-bonding
/interface ethernet set [ find default-name=ether10 ] name=ether10-bonding
/interface ethernet set [ find default-name=ether15 ] name=ether15-trunk
/interface ethernet set [ find default-name=ether16 ] name=ether16-fl3
/interface ethernet set [ find default-name=sfp-sfpplus1 ] disabled=yes
/interface ethernet set [ find default-name=sfp-sfpplus2 ] disabled=yes
/interface pppoe-client add add-default-route=yes disabled=no interface=ether1-wan name=Trueonline password=Password service-name=Trueonline use-peer-dns=yes user=9605418601@fiberhome
/interface wireguard add listen-port=13231 mtu=1420 name=wg-sonoshq private-key="0P7UrLurunhoIkU4+cUp3wjS3XbL0uUeqr4gbm/po3E="
/interface vlan add interface=BRI-TEST name=VLAN10 vlan-id=10
/interface vlan add interface=BRI-TEST name=VLAN11 vlan-id=11
/interface vlan add interface=BRI-TEST name=VLAN12 vlan-id=256
/interface bonding add mode=802.3ad name=nas-bonding slaves=ether9-bonding,ether10-bonding transmit-hash-policy=layer-2-and-3
/interface list add name=WAN
/interface list add name=InterfaceListVlan10
/interface list add name=InterfaceListVlan11
/interface list add name=InterfaceListVlan12
/interface list add name=VLANS
/interface list add name=BASE
/interface wireless security-profiles set [ find default=yes ] supplicant-identity=MikroTik
/ip pool add name=POOL10 ranges=192.168.1.101-192.168.1.249
/ip pool add name=POOL11 ranges=192.168.11.101-192.168.11.249
/ip pool add name=POOL12 ranges=192.168.12.101-192.168.12.249
/ip dhcp-server add address-pool=POOL10 interface=VLAN10 lease-time=1d name=dhcp1
/ip dhcp-server add address-pool=POOL11 interface=VLAN11 lease-time=1d name=dhcp2
/ip dhcp-server add address-pool=POOL12 interface=VLAN12 lease-time=1d name=dhcp3
/port set 0 name=serial0
/port set 1 name=serial1
/system logging action add bsd-syslog=yes name=syslog remote=192.168.1.250 target=remote
/zerotier set zt1 comment="ZeroTier Central controller - https://my.zerotier.com/" disabled=yes disabled=yes name=zt1 port=9993
/interface bridge port add bridge=BRI-TEST fast-leave=yes frame-types=admit-only-vlan-tagged interface=ether15-trunk trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan10 pvid=10 trusted=yes
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan11 pvid=11
/interface bridge port add bridge=BRI-TEST frame-types=admit-only-untagged-and-priority-tagged interface=InterfaceListVlan12 pvid=12
/ip neighbor discovery-settings set discover-interface-list=BASE
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=10
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=11
/interface bridge vlan add bridge=BRI-TEST tagged=BRI-TEST,ether15-trunk vlan-ids=12
/interface list member add interface=Trueonline list=WAN
/interface list member add interface=ether3 list=InterfaceListVlan10
/interface list member add interface=ether4 list=InterfaceListVlan10
/interface list member add interface=ether5 list=InterfaceListVlan10
/interface list member add interface=ether6 list=InterfaceListVlan10
/interface list member add interface=ether7 list=InterfaceListVlan10
/interface list member add interface=ether8 list=InterfaceListVlan10
/interface list member add interface=ether11 list=InterfaceListVlan10
/interface list member add interface=ether13 list=InterfaceListVlan10
/interface list member add interface=ether14 list=InterfaceListVlan10
/interface list member add interface=ether12 list=InterfaceListVlan10
/interface list member add interface=ether16-fl3 list=InterfaceListVlan10
/interface list member add interface=nas-bonding list=InterfaceListVlan10
/interface list member add interface=VLAN10 list=VLANS
/interface list member add interface=VLAN11 list=VLANS
/interface list member add interface=VLAN12 list=VLANS
/interface list member add interface=ether2-oob list=InterfaceListVlan10
/interface list member add interface=ether2-oob list=BASE
/interface wireguard peers add allowed-address=10.0.0.2/32 interface=wg-sonoshq public-key="MaHvrXErTnQ4m7gfoRR0Kbz8zKnIM9C8LlnFu1WGXRg="
/interface wireguard peers add allowed-address=10.0.0.3/32 interface=wg-sonoshq public-key="MNjdDqRmK4C0zvfqqrYoeTq1Fy7qpbqOBf23gJiDrmU="
/interface wireguard peers add allowed-address=10.0.0.4/32 interface=wg-sonoshq public-key="4GLnFZOT8xVoUy1BrxFnRaklMfNSmuBrzjq+YvH0qV0="
/interface wireguard peers add allowed-address=10.0.0.5/32 interface=wg-sonoshq public-key="TS3Vob4YZqaQSzxpYqlp+KPh3OzCg1JUMpSkxYbr9U0="
/interface wireguard peers add allowed-address=10.0.0.6/32 interface=wg-sonoshq public-key="VPPuNYcG/4lKJdCuv7vuzHXI2x4hC3W3yq3Bd4nJGy8="
/interface wireguard peers add allowed-address=10.0.0.7/32 interface=wg-sonoshq public-key="FfdbBi4N8wtIF+bSkeFVGZd1or6agClt9lsq1dcvalQ="
/interface wireguard peers add allowed-address=10.0.0.8/32 interface=wg-sonoshq public-key="kEs8ACRR5tOVdN2f+VVoK4nLaSGxNXPtiO/zkgRK+XI="
/interface wireguard peers add allowed-address=10.0.0.9/32 interface=wg-sonoshq public-key="5tduxOb3OoVkbrak4zf9Tq3GX//thS84xj3ZoaPUblU="
/interface wireguard peers add allowed-address=10.0.0.10/32 interface=wg-sonoshq public-key="sqszAiDa2nl+DhrUX0gmrHygCiQ6ugGS3fOGyCT74FE="
/interface wireguard peers add allowed-address=10.0.0.11/32 interface=wg-sonoshq public-key="Zmn0RE2rCU7AI9eqfzkiKdgQcR0yN0A0oen5VxHAIz4="
/ip address add address=192.168.1.1/24 interface=VLAN10 network=192.168.1.0
/ip address add address=192.168.11.1/24 interface=VLAN11 network=192.168.11.0
/ip address add address=192.168.12.1/24 interface=VLAN12 network=192.168.12.0
/ip address add address=10.0.0.1/24 interface=wg-sonoshq network=10.0.0.0
/ip address add address=192.168.99.1/24 interface=ether2-oob network=192.168.99.0
/ip cloud set ddns-enabled=yes ddns-update-interval=1d update-time=no
/ip dhcp-client add disabled=yes interface=ether1-wan
/ip dhcp-server network add address=192.168.1.0/24 dns-server=192.168.1.1 gateway=192.168.1.1
/ip dhcp-server network add address=192.168.11.0/24 dns-server=192.168.11.1 gateway=192.168.11.1
/ip dhcp-server network add address=192.168.12.0/24 dns-server=192.168.12.1 gateway=192.168.12.1
/ip dns set allow-remote-requests=yes
/ip firewall filter add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
/ip firewall filter add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
/ip firewall filter add action=accept chain=input dst-port=53,13231,514,123 protocol=udp
/ip firewall filter add action=accept chain=input dst-port=80,443,8291,123 protocol=tcp
/ip firewall filter add action=accept chain=input in-interface-list=VLANS
/ip firewall filter add action=drop chain=input comment="drop all else" log-prefix=drop-input
/ip firewall filter add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-mark=no-mark connection-state=established,related hw-offload=yes
/ip firewall filter add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
/ip firewall filter add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid log-prefix=drop-invalid-forward
/ip firewall filter add action=jump chain=forward comment="allow internet traffic" in-interface-list=VLANS jump-target=ChainForwardAll out-interface-list=WAN
/ip firewall filter add action=jump chain=forward comment="allow internet traffic" in-interface-list=VLANS jump-target=ChainForwardAll out-interface-list=VLANS
/ip firewall filter add action=jump chain=forward in-interface=wg-sonoshq jump-target=ChainForwardAll out-interface-list=VLANS
/ip firewall filter add action=drop chain=forward comment="drop all else" log=yes log-prefix=drop-forward
/ip firewall filter add action=accept chain=ChainForwardAll
/ip firewall nat add action=masquerade chain=srcnat out-interface-list=WAN
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set ssh disabled=yes
/ip service set www-ssl disabled=no
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/system clock set time-zone-name=Asia/Bangkok
/system identity set name=SonosLibraHQ
/system logging add action=syslog topics=firewall
/system logging add action=syslog topics=error
/system note set show-at-login=no
/system ntp client set enabled=yes
/system ntp client servers add address=time.cloudflare.com
/system scheduler add interval=5m name=cf-updater on-event="/system script run cf_update" policy=ftp,read,write,test start-date=2023-07-09 start-time=00:49:03
/system script add dont-require-permissions=no name=cf_update owner=admin policy=ftp,read,write,test source="################# CloudFlare variables #################\r\
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
    \n#########################################################################\r\
    \n########################  DO NOT EDIT BELOW  ############################\r\
    \n#########################################################################\r\
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
    \n    :local currentIP [/ip address get [/ip address find interface=\$WANInterface ] address];\r\
    \n    :set WANip [:pick \$currentIP 0 [:find \$currentIP \"/\"]];\r\
    \n};\r\
    \n\r\
    \n:if ([/file find name=ddns.tmp.txt] = \"\") do={\r\
    \n    :log error \"No previous ip address file found, createing...\"\r\
    \n    :set previousIP \$WANip;\r\
    \n    :execute script=\":put \$WANip\" file=\"ddns.tmp\";\r\
    \n    :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n    /tool fetch http-method=put mode=https output=none url=\"\$CFurl\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\r\
    \n    :error message=\"No previous ip address file found.\"\r\
    \n} else={\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={ \r\
    \n    :global content [/file get [/file find name=\"ddns.tmp.txt\"] contents] ;\r\
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
    \n                :set previousIP [:pick \$previousIP 0 [:find \$previousIP \"\\r\"]];\r\
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
    \n :log info (\"CF: Command = \\\"/tool fetch http-method=put mode=https url=\\\"\$CFurl\\\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" output=none http-data=\\\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\\\"\")\r\
    \n};\r\
    \n  \r\
    \n######## Compare and update CF if necessary #####\r\
    \n:if (\$previousIP != \$WANip) do={\r\
    \n :log info (\"CF: Updating CF, setting \$CFDomain = \$WANip\")\r\
    \n /tool fetch http-method=put mode=https url=\"\$CFurl\" http-header-field=\"Authorization:Bearer \$CFtkn,content-type:application/json\" output=none http-data=\"{\\\"type\\\":\\\"\$CFrecordType\\\",\\\"name\\\":\\\"\$CFdomain\\\",\\\"ttl\\\":\$CFrecordTTL,\\\"content\\\":\\\"\$WANip\\\"}\"\r\
    \n /ip dns cache flush\r\
    \n    :if ( [/file get [/file find name=ddns.tmp.txt] size] > 0 ) do={\r\
    \n        /file remove ddns.tmp.txt\r\
    \n        :execute script=\":put \$WANip\" file=\"ddns.tmp\"\r\
    \n    }\r\
    \n} else={\r\
    \n# :log info \"CF: No Update Needed!\"\r\
    \n}"
/system script add dont-require-permissions=no name=updatearp owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=":local wanInterfaceName \"Trueonline\";\r\
    \n# Remove ARP entries that do not have static DHCP leases or are disabled\r\
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
    \n:if (\$arpId=\"\" && ![/ip dhcp-server lease get \$leaseId disabled]) do={\r\
    \n:local ip [/ip dhcp-server lease get \$leaseId address];\r\
    \n:local comment  [/ip dhcp-server lease get \$leaseId comment];\r\
    \n#interface should not be hard coded but couldn't figure out what to do\r\
    \n:local interface lan_wlan_bridge;\r\
    \n/ip arp add address= \$ip mac-address= \$mac comment= \$comment interface= \$interface;\r\
    \n:log info (\"Adding new ARP entry\");\r\
    \n}\r\
    \n}"
/tool mac-server mac-winbox set allowed-interface-list=BASE
