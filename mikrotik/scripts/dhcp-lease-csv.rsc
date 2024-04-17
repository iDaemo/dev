:execute script="/ip dhcp-server lease\r\
    \n:foreach i in=[find where server=\"fttx-public-dhcp\"] do={\r\
    \n    :local add [get \$i address]\r\
    \n    :local mac [get \$i mac-address]\r\
    \n    :local cid [get \$i client-id]\r\
    \n    :local svr [get \$i server]\r\
    \n    :local line \"\\\"\$add\\\",\\\"\$mac\\\",\\\"\$cid\\\",\\\"\$svr\\\"\"\r\
    \n    :put \$line\r\
    \n}\r\
    \n" file="dhcp-leases.txt"