# uv-fast

`uv-fast` 是一个面向国内网络环境的 uv 快速安装入口。

目标是后续只用一句命令完成安装：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

安装脚本会：

- 从 Gitee 缓存下载 `uv-installer.sh`
- 安装前对比 Gitee 缓存版本和官方最新版本，不一致时给出警告
- 通过 `UV_INSTALLER_GITHUB_BASE_URL` 让 uv 二进制包走国内镜像
- 写入 `python-downloads-json-url`，让 `uv python install` 走国内元数据
- 写入 `UV_DEFAULT_INDEX`，让默认 PyPI 源走国内入口

## 目录

```text
uv-fast/
  install.sh                         # 最终 curl | sh 的安装入口
  scripts/
    update-gitee-uv.sh               # 刷新 Gitee uv 缓存
    setup-local-auto-update.sh       # 本机 launchd/cron 定时刷新
  github/
    .github/workflows/update-gitee-uv.yml
  gitee/
    .workflow/update-gitee-uv.yml
```

## 发布到 Gitee

把这些文件放到 `totongf/uv-custom2` 仓库根目录：

```text
install.sh
scripts/update-gitee-uv.sh
scripts/setup-local-auto-update.sh
.workflow/update-gitee-uv.yml
```

然后先手动刷新一次缓存：

```sh
GITEE_TOKEN=你的私人令牌 bash scripts/update-gitee-uv.sh
```

刷新后仓库会出现：

```text
uv-installer.sh
metadata/uv-latest.json
```

## GitHub Actions 在线自动刷新

把 `uv-fast/github/.github/workflows/update-gitee-uv.yml` 放到 GitHub 仓库的 `.github/workflows/update-gitee-uv.yml`。

在 GitHub 仓库中添加 Secret：

```text
GITEE_TOKEN=你的 Gitee 私人令牌
```

它会每天北京时间 04:15 自动执行，也支持手动 `Run workflow`。

可选 Variables：

- `GITEE_OWNER`：默认 `totongf`
- `GITEE_REPO`：默认 `uv-custom2`
- `GITEE_BRANCH`：默认 `master`
- `UV_FAST_MIRROR_BASE_URL`：默认 `https://uv.agentsmirror.com`

## Gitee Go 在线自动刷新

把 `uv-fast/gitee/.workflow/update-gitee-uv.yml` 放到 Gitee 仓库的 `.workflow/update-gitee-uv.yml`。

在 Gitee Go 流水线变量中添加：

```text
UV_GITEE_TOKEN=你的 Gitee 私人令牌
```

设置为私密变量。流水线会每天 04:15 自动执行，也可以手动运行。

## 本机自动刷新

不想用在线 CI 时，可以在本机或 NAS 上安装定时任务：

```sh
GITEE_TOKEN=你的私人令牌 bash scripts/setup-local-auto-update.sh
```

这个方案不需要公网 IP。

## 安全

- 不要把 Gitee 令牌写进仓库文件。
- GitHub 使用 Secrets，Gitee Go 使用私密变量。
- 不要在脚本中打印令牌。
- 建议单独创建一个只用于 `uv-custom2` 的 Gitee 令牌。
