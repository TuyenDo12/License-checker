#RequireAdmin
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

Opt("GUIOnEventMode", 1)

Global $hMainGUI, $idEditDetails, $idBtnScan, $idBtnFix, $idStatusLabel

; --- TẠO GIAO DIỆN CHÍNH (RỘNG HƠN ĐỂ CHỨA KHUNG BÊN PHẢI) ---
$hMainGUI = GUICreate("VST - Win & Office License Checker (WinLicCheck Engine)", 900, 520, -1, -1, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))
GUISetBkColor(0x1E1E1E, $hMainGUI) ; Dark Mode Style

; --- BÊN TRÁI: KHU VỰC ĐIỀU KHIỂN & CHỨC NĂNG (Width: 380) ---
GUICtrlCreateGroup(" Thao tác Bản quyền ", 15, 10, 360, 460)
GUICtrlSetColor(-1, 0xFFFFFF)

$idStatusLabel = GUICtrlCreateLabel("Trạng thái: Sẵn sàng rà quét...", 30, 40, 330, 30)
GUICtrlSetColor(-1, 0x00FF00)
GUICtrlSetFont(-1, 10, 800, 0, "Segoe UI")

$idBtnScan = GUICtrlCreateButton("1. Rà quét & Phân tích (WinLicCheck)", 30, 85, 330, 45)
GUICtrlSetFont(-1, 10, 600, 0, "Segoe UI")
GUICtrlSetOnEvent($idBtnScan, "OnScanLicCheck")

$idBtnFix = GUICtrlCreateButton("2. Gỡ bỏ Crack & Khôi phục Key OEM", 30, 140, 330, 45)
GUICtrlSetFont(-1, 10, 600, 0, "Segoe UI")
GUICtrlSetOnEvent($idBtnFix, "OnFixLicCheck")

; Thông tin liên hệ & Link tham chiếu
GUICtrlCreateLabel("Nguồn Script Rà quét:", 30, 410, 330, 20)
GUICtrlSetColor(-1, 0xAAAAAA)
$idLink = GUICtrlCreateLabel("khanggiaphuc.com/win", 30, 430, 330, 25)
GUICtrlSetColor(-1, 0x00A2ED)
GUICtrlSetFont(-1, 10, 800, 4, "Segoe UI")

; --- BÊN PHẢI: KHUNG MÔ TẢ CHI TIẾT (Width: 480) ---
GUICtrlCreateGroup(" Chi tiết Bản quyền & Dấu vết Can thiệp ", 390, 10, 495, 460)
GUICtrlSetColor(-1, 0xFFFFFF)

$idEditDetails = GUICtrlCreateEdit("", 400, 35, 475, 425, BitOR($ES_MULTILINE, $ES_READONLY, $WS_VSCROLL))
GUICtrlSetBkColor(-1, 0x121212)
GUICtrlSetColor(-1, 0x00FF66) ; Màu chữ terminal xanh lá
GUICtrlSetFont(-1, 9, 400, 0, "Consolas")

GUICtrlSetData($idEditDetails, "=== BẢNG THÔNG TIN MÔ TẢ CHI TIẾT ===" & @CRLF & _
        "Nhấn nút '1. Rà quét & Phân tích' để bắt đầu chạy kiểm tra độc lập bằng WinLicCheck.ps1..." & @CRLF & @CRLF & _
        "Kết quả rà quét bao gồm:" & @CRLF & _
        " - Trạng thái kích hoạt Windows 10/11 & Office" & @CRLF & _
        " - Phát hiện Server KMS lậu, Task ẩn, AAct, MAS" & @CRLF & _
        " - Đọc Key OEM từ BIOS (MSDM)" & @CRLF & _
        " - Kiểm tra vết can thiệp lịch sử PowerShell/Registry")

GUISetOnEvent($GUI_EVENT_CLOSE, "OnCloseApp")
GUISetState(@SW_SHOW, $hMainGUI)

; --- VÒNG LẶP CHÍNH ---
While 1
    Sleep(100)
WEnd

; --- XỬ LÝ SỰ KIỆN RÀ QUÉT ---
Func OnScanLicCheck()
    GUICtrlSetData($idStatusLabel, "Trạng thái: Đang rà quét hệ thống...")
    GUICtrlSetColor($idStatusLabel, 0xFFFF00)
    GUICtrlSetData($idEditDetails, "[*] Đang khởi chạy WinLicCheck.ps1..." & @CRLF & "Vui lòng chờ trong giây lát...")

    Local $sScriptPath = @ScriptDir & "\WinLicCheck.ps1"
    
    ; Tự động tải script nếu chưa có sẵn ở thư mục làm việc
    If Not FileExists($sScriptPath) Then
        GUICtrlSetData($idEditDetails, "[*] Đang tải WinLicCheck.ps1 từ nguồn bảo mật..." & @CRLF)
        InetGet("https://raw.githubusercontent.com/tiennnict/license.info.vn/main/WinLicCheck.ps1", $sScriptPath, 1, 0)
    EndIf

    ; Gọi PowerShell thực thi rà quét và ghi Output ra tệp tạm
    Local $sOutFile = @TempDir & "\WinLic_Result.log"
    Local $sPSCmd = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {& ''' & $sScriptPath & '''} | Out-File -FilePath ''' & $sOutFile & ''' -Encoding utf8"'
    
    RunWait($sPSCmd, "", @SW_HIDE)

    ; Đọc và hiển thị kết quả lên khung mô tả bên phải
    If FileExists($sOutFile) Then
        Local $sResult = FileRead($sOutFile)
        GUICtrlSetData($idEditDetails, $sResult)
        GUICtrlSetData($idStatusLabel, "Trạng thái: Đã hoàn tất rà quét!")
        GUICtrlSetColor($idStatusLabel, 0x00FF00)
        FileDelete($sOutFile)
    Else
        GUICtrlSetData($idEditDetails, "[ERROR] Không thể lấy dữ liệu rà quét từ PowerShell.")
        GUICtrlSetData($idStatusLabel, "Trạng thái: Lỗi rà quét!")
        GUICtrlSetColor($idStatusLabel, 0xFF0000)
    EndIf
EndFunc

; --- XỬ LÝ SỰ KIỆN GỠ BỎ CRACK ---
Func OnFixLicCheck()
    Local $iConfirm = MsgBox(36, "Xác nhận", "Bạn có chắc chắn muốn gỡ bỏ toàn bộ dấu vết Crack và kích hoạt lại bằng Key hợp lệ không?")
    If $iConfirm = 6 Then
        GUICtrlSetData($idStatusLabel, "Trạng thái: Đang gỡ bỏ & dọn dẹp...")
        GUICtrlSetColor($idStatusLabel, 0xFF9900)
        
        ; Mở cửa sổ Console PowerShell trực tiếp để người dùng tương tác các bước gỡ bỏ (nhập từ khóa GOBO/DON nếu cần)
        Local $sScriptPath = @ScriptDir & "\WinLicCheck.ps1"
        Local $sPSCmd = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' & $sScriptPath & '"'
        RunWait($sPSCmd, "", @SW_SHOW)

        GUICtrlSetData($idStatusLabel, "Trạng thái: Đã hoàn tất xử lý!")
        GUICtrlSetColor($idStatusLabel, 0x00FF00)
    EndIf
EndFunc

Func OnCloseApp()
    Exit
EndFunc
