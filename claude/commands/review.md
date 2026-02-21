审查当前工作目录的未提交改动。

1. 用 code-reviewer agent 审查所有 staged 和 unstaged 的改动
2. 如果有 CRITICAL 或 WARNING 级别的问题，列出来
3. 如果全部 LGTM，直接说"可以 ship 了"

如果用户在命令后面附了需求描述，把需求传给 code-reviewer 做对照检查。
