" *nix: curl -x <PROXY> -Lo ~/.vimrc https://github.com/roy2220/dotfiles/raw/master/vim/.vim/_/base.vim
" windows: curl -x <PROXY> -Lo %HOMEPATH%\.vimrc https://github.com/roy2220/dotfiles/raw/master/vim/.vim/_/base.vim
set nocompatible
set nowritebackup
set noswapfile

set regexpengine=1
set ttyfast
set lazyredraw

if &term =~ '^\(xterm\|tmux\|screen\)\>'
    let [&t_SI, &t_SR, &t_EI] = ["\e[5 q", "\e[3 q", "\e[1 q"]
endif

noremap : ,
noremap , :
noremap q: q,
noremap q, q:
nnoremap Y y$

let g:ctrl_g_format = '%s:%d:%d'
let g:ctrl_g_args = ['expand(''%:p'')', 'line(''.'')', 'virtcol(''.'')']
nnoremap <silent> <C-G> :<C-U>echomsg call('printf', [g:ctrl_g_format] + map(copy(g:ctrl_g_args), {_, arg -> eval(arg)}))<CR>

inoremap <C-A> <C-O>^
inoremap <C-E> <C-O>$

set number
set ruler
set showcmd

set nowrap
set colorcolumn=101

set ignorecase smartcase
set hlsearch incsearch
nnoremap <silent> <F5> :nohlsearch<CR>

set virtualedit=onemore
set whichwrap=b,s,h,l,<,>,[,]

set mouse=a
"===================================================================================================
" source xterm-paste.vim
if &term =~ '^\(xterm\|tmux\|screen\)\>'
    let [&t_SI, &t_EI] .= ["\e[?2004h", "\e[?2004l"]

    inoremap <special> <expr> <Esc>[200~ <SID>xterm_paste_begin()
    function! s:xterm_paste_begin() abort
        set pastetoggle=<Esc>[201~
        set paste
        return ''
    endfunction
else
    set pastetoggle=<F6>
endif
"===================================================================================================

set shiftwidth=4 softtabstop=4 expandtab
augroup __whitespace__
    autocmd!
    autocmd BufWritePre * retab|%s/\s\+$//e
augroup END

set completeopt=menuone,noinsert,noselect
set cinoptions=:0,l1,g0,N-s,(0,Ws

set scrolloff=5 sidescrolloff=5

set timeoutlen=1000 ttimeoutlen=0
set updatetime=500

set splitbelow splitright

try
    set diffopt+=vertical
catch
    set diffopt-=internal
    set diffopt+=vertical
endtry

set fillchars+=vert:│

let g:mapleader = ' '

"===================================================================================================
"source get-visual-selection.vim
function! GetVisualSelection() abort
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction
"===================================================================================================
vnoremap / o<ESC>/\V\C<C-R>=substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')<CR>
vnoremap ? o<ESC>?\V\C<C-R>=substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')<CR>

nnoremap \\s :%s/\V\C<C-R>=expand('<cword>')<CR>//g<left><left>
nnoremap \\s :let g:tmp = expand('<cword>')<CR>
    \q:i%s/\V\C<C-R>=g:tmp<CR>/<C-O>m'<C-R>=g:tmp<CR>/g<ESC>`'v$3h
    \:<C-U>unlet g:tmp<CR>gvo
vnoremap \\s :<C-U>let g:tmp = escape(GetVisualSelection(), '/\')<CR>
    \q:i%s/\V\C<C-R>=substitute(g:tmp, "\n", '\\n', 'g')<CR>/<C-O>m'<C-R>=substitute(g:tmp, "\n", '\\r', 'g')<CR>/g<ESC>`'v$3h
    \:<C-U>unlet g:tmp<CR>gvo
nnoremap \\e :let g:tmp = expand('%:p')<CR>
    \q:ie <C-R>=g:tmp<CR><ESC>T/v$h
    \:<C-U>unlet g:tmp<CR>gvo
nnoremap \\w :let g:tmp = expand('%:p')<CR>
    \q:iw <C-R>=g:tmp<CR><ESC>T/v$h
    \:<C-U>unlet g:tmp<CR>gvo

augroup __systemclipboard__
    autocmd!
    autocmd TextYankPost * call s:sync_clipboard_to_system(v:event)
augroup END

function! s:sync_clipboard_to_system(event) abort
    if !(v:event.regname == '' && v:event.operator ==# 'y')
        return
    endif
    let data = a:event.regcontents
    if a:event.regtype ==# 'V'
        let data = data + ['']
    endif
    if has('win32')
        call timer_start(0, {_ -> systemlist('clip', data)})
    else
        call timer_start(0, {_ -> systemlist('pbcopy', data)})
    endif
endfunction

syntax on
filetype plugin indent on

let g:vim_json_conceal = 0
let g:markdown_syntax_conceal = 0

" *nix: curl -x <PROXY> -Lo ~/.vim/colors/gruvbox8.vim --create-dirs https://github.com/lifepillar/vim-gruvbox8/raw/master/colors/gruvbox8.vim
" windows: curl -x <PROXY> -Lo %HOMEPATH%\vimfiles\colors\gruvbox8.vim --create-dirs https://github.com/lifepillar/vim-gruvbox8/raw/master/colors/gruvbox8.vim
"set background=dark
"let g:gruvbox_italics = 0
"colorscheme gruvbox8
