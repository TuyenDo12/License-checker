# =============================================================================
#  WIN TOOLS - Bộ Công Cụ Tối Ưu Windows Chuyên Nghiệp
#  Phát triển bởi: Mr Hạnh - 0938.608.602
#  Website: https://khanggiaphuc.com/win
#  Phiên bản: v26.7.1 (đã nâng cấp)
# =============================================================================

#region --- PHIÊN BẢN (dùng chung, tránh lệch số như bản cũ) ---
$Global:AppVersion = "v26.7.1"
#endregion

#region --- KHỞI TẠO & KIỂM TRA QUYỀN ---
$OutputEncoding           = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
$ErrorActionPreference    = "SilentlyContinue"
$ProgressPreference       = "SilentlyContinue"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}
#endregion

#region --- ASSEMBLY & DPI ---
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
try {
    Add-Type -TypeDefinition @'
    using System; using System.Runtime.InteropServices;
    public class WinApi {
        [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
        [DllImport("user32.dll")] public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string lpszClass, string lpszWindow);
        [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
'@
    [void][WinApi]::SetProcessDPIAware()
} catch {}
#endregion

#region --- MÀU SẮC & FONT ---
$C = @{
    Bg         = [System.Drawing.Color]::FromArgb(15,15,20)
    BgPanel    = [System.Drawing.Color]::FromArgb(22,22,30)
    BgCard     = [System.Drawing.Color]::FromArgb(30,32,42)
    BgInput    = [System.Drawing.Color]::FromArgb(18,18,25)
    Accent     = [System.Drawing.Color]::FromArgb(0,210,180)
    AccentDark = [System.Drawing.Color]::FromArgb(0,140,120)
    Blue       = [System.Drawing.Color]::FromArgb(30,144,255)
    BlueDark   = [System.Drawing.Color]::FromArgb(0,90,180)
    Orange     = [System.Drawing.Color]::FromArgb(255,140,0)
    OrangeDark = [System.Drawing.Color]::FromArgb(180,80,0)
    Red        = [System.Drawing.Color]::FromArgb(220,50,50)
    RedDark    = [System.Drawing.Color]::FromArgb(140,20,20)
    Green      = [System.Drawing.Color]::FromArgb(50,205,50)
    GreenDark  = [System.Drawing.Color]::FromArgb(20,120,20)
    Purple     = [System.Drawing.Color]::FromArgb(148,0,211)
    PurpleDark = [System.Drawing.Color]::FromArgb(80,0,140)
    Text       = [System.Drawing.Color]::FromArgb(220,220,230)
    TextDim    = [System.Drawing.Color]::FromArgb(140,140,160)
    Border     = [System.Drawing.Color]::FromArgb(45,48,65)
    LogGreen   = [System.Drawing.Color]::FromArgb(80,220,120)
    LogYellow  = [System.Drawing.Color]::FromArgb(255,215,0)
    LogRed     = [System.Drawing.Color]::FromArgb(255,80,80)
    LogCyan    = [System.Drawing.Color]::FromArgb(0,220,220)
    White      = [System.Drawing.Color]::White
}
$F = @{
    Title  = New-Object System.Drawing.Font("Segoe UI",16,[System.Drawing.FontStyle]::Bold)
    Header = New-Object System.Drawing.Font("Segoe UI",9.5,[System.Drawing.FontStyle]::Bold)
    Body   = New-Object System.Drawing.Font("Segoe UI",9)
    Small  = New-Object System.Drawing.Font("Segoe UI",8)
    Mono   = New-Object System.Drawing.Font("Consolas",9)
    MonoSm = New-Object System.Drawing.Font("Consolas",8)
    Btn    = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
}
#endregion

#region --- HÀM TIỆN ÍCH UI ---
# [NÂNG CẤP GIAO DIỆN] Hàm điều chỉnh độ sáng/tối của màu để tạo hiệu ứng hover/press
function Get-AdjustedColor {
    param([System.Drawing.Color]$Color,[int]$Amount)
    $r=[Math]::Min(255,[Math]::Max(0,$Color.R+$Amount))
    $g=[Math]::Min(255,[Math]::Max(0,$Color.G+$Amount))
    $b=[Math]::Min(255,[Math]::Max(0,$Color.B+$Amount))
    return [System.Drawing.Color]::FromArgb($r,$g,$b)
}
# [NÂNG CẤP GIAO DIỆN] Tạo vùng bo tròn 4 góc dùng cho nút bấm
function New-RoundedRegion {
    param([int]$Width,[int]$Height,[int]$Radius=10)
    $r=[Math]::Max(2,[Math]::Min($Radius,[Math]::Floor([Math]::Min($Width,$Height)/2)))
    $d=$r*2
    $path=New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0,0,$d,$d,180,90)
    $path.AddArc($Width-$d,0,$d,$d,270,90)
    $path.AddArc($Width-$d,$Height-$d,$d,$d,0,90)
    $path.AddArc(0,$Height-$d,$d,$d,90,90)
    $path.CloseFigure()
    return New-Object System.Drawing.Region($path)
}
# [NÂNG CẤP GIAO DIỆN] Tạo path bo tròn 2 góc trên (dùng cho các tab menu dạng viên thuốc)
function New-RoundedTopPath {
    param([System.Drawing.Rectangle]$Rect,[int]$Radius=8)
    $d=$Radius*2
    $path=New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($Rect.X,$Rect.Y,$d,$d,180,90)
    $path.AddArc($Rect.Right-$d,$Rect.Y,$d,$d,270,90)
    $path.AddLine($Rect.Right,($Rect.Y+$Radius),$Rect.Right,$Rect.Bottom)
    $path.AddLine($Rect.Right,$Rect.Bottom,$Rect.X,$Rect.Bottom)
    $path.AddLine($Rect.X,$Rect.Bottom,$Rect.X,($Rect.Y+$Radius))
    $path.CloseFigure()
    return $path
}
function New-StyledButton {
    param($Text,$X,$Y,$W,$H,$BgColor,$FgColor=$C.White,$Font=$F.Btn,[int]$Radius=10)
    $b = New-Object System.Windows.Forms.Button
    $b.Text=$Text; $b.Location=[System.Drawing.Point]::new($X,$Y); $b.Size=[System.Drawing.Size]::new($W,$H)
    $b.BackColor=$BgColor; $b.ForeColor=$FgColor; $b.Font=$Font
    $b.FlatStyle="Flat"; $b.Cursor="Hand"
    # [NÂNG CẤP] Viền mảnh sáng hơn nền + hiệu ứng hover sáng lên / nhấn tối đi -> nút "nổi bật" rõ ràng hơn
    $b.FlatAppearance.BorderSize = 1
    $b.FlatAppearance.BorderColor = Get-AdjustedColor $BgColor 50
    $b.FlatAppearance.MouseOverBackColor = Get-AdjustedColor $BgColor 30
    $b.FlatAppearance.MouseDownBackColor = Get-AdjustedColor $BgColor -35
    # [NÂNG CẤP] Bo tròn 4 góc cho đẹp mắt, hiện đại hơn kiểu vuông cạnh cũ
    $b.Region = New-RoundedRegion -Width $W -Height $H -Radius $Radius
    return $b
}
function New-GroupCard {
    param($Text,$X,$Y,$W,$H,$FgColor=$C.Accent)
    $g = New-Object System.Windows.Forms.GroupBox
    $g.Text=$Text; $g.Location=[System.Drawing.Point]::new($X,$Y); $g.Size=[System.Drawing.Size]::new($W,$H)
    $g.ForeColor=$FgColor; $g.BackColor=$C.BgCard; $g.Font=$F.Header
    return $g
}
function New-CheckListBox {
    param($X,$Y,$W,$H)
    $l = New-Object System.Windows.Forms.CheckedListBox
    $l.Location=[System.Drawing.Point]::new($X,$Y); $l.Size=[System.Drawing.Size]::new($W,$H)
    $l.BackColor=$C.BgInput; $l.ForeColor=$C.Text; $l.CheckOnClick=$true
    $l.BorderStyle="None"; $l.Font=$F.Body; $l.ItemHeight=20
    return $l
}
function New-Label {
    param($Text,$X,$Y,$W,$H,$FgColor=$C.Text,$Font=$F.Body,$Align="MiddleLeft")
    $l = New-Object System.Windows.Forms.Label
    $l.Text=$Text; $l.Location=[System.Drawing.Point]::new($X,$Y); $l.Size=[System.Drawing.Size]::new($W,$H)
    $l.ForeColor=$FgColor; $l.Font=$Font; $l.TextAlign=$Align; $l.BackColor=[System.Drawing.Color]::Transparent
    return $l
}
#endregion

#region --- TRẠNG THÁI TOÀN CỤC ---
$global:UnTable  = @{}
$global:SwMap    = [ordered]@{}
$global:LogLines = [System.Collections.Generic.List[string]]::new()
#endregion

#region --- FORM CHÍNH (Độ phân giải thấp 1024x768) ---
$form               = New-Object System.Windows.Forms.Form
$form.Text          = "WIN TOOLS Pro $($Global:AppVersion) - Ultimate Edition"
$form.Size          = [System.Drawing.Size]::new(1010,730)
$form.StartPosition = "CenterScreen"
$form.BackColor     = $C.Bg; $form.ForeColor=$C.Text; $form.Font=$F.Body
$form.FormBorderStyle="FixedSingle"; $form.MaximizeBox=$false; $form.AutoScaleMode="Dpi"
#endregion

#region --- HEADER ---
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location=[System.Drawing.Point]::new(0,0); $pnlHeader.Size=[System.Drawing.Size]::new(1010,50)
$pnlHeader.BackColor=$C.BgPanel; $form.Controls.Add($pnlHeader)
$pnlHeader.Controls.Add((New-Label "WIN TOOLS PRO" 15 5 400 40 $C.Accent $F.Title "MiddleLeft"))
$pnlHeader.Controls.Add((New-Label "Phát triển bởi Mr Hạnh | 0938.608.602 | www.khanggiaphuc.com/win" 420 5 400 40 $C.TextDim $F.Body "MiddleCenter"))
$pnlHeader.Controls.Add((New-Label "$($Global:AppVersion) Pro" 875 5 110 40 $C.Orange $F.Header "MiddleRight"))
#endregion

#region --- SYSINFO BAR ---
$pnlSys = New-Object System.Windows.Forms.Panel
$pnlSys.Location=[System.Drawing.Point]::new(0,50); $pnlSys.Size=[System.Drawing.Size]::new(1010,35)
$pnlSys.BackColor=$C.BgCard; $form.Controls.Add($pnlSys)
$lblSys = New-Label "  Đang thu thập thông tin cấu hình phần cứng..." 0 0 1010 35 $C.Green $F.Mono "MiddleLeft"
$pnlSys.Controls.Add($lblSys)
#endregion

#region --- TAB CONTAINER ---
$tabCtrl = New-Object System.Windows.Forms.TabControl
$tabCtrl.Location=[System.Drawing.Point]::new(8,93); $tabCtrl.Size=[System.Drawing.Size]::new(980,480)
$tabCtrl.BackColor=$C.Bg; $tabCtrl.Font=$F.Header; $tabCtrl.DrawMode="OwnerDrawFixed"
# [NÂNG CẤP GIAO DIỆN] Thu nhỏ khoảng cách giữa các tab (158 -> 128) để hàng menu gọn gàng hơn, đủ chỗ cho 7 mục kể cả "Thoát"
$tabCtrl.ItemSize=[System.Drawing.Size]::new(128,32); $tabCtrl.SizeMode="Fixed"; $tabCtrl.Appearance="FlatButtons"
$form.Controls.Add($tabCtrl)
$tabCtrl.Add_DrawItem({
    param($s,$e)
    $g=$e.Graphics; $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $tab=$s.TabPages[$e.Index]; $sel=($e.Index -eq $s.SelectedIndex)
    $isExit = ($tab.Text -eq "Thoát")
    $bg = if ($isExit) { $C.BgCard } elseif ($sel) { $C.Accent } else { $C.BgCard }
    $fg = if ($isExit) { $C.Red } elseif ($sel) { $C.Bg } else { $C.TextDim }
    # [NÂNG CẤP GIAO DIỆN] Bo tròn 2 góc trên mỗi tab kiểu "viên thuốc" thay vì vuông cạnh cứng nhắc
    $rect = $e.Bounds; $rect.Inflate(-2,-3)
    $path = New-RoundedTopPath -Rect $rect -Radius 8
    $g.FillPath([System.Drawing.SolidBrush]::new($bg),$path)
    if ($isExit) {
        $pen = New-Object System.Drawing.Pen($C.Red,1)
        $g.DrawPath($pen,$path)
    }
    $sf=[System.Drawing.StringFormat]::new(); $sf.Alignment="Center"; $sf.LineAlignment="Center"
    $g.DrawString($tab.Text,$F.Header,[System.Drawing.SolidBrush]::new($fg),[System.Drawing.RectangleF]$rect,$sf)
})
function New-Tab { param($Text) $t=New-Object System.Windows.Forms.TabPage; $t.Text=$Text; $t.BackColor=$C.Bg; $t.BorderStyle="None"; return $t }
$tabTweaks  = New-Tab "Tùy Chỉnh"
$tabInstall = New-Tab "Cài Đặt"
$tabRemove  = New-Tab "Gỡ Bỏ"
$tabBackup  = New-Tab "Sao Lưu"
$tabLicense = New-Tab "Bản Quyền"
$tabAbout   = New-Tab "Thông Tin"
$tabExit    = New-Tab "Thoát"
foreach ($tab in @($tabTweaks,$tabInstall,$tabRemove,$tabBackup,$tabLicense,$tabAbout,$tabExit)) { $tabCtrl.TabPages.Add($tab) }

# [TÍNH NĂNG MỚI] Tab "Thoát" hoạt động như một nút bấm ngay trong hàng menu: bấm vào sẽ hỏi xác nhận rồi đóng ứng dụng,
# thay vì hiển thị 1 trang trống. Nếu người dùng chọn Không, tự động quay về tab đang xem trước đó.
$global:LastTabIndex = 0
$tabCtrl.Add_SelectedIndexChanged({
    if ($tabCtrl.SelectedTab -eq $tabExit) {
        $tabCtrl.SelectedIndex = $global:LastTabIndex
        $r = [System.Windows.Forms.MessageBox]::Show("Bạn có chắc chắn muốn thoát chương trình?","Xác nhận",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($r -eq [System.Windows.Forms.DialogResult]::Yes) { $form.Close() }
    } else {
        $global:LastTabIndex = $tabCtrl.SelectedIndex
    }
})
#endregion

#region --- LOG & PROGRESS ---
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location=[System.Drawing.Point]::new(8,582); $progressBar.Size=[System.Drawing.Size]::new(920,10)
$progressBar.Style="Continuous"; $progressBar.ForeColor=$C.Accent; $progressBar.BackColor=$C.BgCard
$form.Controls.Add($progressBar)
$lblPct = New-Label "0%" 938 577 50 18 $C.Text $F.Body "MiddleLeft"
$form.Controls.Add($lblPct)
$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location=[System.Drawing.Point]::new(8,598); $txtLog.Size=[System.Drawing.Size]::new(980,82)
$txtLog.BackColor=$C.BgInput; $txtLog.ForeColor=$C.LogGreen; $txtLog.Font=$F.MonoSm; $txtLog.ReadOnly=$true; $txtLog.BorderStyle="None"
$form.Controls.Add($txtLog)
$btnClearLog=New-StyledButton "X Log" 935 598 53 18 $C.BgCard $C.TextDim $F.Small
$form.Controls.Add($btnClearLog)
$btnClearLog.Add_Click({ $txtLog.Clear(); $global:LogLines.Clear() })

function Write-Log {
    param($Msg,[ValidateSet("OK","WARN","ERR","INFO","TITLE")]$Type="INFO")
    $ts=$( (Get-Date).ToString("HH:mm:ss") )
    $icon=switch($Type){"OK"{"[OK]"};"WARN"{"[!!]"};"ERR"{"[XX]"};"INFO"{"[>>]"};"TITLE"{"[==]"}}
    $line="[$ts] $icon $Msg"
    $color=switch($Type){"OK"{$C.LogGreen};"WARN"{$C.LogYellow};"ERR"{$C.LogRed};"INFO"{$C.LogCyan};"TITLE"{$C.Accent}}
    $txtLog.SelectionStart=$txtLog.TextLength; $txtLog.SelectionLength=0
    $txtLog.SelectionColor=$color; $txtLog.AppendText("$line`n"); $txtLog.ScrollToCaret()
    $global:LogLines.Add($line)
    [System.Windows.Forms.Application]::DoEvents()
}
function Set-Progress {
    param([int]$Val,[int]$Max=100)
    $p=[math]::Min(100,[math]::Max(0,[math]::Round($Val*100/$Max)))
    $progressBar.Value=$p; $lblPct.Text="$p%"
    [System.Windows.Forms.Application]::DoEvents()
}
function Reset-Progress { $progressBar.Value=0; $lblPct.Text="0%"; [System.Windows.Forms.Application]::DoEvents() }
#endregion

# ==============================================================
#  TAB 1 - TÙY CHỈNH HỆ THỐNG (BẢN NÂNG CẤP ĐỘT PHÁ)
# ==============================================================
#region --- TAB TWEAKS & SEARCH BAR ---
$gbTwL = New-GroupCard "TUỲ CHỈNH HỆ THỐNG WINDOWS" 5 5 440 435 $C.Accent
$tabTweaks.Controls.Add($gbTwL)

# [NÂNG CẤP 4] Bổ sung Bộ lọc Tìm kiếm nhanh (Search/Filter Bar)
$lblSearch = New-Label "Tìm kiếm nhanh:" 10 25 100 20 $C.TextDim $F.Small
$gbTwL.Controls.Add($lblSearch)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = [System.Drawing.Point]::new(110, 23)
$txtSearch.Size = [System.Drawing.Size]::new(320, 22)
$txtSearch.BackColor = $C.BgInput
$txtSearch.ForeColor = $C.Accent
$txtSearch.BorderStyle = "FixedSingle"
$txtSearch.Font = $F.Body
$gbTwL.Controls.Add($txtSearch)

# Di chuyển ListBox xuống dưới để nhường chỗ cho Search Bar
$listTw = New-CheckListBox 10 52 420 305
$gbTwL.Controls.Add($listTw)

$chkRestorePoint = New-Object System.Windows.Forms.CheckBox
$chkRestorePoint.Text = "Tạo Điểm Khôi Phục (Restore Point) trước khi chạy - khuyến nghị"
$chkRestorePoint.Location = [System.Drawing.Point]::new(10,359)
$chkRestorePoint.Size = [System.Drawing.Size]::new(420,18)
$chkRestorePoint.ForeColor = $C.TextDim; $chkRestorePoint.Font = $F.Small; $chkRestorePoint.Checked = $true
$gbTwL.Controls.Add($chkRestorePoint)

# Cơ sở dữ liệu Tweak nguyên bản - Đã tối ưu hóa lệnh [NÂNG CẤP 3]
$tweakDatabase = [ordered]@{
    "01 - Gỡ ứng dụng rác (Bloatware)" = @{
        Desc = "Loại bỏ các ứng dụng cài sẵn không cần thiết của Windows như Xbox, Clipchamp, Cortana, Maps, News, Teams, 3D Viewer, Get Help... giúp hệ thống gọn gàng hơn, giảm tiến trình chạy nền, tiết kiệm RAM, giải phóng dung lượng và cải thiện tốc độ khởi động. [BẢN VÁ AN TOÀN] Chỉ gỡ đúng danh sách các gói đã xác định là rác (whitelist), KHÔNG còn xoá theo kiểu loại trừ nữa để tránh xoá nhầm Windows Security, Terminal, Store hay các app hệ thống quan trọng khác."
        Cmd  = {
            $bloatList = @(
                "Microsoft.XboxApp","Microsoft.XboxGamingOverlay","Microsoft.XboxGameOverlay",
                "Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay","Microsoft.Xbox.TCUI",
                "Microsoft.GamingApp","Microsoft.549981C3F5F10","Microsoft.Clipchamp",
                "Microsoft.BingNews","Microsoft.BingWeather","Microsoft.BingFinance",
                "Microsoft.WindowsMaps","Microsoft.MicrosoftTeams","Microsoft.Teams",
                "Microsoft.YourPhone","Microsoft.People","Microsoft.MixedReality.Portal",
                "Microsoft.GetHelp","Microsoft.Getstarted","Microsoft.Microsoft3DViewer",
                "Microsoft.MicrosoftSolitaireCollection","Microsoft.MicrosoftOfficeHub",
                "Microsoft.WindowsFeedbackHub","Microsoft.WindowsSoundRecorder","Microsoft.ZuneMusic",
                "Microsoft.ZuneVideo","Microsoft.SkypeApp","Microsoft.PowerAutomateDesktop",
                "Microsoft.Todos","Microsoft.WindowsAlarms","Microsoft.MSPaint.WinAppSDK.Bloat"
            )
            foreach ($b in $bloatList) {
                Get-AppxPackage -AllUsers -Name $b -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
                Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "$b*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
            }
        }
        Undo = { Write-Log "Ứng dụng rác cần khôi phục qua Microsoft Store (tìm theo tên gói đã gỡ)." "WARN" }
    }
    "02 - Dọn dẹp ổ đĩa hệ thống (Disk Cleanup)" = @{
        Desc = "Xóa file tạm, bộ nhớ đệm, Windows Update Cache, Thumbnail Cache, Error Log, Memory Dump, Recycle Bin và thực hiện Component Cleanup. Giúp giải phóng dung lượng, tăng hiệu suất hệ thống và giữ Windows luôn sạch sẽ mà không làm mất dữ liệu cá nhân.."
        # [TỐI ƯU CÂU LỆNH 3]: Thêm dọn dẹp thư mục C:\Windows\Temp và CrashDumps hệ thống
        Cmd  = { 
            Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item "$env:LOCALAPPDATA\CrashDumps\*" -Force -Recurse -ErrorAction SilentlyContinue
            Start-Process "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -WindowStyle Hidden -Wait 
        }
        Undo = { Write-Log "Không cần hoàn tác dọn dẹp bộ nhớ tạm." "INFO" }
    }
    "03 - Dọn Prefetch và SuperFetch" = @{
        Desc = "Xóa bộ nhớ đệm khởi động và vô hiệu hóa dịch vụ SysMain, giúp giảm truy cập ổ đĩa và tăng tốc phản hồi hệ thống."
        Cmd  = { Stop-Service "SysMain" -Force; Set-Service "SysMain" -StartupType Disabled }
        Undo = { Set-Service "SysMain" -StartupType Automatic; Start-Service "SysMain" }
    }
    "04 - Tắt các ứng dụng khởi động cùng windows (Startup Apps)" = @{
        Desc = "Ngăn các ứng dụng không cần thiết tự khởi động cùng Windows, giúp máy khởi động nhanh hơn."
        Cmd  = {"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run","HKLM:\Software\Microsoft\Windows\CurrentVersion\Run","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"|%{if(Test-Path $_){(gi $_).Property|?{$_-notmatch'^EVKey$|^UniKey$|^GoogleDriveFS$|^SecurityHealth$|^WindowsDefender$'}|%{rp $_ $_ -Force -EA 0}}}}
        Undo = { Write-Log "Hãy bật lại thủ công trong Task Manager." "INFO" }
    }
    "05 - Tắt Background Apps ngầm" = @{
        Desc = "Vô hiệu hóa ứng dụng chạy nền để giảm tiêu thụ RAM, CPU và tiết kiệm pin.."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 0 -Type DWord -Force }
    }
    "06 - Kích hoạt High Performance" = @{
        Desc = "Bật chế độ điện năng tối đa hiệu suất cho CPU."
        Cmd  = { Start-Process "powercfg" -ArgumentList "/setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -WindowStyle Hidden }
        Undo = { Start-Process "powercfg" -ArgumentList "/setactive 381b4222-f694-41f0-9685-ff5bb260df2e" -WindowStyle Hidden }
    }
    "07 - Tối ưu hiệu ứng đồ họa" = @{
        Desc = "Tắt animation rườm rà, giúp phản hồi click chuột nhanh hơn."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 0 -Type DWord -Force }
    }
    "08 - Tắt hiệu ứng suốt mờ (Transparency)" = @{
        Desc = "Bỏ kính mờ giao diện, giảm tải cho GPU tích hợp."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 1 -Type DWord -Force }
    }
    "09 - Tắt Game Bar & Game Mode" = @{
        Desc = "Vô hiệu Xbox DVR để tránh tụt FPS khi chơi game."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 1 -Type DWord -Force }
    }
    "10 - Tắt Thông báo & Quảng cáo hệ thống" = @{
        Desc = "Chặn tin nhắn gợi ý phiền phức từ Windows."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GlobalSetting" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GlobalSetting" 1 -Type DWord -Force }
    }
    "11 - Tắt trợ lý ảo Cortana & Copilot" = @{
        Desc = "Dừng các tiến trình AI ngầm chiếm dụng bộ nhớ ảo."
        Cmd  = { $p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; if(!(Test-Path $p)){New-Item $p -Force}; Set-ItemProperty $p "TurnOffWindowsCopilot" 1 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 0 -Type DWord -Force }
    }
    "12 - Tắt Widget trên thanh Taskbar" = @{
        Desc = "Gỡ bảng tin tức thời tiết chạy ngầm gây lag máy."
        Cmd  = { Get-AppxPackage *Client.WebExperience* -AllUsers | Remove-AppxPackage -AllUsers }
        Undo = { Write-Log "Cài lại WebExperience qua Microsoft Store nếu muốn khôi phục." "INFO" }
    }
    "13 - Tắt Search Indexing (WSearch)" = @{
        Desc = "Dừng dịch vụ index dữ liệu để giảm 100% nghẽn Disk."
        Cmd = { Stop-Service "WSearch" -Force; Set-Service "WSearch" -StartupType Disabled }
        Undo = { Set-Service "WSearch" -StartupType Automatic; Start-Service "WSearch" }
    }
    "14 - Vô hiệu hóa Windows Update" = @{
        Desc = "Chặn tự động cập nhật hệ điều hành ngoài ý muốn một cách triệt để."
        # [TỐI ƯU CÂU LỆNH 3]: Khóa thêm Service điều phối dịch vụ UsoSvc của Win 10/11 tránh tự bật lại
        Cmd  = {
            Stop-Service wuauserv,bits,dosvc,UsoSvc -EA 0
            Set-Service wuauserv -StartupType Disabled -EA 0
            Set-Service bits -StartupType Disabled -EA 0
            Set-Service dosvc -StartupType Disabled -EA 0
            Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc" "Start" 4 -Force -EA 0
            ni 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Force|Out-Null
            sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' NoAutoUpdate 1 -Type DWord
            ni 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' -Force|Out-Null
            sp 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' AutoDownload 2 -Type DWord
        }
        Undo = {
            Set-Service wuauserv -StartupType Manual -EA 0
            Set-Service bits -StartupType Automatic -EA 0
            Set-Service dosvc -StartupType Automatic -EA 0
            Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\UsoSvc" "Start" 2 -Force -EA 0
            Start-Service bits,dosvc,wuauserv,UsoSvc -EA 0
            ri 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Recurse -Force -EA 0
            ri 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsStore' -Recurse -Force -EA 0
            gpupdate /force|Out-Null
        }
    }
    "15 - Tắt BitLocker mã hóa" = @{
        Desc = "Giải mã ổ đĩa hệ thống tránh khóa mất dữ liệu."
        Cmd  = { Disable-BitLocker -MountPoint $Env:SystemDrive }
        Undo = { Write-Log "Bật lại BitLocker thủ công trong Control Panel." "INFO" }
    }
    "16 - Tắt giao thức mạng IPv6" = @{
        Desc = "Vô hiệu hóa IPv6 để tăng độ ổn định cho mạng cục bộ LAN."
        Cmd  = { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 255 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0 -Type DWord -Force }
    }
    "17 - Tắt Folder Auto Discovery" = @{
        Desc = "Ngăn Explorer tự quét phân loại thư mục, mở folder cực nhanh."
        Cmd  = { Set-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "NotSpecified" -Force }
        Undo = { Remove-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" -Force }
    }
    "18 - Tắt Telemetry thu thập dữ liệu" = @{
        Desc = "Chặn dịch vụ thu thập dữ liệu và gửi thông tin chẩn đoán về Microsoft."
        Cmd  = { Set-Service "DiagTrack" -StartupType Disabled; Stop-Service "DiagTrack" -Force }
        Undo = { Set-Service "DiagTrack" -StartupType Automatic }
    }
    "19 - Gỡ bỏ tận gốc OneDrive ngầm" = @{
        Desc = "Xóa hoàn toàn OneDrive khởi động đồng bộ gây nghẽn mạng."
        Cmd  = {Stop-Process -n OneDrive -Force -EA 0;$o="$env:SystemRoot\SysWOW64\OneDriveSetup.exe";if(!(Test-Path $o)){$o="$env:SystemRoot\System32\OneDriveSetup.exe"};&$o /uninstall;ri "$env:UserProfile\OneDrive" -Recurse -Force -EA 0;ri "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -EA 0;ri "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -EA 0;ri "$env:SystemDrive\OneDriveTemp" -Recurse -Force -EA 0}
        Undo = { $o="$env:SystemRoot\SysWOW64\OneDriveSetup.exe";if(!(Test-Path $o)){$o="$env:SystemRoot\System32\OneDriveSetup.exe"};&$o }
    }
    "20 - Classic Taskbar Menu (Win11)" = @{
        Desc = "Khôi phục menu chuột phải cũ và căn lề trái thanh Taskbar."
        Cmd  = { New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force }
        Undo = { Remove-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force }
    }
    "21 - RAM Flush (Giải phóng bộ nhớ)" = @{
        Desc = "Ép hệ thống thu hồi bộ nhớ cache Standby dư thừa."
        Cmd  = { [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers() }
        Undo = { Write-Log "RAM Flush tự động cấp phát lại khi ứng dụng cần." "INFO" }
    }
    "22 - Chạy SSD TRIM Tối Ưu Tốc Độ" = @{
        Desc = "Gửi lệnh TRIM giúp ổ cứng SSD lấy lại tốc độ đọc ghi gốc."
        Cmd  = { Get-Volume | Where-Object { $_.DriveType -eq "Fixed" } | Optimize-Volume -ReTrim }
        Undo = { Write-Log "TRIM là tiến trình phần cứng, không cần khôi phục." "INFO" }
    }
    "23 - Reset mạng TCP/IP & Xóa DNS Cache" = @{
        Desc = "Khắc phục lỗi mất mạng, web load chậm hoặc xung đột IP bằng cách reset Winsock, TCP/IP stack và xoá bộ nhớ đệm DNS. Nên khởi động lại máy sau khi chạy."
        Cmd  = {
            Start-Process "netsh" -ArgumentList "winsock reset" -WindowStyle Hidden -Wait
            Start-Process "netsh" -ArgumentList "int ip reset" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/flushdns" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/release" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/renew" -WindowStyle Hidden -Wait
        }
        Undo = { Write-Log "Đây là thao tác reset, không có chiều hoàn tác." "INFO" }
    }
    "24 - Tắt Hibernate (Giải phóng dung lượng ổ C)" = @{
        Desc = "Tắt chế độ Ngủ đông (Hibernate) và xoá file hiberfil.sys, giúp giải phóng dung lượng ổ C tương đương với dung lượng RAM đang lắp trên máy. Không ảnh hưởng chế độ Sleep thông thường."
        Cmd  = { Start-Process "powercfg" -ArgumentList "/hibernate off" -WindowStyle Hidden -Wait }
        Undo = { Start-Process "powercfg" -ArgumentList "/hibernate on" -WindowStyle Hidden -Wait }
    }
    "25 - Dọn WinSxS nâng cao (Giảm dung lượng Windows)" = @{
        Desc = "Chạy DISM để dọn sạch các gói Windows Update cũ không thể gỡ (superseded) trong thư mục WinSxS. Có thể giải phóng vài GB nhưng sẽ KHÔNG THỂ gỡ cài đặt các bản Update trước đó sau khi chạy lệnh này."
        Cmd  = { Start-Process "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /ResetBase" -WindowStyle Hidden -Wait }
        Undo = { Write-Log "Thao tác ResetBase không thể hoàn tác - đây là hành vi mong muốn của DISM." "WARN" }
    }
}

# Lưu trữ danh sách trạng thái Check để đồng bộ khi lọc Tìm kiếm
$global:CheckedItemsState = @{}
foreach ($k in $tweakDatabase.Keys) { 
    [void]$listTw.Items.Add($k)
    $global:CheckedItemsState[$k] = $false 
}

# Logic đồng bộ trạng thái khi người dùng nhấn chọn trực tiếp trên CheckListBox
$listTw.Add_ItemCheck({
    param($s, $e)
    $itemText = $listTw.Items[$e.Index].ToString()
    $global:CheckedItemsState[$itemText] = ($e.NewValue -eq "Checked")
})

# Logic xử lý bộ lọc Tìm Kiếm nhanh (Search Text Changed)
$txtSearch.Add_TextChanged({
    $searchText = $txtSearch.Text.Trim()
    $prevSelected = if ($listTw.SelectedItem) { $listTw.SelectedItem.ToString() } else { $null }
    $listTw.Items.Clear()
    foreach ($key in $tweakDatabase.Keys) {
        if ($key -like "*$searchText*" -or $tweakDatabase[$key].Desc -like "*$searchText*") {
            $idx = $listTw.Items.Add($key)
            if ($global:CheckedItemsState[$key]) {
                $listTw.SetItemChecked($idx, $true)
            }
            if ($key -eq $prevSelected) { $listTw.SetSelected($idx, $true) }
        }
    }
})

# Khung chi tiết hiển thị mô tả Tweak khi Click chọn dòng
$gbTwR = New-GroupCard "MÔ TẢ CHI TIẾT TÙY CHỈNH" 455 5 510 435 $C.Accent
$tabTweaks.Controls.Add($gbTwR)
$txtTwDesc = New-Object System.Windows.Forms.RichTextBox
$txtTwDesc.Location=[System.Drawing.Point]::new(15,25); $txtTwDesc.Size=[System.Drawing.Size]::new(480,320)
$txtTwDesc.BackColor=$C.BgCard; $txtTwDesc.ForeColor=$C.Text; $txtTwDesc.Font=$F.Mono
$txtTwDesc.BorderStyle="None"; $txtTwDesc.ReadOnly=$true
$gbTwR.Controls.Add($txtTwDesc)

# [TÍNH NĂNG MỚI] Lưu / Tải cấu hình các tweak đã chọn ra file JSON - tiện khi cài hàng loạt máy
$pnlProfile = New-Object System.Windows.Forms.Panel
$pnlProfile.Location=[System.Drawing.Point]::new(15,349); $pnlProfile.Size=[System.Drawing.Size]::new(480,26)
$pnlProfile.BackColor=[System.Drawing.Color]::Transparent; $gbTwR.Controls.Add($pnlProfile)
$btnSaveProfile = New-StyledButton "Lưu Cấu Hình" 0 0 235 24 $C.BgCard $C.TextDim $F.Small
$btnLoadProfile = New-StyledButton "Tải Cấu Hình" 245 0 235 24 $C.BgCard $C.TextDim $F.Small
$pnlProfile.Controls.AddRange(@($btnSaveProfile,$btnLoadProfile))
$btnSaveProfile.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "WinTools Profile (*.json)|*.json"; $sfd.FileName = "WinTools_Profile.json"
    if ($sfd.ShowDialog() -eq "OK") {
        try {
            $selected = @($tweakDatabase.Keys | Where-Object { $global:CheckedItemsState[$_] -eq $true })
            # [SỬA LỖI PS 5.1] Dùng toán tử phẩy để ép ConvertTo-Json luôn xuất mảng, kể cả khi chỉ có 1 phần tử
            (,$selected) | ConvertTo-Json | Out-File $sfd.FileName -Encoding UTF8
            Write-Log "Đã lưu cấu hình $($selected.Count) tùy chỉnh -> $($sfd.FileName)" "OK"
        } catch { Write-Log "Lỗi lưu cấu hình: $($_.Exception.Message)" "ERR" }
    }
})
$btnLoadProfile.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "WinTools Profile (*.json)|*.json"
    if ($ofd.ShowDialog() -eq "OK") {
        try {
            # [SỬA LỖI PS 5.1] Ép @() vì ConvertFrom-Json cũng bung mảng 1 phần tử thành giá trị đơn (string), làm sai -contains
            $loaded = @(Get-Content $ofd.FileName -Raw | ConvertFrom-Json)
            foreach ($key in $tweakDatabase.Keys) { $global:CheckedItemsState[$key] = ($loaded -contains $key) }
            $txtSearch.Text = ""
            for ($i=0; $i -lt $listTw.Items.Count; $i++) {
                $listTw.SetItemChecked($i, ($global:CheckedItemsState[$listTw.Items[$i].ToString()] -eq $true))
            }
            Write-Log "Đã tải cấu hình từ: $($ofd.FileName)" "OK"
        } catch { Write-Log "Lỗi tải cấu hình (file không hợp lệ?): $($_.Exception.Message)" "ERR" }
    }
})

$listTw.Add_SelectedIndexChanged({
    if($listTw.SelectedItem -ne $null){
        $k = $listTw.SelectedItem.ToString()
        $entry = $tweakDatabase[$k]
        # [NÂNG CẤP] Hiển thị đầy đủ: Thông tin, Lệnh thực thi (Cmd) và Lệnh hoàn tác (Undo) dạng mã nguồn thật
        $cmdText  = $entry.Cmd.ToString().Trim()
        $undoText = $entry.Undo.ToString().Trim()
        $txtTwDesc.ForeColor = $C.LogCyan
        $txtTwDesc.Text = "TÙY CHỈNH: $k`n`nTHÔNG TIN:`n$($entry.Desc)`n`n--------------------------------------------------`nLỆNH THỰC THI (Cmd):`n$cmdText`n`n--------------------------------------------------`nLỆNH HOÀN TÁC (Undo):`n$undoText"
    }
})

# Thêm Panel chứa các nút thực thi phía dưới
$pnlTwBtns = New-Object System.Windows.Forms.Panel
$pnlTwBtns.Location=[System.Drawing.Point]::new(10,380); $pnlTwBtns.Size=[System.Drawing.Size]::new(420,45)
$pnlTwBtns.BackColor=[System.Drawing.Color]::Transparent; $gbTwL.Controls.Add($pnlTwBtns)

$btnAllTw    = New-StyledButton "Chọn Hết" 0 5 70 35 $C.BgCard $C.Accent
$btnNoneTw   = New-StyledButton "Bỏ Chọn" 75 5 70 35 $C.BgCard $C.TextDim
$btnRunTw    = New-StyledButton "CHẠY TÙY CHỈNH" 150 5 165 35 $C.Accent $C.Bg
$btnCancelTw = New-StyledButton "HỦY" 320 5 100 35 $C.RedDark $C.White
$btnCancelTw.Enabled = $false

$pnlTwBtns.Controls.AddRange(@($btnAllTw,$btnNoneTw,$btnRunTw,$btnCancelTw))

# [NÂNG CẤP GIAO DIỆN] Tùy chỉnh riêng màu hover cho từng nút đặc thù (nền mặc định đã có hiệu ứng sáng/tối chung)
$btnRunTw.FlatAppearance.MouseOverBackColor = $C.AccentDark
$btnAllTw.FlatAppearance.MouseOverBackColor = $C.Border
$btnNoneTw.FlatAppearance.MouseOverBackColor = $C.Border
$btnCancelTw.FlatAppearance.MouseOverBackColor = $C.Red

$btnAllTw.Add_Click({
    for($i=0;$i -lt $listTw.Items.Count;$i++){ 
        $listTw.SetItemChecked($i,$true)
        $global:CheckedItemsState[$listTw.Items[$i].ToString()] = $true
    }
})
$btnNoneTw.Add_Click({
    for($i=0;$i -lt $listTw.Items.Count;$i++){ 
        $listTw.SetItemChecked($i,$false)
        $global:CheckedItemsState[$listTw.Items[$i].ToString()] = $false
    }
})

# Panel chứa nút Hoàn tác bên Tab Mô tả
$pnlUndoBtns = New-Object System.Windows.Forms.Panel
$pnlUndoBtns.Location=[System.Drawing.Point]::new(15,380); $pnlUndoBtns.Size=[System.Drawing.Size]::new(480,45)
$pnlUndoBtns.BackColor=[System.Drawing.Color]::Transparent; $gbTwR.Controls.Add($pnlUndoBtns)

$btnUndoSel = New-StyledButton "HOÀN TÁC MỤC ĐANG CHỌN" 0 5 230 35 $C.BgCard $C.Orange
$btnUndoAll = New-StyledButton "HOÀN TÁC TẤT CẢ" 245 5 235 35 $C.BgCard $C.Red

$pnlUndoBtns.Controls.AddRange(@($btnUndoSel,$btnUndoAll))
$btnUndoSel.FlatAppearance.MouseOverBackColor = $C.OrangeDark
$btnUndoAll.FlatAppearance.MouseOverBackColor = $C.RedDark

# --- HÀM HỖ TRỢ CHẠY BẤT ĐỒNG BỘ QUA TIMER (CHỐNG FREEZE UI) ---
# [NÂNG CẤP 1] Sử dụng bộ lập lịch tuần tự thông qua cơ chế Windows Forms Timer và Jobs
$global:QueueJobs = [System.Collections.Generic.Queue[string]]::new()
$global:CurrentTaskName = ""
$global:TotalTasks = 0
$global:CompletedTasks = 0
$global:ActiveJob = $null
$global:IsUndoMode = $false
$global:JobStartTime = $null
$global:JobTimeoutSec = 120   # [NÂNG CẤP] Chống treo: hủy job nếu chạy quá 120 giây
$global:CancelRequested = $false

function Set-TweakButtonsEnabled {
    param([bool]$Running)
    $btnRunTw.Enabled    = -not $Running
    $btnUndoSel.Enabled  = -not $Running
    $btnUndoAll.Enabled  = -not $Running
    $btnCancelTw.Enabled = $Running
}

function New-SystemRestorePointSafe {
    try {
        Write-Log "Đang tạo Điểm Khôi Phục Hệ Thống (Restore Point)..." "INFO"
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "WinTools Pro $($Global:AppVersion) - Trước khi chỉnh sửa" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Log "Đã tạo Restore Point thành công. Có thể khôi phục qua rstrui.exe nếu cần." "OK"
    } catch {
        Write-Log "Không thể tạo Restore Point (có thể do máy tắt sẵn tính năng System Protection): $($_.Exception.Message)" "WARN"
    }
}

$asyncTimer = New-Object System.Windows.Forms.Timer
$asyncTimer.Interval = 200 # Kiểm tra trạng thái Job mỗi 200ms

$asyncTimer.Add_Tick({
    if ($global:CancelRequested) {
        if ($global:ActiveJob) { Stop-Job -Job $global:ActiveJob -ErrorAction SilentlyContinue; Remove-Job -Job $global:ActiveJob -Force -ErrorAction SilentlyContinue; $global:ActiveJob = $null }
        $global:QueueJobs.Clear()
        $asyncTimer.Stop(); Reset-Progress
        Write-Log "Đã HỦY tiến trình theo yêu cầu người dùng." "WARN"
        Set-TweakButtonsEnabled -Running $false
        $global:CancelRequested = $false
        return
    }
    if ($global:ActiveJob -eq $null) {
        # Nếu không có Job nào đang chạy, lấy tác vụ tiếp theo từ hàng đợi (Queue)
        if ($global:QueueJobs.Count -gt 0) {
            $global:CurrentTaskName = $global:QueueJobs.Dequeue()
            Write-Log "Bắt đầu xử lý: $($global:CurrentTaskName)..." "INFO"
            
            # Lấy khối Script mã nguồn tương ứng (Cmd hoặc Undo)
            $taskBlock = if ($global:IsUndoMode) { $tweakDatabase[$global:CurrentTaskName].Undo } else { $tweakDatabase[$global:CurrentTaskName].Cmd }
            
            # [BẤT ĐỒNG BỘ]: Khởi chạy tiến trình chạy nền không khóa UI Thread
            $global:ActiveJob = Start-Job -ScriptBlock $taskBlock
            $global:JobStartTime = Get-Date
        } else {
            # Hàng đợi trống -> Hoàn thành toàn bộ tiến trình
            $asyncTimer.Stop()
            Reset-Progress
            $statusText = if ($global:IsUndoMode) { "Hoàn thành toàn bộ tiến trình Hoàn tác!" } else { "Tối ưu hóa hệ thống hoàn tất!" }
            Write-Log $statusText "OK"
            [System.Windows.Forms.MessageBox]::Show($statusText, "Thông báo", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            Set-TweakButtonsEnabled -Running $false
        }
    } else {
        # Nếu có Job đang chạy, kiểm tra xem nó đã xong chưa
        $jobStatus = Get-Job -Id $global:ActiveJob.Id
        $elapsed = (Get-Date) - $global:JobStartTime
        if ($jobStatus.State -eq "Running" -and $elapsed.TotalSeconds -gt $global:JobTimeoutSec) {
            # [NÂNG CẤP] Chống treo: hủy tác vụ quá thời gian cho phép
            Write-Log "CẢNH BÁO: '$($global:CurrentTaskName)' chạy quá $($global:JobTimeoutSec)s, đang buộc dừng..." "ERR"
            Stop-Job -Job $global:ActiveJob -ErrorAction SilentlyContinue
            Remove-Job -Job $global:ActiveJob -Force -ErrorAction SilentlyContinue
            $global:ActiveJob = $null
            $global:CompletedTasks++
            Set-Progress $global:CompletedTasks $global:TotalTasks
            return
        }
        if ($jobStatus.State -ne "Running") {
            # [SỬA LỖI] Trước đây lỗi bên trong Job bị Out-Null nuốt mất, không ai biết tweak thất bại vì sao
            $jobErrors = $global:ActiveJob.ChildJobs[0].Error
            Receive-Job -Job $global:ActiveJob -ErrorAction SilentlyContinue | Out-Null
            Remove-Job -Job $global:ActiveJob -Force
            $global:ActiveJob = $null
            
            # Cập nhật thanh tiến trình tăng dần mượt mà
            $global:CompletedTasks++
            Set-Progress $global:CompletedTasks $global:TotalTasks
            if ($jobErrors -and $jobErrors.Count -gt 0) {
                Write-Log "Hoàn tất với cảnh báo: $($global:CurrentTaskName) - $($jobErrors[0].ToString())" "WARN"
            } else {
                Write-Log "Đã xong: $($global:CurrentTaskName)" "OK"
            }
        }
    }
})

# Sự kiện nút bấm CHẠY TÙY CHỈNH
$btnRunTw.Add_Click({
    $global:QueueJobs.Clear()
    # Duyệt qua các phần tử thực tế đang được tích chọn (Ủy thác từ trạng thái đồng bộ toàn cục)
    foreach ($key in $tweakDatabase.Keys) {
        if ($global:CheckedItemsState[$key] -eq $true) {
            $global:QueueJobs.Enqueue($key)
        }
    }

    if ($global:QueueJobs.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng tích chọn ít nhất một tùy chỉnh trước khi chạy!", "Thông báo", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if ($chkRestorePoint.Checked) { New-SystemRestorePointSafe }

    # Cấu hình biến môi trường chạy bất đồng bộ
    $global:IsUndoMode = $false
    $global:TotalTasks = $global:QueueJobs.Count
    $global:CompletedTasks = 0
    $global:CancelRequested = $false
    
    Set-TweakButtonsEnabled -Running $true
    
    Write-Log "Khởi động tiến trình tối ưu hóa đa luồng (Async)..." "TITLE"
    $asyncTimer.Start()
})

$btnCancelTw.Add_Click({
    Write-Log "Đang yêu cầu hủy tiến trình, vui lòng chờ tác vụ hiện tại kết thúc..." "WARN"
    $global:CancelRequested = $true
})

# Sự kiện nút bấm HOÀN TÁC MỤC ĐANG CHỌN
$btnUndoSel.Add_Click({
    if ($listTw.SelectedItem -eq $null) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn một dòng tùy chỉnh cụ thể bên danh sách để hoàn tác!", "Thông báo", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    $global:QueueJobs.Clear()
    $global:QueueJobs.Enqueue($listTw.SelectedItem.ToString())
    
    $global:IsUndoMode = $true
    $global:TotalTasks = 1
    $global:CompletedTasks = 0
    $global:CancelRequested = $false
    
    Set-TweakButtonsEnabled -Running $true
    
    Write-Log "Khởi động tiến trình hoàn tác mục được chọn..." "TITLE"
    $asyncTimer.Start()
})

# Sự kiện nút bấm HOÀN TÁC TẤT CẢ
$btnUndoAll.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("Bạn có chắc chắn muốn hoàn tác lại toàn bộ các cấu hình tweaks về mặc định không?", "Xác nhận", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($confirm -eq [System.Windows.Forms.DialogResult]::No) { return }

    $global:QueueJobs.Clear()
    foreach ($key in $tweakDatabase.Keys) {
        $global:QueueJobs.Enqueue($key)
    }
    
    $global:IsUndoMode = $true
    $global:TotalTasks = $global:QueueJobs.Count
    $global:CompletedTasks = 0
    $global:CancelRequested = $false
    
    Set-TweakButtonsEnabled -Running $true
    
    Write-Log "Khởi động tiến trình hoàn tác toàn bộ hệ thống..." "TITLE"
    $asyncTimer.Start()
})
#endregion
# ==============================================================
#  TAB 2 - CÀI ĐẶT ỨNG DỤNG (ĐÃ SỬA KHUNG HIỂN THỊ THÔNG TIN CHUẨN)
# ==============================================================
#region --- TAB INSTALL ---
$global:SwMap = [ordered]@{
    "Chrome"             = @{ ID="Google.Chrome";           Desc="Trình duyệt web phổ biến nhất thế giới của Google, tốc độ cao và kho tiện ích khổng lồ."; Url="https://www.google.com/chrome/" }
    "Firefox"            = @{ ID="Mozilla.Firefox";          Desc="Trình duyệt mã nguồn mở bảo mật cao, tôn trọng quyền riêng tư của người dùng."; Url="https://www.mozilla.org/firefox/" }
    "Edge"               = @{ ID="Microsoft.Edge";           Desc="Trình duyệt lõi Chromium mặc định của Windows, tối ưu pin và RAM cực tốt."; Url="https://www.microsoft.com/edge" }
    "Coc Coc"            = @{ ID="CocCoc.CocCoc";            Desc="Trình duyệt tối ưu cho người Việt, hỗ trợ tải video và sửa lỗi chính tả."; Url="https://coccoc.com/download" }
    "Brave Browser"      = @{ ID="Brave.Brave";              Desc="Trình duyệt siêu bảo mật, tự động chặn toàn bộ quảng cáo độc hại và tracker."; Url="https://brave.com/download/" }
    "Microsoft Office"   = @{ ID="Microsoft.Office";         Desc="Bộ ứng dụng văn phòng cao cấp chuẩn doanh nghiệp (Word, Excel, PowerPoint)."; Url="https://www.microsoft.com/microsoft-365" }
    "Foxit PDF Reader"   = @{ ID="Foxit.FoxitReader";        Desc="Phần mềm đọc và quản lý tệp tin tài liệu định dạng PDF nhẹ và mượt mà."; Url="https://www.foxit.com/pdf-reader/" }
    "Notepad++"          = @{ ID="Notepad++.Notepad++";      Desc="Trình soạn thảo văn bản code chuyên nghiệp gọn nhẹ, hỗ trợ nhiều ngôn ngữ."; Url="https://notepad-plus-plus.org/downloads/" }
    "Google Drive"       = @{ ID="Google.GoogleDrive";       Desc="Ứng dụng đồng bộ dữ liệu đám mây Google Drive trực tiếp vào ổ đĩa máy tính."; Url="https://www.google.com/drive/download/" }
    "AnyDesk"            = @{ ID="AnyDesk.AnyDesk";          Desc="Phần mềm điều khiển máy tính từ xa tốc độ cao kết nối ổn định."; Url="https://anydesk.com/downloads" }
    "UltraViewer"        = @{ ID="UltraViewer.UltraViewer";  Desc="Công cụ hỗ trợ kỹ thuật và điều khiển máy từ xa phổ biến hàng đầu tại Việt Nam."; Url="https://ultraviewer.net/vi/download" }
    "7-Zip"              = @{ ID="7zip.7zip";                Desc="Trình nén và giải nén dữ liệu mã nguồn mở hoàn toàn miễn phí, siêu nhẹ."; Url="https://www.7-zip.org/download.html" }
    "WinRAR"             = @{ ID="RARLab.WinRAR";            Desc="Phần mềm nén và giải nén file định dạng .RAR mạnh mẽ bậc nhất hiện nay."; Url="https://www.win-rar.com/download.html" }
    "UniKey"             = @{ ID="Unikey.Unikey";            Desc="Bộ gõ Tiếng Việt huyền thoại, gọn nhẹ và tương thích tuyệt đối mọi phiên bản OS."; Url="https://www.unikey.org/#download" }
    "EVKey"              = @{ ID="EVKey.EVKey";              Desc="Bộ gõ Tiếng Việt thế hệ mới, sửa lỗi dấu từ trên trình duyệt và game cực tốt."; Url="https://evkeyvn.com/" }
    "VLC Media Player"   = @{ ID="VideoLAN.VLC";             Desc="Trình phát nhạc và video đa định dạng, chạy mượt toàn bộ codec phổ thông."; Url="https://www.videolan.org/vlc/" }
    "Zalo PC"            = @{ ID="VNGCorp.Zalo";             Desc="Ứng dụng nhắn tin, gọi điện và truyền file làm việc số một tại Việt Nam."; Url="https://zalo.me/pc" }
    "Zoom"               = @{ ID="Zoom.Zoom";                Desc="Nền tảng hội họp trực tuyến và học tập từ xa chất lượng âm thanh hình ảnh cao."; Url="https://zoom.us/download" }
    "C++ x64 2022"       = @{ ID="Microsoft.VCRedist.2015+.x64"; Desc="Thư viện Microsoft Visual C++ Redistributable x64 cần thiết để chạy game và app."; Url="https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist" }
    ".NET Runtime 8"     = @{ ID="Microsoft.DotNet.Runtime.8";   Desc="Nền tảng thực thi cho các phần mềm viết trên ngôn ngữ hệ sinh thái .NET mới nhất."; Url="https://dotnet.microsoft.com/download/dotnet/8.0" }
}

$gbInL = New-GroupCard "PHẦN MỀM CÀI ĐẶT" 5 5 440 435 $C.Blue
$tabInstall.Controls.Add($gbInL)
$listSw = New-CheckListBox 10 25 420 350
foreach ($k in $global:SwMap.Keys) { [void]$listSw.Items.Add($k,$false) }
$gbInL.Controls.Add($listSw)
$btnSwAll   = New-StyledButton "Chọn Hết" 10 388 120 34 $C.BlueDark
$btnSwNone  = New-StyledButton "Bỏ Chọn"    135 388 120 34 $C.BgInput $C.TextDim
$btnInstall = New-StyledButton "CÀI ĐẶT"    260 388 170 34 $C.Blue
$gbInL.Controls.AddRange(@($btnSwAll,$btnSwNone,$btnInstall))
$btnSwAll.Add_Click({ for($i=0;$i -lt $listSw.Items.Count;$i++){$listSw.SetItemChecked($i,$true)} })
$btnSwNone.Add_Click({ for($i=0;$i -lt $listSw.Items.Count;$i++){$listSw.SetItemChecked($i,$false)} })

$gbInR = New-GroupCard "THÔNG TIN ỨNG DỤNG CÀI ĐẶT" 450 5 520 435 $C.Green
$tabInstall.Controls.Add($gbInR)

# GIỮ NGUYÊN CHIỀU CAO 400 CHO KHUNG TEXT ĐỂ HIỂN THỊ ĐỦ CÁC THÀNH PHẦN MÔ TẢ
$txtSwDescInfo = New-Object System.Windows.Forms.RichTextBox
$txtSwDescInfo.Location=[System.Drawing.Point]::new(10,25); $txtSwDescInfo.Size=[System.Drawing.Size]::new(500,360)
$txtSwDescInfo.BackColor=$C.BgInput; $txtSwDescInfo.ForeColor=$C.Text; $txtSwDescInfo.Font=$F.Mono; $txtSwDescInfo.ReadOnly=$true; $txtSwDescInfo.BorderStyle="None"
$txtSwDescInfo.DetectUrls = $true
$txtSwDescInfo.Text = "Chọn một phần mềm bên trái để xem thông tin chi tiết gói cài đặt winget..."
$gbInR.Controls.Add($txtSwDescInfo)
# [NÂNG CẤP] Cho phép click trực tiếp vào link tải trong khung mô tả để mở trình duyệt
$txtSwDescInfo.Add_LinkClicked({ param($s,$e) Start-Process $e.LinkText })

$lblWingetCheck = New-Label "Đang kiểm tra Winget..." 10 392 500 25 $C.TextDim $F.Body "MiddleLeft"
$gbInR.Controls.Add($lblWingetCheck)

$listSw.Add_SelectedIndexChanged({
    $n=$listSw.SelectedItem
    if ($n -and $global:SwMap.ContainsKey($n)) {
        $appInfo = $global:SwMap[$n]
        $installCmd   = "winget install --id $($appInfo.ID) --silent --force --accept-package-agreements --accept-source-agreements"
        $uninstallCmd = "winget uninstall --id $($appInfo.ID) --silent"
        $txtSwDescInfo.ForeColor = $C.LogCyan
        $txtSwDescInfo.Text = "TÊN PHẦN MỀM  : $n`nWINGET ID     : $($appInfo.ID)`n`nMÔ TẢ TÍNH NĂNG:`n$($appInfo.Desc)`n`n--------------------------------------------------`nLỆNH THỰC THI (Cài đặt):`n$installCmd`n`nLỆNH GỠ BỎ:`n$uninstallCmd`n`n--------------------------------------------------`nLINK TẢI CHÍNH CHỦ (dự phòng nếu Winget lỗi):`n$($appInfo.Url)`n`nTrạng thái: Sẵn sàng tải xuống và cài đặt ngầm (Silent Install) thông qua Microsoft Winget Package Manager."
    }
})

$btnInstall.Add_Click({
    $sel=$listSw.CheckedItems
    if ($sel.Count -eq 0) { Write-Log "Chưa chọn phần mềm nào." "WARN"; return }
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Log "Không tìm thấy Winget trên hệ thống!" "ERR"; return
    }
    Reset-Progress; Write-Log "BẮT ĐẦU TIẾN TRÌNH CÀI ĐẶT PHẦN MỀM" "TITLE"
    $c=0; $ok=0; $fail=0
    foreach ($item in $sel) {
        $c++; $id=$global:SwMap[$item].ID; Set-Progress $c $sel.Count
        Write-Log "Đang cài đặt ngầm: ${item}..." "INFO"
        $proc=Start-Process winget -ArgumentList "install --id $id --silent --force --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow -PassThru -ErrorAction SilentlyContinue
        if ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
            Write-Log "Thành công: ${item}" "OK"; $ok++
        } else {
            Write-Log "Thất bại: ${item} (Mã lỗi: $($proc.ExitCode))" "ERR"; $fail++
        }
    }
    Set-Progress 100; Write-Log "HOÀN TẤT CÀI ĐẶT: Thành công $ok | Thất bại $fail" "TITLE"
    [System.Windows.Forms.MessageBox]::Show("Tiến trình cài đặt hoàn tất!`nThành công: $ok`nThất bại: $fail","WinTools","OK","Information") | Out-Null
})
#endregion

# ==============================================================
#  TAB 3 - GỠ BỎ ỨNG DỤNG
# ==============================================================
#region --- TAB REMOVE ---
$gbUnL = New-GroupCard "ỨNG DỤNG ĐÃ CÀI" 5 5 440 435 $C.Orange
$tabRemove.Controls.Add($gbUnL)
$txtUnSearch = New-Object System.Windows.Forms.TextBox
$txtUnSearch.Location=[System.Drawing.Point]::new(10,25); $txtUnSearch.Size=[System.Drawing.Size]::new(310,25)
$txtUnSearch.BackColor=$C.BgInput; $txtUnSearch.ForeColor=$C.Text; $txtUnSearch.Font=$F.Body; $txtUnSearch.BorderStyle="FixedSingle"
$gbUnL.Controls.Add($txtUnSearch)
$btnRescan=New-StyledButton "Quét Lại" 330 22 100 25 $C.OrangeDark
$gbUnL.Controls.Add($btnRescan)
$listUn=New-CheckListBox 10 58 420 290
$gbUnL.Controls.Add($listUn)
$lblUnCount=New-Label "Chưa quét" 10 355 300 20 $C.TextDim $F.Small "MiddleLeft"
$gbUnL.Controls.Add($lblUnCount)
$btnUnAll  = New-StyledButton "Chọn Hết" 10 388 120 34 $C.OrangeDark
$btnUnNone = New-StyledButton "Bỏ Chọn"    135 388 120 34 $C.BgInput $C.TextDim
$btnGo     = New-StyledButton "GỠ BỎ"      260 388 170 34 $C.Red
$gbUnL.Controls.AddRange(@($btnUnAll,$btnUnNone,$btnGo))
$btnUnAll.Add_Click({ for($i=0;$i -lt $listUn.Items.Count;$i++){$listUn.SetItemChecked($i,$true)} })
$btnUnNone.Add_Click({ for($i=0;$i -lt $listUn.Items.Count;$i++){$listUn.SetItemChecked($i,$false)} })

$gbUnR = New-GroupCard "THÔNG TIN ỨNG DỤNG" 450 5 520 435 $C.Orange
$tabRemove.Controls.Add($gbUnR)
$txtUnInfo = New-Object System.Windows.Forms.RichTextBox
$txtUnInfo.Location=[System.Drawing.Point]::new(10,25); $txtUnInfo.Size=[System.Drawing.Size]::new(500,400)
$txtUnInfo.BackColor=$C.BgInput; $txtUnInfo.ForeColor=$C.Text; $txtUnInfo.Font=$F.Mono; $txtUnInfo.ReadOnly=$true; $txtUnInfo.BorderStyle="None"
$txtUnInfo.DetectUrls = $true
$txtUnInfo.Text="Chọn ứng dụng để xem thông tin chi tiết."
$gbUnR.Controls.Add($txtUnInfo)
$txtUnInfo.Add_LinkClicked({ param($s,$e) Start-Process $e.LinkText })

# [NÂNG CẤP] Dò link tải chính chủ bằng cách đối chiếu tên ứng dụng đã cài với danh mục SwMap (khớp gần đúng)
function Find-DownloadUrl {
    param([string]$AppName)
    foreach ($k in $global:SwMap.Keys) {
        if ($AppName -like "*$k*" -or $k -like "*$AppName*") { return $global:SwMap[$k].Url }
    }
    return $null
}

function Scan-Apps {
    Write-Log "Đang quét danh sách ứng dụng đã cài..." "INFO"
    $listUn.Items.Clear(); $global:UnTable=@{}
    $regPaths=@(
        @{Hive=[Microsoft.Win32.Registry]::LocalMachine;Path="SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"}
        @{Hive=[Microsoft.Win32.Registry]::LocalMachine;Path="SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"}
        @{Hive=[Microsoft.Win32.Registry]::CurrentUser; Path="SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"}
    )
    foreach ($rp in $regPaths) {
        $key=$rp.Hive.OpenSubKey($rp.Path)
        if (-not $key) { continue }
        foreach ($sub in $key.GetSubKeyNames()) {
            $k=$key.OpenSubKey($sub); if (-not $k) { continue }
            $dn=$k.GetValue("DisplayName"); $un=$k.GetValue("UninstallString")
            $sc=$k.GetValue("SystemComponent"); $rt=$k.GetValue("ReleaseType")
            $pub=$k.GetValue("Publisher"); $ver=$k.GetValue("DisplayVersion")
            $date=$k.GetValue("InstallDate"); $sz=$k.GetValue("EstimatedSize")
            if ($dn -and $un -and ($sc -ne 1) -and ($rt -ne "Update") `
                -and $dn -notmatch "^Microsoft Visual C\+\+" `
                -and $dn -notmatch "^Microsoft \.NET") {
                $name=$dn.ToString().Trim()
                if (-not $global:UnTable.ContainsKey($name)) {
                    $global:UnTable[$name]=@{Un=$un.ToString();Publisher=$pub;Version=$ver;Date=$date;Size=$sz}
                    [void]$listUn.Items.Add($name)
                }
            }
            $k.Close()
        }
        $key.Close()
    }
    $lblUnCount.Text="Tìm thấy $($listUn.Items.Count) ứng dụng"
    Write-Log "Quét xong: $($listUn.Items.Count) ứng dụng." "OK"
}

$txtUnSearch.Add_TextChanged({
    $q=$txtUnSearch.Text.Trim(); $listUn.Items.Clear()
    $global:UnTable.Keys | Where-Object { $_ -like "*$q*" } | Sort-Object | ForEach-Object { [void]$listUn.Items.Add($_) }
})
$listUn.Add_SelectedIndexChanged({
    $n=$listUn.SelectedItem
    if ($n -and $global:UnTable.ContainsKey($n)) {
        $d=$global:UnTable[$n]
        $szMB=if($d.Size){[math]::Round([int]$d.Size/1024,1)}else{"N/A"}
        $url = Find-DownloadUrl -AppName $n
        $urlText = if ($url) { $url } else { "https://www.google.com/search?q=download+$([uri]::EscapeDataString($n))" }
        $txtUnInfo.ForeColor=$C.LogCyan
        $txtUnInfo.Text="TÊN ỨNG DỤNG : $n`nNHÀ PHÁT HÀNH: $($d.Publisher)`nPHIÊN BẢN    : $($d.Version)`nNGÀY CÀI     : $($d.Date)`nDUNG LƯỢNG   : $szMB MB`n`n--------------------------------------------------`nLỆNH GỠ BỎ:`n$($d.Un)`n`n--------------------------------------------------`nLINK TẢI VỀ (nếu cần cài lại):`n$urlText"
    }
})
$btnRescan.Add_Click({ Scan-Apps })
$btnGo.Add_Click({
    $sel=$listUn.CheckedItems
    if ($sel.Count -eq 0) { Write-Log "Chưa chọn ứng dụng nào." "WARN"; return }
    $confirm=[System.Windows.Forms.MessageBox]::Show("Bạn có chắc muốn gỡ bỏ $($sel.Count) ứng dụng đã chọn?","Xác Nhận Gỡ Bỏ","YesNo","Warning")
    if ($confirm -ne "Yes") { return }
    Reset-Progress; Write-Log "BẮT ĐẦU GỠ BỎ $($sel.Count) ỨNG DỤNG" "TITLE"
    $c=0; $ok=0
    foreach ($item in $sel) {
        $c++; Set-Progress $c $sel.Count
        Write-Log "Đang gỡ: ${item}" "INFO"
        $d=$global:UnTable[$item]; if (-not $d) { continue }
        try {
            $un=$d.Un
            if ($un -match '\{[A-Z0-9\-]{36}\}') {
                Start-Process msiexec.exe -ArgumentList "/x $($Matches[0]) /qn /norestart" -Wait -ErrorAction SilentlyContinue
            } elseif ($un -match '^"(.+?)"(.*)$') {
                Start-Process $Matches[1] -ArgumentList "$($Matches[2]) /S /silent /VERYSILENT /qn" -Wait -ErrorAction SilentlyContinue
            } else {
                $parts=$un -split ' ',2
                Start-Process $parts[0] -ArgumentList "$($parts[1]) /S /silent /VERYSILENT /qn" -Wait -ErrorAction SilentlyContinue
            }
            Write-Log "Đã gỡ: ${item}" "OK"; $ok++
        } catch { Write-Log "Lỗi gỡ ${item}: $($_.Exception.Message)" "ERR" }
    }
    Scan-Apps; Set-Progress 100
    Write-Log "GỠ BỎ HOÀN TẤT: $ok/$($sel.Count)" "TITLE"
})
#endregion

# ==============================================================
#  TAB 4 - SAO LƯU DỮ LIỆU
# ==============================================================
#region --- TAB BACKUP ---
$gbBkDest=New-GroupCard "THƯ MỤC SAO LƯU" 5 5 965 65 $C.Orange
$tabBackup.Controls.Add($gbBkDest)
$txtBkPath=New-Object System.Windows.Forms.TextBox
# [SỬA LỖI] Trước đây hardcode "D:\Backup" - lỗi nếu máy không có ổ D. Tự dò ổ ngoài ổ hệ thống, fallback về ổ C.
$defaultBackupDrive = (Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -and $_.DriveType -eq 'Fixed' -and "$($_.DriveLetter):" -ne $env:SystemDrive } | Sort-Object SizeRemaining -Descending | Select-Object -First 1).DriveLetter
$defaultBackupPath = if ($defaultBackupDrive) { "$($defaultBackupDrive):\Backup" } else { "$env:SystemDrive\Backup" }
$txtBkPath.Text=$defaultBackupPath; $txtBkPath.Location=[System.Drawing.Point]::new(10,25); $txtBkPath.Size=[System.Drawing.Size]::new(650,25)
$txtBkPath.BackColor=$C.BgInput; $txtBkPath.ForeColor=$C.Text; $txtBkPath.Font=$F.Body; $txtBkPath.BorderStyle="FixedSingle"
$gbBkDest.Controls.Add($txtBkPath)
$btnBkBrowse=New-StyledButton "Chọn Thư Mục" 670 21 140 28 $C.OrangeDark
$btnBkOpen  =New-StyledButton "Mở Thư Mục"   815 21 140 28 $C.BgCard
$gbBkDest.Controls.AddRange(@($btnBkBrowse,$btnBkOpen))
$btnBkBrowse.Add_Click({ $d=New-Object System.Windows.Forms.FolderBrowserDialog; if($d.ShowDialog()-eq"OK"){$txtBkPath.Text=$d.SelectedPath} })
$btnBkOpen.Add_Click({ if(Test-Path $txtBkPath.Text){Start-Process explorer $txtBkPath.Text} })

# [SỬA LỖI] Kiểm tra ổ đĩa đích tồn tại trước khi backup, tránh lỗi âm thầm (do $ErrorActionPreference SilentlyContinue) khiến người dùng tưởng đã backup xong nhưng thực ra không có gì được ghi
function Test-BackupPathReady {
    param([string]$Path)
    $driveRoot = [System.IO.Path]::GetPathRoot($Path)
    if (-not $driveRoot -or -not (Test-Path $driveRoot)) {
        Write-Log "Ổ đĩa đích '$driveRoot' không tồn tại! Vui lòng chọn lại thư mục sao lưu." "ERR"
        [System.Windows.Forms.MessageBox]::Show("Ổ đĩa đích không tồn tại: $driveRoot`nVui lòng bấm 'Chọn Thư Mục' để chọn lại nơi lưu.","Lỗi Đường Dẫn","OK","Error") | Out-Null
        return $false
    }
    return $true
}

$bkDefs=@(
    @{Text="SAO LƯU DỮ LIỆU NGƯỜI DÙNG`n(Desktop, Documents, Music, Pictures, Videos)"; X=5;   Y=80;  W=475;H=110;Color=$C.Blue}
    @{Text="SAO LƯU TRÌNH ĐIỀU KHIỂN`n(Export All Drivers)";                             X=490; Y=80;  W=480;H=110;Color=$C.Blue}
    @{Text="SAO LƯU REGISTRY HỆ THỐNG`n(Export HKCU và HKLM)";                          X=5;   Y=200; W=475;H=110;Color=$C.Purple}
    @{Text="SAO LƯU DANH SÁCH PHẦN MỀM`n(Export Installed Apps List)";                  X=490; Y=200; W=480;H=110;Color=$C.Green}
    @{Text="SAO LƯU PROFILE MẠNG WI-FI`n(Export Wi-Fi Profiles)";                       X=5;   Y=320; W=475;H=110;Color=$C.Green}
    @{Text="SAO LƯU TOÀN BỘ (ALL-IN-ONE)`n(Full Backup tất cả mục trên)";               X=490; Y=320; W=480;H=110;Color=$C.Orange}
)
$bkBtns=@()
foreach ($a in $bkDefs) {
    $btn=New-StyledButton $a.Text $a.X $a.Y $a.W $a.H $a.Color $C.White
    $btn.TextAlign="MiddleCenter"; $tabBackup.Controls.Add($btn); $bkBtns+=$btn
}
$bkBtns[0].Add_Click({
    if (-not (Test-BackupPathReady $txtBkPath.Text)) { return }
    $root=Join-Path $txtBkPath.Text "User.$(Get-Date -f 'yyyy.MM.dd')"
    New-Item $root -ItemType Directory -Force | Out-Null
    $map=@{Desktop="Desktop";Documents="MyDocuments";Music="MyMusic";Pictures="MyPictures";Videos="MyVideos"}
    $c=0; Reset-Progress; Write-Log "Sao lưu dữ liệu người dùng..." "TITLE"
    foreach ($k in $map.Keys) {
        $c++; Set-Progress $c 5
        $src=[Environment]::GetFolderPath($map[$k])
        if ($src -and (Test-Path $src)) {
            $dst=Join-Path $root $k; New-Item $dst -ItemType Directory -Force | Out-Null
            Copy-Item "$src\*" $dst -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log "$k -> $dst" "OK"
        }
    }
    Set-Progress 100; Write-Log "Backup dữ liệu người dùng hoàn tất: $root" "TITLE"
    [System.Windows.Forms.MessageBox]::Show("Sao lưu hoàn tất!`n$root","Hoàn Tất","OK","Information") | Out-Null
})
$bkBtns[1].Add_Click({
    if (-not (Test-BackupPathReady $txtBkPath.Text)) { return }
    $dst=Join-Path $txtBkPath.Text "Drivers.$(Get-Date -f 'yyyy.MM.dd')"
    New-Item $dst -ItemType Directory -Force | Out-Null
    Reset-Progress; Write-Log "Đang xuất Driver hệ thống..." "INFO"
    try { Export-WindowsDriver -Online -Destination $dst -ErrorAction Stop; Set-Progress 100; Write-Log "Backup Drivers hoàn tất: $dst" "OK" }
    catch { Write-Log "Lỗi xuất Driver: $($_.Exception.Message)" "ERR" }
})
$bkBtns[2].Add_Click({
    if (-not (Test-BackupPathReady $txtBkPath.Text)) { return }
    $dst=Join-Path $txtBkPath.Text "Registry.$(Get-Date -f 'yyyy.MM.dd')"; New-Item $dst -ItemType Directory -Force | Out-Null
    Reset-Progress; Write-Log "Đang xuất Registry..." "INFO"; $c=0
    foreach ($h in @(@{K="HKCU";V="HKCU"},@{K="HKLM";V="HKLM"})) {
        $c++; Set-Progress $c 2
        $out=Join-Path $dst "$($h.K).reg"
        Start-Process "reg.exe" -ArgumentList "export $($h.V) `"$out`" /y" -Wait -WindowStyle Hidden
        Write-Log "Xuất $($h.K) -> $out" "OK"
    }
    Set-Progress 100; Write-Log "Backup Registry hoàn tất." "TITLE"
})
$bkBtns[3].Add_Click({
    if (-not (Test-BackupPathReady $txtBkPath.Text)) { return }
    $out=Join-Path $txtBkPath.Text "AppList.$(Get-Date -f 'yyyy.MM.dd').txt"
    Reset-Progress; Write-Log "Đang tạo danh sách phần mềm..." "INFO"
    winget list 2>$null | Out-File $out -Encoding UTF8
    Set-Progress 100; Write-Log "Danh sách phần mềm -> $out" "OK"
})
$bkBtns[4].Add_Click({
    if (-not (Test-BackupPathReady $txtBkPath.Text)) { return }
    $dst=Join-Path $txtBkPath.Text "WiFi.$(Get-Date -f 'yyyy.MM.dd')"; New-Item $dst -ItemType Directory -Force | Out-Null
    Reset-Progress; Write-Log "Đang xuất Wi-Fi profiles..." "INFO"
    Start-Process "netsh" -ArgumentList "wlan export profile folder=`"$dst`" key=clear" -Wait -WindowStyle Hidden
    Set-Progress 100; Write-Log "Backup Wi-Fi hoàn tất: $dst" "OK"
})
$bkBtns[5].Add_Click({
    $r=[System.Windows.Forms.MessageBox]::Show("Thực hiện tất cả các mục sao lưu?","Xác Nhận","YesNo","Question")
    if ($r -eq "Yes") { 0..4 | ForEach-Object { $bkBtns[$_].PerformClick() } }
})
#endregion

# ==============================================================
#  TAB 5 - KÍCH HOẠT & KIỂM TRA BẢN QUYỀN WINDOWS & OFFICE
# ==============================================================
#region --- TAB LICENSE ---
$gbLic = New-GroupCard "QUẢN LÝ & KÍCH HOẠT BẢN QUYỀN WINDOWS & OFFICE" 5 5 960 435 $C.Purple
$tabLicense.Controls.Add($gbLic)

$lblLicInfo = New-Label "Công cụ kiểm tra tình trạng kích hoạt chi tiết Windows/Office và tích hợp Microsoft Activation Scripts (MAS)." 15 25 930 20 $C.Text $F.Body
$gbLic.Controls.Add($lblLicInfo)

# --- THANH NÚT THAO TÁC PhÍA TRÊN ---
$btnCheckWin = New-StyledButton "KIỂM TRA WINDOWS" 15 50 175 40 $C.Accent $C.Bg $F.Btn
$btnCheckOff = New-StyledButton "KIỂM TRA OFFICE" 200 50 175 40 $C.Green $C.Bg $F.Btn
$btnActWin   = New-StyledButton "KÍCH HOẠT WIN (HWID)" 385 50 180 40 $C.Purple $C.White $F.Btn
$btnActOff   = New-StyledButton "KÍCH HOẠT OFFICE (OHOOK)" 575 50 190 40 $C.PurpleDark $C.White $F.Btn
$btnMAS      = New-StyledButton "MENU MAS (ONLINE)" 775 50 170 40 $C.BgCard $C.Accent $F.Btn

$gbLic.Controls.AddRange(@($btnCheckWin, $btnCheckOff, $btnActWin, $btnActOff, $btnMAS))

# --- KHUNG HIỂN THỊ TRỰC TIẾP PRODUCT KEY ---
$lblWinKeyTitle = New-Label "Windows Key:" 15 100 110 25 $C.Accent $F.Header
$txtWinKey      = New-Object System.Windows.Forms.TextBox
$txtWinKey.Location = [System.Drawing.Point]::new(130, 98)
$txtWinKey.Size = [System.Drawing.Size]::new(815, 25)
$txtWinKey.BackColor = $C.BgInput
$txtWinKey.ForeColor = $C.Accent
$txtWinKey.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$txtWinKey.ReadOnly = $true
$txtWinKey.BorderStyle = "FixedSingle"
$txtWinKey.Text = "Nhấn 'KIỂM TRA WINDOWS' để lấy Product Key..."

$lblOffKeyTitle = New-Label "Office Key:" 15 132 110 25 $C.Green $F.Header
$txtOffKey      = New-Object System.Windows.Forms.TextBox
$txtOffKey.Location = [System.Drawing.Point]::new(130, 130)
$txtOffKey.Size = [System.Drawing.Size]::new(815, 25)
$txtOffKey.BackColor = $C.BgInput
$txtOffKey.ForeColor = $C.Green
$txtOffKey.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$txtOffKey.ReadOnly = $true
$txtOffKey.BorderStyle = "FixedSingle"
$txtOffKey.Text = "Nhấn 'KIỂM TRA OFFICE' để lấy 5 ký tự đuôi Key Office..."

$gbLic.Controls.AddRange(@($lblWinKeyTitle, $txtWinKey, $lblOffKeyTitle, $txtOffKey))

# --- KHUNG HIỂN THỊ KẾT QUẢ KIỂM TRA CHI TIẾT ---
$lblLicResultHeader = New-Label "KẾT QUẢ KIỂM TRA CHI TIẾT BẢN QUYỀN:" 15 163 500 20 $C.Green $F.Header
$gbLic.Controls.Add($lblLicResultHeader)

$txtLicResult = New-Object System.Windows.Forms.RichTextBox
$txtLicResult.Location = [System.Drawing.Point]::new(15, 185)
$txtLicResult.Size = [System.Drawing.Size]::new(930, 235)
$txtLicResult.BackColor = $C.BgInput
$txtLicResult.ForeColor = $C.Green
$txtLicResult.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$txtLicResult.ReadOnly = $true
$txtLicResult.BorderStyle = "None"
$txtLicResult.Text = "Chọn 'KIỂM TRA WINDOWS' hoặc 'KIỂM TRA OFFICE' phía trên để xem chi tiết thông tin bản quyền..."
$gbLic.Controls.Add($txtLicResult)

# ==============================================================
#  1. SỰ KIỆN KIỂM TRA BẢN QUYỀN & LẤY KEY WINDOWS
# ==============================================================
$btnCheckWin.Add_Click({
    $lblLicResultHeader.Text = "KẾT QUẢ KIỂM TRA CHI TIẾT BẢN QUYỀN WINDOWS:"
    $txtLicResult.ForeColor = $C.Text
    $txtLicResult.Text = "Đang truy vấn dữ liệu bản quyền và giải mã Key Windows từ Registry/BIOS... Vui lòng chờ!"
    $txtWinKey.Text = "Đang quét..."
    Write-Log "Đang kiểm tra thông tin bản quyền và Product Key Windows..." "INFO"
    
    $btnCheckWin.Enabled = $false
    $btnCheckOff.Enabled = $false

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $pipeline = $runspace.CreatePipeline({
        # 1. Trích xuất OEM Key từ BIOS/UEFI Firmware
        $oemKey = (Get-CimInstance -Query "SELECT OA3xOriginalProductKey FROM SoftwareLicensingService").OA3xOriginalProductKey
        
        # 2. Trích xuất Installed Product Key từ Registry WMI
        $wmiProduct = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.Name -like "*Windows*" } | Select-Object -First 1
        $partialKey = if ($wmiProduct) { $wmiProduct.PartialProductKey } else { "N/A" }

        # Lấy đầy đủ Key nếu có trong Registry
        $regKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -Name "BackupProductKeyDefault" -ErrorAction SilentlyContinue).BackupProductKeyDefault

        $winKeyDisplay = ""
        if ($oemKey) {
            $winKeyDisplay = "$oemKey (Key OEM từ BIOS)"
        } elseif ($regKey) {
            $winKeyDisplay = "$regKey (Key Cài Đặt)"
        } elseif ($partialKey -ne "N/A") {
            $winKeyDisplay = "XXXXX-XXXXX-XXXXX-XXXXX-$partialKey (5 ký tự cuối)"
        } else {
            $winKeyDisplay = "Không tìm thấy Product Key trong Registry/BIOS"
        }

        # 3. Chạy slmgr.vbs lấy chi tiết
        $dlv = cscript //NoLogo C:\Windows\System32\slmgr.vbs /dlv 2>&1 | Out-String
        
        $statusStr = switch ($wmiProduct.LicenseStatus) {
            1 { "Đã kích hoạt hợp lệ (Licensed)" }
            2 { "Trong thời gian chờ kích hoạt (OOB Grace)" }
            3 { "Hết hạn thử nghiệm (OOT Grace)" }
            4 { "Cần kích hoạt lại (Non-Genuine Grace)" }
            5 { "Thử nghiệm (Notification)" }
            6 { "Thời gian gia hạn (Extended Grace)" }
            default { "Chưa kích hoạt hoặc Không xác định" }
        }

        return @{
            WinKey     = $winKeyDisplay
            StatusText = $statusStr
            DetailText = $dlv
        }
    })

    $asyncResult = $pipeline.BeginInvoke()

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 300
    $timer.Add_Tick({
        if ($asyncResult.IsCompleted) {
            $res = $pipeline.EndInvoke()
            
            # Cập nhật ô Key
            $txtWinKey.Text = $res.WinKey
            
            # Cập nhật kết quả chi tiết
            $txtLicResult.Clear()
            $txtLicResult.SelectionColor = $C.Accent
            $txtLicResult.AppendText("=== TRẠNG THÁI BẢN QUYỀN WINDOWS: $($res.StatusText) ===`n`n")
            $txtLicResult.SelectionColor = $C.Green
            $txtLicResult.AppendText($res.DetailText)
            
            Write-Log "Đã lấy xong thông tin và Key Windows!" "OK"
            
            $btnCheckWin.Enabled = $true
            $btnCheckOff.Enabled = $true
            $timer.Stop()
            $runspace.Close()
            $runspace.Dispose()
        }
    })
    $timer.Start()
})

# ==============================================================
#  2. SỰ KIỆN KIỂM TRA BẢN QUYỀN & LẤY KEY OFFICE
# ==============================================================
$btnCheckOff.Add_Click({
    $lblLicResultHeader.Text = "KẾT QUẢ KIỂM TRA CHI TIẾT BẢN QUYỀN MICROSOFT OFFICE:"
    $txtLicResult.ForeColor = $C.Text
    $txtLicResult.Text = "Đang quét các thư mục cài đặt Microsoft Office và kiểm tra bản quyền (ospp.vbs /dstatus)... Vui lòng chờ!"
    $txtOffKey.Text = "Đang quét..."
    Write-Log "Đang kiểm tra thông tin bản quyền và Product Key Office..." "INFO"

    $btnCheckWin.Enabled = $false
    $btnCheckOff.Enabled = $false

    $runspace = [runspacefactory]::CreateRunspace()
    $runspace.Open()
    $pipeline = $runspace.CreatePipeline({
        $searchPaths = @(
            "${env:ProgramFiles}\Microsoft Office\Office16\OSPP.VBS",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office16\OSPP.VBS",
            "${env:ProgramFiles}\Microsoft Office\Office15\OSPP.VBS",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office15\OSPP.VBS",
            "${env:ProgramFiles}\Microsoft Office\Office14\OSPP.VBS",
            "${env:ProgramFiles(x86)}\Microsoft Office\Office14\OSPP.VBS"
        )

        $osppPath = $null
        foreach ($path in $searchPaths) {
            if (Test-Path $path) {
                $osppPath = $path
                break
            }
        }

        if ($osppPath) {
            $offResult = cscript //NoLogo "$osppPath" /dstatus 2>&1 | Out-String
            
            # Lấy 5 ký tự đuôi của Key Office từ đầu ra ospp.vbs
            $offKeyMatches = [regex]::Matches($offResult, "Last 5 characters of installed product key:\s*([A-Z0-9]{5})")
            $offKeys = @()
            foreach ($match in $offKeyMatches) {
                $offKeys += $match.Groups[1].Value
            }

            $keyDisplay = if ($offKeys.Count -gt 0) {
                "XXXXX-XXXXX-XXXXX-XXXXX-" + ($offKeys -join " | XXXXX-XXXXX-XXXXX-XXXXX-")
            } else {
                "Không tìm thấy partial key Office nào đang kích hoạt"
            }

            return @{
                Success   = $true
                OfficeKey = $keyDisplay
                Detail    = $offResult
            }
        } else {
            return @{
                Success   = $false
                OfficeKey = "Chưa cài đặt Office hoặc không tìm thấy OSPP.VBS"
                Detail    = "Không tìm thấy file 'OSPP.VBS' trên hệ thống!`nKhả năng cao máy tính chưa cài đặt Microsoft Office hoặc đang sử dụng phiên bản Office Web/Click-to-Run dạng rút gọn."
            }
        }
    })

    $asyncResult =$pipeline.BeginInvoke()

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 300$timer.Add_Tick({
        if ($asyncResult.IsCompleted) {
            $res =$pipeline.EndInvoke()
            
            # Cập nhật ô Key Office
            $txtOffKey.Text =$res.OfficeKey
            
            # Cập nhật khung kết quả chi tiết
            $txtLicResult.Clear()
            if ($res.Success) {
                $txtLicResult.SelectionColor =$C.Accent
                $txtLicResult.AppendText("=== THÔNG TIN BẢN QUYỀN OFFICE (OSPP.VBS) ===`n`n")
                $txtLicResult.SelectionColor =$C.Green
                $txtLicResult.AppendText($res.Detail)
                Write-Log "Đã kiểm tra xong thông tin và Key Office!" "OK"
            } else {
                $txtLicResult.SelectionColor = [System.Drawing.Color]::Red$txtLicResult.AppendText("=== KHÔNG TÌM THẤY MICROSOFT OFFICE ===`n`n")
                $txtLicResult.SelectionColor =$C.Text
                $txtLicResult.AppendText($res.Detail)
                Write-Log "Không tìm thấy dữ liệu bản quyền Office!" "WARN"
            }

            $btnCheckWin.Enabled = $true$btnCheckOff.Enabled = $true$timer.Stop()
            $runspace.Close()$runspace.Dispose()
        }
    })
    $timer.Start()
})

# ==============================================================
#  3. CÁC NÚT KÍCH HOẠT BẢN QUYỀN MÁY TÍNH (MAS)
# ==============================================================
$btnActWin.Add_Click({
    Write-Log "Đang mở kịch bản kích hoạt Digital License Windows qua MAS..." "INFO"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`""
})

$btnActOff.Add_Click({
    Write-Log "Đang mở kịch bản kích hoạt Office (Ohook) qua MAS..." "INFO"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`""
})

$btnMAS.Add_Click({
    Write-Log "Đang kích hoạt Menu tổng MAS (Microsoft Activation Scripts)..." "INFO"
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`""
})
#endregion
# ==============================================================
#  TAB 6 - THÔNG TIN ỨNG DỤNG
# ==============================================================
#region --- TAB ABOUT ---
$gbAbout=New-GroupCard "THÔNG TIN CÔNG CỤ" 5 5 965 435 $C.Accent
$tabAbout.Controls.Add($gbAbout)
$txtAbout=New-Object System.Windows.Forms.RichTextBox
$txtAbout.Location=[System.Drawing.Point]::new(10,25); $txtAbout.Size=[System.Drawing.Size]::new(945,350)
$txtAbout.BackColor=$C.BgInput; $txtAbout.ForeColor=$C.Text; $txtAbout.Font=$F.Mono; $txtAbout.ReadOnly=$true; $txtAbout.BorderStyle="None"
$txtAbout.Text="  ================================================================================`n        WIN TOOLS PRO - BỘ CÔNG CỤ TỐI ƯU WINDOWS CHUYÊN NGHIỆP`n  ================================================================================`n`n  Phát triển bởi : Mr Hạnh`n  Điện thoại     : 0938.608.602`n  Website        : https://khanggiaphuc.com/win`n  Phiên bản      : $($Global:AppVersion) Pro Edition`n`n  ================================================================================`n  TÍNH NĂNG CHÍNH`n  ================================================================================`n`n  [1] Tùy Chỉnh & Sửa Chữa    - 25 tweak, Restore Point an toàn, Lưu/Tải cấu hình`n  [2] Cài Đặt (20 phần mềm)   - Cài ngầm qua Winget, bảng thông tin real-time`n  [3] Gỡ Bỏ                   - Quét ứng dụng Win32, tìm kiếm và thông tin chi tiết`n  [4] Sao Lưu (6 loại)        - Backup User/Driver/Registry/WiFi/AppList/All-in-One`n  [5] Bản Quyền               - Genuine Detector chuyên sâu Windows & Office, quản lý Key`n  [6] Nâng cấp $($Global:AppVersion) - Restore Point, Cancel job, chống treo, sửa lỗi bloatware,`n                        Reset mạng, Tắt Hibernate, Dọn WinSxS, Xuất Log ra file"
$gbAbout.Controls.Add($txtAbout)
$btnWebsite=New-StyledButton "Mở Website" 10 388 200 34 $C.BlueDark
$btnCopyLog=New-StyledButton "Sao Chép Log" 220 388 200 34 $C.BgCard $C.TextDim
$btnExportLog=New-StyledButton "Xuất Log Ra File" 430 388 200 34 $C.BgCard $C.TextDim
$gbAbout.Controls.AddRange(@($btnWebsite,$btnCopyLog,$btnExportLog))
$btnWebsite.Add_Click({ Start-Process "https://khanggiaphuc.com/win" })
$btnExportLog.Add_Click({
    if ($global:LogLines.Count -eq 0) { Write-Log "Chưa có log để xuất." "WARN"; return }
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Text File (*.txt)|*.txt"; $sfd.FileName = "WinTools_Log_$(Get-Date -f 'yyyyMMdd_HHmmss').txt"
    if ($sfd.ShowDialog() -eq "OK") {
        $global:LogLines -join "`r`n" | Out-File $sfd.FileName -Encoding UTF8
        Write-Log "Đã xuất log ra: $($sfd.FileName)" "OK"
    }
})
$btnCopyLog.Add_Click({
    if ($global:LogLines.Count -gt 0) {
        [System.Windows.Forms.Clipboard]::SetText($global:LogLines -join "`r`n")
        Write-Log "Đã sao chép $($global:LogLines.Count) dòng log." "OK"
    }
})
#endregion

# ==============================================================
#  KHỞI ĐỘNG
# ==============================================================
$form.Add_Shown({
    $form.Refresh()
    # [NÂNG CẤP GIAO DIỆN] Chủ động ẩn nút cuộn trái-phải (Up-Down control) mà WinForms tự sinh
    # khi các tab bị tràn khung, để hàng menu luôn gọn gàng không có nút điều hướng thừa
    try {
        $updown = [WinApi]::FindWindowEx($tabCtrl.Handle, [IntPtr]::Zero, "msctls_updown32", $null)
        if ($updown -ne [IntPtr]::Zero) { [void][WinApi]::ShowWindow($updown, 0) }
    } catch {}
        function Get-SystemSummary {
        try {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cpu = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim()
        $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB)
        $ramFree  = [math]::Round($os.FreePhysicalMemory / 1MB,1)
        $text = "$($os.Caption) | $cpu | RAM: $ramFree/$ramTotal GB"
        $volumes = Get-Volume | Where-Object {$_.DriveLetter -and $_.DriveType -eq 'Fixed'}
        $partitions = Get-Partition
        $disks      = Get-Disk
        $physical   = Get-PhysicalDisk
        $diskType = @{}
        foreach ($d in $disks) {$p = $physical | Where-Object {$d.FriendlyName.StartsWith($_.FriendlyName) -or
                $_.FriendlyName.StartsWith($d.FriendlyName)} | Select-Object -First 1
            if ($p) {$diskType[$d.Number] = "$($p.BusType)-$($p.MediaType)"}
            else {$diskType[$d.Number] = $d.BusType}}
        foreach ($v in $volumes | Sort-Object DriveLetter) {$part = $partitions | Where-Object DriveLetter -eq $v.DriveLetter
            if (-not $part) { continue }
            $used  = [math]::Round(($v.Size - $v.SizeRemaining)/1GB)
            $total = [math]::Round($v.Size/1GB)
            $type = $diskType[$part.DiskNumber]
            $text += " | $($v.DriveLetter): $used/$total GB $type"}
        return $text}
    catch {return "Không lấy được thông tin hệ thống."}}
$lblSys.Text = Get-SystemSummary
    Scan-Apps
    Write-Log "WIN TOOLS Pro $($Global:AppVersion) khởi động thành công" "TITLE"
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $wv=(winget --version 2>$null)
        $lblWingetCheck.Text="Winget $wv sẵn sàng."
        $lblWingetCheck.ForeColor=$C.LogGreen
    } else {
        $lblWingetCheck.Text="Winget chưa cài! Vào Microsoft Store cài App Installer."
        $lblWingetCheck.ForeColor=$C.LogRed
    }
})

$form.Add_FormClosing({
    param($s,$e)
    if ($global:ActiveJob -or $asyncTimer.Enabled) {
        $r = [System.Windows.Forms.MessageBox]::Show("Đang có tiến trình tùy chỉnh chạy dở! Thoát ngay có thể khiến hệ thống ở trạng thái không nhất quán. Bạn có chắc muốn thoát?","Cảnh báo",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Warning)
        if ($r -eq [System.Windows.Forms.DialogResult]::No) { $e.Cancel = $true; return }
        if ($global:ActiveJob) { Stop-Job -Job $global:ActiveJob -ErrorAction SilentlyContinue; Remove-Job -Job $global:ActiveJob -Force -ErrorAction SilentlyContinue }
    }
})

[void]$form.ShowDialog()
$form.Dispose()
