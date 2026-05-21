# 系统架构

## 目标

`uv-fast` 解决两个问题：

1. 官方安装入口在国内网络环境下可能较慢或不稳定。
2. 官方 installer 后续下载 uv 二进制时也可能访问 GitHub release，仍然慢。

因此只替换第一跳是不够的。完整链路需要同时处理：

- installer 脚本下载。
- uv 二进制包下载。
- `uv python install` 的 Python 运行时元数据。
- `uv pip install` / `uv sync` / `uv add` 使用的 PyPI 源。

## 主链路

```text
用户机器
  |
  | curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
  v
Gitee uv-custom2
  |
  | 下载缓存的 uv-installer.sh
  v
uv 官方 installer
  |
  | UV_INSTALLER_GITHUB_BASE_URL=https://uv.agentsmirror.com/github
  v
国内镜像入口 uv.agentsmirror.com
  |
  | 下载 uv 二进制
  v
用户机器安装 uv
```

## 自动刷新链路

```text
GitHub Actions
  |
  | 定时触发，每天北京时间 04:15
  v
scripts/update-gitee-uv.sh
  |
  | 查询 GitHub astral-sh/uv 最新 release
  | 下载 uv-installer.sh
  v
Gitee API
  |
  | 写入 uv-custom2 仓库
  v
uv-installer.sh
metadata/uv-latest.json
```

## 仓库职责

### GitHub: totongf/uv-fast

职责：

- 保存 `uv-fast` 源码。
- 保存详细文档。
- 运行 GitHub Actions 定时任务。
- 使用 GitHub Secrets 保存 `GITEE_TOKEN`。

不作为国内安装入口。

### Gitee: totongf/uv-custom2

职责：

- 保存最终安装入口 `install.sh`。
- 保存缓存的 `uv-installer.sh`。
- 保存版本元数据 `metadata/uv-latest.json`。
- 面向国内机器提供 raw 下载。

## 镜像入口职责

默认镜像入口：

```text
https://uv.agentsmirror.com
```

当前使用到的路径：

```text
/github/astral-sh/uv/releases/download/<tag>/...
/metadata/python-downloads.json
/pypi/simple
```

`uv-fast` 不直接存储所有 uv 二进制包，而是让 official installer 通过 `UV_INSTALLER_GITHUB_BASE_URL` 去镜像入口拉取二进制。

## 文件关系

```text
uv-fast/
  install.sh
    -> 安装入口
    -> 从 Gitee raw 下载 uv-installer.sh
    -> 设置国内镜像环境变量

  scripts/update-gitee-uv.sh
    -> 查询官方最新 release
    -> 下载官方 uv-installer.sh
    -> 写回 Gitee

  .github/workflows/update-gitee-uv.yml
    -> GitHub Actions 定时触发 update-gitee-uv.sh

  .workflow/update-gitee-uv.yml
    -> Gitee Go 定时触发 update-gitee-uv.sh
```

## 设计取舍

选择 Gitee 作为安装入口：

- 国内访问速度通常更好。
- raw 文件适合一句 `curl | sh`。

选择 GitHub Actions 作为推荐自动刷新：

- 不需要公网 IP。
- 不需要本机在线。
- 定时任务和手动触发都成熟。

保留 Gitee Go：

- 满足只用 Gitee 生态的需求。
- 账号未开通 Gitee Go 时可不用。

保留本机定时脚本：

- 适合 NAS、内网服务器、个人电脑长期在线场景。
- 不依赖 GitHub。
