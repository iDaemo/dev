#!/bin/bash
sudo timedatectl set-timezone Asia/Bangkok
sudo apt update -y && sudo apt upgrade -y
apt install cron
apt install iputils-ping 
apt install cron
#sudo useradd idaemon
echo "$USER:thaigaming" | sudo chpasswd
#usermod -aG sudo idaemon
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart
sudo apt autoremove -y
echo " DONE "
#sh <(curl https://cyberpanel.net/install.sh -v ols -p thaigaming -a -m || wget -O - https://cyberpanel.net/install.sh -v ols -p thaigaming -a -m)
sh <(curl https://cyberpanel.net/install.sh || wget -O - https://cyberpanel.net/install.sh) -v ols -p thaigaming -a -m
sudo cat /usr/local/lsws/adminpasswd 
echo "PLEASE RESTART SERVER "
#sudo shutdown -r now

#UPGRADE MARIADB TO3EjMcDgo4RHj
cat /etc/cyberpanel/mysqlPassword
mysql -u root -p
### run command in mysql cli
SET GLOBAL innodb_fast_shutdown = 1;
XA RECOVER;
exit;
## stop mysql
systemctl stop mariadb
apt remove "*mariadb*" "galera*" -y
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.11"
apt update -y
apt install mariadb-server libmariadb-dev -y
apt update -y && apt upgrade -y
systemctl enable mariadb
systemctl start mariadb
mysql_upgrade -u root -p
sudo apt autoremove -y && sudo apt autoclean -y
sudo apt update -y && apt upgrade -y 


 think have finally properly upgraded to MariaDB v10.6 on Ubuntu 20.04. Here is what I did. The process should be similar for other OSs, but please be careful and post any variations that you discover below.

Note: there’s a lot of extra steps included here just to be extra thorough. For instance, it isn’t absolutely necessary to check the packages installed/uninstalled, check status of mariadb etc…

1. Review Official MariaDB Instructions
Upgrading Between Major MariaDB Versions - MariaDB Knowledge Base 20
Find the Community Server instructions for your desired MariaDB version and OS Upgrades — MariaDB Enterprise Documentation 3
For 10.6 on Ubuntu 20.04, use this one: Upgrade to MariaDB Community Server 10.6 on Ubuntu 20.04 LTS — MariaDB Enterprise Documentation 19
2. Backup
I didn’t take any backups, but the method written above by Usman or ones listed in the articles should work. Instead, I just made a snapshot of my entire server, which I DID end up needing once because something broke.

3. Config mariadb for proper shutdown
run cat /etc/cyberpanel/mysqlPassword to get your mariadb root password
run mysql -u root -p
enter password
Run these commands within mariadb cli

SET GLOBAL innodb_fast_shutdown = 1;
XA RECOVER;
exit;
4. Remove MariaDB
run systemctl stop mariadb
confirm it is stopped with systemctl status mariadb. The output is convoluted, but look for following lines
Active: inactive (dead) since Wed 2022-03-16 14:13:25 CST; 1s ago
Status: "MariaDB server is down"
run apt list --installed | grep -i -E "mariadb|galera" to confirm which packages will be removed
run apt remove "*mariadb*" "galera*" -y
run apt list --installed | grep -i -E "mariadb|galera" again to confirm all those packages were removed
5. Install New Version of MariaDB
run the following command, changing 10.6 for whichever version you would like to install. 10.11 is the latest LTS version 3.
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-10.6"
run apt update
run apt install mariadb-server libmariadb-dev -y
when prompted with this, enter N
Configuration file '/etc/mysql/mariadb.conf.d/50-server.cnf'
 ==> Modified (by you or by a script) since installation.
 ==> Package distributor has shipped an updated version.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** 50-server.cnf (Y/I/N/O/D/Z) [default=N] ?
run apt update && apt upgrade -y to update all packages again (there’s a mysql-common package that got updated from 5.8 to 10.6.7 for me)

run apt list --installed | grep -i -E "mariadb|galera" to confirm which packages were installed
Note: don’t worry that libmariadbclient-dev is not installed as it was before. It appears to have been deprecated/replaced by libmariadb-dev, which was installed.

run systemctl enable mariadb

run systemctl start mariadb

run systemctl status mariadb to confirm version and active

run mysql_upgrade -u root -p.

This is CRITICAL, and not mentioned in the method above. Here are detailed investigations into what mysql_upgrade does

Upgrading to a newer major version of MariaDB - Valerii Kravchuk - FOSDEM 2021 5
What mysql_upgrade really does in MariaDB, Part I 4
enter password from previously
Note: it might be worth upgrading CyberPanel after all of this. It is harmless, might pre-emptively fix any issues, and might even give you some minor updates that have not yet been included in an official release. Run

###
sudo apt autoremove -y && sudo autoclean -y
sudo apt update -y && apt upgrade -y 

### upgrade phpmyadmin
sh <(curl https://raw.githubusercontent.com/iDaemo/server-deploy/master/update-phpmyadmin.sh || wget -O - https://raw.githubusercontent.com/iDaemo/server-deploy/master/update-phpmyadmin.sh)

#upgrade the cyberpanel system again
sh <(curl https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh || wget -O - https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh)




