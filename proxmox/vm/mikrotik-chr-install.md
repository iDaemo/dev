1.Create a VM in the Proxmox VE web interface. Make a note of the VM ID

2.ssh to host

3.get mikrotik chr
```
wget -q --show-progress https://download.mikrotik.com/routeros/7.15.2/chr-7.15.2.img.zip
```

4.unzip
```
gunzip -f -S .zip chr-7.15.2.img.zip
```

5.dd partition xxx is vmid
```
dd if=chr-7.15.2.img of=/dev/zvol/rpool/data/vm-xxx-disk-0
```

6.start vm and finish 