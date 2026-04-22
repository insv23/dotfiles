set nocompatible " not vi compatible
let mapleader = " "

" -----------------
"  Style
" -----------------
" colo desert               " Use vim builtin color theme 'desert'

let &t_SI = "\e[6 q"        " 在插入模式下使用竖线光标
let &t_SR = "\e[4 q"        " 在替换模式下使用下划线光标
let &t_EI = "\e[2 q"        " 在普通模式下使用块状光标


"------------------
" Syntax and indent
"------------------
syntax on " turn on syntax highlighting
set showmatch " show matching braces when text indicator is over them

" highlight current line, but only in active window
augroup CursorLineOnlyInActiveWindow
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    autocmd WinLeave * setlocal nocursorline
augroup END

" 去掉 cursorline 的下划线，只保留背景色（用 autocmd 确保在颜色方案后生效）
augroup CursorLineStyle
    autocmd!
    " cterm=NONE 去掉下划线, ctermbg=236 深灰背景色, gui* 为 gvim/MacVim 设置
    autocmd ColorScheme,VimEnter * highlight CursorLine cterm=NONE ctermbg=236 gui=NONE guibg=#303030
    " 行号：低饱和度灰色，避免与语法高亮的黄色冲突
    autocmd ColorScheme,VimEnter * highlight LineNr ctermfg=243 guifg=#767676 cterm=NONE gui=NONE
    " 去掉当前行号的下划线
    autocmd ColorScheme,VimEnter * highlight CursorLineNr term=NONE cterm=NONE
    " sign 列背景与编辑区保持一致，避免 gitgutter 的 gutter 显示为浅灰色
    autocmd ColorScheme,VimEnter * highlight SignColumn ctermbg=NONE guibg=NONE
    " gitgutter 改动标记：用低饱和度的绿/黄/红，在暗色背景上不刺眼
    autocmd ColorScheme,VimEnter * highlight GitGutterAdd    ctermfg=65  guifg=#5f875f ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
    autocmd ColorScheme,VimEnter * highlight GitGutterChange ctermfg=136 guifg=#87875f ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
    autocmd ColorScheme,VimEnter * highlight GitGutterDelete ctermfg=131 guifg=#875f5f ctermbg=NONE guibg=NONE cterm=NONE gui=NONE
    " vim-which-key 菜单配色：低饱和度，与暗色主题协调
    " WhichKeyFloating 控制弹窗背景色，不设置则继承颜色方案的 Normal，容易出现紫色等突兀颜色
    autocmd ColorScheme,VimEnter * highlight WhichKeyFloating  ctermbg=235 guibg=#262626
    autocmd ColorScheme,VimEnter * highlight WhichKey          ctermfg=179 guifg=#d7af5f cterm=NONE gui=NONE
    autocmd ColorScheme,VimEnter * highlight WhichKeySeperator ctermfg=243 guifg=#767676 cterm=NONE gui=NONE
    autocmd ColorScheme,VimEnter * highlight WhichKeyGroup     ctermfg=109 guifg=#87afaf cterm=NONE gui=NONE
    autocmd ColorScheme,VimEnter * highlight WhichKeyDesc      ctermfg=250 guifg=#bcbcbc cterm=NONE gui=NONE
augroup END

" Insert 模式下关闭括号匹配高亮，避免遮挡光标
augroup MatchParenInInsert
    autocmd!
    autocmd InsertEnter * NoMatchParen
    autocmd InsertLeave * DoMatchParen
augroup END

" ===== 中文支持 =====
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312,gb18030
set breakindent               " 软换行续行保持缩进
" set ambiwidth=double          " 注释掉：它把 ┊· 等 Unicode 字符当全角，导致 leadmultispace 报错。现代终端本身能正确处理中文宽度，不需要这个设置

filetype plugin indent on " enable file type detection
set autoindent

" Insert 模式下回车的增强映射：
"   <C-g>u    — 插入撤销断点，让每次回车可以单独用 u 撤销
"   <CR>      — 正常换行
"   <Space><BS> — 插入空格再删掉，骗 Vim 保留空行的自动缩进
inoremap <CR> <C-g>u<CR><Space><BS>
" 让 undo 更细粒度：每输入一个词/短语就断开撤销单元
" 这样 u 只撤销最近一小段输入，而不是整个 Insert 会话
" 效果接近 GUI 编辑器的 Ctrl-Z 体验
inoremap <Space> <C-g>u<Space>
inoremap , <C-g>u,
inoremap . <C-g>u.
" 同理，o/O 新建行后离开再回来也保留缩进
nnoremap o o<Space><BS>
nnoremap O O<Space><BS>

"---------------------
" Basic editing config
"---------------------
set clipboard=unnamed           " system clipboard
" c 操作不污染系统剪贴板，删除内容送入黑洞寄存器
nnoremap c "_c
nnoremap C "_C
xnoremap c "_c
set noswapfile                  " no swap file
set shortmess+=I                " disable startup message
set incsearch                   " incremental search (as string is being typed)
set hls                         " highlight search
set list                                      " 显示不可见字符
set listchars=tab:>>,nbsp:~,leadmultispace:┊···  " 每 4 格一条竖线，可视化缩进层级
set lbr                         " line break
set scrolloff=5                 " show lines above and below cursor (when possible)
set noshowmode                  " hide mode
set showcmd                     " 右下角实时显示正在输入的按键序列，确认 leader 等前缀键是否已被接收
set laststatus=2
set statusline=%{fnamemodify(expand('%:p:h'),':t')}/%t\ %m%=%l:%c
set backspace=indent,eol,start  " allow backspacing over everything
set timeout timeoutlen=400 ttimeoutlen=100  " fix slow O inserts; timeoutlen 同时控制 vim-which-key 弹出延迟
set lazyredraw                  " skip redrawing screen in some cases
set autochdir                   " automatically set current directory to directory of last opened file
set hidden                      " allow auto-hiding of edited buffers
set autoread                    " 文件被外部程序修改时自动重新加载，不弹提示
" autoread 本身是被动的，只有 Vim 主动触发检查（checktime）时才生效。
" 下面的 autocmd 在三个时机触发检查：
"   FocusGained — Vim 重新获得焦点（从其他窗口切回来）
"   BufEnter    — 切换到另一个 buffer
"   CursorHold  — 停止输入超过 updatetime 毫秒（当前为 100ms）
" 三者结合，效果等同于 VS Code 的自动静默刷新
augroup AutoReload
    autocmd!
    autocmd FocusGained,BufEnter,CursorHold * checktime
augroup END
set history=8192                " more history
set nojoinspaces                " suppress inserting two spaces between sentences

" 在 SSH 环境下，每次 yank 自动通过 OSC 52 同步到本地剪贴板
if !empty($SSH_CONNECTION)
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif
endif

nnoremap H 0
nnoremap L $
nnoremap <C-e> %    " 跳转到匹配的括号、括弧或引号
nnoremap yie :%y+<CR>   " 复制整个文件的内容到系统剪贴板
nnoremap die :%d+<CR>   " 剪切整个文件的内容到系统剪贴板
nnoremap yte VGy        " 复制从当前行到最后一行

" 复制当前文件的完整绝对路径（从根目录起），右下角弹出通知确认
" 同时写入两个寄存器，原因如下：
"   @+ — 系统剪贴板寄存器，对应 Cmd+V，本地 macOS 下首选
"   @" — Vim 无名寄存器，SSH 远程环境下系统剪贴板同步可能失败，
"         但 @" 是 Vim 内部的，p 命令始终可用，作为保底
" expand('%:p')：% = 当前文件，:p = 展开为完整绝对路径
nnoremap <silent> <Leader>yp :let @+ = expand('%:p') \| let @" = expand('%:p') \| call popup_notification('  ' . expand('%:p'), #{time: 1500, highlight: 'Normal', pos: 'botright', line: &lines - 1, col: &columns})<CR>

" use 4 spaces instead of tabs during formatting
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" smart case-sensitive search
set ignorecase
set smartcase

" tab completion for files/bufferss
set wildmode=longest,list
set wildmenu
set mouse+=a                " enable mouse mode (scrolling, selection, etc)
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif
set nofoldenable             " disable folding by default

"--------------------
" Misc configurations
"--------------------

" vimrc 快捷编辑与重载
nnoremap <Leader>ve :e $MYVIMRC<CR>
"   编辑完后 :w 保存（自动 reload）→ :bd 关闭 buffer 回到原文件
"   或用 Ctrl-^ 在两个 buffer 间来回切换
nnoremap <Leader>vr :source $MYVIMRC \| redraw \| call popup_notification('  vimrc reloaded ✓ ', #{time: 800, highlight: 'Normal', pos: 'botright', line: &lines - 1, col: &columns})<CR>

" 保存 vimrc 时自动重载
augroup ReloadVimrc
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC | redraw | call popup_notification('  vimrc reloaded ✓ ', #{time: 800, highlight: 'Normal', pos: 'botright', line: &lines - 1, col: &columns})
augroup END

" unbind keys
map <C-a> <Nop>
map <C-x> <Nop>
" S = cc（删除整行进入 Insert），与 stargate 已重映射 s，S 失去配对意义，覆盖为保存退出
" :x 比 :wq 更智能：仅在 buffer 有改动时才写入，不会无谓地更新文件时间戳
nnoremap S :x<CR>

" disable audible bell
set noerrorbells visualbell t_vb=

" open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" ----- 按视觉行移动（对中文长行友好）-----
"
" 问题：Vim 默认 j/k 按文件实际行跳。一行中文折成多个屏幕行时，
"       按一下 j 会直接跳过所有折行，跳到下一个实际行首——
"       光标"瞬移"，完全感知不到中间的视觉行。
"
" 方案：把 j/k/0/$ 重映射到对应的 gj/gk/g0/g$（按屏幕显示行移动）。
"       带数字前缀时（如 5j）仍按实际行跳，保留行号跳转的精确性。
"
" 切换：<Leader>d 可按 buffer 临时切换回按实际行模式（需要大范围跳转时使用）。
"
" 注意：用 BufEnter 而非 BufReadPost 触发，确保新建的空 buffer
"       （如直接 vim 打开不带文件名）也能立即生效。

function! SetMovementByDisplayLines()
    noremap <buffer> <silent> <expr> j v:count ? 'j' : 'gj'
    noremap <buffer> <silent> <expr> k v:count ? 'k' : 'gk'
    noremap <buffer> <silent> 0 g0
    noremap <buffer> <silent> $ g$
endfunction

function! ToggleMovementByDisplayLines()
    if !exists('b:movement_by_display_lines')
        let b:movement_by_display_lines = 0
    endif
    if b:movement_by_display_lines
        let b:movement_by_display_lines = 0
        silent! nunmap <buffer> j
        silent! nunmap <buffer> k
        silent! nunmap <buffer> 0
        silent! nunmap <buffer> $
    else
        let b:movement_by_display_lines = 1
        call SetMovementByDisplayLines()
    endif
endfunction

nnoremap <silent> <Leader>d :call ToggleMovementByDisplayLines()<CR>
autocmd BufEnter * call SetMovementByDisplayLines()

" ----- Line Numbers -----
set nu                          " number lines
"set rnu                         " relative line numbering
nnoremap <C-n> :call ToggleLineNumbers()<CR>          " toggle line numbers on/off
function! ToggleLineNumbers()
    if(&number == 1)
        set nonumber
    else
        set number
    endif
endfunction

" add new command 'Sudow' to sudo write cur file
command! -nargs=0 Sudow w !sudo tee % >/dev/null

"---------------------
" Plugin configuration
"---------------------

" vim-gitgutter — 在行号左侧显示 git 改动标记
" updatetime 控制停止输入后多久刷新 gutter，默认 4000ms 太慢
set updatetime=100
" 默认的 ]c / [c 跳转 hunk 在定制键盘上不好按，改用 <Leader>hg / <Leader>hk
nnoremap <silent> <Leader>hj :GitGutterNextHunk<CR>
nnoremap <silent> <Leader>hk :GitGutterPrevHunk<CR>
"   <Leader>hp      — 预览当前 hunk 的 diff
"   <Leader>hs      — 暂存（stage）当前 hunk
"   <Leader>hu      — 撤销（undo）当前 hunk

" vim-which-key — 按下 leader 后弹出可用快捷键菜单
" 按下 leader（空格）后停顿 timeoutlen 毫秒，自动弹出菜单列出所有 leader 映射
" 如果在超时前继续按键，菜单不会出现，正常执行映射
" 注意：g:which_key_timeout 对弹出延迟无效（只控制 chord 歧义消解），
"       真正控制弹出速度的是上方的 timeoutlen
let g:which_key_map = {}
call which_key#register('<Space>', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

let g:which_key_map['d'] = '切换视觉行/实际行移动'
let g:which_key_map['n'] = '文件树 开/关'
let g:which_key_map['f'] = '文件树 定位当前文件'

let g:which_key_map['v'] = { 'name': '+vimrc' }
let g:which_key_map['v']['e'] = '编辑 vimrc'
let g:which_key_map['v']['r'] = '重载 vimrc'

let g:which_key_map['y'] = { 'name': '+yank' }
let g:which_key_map['y']['p'] = '复制文件完整路径'

let g:which_key_map['h'] = { 'name': '+git hunk' }
let g:which_key_map['h']['j'] = '下一个 hunk'
let g:which_key_map['h']['k'] = '上一个 hunk'
let g:which_key_map['h']['p'] = '预览 hunk diff'
let g:which_key_map['h']['s'] = '暂存 hunk'
let g:which_key_map['h']['u'] = '撤销 hunk'

let g:which_key_map['l'] = { 'name': '+leetcode' }
let g:which_key_map['l']['t'] = '测试当前题目'
let g:which_key_map['l']['x'] = '提交当前题目'

" auto-pairs
" 禁用 auto-pairs 对 <Space> 的映射，防止它覆盖我们的 <C-g>u<Space> 撤销断点
" （auto-pairs 的 buffer-local 映射优先级更高，会导致 u 一次性撤销整个 Insert 会话）
let g:AutoPairsMapSpace = 0

" rust.vim
let g:rustfmt_autosave = 1

" vim9-stargate — 全屏双向跳转（类似 leap.nvim）
" 输入 s 后键入两个字符，屏幕上所有匹配位置（上下方向）显示标签，按标签直接跳转
noremap s <Cmd>call stargate#OKvim(2)<CR>

" nerdtree
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>f :NERDTreeFind<CR>

" LeetCode Daily  (<Leader>l 为 LeetCode 分组前缀)
nnoremap <Leader>lt :update<Bar>execute '!leetcode test ' . split(expand('%:t'), '\.')[0]<CR>
nnoremap <Leader>lx :execute '!leetcode exec ' . split(expand('%:t'), '\.')[0]<CR>
