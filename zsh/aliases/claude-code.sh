# # ===== Claude Code =====
alias cc="claude"
# alias claude="/Users/tony/.claude/local/claude"
# alias cc="claude --dangerously-skip-permissions"
# alias ccc="claude --dangerously-skip-permissions --continue"
# alias cco="claude --dangerously-skip-permissions --model opus"

# # ===== xlaude =====
# alias xl="xlaude"
# alias xll="xlaude list"
# alias xlc="xlaude create"
# alias xld="xlaude delete"
# alias xln="xlaude new --with code"

# # ===== glm4.6 接入=====
# Claude Code 使用 brew 安装, 因此使用 DISABLE_AUTOUPDATER=1 禁止自动更新
# GLM_API_TOKEN 放在 mba.zshenv.secret 
function ccglm() {
    ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic \
    ANTHROPIC_AUTH_TOKEN=$GLM_API_TOKEN \
    ANTHROPIC_MODEL=glm-4.6 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

# # ===== 302 接入 =====
# 以官方API 3折计费，支持缓存命中
# https://doc.302.ai/349734723e0
# claude-3-5-haiku-20241022
# claude-sonnet-4-20250514
# claude-opus-4-20250514
# 价格：原模型价格的3折
function cc302() {
    ANTHROPIC_BASE_URL=https://api.302.ai/cc \
    ANTHROPIC_AUTH_TOKEN=$CC_302_API_KEY \
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}
