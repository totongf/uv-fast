# Gitee 部署说明

把 `uv-fast` 根目录中的运行文件发布到 Gitee 仓库根目录：

```text
install.sh
scripts/update-gitee-uv.sh
scripts/setup-local-auto-update.sh
```

把本目录的 `.workflow/update-gitee-uv.yml` 发布到 Gitee 仓库：

```text
.workflow/update-gitee-uv.yml
```

在 Gitee Go 流水线变量中添加私密变量：

```text
UV_GITEE_TOKEN=你的 Gitee 私人令牌
```

最终安装命令：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```
