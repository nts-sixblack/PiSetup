# Hướng Dẫn Sử Dụng Pi Cho iOS Developer

Tài liệu này hướng dẫn cách khai thác tối đa sức mạnh của bộ công cụ **Pi Coding Agent** kết hợp với hệ sinh thái lập trình iOS (Swift, SwiftUI, UIKit, Xcode, SPM, Maestro).

---

## 1. Code Intelligence với `pi-lens` & `sourcekit-lsp`

### Cách thức hoạt động
Xcode cung cấp sẵn Language Server Protocol chính chủ của Apple tại `/usr/bin/sourcekit-lsp` (hoặc thông qua `xcrun sourcekit-lsp`). 
Extension **`pi-lens`** tự động nhận diện và kết nối với server này khi bạn mở project Swift hoặc thư mục có file `Package.swift`.

### Lợi ích thực tế cho iOS Dev
* **Bắt lỗi compile ngay khi sinh code:** Khi AI viết code Swift, `pi-lens` kiểm tra cú pháp và kiểu dữ liệu ngay lập tức, phát hiện lỗi thiếu protocol, sai parameter, hoặc type mismatch mà không cần bạn phải chuyển sang Xcode nhấn `Cmd + B`.
* **Kiểm tra Swift 6 Concurrency:** Các cảnh báo về `@MainActor`, `Sendable`, data race giữa các Task/Actor được bắt ngay từ terminal.
* **Jump to Definition & Symbol Search:** AI có thể tra cứu struct, protocol, class định nghĩa ở đâu trong toàn bộ codebase thay vì phải grep text mù quáng.

### File cấu hình (`~/.pi-lens/config.json`)
```json
{
  "lsp": { "enabled": true },
  "widget": { "visible": false },
  "format": { "enabled": false },
  "autofix": { "enabled": false },
  "ui": {
    "compactLspStatus": true
  }
}
```
* `widget.visible: false`: Tắt banner hiển thị danh sách file phía trên trình soạn thảo để không chiếm chỗ màn hình terminal.
* `ui.compactLspStatus: true`: Trạng thái LSP trên footer được hiển thị dạng tinh gọn `LSP ✓` (hoặc `LSP ✗` nếu lỗi).

---

## 2. Xử lý tác vụ nặng với `pi-background-tasks`

Build một dự án iOS hoặc chạy test bằng Xcode có thể mất từ vài phút đến cả chục phút. Nếu để AI chạy chặn (blocking), bạn sẽ phải ngồi chờ và không thể trao đổi gì thêm.

### Ví dụ áp dụng:
* **Chạy build nền:**
  > *"Hãy chạy build project trong background bằng xcodebuild để kiểm tra xem có lỗi linker nào không."*
* **Chạy UI Test qua Maestro:**
  > *"Chạy file Maestro flow test đăng nhập dưới nền và báo cho tôi khi hoàn tất."*

AI sẽ kích hoạt lệnh qua background task runner, tiếp tục phân tích kiến trúc với bạn trong lúc máy đang compile.

---

## 3. Thử nghiệm tính năng độc lập với `pi-worktree`

Dự án iOS mở bằng Xcode thường rất nhạy cảm với việc đổi branch hoặc sửa file trực tiếp (Xcode phải index lại, resolve lại package).

Khi bạn muốn AI làm các task thử nghiệm:
* Refactor một màn hình phức tạp từ UIKit sang SwiftUI.
* Thử nghiệm migration sang Swift 6 Concurrency.
* Thử nghiệm một thư viện SPM mới.

Chỉ cần yêu cầu:
> *"Tạo một worktree mới cho task refactor UserService sang Concurrency."*

`pi-worktree` sẽ tạo một thư mục nhánh git riêng biệt. AI thao tác, sửa đổi và kiểm tra trên nhánh đó mà không làm đụng chạm đến thư mục code chính đang mở trong Xcode của bạn. Khi ưng ý, bạn chỉ việc merge lại.

---

## 4. Quản lý Context & Compaction chống Crash

Project iOS có cấu trúc thư mục sâu và nhiều boilerplate (Coordinator, ViewModel, View, Data Model, API Service). Context của session AI rất nhanh đầy khi trao đổi về một module lớn.

### Vấn đề thường gặp của Pi:
Mặc định Pi chỉ dành khoảng ~13.000 tokens cho bản tóm tắt (summary). Khi một phiên làm việc dài và nhiều file, summary vượt ngưỡng 13k tokens sẽ khiến phiên bị crash: `Compaction failed: Summarization failed: generation hit the token cap`.

### Giải pháp trong bộ setup này:
* `compaction-policy.ts`: Tự động nhận diện dung lượng context window của model:
  * Model context lớn (≥ 500K tokens như Gemini, DeepSeek): chỉ kích hoạt nén khi đã dùng **40% window**, giúp tận dụng tối đa bộ nhớ ngữ cảnh.
  * Khi nén thất bại: tự động tạm dừng thử lại trong 10 phút (backoff), tránh spam request lỗi liên tục.
* `settings.json`: Cấu hình `reserveTokens: 60000` cho các model context lớn, cho phép bản tóm tắt dài tới 48.000 tokens, đảm bảo phiên làm việc dài ngày không bao giờ bị đứt mạch.

---

## 5. Tự động thông báo qua `@pi-unipi/notify`

Khi bạn giao cho Pi các task dài:
* Sinh bộ Unit Test cho toàn bộ ViewModel.
* Viết tài liệu mô tả API cho SDK.
* Reorganize lại cấu trúc thư mục theo chuẩn MVVM-C.

Bạn có thể chuyển sang Xcode code việc khác. Khi Pi hoàn thành hoặc cần sự can thiệp của bạn, macOS Notification sẽ xuất hiện kèm âm thanh thông báo.

---

## 6. Giao diện Terminal tối ưu với `pi-footer`

Statusline được tinh chỉnh hiển thị 3 dòng cực kỳ trực quan:
* **Dòng 1:** Thư mục làm việc · Model & Provider đang dùng · Thinking level.
* **Dòng 2:** Thanh Context Bar (đổi màu xanh → vàng khi ≥70% → đỏ khi ≥90%) · Cache hit rate · Tốc độ sinh token (t/s) · Tổng thời gian phiên.
* **Dòng 3:** Git branch · Trạng thái git diff · Chi phí ước tính · Trạng thái MCP · Trạng thái Worktree · Trạng thái Background tasks · Trạng thái `LSP ✓`.

> **Mẹo:** Cài đặt font **JetBrains Mono Nerd Font** trên macOS để hiển thị trọn vẹn các biểu tượng icon trên thanh statusline:
> ```bash
> brew install --cask font-jetbrains-mono-nerd-font
> ```
