First of all, these rights should not be there. "ispapps"
Here's my first way of doing it with my big arms in gruff mode.
Change
Code:
$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';
to
Code:
$cfg['TempDir'] = '/tmp';
Secondly, in a more consensual way, we will have to change the rights and put them back in their place!

Code:
cd /var/lib/phpmyadmin/
chown www-data:www-data tmp
rm -r tmp/twig
Now I need some chocolate milk, I love chocolate.
Please send me some in PM!
