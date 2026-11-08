#Requires -RunAsAdministrator
# ==============================================================================
# SonosLibra Infrastructure - Zero-Touch Site Mini PC Provisioning Script (v5.1)
# Edition: Hardened Headless 24/7 (100% Non-Expire OAuth + Full Policy Tuning)
#
# Changelog v5.1:
#   [Fix 1] หยุดสคริปต์และไม่ Restart หาก Tailscale ไม่ได้ IP (ป้องกันเครื่องหลุดรีโมทที่ไซต์)
#   [Fix 2] บังคับรันแบบ Administrator (#Requires + ตรวจซ้ำตอนรัน)
#   [Fix 3] ไฟล์บันทึกเป็น UTF-8 with BOM เพื่อให้ภาษาไทยแสดงถูกต้องบน PowerShell 5.1
#           (หากแก้ไขไฟล์นี้ ต้องเซฟกลับเป็น "UTF-8 with BOM" ทุกครั้ง)
#   [Fix 4] Firewall รับ RustDesk (21118) เฉพาะจาก Tailscale / เลิกบังคับ Network Profile เป็น Private
#   [Fix 5] ใช้คู่กับ Tailscale ACL ในไฟล์ tailscale-acl.hujson (ตั้งที่ Admin Console)
#   [Bat]   ใช้คู่กับ Install-SiteNode.bat (ไฟล์ต้องชื่อ Setup-SiteNode.ps1 และอยู่โฟลเดอร์เดียวกัน)
#           Exit code: 0 = สำเร็จ (เครื่องจะ Restart) / 1 = ล้มเหลว (ไม่ Restart)
#
# วิธีใช้: ดับเบิลคลิก Install-SiteNode.bat จาก Flash Drive > กด Yes ที่หน้าต่าง UAC
# ==============================================================================

# --- [Fix 2] ตรวจสิทธิ์ Administrator (กรณีถูกวางคำสั่งลง Console โดยตรง #Requires จะไม่ทำงาน) ---
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host ""
    Write-Host "[!] สคริปต์นี้ต้องรันด้วยสิทธิ์ Administrator" -ForegroundColor Red
    Write-Host "    กรุณาดับเบิลคลิก Install-SiteNode.bat แล้วกด Yes ที่หน้าต่าง UAC" -ForegroundColor Red
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้"
    exit 1
}

# --- [ส่วนตั้งค่าตัวแปรหลัก (ฝังรหัสถาวรเรียบร้อยแล้ว)] ---
$ScriptVersion     = '5.1'
$MasterPassword    = 'Sono$33338888'
$TailscaleClientId = 'kkFZkR5GWw11CNTRL'
$TailscaleKey      = 'tskey-client-kkFZkR5GWw11CNTRL-CRbJ7LWBXTUUc1dyByrwTUyqM8xBsBAK'
$GoogleWebhookUrl  = 'https://script.google.com/macros/s/AKfycbzKA3AAks42o6G8OtlLCgEnBE-gNqRVDspTGZQAvqpYhEpyaQjbP1U5s8q2qKAlXb6xQg/exec'

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   SONOSLIBRA - ระบบติดตั้งเครื่อง MINI PC อัตโนมัติ (v$ScriptVersion 24/7)       " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# 0. ตรวจสอบสัญญาณอินเทอร์เน็ต
Write-Host "[*] กำลังตรวจสอบสัญญาณอินเทอร์เน็ต..." -ForegroundColor Yellow
if (-not (Test-Connection -ComputerName 8.8.8.8 -Count 2 -Quiet)) {
    Write-Host ""
    Write-Host "[!] ไม่พบสัญญาณอินเทอร์เน็ต! กรุณาเสียบสาย LAN หรือต่อ Wi-Fi ให้เรียบร้อยก่อนรันโปรแกรมนี้" -ForegroundColor Red
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้"
    exit 1
}
Write-Host "[OK] เชื่อมต่ออินเทอร์เน็ตเรียบร้อย" -ForegroundColor Green

# 1. ดึงเลขลำดับถัดไป (Auto-Increment) จาก Google Sheets อัตโนมัติ
$CurrentYear = (Get-Date).Year.ToString()
$NextSeq     = "01"

Write-Host "[*] กำลังดึงเลขลำดับเครื่องล่าสุดจากระบบ Cloud..." -ForegroundColor Yellow
try {
    $CheckUrl = "$GoogleWebhookUrl`?action=getNext&year=$CurrentYear"
    $CloudCheck = Invoke-RestMethod -Uri $CheckUrl -Method Get -TimeoutSec 10
    if ($CloudCheck.status -eq "ready" -and $CloudCheck.nextSeq) {
        $NextSeq = $CloudCheck.nextSeq
    }
} catch {
    Write-Warning "ดึงเลขลำดับจาก Cloud ไม่สำเร็จ ระบบจะใช้เลขลำดับเริ่มต้นแทน"
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Yellow
Write-Host " ขั้นตอนเดียวที่ต้องทำ: พิมพ์ชื่อสถานที่ภาษาอังกฤษ (ไม่ต้องพิมพ์ปี ไม่ต้องพิมพ์เลข)" -ForegroundColor Yellow
Write-Host " ตัวอย่าง: SIAMPARAGON หรือ ICONSIAM หรือ CENTRALWORLD" -ForegroundColor White
Write-Host "==================================================================" -ForegroundColor Yellow

do {
    $RawInput = Read-Host "พิมพ์ชื่อสถานที่ตรงนี้แล้วกด Enter"
    $CleanLocation = ($RawInput.ToUpper() -replace '\s+', '' -replace '[^A-Z0-9\-]', '')

    if ([string]::IsNullOrWhiteSpace($CleanLocation)) {
        Write-Host "[!] กรุณาพิมพ์ชื่อสถานที่เป็นภาษาอังกฤษอย่างน้อย 2 ตัวอักษร`n" -ForegroundColor Red
        $Valid = $false
    } elseif ($CleanLocation -match '^20\d{2}-\d{2,3}-') {
        $SiteName = $CleanLocation
        $Valid = $true
    } else {
        $SiteName = "$CurrentYear-$NextSeq-$CleanLocation"
        $Valid = $true
    }
} while (-not $Valid)

$WinComputerName = if ($SiteName.Length -gt 15) { $SiteName.Substring(0, 15) } else { $SiteName }

Write-Host "`n[+] ระบบตั้งชื่อเครื่องให้อัตโนมัติเป็น : $SiteName" -ForegroundColor Green
Write-Host "[+] กำลังเริ่มติดตั้งและปรับจูน Policy ทั้งหมด กรุณารอ 2-3 นาที..." -ForegroundColor Cyan

# ==============================================================================
# 2. ปรับโหมดพลังงาน High Performance 24/7 + ห้ามหลับ + ปิด USB Suspend
# ==============================================================================
Write-Host "`n>>> [1/7] ตั้งค่า Power Plan (High Performance) และปิดโหมดหลับทั้งหมด..." -ForegroundColor Yellow

# เปิดและบังคับใช้โหมด High Performance (GUID: 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c)
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

# ปิด Timeout การหลับ การดับจอ และ Hibernate ทั้งหมด (0 = Never)
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /h off

# ปิดการล็อกหน้าจอเมื่อหน้าจอดับ (Console lock display off timeout = 0)
powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0

# ปิดระบบตัดไฟพอร์ต USB อัตโนมัติ (USB Selective Suspend = Disabled)
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

# ปิดระบบประหยัดไฟ PCI Express Link State
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0

# ตั้งค่าปุ่มกด Power หน้าเครื่องให้ "ไม่ทำอะไร (Do Nothing)" ป้องกันคนไปเผลอกดโดน
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
powercfg /setActive SCHEME_CURRENT

# ปิดโหมดประหยัดไฟของการ์ด LAN และ Wi-Fi ทุกตัว
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue
}

# ==============================================================================
# 3. ตั้งค่า Auto-Login 100%, ปิด Screen Saver, ปิด Lock Screen และ UAC
# ==============================================================================
Write-Host ">>> [2/7] ปลดล็อก Auto-Login, ปิด Screen Saver และปิด Lock Screen..." -ForegroundColor Yellow
$CurrentUser = $env:USERNAME
$SecurePass = ConvertTo-SecureString $MasterPassword -AsPlainText -Force
Set-LocalUser -Name $CurrentUser -Password $SecurePass -PasswordNeverExpires $true -ErrorAction SilentlyContinue

# ปิดฟีเจอร์ Windows 11 Passwordless ที่ชอบบล็อก Auto-Login
$DeviceLockPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
if (Test-Path $DeviceLockPath) {
    Set-ItemProperty -Path $DeviceLockPath -Name "DevicePasswordLessBuildVersion" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# ตั้งค่า Winlogon Auto-Login เข้าหน้า Desktop อัตโนมัติเมื่อไฟดับแล้วติดใหม่
$RegWinlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $RegWinlogon -Name "AutoAdminLogon" -Value "1" -Type String
Set-ItemProperty -Path $RegWinlogon -Name "DefaultUserName" -Value $CurrentUser -Type String
Set-ItemProperty -Path $RegWinlogon -Name "DefaultPassword" -Value $MasterPassword -Type String
Set-ItemProperty -Path $RegWinlogon -Name "ForceAutoLogon" -Value "1" -Type String
Remove-ItemProperty -Path $RegWinlogon -Name "AutoLogonCount" -ErrorAction SilentlyContinue

# ปิด Screen Saver ถาวร และห้ามถามรหัสผ่านเมื่อพักหน้าจอ
$RegDesktop = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $RegDesktop -Name "ScreenSaveActive" -Value "0" -Type String
Set-ItemProperty -Path $RegDesktop -Name "ScreenSaverIsSecure" -Value "0" -Type String
Set-ItemProperty -Path $RegDesktop -Name "ScreenSaveTimeOut" -Value "0" -Type String
Remove-ItemProperty -Path $RegDesktop -Name "SCRNSAVE.EXE" -ErrorAction SilentlyContinue

# ปิดหน้าต่าง Lock Screen และ Inactivity Timeout ของระบบ
$RegPersonalize = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
if (-not (Test-Path $RegPersonalize)) { New-Item -Path $RegPersonalize -Force | Out-Null }
Set-ItemProperty -Path $RegPersonalize -Name "NoLockScreen" -Value 1 -Type DWord

$RegSystemPol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $RegSystemPol -Name "EnableFirstLogonAnimation" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegSystemPol -Name "InactivityTimeoutSecs" -Value 0 -Type DWord -ErrorAction SilentlyContinue
# ปิด UAC Prompt เพื่อไม่ให้หน้าจอดำเวลาวิศวกรรีโมทผ่าน RustDesk เข้ามากดตั้งค่า
Set-ItemProperty -Path $RegSystemPol -Name "ConsentPromptBehaviorAdmin" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegSystemPol -Name "PromptOnSecureDesktop" -Value 0 -Type DWord -ErrorAction SilentlyContinue

# ==============================================================================
# 4. ตั้งค่าระบบเสริมที่จำเป็น (TimeZone, ปิด Auto-Reboot Update)
# ==============================================================================
Write-Host ">>> [3/7] ตั้งค่าโซนเวลาไทย และบล็อกการรีสตาร์ทเอง..." -ForegroundColor Yellow

# ตั้งโซนเวลาไทย (UTC+7) และซิงค์เวลามาตรฐาน
Set-TimeZone -Id "SE Asia Standard Time" -ErrorAction SilentlyContinue
Start-Service w32time -ErrorAction SilentlyContinue
w32tm /resync /force 2>$null | Out-Null

# [Fix 4] ไม่เปลี่ยน Network Profile เป็น Private แล้ว (LAN ของไซต์ลูกค้าคงเป็น Public ตามเดิม)
#         การรีโมทผ่าน Tailscale ใช้ Firewall rule เฉพาะในขั้นตอน [5/7] แทน

# ป้องกัน Windows Update แอบรีสตาร์ทเครื่องเองตอนใช้งานอยู่
$RegWinUpdate = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $RegWinUpdate)) { New-Item -Path $RegWinUpdate -Force | Out-Null }
Set-ItemProperty -Path $RegWinUpdate -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord

# ==============================================================================
# 5. ติดตั้งและตั้งค่า Tailscale & RustDesk
# ==============================================================================
Write-Host ">>> [4/7] กำลังดาวน์โหลดและติดตั้ง Tailscale & RustDesk..." -ForegroundColor Yellow
winget install --id tailscale.tailscale --silent --accept-package-agreements --accept-source-agreements
winget install --id RustDesk.RustDesk --silent --accept-package-agreements --accept-source-agreements

Start-Sleep -Seconds 5

Write-Host ">>> [5/7] กำลังตั้งค่ารหัสผ่าน RustDesk และเปิด Direct IP..." -ForegroundColor Yellow
# [Fix 4] รับ RustDesk Direct IP เฉพาะจากเครือข่าย Tailscale เท่านั้น (คนใน LAN ไซต์ต่อไม่ได้)
#         100.64.0.0/10 = Tailscale IPv4, fd7a:115c:a1e0::/48 = Tailscale IPv6
$TailscaleRanges = @('100.64.0.0/10', 'fd7a:115c:a1e0::/48')
$RustDeskExe     = "C:\Program Files\RustDesk\rustdesk.exe"

# ลบ rule เดิมของ v5.0 ที่เปิดรับจากทุกที่ (กรณีรันซ้ำบนเครื่องเก่า) แล้วสร้างใหม่
Remove-NetFirewallRule -DisplayName "SonosLibra - RustDesk Direct IP" -ErrorAction SilentlyContinue
Remove-NetFirewallRule -DisplayName "SonosLibra - RustDesk via Tailscale" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "SonosLibra - RustDesk via Tailscale" `
                    -Direction Inbound `
                    -LocalPort 21118 `
                    -Protocol TCP `
                    -RemoteAddress $TailscaleRanges `
                    -Profile Any `
                    -Action Allow | Out-Null

# ตัวติดตั้ง RustDesk สร้าง rule แบบ "อนุญาตโปรแกรม rustdesk.exe ทุกพอร์ต" ไว้เอง
# ซึ่งจะทำให้ rule ด้านบนไม่มีผล จึงจำกัด RemoteAddress ของ rule เหล่านั้นให้เหลือเฉพาะ Tailscale ด้วย
Get-NetFirewallApplicationFilter -Program $RustDeskExe -ErrorAction SilentlyContinue |
    Get-NetFirewallRule -ErrorAction SilentlyContinue |
    Where-Object { $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' } |
    Set-NetFirewallRule -RemoteAddress $TailscaleRanges -ErrorAction SilentlyContinue

$RustDeskID  = "N/A"
if (Test-Path $RustDeskExe) {
    Stop-Service -Name "rustdesk" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2

    & $RustDeskExe --password $MasterPassword | Out-Null

    $ConfigDirs = @(
        "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config",
        "$env:APPDATA\RustDesk\config"
    )
    foreach ($Dir in $ConfigDirs) {
        if (-not (Test-Path $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }
        $TomlFile = Join-Path $Dir "RustDesk2.toml"
        if (Test-Path $TomlFile) {
            $Content = Get-Content $TomlFile -Raw
            if ($Content -notmatch "direct-server") {
                Add-Content -Path $TomlFile -Value "`n[options]`ndirect-server = 'Y'"
            }
        } else {
            Set-Content -Path $TomlFile -Value "[options]`ndirect-server = 'Y'"
        }
    }

    Set-Service -Name "rustdesk" -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name "rustdesk" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3

    try { $RustDeskID = (& $RustDeskExe --get-id | Out-String).Trim() } catch { $RustDeskID = "Unknown" }
}

# ==============================================================================
# 6. ผูกเครื่องเข้ากับ Tailscale แบบ Non-Expire ถาวรด้วย OAuth + Tag
# ==============================================================================
Write-Host ">>> [6/7] กำลังผูกเครื่องเข้ากับระบบ Tailscale แบบไม่มีวันหมดอายุ ($SiteName)..." -ForegroundColor Yellow
$TailscaleExe = "C:\Program Files\Tailscale\tailscale.exe"
$TailscaleIP  = "N/A"
$TailscaleErr = ""
if (Test-Path $TailscaleExe) {
    $FullAuthKey = "$TailscaleKey`?ephemeral=false&preauthorized=true"
    & $TailscaleExe up --authkey=$FullAuthKey --hostname=$SiteName --advertise-tags=tag:site-node --unattended --reset
    if ($LASTEXITCODE -ne 0) { $TailscaleErr = "tailscale up ล้มเหลว (exit code $LASTEXITCODE)" }

    # [Fix 1] รอ IP สูงสุด 60 วินาที (20 x 3 วินาที)
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Seconds 3
        try {
            $CheckIP = (& $TailscaleExe ip -4 2>$null | Out-String).Trim()
            if ($CheckIP -match '^100\.') {
                $TailscaleIP = $CheckIP
                break
            }
        } catch {}
    }
} else {
    $TailscaleErr = "ไม่พบไฟล์ $TailscaleExe (ติดตั้ง Tailscale ผ่าน winget ไม่สำเร็จ)"
}

# [Fix 1] ถ้าไม่ได้ Tailscale IP ห้ามดำเนินการต่อ และห้าม Restart
if ($TailscaleIP -notmatch '^100\.') {
    if (-not $TailscaleErr) { $TailscaleErr = "รอ 60 วินาทีแล้วยังไม่ได้ Tailscale IP" }
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "   [X] ติดตั้งไม่สำเร็จ - เครื่องนี้ยังรีโมทผ่าน Tailscale ไม่ได้!        " -ForegroundColor Red
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "   สาเหตุ : $TailscaleErr" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   ระบบจะ *ไม่* Restart เครื่อง และ *ไม่* ส่งข้อมูลขึ้น Google Sheets" -ForegroundColor White
    Write-Host "   กรุณาตรวจสอบอินเทอร์เน็ต / Firewall ของไซต์ แล้วรันสคริปต์นี้ใหม่อีกครั้ง" -ForegroundColor White
    Write-Host "   (ห้ามถอด Flash Drive และห้ามปล่อยเครื่องไว้ที่ไซต์จนกว่าจะติดตั้งสำเร็จ)" -ForegroundColor White
    Write-Host "==================================================================" -ForegroundColor Red
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้"
    exit 1
}
Write-Host "    [OK] Tailscale เชื่อมต่อแล้ว IP: $TailscaleIP" -ForegroundColor Green

# ==============================================================================
# 7. บันทึกข้อมูลขึ้น Google Sheets อัตโนมัติ + สำรองลง Flash Drive + เปลี่ยนชื่อเครื่อง
# ==============================================================================
Write-Host ">>> [7/7] กำลังส่งข้อมูลเข้าตาราง Google Sheets ของบริษัท..." -ForegroundColor Yellow
$SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$MacAddress   = (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).MacAddress
try { $PublicIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim() } catch { $PublicIP = "Unknown" }

$Payload = [ordered]@{
    SiteName        = $SiteName
    WinComputerName = $WinComputerName
    TailscaleIP     = $TailscaleIP
    RustDeskID      = $RustDeskID
    SerialNumber    = $SerialNumber
    MacAddress      = $MacAddress
    PublicIP        = $PublicIP
}

$LocalCsvPath = Join-Path $PSScriptRoot "Site_Inventory_Backup.csv"
[PSCustomObject]$Payload | Export-Csv -Path $LocalCsvPath -Append -NoTypeInformation -Encoding UTF8

try {
    $QueryParams = @(
        "SiteName=$([uri]::EscapeDataString($SiteName))",
        "WinComputerName=$([uri]::EscapeDataString($WinComputerName))",
        "TailscaleIP=$([uri]::EscapeDataString($TailscaleIP))",
        "RustDeskID=$([uri]::EscapeDataString($RustDeskID))",
        "SerialNumber=$([uri]::EscapeDataString($SerialNumber))",
        "MacAddress=$([uri]::EscapeDataString($MacAddress))",
        "PublicIP=$([uri]::EscapeDataString($PublicIP))"
    ) -join "&"

    $FullUrl = "$GoogleWebhookUrl`?$QueryParams"
    $Response = Invoke-RestMethod -Uri $FullUrl -Method Get -TimeoutSec 15
    if ($Response.status -eq "success") {
        Write-Host "    [OK] ส่งข้อมูลขึ้น Google Sheets เรียบร้อยแล้ว!" -ForegroundColor Green
    }
} catch {
    Write-Warning "ส่งข้อมูลขึ้น Cloud ไม่สำเร็จ แต่บันทึกสำรองลง Flash Drive ให้แล้ว"
}

Rename-Computer -NewName $WinComputerName -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "   ติดตั้งเสร็จสมบูรณ์ 100%! กรุณาจดชื่อนี้แปะสติกเกอร์หน้าเครื่อง:   " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "   ชื่อเครื่อง (SITE NAME) :  $SiteName" -ForegroundColor Yellow
Write-Host "   TAILSCALE IP          :  $TailscaleIP" -ForegroundColor White
Write-Host "   RUSTDESK ID           :  $RustDeskID" -ForegroundColor White
Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "เครื่องจะทำการ Restart อัตโนมัติในอีก 15 วินาที (ถอด Flash Drive ออกได้เลย)..." -ForegroundColor Cyan
Start-Sleep -Seconds 15
Restart-Computer -Force
