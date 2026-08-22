# สคริปต์ Auto Login สำหรับระบบ Chato (ห้อง 132)
:local TargetPing "8.8.8.8";
:local LoginURL "http://192.168.120.1/login";
# ใส่รหัสผ่านของคุนแทนที่ข้อวามด้านล่าฉนี้
:local LoginData "username=TCP2380&password=17573";

# ตรวจสอบว่าอินเทอร์เน็ตใช้งานได้ปกติไหม
:if ([:ping $TargetPing count=3] = 0) do={
    :log warning "Internet is down (Web Auth required). Attempting to login to Chato...";
    
    :do {
        # ยิงคำสั่ง POST ล็อกอินเข้า Hotspot
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

# 1. ตรวจสอบว่าอินเทอร์เน็ตใช้งานได้หรือไม่ (ปิง 5 ครั้ง ถ้ารอดน้อยกว่า 2 ให้ทำงาน)
:if ([:ping $TargetPing count=5] <= 1) do={
    
    # 2. เช็กว่าเชื่อมต่อ Gateway ได้ไหม ก่อนส่งข้อมูล (ป้องกัน Idle timeout)
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
