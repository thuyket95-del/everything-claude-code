<#
╔══════════════════════════════════════════════════════════════╗
║           RAR/ZIP PASSWORD CRACKER TOOL v1.0                ║
║           Sử dụng 7-Zip để dò mật khẩu                     ║
║           Hỗ trợ: Dictionary + Pattern + Brute Force        ║
╚══════════════════════════════════════════════════════════════╝
#>

param(
    [string]$ArchivePath = ".\BAN VIP.zip",
    [string]$SevenZipPath = "C:\Program Files\7-Zip\7z.exe",
    [int]$MaxBruteForceLength = 6,
    [string]$CustomWordlistPath = "",
    [switch]$BruteForceOnly,
    [switch]$DictionaryOnly,
    [string]$BruteForceChars = "abcdefghijklmnopqrstuvwxyz0123456789"
)

# ═══════════════════════════════════════
# CẤU HÌNH
# ═══════════════════════════════════════
$script:totalTried = 0
$script:found = $false
$script:foundPassword = ""
$script:startTime = Get-Date
$script:logFile = ".\crack_log.txt"

# ═══════════════════════════════════════
# HÀM KIỂM TRA MẬT KHẨU
# ═══════════════════════════════════════
function Test-Password {
    param([string]$Password)
    
    if ($script:found) { return $true }
    
    $script:totalTried++
    
    # Hiển thị tiến trình mỗi 50 lần thử
    if ($script:totalTried % 50 -eq 0) {
        $elapsed = (Get-Date) - $script:startTime
        $speed = [math]::Round($script:totalTried / $elapsed.TotalSeconds, 1)
        Write-Host "`r  ⏱  Đã thử: $($script:totalTried) | Tốc độ: $speed pw/s | Thời gian: $([math]::Round($elapsed.TotalSeconds))s" -NoNewline -ForegroundColor DarkGray
    }
    
    try {
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo.FileName = $SevenZipPath
        $process.StartInfo.Arguments = "t `"$ArchivePath`" -p`"$Password`""
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        $process.StartInfo.CreateNoWindow = $true
        $process.Start() | Out-Null
        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()
        
        $output = "$stdout $stderr"
        
        if ($output -notmatch "Wrong password" -and $output -notmatch "ERROR" -and $process.ExitCode -eq 0) {
            $script:found = $true
            $script:foundPassword = $Password
            Write-Host ""
            Write-Host ""
            Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
            Write-Host "  ║  🎉 TÌM THẤY MẬT KHẨU!                            ║" -ForegroundColor Green
            Write-Host "  ╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
            Write-Host "  ║  Mật khẩu: $Password" -ForegroundColor Yellow -NoNewline
            Write-Host "$(' ' * [math]::Max(1, 43 - $Password.Length))║" -ForegroundColor Green
            Write-Host "  ║  Số lần thử: $($script:totalTried)$(' ' * [math]::Max(1, 39 - $script:totalTried.ToString().Length))║" -ForegroundColor Green
            $elapsed = (Get-Date) - $script:startTime
            $timeStr = "$([math]::Round($elapsed.TotalSeconds, 1))s"
            Write-Host "  ║  Thời gian: $timeStr$(' ' * [math]::Max(1, 40 - $timeStr.Length))║" -ForegroundColor Green
            Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
            Write-Host ""
            
            # Lưu kết quả
            "PASSWORD FOUND: $Password`nTotal tried: $($script:totalTried)`nTime: $timeStr" | Out-File $script:logFile -Encoding UTF8
            
            return $true
        }
    }
    catch {
        # Bỏ qua lỗi
    }
    
    return $false
}

# ═══════════════════════════════════════
# TẠO WORDLIST THÔNG MINH
# ═══════════════════════════════════════
function Get-SmartWordlist {
    $words = [System.Collections.Generic.List[string]]::new()
    
    # --- Nhóm 1: Từ khóa liên quan đến phần mềm ---
    $baseWords = @(
        # Liên quan đến Dinh Duc
        "dinhducsoftware", "DINHDUCSOFTWARE", "DinhDucSoftware", "Dinhducsoftware",
        "dinhduc", "DinhDuc", "DINHDUC", "dinhducsoft", "DinhDucSoft",
        "hadinhduc", "HaDinhDuc", "HADINHDUC",
        "hadinhduc1006", "dinhduc1006", "duc1006",
        
        # Số điện thoại / tài khoản
        "09044086993", "0964788685", "964788685", "9044086993",
        
        # Liên quan đến phần mềm
        "nest", "Nest", "NEST", "nest7", "Nest7", "NEST7",
        "nest7191", "Nest7191", "NEST7191",
        "nestpro", "NestPro", "NESTPRO", "nestpro7",
        "nest++", "Nest++", "nest++pro", "Nest++Pro",
        "v7191", "V7191", "7191",
        "optitex", "Optitex", "OPTITEX",
        "gerber", "Gerber", "GERBER",
        "accumark", "AccuMark", "ACCUMARK",
        "autonester", "AutoNester", "AUTONESTER",
        "codemeter", "CodeMeter", "CODEMETER",
        "dongle", "Dongle", "DONGLE",
        
        # Tên file gốc và biến thể
        "Nest_V7191_Dongle_3-11119130",
        "Nest_V7191_Dongle_3", "Nest_V7191_Dongle",
        "Nest_V7191", "11119130", "3-11119130",
        
        # Liên quan đến BAN VIP
        "BANVIP", "banvip", "BanVip", "ban vip", "BAN VIP",
        "vip", "VIP", "Vip",
        
        # Mật khẩu phổ biến Việt Nam
        "matkhau", "mk", "123", "1234", "12345", "123456",
        "1234567", "12345678", "123456789", "1234567890",
        "000000", "111111", "888888", "666666",
        "abc123", "abcd1234", "qwerty", "password",
        "admin", "letmein", "welcome", "master",
        
        # Mạng xã hội
        "facebook", "Facebook", "youtube", "YouTube",
        "telegram", "Telegram", "zalo", "Zalo",
        "j2team", "J2TEAM", "j2team.dev",
        
        # Web/link
        "facebook.com/dinhducsoftware",
        "dinhducsoftware.com", "dinhducsoftware.blogspot.com",
        "hadinhduc1006@gmail.com",
        
        # Crack/keygen
        "crack", "Crack", "CRACK", "keygen", "KeyGen", "KEYGEN",
        "fullcrack", "FullCrack", "FULLCRACK",
        "cracked", "Cracked", "CRACKED",
        "patch", "Patch", "PATCH",
        "serial", "Serial", "SERIAL",
        "license", "License", "LICENSE",
        "activate", "Activate", "ACTIVATE",
        "register", "Register",
        
        # Các từ thường dùng
        "software", "Software", "SOFTWARE",
        "download", "Download", "DOWNLOAD",
        "free", "Free", "FREE",
        "pro", "Pro", "PRO",
        "full", "Full", "FULL",
        "setup", "Setup", "SETUP"
    )
    
    foreach ($w in $baseWords) {
        $words.Add($w)
    }
    
    # --- Nhóm 2: Biến thể với hậu tố số ---
    $importantWords = @("dinhducsoftware", "dinhduc", "hadinhduc", "nest", "nest7", "optitex", "gerber", "vip", "crack", "admin", "password", "nestpro")
    $suffixes = @("1", "2", "3", "7", "12", "13", "123", "1234", "!", "@", "#", "2024", "2025", "2026", "007", "666", "777", "888", "999", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10")
    
    foreach ($w in $importantWords) {
        foreach ($s in $suffixes) {
            $words.Add("$w$s")
            $words.Add("$($w.ToUpper())$s")
            $words.Add("$($w.Substring(0,1).ToUpper())$($w.Substring(1))$s")
            # Thêm tiền tố
            $words.Add("$s$w")
        }
    }
    
    # --- Nhóm 3: Kết hợp từ ---
    $comboParts1 = @("dinh", "duc", "ha", "nest", "vip", "pro", "soft", "crack", "full")
    $comboParts2 = @("duc", "soft", "ware", "7", "7191", "vip", "pro", "123", "1006", "888", "crack")
    
    foreach ($p1 in $comboParts1) {
        foreach ($p2 in $comboParts2) {
            if ($p1 -ne $p2) {
                $words.Add("$p1$p2")
                $words.Add("${p1}_${p2}")
                $words.Add("${p1}-${p2}")
                $words.Add("$($p1.ToUpper())$($p2.ToUpper())")
            }
        }
    }
    
    # --- Nhóm 4: Ngày tháng (DDMMYYYY, MMDDYYYY, YYYYMMDD) ---
    foreach ($y in 1990..2005) {
        foreach ($m in @("01","06","10")) {
            foreach ($d in @("01","06","10","15","20")) {
                $words.Add("$d$m$y")
                $words.Add("$m$d$y")
                $words.Add("$y$m$d")
            }
        }
    }
    
    # Loại bỏ trùng lặp
    $unique = $words | Select-Object -Unique
    return $unique
}

# ═══════════════════════════════════════
# BRUTE FORCE
# ═══════════════════════════════════════
function Start-BruteForce {
    param(
        [string]$Chars,
        [int]$MinLength = 1,
        [int]$MaxLength = 6
    )
    
    Write-Host ""
    Write-Host "  🔓 BRUTE FORCE: Ký tự [$($Chars.Length)], Độ dài $MinLength-$MaxLength" -ForegroundColor Cyan
    
    $charArray = $Chars.ToCharArray()
    $base = $charArray.Length
    
    for ($len = $MinLength; $len -le $MaxLength; $len++) {
        if ($script:found) { return }
        
        $totalCombinations = [math]::Pow($base, $len)
        Write-Host "  📏 Độ dài $len : ~$([math]::Round($totalCombinations)) tổ hợp" -ForegroundColor DarkYellow
        
        $indices = New-Object int[] $len
        
        for ($i = 0; $i -lt $totalCombinations; $i++) {
            if ($script:found) { return }
            
            # Tạo mật khẩu từ indices
            $pw = ""
            for ($j = 0; $j -lt $len; $j++) {
                $pw += $charArray[$indices[$j]]
            }
            
            if (Test-Password -Password $pw) { return }
            
            # Tăng indices (đếm theo base)
            $carry = $true
            for ($j = $len - 1; $j -ge 0 -and $carry; $j--) {
                $indices[$j]++
                if ($indices[$j] -ge $base) {
                    $indices[$j] = 0
                } else {
                    $carry = $false
                }
            }
        }
    }
}

# ═══════════════════════════════════════
# GIAO DIỆN CHÍNH
# ═══════════════════════════════════════
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║      🔐 RAR/ZIP PASSWORD CRACKER v1.0              ║" -ForegroundColor Cyan
Write-Host "  ║      Powered by 7-Zip Engine                       ║" -ForegroundColor Cyan
Write-Host "  ╠══════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "  ║  File : $([System.IO.Path]::GetFileName($ArchivePath))" -ForegroundColor White -NoNewline
$fname = [System.IO.Path]::GetFileName($ArchivePath)
Write-Host "$(' ' * [math]::Max(1, 44 - $fname.Length))║" -ForegroundColor Cyan
$fsize = [math]::Round((Get-Item $ArchivePath).Length / 1MB, 1)
Write-Host "  ║  Size : $fsize MB$(' ' * [math]::Max(1, 40 - "$fsize MB".Length))║" -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra file tồn tại
if (-not (Test-Path $ArchivePath)) {
    Write-Host "  ❌ Không tìm thấy file: $ArchivePath" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $SevenZipPath)) {
    Write-Host "  ❌ Không tìm thấy 7-Zip: $SevenZipPath" -ForegroundColor Red
    exit 1
}

# ═══════════════════════════════════════
# PHASE 1: WORDLIST THÔNG MINH
# ═══════════════════════════════════════
if (-not $BruteForceOnly) {
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  📖 PHASE 1: Dictionary Attack (Từ điển thông minh)" -ForegroundColor Yellow
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    
    $wordlist = Get-SmartWordlist
    Write-Host "  📝 Tổng số mật khẩu trong wordlist: $($wordlist.Count)" -ForegroundColor White
    Write-Host ""
    
    foreach ($pw in $wordlist) {
        if ($script:found) { break }
        if ([string]::IsNullOrEmpty($pw)) { continue }
        if (Test-Password -Password $pw) { break }
    }
    
    # Thử thêm wordlist tùy chỉnh nếu có
    if (-not $script:found -and $CustomWordlistPath -and (Test-Path $CustomWordlistPath)) {
        Write-Host ""
        Write-Host "  📂 Đang đọc wordlist tùy chỉnh: $CustomWordlistPath" -ForegroundColor Yellow
        $customWords = Get-Content $CustomWordlistPath -Encoding UTF8
        Write-Host "  📝 Số mật khẩu: $($customWords.Count)" -ForegroundColor White
        
        foreach ($pw in $customWords) {
            if ($script:found) { break }
            $pw = $pw.Trim()
            if ([string]::IsNullOrEmpty($pw)) { continue }
            if (Test-Password -Password $pw) { break }
        }
    }
    
    if (-not $script:found) {
        Write-Host ""
        Write-Host "  ⚠️  Dictionary attack hoàn tất - KHÔNG tìm thấy mật khẩu" -ForegroundColor DarkYellow
    }
}

# ═══════════════════════════════════════
# PHASE 2: BRUTE FORCE
# ═══════════════════════════════════════
if (-not $script:found -and -not $DictionaryOnly) {
    Write-Host ""
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  💪 PHASE 2: Brute Force Attack" -ForegroundColor Yellow
    Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "  ⚠️  Brute force có thể mất RẤT NHIỀU thời gian!" -ForegroundColor DarkYellow
    Write-Host "  💡 Nhấn Ctrl+C để dừng bất cứ lúc nào" -ForegroundColor DarkGray
    
    # Thử số trước (thường nhanh hơn)
    Write-Host ""
    Write-Host "  🔢 Phase 2a: Chỉ số (0-9), độ dài 1-8" -ForegroundColor Cyan
    Start-BruteForce -Chars "0123456789" -MinLength 1 -MaxLength 8
    
    if (-not $script:found) {
        Write-Host ""
        Write-Host "  🔤 Phase 2b: Chữ thường (a-z), độ dài 1-$MaxBruteForceLength" -ForegroundColor Cyan
        Start-BruteForce -Chars "abcdefghijklmnopqrstuvwxyz" -MinLength 1 -MaxLength $MaxBruteForceLength
    }
    
    if (-not $script:found) {
        Write-Host ""
        Write-Host "  🔡 Phase 2c: Chữ + số (a-z, 0-9), độ dài 1-$([math]::Min($MaxBruteForceLength, 5))" -ForegroundColor Cyan
        Start-BruteForce -Chars $BruteForceChars -MinLength 1 -MaxLength ([math]::Min($MaxBruteForceLength, 5))
    }
}

# ═══════════════════════════════════════
# KẾT QUẢ CUỐI CÙNG
# ═══════════════════════════════════════
Write-Host ""
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
$elapsed = (Get-Date) - $script:startTime

if ($script:found) {
    Write-Host "  ✅ THÀNH CÔNG! Mật khẩu: $($script:foundPassword)" -ForegroundColor Green
} else {
    Write-Host "  ❌ KHÔNG tìm thấy mật khẩu sau $($script:totalTried) lần thử" -ForegroundColor Red
    Write-Host "  ⏱  Thời gian: $([math]::Round($elapsed.TotalMinutes, 1)) phút" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  💡 GỢI Ý:" -ForegroundColor Yellow
    Write-Host "     - Tạo file wordlist.txt với mỗi mật khẩu 1 dòng" -ForegroundColor White
    Write-Host "     - Chạy: .\CrackRAR.ps1 -CustomWordlistPath .\wordlist.txt" -ForegroundColor White
    Write-Host "     - Tăng brute force: .\CrackRAR.ps1 -MaxBruteForceLength 8" -ForegroundColor White
    Write-Host "     - Chỉ brute force: .\CrackRAR.ps1 -BruteForceOnly" -ForegroundColor White
}

Write-Host "  Tổng: $($script:totalTried) mật khẩu | Thời gian: $([math]::Round($elapsed.TotalSeconds))s" -ForegroundColor DarkGray
Write-Host "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
