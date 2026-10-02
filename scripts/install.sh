#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================================="
echo "   CÀI ĐẶT MÔI TRƯỜNG PI CODING AGENT CHO IOS DEVELOPER   "
echo "=========================================================="

# 1. Kiểm tra Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "✗ Lỗi: Node.js chưa được cài đặt. Yêu cầu Node >= 20 (khuyên dùng Node 24 qua fnm hoặc nvm)."
    exit 1
fi

NODE_MAJOR=$(node -e 'console.log(process.versions.node.split(".")[0])')
if [ "$NODE_MAJOR" -lt 20 ]; then
    echo "✗ Lỗi: Phiên bản Node.js hiện tại ($NODE_MAJOR) quá cũ. Yêu cầu Node >= 20."
    exit 1
fi
echo "✓ Node.js $(node -v) hợp lệ."

# 2. Kiểm tra hoặc cài đặt pi CLI
if ! command -v pi >/dev/null 2>&1; then
    echo "→ Không tìm thấy 'pi'. Đang tiến hành cài đặt toàn cục @earendil-works/pi-coding-agent..."
    npm i -g @earendil-works/pi-coding-agent
fi
echo "✓ Pi CLI đã sẵn sàng: $(pi --version)"

# 3. Tạo các thư mục cần thiết
PI_AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
mkdir -p "$PI_AGENT_DIR/extensions"
mkdir -p "$HOME/.pi-lens"

echo "✓ Đã khởi tạo cấu trúc thư mục tại $PI_AGENT_DIR và ~/.pi-lens"

# 4. Sao chép các file cấu hình và extension
echo "→ Đang sao chép các extensions và cấu hình..."
cp "$SETUP_ROOT/config/extensions/compaction-policy.ts" "$PI_AGENT_DIR/extensions/"
cp "$SETUP_ROOT/config/extensions/pi-footer-cache-tps.ts" "$PI_AGENT_DIR/extensions/"
cp "$SETUP_ROOT/config/extensions/pi-footer.json" "$PI_AGENT_DIR/extensions/"
cp "$SETUP_ROOT/config/pi-lens-config.json" "$HOME/.pi-lens/config.json"

# 5. Thiết lập settings.json
SETTINGS_FILE="$PI_AGENT_DIR/settings.json"
SOURCE_SETTINGS="$SETUP_ROOT/config/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    echo "→ Tạo mới settings.json..."
    cp "$SOURCE_SETTINGS" "$SETTINGS_FILE"
else
    echo "→ Cập nhật settings.json hiện tại (merge an toàn)..."
    node -e '
    const fs = require("fs");
    const targetPath = process.argv[1];
    const sourcePath = process.argv[2];

    const target = JSON.parse(fs.readFileSync(targetPath, "utf8"));
    const source = JSON.parse(fs.readFileSync(sourcePath, "utf8"));

    // Merge packages
    const pkgSet = new Set(target.packages || []);
    for (const pkg of (source.packages || [])) {
        pkgSet.add(pkg);
    }
    target.packages = Array.from(pkgSet);

    // Merge compaction
    if (source.compaction) {
        target.compaction = target.compaction || {};
        target.compaction.enabled = source.compaction.enabled !== false;
        target.compaction.reserveTokens = target.compaction.reserveTokens || source.compaction.reserveTokens;
        target.compaction.keepRecentTokens = target.compaction.keepRecentTokens || source.compaction.keepRecentTokens;
        target.compaction.modelOverrides = Object.assign({}, source.compaction.modelOverrides, target.compaction.modelOverrides);
    }

    fs.writeFileSync(targetPath, JSON.stringify(target, null, 2), "utf8");
    ' "$SETTINGS_FILE" "$SOURCE_SETTINGS"
fi

# 6. Cài đặt các packages cần thiết vào Pi
PACKAGES=(
    "npm:pi-lens"
    "npm:pi-background-tasks"
    "npm:pi-worktree"
    "npm:pi-simplify"
    "npm:@juicesharp/rpiv-ask-user-question"
    "npm:@pi-unipi/notify"
    "npm:pi-footer"
)

echo "→ Đang cài đặt các extension vào Pi..."
for pkg in "${PACKAGES[@]}"; do
    echo "  + Cài đặt $pkg..."
    pi install "$pkg" >/dev/null 2>&1 || true
done

# 7. Chạy patch sửa lỗi stale context cho pi-footer
echo "→ Đang áp dụng bản vá chống crash stale context..."
node "$SETUP_ROOT/scripts/patch-extensions.mjs"

# 8. Cấp quyền thực thi cho các script
chmod +x "$SETUP_ROOT/scripts/"*.sh "$SETUP_ROOT/scripts/"*.mjs || true

echo ""
echo "=========================================================="
echo "   CÀI ĐẶT THÀNH CÔNG!"
echo "=========================================================="
echo ""
bash "$SETUP_ROOT/scripts/verify.sh"
