# 自动更新方案

`uv-fast` 支持三种刷新 Gitee 缓存的方案。

推荐顺序：

1. GitHub Actions
2. Gitee Go
3. 本机定时任务

## 方案一：GitHub Actions

适合：

- 希望完全在线自动运行。
- 没有公网 IP。
- 不希望依赖本机在线。

工作方式：

```text
GitHub Actions schedule
  -> scripts/update-gitee-uv.sh
  -> Gitee API
  -> 更新 uv-custom2
```

当前配置：

```text
.github/workflows/update-gitee-uv.yml
```

触发：

```yaml
workflow_dispatch:
schedule:
  - cron: "15 20 * * *"
```

GitHub cron 使用 UTC 时间。`20:15 UTC` 等于北京时间第二天 `04:15`。

需要的 Secret：

```text
GITEE_TOKEN
```

## 方案二：Gitee Go

适合：

- 希望所有东西都在 Gitee 生态内。
- Gitee 账号已开通 Gitee Go。

配置文件：

```text
.workflow/update-gitee-uv.yml
```

需要的私密变量：

```text
UV_GITEE_TOKEN
```

注意：Gitee Go 自定义变量不能使用 `GITEE_` 前缀，所以 workflow 使用 `UV_GITEE_TOKEN`，再在执行时导出为 `GITEE_TOKEN`。

## 方案三：本机定时任务

适合：

- 有长期在线的 Mac、Linux 机器或 NAS。
- 不想依赖 GitHub Actions 或 Gitee Go。

安装：

```sh
GITEE_TOKEN=你的令牌 bash scripts/setup-local-auto-update.sh
```

macOS 会安装 launchd：

```text
~/Library/LaunchAgents/com.totongf.uv-fast-update.plist
```

Linux 会写入 crontab：

```cron
15 4 * * * . "$HOME/.config/uv-fast/gitee.env" && /bin/bash "scripts/update-gitee-uv.sh"
```

## 刷新脚本做了什么

脚本：

```text
scripts/update-gitee-uv.sh
```

执行步骤：

1. 读取官方最新 release：

```text
https://api.github.com/repos/astral-sh/uv/releases/latest
```

2. 解析 `tag_name`。
3. 下载官方 installer：

```text
https://github.com/astral-sh/uv/releases/download/<tag>/uv-installer.sh
```

4. 生成元数据：

```json
{
  "tag": "<tag>",
  "installer_sh": "https://gitee.com/totongf/uv-custom2/raw/master/uv-installer.sh",
  "mirror_base_url": "https://uv.agentsmirror.com",
  "updated_at": "..."
}
```

5. 通过 Gitee API 更新：

```text
uv-installer.sh
metadata/uv-latest.json
```

## 手动刷新

在仓库根目录执行：

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

成功输出类似：

```text
查询官方 uv 最新版本...
官方最新版本：0.11.15
下载官方 installer...
更新 Gitee 缓存文件...
完成：totongf/uv-custom2 已刷新到 0.11.15
```

## 版本校验

```sh
cached=$(curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/metadata/uv-latest.json | ruby -rjson -e 'puts JSON.parse(STDIN.read)["tag"]')
official=$(curl -fsSL https://api.github.com/repos/astral-sh/uv/releases/latest | ruby -rjson -e 'puts JSON.parse(STDIN.read)["tag_name"]')
printf 'cached=%s\nofficial=%s\n' "$cached" "$official"
test "$cached" = "$official"
```
