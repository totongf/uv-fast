# 安装脚本说明

安装入口文件：

```text
install.sh
```

默认在线地址：

```sh
curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh | sh
```

## 执行流程

`install.sh` 执行顺序：

1. 设置 Gitee raw 地址和国内镜像地址。
2. 查询 Gitee 缓存版本。
3. 查询官方最新 uv 版本。
4. 如果版本不一致，打印警告。
5. 从 Gitee 下载缓存的 `uv-installer.sh`。
6. 设置 `UV_INSTALLER_GITHUB_BASE_URL` 后执行官方 installer。
7. 写入 `~/.config/uv/uv.toml`。
8. 写入 shell profile 受管环境变量块。

## 默认配置

默认 Gitee raw 地址：

```text
https://gitee.com/totongf/uv-custom2/raw/master
```

默认镜像地址：

```text
https://uv.agentsmirror.com
```

## 环境变量

### UV_FAST_GITEE_RAW_BASE

覆盖 Gitee raw 根地址。

示例：

```sh
UV_FAST_GITEE_RAW_BASE=https://gitee.com/yourname/uv-fast/raw/master \
  sh -c "$(curl -LsSf https://gitee.com/yourname/uv-fast/raw/master/install.sh)"
```

### UV_FAST_MIRROR_BASE_URL

覆盖 uv 二进制、Python 元数据、PyPI 使用的镜像入口。

示例：

```sh
UV_FAST_MIRROR_BASE_URL=https://your-mirror.example.com \
  sh -c "$(curl -LsSf https://gitee.com/totongf/uv-custom2/raw/master/install.sh)"
```

## 写入 uv.toml

路径：

```text
${XDG_CONFIG_HOME:-$HOME/.config}/uv/uv.toml
```

写入内容：

```toml
python-downloads-json-url = "https://uv.agentsmirror.com/metadata/python-downloads.json"
```

如果文件已存在，脚本会先备份：

```text
uv.toml.YYYYMMDDHHMMSS.bak
```

然后删除旧的受管键：

```text
python-downloads-json-url
pypy-install-mirror
```

再写入新的配置。

## 写入 shell profile

脚本会始终写入：

```text
~/.profile
```

如果当前 `SHELL` 是 zsh，还会写入：

```text
~/.zshrc
```

如果当前 `SHELL` 是 bash，还会写入：

```text
~/.bashrc
```

写入块：

```sh
# >>> uv-fast managed block >>>
export UV_INSTALLER_GITHUB_BASE_URL="https://uv.agentsmirror.com/github"
export UV_PYTHON_DOWNLOADS_JSON_URL="https://uv.agentsmirror.com/metadata/python-downloads.json"
export UV_DEFAULT_INDEX="https://uv.agentsmirror.com/pypi/simple"
# <<< uv-fast managed block <<<
```

重复运行时，脚本会替换旧块，不会无限追加。

## 为什么仍然执行官方 installer

`uv-fast` 不重写安装逻辑，而是复用官方 installer。

这样做的好处：

- 平台识别逻辑保持官方一致。
- 安装目录、PATH 修改、二进制解包逻辑保持官方一致。
- 只通过环境变量替换下载源，维护成本低。

关键环境变量：

```sh
UV_INSTALLER_GITHUB_BASE_URL=https://uv.agentsmirror.com/github
```

官方 installer 会用这个地址拼接 release 资产下载地址。

## 版本告警逻辑

Gitee 缓存版本来自：

```text
$UV_FAST_GITEE_RAW_BASE/metadata/uv-latest.json
```

官方最新版本来自：

```text
https://api.github.com/repos/astral-sh/uv/releases/latest
```

如果两者不同，输出：

```text
警告：Gitee 缓存的 uv 版本是 x，官方最新版本是 y。
```

告警只提醒，不中断安装。原因是旧版本 uv 仍然可以正常安装，且国内环境下安装成功优先于强制最新。
