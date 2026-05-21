# uv-fast

`uv-fast` 是一个面向国内网络环境的 uv 快速安装入口。

最终安装命令：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

安装脚本会：

- 从 Gitee 缓存下载 `uv-installer.sh`
- 安装前对比 Gitee 缓存版本和官方最新版本，不一致时给出警告
- 通过 `UV_INSTALLER_GITHUB_BASE_URL` 让 uv 二进制包走国内镜像
- 写入 `python-downloads-json-url`，让 `uv python install` 走国内元数据
- 写入 `UV_DEFAULT_INDEX`，让默认 PyPI 源走国内入口

## 当前状态

当前自动更新链路已经配置：

```text
GitHub Actions 定时任务
  -> 更新 Gitee uv-custom2 缓存
  -> 国内用户通过 Gitee raw 安装
```

定时任务默认每天北京时间 `04:15` 执行，也可以在 GitHub Actions 页面手动运行。

## 文档

详细文档见 [docs/README.md](docs/README.md)。

常用入口：

- [快速开始](docs/quick-start.md)
- [系统架构](docs/architecture.md)
- [安装脚本说明](docs/installer.md)
- [自动更新方案](docs/auto-update.md)
- [GitHub Actions 配置](docs/github-actions.md)
- [Gitee Go 配置](docs/gitee-go.md)
- [安全与令牌](docs/security.md)
- [故障排查](docs/troubleshooting.md)
- [运维手册](docs/operations.md)

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
  docs/
    README.md
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

配置说明见 [docs/github-actions.md](docs/github-actions.md)。

## Gitee Go 在线自动刷新

配置说明见 [docs/gitee-go.md](docs/gitee-go.md)。

## 本机自动刷新

不想用在线 CI 时，可以在本机或 NAS 上安装定时任务：

```sh
GITEE_TOKEN=你的私人令牌 bash scripts/setup-local-auto-update.sh
```

这个方案不需要公网 IP。

## 安全

安全说明见 [docs/security.md](docs/security.md)。
