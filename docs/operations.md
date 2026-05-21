# 运维手册

## 日常检查

每天自动更新由 GitHub Actions 执行。

检查入口：

```text
https://github.com/totongf/uv-fast/actions
```

关注 workflow：

```text
Update Gitee uv cache
```

正常结果：

```text
conclusion=success
```

## 版本一致性检查

```sh
cached=$(curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/metadata/uv-latest.json | ruby -rjson -e 'puts JSON.parse(STDIN.read)["tag"]')
official=$(curl -fsSL https://api.github.com/repos/astral-sh/uv/releases/latest | ruby -rjson -e 'puts JSON.parse(STDIN.read)["tag_name"]')
printf 'cached=%s\nofficial=%s\n' "$cached" "$official"
test "$cached" = "$official"
```

如果退出码为 0，表示一致。

## 手动触发 GitHub Actions

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

## 手动本地刷新

在仓库根目录执行：

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

刷新目标默认是：

```text
GITEE_OWNER=totongf
GITEE_REPO=uv-custom2
GITEE_BRANCH=master
```

如需覆盖：

```sh
GITEE_OWNER=totongf \
GITEE_REPO=uv-custom2 \
GITEE_BRANCH=master \
GITEE_TOKEN=你的令牌 \
bash scripts/update-gitee-uv.sh
```

## 发布流程

修改 `uv-fast` 后，建议按以下顺序发布。

### 1. 本地验证

```sh
sh -n install.sh
bash -n scripts/update-gitee-uv.sh
bash -n scripts/setup-local-auto-update.sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/update-gitee-uv.yml")'
ruby -e 'require "yaml"; YAML.load_file(".workflow/update-gitee-uv.yml")'
```

### 2. 检查敏感信息

```sh
rg -n 'ghp_|GITEE_TOKEN=.*[0-9a-f]{20,}|access_token=[0-9a-f]' .
```

不应出现真实令牌。

### 3. 推送 GitHub

```sh
git add .
git commit -m "Update uv-fast"
git push
```

如果改了 `.github/workflows/*.yml`，推送用的 GitHub token 需要 `workflow` 权限。

### 4. 同步 Gitee 安装入口

需要同步到 Gitee 的文件：

```text
install.sh
README.md
scripts/update-gitee-uv.sh
scripts/setup-local-auto-update.sh
.workflow/update-gitee-uv.yml
```

### 5. 手动触发一次刷新

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

### 6. 验证最终安装入口

不要在生产机器上直接反复测试破坏已有环境。可以使用临时用户、容器或干净机器测试：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
uv --version
```

## 回滚

如果 `install.sh` 发布出错：

1. 在 GitHub 回滚 commit。
2. 同步旧版 `install.sh` 到 Gitee。
3. 检查 Gitee raw：

```sh
curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh -n
```

如果 `uv-installer.sh` 缓存出错：

1. 重新运行 `scripts/update-gitee-uv.sh`。
2. 或手动下载上一个可用版本 installer 并写回 Gitee。

## 建议监控

轻量监控命令：

```sh
curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/metadata/uv-latest.json >/dev/null
curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh -n
```

可以放到任意外部监控或本机定时任务中。
