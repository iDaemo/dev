#!/bin/bash
### upgrade everything
sudo apt update && sudo apt upgrade -y

## APT PROBLEM TRUST KEY
sudo cp /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
## APT UNLINK
sudo rm -rf /var/lib/apt/lists
sudo apt-get update


### messing with ssh
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
#sudo sed -i "/^[^#]*ClientAliveInterval[[:space:]]0/c\ClientAliveInterval 60" /etc/ssh/sshd_config
#echo 'ClientAliveInterval 60' | sudo tee -a /etc/ssh/sshd_config
sudo service sshd restart

### another options
#sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
#systemctl restart sshd
#service sshd restart

#TODO: replace bob with your desired username
useradd idaemon
echo "thaigaming" | passwd --stdin idaemon

### create swap file edit the size 1g=2g 2g=2g 4g=4g
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
cp /etc/fstab /etc/fstab_$(date +%Y%m%d%H%M%S)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf


timedatectl set-timezone Asia/Bangkok

### redis recommended
I set it up very easily.
1. Ensure Redis is up and running
2. Enable Redis via the WordPress plugin, only setting I had to change was password because I use requirepass
Additionally, I’d recommend these settings in redis.conf:
maxmemory 100mb
maxmemory-policy allkeys-lru
maxmemory-samples 10
appendonly yes

and disable snapshotting, comment out the lines beginning with “save” to do this, for example,
#save 900 1
#save 300 10
#save 60 10000

I’d also add vm.overcommit_memory = 1 to /etc/sysctl.conf.
Also disable transparent huge pages,echo never > /sys/kernel/mm/transparent_hugepage/enabled


### CYBERPANEL BACKUP AFTER SETUP GOOGLE
/usr/local/CyberCP/bin/python /usr/local/CyberCP/IncBackups/IncScheduler.py Weekly



### MEMCACHE
What you should know is that LiteSpeed ​​has its own Memcached server which is optimized

Before starting the installation, test using the telnet command if Memecached is installed and functional:

telnet 127.0.0.1 11211
If the return of the command is telnet: Unable to connect to remote host: Connection refused, it means that the Memcached server is not available.

Install dependencies:

sudo apt-get install git build-essential zlib1g-dev libexpat1-dev openssl libssl-dev libsasl2-dev libpcre3-dev -y
Download LiteSpeed ​​Memcached:

sudo wget https://github.com/litespeedtech/lsmcd/archive/master.zip
Unzip the archive:

sudo unzip master.zip
Go to the sources folder:

cd lsmcd-master
Prepare, compile and install LSMCD using the following commands:

sudo./fixtimestamp.sh
sudo./configure CFLAGS=" -O3" CXXFLAGS=" -O3"
sudo make
sudo make install
Start the service:

sudo systemctl start lsmcd
Activate automatic start:

sudo systemctl enable lsmcd
Check the service:

sudo systemctl status lsmcd.service
You can also re-test with telnet.


### redis setup
I set it up very easily.

Ensure Redis is up and running
Enable Redis via the WordPress plugin, only setting I had to change was password because I use requirepass
Additionally, I’d recommend these settings in redis.conf:

maxmemory 100mb
maxmemory-policy allkeys-lru
maxmemory-samples 10
appendonly yes

and disable snapshotting, comment out the lines beginning with “save” to do this, for example,

#save 900 1
#save 300 10
#save 60 10000

I’d also add vm.overcommit_memory = 1 to /etc/sysctl.conf.

Also disable transparent huge pages,
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' | sudo tee -a /etc/rc.local

### edit /etc/redis/redis.conf
# create a unix domain socket to listen on
unixsocket /run/redis/redis.sock
# set permissions for the socket
unixsocketperm 775
#requirepass passwordtouse
#bind 127.0.0.1
daemonize yes
stop-writes-on-bgsave-error no
rdbcompression yes
# maximum memory allowed for redis
maxmemory 50M
# how redis will evice old objects - least recently used
maxmemory-policy allkeys-lru


