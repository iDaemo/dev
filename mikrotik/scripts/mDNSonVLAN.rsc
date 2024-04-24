/interface bridge filter
add action=accept chain=forward comment="Allow mDNS VLAN10" \
    dst-address=224.0.0.251/32 dst-mac-address=\
    01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF dst-port=5353 in-bridge=BridgemDNS \
    in-interface=VLAN1 ip-protocol=udp mac-protocol=ip \
    out-bridge=BridgemDNS src-mac-address=34:FD:6A:03:A1:8B/FF:FF:FF:FF:FF:FF \
    src-port=5353

add action=drop chain=forward comment="Drop all other mDNS from VLAN10" \
    dst-address=224.0.0.251/32 dst-mac-address=\
    01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF dst-port=5353 in-bridge=BridgemDNS \
    in-interface=VLAN1 ip-protocol=udp mac-protocol=ip \
    out-bridge=BridgemDNS src-port=5353
    
add action=accept chain=forward comment="Allow mDNS" dst-address=\
    224.0.0.251/32 dst-mac-address=01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF \
    dst-port=5353 in-bridge=BridgemDNS ip-protocol=udp \
    mac-protocol=ip out-bridge=BridgemDNS src-port=5353

add action=drop chain=forward in-bridge=BridgemDNS \
    out-bridge=BridgemDNS
    
/interface bridge nat
add action=src-nat chain=srcnat dst-mac-address=\
    01:00:5E:00:00:FB/FF:FF:FF:FF:FF:FF to-src-mac-address=CC:2D:E0:14:64:AD