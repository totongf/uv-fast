#!/usr/bin/env bash
set -euo pipefail

# 安装本机定时任务：每天自动刷新 Gitee uv 缓存。
# 使用前设置：
#   export GITEE_TOKEN="你的 Gitee 私人令牌"

if [ -z "${GITEE_TOKEN:-}" ]; then
    echo "错误：请先设置 GITEE_TOKEN"
    exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
update_script="$script_dir/update-gitee-uv.sh"
config_dir="$HOME/.config/uv-fast"
env_file="$config_dir/gitee.env"
log_dir="$HOME/Library/Logs"

mkdir -p "$config_dir"
umask 077
cat > "$env_file" <<EOF
GITEE_TOKEN='$GITEE_TOKEN'
GITEE_OWNER='${GITEE_OWNER:-totongf}'
GITEE_REPO='${GITEE_REPO:-uv-custom2}'
GITEE_BRANCH='${GITEE_BRANCH:-master}'
UV_FAST_MIRROR_BASE_URL='${UV_FAST_MIRROR_BASE_URL:-https://uv.agentsmirror.com}'
EOF

if command -v launchctl >/dev/null 2>&1 && [ "$(uname -s)" = "Darwin" ]; then
    plist="$HOME/Library/LaunchAgents/com.totongf.uv-fast-update.plist"
    mkdir -p "$HOME/Library/LaunchAgents" "$log_dir"
    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.totongf.uv-fast-update</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-lc</string>
    <string>source "$env_file" && bash "$update_script"</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>4</integer>
    <key>Minute</key>
    <integer>15</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>$log_dir/uv-fast-update.log</string>
  <key>StandardErrorPath</key>
  <string>$log_dir/uv-fast-update.err.log</string>
</dict>
</plist>
EOF
    launchctl unload "$plist" >/dev/null 2>&1 || true
    launchctl load "$plist"
    echo "已安装 macOS launchd 定时任务：每天 04:15 自动刷新"
    echo "日志：$log_dir/uv-fast-update.log"
else
    cron_line="15 4 * * * . '$env_file' && /bin/bash '$update_script' >> '$HOME/uv-fast-update.log' 2>&1"
    current_cron="$(mktemp)"
    new_cron="$(mktemp)"
    trap 'rm -f "$current_cron" "$new_cron"' EXIT
    crontab -l > "$current_cron" 2>/dev/null || true
    grep -vF "$update_script" "$current_cron" > "$new_cron" || true
    printf '%s\n' "$cron_line" >> "$new_cron"
    crontab "$new_cron"
    echo "已安装 cron 定时任务：每天 04:15 自动刷新"
    echo "日志：$HOME/uv-fast-update.log"
fi
