### server-deploy

cyberpanel openlitespeed wordpress

## Initiail setup for cloud server 

curl -LJO https://raw.githubusercontent.com/iDaemo/server-deploy/master/cloudini.sh && bash cloudini.sh

curl -LJO https://raw.githubusercontent.com/iDaemo/server-deploy/master/cyberpanel.sh && sh cyberpanel.sh

### to upgrade cyberpanel while in root

sh <(curl <https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh> || wget -O - <https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh>)

sh <(curl <https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh> || wget -O - <https://raw.githubusercontent.com/usmannasir/cyberpanel/stable/preUpgrade.sh>)



Post install
https://www.linuxcapable.com/how-to-configure-unattended-upgrades-on-ubuntu-linux/
https://linuxopsys.com/topics/ubuntu-automatic-updates


sudo su - -c "sh <(curl -LJO https://raw.githubusercontent.com/iDaemo/server-deploy/master/cloudini.sh)>
