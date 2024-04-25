/interface macvlan add interface=VLAN10-LOCAL name=macvlan10
/interface macvlan add interface=VLAN11-WIFI name=macvlan11

/interface bridge add name=bridge-mdns protocol-mode=none
/interface bridge port add bridge=bridge-mdns interface=macvlan10
/interface bridge port add bridge=bridge-mdns interface=macvlan11

/interface bridge filter add action=accept chain=forward comment="Allow mDNS only" dst-address=224.0.0.251/32 dst-mac-address=06:7B:D3:54:50:A5/FF:FF:FF:FF:FF:FF dst-port=5353 in-bridge=bridge-mdns ip-protocol=udp mac-protocol=ip out-bridge=bridge-mdns src-port=5353
/interface bridge filter add action=drop chain=forward in-bridge=bridge-mdns out-bridge=bridge-mdns comment="Drop all other L2 traffic"

/interface bridge nat add action=src-nat chain=srcnat dst-mac-address=06:7B:D3:54:50:A5/FF:FF:FF:FF:FF:FF to-src-mac-address=18:FD:74:82:56:71 comment="SNAT to Primary VLAN bridge"

#Sonos HQ mac= 18:FD:74:82:56:71