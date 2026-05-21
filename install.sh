#!/bin/sh
set -eu

# Gitee 上缓存的 uv installer 与版本元数据。
GITEE_RAW_BASE="${UV_FAST_GITEE_RAW_BASE:-https://gitee.com/totongf/uv-custom2/raw/master}"

# uv 二进制、Python 运行时与 PyPI 代理使用的国内镜像入口。
MIRROR_BASE_URL="${UV_FAST_MIRROR_BASE_URL:-https://uv.agentsmirror.com}"

json_value() {
  key="$1"
  sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1
}

warn_if_cache_outdated() {
  cached_tag=""
  official_tag=""

  if cached_json=$(curl -fsSL "$GITEE_RAW_BASE/metadata/uv-latest.json" 2>/dev/null); then
    cached_tag=$(printf '%s\n' "$cached_json" | json_value tag)
  fi

  if official_json=$(curl -fsSL "https://api.github.com/repos/astral-sh/uv/releases/latest" 2>/dev/null); then
    official_tag=$(printf '%s\n' "$official_json" | json_value tag_name)
  fi

  if [ -n "$cached_tag" ] && [ -n "$official_tag" ] && [ "$cached_tag" != "$official_tag" ]; then
    echo "警告：Gitee 缓存的 uv 版本是 $cached_tag，官方最新版本是 $official_tag。"
    echo "      请执行刷新脚本更新 Gitee 缓存：bash scripts/update-gitee-uv.sh"
  fi
}

append_managed_block() {
  target_file="$1"
  managed_block=$(cat <<EOF_BLOCK
# >>> uv-fast managed block >>>
export UV_INSTALLER_GITHUB_BASE_URL="$MIRROR_BASE_URL/github"
export UV_PYTHON_DOWNLOADS_JSON_URL="$MIRROR_BASE_URL/metadata/python-downloads.json"
export UV_DEFAULT_INDEX="$MIRROR_BASE_URL/pypi/simple"
# <<< uv-fast managed block <<<
EOF_BLOCK
)

  mkdir -p "$(dirname "$target_file")"
  touch "$target_file"

  if grep -qF "# >>> uv-fast managed block >>>" "$target_file"; then
    awk '
      BEGIN {skip=0}
      /^# >>> uv-fast managed block >>>/ {skip=1; next}
      /^# <<< uv-fast managed block <<</ {skip=0; next}
      !skip {print}
    ' "$target_file" > "$target_file.tmp"
    mv "$target_file.tmp" "$target_file"
  fi

  printf '\n%s\n' "$managed_block" >> "$target_file"
}

write_uv_config() {
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/uv"
  config_file="$config_dir/uv.toml"
  timestamp=$(date +%Y%m%d%H%M%S)
  tmp_file=$(mktemp)
  mkdir -p "$config_dir"

  if [ -f "$config_file" ]; then
    cp "$config_file" "$config_file.$timestamp.bak"
    while IFS= read -r line || [ -n "$line" ]; do
      trimmed=$(printf '%s' "$line" | sed 's/^[[:space:]]*//')
      case "$trimmed" in
        python-downloads-json-url\ =*|pypy-install-mirror\ =*)
          continue
          ;;
      esac
      printf '%s\n' "$line" >> "$tmp_file"
    done < "$config_file"
  fi

  if [ -s "$tmp_file" ]; then
    printf '\n' >> "$tmp_file"
  fi

  printf 'python-downloads-json-url = "%s/metadata/python-downloads.json"\n' "$MIRROR_BASE_URL" >> "$tmp_file"
  mv "$tmp_file" "$config_file"
}

install_uv() {
  installer_file=$(mktemp)
  trap 'rm -f "$installer_file"' EXIT HUP INT TERM
  curl -LsSf "$GITEE_RAW_BASE/uv-installer.sh" -o "$installer_file"
  env UV_INSTALLER_GITHUB_BASE_URL="$MIRROR_BASE_URL/github" sh "$installer_file"
  rm -f "$installer_file"
  trap - EXIT HUP INT TERM
}

warn_if_cache_outdated
install_uv
write_uv_config

if [ -n "${SHELL:-}" ]; then
  case "${SHELL##*/}" in
    zsh) append_managed_block "$HOME/.zshrc" ;;
    bash) append_managed_block "$HOME/.bashrc" ;;
  esac
fi

append_managed_block "$HOME/.profile"
