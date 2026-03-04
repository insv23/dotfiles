#!/bin/zsh
# LCD - LeetCode Daily
# 每日 LeetCode 刷题工作流：Vim + Claude Code + 计时器
#
# Usage:
#   lcd              打开今天的题（默认 Easy，没有则新建）
#   lcd -m           Medium 难度
#   lcd -h           Hard 难度
#   lcd -n           强制开新题
#   lcd -m -n        Medium + 强制新题（可组合）
#   lcd note [文字]  给今天的题写笔记
#   lcd stats        查看刷题统计
#   lcd history      最近 10 条记录

LCD_DB="$HOME/.leetcode/lcd.db"
LCD_TIMER="$HOME/.dotfiles/zsh/aliases/lcd-timer.sh"
LCD_CODE_DIR="$HOME/.leetcode/code"
LCD_TOML="$HOME/.leetcode/leetcode.toml"

_lcd_init_db() {
    sqlite3 "$LCD_DB" << 'SQL'
CREATE TABLE IF NOT EXISTS exercises (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    problem_id INTEGER NOT NULL,
    title      TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    file_path  TEXT NOT NULL,
    created_at DATETIME DEFAULT (datetime('now','localtime')),
    duration_s INTEGER DEFAULT 0,
    issue_url  TEXT DEFAULT ''
);
SQL
}

lcd() {
    local difficulty="e"
    local force_new=0

    # 子命令
    case "$1" in
        issue)   _lcd_issue; return ;;
        test)    shift; _lcd_test "$@"; return ;;
        exec)    shift; _lcd_exec "$@"; return ;;
        stats)   _lcd_stats; return ;;
        history) _lcd_history; return ;;
    esac

    # lcd <题号> → 直接打开指定题目
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        _lcd_open_by_id "$1"
        return
    fi

    # 解析参数
    local OPTIND
    while getopts "emhn" opt; do
        case $opt in
            e) difficulty="e" ;;
            m) difficulty="m" ;;
            h) difficulty="h" ;;
            n) force_new=1 ;;
            *) echo "用法: lcd [-e|-m|-h] [-n]"; return 1 ;;
        esac
    done

    _lcd_init_db

    # 已有 tmux 会话：无 -n 则接入，有 -n 则杀掉重来
    if tmux has-session -t lcd 2>/dev/null; then
        if [[ $force_new -eq 0 ]]; then
            echo "lcd 会话已存在，接入中..."
            if [[ -n "$TMUX" ]]; then
                tmux switch-client -t lcd
            else
                tmux attach -t lcd
            fi
            return
        fi
        tmux kill-session -t lcd 2>/dev/null
    fi

    # 查今天的记录
    local today_record
    today_record=$(sqlite3 "$LCD_DB" \
        "SELECT id, problem_id, title, difficulty, file_path, duration_s
         FROM exercises
         WHERE date(created_at) = date('now','localtime')
         ORDER BY id DESC LIMIT 1;")

    if [[ -n "$today_record" && $force_new -eq 0 ]]; then
        local row_id pid title diff fpath prev_duration
        IFS='|' read -r row_id pid title diff fpath prev_duration <<< "$today_record"

        echo "今天已做过: #${pid} ${title} (${diff})"
        read "yn?继续这道题？(y/n，用 lcd -n 开新题): "
        case $yn in
            [Yy]*)
                _lcd_open_tmux "$row_id" "$pid" "$title" "$fpath" "$prev_duration"
                return
                ;;
            *) return 0 ;;
        esac
    fi

    # 选新题
    _lcd_new_problem "$difficulty"
}

_lcd_new_problem() {
    local difficulty="$1"
    local diff_flag diff_name
    case $difficulty in
        e) diff_flag="eDL"; diff_name="Easy" ;;
        m) diff_flag="mDL"; diff_name="Medium" ;;
        h) diff_flag="hDL"; diff_name="Hard" ;;
    esac

    echo "正在获取未做的 ${diff_name} 题..."
    local list_output
    list_output=$(leetcode list -q "$diff_flag" 2>/dev/null)

    if [[ -z "$list_output" ]]; then
        echo "${diff_name} 题全部刷完了！换个难度试试。"
        return 1
    fi

    local id
    id=$(echo "$list_output" \
        | grep -oE '\[\s*[0-9]+\s*\]' \
        | tr -d '[] ' \
        | shuf -n 1)

    if [[ -z "$id" ]]; then
        echo "没有找到未做的题，可能登录过期了。"
        return 1
    fi

    # 从列表解析题目名称
    local title_line title
    title_line=$(echo "$list_output" | grep "\[\\s*${id}\\s*\]")
    title=$(echo "$title_line" | sed 's/^[^]]*] *//' | sed 's/  .*//')

    echo "🎲 今天的题: #${id} ${title} (${diff_name})"

    # 下载题目
    leetcode pick "$id" > /dev/null 2>&1

    # 生成代码文件（临时禁用编辑器）
    sed -i '' "s/editor = 'vim'/editor = 'true'/" "$LCD_TOML"
    leetcode edit "$id" > /dev/null 2>&1
    sed -i '' "s/editor = 'true'/editor = 'vim'/" "$LCD_TOML"

    # 定位生成的文件
    local file_path
    file_path=$(ls "${LCD_CODE_DIR}/${id}."*.rs 2>/dev/null | head -1)
    if [[ -z "$file_path" ]]; then
        echo "代码文件生成失败。"
        return 1
    fi

    # 初始提交：建立 baseline，后续解法 diff 只显示真正写的代码
    (cd "$HOME/.leetcode" && git add "$file_path" && \
     git commit -m "init(${id}): $(basename "$file_path" .rs | sed 's/^[0-9]*\.//')")

    # 创建 GitHub Issue
    local issue_url
    issue_url=$(_lcd_create_issue "$id" "$title" "$diff_name")

    # 写入数据库
    local escaped_title
    escaped_title=$(echo "$title" | sed "s/'/''/g")
    sqlite3 "$LCD_DB" \
        "INSERT INTO exercises (problem_id, title, difficulty, file_path, issue_url)
         VALUES (${id}, '${escaped_title}', '${diff_name}', '${file_path}', '${issue_url}');"
    local row_id
    row_id=$(sqlite3 "$LCD_DB" "SELECT last_insert_rowid();")

    _lcd_open_tmux "$row_id" "$id" "$title" "$file_path" "0"
}

_lcd_open_tmux() {
    local row_id="$1" pid="$2" title="$3" file_path="$4" prev_duration="${5:-0}"
    local start_ts=$(date +%s)
    local duration_file="/tmp/lcd_duration_${row_id}"
    local prompt_file="/tmp/lcd_sysprompt_${row_id}.txt"
    local left_script="/tmp/lcd_left_${row_id}.sh"
    local claude_script="/tmp/lcd_claude_${row_id}.sh"

    # ── 左侧 pane：vim + 退出后记录 ──
    cat > "$left_script" << LEFTEOF
#!/bin/bash
vim "$file_path"

# 从计时器文件读取耗时
duration=0
if [[ -f "$duration_file" ]]; then
    duration=\$(cat "$duration_file")
fi
sqlite3 "$LCD_DB" "UPDATE exercises SET duration_s=\$duration WHERE id=$row_id;"

# 关掉计时器 pane
timer_pane=\$(cat "/tmp/lcd_timer_pane_${row_id}" 2>/dev/null)
if [[ -n "\$timer_pane" ]]; then
    tmux kill-pane -t "\$timer_pane" 2>/dev/null
fi

mins=\$((duration / 60))
secs=\$((duration % 60))
issue_url=\$(sqlite3 "$LCD_DB" "SELECT issue_url FROM exercises WHERE id=$row_id;")
echo ""
echo "✅ 用时: \${mins}分\${secs}秒"
if [[ -n "\$issue_url" ]]; then
    echo "📋 Issue: \$issue_url"
fi
echo ""
echo "按回车关闭会话..."
read
tmux kill-session -t lcd 2>/dev/null
LEFTEOF
    chmod +x "$left_script"

    # ── Claude Code 系统提示词 ──
    cat > "$prompt_file" << PROMPTEOF
你是一位耐心的 Rust 导师，正在辅导一个 Rust 新手解 LeetCode 题目。
当前题目: #${pid} ${title}
代码文件: ${file_path}

规则:
1. 先阅读题目文件，用简单中文解释题意
2. 提示可能用到的 Rust 数据结构和语法（Vec、HashMap、迭代器等）
3. 用启发式提问引导思路，一步步引导，不要直接给出完整答案
4. 当学生写出代码后，帮忙 review 并解释 Rust 特有语法（所有权、借用、模式匹配等）
5. 鼓励学生先尝试，遇到编译错误再一起分析
6. 如果学生卡住了，给出小提示而非完整解法
PROMPTEOF

    # ── Claude Code 启动脚本 ──
    cat > "$claude_script" << CLAUDEEOF
#!/bin/bash
cd "$LCD_CODE_DIR"
sysprompt=\$(cat "$prompt_file")
claude --dangerously-skip-permissions --model opus --system-prompt "\$sysprompt" "请阅读 $file_path 并开始引导我解题"
CLAUDEEOF
    chmod +x "$claude_script"

    # ── 构建 tmux 布局 ──
    #  ┌──────────┬──────────┐
    #  │          │ Claude   │
    #  │  Vim     │  Code    │
    #  │          ├──────────┤
    #  │          │ ⏱ Timer  │
    #  └──────────┴──────────┘

    tmux new-session -d -s lcd -x "$(tput cols)" -y "$(tput lines)"

    # 用 pane ID 寻址，不受 base-index / pane-base-index 影响
    local vim_pane claude_pane timer_pane

    # 左 pane: vim wrapper（初始 pane）
    vim_pane=$(tmux display-message -t lcd -p '#{pane_id}')
    tmux send-keys -t "$vim_pane" "bash $left_script" C-m

    # 右 pane: 水平切割，新 pane 自动成为 active
    tmux split-window -h -t "$vim_pane"
    claude_pane=$(tmux display-message -t lcd -p '#{pane_id}')

    # 右上: Claude Code
    tmux send-keys -t "$claude_pane" "bash $claude_script" C-m

    # 右下: 计时器，3 行高
    tmux split-window -v -t "$claude_pane" -l 3
    timer_pane=$(tmux display-message -t lcd -p '#{pane_id}')
    tmux send-keys -t "$timer_pane" "bash $LCD_TIMER $start_ts $duration_file $prev_duration" C-m

    # 写入 timer pane ID，供左侧 wrapper 退出时杀掉
    echo "$timer_pane" > "/tmp/lcd_timer_pane_${row_id}"

    # 焦点放在 vim
    tmux select-pane -t "$vim_pane"

    # 接入会话
    if [[ -n "$TMUX" ]]; then
        tmux switch-client -t lcd
    else
        tmux attach -t lcd
    fi
}

# ── 创建 GitHub Issue ──
_lcd_create_issue() {
    local id="$1" title="$2" difficulty="$3"
    local issue_title="LeetCode #${id}: ${title}"
    local issue_body="- **Difficulty**: ${difficulty}
- **Link**: https://leetcode.com/problems/$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')/
- **Language**: Rust"

    local url
    url=$(cd "$HOME/.leetcode" && gh issue create \
        --title "$issue_title" \
        --body "$issue_body" \
        --label "$difficulty" 2>/dev/null) || true
    echo "$url"
}

# ── 按题号打开 ──
_lcd_open_by_id() {
    local id="$1"

    # 杀掉旧 session
    tmux kill-session -t lcd 2>/dev/null

    # 先看本地有没有现成文件
    local file_path
    file_path=$(ls "${LCD_CODE_DIR}/${id}."*.rs 2>/dev/null | head -1)

    if [[ -z "$file_path" ]]; then
        echo "本地没有 #${id}，正在下载..."
        leetcode pick "$id" > /dev/null 2>&1
        sed -i '' "s/editor = 'vim'/editor = 'true'/" "$LCD_TOML"
        leetcode edit "$id" > /dev/null 2>&1
        sed -i '' "s/editor = 'true'/editor = 'vim'/" "$LCD_TOML"
        file_path=$(ls "${LCD_CODE_DIR}/${id}."*.rs 2>/dev/null | head -1)
        if [[ -z "$file_path" ]]; then
            echo "题目 #${id} 不存在或下载失败。"
            return 1
        fi

        # 初始提交：建立 baseline，后续解法 diff 只显示真正写的代码
        (cd "$HOME/.leetcode" && git add "$file_path" && \
         git commit -m "init(${id}): $(basename "$file_path" .rs | sed 's/^[0-9]*\.//')")
    fi

    # 解析难度和标题
    local diff title
    diff=$(head -3 "$file_path" | grep '// Level:' | sed 's/.*Level: //')
    title=$(basename "$file_path" .rs | sed 's/^[0-9]*\.//' | tr '-' ' ')

    # 创建 GitHub Issue + 记录到 DB
    _lcd_init_db
    local issue_url
    issue_url=$(_lcd_create_issue "$id" "$title" "${diff:-Unknown}")
    local escaped_title
    escaped_title=$(echo "$title" | sed "s/'/''/g")
    sqlite3 "$LCD_DB" \
        "INSERT INTO exercises (problem_id, title, difficulty, file_path, issue_url)
         VALUES (${id}, '${escaped_title}', '${diff:-Unknown}', '${file_path}', '${issue_url}');"
    local row_id
    row_id=$(sqlite3 "$LCD_DB" "SELECT last_insert_rowid();")

    echo "📂 #${id} ${title} (${diff:-Unknown})"
    _lcd_open_tmux "$row_id" "$id" "$title" "$file_path" "0"
}

# ── 从文件路径提取题号 ──
# 2869.minimum-operations-to-collect-elements.rs → 2869
_lcd_id_from_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo "用法: lcd test <文件路径>  (在 Vim 里用 :!lcd test %)" >&2
        return 1
    fi
    local id
    id=$(basename "$file" | sed 's/^\([0-9]*\)\..*/\1/')
    if [[ -z "$id" || ! "$id" =~ ^[0-9]+$ ]]; then
        echo "无法从文件名解析题号: $file" >&2
        return 1
    fi
    echo "$id"
}

# ── 子命令：测试 ──
_lcd_test() {
    local id
    id=$(_lcd_id_from_file "$1") || return 1
    echo "测试 #${id}..."
    leetcode test "$id"
}

# ── 子命令：提交 ──
_lcd_exec() {
    local id
    id=$(_lcd_id_from_file "$1") || return 1
    echo "提交 #${id}..."
    leetcode exec "$id"
}

# ── 子命令：打开今天的 issue ──
_lcd_issue() {
    _lcd_init_db
    local issue_url
    issue_url=$(sqlite3 "$LCD_DB" \
        "SELECT issue_url FROM exercises
         WHERE date(created_at) = date('now','localtime')
         ORDER BY id DESC LIMIT 1;")
    if [[ -z "$issue_url" ]]; then
        echo "今天没有做题记录或没有关联 issue。"
        return 1
    fi
    echo "📋 $issue_url"
    open "$issue_url"
}

# ── 子命令：统计 ──
_lcd_stats() {
    _lcd_init_db
    echo "📊 LeetCode 刷题统计"
    echo "─────────────────────"
    sqlite3 -header -column "$LCD_DB" "
        SELECT
            difficulty AS 难度,
            COUNT(*)   AS 题数,
            printf('%d分%02d秒', AVG(duration_s)/60, AVG(duration_s)%60) AS 平均用时
        FROM exercises
        GROUP BY difficulty;
    "
    echo ""
    echo "总计: $(sqlite3 "$LCD_DB" "SELECT COUNT(*) FROM exercises;") 题"
}

# ── 子命令：历史 ──
_lcd_history() {
    _lcd_init_db
    echo "📜 最近 10 条记录"
    echo "─────────────────────"
    sqlite3 -header -column "$LCD_DB" "
        SELECT
            problem_id AS '#',
            title      AS 题目,
            difficulty AS 难度,
            printf('%d分%02d秒', duration_s/60, duration_s%60) AS 用时,
            substr(created_at, 1, 10) AS 日期,
            CASE WHEN issue_url != '' THEN '✓' ELSE '' END AS issue
        FROM exercises
        ORDER BY id DESC
        LIMIT 10;
    "
}
