# Claude Code CLI：cc/cco/ccs 等快捷命令及辅助函数
# # ===== Claude Code =====
alias cc="claude --dangerously-skip-permissions --model sonnet"
alias cco="claude --dangerously-skip-permissions --model opus"
alias ccs="claude --dangerously-skip-permissions --model sonnet"


# # ===== glm4.6 接入=====
# Claude Code 使用 brew 安装, 因此使用 DISABLE_AUTOUPDATER=1 禁止自动更新
# GLM_API_TOKEN 放在 mba.zshenv.secret 
function ccglm() {
    ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic \
    ANTHROPIC_AUTH_TOKEN=$GLM_API_TOKEN \
    ANTHROPIC_MODEL=glm-4.7 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

# # ===== 302 接入 =====
# 以官方API 3折计费，支持缓存命中
# https://doc.302.ai/349734723e0
# claude-3-5-haiku-20241022
# claude-sonnet-4-20250514
# claude-opus-4-20250514
# claude-opus-4-5-20251101 (不知为何，换这个请求会失败)
# 价格：原模型价格的3折
function cc302() {
    ANTHROPIC_BASE_URL=https://api.302.ai/cc \
    ANTHROPIC_AUTH_TOKEN=$CC_302_API_KEY \
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

function cckat() {
    ANTHROPIC_BASE_URL=https://vanchin.streamlake.ai/api/gateway/v1/endpoints/ep-uflfxs-1760153821291704226/claude-code-proxy \
    ANTHROPIC_AUTH_TOKEN=$CC_KAT_API_KEY \
    ANTHROPIC_MODEL=KAT-Coder \
    ANTHROPIC_SMALL_FAST_MODEL=KAT-Coder \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

function cckimi() {
    ANTHROPIC_BASE_URL=https://api.kimi.com/coding/ \
    ANTHROPIC_AUTH_TOKEN=$CC_KIMI_API_KEY \
    ANTHROPIC_MODEL=kimi-for-coding \
    ANTHROPIC_SMALL_FAST_MODEL=kimi-for-coding \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

function ccjk() {
    ANTHROPIC_BASE_URL=https://api.jiekou.ai/anthropic \
    ANTHROPIC_AUTH_TOKEN=$CC_JIEKOU_API_KEY \
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}
