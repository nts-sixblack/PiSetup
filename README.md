# Pi Coding Agent Setup (Optimized for macOS & iOS Development)

Bộ thiết lập hoàn chỉnh, di động (portable) và tối ưu hóa cao cho **Pi Coding Agent** (`pi`), được tuyển chọn kỹ lưỡng dành riêng cho **iOS / macOS Developer** (Swift, SwiftUI, Xcode, SourceKit-LSP, Maestro).

---

## 📁 Cấu trúc thư mục PiSetup

```
PiSetup/
├── README.md                      ← Hướng dẫn tổng quan & cài đặt nhanh
├── docs/
│   └── ios-developer-guide.md     ← Hướng dẫn chuyên sâu cho quy trình iOS Dev
├── config/
│   ├── settings.json              ← Manifest các extension & cấu hình compaction
│   ├── pi-lens-config.json        ← Cấu hình LSP (được sao chép tới ~/.pi-lens/config.json)
│   └── extensions/                ← Các extension chạy local (không qua npm)
│       ├── compaction-policy.ts   ← Chính sách nén context theo % window & chống lặp lỗi
│       ├── pi-footer.json         ← Layout thanh trạng thái 3 dòng tinh gọn
│       └── pi-footer-cache-tps.ts ← Widget tính tốc độ sinh token & thời gian cache
└── scripts/
    ├── install.sh                 ← Script 1-click cài đặt toàn bộ môi trường
    ├── verify.sh                  ← Kiểm tra tính sẵn sàng của LSP, extensions & CLI
    └── patch-extensions.mjs       ← Bản vá lỗi stale context cho pi-footer khi /reload
```

---

## 🚀 Cài đặt trên máy mới (1-Click Setup)

Khi chuyển sang một máy Mac mới hoặc setup thiết bị phụ:

### Bước 1: Yêu cầu chuẩn bị
1. **Node.js (>= 20)**: Khuyên dùng `fnm` hoặc `nvm`:
   ```bash
   brew install fnm && fnm install 24 && fnm use 24
   ```
2. **Xcode & Command Line Tools**:
   ```bash
   xcode-select --install
   ```
3. **Nerd Font** (Để hiển thị đúng icon statusline):
   ```bash
   brew install --cask font-jetbrains-mono-nerd-font
   ```

### Bước 2: Chạy cài đặt tự động
Clone hoặc copy thư mục `PiSetup` này sang máy mới và chạy:
```bash
cd ~/Documents/PiSetup
./scripts/install.sh
```

Script sẽ tự động:
* Cài đặt `pi` CLI nếu chưa có.
* Cấu hình các thư mục `~/.pi/agent` và `~/.pi-lens`.
* Đồng bộ các extension chọn lọc và cấu hình tối ưu.
* Tự động vá lỗi upstream stale context.
* Chạy `verify.sh` để kiểm tra kết quả ngay lập tức.

---

## 🛠 Danh sách các Extension được tích hợp

| Gói cài đặt | Tác dụng cho iOS Developer |
|---|---|
| **`pi-lens`** | Tích hợp **SourceKit-LSP** chính chủ của Apple; kiểm tra lỗi type, syntax, Swift Concurrency (`@MainActor`, `Sendable`) tức thì. |
| **`pi-background-tasks`** | Chạy ngầm các lệnh tốn thời gian như `xcodebuild`, resolve SPM, chạy test qua `maestro` mà không block terminal. |
| **`pi-worktree`** | Quản lý Git Worktree độc lập; thử nghiệm refactor SwiftUI / Swift 6 trên branch riêng biệt mà không làm bẩn Xcode project chính. |
| **`pi-simplify`** | Tự động rà soát và dọn dẹp các đoạn code thừa, boilerplate rườm rà do AI sinh ra trong Swift. |
| **`@juicesharp/rpiv-ask-user-question`** | Hiển thị bảng hỏi lựa chọn tương tác thay vì tự đoán mò khi quyết định kiến trúc (ví dụ: SwiftData vs CoreData, NavigationStack). |
| **`@pi-unipi/notify`** | Bắn thông báo macOS khi AI chạy xong tác vụ dài, giúp bạn tập trung code trên Xcode mà không cần canh terminal. |
| **`pi-footer`** | Thanh trạng thái 3 dòng hiển thị thanh % Context Bar thực tế, tốc độ token (t/s), trạng thái Git và biểu tượng `LSP ✓`. |
| **`compaction-policy.ts`** | Tự động kích hoạt nén thông minh ở ngưỡng 40% window cho các model context lớn, nâng trần tóm tắt lên 60.000 tokens tránh lỗi đứt gãy session. |

---

## 🔍 Kiểm tra hệ thống

Bất kỳ lúc nào bạn muốn kiểm tra tình trạng hoạt động của Pi:
```bash
./scripts/verify.sh
```

---

## 💡 Lưu ý quan trọng khi cập nhật

* Khi bạn chạy `pi update` (cập nhật phiên bản các extension qua npm), npm có thể ghi đè file của `pi-footer`. Nếu gõ `/reload` trong Pi mà gặp thông báo lỗi *stale context*, hãy chạy lại script vá lỗi:
  ```bash
  node ./scripts/patch-extensions.mjs
  ```
* Xem chi tiết hướng dẫn sử dụng chuyên sâu tại [`docs/ios-developer-guide.md`](./docs/ios-developer-guide.md).
