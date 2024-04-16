# 2023-11-26 08:38:44 by RouterOS 7.12
# software id = NRY1-5C8G
#
# model = RB760iGS
# serial number = **********
/interface bridge
add comment=my.LAN.block name="Lan Bridge"
add comment="my.LAN.block-2 - Ether3" name=bridge1
/interface ethernet
set [ find default-name=ether1 ] comment="ATT Fiber Modem"
set [ find default-name=ether2 ] comment="Nokia AC3000 WAP"
set [ find default-name=ether3 ] comment="Test Port"
set [ find default-name=ether4 ] comment=\
    "SyncServer Eth1 - Load Balancing - Server Side"
set [ find default-name=ether5 ] comment=\
    "SyncServer Eth2 - Load Balancing - Server Side" poe-out=off
/interface wireguard
add comment="Personal VPN" listen-port=port mtu=1420 name=wireguard1
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip hotspot profile
set [ find default=yes ] html-directory=hotspot
/ip pool
add name=LAN ranges=my.LAN.block
add name=dhcp_pool4 ranges=my.LAN.block-2
/ip dhcp-server
add address-pool=LAN interface="Lan Bridge" lease-time=10m name=dhcp1
add address-pool=dhcp_pool4 interface=bridge1 lease-time=1m name=dhcp2
/queue simple
add comment="AppleTV - Home Theatre" disabled=yes limit-at=50M/50M max-limit=\
    1G/1G name="AppleTV - Home Theatre" queue=\
    pcq-upload-default/pcq-download-default target=AppleTV.IP/32 \
    total-queue=synchronous-default
add comment=SyncServer disabled=yes limit-at=50M/50M max-limit=1G/1G name=\
    SyncServer queue=pcq-upload-default/pcq-download-default target=\
    Server.IP/32 total-queue=synchronous-default
/certificate settings
set crl-download=yes crl-use=yes
/interface bridge port
add bridge="Lan Bridge" interface=ether2
add bridge="Lan Bridge" interface=ether4
add bridge="Lan Bridge" interface=ether5
add bridge=bridge1 interface=ether3
/ipv6 settings
set disable-ipv6=yes
/interface list member
add interface=ether1 list=WAN
add interface="Lan Bridge" list=LAN
add interface=wireguard1 list=LAN
add interface=bridge1 list=LAN
/interface wireguard peers
add allowed-address=0.0.0.0/0 client-address=my.LAN.block-WG client-dns=\
    1.1.1.3 client-endpoint=123.456.789.123 client-listen-port=port \
    comment="Personal VPN" endpoint-address=WG.IP endpoint-port=port \
    interface=wireguard1 preshared-key=\
    "*******************************************" private-key=\
    "*******************************************" public-key=\
    "*******************************************"
/ip address
add address=my.LAN.block/24 interface="Lan Bridge" network=my.LAN.block
add address=my.LAN.block-WG/24 interface=wireguard1 network=my.LAN.block-WG
add address=my.LAN.block-2/24 interface=bridge1 network=my.LAN.block-2
/ip dhcp-client
add interface=ether1 use-peer-dns=no
/ip dhcp-server network
add address=my.LAN.block/24 dns-server=my.LAN.block.router gateway=my.LAN.block
add address=my.LAN.block-2/24 dns-server=1.1.1.1 gateway=my.LAN.block-2
/ip dns
set allow-remote-requests=yes doh-max-concurrent-queries=100 \
    doh-max-server-connections=20 doh-timeout=6s servers=1.1.1.1,1.0.0.1 \
    use-doh-server=https://1.1.1.1/dns-query verify-doh-cert=yes
/ip firewall address-list
add address=Server.IP comment=SyncServer list=SyncServer
add address=my.LAN.block/24 comment="Private LAN" list=LAN
add address=123.456.789.123 comment="ATT Fiber" list=WAN
add address=0.0.0.0/8 comment="Rule: RFC6890" list=no_forward_ipv4
add address=169.254.0.0/16 comment="Rule: RFC6890" list=no_forward_ipv4
add address=224.0.0.0/4 comment="Rule: multicast" list=no_forward_ipv4
add address=255.255.255.255 comment="Rule: RFC6890" list=no_forward_ipv4
add address=127.0.0.0/8 comment="Rule: RFC6890" list=bad_ipv4
add address=192.0.0.0/24 comment="Rule: RFC6890" list=bad_ipv4
add address=192.0.2.0/24 comment="Rule: RFC6890 documentation" list=bad_ipv4
add address=198.51.100.0/24 comment="Rule: RFC6890 documentation" list=\
    bad_ipv4
add address=203.0.113.0/24 comment="Rule: RFC6890 documentation" list=\
    bad_ipv4
add address=240.0.0.0/4 comment="Rule: RFC6890 reserved" list=bad_ipv4
add address=0.0.0.0/8 comment="Rule: RFC6890" list=not_global_ipv4
add address=10.0.0.0/8 comment="Rule: RFC6890" list=not_global_ipv4
add address=100.64.0.0/10 comment="Rule: RFC6890" list=not_global_ipv4
add address=169.254.0.0/16 comment="Rule: RFC6890" list=not_global_ipv4
add address=172.16.0.0/12 comment="Rule: RFC6890" list=not_global_ipv4
add address=192.0.0.0/29 comment="Rule: RFC6890" list=not_global_ipv4
add address=192.168.0.0/16 comment="Rule: RFC6890" list=not_global_ipv4
add address=198.18.0.0/15 comment="Rule: RFC6890 benchmark" list=\
    not_global_ipv4
add address=255.255.255.255 comment="Rule: RFC6890" list=not_global_ipv4
add address=224.0.0.0/4 comment="Rule: multicast" list=bad_src_ipv4
add address=255.255.255.255 comment="Rule: RFC6890" list=bad_src_ipv4
add address=0.0.0.0/8 comment="Rule: RFC6890" list=bad_dst_ipv4
add address=224.0.0.0/4 comment="Rule: RFC6890" list=bad_dst_ipv4
add address=my.LAN.block-WG/24 comment="Wireguard - Personal VPN" list=LAN
add address=my.LAN.block-2/24 list=LAN
/ip firewall filter
add action=accept chain=input comment=\
    "Rule: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=accept chain=input comment="Rule: accept ICMP after RAW" protocol=\
    icmp
add action=accept chain=input comment="Rule: allow WireGuard" dst-port=port \
    protocol=udp
add action=accept chain=input comment="Rule: allow WireGuard" dst-port=port \
    protocol=udp
add action=drop chain=input comment="Rule: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=accept chain=forward comment=\
    "Rule: accept all that matches IPSec policy" ipsec-policy=in,ipsec
add action=fasttrack-connection chain=forward comment="Rule: fasttrack" \
    connection-mark=no-mark connection-state=established,related hw-offload=\
    yes
add action=accept chain=forward comment=\
    "Rule: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="Rule: drop invalid" connection-state=\
    invalid
add action=accept chain=forward comment="Rule: internet" in-interface-list=\
    LAN out-interface-list=WAN
add action=accept chain=forward comment="Rule: port forwarding" \
    connection-nat-state=dstnat
add action=accept chain=forward comment="Rule: allow all LAN networks" \
    connection-state="" dst-address-list=LAN src-address-list=LAN
add action=drop chain=forward comment="Rule: DROP ALL ELSE" log=yes
/ip firewall nat
add action=masquerade chain=srcnat comment="LAN Masquerade" \
    out-interface-list=WAN
add action=masquerade chain=srcnat comment="Hairpin NAT - LAN" \
    dst-address-list=LAN src-address-list=LAN
add action=dst-nat chain=dstnat comment="SyncServer NAT - HTTPS" \
    dst-address-type=local dst-port=port log=yes protocol=tcp to-addresses=\
    Server.IP to-ports=port
add action=dst-nat chain=dstnat comment="SyncServer NAT - VPN" \
    dst-address-type=local dst-port=port log=yes protocol=tcp to-addresses=\
    Server.IP to-ports=port
add action=src-nat chain=srcnat comment="Hide LAN IP's for WAN" \
    out-interface-list=WAN src-address-list=LAN to-addresses=123.456.789.123
add action=accept chain=srcnat comment=\
    "Rule: accept all that matches IPSec policy" disabled=yes ipsec-policy=\
    out,ipsec
/ip firewall raw
add action=accept chain=prerouting comment=\
    "Rule: enable for transparent firewall" disabled=yes
add action=accept chain=prerouting comment="Rule: accept DHCP discover" \
    dst-address=255.255.255.255 dst-port=67 in-interface-list=LAN protocol=\
    udp src-address=0.0.0.0 src-port=68
add action=drop chain=prerouting comment="Rule: drop bogon IP's" \
    src-address-list=bad_ipv4
add action=drop chain=prerouting comment="Rule: drop bogon IP's" \
    dst-address-list=bad_ipv4
add action=drop chain=prerouting comment="Rule: drop bogon IP's" \
    src-address-list=bad_src_ipv4
add action=drop chain=prerouting comment="Rule: drop bogon IP's" \
    dst-address-list=bad_dst_ipv4
add action=drop chain=prerouting comment="Rule: drop non global from WAN" \
    in-interface-list=WAN src-address-list=not_global_ipv4
add action=drop chain=prerouting comment=\
    "Rule: drop forward to local lan from WAN" dst-address-list=LAN \
    in-interface-list=WAN
add action=drop chain=prerouting comment=\
    "Rule: drop local if not from default IP range" in-interface-list=LAN \
    src-address-list=!LAN
add action=drop chain=prerouting comment="Rule: drop bad UDP" port=0 \
    protocol=udp
add action=jump chain=prerouting comment="Rule: jump to ICMP chain" \
    jump-target=icmp4 protocol=icmp
add action=jump chain=prerouting comment="Rule: jump to TCP chain" \
    jump-target=bad_tcp protocol=tcp
add action=accept chain=prerouting comment=\
    "Rule: accept everything else from LAN" in-interface-list=LAN
add action=accept chain=prerouting comment=\
    "Rule: accept everything else from WAN" in-interface-list=WAN
add action=drop chain=prerouting comment="Rule: drop the rest"
add action=drop chain=bad_tcp comment="Rule: TCP flag filter" protocol=tcp \
    tcp-flags=!fin,!syn,!rst,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,syn
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,!ack
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=fin,urg
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=syn,rst
add action=drop chain=bad_tcp comment=defconf protocol=tcp tcp-flags=rst,urg
add action=drop chain=bad_tcp comment="Rule: TCP port 0 drop" port=0 \
    protocol=tcp
add action=accept chain=icmp4 comment="Rule: echo reply" icmp-options=0:0 \
    limit=5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="Rule: net unreachable" icmp-options=\
    3:0 protocol=icmp
add action=accept chain=icmp4 comment="Rule: host unreachable" icmp-options=\
    3:1 protocol=icmp
add action=accept chain=icmp4 comment="Rule: protocol unreachable" \
    icmp-options=3:2 protocol=icmp
add action=accept chain=icmp4 comment="Rule: port unreachable" icmp-options=\
    3:3 protocol=icmp
add action=accept chain=icmp4 comment="Rule: fragmentation needed" \
    icmp-options=3:4 protocol=icmp
add action=accept chain=icmp4 comment="Rule: echo" icmp-options=8:0 limit=\
    5,10:packet protocol=icmp
add action=accept chain=icmp4 comment="Rule: time exceeded " icmp-options=\
    11:0-255 protocol=icmp
add action=drop chain=icmp4 comment="Rule: drop other icmp" protocol=icmp
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set ssh disabled=yes
set api disabled=yes
set winbox address=my.LAN.block.personal/24 port=1234
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/system clock
set time-zone-name=America/New_York
/system logging
add disabled=yes topics=dns
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp server
set broadcast=yes broadcast-addresses=my.LAN.block enabled=yes multicast=\
    yes use-local-clock=yes
/system ntp client servers
add address=time.cloudflare.com