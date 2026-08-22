# สคริปต์ Auto Login สำหรับระบบ Chato (ห้อง 132)
:local TargetPing "8.8.8.8";
:local LoginData "username=TCP2380&password=17573";


:if ([:ping $TargetPing count=3] = 0) do={
    :log warning "Internet is down (Web Auth required). Attempting to login to Chato...";
    
    :do {
        
        /tool fetch http-method=post url=$LoginURL http-data=$LoginData keep-result=no;
        :log info "Chato Auto-login packet sent.";
    } on-error={
        :log error "Cannot connect to Chato server (192.168.120.1)";
    }
}


# Improved Auto Web Login Script
:local TargetPing "8.8.8.8"
:local GatewayIP "192.168.120.1"
:local LoginURL "http://192.168.120.1/login"
:local Username "TCP2380"
:local Password "17573"

:local LoginData ("username=" . $Username . "&password=" . $Password)


:if ([:ping $TargetPing count=5] <= 1) do={
    

    :if ([:ping $GatewayIP count=2] > 0) do={
        :log warning "Internet down. Gateway reachable. Attempting login..."
        :do {
            /tool fetch http-method=post \
                url=$LoginURL \
                http-data=$LoginData \
                http-header-field="Content-Type: application/x-www-form-urlencoded" \
                keep-result=no \
                timeout=5s
            :log info "Auto-login request sent."
        } on-error={
            :log error "Portal login failed."
        }
    } else={
        :log error "Gateway unreachable. Skipping login (Wi-Fi disconnected)."
    }
}
