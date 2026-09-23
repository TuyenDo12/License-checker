# =============================================================================
#  WinLicCheck_GUI.ps1  --  Giao diện Windows Forms cho WinLicCheck
# =============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CẤU HÌNH GIAO DIỆN CHÍNH (DARK MODE) ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "VST - Win & Office License Checker (WinLicCheck Engine)"
$form.Size = New-Object System.Drawing.Size(920, 560)$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox =$false

# --- KHUNG BÊN TRÁI: ĐIỀU KHIỂN & THAO TÁC ---
$groupLeft = New-Object System.Windows.Forms.GroupBox
$groupLeft.Text = " Thao tác Bản quyền "
$groupLeft.ForeColor = [System.Drawing.Color]::White
$groupLeft.Location = New-Object System.Drawing.Point(15, 10)$groupLeft.Size = New-Object System.Drawing.Size(360, 490)
$form.Controls.Add($groupLeft)

# Nhãn trạng thái
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Trạng thái: Sẵn sàng rà quét..."
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)$lblStatus.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$lblStatus.Location = New-Object System.Drawing.Point(20, 30)$lblStatus.Size = New-Object System.Drawing.Size(320, 30)
$groupLeft.Controls.Add($lblStatus)

# Nút 1: Rà quét
$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = "1. Rà quét & Phân tích (WinLicCheck)"
$btnScan.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$btnScan.ForeColor = [System.Drawing.Color]::White$btnScan.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnScan.Location = New-Object System.Drawing.Point(20, 75)
$btnScan.Size = New-Object System.Drawing.Size(320, 45)$btnScan.FlatStyle = "Flat"
$groupLeft.Controls.Add($btnScan)

# Nút 2: Gỡ bỏ Crack & Khôi phục
$btnFix = New-Object System.Windows.Forms.Button
$btnFix.Text = "2. Gỡ bỏ Crack & Khôi phục Key OEM"
$btnFix.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)
$btnFix.ForeColor = [System.Drawing.Color]::White$btnFix.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$btnFix.Location = New-Object System.Drawing.Point(20, 130)
$btnFix.Size = New-Object System.Drawing.Size(320, 45)$btnFix.FlatStyle = "Flat"
$groupLeft.Controls.Add($btnFix)

# Thông tin tham chiếu
$lblRef = New-Object System.Windows.Forms.Label
$lblRef.Text = "Nguồn Script Rà quét:"
$lblRef.ForeColor = [System.Drawing.Color]::FromArgb(170, 170, 170)
$lblRef.Location = New-Object System.Drawing.Point(20, 430)$lblRef.Size = New-Object System.Drawing.Size(320, 20)
$groupLeft.Controls.Add($lblRef)

$lblLink = New-Object System.Windows.Forms.Label
$lblLink.Text = "khanggiaphuc.com/win"
$lblLink.ForeColor = [System.Drawing.Color]::FromArgb(0, 162, 237)$lblLink.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Underline)
$lblLink.Location = New-Object System.Drawing.Point(20, 450)$lblLink.Size = New-Object System.Drawing.Size(320, 25)
$groupLeft.Controls.Add($lblLink)

# --- KHUNG BÊN PHẢI: BẢNG MÔ TẢ CHI TIẾT ---
$groupRight = New-Object System.Windows.Forms.GroupBox
$groupRight.Text = " Chi tiết Bản quyền & Dấu vết Can thiệp "
$groupRight.ForeColor = [System.Drawing.Color]::White
$groupRight.Location = New-Object System.Drawing.Point(390, 10)$groupRight.Size = New-Object System.Drawing.Size(495, 490)
$form.Controls.Add($groupRight)

$txtDetails = New-Object System.Windows.Forms.TextBox
$txtDetails.Multiline = $true$txtDetails.ReadOnly = $true$txtDetails.ScrollBars = "Vertical"
$txtDetails.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$txtDetails.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 102)$txtDetails.Font = New-Object System.Drawing.Font("Consolas", 9)
$txtDetails.Location = New-Object System.Drawing.Point(15, 25)
$txtDetails.Size = New-Object System.Drawing.Size(465, 450)$txtDetails.Text = @"
=== BẢNG THÔNG TIN MÔ TẢ CHI TIẾT ===
Nhấn nút '1. Rà quét & Phân tích' để bắt đầu kiểm tra bằng WinLicCheck.ps1...

Kết quả rà quét bao gồm:
 - Trạng thái kích hoạt Windows 10/11 & Office
 - Phát hiện Server KMS lậu, Task ẩn, AAct, MAS, TSforge
 - Đọc Key OEM gốc từ BIOS (MSDM)
 - Kiểm tra vết can thiệp lịch sử PowerShell/Registry
"@
$groupRight.Controls.Add($txtDetails)

# --- LOGIC XỬ LÝ SỰ KIỆN ---

# 1. Sự kiện Rà quét
$btnScan.Add_Click({$lblStatus.Text = "Trạng thái: Đang rà quét..."
    $lblStatus.ForeColor = [System.Drawing.Color]::Yellow$txtDetails.Text = "[*] Đang khởi chạy engine rà quét WinLicCheck.ps1...`r`nVui lòng chờ trong giây lát...`r`n"
    $form.Refresh()

    $scriptPath = Join-Path$PSScriptRoot "WinLicCheck.ps1"
    
    # Tự động tải script gốc nếu chưa có sẵn trong cùng thư mục
    if (-not (Test-Path $scriptPath)) {$txtDetails.AppendText("[*] Chưa tìm thấy WinLicCheck.ps1 cục bộ, đang tải bản gốc từ GitHub...`r`n")
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/tiennnict/license.info.vn/main/WinLicCheck.ps1" -OutFile $scriptPath
        } catch {
            $txtDetails.AppendText("[ERROR] Không thể tải WinLicCheck.ps1 từ mạng.`r`n")
            $lblStatus.Text = "Trạng thái: Lỗi tải script!"
            $lblStatus.ForeColor = [System.Drawing.Color]::Red
            return
        }
    }

    # Chạy rà quét và lấy output hiển thị trực tiếp lên Textbox bên phải
    try {
        $output = powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath 2>&1 \vert{} Out-String$txtDetails.Text = $output$lblStatus.Text = "Trạng thái: Đã hoàn tất rà quét!"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)     } catch {$txtDetails.Text = "[ERROR] Lỗi khi thực thi script:`r`n$_"
        $lblStatus.Text = "Trạng thái: Lỗi thực thi!"
        $lblStatus.ForeColor = [System.Drawing.Color]::Red
    }
})

# 2. Sự kiện Gỡ bỏ & Khôi phục
$btnFix.Add_Click({$confirm = [System.Windows.Forms.MessageBox]::Show(
        "Bạn có chắc chắn muốn mở trình xử lý gỡ bỏ Crack và khôi phục Key OEM không?", 
        "Xác nhận gỡ bỏ", 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )

    if ($confirm -eq [System.Windows.Forms.DialogResult]::Yes) {$lblStatus.Text = "Trạng thái: Đang mở luồng gỡ bỏ..."
        $lblStatus.ForeColor = [System.Drawing.Color]::Orange
        
        $scriptPath = Join-Path$PSScriptRoot "WinLicCheck.ps1"
        
        # Mở cửa sổ Console PowerShell tương tác để người dùng nhập từ khóa xác nhận (GOBO, DON, TAITAO)
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait

        $lblStatus.Text = "Trạng thái: Đã hoàn tất luồng xử lý!"
        $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 0)
    }
})

# --- HIỂN THỊ GIAO DIỆN ---
[void]$form.ShowDialog()
