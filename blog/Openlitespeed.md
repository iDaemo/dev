1) open google cloud create one of those f1 micro instance (there are so may video on this I like the chrititus one (but it was on install lamp stack, but it gave me a good overview and starting place, but I have to modify a lot of it)
2) Install using ubuntu LTS 18 minimal image (other images are too bloated and we have so little memory)
3) SSH in sudo apt update then sudo apt upgrade
4) This version of ubuntu doesn't come with nano or wget. So sudo apt install nano sudo apt install wget
5) Make a 1g swap file using below (I took this from online youtubber christitus, his video was for LAMP stack)

$ sudo fallocate -l 1G /swapfile
$ sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576
$ sudo chmod 600 /swapfile
$ sudo mkswap /swapfile
$ sudo swapon /swapfile
$ sudo nano /etc/fstab add the following line to swapfile swap swap defaults 0 0

6) restart your server make sure swab file is still active, it should
7) wget --no-check-certificate https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh
8) chmod +x ./ols1clk.sh
9) sudo ./ols1clk.sh -r -a -w (so I get to assign the password I want and install wordpress, my way in the original post to migrate everything directly install the incorrect php version so everything went to hell, also the tag --dbname --dbuser and such didn't create the database for me when I try)
10) let the ols1clk.sh run and finish

11) so now everything should work, however you have to go back to your google cloud and firewall session to open up 2 additional port (look up on how to do this, open 7080 (this is for the web admin interface) and 8088 (for the example page, with the PHP info test page), I did this for my home IP address only, so no one else can get in)

12) play around as you wish, if you don't have an existing wordpress site, you should be done, you can get to you ipaddress and start setting it up. http://IP address of your server to config the site https://IP address of your server to config the site:7080 for the admin panel of the server http://IP address of your server to config the site:8088 for the Example page.

13) As I have my own wordpress back up, Now I upload my back up directory of my wordpress file (I have a tar file) and my backup of my database.sql I upload this to the google cloud server my home folder

14) Create the sql database with the same name as your back up with the same password from your wordpress config file (I took this from online youtubber christitus, his video was for LAMP stack, but gave me a good basic)

$ mysql -u root
> CREATE DATABASE yourdatabasename;
> GRANT ALL ON yourdatabasename.* TO 'yourdatabaseusernamefromwordpressconfigfile' IDENTIFIED BY 'yourpasswordfromwordpressconfigfile';
> quit
$ mysql_secure_installation

15) run mysql -u [username from above] -p [my database name] < [my backup sql database].sql this will import my backup database to this new database, which have the same user name and password and name. So I don't have to mess with my wordpress config file.

16) go to /usr/local/lsws/wordpress/ there are tons of file in here, this is here because we install the oneclick script with the -w. I wipe out this entire directory content, and put my wordpress tar file here an untar it. This step required a bit of linux know how to move files and delete file.... There are too many little steps and variation here. But just get your wordpress directory here.

17) permission time. sudo chown -R nobody:nogroup /usr/local/lsws/wordpress/ this will change all the permission to the wordpress directory to the correct one

18) Now I think we should be done, your wordpress is now active. You have to access the OpenLiteSpeed admin page to activate the rewrite and .htaccess reading and restart the server.

19) IF anyone know how to fine tune the openlitespeed server for the f1micro instance please please let me know

20) you have to install the LS cache, https://openlitespeed.org/kb/how-to-setup-lscache-for-wordpress/ the server stuff is already set.

21) use cloudflare CDN, because this server is bitty. I followed this guide https://websiteedu.com/litespeed-cache-settings/

so guys. I thank you for all the help from the community. This is my contribution. I need additional help with settings of the server, please help
