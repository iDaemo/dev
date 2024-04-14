##edit wp_config.php

define('DISABLE_WP_CRON', true);

##enable uniq key for cache
define('WP_CACHE_KEY_SALT', 'oddperience.com');

##edit cronjob

*/5 * * * * wget -q -O - 'https://websiteedit.com/wp-cron.php?doing_wp_cron' >/dev/null 2>&1

#missing redis


##missing imagick
apt install php81rc-pecl-imagick
apt install lsphp81-imagick

##enable JIT for faster php
nano /usr/local/lsws/lsphp81/etc/php/8.1/litespeed/php.ini

opcache.enable=1
; Determines if Zend OPCache is enabled for the CLI version of PHP
opcache.enable_cli=1
opcache.jit_buffer_size=256M
opcache.jit=1235

sudo apt install lsphp81-opcache

## restart server
service lsws restart
##checkiing if it working
/usr/local/lsws/lsphp81/bin/php -i | grep -i JIT


#disable php fuction
getmyuid,passthru,leak,listen,diskfreespace,tmpfile,link,shell_exec,dl,exec,system,highlight_file,source,show_source,fpassthru,virtual,posix_ctermid,posix_getcwd,posix_getegid,posix_geteuid,posix_getgid,posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid,posix,_getppid,posix_getpwuid,posix_getrlimit,posix_getsid,posix_getuid,posix_isatty,posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid,posix_setpgid,posix_setsid,posix_setuid,posix_times,posix_ttyname,posix_uname,proc_open,proc_close,proc_nice,proc_terminate,escapeshellcmd,ini_alter,popen,pcntl_exec,socket_accept,socket_bind,socket_clear_error,socket_close,socket_connect,symlink,posix_geteuid,ini_alter,socket_listen,socket_create_listen,socket_read,socket_create_pair,stream_socket_server




6. Best LSCache Plugin Settings
The LSCache plugin is already installed, and you’re ready to customize it further. First, go to LSCache settings.

Enable Advanced Settings, and enabled the following settings.

[5 Optimize] CSS/JS minify – combine – http/2 PUSH = ON
[6 Tuning] Remove Query Strings, Remove WordPress Emoji
[CDN 8] : Load Jquery Remotely > Google / CDNJS
A wonderful article covering entire settings.
