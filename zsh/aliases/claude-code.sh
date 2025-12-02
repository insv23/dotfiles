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
# claude-opus-4-5-20251101 (不知为何，换这个请求会失败)
# 价格：原模型价格的3折
function cc302() {
    ANTHROPIC_BASE_URL=https://api.302.ai/cc \
    ANTHROPIC_AUTH_TOKEN=$CC_302_API_KEY \
    ANTHROPIC_MODEL=claude-sonnet-4-5-20250929 \
    DISABLE_AUTOUPDATER=1 \
    claude $@
}

# ===== 本地 cli-proxy-api 接入 =====
# 虽然没什么用... codex 在 vscode GUI 插件中才堪堪能用
# gpt5 只能写代码，讲东西一点都讲不明白
# 而且接入 Claude Code 后 context 无法正常显示(模型返回缺少对应字段)
function ccx() {
    if lsof -nP -iTCP:8317 -sTCP:LISTEN | grep -qi cli-proxy; then
        ANTHROPIC_BASE_URL=http://127.0.0.1:8317 \
        ANTHROPIC_AUTH_TOKEN=sk-dummy \
        ANTHROPIC_MODEL=gpt-5 \
        ANTHROPIC_SMALL_FAST_MODEL=gpt-5 \
        DISABLE_AUTOUPDATER=1 \
        claude $@
    else
        echo "未检测到 8317 端口上的 cli-proxy。请先启动 cli-proxy-api。"
        return 1
    fi
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