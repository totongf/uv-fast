# GitHub Actions 部署说明

把本目录的 `.github/workflows/update-gitee-uv.yml` 放到 GitHub 仓库：

```text
.github/workflows/update-gitee-uv.yml
```

在 GitHub 仓库 `Settings > Secrets and variables > Actions > Secrets` 添加：

```text
GITEE_TOKEN=你的 Gitee 私人令牌
```

GitHub Actions 会每天北京时间 04:15 自动刷新 Gitee 仓库中的 uv 缓存。

这个方案不需要公网 IP，也不需要你的本机在线。
