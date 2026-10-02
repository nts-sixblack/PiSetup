#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo "   KIỂM TRA HỆ THỐNG PI CHO IOS DEV"
echo "=========================================="

# 1. Kiểm tra pi command
if command -v pi >/dev/null 2>&1; then
    echo "✓ [CLI] pi đã được cài đặt: $(pi --version)"
else
    echo "✗ [CLI] Lệnh 'pi' chưa có trong PATH! Cài đặt bằng: npm i -g @earendil-works/pi-coding-agent"
    exit 1
fi

# 2. Kiểm tra SourceKit-LSP cho Swift
if command -v sourcekit-lsp >/dev/null 2>&1; then
    echo "✓ [LSP] sourcekit-lsp tìm thấy tại: $(which sourcekit-lsp)"
elif xcrun -find sourcekit-lsp >/dev/null 2>&1; then
    echo "✓ [LSP] sourcekit-lsp tìm thấy qua xcrun: $(xcrun -find sourcekit-lsp)"
else
    echo "⚠ [LSP] Chưa tìm thấy sourcekit-lsp! Hãy chắc chắn bạn đã cài Xcode và Command Line Tools ('xcode-select --install')."
fi

# 3. Kiểm tra config pi-lens
PI_LENS_CONFIG="$HOME/.pi-lens/config.json"
if [ -f "$PI_LENS_CONFIG" ]; then
    echo "✓ [LENS] File cấu hình tồn tại: $PI_LENS_CONFIG"
else
    echo "✗ [LENS] Thiếu $PI_LENS_CONFIG"
fi

# 4. Kiểm tra extension compaction & footer
COMPACTION_EXT="$HOME/.pi/agent/extensions/compaction-policy.ts"
FOOTER_CFG="$HOME/.pi/agent/extensions/pi-footer.json"
if [ -f "$COMPACTION_EXT" ]; then
    echo "✓ [EXT] compaction-policy.ts tồn tại"
else
    echo "✗ [EXT] Thiếu $COMPACTION_EXT"
fi

if [ -f "$FOOTER_CFG" ]; then
    echo "✓ [EXT] pi-footer.json tồn tại"
else
    echo "✗ [EXT] Thiếu $FOOTER_CFG"
fi

# 5. Kiểm tra các packages cài đặt
echo ""
echo "--- Danh sách extensions đang cài đặt trong Pi ---"
pi list

echo ""
echo "--- Thử nghiệm chạy Pi headless (ping test) ---"
if pi -p "ping" >/dev/null 2>&1; then
    echo "✓ [TEST] Pi khởi động và phản hồi hoàn hảo!"
else
    echo "✗ [TEST] Pi gặp lỗi khi chạy thử. Hãy kiểm tra 'pi auth check' hoặc API keys."
fi

echo ""
echo "=========================================="
echo "   HOÀN TẤT KIỂM TRA!"
echo "=========================================="
