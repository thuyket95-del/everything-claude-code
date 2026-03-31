"""
╔══════════════════════════════════════════════════════════════╗
║           RAR/ZIP PASSWORD CRACKER v2.0 (Python)            ║
║           Multi-threaded · Dictionary + Brute Force         ║
║           Sử dụng 7-Zip engine                              ║
╚══════════════════════════════════════════════════════════════╝
"""

import subprocess
import sys
import time
import itertools
import string
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
from threading import Lock, Event

# ═══════════════════════════════════════
# CẤU HÌNH
# ═══════════════════════════════════════
ARCHIVE_PATH = r"BAN VIP.zip"
SEVEN_ZIP = r"C:\Program Files\7-Zip\7z.exe"
MAX_WORKERS = 8  # Số luồng song song
BRUTE_FORCE_MAX_LEN = 6

# Trạng thái toàn cục
lock = Lock()
found_event = Event()
total_tried = 0
found_password = ""
start_time = time.time()


def test_password(password):
    """Kiểm tra 1 mật khẩu bằng 7-Zip"""
    global total_tried, found_password

    if found_event.is_set():
        return True

    with lock:
        total_tried += 1
        count = total_tried

    if count % 100 == 0:
        elapsed = time.time() - start_time
        speed = count / elapsed if elapsed > 0 else 0
        print(f"\r  ⏱  Đã thử: {count:,} | Tốc độ: {speed:.0f} pw/s | Thời gian: {elapsed:.0f}s   ", end="", flush=True)

    try:
        result = subprocess.run(
            [SEVEN_ZIP, "t", ARCHIVE_PATH, f"-p{password}"],
            capture_output=True, text=True, timeout=30,
            creationflags=subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0
        )
        output = result.stdout + result.stderr

        if "Wrong password" not in output and "ERROR" not in output and result.returncode == 0:
            found_event.set()
            found_password = password
            return True
    except Exception:
        pass

    return False


def print_banner():
    os.system("cls" if os.name == "nt" else "clear")
    size_mb = os.path.getsize(ARCHIVE_PATH) / (1024 * 1024)
    print()
    print("  ╔══════════════════════════════════════════════════════╗")
    print("  ║      🔐 RAR/ZIP PASSWORD CRACKER v2.0 (Python)     ║")
    print("  ║      Multi-threaded · Powered by 7-Zip             ║")
    print("  ╠══════════════════════════════════════════════════════╣")
    print(f"  ║  File    : {os.path.basename(ARCHIVE_PATH):<41}║")
    print(f"  ║  Size    : {size_mb:.1f} MB{' ' * 37}║")
    print(f"  ║  Threads : {MAX_WORKERS:<41}║")
    print("  ╚══════════════════════════════════════════════════════╝")
    print()


def print_success(password):
    elapsed = time.time() - start_time
    print()
    print()
    print("  ╔══════════════════════════════════════════════════════╗")
    print("  ║  🎉🎉🎉 TÌM THẤY MẬT KHẨU! 🎉🎉🎉              ║")
    print("  ╠══════════════════════════════════════════════════════╣")
    print(f"  ║  🔑 Mật khẩu : {password:<36}║")
    print(f"  ║  🔢 Số lần thử: {total_tried:<35}║")
    print(f"  ║  ⏱  Thời gian : {elapsed:.1f}s{' ' * 33}║")
    print("  ╚══════════════════════════════════════════════════════╝")
    print()
    # Lưu ra file
    with open("FOUND_PASSWORD.txt", "w", encoding="utf-8") as f:
        f.write(f"MẬT KHẨU: {password}\n")
        f.write(f"File: {ARCHIVE_PATH}\n")
        f.write(f"Số lần thử: {total_tried}\n")
        f.write(f"Thời gian: {elapsed:.1f}s\n")


def get_smart_wordlist():
    """Tạo wordlist thông minh dựa trên thông tin đã biết"""
    words = []

    # ── Nhóm 1: Từ khóa cốt lõi ──
    core = [
        # Dinh Duc variations
        "dinhducsoftware", "DINHDUCSOFTWARE", "DinhDucSoftware", "Dinhducsoftware",
        "dinhduc", "DinhDuc", "DINHDUC", "dinhducsoft", "DinhDucSoft",
        "hadinhduc", "HaDinhDuc", "HADINHDUC",
        "hadinhduc1006", "dinhduc1006", "duc1006", "dinh1006",
        # Phone/bank
        "09044086993", "0964788685", "964788685", "9044086993",
        # Nest software
        "nest", "Nest", "NEST", "nest7", "Nest7", "NEST7",
        "nest7191", "Nest7191", "NEST7191", "nestv7191", "NestV7191",
        "nestpro", "NestPro", "NESTPRO", "nestpro7", "NestPro7",
        "nest++", "Nest++", "nest++pro", "Nest++Pro",
        "v7191", "V7191", "7191",
        # Other software
        "optitex", "Optitex", "OPTITEX",
        "gerber", "Gerber", "GERBER", "AccuMark", "accumark",
        "autonester", "AutoNester", "codemeter", "CodeMeter",
        "dongle", "Dongle", "DONGLE",
        # File name
        "Nest_V7191_Dongle_3-11119130", "Nest_V7191_Dongle_3",
        "Nest_V7191_Dongle", "Nest_V7191", "11119130", "3-11119130",
        # BAN VIP
        "BANVIP", "banvip", "BanVip", "vip", "VIP", "Vip",
        # Common
        "123", "1234", "12345", "123456", "1234567", "12345678",
        "123456789", "1234567890", "000000", "111111", "888888", "666666",
        "abc123", "abcd1234", "qwerty", "password", "Password",
        "admin", "Admin", "letmein", "welcome", "master",
        # Social
        "facebook", "youtube", "telegram", "zalo",
        "j2team", "J2TEAM",
        # Crack
        "crack", "Crack", "CRACK", "keygen", "KeyGen",
        "fullcrack", "FullCrack", "cracked", "patch", "serial",
        "license", "activate", "register",
        # Common VN
        "matkhau", "mk", "pass", "Pass", "PASS",
        "software", "Software", "download", "free", "pro", "Pro", "full", "Full",
        "setup", "Setup",
    ]
    words.extend(core)

    # ── Nhóm 2: Biến thể với hậu tố ──
    important = [
        "dinhducsoftware", "dinhduc", "hadinhduc", "nest", "nest7",
        "optitex", "gerber", "vip", "crack", "admin", "password",
        "nestpro", "dongle", "codemeter", "full", "pro", "setup",
        "keygen", "serial", "patch", "banvip", "duc", "soft",
    ]
    suffixes = [
        "1", "2", "3", "7", "8", "9", "01", "07", "10",
        "12", "13", "69", "86", "88", "99",
        "123", "456", "789", "007", "111", "222", "333", "666", "777", "888", "999",
        "1234", "1006", "2024", "2025", "2026", "7191",
        "!", "@", "#", "$", "*", ".",
        "!@#", "!!", "@@",
    ]
    for w in important:
        for s in suffixes:
            words.append(f"{w}{s}")
            words.append(f"{w.upper()}{s}")
            words.append(f"{w.capitalize()}{s}")
            words.append(f"{s}{w}")

    # ── Nhóm 3: Kết hợp ──
    parts1 = ["dinh", "duc", "ha", "nest", "vip", "pro", "soft", "crack", "full", "key", "gen", "code"]
    parts2 = ["duc", "soft", "ware", "7", "7191", "vip", "pro", "123", "1006", "888", "crack", "nest", "meter", "gen"]
    for p1 in parts1:
        for p2 in parts2:
            if p1 != p2:
                words.append(f"{p1}{p2}")
                words.append(f"{p1}_{p2}")
                words.append(f"{p1}-{p2}")
                words.append(f"{p1}{p2}".upper())
                words.append(f"{p1}{p2}".capitalize())

    # ── Nhóm 4: Ngày tháng ──
    for y in range(1988, 2006):
        for m in ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]:
            for d in ["01", "06", "10", "15", "20", "25"]:
                words.append(f"{d}{m}{y}")
                words.append(f"{y}{m}{d}")
                words.append(f"{d}{m}{str(y)[2:]}")

    # ── Nhóm 5: Mật khẩu phổ biến quốc tế ──
    common_global = [
        "password1", "qwerty123", "iloveyou", "dragon", "monkey",
        "shadow", "sunshine", "princess", "football", "charlie",
        "access", "hello", "trustno1", "test", "guest",
        "p@ssw0rd", "P@ssw0rd", "passw0rd", "Passw0rd",
        "P@ss1234", "Admin123", "Root123", "Test123",
        "superman", "batman", "master123", "login",
        "abc1234", "pass1234", "1q2w3e4r", "qwer1234",
        "asdf1234", "zxcv1234", "1qaz2wsx",
        "nothing", "please", "enter",
    ]
    words.extend(common_global)

    # ── Nhóm 6: Keyboard patterns ──
    patterns = [
        "1q2w3e", "q1w2e3", "1qaz", "2wsx", "3edc",
        "zaq1", "xsw2", "cde3", "1qaz2wsx", "zaq12wsx",
        "qazwsx", "qazwsxedc", "asdfgh", "asdfghjkl",
        "zxcvbn", "zxcvbnm", "poiuyt", "lkjhgf",
        "mnbvcx", "asd123", "qwe123", "zxc123",
    ]
    words.extend(patterns)

    # Loại bỏ trùng lặp, giữ thứ tự
    seen = set()
    unique = []
    for w in words:
        if w and w not in seen:
            seen.add(w)
            unique.append(w)

    return unique


def run_dictionary_attack(wordlist):
    """Chạy dictionary attack đa luồng"""
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  📖 PHASE 1: Dictionary Attack (Từ điển thông minh)")
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  📝 Tổng mật khẩu: {len(wordlist):,}")
    print()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {}
        for pw in wordlist:
            if found_event.is_set():
                break
            f = executor.submit(test_password, pw)
            futures[f] = pw

        for f in as_completed(futures):
            if found_event.is_set():
                # Hủy các task còn lại
                for remaining in futures:
                    remaining.cancel()
                break

    if found_event.is_set():
        return True

    print()
    print("  ⚠️  Dictionary attack hoàn tất - chưa tìm thấy")
    return False


def run_brute_force():
    """Chạy brute force attack đa luồng"""
    print()
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  💪 PHASE 2: Brute Force Attack")
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("  ⚠️  Nhấn Ctrl+C để dừng bất cứ lúc nào")

    phases = [
        ("🔢 Chỉ số (0-9)", string.digits, 1, 10),
        ("🔤 Chữ thường (a-z)", string.ascii_lowercase, 1, BRUTE_FORCE_MAX_LEN),
        ("🔡 Chữ thường + số", string.ascii_lowercase + string.digits, 1, min(BRUTE_FORCE_MAX_LEN, 5)),
        ("🔠 Chữ HOA + thường + số", string.ascii_letters + string.digits, 1, min(BRUTE_FORCE_MAX_LEN, 4)),
    ]

    for desc, charset, min_len, max_len in phases:
        if found_event.is_set():
            break

        print()
        print(f"  {desc}, độ dài {min_len}-{max_len}")

        for length in range(min_len, max_len + 1):
            if found_event.is_set():
                break

            total_combos = len(charset) ** length
            print(f"  📏 Độ dài {length}: ~{total_combos:,} tổ hợp")

            batch = []
            batch_size = MAX_WORKERS * 4

            for combo in itertools.product(charset, repeat=length):
                if found_event.is_set():
                    break

                pw = "".join(combo)
                batch.append(pw)

                if len(batch) >= batch_size:
                    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
                        list(executor.map(test_password, batch))
                    batch = []

                    if found_event.is_set():
                        break

            # Xử lý batch còn lại
            if batch and not found_event.is_set():
                with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
                    list(executor.map(test_password, batch))

    return found_event.is_set()


def main():
    global start_time

    if not os.path.exists(ARCHIVE_PATH):
        print(f"  ❌ Không tìm thấy file: {ARCHIVE_PATH}")
        sys.exit(1)
    if not os.path.exists(SEVEN_ZIP):
        print(f"  ❌ Không tìm thấy 7-Zip: {SEVEN_ZIP}")
        sys.exit(1)

    print_banner()
    start_time = time.time()

    # Phase 1: Dictionary
    wordlist = get_smart_wordlist()
    if run_dictionary_attack(wordlist):
        print_success(found_password)
        return

    # Phase 2: Custom wordlist nếu có
    if os.path.exists("wordlist.txt"):
        print()
        print("  📂 Tìm thấy wordlist.txt, đang thử...")
        with open("wordlist.txt", "r", encoding="utf-8", errors="ignore") as f:
            custom = [line.strip() for line in f if line.strip()]
        print(f"  📝 Số mật khẩu: {len(custom):,}")
        with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
            list(executor.map(test_password, custom))
        if found_event.is_set():
            print_success(found_password)
            return

    # Phase 3: Brute force
    try:
        if run_brute_force():
            print_success(found_password)
            return
    except KeyboardInterrupt:
        print()
        print("  ⛔ Đã dừng bởi người dùng (Ctrl+C)")

    # Kết quả cuối
    elapsed = time.time() - start_time
    print()
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"  ❌ Không tìm thấy mật khẩu sau {total_tried:,} lần thử")
    print(f"  ⏱  Thời gian: {elapsed:.0f}s ({elapsed/60:.1f} phút)")
    print()
    print("  💡 GỢI Ý:")
    print("     - Tạo file wordlist.txt cùng thư mục (mỗi dòng 1 mật khẩu)")
    print("     - Liên hệ Dinh Duc qua Zalo: +84 964 788 685")
    print("  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print()


if __name__ == "__main__":
    main()
