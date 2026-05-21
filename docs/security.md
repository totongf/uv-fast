# 安全与令牌

## 需要哪些令牌

### Gitee 私人令牌

用途：

- 让刷新脚本通过 Gitee API 更新 `totongf/uv-custom2`。

使用位置：

- GitHub Actions Secret：`GITEE_TOKEN`
- Gitee Go 私密变量：`UV_GITEE_TOKEN`
- 本机环境变量：`GITEE_TOKEN`

### GitHub 令牌

用途：

- 创建或更新 GitHub 仓库。
- 推送 GitHub Actions workflow。

正常运行时不需要 GitHub 令牌。workflow 已配置好后，可以撤销用于配置的 GitHub 令牌。

## 不要做什么

不要把令牌写入：

- README
- docs
- shell 脚本
- workflow 文件
- Git commit
- issue 或评论

不要在脚本中打印：

```sh
echo "$GITEE_TOKEN"
```

不要打开 shell trace：

```sh
set -x
```

因为带 `access_token` 的 curl 命令可能进入日志。

## GitHub Secrets 是否安全

把令牌放在 GitHub Secrets 中是正确做法。

GitHub Actions 日志中通常会把 Secret 值遮蔽为：

```text
***
```

但仍要注意：

- 有仓库写权限的人可以修改 workflow，间接读取或外传 Secret。
- public repo 的外部 PR 默认拿不到 repository secrets，但合并恶意 workflow 后仍然危险。
- 不要给不信任的人仓库 Actions 修改权限。

## 令牌权限建议

Gitee token 建议使用最小权限。

理想权限：

- 只允许操作 `totongf/uv-custom2`
- 允许读取仓库内容
- 允许写入仓库文件

如果 Gitee 的权限粒度不够细，至少单独创建一个只用于 `uv-fast` 的令牌，不和其他项目共用。

GitHub token 建议：

- 配置完成后立即撤销。
- 如果需要推送 workflow，classic token 需要 `workflow` scope。
- 如果使用 fine-grained token，需要给目标仓库 Contents 和 Workflows 对应权限。

## 泄露后的处理

如果令牌发到了聊天、日志、commit 或截图里：

1. 立即撤销该令牌。
2. 重新生成新令牌。
3. 更新 GitHub Secret 或 Gitee Go 私密变量。
4. 检查最近 Actions / Gitee Go 运行记录。
5. 检查 Gitee 仓库最近提交是否异常。

## 本机定时任务的令牌存储

本机定时脚本会把令牌写入：

```text
~/.config/uv-fast/gitee.env
```

脚本使用：

```sh
umask 077
```

这会尽量让文件只有当前用户可读写。

仍然建议：

```sh
ls -l ~/.config/uv-fast/gitee.env
```

权限应类似：

```text
-rw------- 
```
