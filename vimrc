set nocompatible " not vi compatible

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

" ===== 中文支持 =====
set encoding=utf-8
set fileencodings=utf-8,gbk,gb2312,gb18030
set breakindent               " 软换行续行保持缩进
set ambiwidth=double          " 东亚字符宽度

filetype plugin indent on " enable file type detection
set autoindent

"---------------------
" Basic editing config
"---------------------
set clipboard=unnamed           " system clipboard
set noswapfile                  " no swap file
set shortmess+=I                " disable startup message
set incsearch                   " incremental search (as string is being typed)
set hls                         " highlight search
set listchars=tab:>>,nbsp:~     " set list to see tabs and non-breakable spaces
set lbr                         " line break
set scrolloff=5                 " show lines above and below cursor (when possible)
set noshowmode                  " hide mode
set laststatus=2
set backspace=indent,eol,start  " allow backspacing over everything
set timeout timeoutlen=1000 ttimeoutlen=100 " fix slow O inserts
set lazyredraw                  " skip redrawing screen in some cases
set autochdir                   " automatically set current directory to directory of last opened file
set hidden                      " allow auto-hiding of edited buffers
set history=8192                " more history
set nojoinspaces                " suppress inserting two spaces between sentences

" enable ssh cilpboard, keybinding: <leader>y
vnoremap <leader>y :OSCYankVisual<CR>

" 在 SSH 环境下，每次 yank 自动通过 OSC 52 同步到本地剪贴板
if !empty($SSH_CONNECTION)
    autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister "' | endif
endif

nnoremap H 0
nnoremap L $
nnoremap <C-e> %    " 跳转到匹配的括号、括弧或引号
nnoremap yie :%y+<CR>   " 复制整个文件的内容到系统剪贴板

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
function SetMovementByDisplayLines()
    noremap <buffer> <silent> <expr> k v:count ? 'k' : 'gk'
    noremap <buffer> <silent> <expr> j v:count ? 'j' : 'gj'
    noremap <buffer> <silent> 0 g0
    noremap <buffer> <silent> $ g$
endfunction
function ToggleMovementByDisplayLines()
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
command -nargs=0 Sudow w !sudo tee % >/dev/null

"---------------------
" Plugin configuration
"---------------------

" nerdtree
nnoremap <Leader>n :NERDTreeToggle<CR>
nnoremap <Leader>f :NERDTreeFind<CR>
