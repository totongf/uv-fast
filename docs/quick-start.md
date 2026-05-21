# 快速开始

## 一句命令安装

在 macOS 或 Linux 上执行：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

安装完成后重新打开终端，或执行：

```sh
source ~/.profile
```

如果你使用 zsh，也可以执行：

```sh
source ~/.zshrc
```

## 验证安装

```sh
uv --version
```

验证 Python 安装链路：

```sh
uv python install 3.11
uv venv ~/.uv-test --python 3.11
~/.uv-test/bin/python --version
```

验证 PyPI 镜像链路：

```sh
uv pip install -p ~/.uv-test/bin/python -U pip setuptools wheel
```

## 脚本会写入什么

安装脚本会写入两个位置。

第一，写入 uv 配置文件：

```text
~/.config/uv/uv.toml
```

当前写入：

```toml
python-downloads-json-url = "https://uv.agentsmirror.com/metadata/python-downloads.json"
```

第二，写入 shell profile 的受管环境变量块：

```sh
# >>> uv-fast managed block >>>
export UV_INSTALLER_GITHUB_BASE_URL="https://uv.agentsmirror.com/github"
export UV_PYTHON_DOWNLOADS_JSON_URL="https://uv.agentsmirror.com/metadata/python-downloads.json"
export UV_DEFAULT_INDEX="https://uv.agentsmirror.com/pypi/simple"
# <<< uv-fast managed block <<<
```

可能写入的文件：

- `~/.profile`
- `~/.zshrc`
- `~/.bashrc`

如果已有受管块，脚本会先删除旧块再写入新块。

## 版本告警

安装前脚本会检查：

- Gitee 缓存版本：`https://gitee.com/totongf/uv-custom2/raw/master/metadata/uv-latest.json`
- 官方最新版本：`https://api.github.com/repos/astral-sh/uv/releases/latest`

如果两者不同，会打印警告，但不会阻止安装。

## 手动刷新 Gitee 缓存

在 `uv-fast` 或 `uv-custom2` 仓库根目录执行：

```sh
GITEE_TOKEN=你的令牌 bash scripts/update-gitee-uv.sh
```

刷新成功后会更新：

```text
uv-installer.sh
metadata/uv-latest.json
```

## 当前自动更新

当前 GitHub Actions 已配置自动更新。

路径：

```text
https://github.com/totongf/uv-fast/actions
```

任务：

```text
Update Gitee uv cache
```

默认每天北京时间 `04:15` 自动执行。
