#!/usr/bin/env bash
set -euo pipefail

# 一键刷新 Gitee uv 缓存。
# 使用前设置：
#   export GITEE_TOKEN="你的 Gitee 私人令牌"

OWNER="${GITEE_OWNER:-totongf}"
REPO="${GITEE_REPO:-uv-custom2}"
BRANCH="${GITEE_BRANCH:-master}"
MIRROR_BASE_URL="${UV_FAST_MIRROR_BASE_URL:-${UV_CUSTOM_MIRROR_BASE_URL:-https://uv.agentsmirror.com}}"

if [ -z "${GITEE_TOKEN:-}" ]; then
    echo "错误：请先设置 GITEE_TOKEN"
    exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "查询官方 uv 最新版本..."
official_json="$tmp_dir/github-latest.json"
curl -fsSL "https://api.github.com/repos/astral-sh/uv/releases/latest" -o "$official_json"
uv_tag="$(ruby -rjson -e 'puts JSON.parse(File.read(ARGV[0]))["tag_name"]' "$official_json")"

if [ -z "$uv_tag" ]; then
    echo "错误：无法解析官方 uv 最新版本"
    exit 1
fi

echo "官方最新版本：$uv_tag"

echo "下载官方 installer..."
curl -fsSL "https://github.com/astral-sh/uv/releases/download/$uv_tag/uv-installer.sh" \
    -o "$tmp_dir/uv-installer.sh"

cat > "$tmp_dir/uv-latest.json" <<EOF
{
  "tag": "$uv_tag",
  "installer_sh": "https://gitee.com/$OWNER/$REPO/raw/$BRANCH/uv-installer.sh",
  "mirror_base_url": "$MIRROR_BASE_URL",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

put_file() {
    local path="$1"
    local file="$2"
    local message="$3"
    local encoded status sha meta

    encoded="$(base64 < "$file" | tr -d '\n')"
    meta="$tmp_dir/meta-$(printf '%s' "$path" | tr '/.' '__').json"
    status="$(
        curl -sS -o "$meta" -w '%{http_code}' \
            "https://gitee.com/api/v5/repos/$OWNER/$REPO/contents/$path?access_token=$GITEE_TOKEN&ref=$BRANCH"
    )"

    if [ "$status" = "200" ]; then
        sha="$(ruby -rjson -e 'obj=JSON.parse(File.read(ARGV[0])); puts obj.is_a?(Hash) ? obj["sha"] : ""' "$meta")"
        if [ -n "$sha" ]; then
            curl -fsS -X PUT "https://gitee.com/api/v5/repos/$OWNER/$REPO/contents/$path" \
                --data-urlencode "access_token=$GITEE_TOKEN" \
                --data-urlencode "content=$encoded" \
                --data-urlencode "message=$message" \
                --data-urlencode "branch=$BRANCH" \
                --data-urlencode "sha=$sha" \
                >/dev/null
            return
        fi
    fi

    curl -fsS -X POST "https://gitee.com/api/v5/repos/$OWNER/$REPO/contents/$path" \
        --data-urlencode "access_token=$GITEE_TOKEN" \
        --data-urlencode "content=$encoded" \
        --data-urlencode "message=$message" \
        --data-urlencode "branch=$BRANCH" \
        >/dev/null
}

echo "更新 Gitee 缓存文件..."
put_file "uv-installer.sh" "$tmp_dir/uv-installer.sh" "更新 uv installer 到 $uv_tag"
put_file "metadata/uv-latest.json" "$tmp_dir/uv-latest.json" "更新 uv 版本元数据到 $uv_tag"

echo "完成：$OWNER/$REPO 已刷新到 $uv_tag"
