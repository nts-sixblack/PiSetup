#!/usr/bin/env node
/**
 * patch-extensions.mjs
 * Vá lỗi "stale extension ctx" trong pi-footer khi /reload hoặc đổi session.
 */
import fs from "node:fs";
import os from "node:os";
import path from "node:path";

const say = (msg = "") => process.stdout.write(`${msg}\n`);
const complain = (msg = "") => process.stderr.write(`${msg}\n`);

const agentDir = process.env.PI_CODING_AGENT_DIR || path.join(os.homedir(), ".pi", "agent");
const footerIndex = path.join(agentDir, "npm", "node_modules", "pi-footer", "src", "index.ts");

if (!fs.existsSync(footerIndex)) {
  complain(`✗ Không tìm thấy ${footerIndex}. Hãy chắc chắn đã cài pi-footer (pi install npm:pi-footer).`);
  process.exit(1);
}

const source = fs.readFileSync(footerIndex, "utf8");

const anchor = [
  "        render(width: number): string[] {",
  "          const data = collectStatuslineData(ctx, pi, footerData, eventWidgets.values, {",
  "            config,",
  "            requestRender: () => tui.requestRender(),",
  "            textVerbosity: liveTextVerbosity,",
  "          });",
].join("\n");

const replacement = [
  "        render(width: number): string[] {",
  "          let data: StatuslineData;",
  "          try {",
  "            data = collectStatuslineData(ctx, pi, footerData, eventWidgets.values, {",
  "              config,",
  "              requestRender: () => tui.requestRender(),",
  "              textVerbosity: liveTextVerbosity,",
  "            });",
  "          } catch {",
  "            // ctx is invalidated by ctx.reload()/newSession(), and pi treats any use of an",
  "            // invalidated ctx as fatal. The next session_start re-applies this footer with a",
  "            // fresh ctx, so skip this frame rather than throwing out of render.",
  "            return [];",
  "          }",
].join("\n");

if (source.includes("return [];\n          }\n          const lines = renderStatuslines(widgetStore, data, width, {")) {
  say("✓ pi-footer: Đã được vá trước đó (stale ctx guard).");
  process.exit(0);
}

if (!source.includes(anchor)) {
  complain("✗ pi-footer: Không tìm thấy đoạn code anchor cần vá (có thể bản pi-footer đã thay đổi code upstream).");
  process.exit(1);
}

// Backup file gốc
const backupPath = `${footerIndex}.bak`;
if (!fs.existsSync(backupPath)) {
  fs.copyFileSync(footerIndex, backupPath);
}

// Ghi đè file
fs.writeFileSync(footerIndex, source.replace(anchor, replacement), "utf8");
say("✓ pi-footer: Đã vá thành công lỗi stale ctx khi /reload!");
process.exit(0);
