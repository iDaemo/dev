# Sonos HQ Finalized Configuration (MikroTik CCR2004-16G-2S+)
# Cleaned and updated on 2025-03-29

/system identity
set name=SonosLibraHQ

/interface bridge
add name=BRI-TEST vlan-filtering=yes igmp-snooping=yes protocol-mode=none port-cost-mode=short

/interface vlan
add interface=BRI-TEST name=VLAN10-LOCAL vlan-id=10
add interface=BRI-TEST name=VLAN11-WIFI vlan-id=11
add interface=BRI-TEST name=VLAN12-DANTE vlan-id=12
add interface=BRI-TEST name=VLAN13-AURABUILDING vlan-id=13
add interface=BRI-TEST name=VLAN20-LIGHT vlan-id=20

/interface bridge port
add bridge=BRI-TEST interface=ether3 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether4 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether5 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether6 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether7 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether8 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether9 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether10 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether11-dvs pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether12 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether13-Aura-building pvid=13 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether14 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=BRI-TEST interface=ether15-trunk frame-types=admit-only-vlan-tagged trusted=yes
add bridge=BRI-TEST interface=ether16 pvid=10 frame-types=admit-only-untagged-and-priority-tagged

/interface list
add name=WAN
add name=VLANS
add name=Manage
add name=TRUSTVLAN

/ip dns
set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1

/ip firewall filter
# --- INPUT CHAIN ---
add action=accept chain=input comment="Established, Related, Untracked" connection-state=established,related,untracked
add action=accept chain=input comment="Accept from MGMT Interface" in-interface-list=Manage log=yes log-prefix=admin:
add action=drop chain=input comment="Drop Invalid" connection-state=invalid log=yes log-prefix=drop-invalid:
add action=accept chain=input comment="Allow ICMP (Ping)" protocol=icmp limit=10,5
add action=accept chain=input comment="Allow DNS (UDP)" protocol=udp dst-port=53 in-interface-list=VLANS log-prefix=req-dns-udp:
add action=accept chain=input comment="Allow DNS (TCP)" protocol=tcp dst-port=53 in-interface-list=VLANS log-prefix=req-dns-tcp:
add action=accept chain=input comment="Allow WireGuard" protocol=udp dst-port=13231 log-prefix=req-wireguard:
add action=accept chain=input comment="Allow traffic from WireGuard interface" in-interface=wg-sonoshq
add action=accept chain=input comment="Allow DriveSync TCP" protocol=tcp dst-port=6690 in-interface-list=VLANS log-prefix=req-drivesync:
add action=accept chain=input comment="VLAN-Originated Services" in-interface-list=VLANS log-prefix=req-vlan:
add action=drop chain=input comment="Drop All Else" log-prefix=drop-input:

# --- FORWARD CHAIN ---
add action=fasttrack-connection chain=forward comment="FastTrack" connection-state=established,related hw-offload=yes
add action=accept chain=forward comment="Allow Established/Related" connection-state=established,related,untracked
add action=drop chain=forward comment="Drop Invalid" connection-state=invalid log=yes log-prefix=drop-invalid-forward
add action=accept chain=forward comment="Port Forwarding" connection-nat-state=dstnat log-prefix=fw-portfwd:
add action=accept chain=forward comment="VLAN → WAN" in-interface-list=VLANS out-interface-list=WAN
add action=accept chain=forward comment="WireGuard → VLAN" in-interface=wg-sonoshq out-interface-list=VLANS
add action=accept chain=forward comment="VLAN → WireGuard" in-interface=VLANS out-interface-list=wg-sonoshq
add action=drop chain=forward comment="Drop All Else" log-prefix=drop-forward:

# --- CHAIN: ChainForwardAll ---
add action=accept chain=ChainForwardAll comment="Base Allow"

# --- SCHEDULED BACKUP ---
/system scheduler
add name=auto-backup interval=1d start-time=03:00:00 on-event="/system backup save name=daily-backup"