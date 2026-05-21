# uv-fast 文档中心

这里存放 `uv-fast` 的完整说明文档。

`uv-fast` 的目标是提供一个适合国内网络环境的一句命令安装入口：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

## 文档导航

- [快速开始](quick-start.md)：安装、验证、常用命令。
- [系统架构](architecture.md)：GitHub、Gitee、镜像入口和本机脚本之间的关系。
- [安装脚本说明](installer.md)：`install.sh` 具体做了什么，以及可配置环境变量。
- [自动更新方案](auto-update.md)：GitHub Actions、Gitee Go、本机定时三种方案。
- [GitHub Actions 配置](github-actions.md)：如何配置在线定时任务和 Secrets。
- [Gitee Go 配置](gitee-go.md)：如何在 Gitee 生态内完成自动刷新。
- [安全与令牌](security.md)：令牌权限、泄露处理、日志风险。
- [故障排查](troubleshooting.md)：常见错误、检查命令和处理方式。
- [运维手册](operations.md)：日常检查、手动刷新、版本校验、发布流程。

## 当前推荐方案

推荐主链路：

```text
GitHub Actions 定时任务
  -> 拉取 astral-sh/uv 最新 release
  -> 写回 Gitee totongf/uv-custom2
  -> 国内机器通过 Gitee raw 安装
```

原因：

- 不需要公网 IP。
- 不依赖本机长期在线。
- GitHub Actions 定时任务稳定，支持手动触发。
- Gitee 作为国内安装入口，下载体验更直接。

## 仓库角色

当前有两个仓库角色：

- GitHub：`https://github.com/totongf/uv-fast`
  - 保存源码、文档和 GitHub Actions 定时任务。
  - 负责定时刷新 Gitee 缓存。
- Gitee：`https://gitee.com/totongf/uv-custom2`
  - 保存安装入口和缓存文件。
  - 面向最终安装用户提供 `curl | sh`。

## 关键文件

```text
install.sh
scripts/update-gitee-uv.sh
scripts/setup-local-auto-update.sh
.github/workflows/update-gitee-uv.yml
.workflow/update-gitee-uv.yml
metadata/uv-latest.json
uv-installer.sh
```

其中 `metadata/uv-latest.json` 和 `uv-installer.sh` 是刷新脚本生成或更新的缓存文件。
