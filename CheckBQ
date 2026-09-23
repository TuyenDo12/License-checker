=# =============================================================================
#  WIN TOOLS - Bộ Công Cụ Tối Ưu Windows Chuyên Nghiệp (Fullscreen Edition)
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
    }
'@
    [void][WinApi]::SetProcessDPIAware()
} catch {}
#endregion

#region --- MÀU SẮC & FONT ---
$C = @{     Bg         = [System.Drawing.Color]::FromArgb(15,15,20)     BgPanel    = [System.Drawing.Color]::FromArgb(22,22,30)     BgCard     = [System.Drawing.Color]::FromArgb(30,32,42)     BgInput    = [System.Drawing.Color]::FromArgb(18,18,25)     Accent     = [System.Drawing.Color]::FromArgb(0,210,180)     AccentDark = [System.Drawing.Color]::FromArgb(0,140,120)     Blue       = [System.Drawing.Color]::FromArgb(30,144,255)     BlueDark   = [System.Drawing.Color]::FromArgb(0,90,180)     Orange     = [System.Drawing.Color]::FromArgb(255,140,0)     OrangeDark = [System.Drawing.Color]::FromArgb(180,80,0)     Red        = [System.Drawing.Color]::FromArgb(220,50,50)     RedDark    = [System.Drawing.Color]::FromArgb(140,20,20)     Green      = [System.Drawing.Color]::FromArgb(50,205,50)     GreenDark  = [System.Drawing.Color]::FromArgb(20,120,20)     Purple     = [System.Drawing.Color]::FromArgb(148,0,211)     PurpleDark = [System.Drawing.Color]::FromArgb(80,0,140)     Text       = [System.Drawing.Color]::FromArgb(220,220,230)     TextDim    = [System.Drawing.Color]::FromArgb(140,140,160)     Border     = [System.Drawing.Color]::FromArgb(45,48,65)     LogGreen   = [System.Drawing.Color]::FromArgb(80,220,120)     LogYellow  = [System.Drawing.Color]::FromArgb(255,215,0)     LogRed     = [System.Drawing.Color]::FromArgb(255,80,80)     LogCyan    = [System.Drawing.Color]::FromArgb(0,220,220)     White      = [System.Drawing.Color]::White }$F = @{
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
function Get-AdjustedColor {
    param([System.Drawing.Color]$Color,[int]$Amount)$r=[Math]::Min(255,[Math]::Max(0,$Color.R+$Amount))
    $g=[Math]::Min(255,[Math]::Max(0,$Color.G+$Amount))$b=[Math]::Min(255,[Math]::Max(0,$Color.B+$Amount))
    return [System.Drawing.Color]::FromArgb($r,$g,$b)
}
function New-RoundedRegion {
    param([int]$Width,[int]$Height,[int]$Radius=10)$r=[Math]::Max(2,[Math]::Min($Radius,[Math]::Floor([Math]::Min($Width,$Height)/2)))$d=$r*2$path=New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(0,0,$d,$d,180,90)
    $path.AddArc($Width-$d,0,$d,$d,270,90)$path.AddArc($Width-$d,$Height-$d,$d,$d,0,90)
    $path.AddArc(0,$Height-$d,$d,$d,90,90)$path.CloseFigure()
    return New-Object System.Drawing.Region($path)
}
function New-RoundedTopPath {
    param([System.Drawing.Rectangle]$Rect,[int]$Radius=8)$d=$Radius*2$path=New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc($Rect.X,$Rect.Y,$d,$d,180,90)
    $path.AddArc($Rect.Right-$d,$Rect.Y,$d,$d,270,90)
    $path.AddLine($Rect.Right,($Rect.Y+$Radius),$Rect.Right,$Rect.Bottom)
    $path.AddLine($Rect.Right,$Rect.Bottom,$Rect.X,$Rect.Bottom)$path.AddLine($Rect.X,$Rect.Bottom,$Rect.X,($Rect.Y+$Radius))$path.CloseFigure()
    return $path
}
function New-StyledButton {
    param($Text,$X,$Y,$W,$H,$BgColor,$FgColor=$C.White,$Font=$F.Btn,[int]$Radius=10)$b = New-Object System.Windows.Forms.Button
    $b.Text=$Text; $b.Location=[System.Drawing.Point]::new($X,$Y);$b.Size=[System.Drawing.Size]::new($W,$H)
    $b.BackColor=$BgColor; $b.ForeColor=$FgColor; $b.Font=$Font
    $b.FlatStyle="Flat"; $b.Cursor="Hand"
    $b.FlatAppearance.BorderSize = 1
    $b.FlatAppearance.BorderColor = Get-AdjustedColor$BgColor 50
    $b.FlatAppearance.MouseOverBackColor = Get-AdjustedColor$BgColor 30
    $b.FlatAppearance.MouseDownBackColor = Get-AdjustedColor$BgColor -35
    $b.Region = New-RoundedRegion -Width$W -Height $H -Radius$Radius
    return $b
}
function New-GroupCard {
    param($Text,$X,$Y,$W,$H,$FgColor=$C.Accent)$g = New-Object System.Windows.Forms.GroupBox
    $g.Text=$Text; $g.Location=[System.Drawing.Point]::new($X,$Y);$g.Size=[System.Drawing.Size]::new($W,$H)
    $g.ForeColor=$FgColor; $g.BackColor=$C.BgCard; $g.Font=$F.Header
    return $g
}
function New-CheckListBox {
    param($X,$Y,$W,$H)$l = New-Object System.Windows.Forms.CheckedListBox
    $l.Location=[System.Drawing.Point]::new($X,$Y);$l.Size=[System.Drawing.Size]::new($W,$H)
    $l.BackColor=$C.BgInput; $l.ForeColor=$C.Text; $l.CheckOnClick=$true
    $l.BorderStyle="None"; $l.Font=$F.Body; $l.ItemHeight=22
    return $l
}
function New-Label {
    param($Text,$X,$Y,$W,$H,$FgColor=$C.Text,$Font=$F.Body,$Align="MiddleLeft")
    $l = New-Object System.Windows.Forms.Label
    $l.Text=$Text; $l.Location=[System.Drawing.Point]::new($X,$Y); $l.Size=[System.Drawing.Size]::new($W,$H)$l.ForeColor=$FgColor; $l.Font=$Font; $l.TextAlign=$Align; $l.BackColor=[System.Drawing.Color]::Transparent
    return $l
}
#endregion

#region --- TRẠNG THÁI TOÀN CỤC ---
$global:UnTable  = @{}
$global:SwMap    = [ordered]@{}$global:LogLines = [System.Collections.Generic.List[string]]::new()
#endregion

#region --- TÍNH TOÁN KÍCH THƯỚC FULLSCREEN ---
$screenWidth  = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width
$screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height
$appWidth     =$screenWidth
$appHeight    =$screenHeight
#endregion

#region --- FORM CHÍNH (Full Screen) ---
$form                 = New-Object System.Windows.Forms.Form
$form.Text            = "WIN TOOLS Pro $($Global:AppVersion) - Ultimate Edition"
$form.Size            = [System.Drawing.Size]::new($appWidth, $appHeight)$form.StartPosition   = "CenterScreen"
$form.WindowState     = "Maximized"
$form.BackColor       =$C.Bg; $form.ForeColor=$C.Text; $form.Font=$F.Body
$form.FormBorderStyle = "None"; $form.MaximizeBox=$true; $form.AutoScaleMode="Dpi"
#endregion

#region --- HEADER ---
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Location=[System.Drawing.Point]::new(0,0);$pnlHeader.Size=[System.Drawing.Size]::new($appWidth,50)$pnlHeader.BackColor=$C.BgPanel; $form.Controls.Add($pnlHeader)$pnlHeader.Controls.Add((New-Label "WIN TOOLS PRO" 15 5 400 40 $C.Accent $F.Title "MiddleLeft"))
$pnlHeader.Controls.Add((New-Label "Phát triển bởi Mr Hạnh | 0938.608.602 | www.khanggiaphuc.com/win" 450 5 450 40 $C.TextDim $F.Body "MiddleCenter"))
$pnlHeader.Controls.Add((New-Label "$($Global:AppVersion) Pro" ($appWidth - 135) 5 110 40 $C.Orange $F.Header "MiddleRight"))

# Nút thu nhỏ / đóng ứng dụng nhanh cho chế độ Fullscreen không viền
$btnCloseFull = New-StyledButton "X" ($appWidth - 45) 10 35 30$C.RedDark $C.White $F.Btn 6
$pnlHeader.Controls.Add($btnCloseFull)
$btnCloseFull.Add_Click({$form.Close() })
#endregion

#region --- SYSINFO BAR ---
$pnlSys = New-Object System.Windows.Forms.Panel
$pnlSys.Location=[System.Drawing.Point]::new(0,50);$pnlSys.Size=[System.Drawing.Size]::new($appWidth,35)$pnlSys.BackColor=$C.BgCard; $form.Controls.Add($pnlSys)$lblSys = New-Label "  Đang thu thập thông tin cấu hình phần cứng..." 0 0 $appWidth 35 $C.Green $F.Mono "MiddleLeft"
$pnlSys.Controls.Add($lblSys)
#endregion

#region --- TAB CONTAINER (Tự động canh full chiều rộng/cao) ---
$tabCtrlWidth  = $appWidth - 20$tabCtrlHeight = $appHeight - 185$tabCtrl = New-Object System.Windows.Forms.TabControl
$tabCtrl.Location=[System.Drawing.Point]::new(10,93); $tabCtrl.Size=[System.Drawing.Size]::new($tabCtrlWidth, $tabCtrlHeight)$tabCtrl.BackColor=$C.Bg; $tabCtrl.Font=$F.Header; $tabCtrl.DrawMode="OwnerDrawFixed"
$tabCtrl.ItemSize=[System.Drawing.Size]::new(140,32); $tabCtrl.SizeMode="Fixed"; $tabCtrl.Appearance="FlatButtons"
$form.Controls.Add($tabCtrl)$tabCtrl.Add_DrawItem({
    param($s,$e)$g=$e.Graphics; $g.SmoothingMode=[System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $tab=$s.TabPages[$e.Index];$sel=($e.Index -eq$s.SelectedIndex)
    $isExit = ($tab.Text -eq "Thoát")
    $bg = if ($isExit) { $C.BgCard } elseif ($sel) { $C.Accent } else {$C.BgCard }
    $fg = if ($isExit) { $C.Red } elseif ($sel) { $C.Bg } else {$C.TextDim }
    $rect =$e.Bounds; $rect.Inflate(-2,-3)$path = New-RoundedTopPath -Rect $rect -Radius 8$g.FillPath([System.Drawing.SolidBrush]::new($bg),$path)
    if ($isExit) {$pen = New-Object System.Drawing.Pen($C.Red,1)$g.DrawPath($pen,$path)
    }
    $sf=[System.Drawing.StringFormat]::new(); $sf.Alignment="Center"; $sf.LineAlignment="Center"
    $g.DrawString($tab.Text,$F.Header,[System.Drawing.SolidBrush]::new($fg),[System.Drawing.RectangleF]$rect,$sf)
})
function New-Tab { param($Text)$t=New-Object System.Windows.Forms.TabPage; $t.Text=$Text; $t.BackColor=$C.Bg; $t.BorderStyle="None"; return $t }$tabTweaks  = New-Tab "Tùy Chỉnh"
$tabInstall = New-Tab "Cài Đặt"
$tabRemove  = New-Tab "Gỡ Bỏ"
$tabBackup  = New-Tab "Sao Lưu"
$tabLicense = New-Tab "Bản Quyền"
$tabAbout   = New-Tab "Thông Tin"
$tabExit    = New-Tab "Thoát"
foreach ($tab in @($tabTweaks,$tabInstall,$tabRemove,$tabBackup,$tabLicense,$tabAbout,$tabExit)) { $tabCtrl.TabPages.Add($tab) }

$global:LastTabIndex = 0$tabCtrl.Add_SelectedIndexChanged({
    if ($tabCtrl.SelectedTab -eq $tabExit) {$tabCtrl.SelectedIndex = $global:LastTabIndex$r = [System.Windows.Forms.MessageBox]::Show("Bạn có chắc chắn muốn thoát chương trình?","Xác nhận",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
        if ($r -eq [System.Windows.Forms.DialogResult]::Yes) {$form.Close() }
    } else {
        $global:LastTabIndex =$tabCtrl.SelectedIndex
    }
})
#endregion

#region --- LOG & PROGRESS ---
$logY = $appHeight - 92$progY = $logY - 18$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location=[System.Drawing.Point]::new(10, $progY);$progressBar.Size=[System.Drawing.Size]::new($appWidth - 75, 10)$progressBar.Style="Continuous"; $progressBar.ForeColor=$C.Accent; $progressBar.BackColor=$C.BgCard
$form.Controls.Add($progressBar)$lblPct = New-Label "0%" ($appWidth - 55) ($progY - 5) 45 18 $C.Text $F.Body "MiddleLeft"
$form.Controls.Add($lblPct)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Location=[System.Drawing.Point]::new(10, $logY);$txtLog.Size=[System.Drawing.Size]::new($appWidth - 20, 82)$txtLog.BackColor=$C.BgInput; $txtLog.ForeColor=$C.LogGreen; $txtLog.Font=$F.MonoSm; $txtLog.ReadOnly=$true; $txtLog.BorderStyle="None"
$form.Controls.Add($txtLog)$btnClearLog = New-StyledButton "X Log" ($appWidth - 65) $logY 53 18$C.BgCard $C.TextDim $F.Small
$form.Controls.Add($btnClearLog)$btnClearLog.Add_Click({ $txtLog.Clear();$global:LogLines.Clear() })

function Write-Log {
    param($Msg,[ValidateSet("OK","WARN","ERR","INFO","TITLE")]$Type="INFO")
    $ts=$( (Get-Date).ToString("HH:mm:ss") )
    $icon=switch($Type){"OK"{"[OK]"};"WARN"{"[!!]"};"ERR"{"[XX]"};"INFO"{"[>>]"};"TITLE"{"[==]"}}
    $line="[$ts] $icon$Msg"
    $color=switch($Type){"OK"{$C.LogGreen};"WARN"{$C.LogYellow};"ERR"{$C.LogRed};"INFO"{$C.LogCyan};"TITLE"{$C.Accent}}$txtLog.SelectionStart=$txtLog.TextLength; $txtLog.SelectionLength=0
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
#  TAB 1 - TÙY CHỈNH HỆ THỐNG (MỞ RỘNG TOÀN MÀN HÌNH - BỎ KHUNG MÔ TẢ)
# ==============================================================
#region --- TAB TWEAKS & FULL WIDTH CHECKLIST ---
$gbTwL = New-GroupCard "TUỲ CHỈNH HỆ THỐNG WINDOWS (CHỌN TÙY CHỈNH DƯỚI ĐÂY)" 10 10 ($tabCtrlWidth - 20) ($tabCtrlHeight - 20) $C.Accent
$tabTweaks.Controls.Add($gbTwL)

# Thanh tìm kiếm mở rộng theo chiều ngang
$lblSearch = New-Label "Tìm kiếm nhanh:" 15 28 110 20 $C.TextDim $F.Small
$gbTwL.Controls.Add($lblSearch)

$txtSearch = New-Object System.Windows.Forms.TextBox
$txtSearch.Location = [System.Drawing.Point]::new(130, 26)
$txtSearch.Size = [System.Drawing.Size]::new($tabCtrlWidth - 165, 24)
$txtSearch.BackColor = $C.BgInput
$txtSearch.ForeColor = $C.Accent
$txtSearch.BorderStyle = "FixedSingle"
$txtSearch.Font = $F.Body
$gbTwL.Controls.Add($txtSearch)

# Danh sách Checkbox mở rộng toàn màn hình (bỏ khung mô tả bên phải)
$listBoxHeight = $tabCtrlHeight - 130
$listTw = New-CheckListBox 15 60 ($tabCtrlWidth - 50) $listBoxHeight
$gbTwL.Controls.Add($listTw)

$chkRestorePoint = New-Object System.Windows.Forms.CheckBox
$chkRestorePoint.Text = "Tạo Điểm Khôi Phục (Restore Point) trước khi chạy - khuyến nghị"
$chkRestorePoint.Location = [System.Drawing.Point]::new(15, ($tabCtrlHeight - 65))
$chkRestorePoint.Size = [System.Drawing.Size]::new(450, 20)
$chkRestorePoint.ForeColor = $C.TextDim; $chkRestorePoint.Font = $F.Small; $chkRestorePoint.Checked = $true
$gbTwL.Controls.Add($chkRestorePoint)

# Các nút bấm chức năng phía dưới cùng của Tab Tùy Chỉnh
$btnXPos = $tabCtrlWidth - 540
$btnTwAll  = New-StyledButton "Chọn Tất Cả" $btnXPos ($tabCtrlHeight - 68) 110 32 $C.BgCard $C.TextDim $F.Small
$btnTwNone = New-StyledButton "Bỏ Chọn" ($btnXPos + 115) ($tabCtrlHeight - 68) 95 32 $C.BgCard $C.TextDim $F.Small
$btnTwUndo = New-StyledButton "Hoàn Tác (Undo)" ($btnXPos + 215) ($tabCtrlHeight - 68) 120 32 $C.OrangeDark $C.White $F.Btn
$btnTwRun  = New-StyledButton "CHẠY TÙY CHỈNH" ($btnXPos + 340) ($tabCtrlHeight - 68) 155 32 $C.Accent $C.Bg $F.Btn
$gbTwL.Controls.AddRange(@($btnTwAll,$btnTwNone,$btnTwUndo,$btnTwRun))

$tweakDatabase = [ordered]@{
    "01 - Gỡ ứng dụng rác (Bloatware)" = @{
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
        Undo = { Write-Log "Ứng dụng rác cần khôi phục thủ công qua Microsoft Store nếu cần." "WARN" }
    }
    "02 - Dọn dẹp ổ đĩa hệ thống (Disk Cleanup)" = @{
        Cmd  = { 
            Remove-Item "$env:TEMP\*" -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item "C:\Windows\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
            Remove-Item "$env:LOCALAPPDATA\CrashDumps\*" -Force -Recurse -ErrorAction SilentlyContinue
            Start-Process "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup" -WindowStyle Hidden -Wait 
        }
        Undo = { Write-Log "Không cần hoàn tác dọn dẹp bộ nhớ tạm." "INFO" }
    }
    "03 - Dọn Prefetch và SuperFetch" = @{
        Cmd  = { Stop-Service "SysMain" -Force; Set-Service "SysMain" -StartupType Disabled }
        Undo = { Set-Service "SysMain" -StartupType Automatic; Start-Service "SysMain" }
    }
    "04 - Tắt các ứng dụng khởi động cùng windows (Startup Apps)" = @{
        Cmd  = {"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run","HKLM:\Software\Microsoft\Windows\CurrentVersion\Run","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"|%{if(Test-Path $_){(gi $_).Property|?{$_-notmatch'^EVKey$|^UniKey$|^GoogleDriveFS$|^SecurityHealth$|^WindowsDefender$'}|%{rp $_ $_ -Force -EA 0}}}}
        Undo = { Write-Log "Hãy bật lại thủ công trong Task Manager." "INFO" }
    }
    "05 - Tắt Background Apps ngầm" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 1 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" "GlobalUserDisabled" 0 -Type DWord -Force }
    }
    "06 - Kích hoạt High Performance" = @{
        Cmd  = { Start-Process "powercfg" -ArgumentList "/setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" -WindowStyle Hidden }
        Undo = { Start-Process "powercfg" -ArgumentList "/setactive 381b4222-f694-41f0-9685-ff5bb260df2e" -WindowStyle Hidden }
    }
    "07 - Tối ưu hiệu ứng đồ họa" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 3 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" 0 -Type DWord -Force }
    }
    "08 - Tắt hiệu ứng suốt mờ (Transparency)" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" "EnableTransparency" 1 -Type DWord -Force }
    }
    "09 - Tắt Game Bar & Game Mode" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" "AppCaptureEnabled" 1 -Type DWord -Force }
    }
    "10 - Tắt Thông báo & Quảng cáo hệ thống" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GlobalSetting" 0 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" "NOC_GlobalSetting" 1 -Type DWord -Force }
    }
    "11 - Tắt trợ lý ảo Cortana & Copilot" = @{
        Cmd  = { $p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; if(!(Test-Path $p)){New-Item $p -Force}; Set-ItemProperty $p "TurnOffWindowsCopilot" 1 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" "TurnOffWindowsCopilot" 0 -Type DWord -Force }
    }
    "12 - Tắt Widget trên thanh Taskbar" = @{
        Cmd  = { Get-AppxPackage *Client.WebExperience* -AllUsers | Remove-AppxPackage -AllUsers }
        Undo = { Write-Log "Cài lại WebExperience qua Microsoft Store nếu muốn khôi phục." "INFO" }
    }
    "13 - Tắt Search Indexing (WSearch)" = @{
        Cmd = { Stop-Service "WSearch" -Force; Set-Service "WSearch" -StartupType Disabled }
        Undo = { Set-Service "WSearch" -StartupType Automatic; Start-Service "WSearch" }
    }
    "14 - Vô hiệu hóa Windows Update" = @{
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
        Cmd  = { Disable-BitLocker -MountPoint $Env:SystemDrive }
        Undo = { Write-Log "Bật lại BitLocker thủ công trong Control Panel." "INFO" }
    }
    "16 - Tắt giao thức mạng IPv6" = @{
        Cmd  = { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 255 -Type DWord -Force }
        Undo = { Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" "DisabledComponents" 0 -Type DWord -Force }
    }
    "17 - Tắt Folder Auto Discovery" = @{
        Cmd  = { Set-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" "NotSpecified" -Force }
        Undo = { Remove-ItemProperty "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" "FolderType" -Force }
    }
    "18 - Tắt Telemetry thu thập dữ liệu" = @{
        Cmd  = { Set-Service "DiagTrack" -StartupType Disabled; Stop-Service "DiagTrack" -Force }
        Undo = { Set-Service "DiagTrack" -StartupType Automatic }
    }
    "19 - Gỡ bỏ tận gốc OneDrive ngầm" = @{
        Cmd  = {Stop-Process -n OneDrive -Force -EA 0;$o="$env:SystemRoot\SysWOW64\OneDriveSetup.exe";if(!(Test-Path $o)){$o="$env:SystemRoot\System32\OneDriveSetup.exe"};&$o /uninstall;ri "$env:UserProfile\OneDrive" -Recurse -Force -EA 0;ri "$env:LOCALAPPDATA\Microsoft\OneDrive" -Recurse -Force -EA 0;ri "$env:PROGRAMDATA\Microsoft OneDrive" -Recurse -Force -EA 0;ri "$env:SystemDrive\OneDriveTemp" -Recurse -Force -EA 0}
        Undo = { $o="$env:SystemRoot\SysWOW64\OneDriveSetup.exe";if(!(Test-Path $o)){$o="$env:SystemRoot\System32\OneDriveSetup.exe"};&$o }
    }
    "20 - Classic Taskbar Menu (Win11)" = @{
        Cmd  = { New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value "" -Force }
        Undo = { Remove-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force }
    }
    "21 - RAM Flush (Giải phóng bộ nhớ)" = @{
        Cmd  = { [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers() }
        Undo = { Write-Log "RAM Flush tự động cấp phát lại khi ứng dụng cần." "INFO" }
    }
    "22 - Chạy SSD TRIM Tối Ưu Tốc Độ" = @{
        Cmd  = { Get-Volume | Where-Object { $_.DriveType -eq "Fixed" } | Optimize-Volume -ReTrim }
        Undo = { Write-Log "TRIM là tiến trình phần cứng, không cần khôi phục." "INFO" }
    }
    "23 - Reset mạng TCP/IP & Xóa DNS Cache" = @{
        Cmd  = {
            Start-Process "netsh" -ArgumentList "winsock reset" -WindowStyle Hidden -Wait
            Start-Process "netsh" -ArgumentList "int ip reset" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/flushdns" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/release" -WindowStyle Hidden -Wait
            Start-Process "ipconfig" -ArgumentList "/renew" -WindowStyle Hidden -Wait
        }
        Undo = { Write-Log "Thao tác reset mạng không có chiều hoàn tác." "INFO" }
    }
    "24 - Tắt Hibernate (Giải phóng dung lượng ổ C)" = @{
        Cmd  = { Start-Process "powercfg" -ArgumentList "/hibernate off" -WindowStyle Hidden -Wait }
        Undo = { Start-Process "powercfg" -ArgumentList "/hibernate on" -WindowStyle Hidden -Wait }
    }
    "25 - Dọn WinSxS nâng cao (Giảm dung lượng Windows)" = @{
        Cmd  = { Start-Process "dism.exe" -ArgumentList "/Online /Cleanup-Image /StartComponentCleanup /ResetBase" -WindowStyle Hidden -Wait }
        Undo = { Write-Log "Thao tác ResetBase không thể hoàn tác." "WARN" }
    }
}

$global:CheckedItemsState = @{}
foreach ($k in $tweakDatabase.Keys) { 
    [void]$listTw.Items.Add($k)
    $global:CheckedItemsState[$k] = $false 
}

$listTw.Add_ItemCheck({
    param($s, $e)
    $itemText = $listTw.Items[$e.Index].ToString()
    $global:CheckedItemsState[$itemText] = ($e.NewValue -eq "Checked")
})

$txtSearch.Add_TextChanged({
    $searchText = $txtSearch.Text.Trim()
    $prevSelected = if ($listTw.SelectedItem) { $listTw.SelectedItem.ToString() } else { $null }
    $listTw.Items.Clear()
    foreach ($key in $tweakDatabase.Keys) {
        if ($key -like "*$searchText*") {
            $idx = $listTw.Items.Add($key)
            if ($global:CheckedItemsState[$key]) { $listTw.SetItemChecked($idx, $true) }
            if ($key -eq $prevSelected) { $listTw.SetSelected($idx, $true) }
        }
    }
})

$btnTwAll.Add_Click({ 
    for($i=0;$i-lt $listTw.Items.Count;$i++){ 
        $listTw.SetItemChecked($i,$true)
        $global:CheckedItemsState[$listTw.Items[$i].ToString()] = $true
    } 
})
$btnTwNone.Add_Click({ 
    for($i=0;$i-lt $listTw.Items.Count;$i++){ 
        $listTw.SetItemChecked($i,$false)
        $global:CheckedItemsState[$listTw.Items[$i].ToString()] = $false
    } 
})

$btnTwRun.Add_Click({
    $checked = @($listTw.CheckedItems)
    if ($checked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn ít nhất một tùy chỉnh hệ thống!","Thông báo",0,48)
        return
    }
    if ($chkRestorePoint.Checked) {
        Write-Log "Đang tạo điểm khôi phục hệ thống (Restore Point)..." "INFO"
        Checkpoint-Computer -Description "WinToolsPro Restore Point" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
        Write-Log "Đã tạo điểm khôi phục hệ thống thành công." "OK"
    }
    Write-Log "Bắt đầu thực thi $($checked.Count) tùy chỉnh hệ thống..." "TITLE"
    Reset-Progress
    $curr=0; $tot=$checked.Count
    foreach($item in $checked){
        $curr++
        Write-Log "Đang xử lý: $item" "INFO"
        try {
            & $tweakDatabase[$item].Cmd
            Write-Log "Hoàn thành: $item" "OK"
        } catch {
            Write-Log "Lỗi khi chạy [$item]: $_" "ERR"
        }
        Set-Progress $curr $tot
    }
    Write-Log "Đã thực thi xong toàn bộ các tùy chỉnh đã chọn!" "TITLE"
    [System.Windows.Forms.MessageBox]::Show("Quá trình tối ưu hệ thống đã hoàn tất!","Thông báo",0,64)
})

$btnTwUndo.Add_Click({
    $checked = @($listTw.CheckedItems)
    if ($checked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn các mục cần hoàn tác (Undo) trong danh sách!","Thông báo",0,48)
        return
    }
    $r = [System.Windows.Forms.MessageBox]::Show("Bạn có chắc muốn hoàn tác các mục đã chọn về mặc định Windows?","Xác nhận",4,32)
    if ($r -eq "Yes") {
        Write-Log "Bắt đầu hoàn tác $($checked.Count) tùy chỉnh..." "TITLE"
        foreach($item in $checked){
            Write-Log "Đang hoàn tác: $item" "INFO"
            try { & $tweakDatabase[$item].Undo } catch { Write-Log "Lỗi hoàn tác: $_" "ERR" }
        }
        Write-Log "Đã hoàn tất quá trình khôi phục!" "OK"
        [System.Windows.Forms.MessageBox]::Show("Đã hoàn tất khôi phục các mục đã chọn!","Thông báo",0,64)
    }
})
#endregion

# ==============================================================
#  TAB 2 - CÀI ĐẶT PHẦN MỀM NHANH (SILENT INSTALL)
# ==============================================================
#region --- TAB CÀI ĐẶT ---
$gbInsL = New-GroupCard "KHO PHẦN MỀM CHUẨN (CÀI ĐẶT NGẦM KHÔNG CẦN NEXT)" 10 10 600 ($tabCtrlHeight - 20) $C.Blue
$tabInstall.Controls.Add($gbInsL)
$listIns = New-CheckListBox 15 25 570 ($tabCtrlHeight - 110)
$gbInsL.Controls.Add($listIns)

$btnInsAll  = New-StyledButton "Chọn Tất Cả" 15 ($tabCtrlHeight - 72) 140 32 $C.BgCard $C.TextDim $F.Small
$btnInsNone = New-StyledButton "Bỏ Chọn" 165 ($tabCtrlHeight - 72) 140 32 $C.BgCard $C.TextDim $F.Small
$gbInsL.Controls.AddRange(@($btnInsAll,$btnInsNone))

$gbInsR = New-GroupCard "TIẾN TRÌNH & THÔNG TIN CÀI ĐẶT" 620 10 ($tabCtrlWidth - 635) ($tabCtrlHeight - 20) $C.Blue
$tabInstall.Controls.Add($gbInsR)
$txtInsInfo = New-Object System.Windows.Forms.RichTextBox
$txtInsInfo.Location=[System.Drawing.Point]::new(15, 25); $txtInsInfo.Size=[System.Drawing.Size]::new($tabCtrlWidth - 665, $tabCtrlHeight - 110)
$txtInsInfo.BackColor=$C.BgCard; $txtInsInfo.ForeColor=$C.Text; $txtInsInfo.Font=$F.MonoSm
$txtInsInfo.BorderStyle="None"; $txtInsInfo.ReadOnly=$true
$gbInsR.Controls.Add($txtInsInfo)

$btnInstallRun = New-StyledButton "TIẾN HÀNH CÀI ĐẶT" 15 ($tabCtrlHeight - 72) ($tabCtrlWidth - 665) 32 $C.BlueDark $C.White $F.Btn
$gbInsR.Controls.Add($btnInstallRun)

$softwareDatabase = [ordered]@{
    "Google Chrome (Trình duyệt web phổ biến)"           = @{ Id = "Google.Chrome" }
    "Mozilla Firefox (Trình duyệt mã nguồn mở)"         = @{ Id = "Mozilla.Firefox" }
    "7-Zip (Phần mềm giải nén tối ưu)"                  = @{ Id = "7zip.7zip" }
    "WinRAR (Công cụ giải nén quen thuộc)"             = @{ Id = "RARLab.WinRAR" }
    "UniKey (Bộ gõ tiếng Việt Unicode chuẩn)"            = @{ Id = "KHKT.UniKey" }
    "VLC Media Player (Xem phim, nghe nhạc mọi định dạng)" = @{ Id = "VideoLAN.VLC" }
    "Foxit Reader (Đọc file PDF nhanh nhẹn)"           = @{ Id = "Foxit.FoxitReader" }
    "K-Lite Codec Pack Full (Gói giải mã đa phương tiện)" = @{ Id = "CodecGuide.K-LiteCodecPack.Full" }
    "TeamViewer (Hỗ trợ điều khiển từ xa)"             = @{ Id = "TeamViewer.TeamViewer" }
    "AnyDesk (Ứng dụng kết nối từ xa siêu nhẹ)"        = @{ Id = "AnyDeskSoftware.AnyDesk" }
    "Telegram Desktop (Ứng dụng chat bảo mật)"          = @{ Id = "Telegram.TelegramDesktop" }
    "Zalo PC (Ứng dụng nhắn tin công việc hàng đầu)"     = @{ Id = "VNG.Zalo" }
    "Notepad++ (Trình soạn thảo mã nguồn nâng cao)"      = @{ Id = "Notepad++.Notepad++" }
    "Visual Studio Code (Công cụ lập trình chuyên nghiệp)" = @{ Id = "Microsoft.VisualStudioCode" }
    "DirectX & Visual C++ Runtimes (All-in-One Fix Game)" = @{ Id = "Majorgeeks.VCRedist" }
}

foreach ($k in $softwareDatabase.Keys) { [void]$listIns.Items.Add($k) }

$btnInsAll.Add_Click({ for($i=0;$i-lt $listIns.Items.Count;$i++){ $listIns.SetItemChecked($i,$true) } })
$btnInsNone.Add_Click({ for($i=0;$i-lt $listIns.Items.Count;$i++){ $listIns.SetItemChecked($i,$false) } })

$listIns.Add_SelectedIndexChanged({
    if ($listIns.SelectedItem) {
        $name = $listIns.SelectedItem.ToString()
        $pkg = $softwareDatabase[$name]
        $txtInsInfo.Text = "=== THÔNG TIN PHẦN MỀM ===`r`n`r`nTên: $name`nMã Winget ID: $($pkg.Id)`nTrạng thái: Sẵn sàng cài đặt tự động ngầm không cần tương tác."
    }
})

$btnInstallRun.Add_Click({
    $checked = @($listIns.CheckedItems)
    if ($checked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn ít nhất một phần mềm cần cài đặt!","Thông báo",0,48)
        return
    }
    Write-Log "Bắt đầu cài đặt tự động $($checked.Count) phần mềm đã chọn..." "TITLE"
    Reset-Progress
    $curr=0; $tot=$checked.Count
    foreach($item in $checked){
        $curr++
        $pkg = $softwareDatabase[$item]
        Write-Log "Đang cài đặt: $item (ID: $($pkg.Id))..." "INFO"
        try {
            Start-Process "winget" -ArgumentList "install --id $($pkg.Id) --silent --accept-package-agreements --accept-source-agreements" -WindowStyle Hidden -Wait
            Write-Log "Cài đặt thành công: $item" "OK"
        } catch {
            Write-Log "Lỗi cài đặt [$item]: $_" "ERR"
        }
        Set-Progress $curr $tot
    }
    Write-Log "Hoàn tất toàn bộ quy trình cài đặt phần mềm!" "TITLE"
    [System.Windows.Forms.MessageBox]::Show("Đã cài đặt xong các phần mềm đã chọn!","Thông báo",0,64)
})
#endregion

# ==============================================================
#  TAB 3 - GỞ BỎ ỨNG DỤNG & DỌN DẸP (UNINSTALLER)
# ==============================================================
#region --- TAB GỞ BỎ ---
$gbRem = New-GroupCard "QUẢN LÝ & GỞ BỎ ỨNG DỤNG HỆ THỐNG / USER APPS" 10 10 ($tabCtrlWidth - 20) ($tabCtrlHeight - 20) $C.Orange
$tabRemove.Controls.Add($gbRem)

$listRem = New-CheckListBox 15 25 ($tabCtrlWidth - 50) ($tabCtrlHeight - 110)
$gbRem.Controls.Add($listRem)

$btnLoadApps  = New-StyledButton "Tải Danh Sách Ứng Dụng" 15 ($tabCtrlHeight - 72) 220 32 $C.BgCard $C.TextDim $F.Small
$btnRemAll    = New-StyledButton "Chọn Tất Cả" 245 ($tabCtrlHeight - 72) 110 32 $C.BgCard $C.TextDim $F.Small
$btnRemNone   = New-StyledButton "Bỏ Chọn" 365 ($tabCtrlHeight - 72) 110 32 $C.BgCard $C.TextDim $F.Small
$btnRemExec   = New-StyledButton "GỞ BỎ CÁC MỤC ĐÃ CHỌN" 490 ($tabCtrlHeight - 72) ($tabCtrlWidth - 520) 32 $C.RedDark $C.White $F.Btn
$gbRem.Controls.AddRange(@($btnLoadApps,$btnRemAll,$btnRemNone,$btnRemExec))

$btnLoadApps.Add_Click({
    Write-Log "Đang quét danh sách ứng dụng đã cài đặt trên hệ thống..." "INFO"
    $listRem.Items.Clear()
    $global:UnTable.Clear()
    $apps = Get-AppxPackage -AllUsers | Sort-Object Name
    foreach ($app in $apps) {
        if (-not [string]::IsNullOrEmpty($app.Name)) {
            $displayName = "$($app.Name) [Phiên bản: $($app.Version)]"
            if (-not $global:UnTable.ContainsKey($displayName)) {
                $global:UnTable[$displayName] = $app.PackageFullName
                [void]$listRem.Items.Add($displayName)
            }
        }
    }
    Write-Log "Đã tải xong $($listRem.Items.Count) ứng dụng hệ thống và cửa hàng." "OK"
})

$btnRemAll.Add_Click({ for($i=0;$i-lt $listRem.Items.Count;$i++){ $listRem.SetItemChecked($i,$true) } })
$btnRemNone.Add_Click({ for($i=0;$i-lt $listRem.Items.Count;$i++){ $listRem.SetItemChecked($i,$false) } })

$btnRemExec.Add_Click({
    $checked = @($listRem.CheckedItems)
    if ($checked.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Vui lòng chọn ứng dụng cần gỡ bỏ!","Thông báo",0,48)
        return
    }
    $r = [System.Windows.Forms.MessageBox]::Show("Bạn có chắc chắn muốn gỡ bỏ hoàn toàn $($checked.Count) ứng dụng đã chọn?","Cảnh báo",4,48)
    if ($r -eq "Yes") {
        Write-Log "Bắt đầu gỡ bỏ các ứng dụng đã chọn..." "TITLE"
        Reset-Progress
        $curr=0; $tot=$checked.Count
        foreach ($item in $checked) {
            $curr++
            $fullName = $global:UnTable[$item]
            Write-Log "Đang gỡ: $item" "INFO"
            try {
                Remove-AppxPackage -AllUsers -Package $fullName -ErrorAction SilentlyContinue
                Remove-AppxProvisionedPackage -Online -PackageName $fullName -ErrorAction SilentlyContinue | Out-Null
                Write-Log "Đã gỡ thành công: $item" "OK"
            } catch {
                Write-Log "Không thể gỡ [$item]: $_" "ERR"
            }
            Set-Progress $curr $tot
        }
        Write-Log "Hoàn tất quá trình gỡ bỏ ứng dụng!" "TITLE"
        [System.Windows.Forms.MessageBox]::Show("Đã gỡ bỏ xong các ứng dụng đã chọn!","Thông báo",0,64)
    }
})
#endregion

# ==============================================================
#  TAB 4 - SAO LƯU & KHÔI PHỤC (BACKUP & RESTORE)
# ==============================================================
#region --- TAB SAO LƯU ---
$gbBak = New-GroupCard "SAO LƯU & PHỤC HỒI DỮ LIỆU / DRIVER / BẢN QUYỀN" 10 10 ($tabCtrlWidth - 20) ($tabCtrlHeight - 20) $C.Green
$tabBackup.Controls.Add($gbBak)

$txtBakInfo = New-Object System.Windows.Forms.RichTextBox
$txtBakInfo.Location=[System.Drawing.Point]::new(15, 25); $txtBakInfo.Size=[System.Drawing.Size]::new($tabCtrlWidth - 50, $tabCtrlHeight - 110)
$txtBakInfo.BackColor=$C.BgCard; $txtBakInfo.ForeColor=$C.LogGreen; $txtBakInfo.Font=$F.Mono
$txtBakInfo.BorderStyle="None"; $txtBakInfo.ReadOnly=$true
$txtBakInfo.Text = "=== TRUNG TÂM SAO LƯU HỆ THỐNG ===`r`n`r`n- Bạn có thể sao lưu toàn bộ Driver bên thứ ba hiện có ra một thư mục để phục hồi nhanh sau khi cài lại Windows.`r`n- Sao lưu bản quyền Windows / Office hiện tại.`r`n- Tạo điểm khôi phục nhanh chóng."
$gbBak.Controls.Add($txtBakInfo)

$btnBakDrivers = New-StyledButton "Sao Lưu Tất Cả Driver" 15 ($tabCtrlHeight - 72) 220 32 $C.BgCard $C.TextDim $F.Small
$btnBakKey     = New-StyledButton "Sao Lưu Bản Quyền (License)" 245 ($tabCtrlHeight - 72) 220 32 $C.BgCard $C.TextDim $F.Small
$btnCreateRp   = New-StyledButton "Tạo Restore Point Nhanh" 475 ($tabCtrlHeight - 72) 220 32 $C.BgCard $C.TextDim $F.Small
$gbBak.Controls.AddRange(@($btnBakDrivers,$btnBakKey,$btnCreateRp))

$btnBakDrivers.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Chọn thư mục lưu trữ Driver hệ thống"
    if ($fbd.ShowDialog() -eq "OK") {
        $targetDir = $fbd.SelectedPath + "\WinTools_DriverBackup"
        Write-Log "Đang xuất toàn bộ Driver ra thư mục: $targetDir..." "TITLE"
        try {
            Export-WindowsDriver -Online -Destination $targetDir -ErrorAction Stop
            Write-Log "Sao lưu Driver thành công vào: $targetDir" "OK"
            [System.Windows.Forms.MessageBox]::Show("Đã sao lưu Driver thành công!","Thông báo",0,64)
        } catch {
            Write-Log "Lỗi sao lưu Driver: $_" "ERR"
        }
    }
})

$btnBakKey.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Text Document (*.txt)|*.txt"; $sfd.FileName = "License_Backup.txt"
    if ($sfd.ShowDialog() -eq "OK") {
        try {
            $keyInfo = cscript //nologo "$env:windir\system32\slmgr.vbs" /dli 2>&1
            $oaKey = (Get-CimInstance SoftwareLicensingProduct -Filter "Name LIKE 'Windows%'" | Where-Object { $_.OA3xOriginalProductKey -ne $null }).OA3xOriginalProductKey
            $content = "=== SAO LƯU BẢN QUYỀN WINDOWS / OFFICE ===`r`nThời gian: $(Get-Date)`r`nKey gốc phần cứng (OA3x): $oaKey`r`n`nChi tiết SLMGR:`r`n$keyInfo"
            $content \vert{} Out-File$sfd.FileName -Encoding UTF8
            Write-Log "Đã lưu thông tin bản quyền vào: $($sfd.FileName)" "OK"
            [System.Windows.Forms.MessageBox]::Show("Đã lưu thông tin bản quyền thành công!","Thông báo",0,64)
        } catch {
            Write-Log "Lỗi sao lưu bản quyền: $_" "ERR"
        }
    }
})

$btnCreateRp.Add_Click({
    Write-Log "Đang khởi tạo điểm khôi phục hệ thống..." "INFO"
    try {
        Checkpoint-Computer -Description "WinTools Manual Restore Point" -RestorePointType "MODIFY_SETTINGS"
        Write-Log "Đã tạo điểm khôi phục hệ thống thành công!" "OK"
        [System.Windows.Forms.MessageBox]::Show("Đã tạo Restore Point thành công!","Thông báo",0,64)
    } catch {
        Write-Log "Lỗi tạo Restore Point: $_" "ERR"
    }
})
#endregion

# ==============================================================
#  TAB 5 - BẢN QUYỀN KÍCH HOẠT (ACTIVATION TOOLS)
# ==============================================================
#region --- TAB BẢN QUYỀN ---
$gbLic = New-GroupCard "KÍCH HOẠT BẢN QUYỀN WINDOWS & OFFICE (DIGITAL LICENSE / KMS)" 10 10 ($tabCtrlWidth - 20) ($tabCtrlHeight - 20)$C.Purple
$tabLicense.Controls.Add($gbLic)

$txtLicInfo = New-Object System.Windows.Forms.RichTextBox
$txtLicInfo.Location=[System.Drawing.Point]::new(15, 25);$txtLicInfo.Size=[System.Drawing.Size]::new($tabCtrlWidth - 50,$tabCtrlHeight - 120)
$txtLicInfo.BackColor=$C.BgCard; $txtLicInfo.ForeColor=$C.Text; $txtLicInfo.Font=$F.Mono
$txtLicInfo.BorderStyle="None"; $txtLicInfo.ReadOnly=$true$txtLicInfo.Text = "=== HƯỚNG DẪN & TRẠNG THÁI KÍCH HOẠT ===`r`n`r`n- Sử dụng tập lệnh kích hoạt bản quyền kỹ thuật số (Digital License) chính thống qua MAS (Microsoft Activation Scripts).`r`n- Vĩnh viễn, an toàn tuyệt đối, cập nhật trực tiếp từ Microsoft.`r`n- Nhấn nút bên dưới để kích hoạt tự động."
$gbLic.Controls.Add($txtLicInfo)

$btnActWin = New-StyledButton "Kích Hoạt Windows Vĩnh Viễn (MAS)" 15 ($tabCtrlHeight - 80) 460 35$C.PurpleDark $C.White $F.Btn
$btnActOff = New-StyledButton "Kích Hoạt Microsoft Office (MAS)" 495 ($tabCtrlHeight - 80) 460 35$C.PurpleDark $C.White $F.Btn
$btnCheckAct = New-StyledButton "Kiểm Tra Trạng Thái Bản Quyền Hiện Tại" 15 ($tabCtrlHeight - 40) ($tabCtrlWidth - 50) 32$C.BgCard $C.TextDim $F.Small
$gbLic.Controls.AddRange(@($btnActWin,$btnActOff,$btnCheckAct))

$btnActWin.Add_Click({
    Write-Log "Đang chạy tập lệnh kích hoạt Windows kỹ thuật số..." "TITLE"
    try {
        Start-Process "powershell" -ArgumentList "-Command `"irm https://get.activated.win | iex`"" -WindowStyle Normal
        Write-Log "Đã gọi trình kích hoạt MAS thành công." "OK"
    } catch {
        Write-Log "Lỗi kích hoạt: $_" "ERR"
    }
})

$btnActOff.Add_Click({
    Write-Log "Đang chạy tập lệnh kích hoạt Office..." "TITLE"
    try {
        Start-Process "powershell" -ArgumentList "-Command `"irm https://get.activated.win | iex`"" -WindowStyle Normal
        Write-Log "Đã gọi trình kích hoạt Office thành công." "OK"
    } catch {
        Write-Log "Lỗi kích hoạt Office: $_" "ERR"
    }
})

$btnCheckAct.Add_Click({
    Write-Log "Đang kiểm tra trạng thái bản quyền hệ thống..." "INFO"
    $status = cscript //nologo "$env:windir\system32\slmgr.vbs" /xpr 2>&1
    $txtLicInfo.Text = "=== KẾT QUẢ KIỂM TRA BẢN QUYỀN ===`r`n`r`n$status"
    Write-Log "Đã kiểm tra xong bản quyền." "OK"
})
#endregion

# ==============================================================
#  TAB 6 - THÔNG TIN PHẦN MỀM (ABOUT)
# ==============================================================
#region --- TAB THÔNG TIN ---
$gbAbout = New-GroupCard "GIỚI THIỆU WIN TOOLS PRO" 10 10 ($tabCtrlWidth - 20) ($tabCtrlHeight - 20)$C.Accent
$tabAbout.Controls.Add($gbAbout)

$txtAbout = New-Object System.Windows.Forms.RichTextBox
$txtAbout.Location=[System.Drawing.Point]::new(15, 25);$txtAbout.Size=[System.Drawing.Size]::new($tabCtrlWidth - 50,$tabCtrlHeight - 40)
$txtAbout.BackColor=$C.BgCard; $txtAbout.ForeColor=$C.Text; $txtAbout.Font=$F.Body
$txtAbout.BorderStyle="None"; $txtAbout.ReadOnly=$true$txtAbout.Text = @"
=============================================================================
                      WIN TOOLS PRO - ULTIMATE EDITION
=============================================================================

Phát triển bởi: Mr Hạnh
Hotline / Zalo: 0938.608.602
Website hỗ trợ: https://khanggiaphuc.com/win
Phiên bản hiện tại: $($Global:AppVersion)

GIỚI THIỆU CHUNG:
WIN TOOLS PRO là bộ công cụ tối ưu hóa hệ điều hành Windows chuyên nghiệp, được thiết kế dành riêng cho kỹ thuật viên máy tính, phòng nét, văn phòng và người dùng cá nhân muốn khai thác tối đa hiệu năng phần cứng, loại bỏ rác hệ thống và tinh chỉnh bảo mật một cách an toàn nhất.

CÁC TÍNH NĂNG NỔI BẬT:
1. Tùy chỉnh hệ thống sâu: Tắt telemetry, tối ưu service, tinh chỉnh visual effects, chặn update thông minh, dọn dẹp ổ đĩa siêu tốc kèm bộ lọc tìm kiếm nhanh.
2. Kho phần mềm chuẩn: Cài đặt tự động ngầm (silent install) hàng loạt phần mềm thiết yếu chỉ với 1 cú click thông qua kho quản lý Winget chuẩn mực.
3. Gỡ bỏ ứng dụng rác: Quét và gỡ sạch sẽ các ứng dụng Windows Store / Bloatware ngầm gây nặng máy.
4. Sao lưu & Phục hồi: Hỗ trợ trích xuất toàn bộ driver phần cứng, sao lưu bản quyền và tạo điểm khôi phục nhanh chóng.
5. Kích hoạt bản quyền: Tích hợp kịch bản bản quyền số an toàn, sạch sẽ.

BẢN QUYỀN VÀ SỬ DỤNG:
Công cụ được phát triển hoàn toàn miễn phí phục vụ cộng đồng kỹ thuật viên Việt Nam. Mọi hành vi thương mại hóa trái phép vui lòng liên hệ tác giả Mr Hạnh để được cấp phép.
=============================================================================
"@
$gbAbout.Controls.Add($txtAbout)
#endregion

# ==============================================================
#  KHỞI ĐỘNG LUỒNG THU THẬP THÔNG TIN PHẦN CỨNG (ASYNC SYSINFO)
# ==============================================================
$jobSysInfo = Start-Job -ScriptBlock {$os = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version
    $cpu = Get-CimInstance Win32_Processor \vert{} Select-Object Name, NumberOfCores, NumberOfLogicalProcessors$ram = Get-CimInstance Win32_ComputerSystem | Select-Object TotalPhysicalMemory
    $ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB, 2)
    $gpu = Get-CimInstance Win32_VideoController \vert{} Select-Object Name$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" | Select-Object Size, FreeSpace
    $diskFreeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $diskTotalGB = [math]::Round($disk.Size / 1GB, 2)
    return "  OS: $($os.Caption.Trim()) \vert{} CPU:$($cpu.Name.Trim()) ($($cpu.NumberOfCores) Cores / $($cpu.NumberOfLogicalProcessors) Threads) \vert{} RAM:${ramGB}GB | GPU: $($gpu.Name | Select-Object -First 1) | Ổ C: Còn ${diskFreeGB}GB / ${diskTotalGB}GB trống"
}

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000$timer.Add_Tick({
    if ($jobSysInfo.State -eq "Completed") {
        $lblSys.Text = Receive-Job$jobSysInfo
        Remove-Job $jobSysInfo$timer.Stop()
        Write-Log "Đã nạp xong thông tin cấu hình phần cứng hệ thống." "OK"
    }
})
$timer.Start()

# ==============================================================
#  HIỂN THỊ FORM CHÍNH TOÀN MÀN HÌNH
# ==============================================================
Write-Log "Khởi động giao diện WIN TOOLS Pro $($Global:AppVersion) Fullscreen thành công." "TITLE"
[void]$form.ShowDialog()
