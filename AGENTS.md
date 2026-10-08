# Dotfiles Project Instructions

## Changelog Requirement

After every change made in this repo, you MUST update `CHANGELOG.md` with a corresponding entry.

### Format

Follow the existing style in `CHANGELOG.md`:

```markdown
## YYYY-MM-DD

### Topic Name

- **Category**: Description of what changed and why
```

### Rules

- Use today's date. If an entry for today already exists, append under it without creating a duplicate date header.
- The topic name should reflect the tool or config area changed, such as `Zsh`, `Vim`, `Tmux`, or `Yazi`.
- Bullet points should describe what changed and, where useful, why.
- Write entries in the same language as the surrounding changelog content, currently Chinese.

## 部署与同步

默认符号链接：仓库文件与部署位置是同一个文件，改完立即生效，不需要跑任何命令。

写了 `link: nolink` 的条目是两份独立文件，方向要分，两者都会覆盖对面：

- 改的是仓库：`./install`，仓库盖到部署位置。
- 改的是部署位置（程序自己改写）：`dotdrop --cfg config.yaml update <部署路径>`，部署位置收回仓库。

改完配置后：先查 `config.yaml` 有没有 `link: nolink`，没有就结束；有则 `compare -L` 比出差异，判断哪边新，把该跑的 install 或 update 报给用户确认，不要自己执行——跑错方向会丢掉刚改的内容。
