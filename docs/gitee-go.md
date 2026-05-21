# Gitee Go 配置

Gitee Go 是只使用 Gitee 生态时的在线自动刷新方案。

## 配置文件

```text
.workflow/update-gitee-uv.yml
```

这个文件应放在 Gitee 仓库根目录的 `.workflow/` 目录下。

## 当前目标仓库

```text
https://gitee.com/totongf/uv-custom2
```

## 定时规则

```yaml
triggers:
  schedule:
    - cron: '15 4 * * ?'
```

含义：

```text
每天 04:15 执行
```

## 必需变量

在 Gitee Go 流水线变量中添加私密变量：

```text
UV_GITEE_TOKEN
```

值为 Gitee 私人令牌。

不要命名为 `GITEE_TOKEN`。Gitee Go 对 `GITEE_` 前缀有保留限制，所以这里使用 `UV_GITEE_TOKEN`。

workflow 内部会执行：

```sh
export GITEE_TOKEN="$UV_GITEE_TOKEN"
```

## 默认变量

```yaml
variables:
  GITEE_OWNER_NAME: totongf
  GITEE_REPO_NAME: uv-custom2
  GITEE_BRANCH_NAME: master
  UV_FAST_MIRROR_BASE_URL: https://uv.agentsmirror.com
```

如果 fork 到其他账号，需要修改这些变量。

## 手动运行

在 Gitee 仓库打开：

```text
流水线 / Gitee Go
```

找到 `更新 uv 缓存`，手动运行一次。

成功后检查 Gitee 仓库是否更新：

```text
uv-installer.sh
metadata/uv-latest.json
```

## 适用限制

Gitee Go 是否可用取决于账号是否开通、配额是否足够、流水线功能是否可访问。

如果 Gitee Go 不可用，建议使用 GitHub Actions。GitHub Actions 不影响 Gitee 作为最终安装入口。
