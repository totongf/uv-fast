# 故障排查

## 安装脚本下载失败

命令：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

如果失败，先检查 raw 是否可访问：

```sh
curl -I https://gitee.com/totongf/uv-custom2/raw/master/install.sh
```

期望看到：

```text
HTTP/1.1 200
```

或先 `302` 再 `200`。

## uv-installer.sh 下载失败

检查：

```sh
curl -I https://gitee.com/totongf/uv-custom2/raw/master/uv-installer.sh
```

如果 404，说明缓存还没刷新。

处理：

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

或手动触发 GitHub Actions。

## 版本告警

看到：

```text
警告：Gitee 缓存的 uv 版本是 x，官方最新版本是 y。
```

含义：

Gitee 中缓存的 installer 不是官方最新版本。

处理：

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

如果 GitHub Actions 已配置，可以手动触发：

```text
https://github.com/totongf/uv-fast/actions
```

## GitHub Actions 失败

打开：

```text
https://github.com/totongf/uv-fast/actions
```

查看 `Update Gitee uv cache`。

### Check secret 失败

原因：

缺少 `GITEE_TOKEN`。

处理：

在 GitHub 仓库添加 Secret：

```text
Settings > Secrets and variables > Actions > Secrets > New repository secret
```

名称：

```text
GITEE_TOKEN
```

### Gitee API 失败

可能原因：

- Gitee token 已过期。
- Gitee token 权限不足。
- Gitee 仓库名配置错误。
- Gitee 分支名配置错误。

检查 workflow 变量：

```text
GITEE_OWNER
GITEE_REPO
GITEE_BRANCH
```

默认应该是：

```text
totongf
uv-custom2
master
```

## Gitee Go 失败

### UV_GITEE_TOKEN 不存在

日志：

```text
请先在 Gitee Go 流水线变量中添加 UV_GITEE_TOKEN，并设置为私密变量
```

处理：

在 Gitee Go 流水线变量中添加私密变量 `UV_GITEE_TOKEN`。

### scripts/update-gitee-uv.sh 找不到

说明 Gitee 仓库目录结构不完整。

确认仓库根目录存在：

```text
scripts/update-gitee-uv.sh
```

## uv python install 仍然慢

检查环境变量：

```sh
env | grep '^UV_'
```

应该看到：

```text
UV_INSTALLER_GITHUB_BASE_URL=https://uv.agentsmirror.com/github
UV_PYTHON_DOWNLOADS_JSON_URL=https://uv.agentsmirror.com/metadata/python-downloads.json
UV_DEFAULT_INDEX=https://uv.agentsmirror.com/pypi/simple
```

检查 uv 配置：

```sh
cat ~/.config/uv/uv.toml
```

应该包含：

```toml
python-downloads-json-url = "https://uv.agentsmirror.com/metadata/python-downloads.json"
```

## PATH 未生效

安装后找不到 `uv`：

```text
command not found: uv
```

处理：

```sh
export PATH="$HOME/.local/bin:$PATH"
uv --version
```

如果可用，说明 shell profile 还没加载。

重新打开终端，或执行：

```sh
source ~/.profile
```

zsh：

```sh
source ~/.zshrc
```

bash：

```sh
source ~/.bashrc
```

## 检查缓存版本

```sh
curl -fsSL https://gitee.com/totongf/uv-custom2/raw/master/metadata/uv-latest.json
```

检查官方版本：

```sh
curl -fsSL https://api.github.com/repos/astral-sh/uv/releases/latest | ruby -rjson -e 'puts JSON.parse(STDIN.read)["tag_name"]'
```
