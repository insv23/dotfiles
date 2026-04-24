# 自定义插件：在提示符中显示 jj (Jujutsu VCS) 的仓库状态
# jj-status: 在 powerlevel10k 提示符中显示 jujutsu 仓库状态
# 自定义 p10k segment，不依赖外部插件
#
# 用法: 将 jj_status 添加到 POWERLEVEL9K_LEFT_PROMPT_ELEMENTS 或
#       POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS 中
#
# 显示信息一览:
#
#   符号    颜色    含义                          示例
#   ─────────────────────────────────────────────────────────────
#   ◆              immutable，当前 change 不可变   ◆ xxqy
#   ×              conflict，存在合并冲突          × xxqy
#   (id)   紫/灰   change ID 缩写                 xxqyzxur
#   (name)         bookmarks，所在的 bookmark      main (截断 18 字符)
#   (name)         tags，所在的 tag
#   @              working copy 标识
#   ∅              empty，change 内容为空
#   (text)         description 摘要                feat: add… (截断 24 字符)
#   #      黄      无 description 时的占位符
#   +N     绿      新增文件数                      +3
#   ±N     青      修改文件数                      ±2
#   -N     红      删除文件数                      -1
#   ⧉N     绿      复制文件数                      ⧉1
#   ↻N     青      重命名文件数                    ↻1
#
# 示例输出: xxqyzxur main ∅ #
#          xxqyzxur feat: add task command +1 ±3
#          ◆ xxqyzxur v0.1.0 release v0.1.0

autoload -Uz VCS_INFO_bydir_detect

# jj log 模板命令，可通过在 source 之后重新 typeset 来覆盖
typeset -g POWERLEVEL9K_JJ_STATUS_COMMAND=(
    jj log --ignore-working-copy --color always --revisions @ --no-graph --template '
    if(root,
      format_root_commit(self),
      concat(
        separate(" ",
          if(immutable, label("immutable", "◆")),
          if(conflict, label("conflict", "×")),
          format_short_change_id_with_change_offset(self),
          truncate_end(18, bookmarks, "…"),
          tags,
          working_copies,
          if(empty, label("empty", "∅")),
          if(description,
            truncate_end(24, description.first_line(), "…"),
            label(if(empty, "empty", "description placeholder"), "#"),
          ),
          if(self.diff().files().filter(|f| f.status() == "added").len() > 0,
            label("diff added", "+" ++ self.diff().files().filter(|f| f.status() == "added").len())),
          if(self.diff().files().filter(|f| f.status() == "modified").len() > 0,
            label("diff modified", "±" ++ self.diff().files().filter(|f| f.status() == "modified").len())),
          if(self.diff().files().filter(|f| f.status() == "removed").len() > 0,
            label("diff removed", "-" ++ self.diff().files().filter(|f| f.status() == "removed").len())),
          if(self.diff().files().filter(|f| f.status() == "copied").len() > 0,
            label("diff added", "⧉" ++ self.diff().files().filter(|f| f.status() == "copied").len())),
          if(self.diff().files().filter(|f| f.status() == "renamed").len() > 0,
            label("diff modified", "↻" ++ self.diff().files().filter(|f| f.status() == "renamed").len())),
        ),
        "\n"
      ),
    )')

function prompt_jj_status() {
    local -A vcs_comm
    vcs_comm[detect_need_file]=working_copy

    VCS_INFO_bydir_detect .jj \
    && p10k segment -t \
        "$(${POWERLEVEL9K_JJ_STATUS_COMMAND[@]} \
            | tr -d '\n' \
            | sed -r "s/\[[^m]+m/%{&%}/g")"
}
