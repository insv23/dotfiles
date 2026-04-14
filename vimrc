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
    " 去掉行号区域的下划线
    autocmd ColorScheme,VimEnter * highlight CursorLineNr term=NONE cterm=NONE
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
set laststatus=2
set statusline=%{fnamemodify(expand('%:p:h'),':t')}/%t\ %m%=%l:%c
set backspace=indent,eol,start  " allow backspacing over everything
set timeout timeoutlen=1000 ttimeoutlen=100 " fix slow O inserts
set lazyredraw                  " skip redrawing screen in some cases
set autochdir                   " automatically set current directory to directory of last opened file
set hidden                      " allow auto-hiding of edited buffers
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
nmap Q :wq<CR>

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

" movement relative to display lines
nnoremap <silent> <Leader>d :call ToggleMovementByDisplayLines()<CR>
function! SetMovementByDisplayLines()
    noremap <buffer> <silent> <expr> k v:count ? 'k' : 'gk'
    noremap <buffer> <silent> <expr> j v:count ? 'j' : 'gj'
    noremap <buffer> <silent> 0 g0
    noremap <buffer> <silent> $ g$
endfunction
function! ToggleMovementByDisplayLines()
    if !exists('b:movement_by_display_lines')
        let b:movement_by_display_lines = 0
    endif
    if b:movement_by_display_lines
        let b:movement_by_display_lines = 0
        silent! nunmap <buffer> k
        silent! nunmap <buffer> j
        silent! nunmap <buffer> 0
        silent! nunmap <buffer> $
    else
        let b:movement_by_display_lines = 1
        call SetMovementByDisplayLines()
    endif
endfunction

" 默认启用按显示行移动（对中文长文本友好）
autocmd BufReadPost * call SetMovementByDisplayLines()

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
