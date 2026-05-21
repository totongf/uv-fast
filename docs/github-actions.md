# GitHub Actions 配置

GitHub Actions 是当前推荐的在线自动刷新方案。

## 当前仓库

```text
https://github.com/totongf/uv-fast
```

Workflow 文件：

```text
.github/workflows/update-gitee-uv.yml
```

## 定时规则

```yaml
schedule:
  - cron: "15 20 * * *"
```

GitHub cron 使用 UTC 时间。

对应北京时间：

```text
每天 04:15
```

同时支持手动触发：

```yaml
workflow_dispatch:
```

## 必需 Secret

进入 GitHub 仓库：

```text
Settings > Secrets and variables > Actions > Secrets
```

添加：

```text
GITEE_TOKEN
```

值为 Gitee 私人令牌。

不要把令牌写进 workflow 文件。

## 可选 Variables

进入：

```text
Settings > Secrets and variables > Actions > Variables
```

可配置：

```text
GITEE_OWNER=totongf
GITEE_REPO=uv-custom2
GITEE_BRANCH=master
UV_FAST_MIRROR_BASE_URL=https://uv.agentsmirror.com
```

不配置时 workflow 使用默认值。

## 手动运行

打开：

```text
https://github.com/totongf/uv-fast/actions
```

选择：

```text
Update Gitee uv cache
```

点击：

```text
Run workflow
```

## 检查运行结果

成功时状态应为：

```text
status=completed
conclusion=success
```

如果失败，优先看这几个步骤：

- `Check secret`
- `Update Gitee uv cache`

## 常见失败

### 缺少 GITEE_TOKEN

日志：

```text
请先在 GitHub 仓库 Settings > Secrets and variables > Actions 中添加 GITEE_TOKEN
```

处理：

重新添加或检查 Secret 名称。必须精确叫 `GITEE_TOKEN`。

### Gitee API 401

原因：

- Gitee 令牌无效。
- Gitee 令牌已撤销。
- Gitee 令牌权限不足。

处理：

重新生成 Gitee 私人令牌，并更新 GitHub Secret。

### 推送 workflow 文件失败

如果用 GitHub token 推送 `.github/workflows/*.yml`，token 需要 `workflow` 权限。

错误类似：

```text
refusing to allow a Personal Access Token to create or update workflow without workflow scope
```

处理：

重新生成带 `workflow` scope 的 GitHub token。

## 安全建议

- GitHub token 用完后撤销。
- Gitee token 只放在 GitHub Secret。
- 不在日志中打印 token。
- 不在 workflow 中启用 `set -x`。
