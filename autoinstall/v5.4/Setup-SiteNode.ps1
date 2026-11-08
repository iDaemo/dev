#Requires -RunAsAdministrator
# ==============================================================================
# SonosLibra Infrastructure - Zero-Touch Site Mini PC Provisioning Script (v5.4)
# Edition: Hardened Headless 24/7 (100% Non-Expire OAuth + Full Policy Tuning)
#
# วิธีใช้   : ดับเบิลคลิก Install-SiteNode.bat จาก Flash Drive > กด Yes ที่หน้าต่าง UAC
# เอกสาร   : README.md (อยู่โฟลเดอร์เดียวกัน)
# Encoding : ไฟล์นี้ต้องเป็น UTF-8 with BOM + CRLF เสมอ (ไม่งั้นภาษาไทยเพี้ยนบน PowerShell 5.1)
# Exit code: 0 = สำเร็จ (เครื่องจะ Restart) / 1 = ล้มเหลว (ไม่ Restart, รันซ้ำได้)
#
# Changelog v5.4:
#   - ไม่ต้องมีโฟลเดอร์ Installers แล้ว: ดาวน์โหลดเวอร์ชันล่าสุดจากอินเทอร์เน็ตทุกครั้ง
#   - ไม่มี winget -> ติดตั้ง winget ให้อัตโนมัติ (Microsoft.WinGet.Client / Repair-WinGetPackageManager)
#   - winget ใช้ไม่ได้ -> ดาวน์โหลด MSI ล่าสุดจากเว็บทางการโดยตรง + ตรวจลายเซ็นดิจิทัลก่อนติดตั้ง
#   - โปรแกรมติดตั้งอยู่แล้ว -> อัปเดตเป็นเวอร์ชันล่าสุดผ่าน winget
#
# Changelog v5.3:
#   [6]  ตั้งรอบ Windows Update ติดตั้งวันอาทิตย์ 03:00 + Reboot อัตโนมัติวันอาทิตย์ 04:00
#   [7]  ดึงเลขลำดับจาก Cloud ไม่ได้ -> ไม่ใช้ "01" อัตโนมัติอีกต่อไป ให้พิมพ์เลขเอง
#   [8]  ชื่อเครื่องรูปแบบใหม่ YY-NN-สถานที่ (ไม่เกิน 15 ตัว) ชื่อ Windows = ชื่อ Tailscale = สติกเกอร์
#   [9]  สร้างบัญชี Local "SiteNode" สำหรับ Auto-Login (ไม่แตะบัญชีของคนที่ติดตั้ง)
#   [14] เลิกปิด UAC (คืนค่า Default) - RustDesk แบบ Service มองเห็นหน้าต่าง UAC อยู่แล้ว
#   [15] ตัด NoLockScreen (มีผลเฉพาะ Enterprise/Education)
#   [17] ตัดตัวแปรที่ไม่ได้ใช้
#   [7b] ส่ง Serial ตอนขอเลขลำดับ (ใช้คู่กับ Apps Script Code.gs v3.2 ที่จองเลขด้วย LockService)
#        Webhook URL ชี้ไปที่ deployment ใหม่ของ Apps Script v3.2
# v5.2: ตรวจเน็ต 443, winget + MSI สำรอง, Log, ข้อความสติกเกอร์ / v5.1: หยุดถ้าไม่ได้ Tailscale IP,
#       บังคับ Admin, UTF-8 BOM, Firewall เฉพาะ Tailscale
# ==============================================================================

# --- ตรวจสิทธิ์ Administrator (กรณีวางคำสั่งลง Console โดยตรง #Requires จะไม่ทำงาน) ---
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Write-Host ""
    Write-Host "[!] สคริปต์นี้ต้องรันด้วยสิทธิ์ Administrator" -ForegroundColor Red
    Write-Host "    กรุณาดับเบิลคลิก Install-SiteNode.bat แล้วกด Yes ที่หน้าต่าง UAC" -ForegroundColor Red
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้"
    exit 1
}

# ==============================================================================
# ส่วนตั้งค่าหลัก (ฝังรหัสถาวร - ดู Accepted Risk ใน README)
# ==============================================================================
$ScriptVersion    = '5.4'
$MasterPassword   = 'Sono$33338888'
$TailscaleKey     = 'tskey-client-kXyFKGoyXD11CNTRL-Pi6X3m7Z3QZq2egY9SSZPZLqZoD9DuVP'
$GoogleWebhookUrl = 'https://script.google.com/macros/s/AKfycbywkibVqwNaU9x0LG3GVeP7ksQUk6qfreT40ODSj9DN-JKX5w0KmNvx1aEJ2KCabaOmrA/exec'

$AutoLoginUser    = 'SiteNode'          # [9] บัญชี Local ที่เครื่อง Login อัตโนมัติ (รหัส = $MasterPassword)
$WeeklyRebootDay  = 'Sunday'            # [6] วันที่ Reboot ประจำสัปดาห์
$WeeklyRebootTime = '04:00'             # [6] เวลา Reboot (Windows Update ติดตั้งก่อนหน้านี้ 1 ชม.)

$ProgressPreference = 'SilentlyContinue'
# PowerShell 5.1 ต้องเปิด TLS 1.2 เพื่อดาวน์โหลดจาก GitHub / PowerShell Gallery
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$UsbRoot      = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$UsbLogDir    = Join-Path $UsbRoot 'Logs'
$DownloadDir  = Join-Path $env:TEMP 'SonosLibra'

$TailscaleExe = "C:\Program Files\Tailscale\tailscale.exe"
$RustDeskExe  = "C:\Program Files\RustDesk\rustdesk.exe"

# ==============================================================================
# Log + ฟังก์ชันช่วย
# ==============================================================================
$LogDir  = Join-Path $env:ProgramData 'SonosLibra\Logs'
New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction SilentlyContinue | Out-Null
$LogFile = Join-Path $LogDir ("Setup-v{0}-{1}-{2}.log" -f $ScriptVersion, (Get-Date -Format 'yyyyMMdd-HHmmss'), $env:COMPUTERNAME)
try { Start-Transcript -Path $LogFile -Append | Out-Null } catch {}

function Save-LogToUsb {
    try { Stop-Transcript | Out-Null } catch {}
    try {
        New-Item -ItemType Directory -Path $UsbLogDir -Force -ErrorAction Stop | Out-Null
        Copy-Item -Path $LogFile -Destination $UsbLogDir -Force -ErrorAction Stop
    } catch {
        Write-Host "    [!] คัดลอก Log ลง USB ไม่สำเร็จ (Log ยังอยู่ที่ $LogFile)" -ForegroundColor DarkYellow
    }
}

# หยุดการติดตั้งอย่างปลอดภัย: แสดงสาเหตุ + บันทึก Log + ไม่ Restart
function Stop-Setup {
    param([string]$Reason, [string[]]$Hints = @())
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "   [X] ติดตั้งไม่สำเร็จ - ระบบหยุดการติดตั้งและจะ *ไม่* Restart เครื่อง     " -ForegroundColor Red
    Write-Host "==================================================================" -ForegroundColor Red
    Write-Host "   สาเหตุ : $Reason" -ForegroundColor Yellow
    foreach ($h in $Hints) { Write-Host "   - $h" -ForegroundColor White }
    Write-Host ""
    Write-Host "   แก้ไขแล้วรัน Install-SiteNode.bat ใหม่อีกครั้ง (รันซ้ำได้ ไม่เสียหาย)" -ForegroundColor White
    Write-Host "   ห้ามปล่อยเครื่องไว้ที่ไซต์จนกว่าจะติดตั้งสำเร็จ" -ForegroundColor White
    Write-Host "   Log: $LogFile" -ForegroundColor DarkGray
    Write-Host "==================================================================" -ForegroundColor Red
    Save-LogToUsb
    Read-Host "กดปุ่ม Enter เพื่อปิดหน้าต่างนี้"
    exit 1
}

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   SONOSLIBRA - ระบบติดตั้งเครื่อง MINI PC อัตโนมัติ (v$ScriptVersion 24/7)       " -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# 0. ตรวจความพร้อมก่อนเริ่ม (ขั้นนี้แก้ไขเครื่องเฉพาะการติดตั้ง winget ถ้ายังไม่มี)
# ==============================================================================
Write-Host "[*] กำลังตรวจสอบการเชื่อมต่ออินเทอร์เน็ต (HTTPS ไปยัง Tailscale)..." -ForegroundColor Yellow
$NetOK = $false
foreach ($TestHost in @('controlplane.tailscale.com', 'login.tailscale.com')) {
    try {
        if (Test-NetConnection -ComputerName $TestHost -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue) {
            $NetOK = $true
            break
        }
    } catch {}
}
if (-not $NetOK) {
    Stop-Setup -Reason "เชื่อมต่อ Tailscale ผ่าน HTTPS (พอร์ต 443) ไม่ได้" -Hints @(
        "ตรวจว่าเสียบสาย LAN หรือต่อ Wi-Fi แล้ว",
        "ถ้าเน็ตของไซต์มีหน้า Login (Captive Portal) ให้เปิด Browser แล้ว Login ก่อน",
        "ถ้า Firewall ของไซต์บล็อก ให้ลองแชร์ Hotspot จากมือถือชั่วคราว"
    )
}
Write-Host "[OK] เชื่อมต่ออินเทอร์เน็ตเรียบร้อย" -ForegroundColor Green

# --- winget: หา -> ถ้าไม่มีให้ติดตั้งเอง -> ถ้ายังไม่ได้ จะดาวน์โหลด MSI จากเว็บทางการแทน ---
function Find-Winget {
    $Cmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($Cmd) { return $Cmd.Source }
    # หลังติดตั้งใหม่ alias อาจยังไม่อยู่ใน PATH ของ session นี้ จึงหาจากโฟลเดอร์ของ App Installer โดยตรง
    $Exe = Get-ChildItem -Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" `
                         -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($Exe) { return $Exe.FullName }
    return $null
}

function Install-WingetBootstrap {
    Write-Host "[*] ไม่พบ winget - กำลังติดตั้ง winget จาก Microsoft (ใช้เวลา 1-3 นาที)..." -ForegroundColor Yellow
    try {
        if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope AllUsers -ErrorAction Stop | Out-Null
        }
        Install-Module -Name Microsoft.WinGet.Client -Repository PSGallery -Scope AllUsers -Force -ErrorAction Stop
        Import-Module -Name Microsoft.WinGet.Client -Force -ErrorAction Stop
        Repair-WinGetPackageManager -AllUsers -Latest -ErrorAction Stop | Out-Null
        return $true
    } catch {
        Write-Host "    [!] ติดตั้ง winget ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor DarkYellow
        return $false
    }
}

$Winget = Find-Winget
if (-not $Winget) {
    if (Install-WingetBootstrap) { $Winget = Find-Winget }
}

if ($Winget) {
    Write-Host "[OK] พบ winget ($(& $Winget --version 2>$null))" -ForegroundColor Green
} else {
    # ไม่มี winget: ต้องต่อเว็บดาวน์โหลดทางการได้ ไม่งั้นหยุดตั้งแต่ตอนนี้ (ก่อนแก้ไขเครื่อง)
    $DirectOK = $true
    foreach ($TestHost in @('pkgs.tailscale.com', 'api.github.com', 'github.com')) {
        if (-not (Test-NetConnection -ComputerName $TestHost -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)) {
            $DirectOK = $false
        }
    }
    if (-not $DirectOK) {
        Stop-Setup -Reason "ไม่มี winget และเชื่อมต่อเว็บดาวน์โหลดทางการ (pkgs.tailscale.com / github.com) ไม่ได้" -Hints @(
            "ถ้า Firewall ของไซต์บล็อก ให้ลองแชร์ Hotspot จากมือถือชั่วคราว",
            "หรืออัปเดต 'App Installer' จาก Microsoft Store แล้วรันใหม่"
        )
    }
    Write-Host "[!] ไม่มี winget - จะดาวน์โหลดเวอร์ชันล่าสุดจากเว็บทางการโดยตรงแทน" -ForegroundColor DarkYellow
}

# ==============================================================================
# 1. ตั้งชื่อเครื่อง
#    SiteName   (ทะเบียนใน Google Sheets) : 2026-07-ICONSIAM   (รูปแบบเดิม - Apps Script ใช้นับเลข)
#    DeviceName (Windows/Tailscale/สติกเกอร์): 26-07-ICONSIAM     (ไม่เกิน 15 ตัว จึงไม่ถูกตัด)
# ==============================================================================
$CurrentYear = (Get-Date).Year.ToString()
$YearShort   = $CurrentYear.Substring(2, 2)

# [7] ดึงเลขลำดับจาก Cloud (ลอง 3 ครั้ง) ถ้าไม่ได้ ให้พิมพ์เอง ไม่ใช้ "01" อัตโนมัติ
#     ส่ง Serial ไปด้วย: Apps Script v3.2 จะจองเลขไว้ให้ และรันซ้ำบนเครื่องเดิมจะได้เลขเดิม
$SerialNumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$NextSeq = $null
Write-Host "[*] กำลังดึงเลขลำดับเครื่องล่าสุดจากระบบ Cloud..." -ForegroundColor Yellow
for ($try = 1; $try -le 3 -and -not $NextSeq; $try++) {
    try {
        $CloudCheck = Invoke-RestMethod -Uri "$GoogleWebhookUrl`?action=getNext&year=$CurrentYear&serial=$([uri]::EscapeDataString([string]$SerialNumber))" -Method Get -TimeoutSec 10
        if ($CloudCheck.status -eq "ready" -and "$($CloudCheck.nextSeq)" -match '^\d{1,3}$') {
            $NextSeq = '{0:D2}' -f [int]$CloudCheck.nextSeq
        }
    } catch {}
    if (-not $NextSeq -and $try -lt 3) { Start-Sleep -Seconds 3 }
}
if ($NextSeq) {
    Write-Host "[OK] เลขลำดับถัดไป: $NextSeq" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[!] ดึงเลขลำดับจาก Cloud ไม่สำเร็จ" -ForegroundColor Red
    Write-Host "    เปิด Google Sheets ดูเลขลำดับล่าสุดของปี $CurrentYear แล้วพิมพ์ 'เลขถัดไป' (เช่น ล่าสุด 06 ให้พิมพ์ 07)" -ForegroundColor White
    do {
        $SeqInput = (Read-Host "พิมพ์เลขลำดับ (ตัวเลข 1-3 หลัก)").Trim()
    } while ($SeqInput -notmatch '^\d{1,3}$' -or [int]$SeqInput -lt 1)
    $NextSeq = '{0:D2}' -f [int]$SeqInput
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Yellow
Write-Host " พิมพ์ชื่อสถานที่ภาษาอังกฤษ (ไม่ต้องพิมพ์ปี ไม่ต้องพิมพ์เลข)" -ForegroundColor Yellow
Write-Host " ตัวอย่าง: ICONSIAM, PARAGON, CTW (ยาวได้ไม่เกิน 9 ตัวอักษร)" -ForegroundColor White
Write-Host " ติดตั้งเครื่องทดแทนชื่อเดิม: พิมพ์ชื่อเต็ม เช่น 26-07-ICONSIAM" -ForegroundColor DarkGray
Write-Host "==================================================================" -ForegroundColor Yellow

do {
    $Valid = $false
    $RawInput = Read-Host "พิมพ์ชื่อสถานที่ตรงนี้แล้วกด Enter"
    $Clean    = ($RawInput.ToUpper() -replace '\s+', '' -replace '[^A-Z0-9\-]', '')

    if ($Clean -match '^(?:20)?(\d{2})-(\d{2,3})-([A-Z0-9][A-Z0-9\-]*)$') {
        # ใส่ชื่อเต็มมาเอง (กรณีติดตั้งทดแทน)
        $Yy = $Matches[1]; $Seq = $Matches[2]; $Location = $Matches[3]
    } else {
        $Yy = $YearShort; $Seq = $NextSeq; $Location = $Clean.Trim('-')
    }

    $MaxLoc = 15 - "$Yy-$Seq-".Length
    if ($Location.Length -lt 2) {
        Write-Host "[!] กรุณาพิมพ์ชื่อสถานที่เป็นภาษาอังกฤษอย่างน้อย 2 ตัวอักษร (ภาษาไทยและอักขระพิเศษจะถูกตัดออก)`n" -ForegroundColor Red
    } elseif ($Location.Length -gt $MaxLoc) {
        # [8] ไม่ตัดชื่อเอง ให้คนพิมพ์ชื่อย่อที่สื่อความหมายแทน
        Write-Host "[!] '$Location' ยาว $($Location.Length) ตัว - ชื่อสถานที่ยาวได้ไม่เกิน $MaxLoc ตัว กรุณาพิมพ์ชื่อย่อ (เช่น CENTRALWORLD -> CTW)`n" -ForegroundColor Red
    } else {
        $SiteName   = "20$Yy-$Seq-$Location"
        $DeviceName = "$Yy-$Seq-$Location"
        $Valid = $true
    }
} while (-not $Valid)

Write-Host "`n[+] ชื่อเครื่อง (Windows / Tailscale) : $DeviceName" -ForegroundColor Green
Write-Host "[+] ทะเบียนใน Google Sheets          : $SiteName" -ForegroundColor Green
Write-Host "[+] กำลังเริ่มติดตั้งและปรับจูน Policy ทั้งหมด กรุณารอ 3-5 นาที..." -ForegroundColor Cyan

# ==============================================================================
# 2. ปรับโหมดพลังงาน High Performance 24/7 + ห้ามหลับ + ปิด USB Suspend
# ==============================================================================
Write-Host "`n>>> [1/7] ตั้งค่า Power Plan (High Performance) และปิดโหมดหลับทั้งหมด..." -ForegroundColor Yellow

powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /h off

# ไม่ล็อกหน้าจอเมื่อจอดับ
powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0
powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 0

# ปิด USB Selective Suspend
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0

# ปิดประหยัดไฟ PCI Express Link State
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0

# ปุ่ม Power หน้าเครื่อง = ไม่ทำอะไร
powercfg /setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 0
powercfg /setActive SCHEME_CURRENT

# ปิดโหมดประหยัดไฟของการ์ด LAN / Wi-Fi
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue
}

# ==============================================================================
# 3. [9] บัญชี SiteNode + Auto-Login + ปิด Screen Saver
# ==============================================================================
Write-Host ">>> [2/7] สร้างบัญชี '$AutoLoginUser' และตั้งค่า Auto-Login..." -ForegroundColor Yellow
$SecurePass = ConvertTo-SecureString $MasterPassword -AsPlainText -Force

try {
    if (Get-LocalUser -Name $AutoLoginUser -ErrorAction SilentlyContinue) {
        Set-LocalUser -Name $AutoLoginUser -Password $SecurePass -PasswordNeverExpires $true -ErrorAction Stop
        Enable-LocalUser -Name $AutoLoginUser -ErrorAction Stop
        Write-Host "    [OK] มีบัญชี $AutoLoginUser อยู่แล้ว - อัปเดตรหัสผ่าน" -ForegroundColor Green
    } else {
        New-LocalUser -Name $AutoLoginUser -Password $SecurePass -FullName 'SonosLibra Site Node' `
                      -Description 'Auto-login account for SonosLibra site node' `
                      -PasswordNeverExpires -AccountNeverExpires -ErrorAction Stop | Out-Null
        Write-Host "    [OK] สร้างบัญชี $AutoLoginUser แล้ว" -ForegroundColor Green
    }
    # ใช้ SID ของกลุ่ม Administrators เพื่อให้ใช้ได้กับ Windows ทุกภาษา
    # (ถ้าเป็นสมาชิกอยู่แล้วจะ error "already a member" จึงไม่ถือเป็นความล้มเหลว)
    Add-LocalGroupMember -SID 'S-1-5-32-544' -Member $AutoLoginUser -ErrorAction SilentlyContinue
} catch {
    Stop-Setup -Reason "สร้าง/ตั้งค่าบัญชี $AutoLoginUser ไม่สำเร็จ: $($_.Exception.Message)" -Hints @(
        "ตรวจว่ารหัสผ่านผ่านนโยบายความซับซ้อนของเครื่อง"
    )
}

# ปิดฟีเจอร์ Windows 11 Passwordless ที่บล็อก Auto-Login
$DeviceLockPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
if (Test-Path $DeviceLockPath) {
    Set-ItemProperty -Path $DeviceLockPath -Name "DevicePasswordLessBuildVersion" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Auto-Login (DefaultDomainName ตั้งในขั้นตอนสุดท้ายหลังเปลี่ยนชื่อเครื่อง)
$RegWinlogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $RegWinlogon -Name "AutoAdminLogon"  -Value "1" -Type String
Set-ItemProperty -Path $RegWinlogon -Name "DefaultUserName" -Value $AutoLoginUser -Type String
Set-ItemProperty -Path $RegWinlogon -Name "DefaultPassword" -Value $MasterPassword -Type String
Set-ItemProperty -Path $RegWinlogon -Name "ForceAutoLogon"  -Value "1" -Type String
Remove-ItemProperty -Path $RegWinlogon -Name "AutoLogonCount" -ErrorAction SilentlyContinue

# ปิด Screen Saver ใน Default User Profile (บัญชี SiteNode จะได้ค่านี้ตอน Login ครั้งแรก)
$DefaultHive = Join-Path $env:SystemDrive 'Users\Default\NTUSER.DAT'
reg.exe load 'HKU\SL_DefaultUser' "$DefaultHive" 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    try {
        $DesktopKey = 'HKU\SL_DefaultUser\Control Panel\Desktop'
        reg.exe add $DesktopKey /v ScreenSaveActive    /t REG_SZ /d 0 /f | Out-Null
        reg.exe add $DesktopKey /v ScreenSaverIsSecure /t REG_SZ /d 0 /f | Out-Null
        reg.exe add $DesktopKey /v ScreenSaveTimeOut   /t REG_SZ /d 0 /f | Out-Null
        reg.exe delete $DesktopKey /v SCRNSAVE.EXE /f 2>$null | Out-Null
    } finally {
        [gc]::Collect()
        Start-Sleep -Seconds 1
        reg.exe unload 'HKU\SL_DefaultUser' 2>$null | Out-Null
    }
} else {
    Write-Host "    [!] โหลด Default User Profile ไม่ได้ - ข้ามการตั้งค่า Screen Saver" -ForegroundColor DarkYellow
}

$RegSystemPol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $RegSystemPol -Name "EnableFirstLogonAnimation" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegSystemPol -Name "InactivityTimeoutSecs"     -Value 0 -Type DWord -ErrorAction SilentlyContinue

# [14] คืนค่า UAC เป็นค่า Default (กรณีรันซ้ำบนเครื่องที่ v5.0 เคยปิดไว้)
Set-ItemProperty -Path $RegSystemPol -Name "ConsentPromptBehaviorAdmin" -Value 5 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $RegSystemPol -Name "PromptOnSecureDesktop"      -Value 1 -Type DWord -ErrorAction SilentlyContinue

# ==============================================================================
# 4. TimeZone + [6] รอบ Windows Update และ Reboot ประจำสัปดาห์
# ==============================================================================
Write-Host ">>> [3/7] ตั้งค่าโซนเวลาไทย และรอบ Update/Reboot ประจำสัปดาห์..." -ForegroundColor Yellow

Set-TimeZone -Id "SE Asia Standard Time" -ErrorAction SilentlyContinue
Start-Service w32time -ErrorAction SilentlyContinue
w32tm /resync /force 2>$null | Out-Null

# Windows Update: ดาวน์โหลดและติดตั้งอัตโนมัติ วันอาทิตย์ 03:00 และห้าม Restart เองระหว่างวัน
$RegWinUpdate = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (-not (Test-Path $RegWinUpdate)) { New-Item -Path $RegWinUpdate -Force | Out-Null }
Set-ItemProperty -Path $RegWinUpdate -Name "NoAutoUpdate"                  -Value 0 -Type DWord
Set-ItemProperty -Path $RegWinUpdate -Name "AUOptions"                     -Value 4 -Type DWord
Set-ItemProperty -Path $RegWinUpdate -Name "ScheduledInstallDay"           -Value 1 -Type DWord   # 1 = วันอาทิตย์
Set-ItemProperty -Path $RegWinUpdate -Name "ScheduledInstallTime"          -Value 3 -Type DWord   # 03:00
Set-ItemProperty -Path $RegWinUpdate -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord

# Reboot ประจำสัปดาห์ เพื่อให้ Update ที่ติดตั้งแล้วมีผล (เตือนล่วงหน้า 5 นาที ยกเลิกได้ด้วย shutdown /a)
try {
    $RebootAction   = New-ScheduledTaskAction -Execute "$env:SystemRoot\System32\shutdown.exe" `
                        -Argument '/r /f /t 300 /c "SonosLibra weekly maintenance reboot in 5 minutes (cancel: shutdown /a)"'
    $RebootTrigger  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $WeeklyRebootDay -At $WeeklyRebootTime
    $RebootPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName 'SonosLibra - Weekly Reboot' -TaskPath '\SonosLibra\' `
        -Action $RebootAction -Trigger $RebootTrigger -Principal $RebootPrincipal `
        -Description 'Weekly reboot so Windows Updates can finish installing' -Force -ErrorAction Stop | Out-Null
    Write-Host "    [OK] ตั้ง Reboot ทุกวัน $WeeklyRebootDay เวลา $WeeklyRebootTime" -ForegroundColor Green
} catch {
    Write-Host "    [!] ตั้ง Reboot ประจำสัปดาห์ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# ==============================================================================
# 5. ติดตั้ง Tailscale & RustDesk เวอร์ชันล่าสุด
#    winget -> (ถ้าไม่ได้) ดาวน์โหลด MSI ล่าสุดจากเว็บทางการ + ตรวจลายเซ็น -> ตรวจว่ามีไฟล์ .exe จริง
# ==============================================================================
Write-Host ">>> [4/7] กำลังดาวน์โหลดและติดตั้ง Tailscale & RustDesk (เวอร์ชันล่าสุด)..." -ForegroundColor Yellow

# ลิงก์ดาวน์โหลด MSI ล่าสุดจากแหล่งทางการ (ใช้เมื่อ winget ใช้ไม่ได้)
function Get-LatestMsiUrl {
    param([string]$Name)
    switch ($Name) {
        'Tailscale' { return 'https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi' }
        'RustDesk'  {
            $Release = Invoke-RestMethod -Uri 'https://api.github.com/repos/rustdesk/rustdesk/releases/latest' `
                                         -Headers @{ 'User-Agent' = 'SonosLibra-SiteNode-Setup' } -TimeoutSec 20 -ErrorAction Stop
            $Asset = $Release.assets | Where-Object { $_.name -match '^rustdesk-[\d\.]+-x86_64\.msi$' } | Select-Object -First 1
            if ($Asset) { return $Asset.browser_download_url }
            return $null
        }
    }
    return $null
}

function Install-App {
    param([string]$Name, [string]$WingetId, [string]$ExePath, [string]$SignerMatch)

    $WingetArgs = @('--id', $WingetId, '--exact', '--silent', '--source', 'winget',
                    '--accept-package-agreements', '--accept-source-agreements')

    # ติดตั้งอยู่แล้ว (รันซ้ำ) -> อัปเดตเป็นเวอร์ชันล่าสุด (ถ้าไม่มีเวอร์ชันใหม่ winget จะข้ามไปเอง)
    if (Test-Path $ExePath) {
        if ($Winget) {
            Write-Host "    [*] $Name ติดตั้งอยู่แล้ว - ตรวจหาเวอร์ชันใหม่..." -ForegroundColor Gray
            & $Winget upgrade @WingetArgs | Out-Null
        }
        Write-Host "    [OK] $Name พร้อมใช้งาน" -ForegroundColor Green
        return
    }

    # ทางที่ 1: winget
    if ($Winget) {
        Write-Host "    [*] ติดตั้ง $Name ผ่าน winget..." -ForegroundColor Gray
        & $Winget install @WingetArgs
        $WingetRC = $LASTEXITCODE
        Start-Sleep -Seconds 3
        if (Test-Path $ExePath) {
            Write-Host "    [OK] ติดตั้ง $Name สำเร็จ (winget)" -ForegroundColor Green
            return
        }
        Write-Host "    [!] winget ติดตั้ง $Name ไม่สำเร็จ (exit code $WingetRC) - ลองดาวน์โหลดตรงจากเว็บทางการ" -ForegroundColor DarkYellow
    }

    # ทางที่ 2: ดาวน์โหลด MSI ล่าสุดจากเว็บทางการ + ตรวจลายเซ็นดิจิทัล
    $FailReason = ""
    try {
        $Url = Get-LatestMsiUrl -Name $Name
        if (-not $Url) { throw "หาลิงก์ดาวน์โหลดเวอร์ชันล่าสุดไม่เจอ" }

        New-Item -ItemType Directory -Path $DownloadDir -Force | Out-Null
        $MsiPath = Join-Path $DownloadDir "$Name-latest.msi"
        Write-Host "    [*] ดาวน์โหลด $Name จาก $Url ..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $Url -OutFile $MsiPath -UseBasicParsing -TimeoutSec 600 -ErrorAction Stop

        $Sig    = Get-AuthenticodeSignature -FilePath $MsiPath
        $Signer = if ($Sig.SignerCertificate) { $Sig.SignerCertificate.Subject } else { '-' }
        if ($Sig.Status -ne 'Valid' -or ($SignerMatch -and $Signer -notmatch $SignerMatch)) {
            Remove-Item -Path $MsiPath -Force -ErrorAction SilentlyContinue
            throw "ลายเซ็นดิจิทัลไม่ถูกต้อง (Status=$($Sig.Status), Signer=$Signer) - ไม่ติดตั้งเพื่อความปลอดภัย"
        }
        Write-Host "    [OK] ตรวจลายเซ็นดิจิทัลผ่าน: $Signer" -ForegroundColor Green

        $Proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$MsiPath`" /qn /norestart" -Wait -PassThru
        Remove-Item -Path $MsiPath -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
        if (Test-Path $ExePath) {
            Write-Host "    [OK] ติดตั้ง $Name สำเร็จ (ดาวน์โหลดตรง)" -ForegroundColor Green
            return
        }
        $FailReason = "MSI exit code $($Proc.ExitCode)"
    } catch {
        $FailReason = $_.Exception.Message
    }

    Stop-Setup -Reason "ติดตั้ง $Name ไม่สำเร็จ ($FailReason)" -Hints @(
        "ตรวจอินเทอร์เน็ต แล้วรันใหม่อีกครั้ง",
        "ถ้า Firewall ของไซต์บล็อก github.com / pkgs.tailscale.com ให้ลองใช้ Hotspot มือถือ"
    )
}

Install-App -Name "Tailscale" -WingetId "Tailscale.Tailscale" -ExePath $TailscaleExe -SignerMatch 'Tailscale'
Install-App -Name "RustDesk"  -WingetId "RustDesk.RustDesk"   -ExePath $RustDeskExe  -SignerMatch ''

Start-Sleep -Seconds 5

# ==============================================================================
# 6. RustDesk: รหัสผ่าน + Direct IP + Firewall เฉพาะ Tailscale
# ==============================================================================
Write-Host ">>> [5/7] กำลังตั้งค่ารหัสผ่าน RustDesk และเปิด Direct IP..." -ForegroundColor Yellow
# รับ RustDesk Direct IP เฉพาะจากเครือข่าย Tailscale (คนใน LAN ไซต์ต่อไม่ได้)
#   100.64.0.0/10 = Tailscale IPv4, fd7a:115c:a1e0::/48 = Tailscale IPv6
$TailscaleRanges = @('100.64.0.0/10', 'fd7a:115c:a1e0::/48')

Remove-NetFirewallRule -DisplayName "SonosLibra - RustDesk Direct IP"     -ErrorAction SilentlyContinue   # rule ของ v5.0
Remove-NetFirewallRule -DisplayName "SonosLibra - RustDesk via Tailscale" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "SonosLibra - RustDesk via Tailscale" `
                    -Direction Inbound `
                    -LocalPort 21118 `
                    -Protocol TCP `
                    -RemoteAddress $TailscaleRanges `
                    -Profile Any `
                    -Action Allow | Out-Null

# rule "อนุญาต rustdesk.exe ทุกพอร์ต" ที่ตัวติดตั้งสร้างเอง -> จำกัดให้รับเฉพาะ Tailscale ด้วย
Get-NetFirewallApplicationFilter -Program $RustDeskExe -ErrorAction SilentlyContinue |
    Get-NetFirewallRule -ErrorAction SilentlyContinue |
    Where-Object { $_.Direction -eq 'Inbound' -and $_.Action -eq 'Allow' } |
    Set-NetFirewallRule -RemoteAddress $TailscaleRanges -ErrorAction SilentlyContinue

$RustDeskID = "N/A"
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
# 7. Tailscale แบบ Non-Expire ถาวรด้วย OAuth + Tag (hostname = DeviceName)
# ==============================================================================
Write-Host ">>> [6/7] กำลังผูกเครื่องเข้ากับระบบ Tailscale แบบไม่มีวันหมดอายุ ($DeviceName)..." -ForegroundColor Yellow
$TailscaleIP  = "N/A"
$TailscaleErr = ""
if (Test-Path $TailscaleExe) {
    $FullAuthKey = "$TailscaleKey`?ephemeral=false&preauthorized=true"
    & $TailscaleExe up --authkey=$FullAuthKey --hostname=$DeviceName --advertise-tags=tag:site-node --unattended --reset
    if ($LASTEXITCODE -ne 0) { $TailscaleErr = "tailscale up ล้มเหลว (exit code $LASTEXITCODE)" }

    # รอ IP สูงสุด 60 วินาที
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
    $TailscaleErr = "ไม่พบไฟล์ $TailscaleExe"
}

if ($TailscaleIP -notmatch '^100\.') {
    if (-not $TailscaleErr) { $TailscaleErr = "รอ 60 วินาทีแล้วยังไม่ได้ Tailscale IP" }
    Stop-Setup -Reason "$TailscaleErr - เครื่องนี้ยังรีโมทผ่าน Tailscale ไม่ได้" -Hints @(
        "ระบบ *ไม่* ส่งข้อมูลขึ้น Google Sheets และ *ไม่* เปลี่ยนชื่อเครื่อง",
        "ตรวจอินเทอร์เน็ต / Firewall ของไซต์",
        "แจ้งผู้ดูแลตรวจ OAuth client และ tag:site-node ใน Tailscale Admin Console"
    )
}
Write-Host "    [OK] Tailscale เชื่อมต่อแล้ว IP: $TailscaleIP" -ForegroundColor Green

# ==============================================================================
# 8. บันทึกข้อมูล (Google Sheets + CSV สำรอง) + เปลี่ยนชื่อเครื่อง
# ==============================================================================
Write-Host ">>> [7/7] กำลังบันทึกข้อมูลและเปลี่ยนชื่อเครื่อง..." -ForegroundColor Yellow
$MacAddress   = (Get-NetAdapter | Where-Object Status -eq 'Up' | Select-Object -First 1).MacAddress
try { $PublicIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim() } catch { $PublicIP = "Unknown" }

$Payload = [ordered]@{
    SiteName        = $SiteName
    WinComputerName = $DeviceName
    TailscaleIP     = $TailscaleIP
    RustDeskID      = $RustDeskID
    SerialNumber    = $SerialNumber
    MacAddress      = $MacAddress
    PublicIP        = $PublicIP
}

$LocalCsvPath = Join-Path $UsbRoot "Site_Inventory_Backup.csv"
try {
    [PSCustomObject]$Payload | Export-Csv -Path $LocalCsvPath -Append -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
} catch {
    Write-Host "    [!] บันทึก CSV สำรองลง USB ไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

try {
    $QueryParams = ($Payload.GetEnumerator() | ForEach-Object {
        "$($_.Key)=$([uri]::EscapeDataString([string]$_.Value))"
    }) -join "&"
    $Response = Invoke-RestMethod -Uri "$GoogleWebhookUrl`?$QueryParams" -Method Get -TimeoutSec 15
    if ($Response.status -eq "success") {
        Write-Host "    [OK] ส่งข้อมูลขึ้น Google Sheets เรียบร้อยแล้ว!" -ForegroundColor Green
    } else {
        Write-Host "    [!] Google Sheets ตอบกลับไม่สำเร็จ - ข้อมูลอยู่ใน CSV สำรองบน USB" -ForegroundColor DarkYellow
    }
} catch {
    Write-Host "    [!] ส่งข้อมูลขึ้น Cloud ไม่สำเร็จ - ข้อมูลอยู่ใน CSV สำรองบน USB" -ForegroundColor DarkYellow
}

# เปลี่ยนชื่อเครื่อง แล้วผูก Auto-Login กับชื่อที่จะใช้จริงหลัง Restart
$LogonDomain = $env:COMPUTERNAME
if ($env:COMPUTERNAME -ne $DeviceName) {
    try {
        Rename-Computer -NewName $DeviceName -Force -ErrorAction Stop
        $LogonDomain = $DeviceName
        Write-Host "    [OK] เปลี่ยนชื่อเครื่องเป็น $DeviceName (มีผลหลัง Restart)" -ForegroundColor Green
    } catch {
        Write-Host "    [!] เปลี่ยนชื่อเครื่องไม่สำเร็จ: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
}
Set-ItemProperty -Path $RegWinlogon -Name "DefaultDomainName" -Value $LogonDomain -Type String

# ข้อความสติกเกอร์ (บันทึกลง USB)
$StickerText = @"
SONOSLIBRA SITE NODE
DEVICE    : $DeviceName
REMOTE    : RustDesk > $TailscaleIP  (ผ่าน Tailscale เท่านั้น)
RUSTDESK  : $RustDeskID
SERIAL    : $SerialNumber
REGISTRY  : $SiteName
INSTALLED : $(Get-Date -Format 'yyyy-MM-dd')  (script v$ScriptVersion)
"@
try {
    New-Item -ItemType Directory -Path $UsbLogDir -Force -ErrorAction Stop | Out-Null
    Set-Content -Path (Join-Path $UsbLogDir "Sticker_$DeviceName.txt") -Value $StickerText -Encoding UTF8 -ErrorAction Stop
} catch {}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "   ติดตั้งเสร็จสมบูรณ์ 100%! กรุณาจดชื่อนี้แปะสติกเกอร์หน้าเครื่อง:   " -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "   ชื่อเครื่อง (DEVICE)   :  $DeviceName" -ForegroundColor Yellow
Write-Host "   TAILSCALE IP          :  $TailscaleIP" -ForegroundColor White
Write-Host "   RUSTDESK ID           :  $RustDeskID" -ForegroundColor White
Write-Host "   AUTO-LOGIN USER       :  $AutoLoginUser" -ForegroundColor White
Write-Host ""
Write-Host "   วิธีรีโมท : เปิด Tailscale > เปิด RustDesk > ใส่ $TailscaleIP" -ForegroundColor Cyan
Write-Host "   [!] ใช้ IP 100.x เท่านั้น - IP ของ LAN ไซต์ (เช่น 192.168.x.x) จะต่อไม่ผ่าน" -ForegroundColor Cyan
Write-Host ""
Write-Host "   ข้อความสติกเกอร์ถูกบันทึกไว้ที่ USB: Logs\Sticker_$DeviceName.txt" -ForegroundColor DarkGray
Write-Host "==================================================================" -ForegroundColor Green

Save-LogToUsb
Write-Host "เครื่องจะทำการ Restart อัตโนมัติในอีก 15 วินาที (ถอด Flash Drive ออกได้เลย)..." -ForegroundColor Cyan
Start-Sleep -Seconds 15
Restart-Computer -Force
