set noswapfile
set shada='10000

set termguicolors
set number
set nowrap
set colorcolumn=101
set virtualedit=onemore

set scrolloff=10
set sidescrolloff=10

set ignorecase
set smartcase

set shiftwidth=4
set softtabstop=4
set expandtab

set completeopt=menuone,noselect

set splitbelow
set splitright

set updatetime=500

let g:vim_json_conceal = 0
let g:markdown_syntax_conceal = 0

augroup __rstrip__
    autocmd!
    autocmd BufWritePre * retab|%s/\s\+$//e
augroup END

let g:mapleader = ' '

noremap : ,
noremap , :
noremap q: q,
noremap q, q:

inoremap <Esc>@a <C-O>^
cnoremap <Esc>@a <C-B>
noremap <Esc>@a ^
inoremap <Esc>@e <C-O>$
cnoremap <Esc>@e <C-E>
noremap <Esc>@e $
inoremap <Esc>@b <C-O>h
cnoremap <Esc>@b <Left>
inoremap <Esc>@f <C-O>l
cnoremap <Esc>@f <Right>
inoremap <Esc>@B <C-O>b
cnoremap <Esc>@B <C-Left>
inoremap <Esc>@F <C-O>w
cnoremap <Esc>@F <C-Right>

nnoremap <silent> <Esc>@h :execute (v:hlsearch == '0' ? 'set hlsearch' : 'nohlsearch')<CR>

"===================================================================================================

let g:ctrl_g_format = '▶ %s:%d:%d'
let g:ctrl_g_args = ['expand(''%'')', 'line(''.'')', 'virtcol(''.'')']
nnoremap <silent> <C-G> :<C-U>echomsg call('printf', [g:ctrl_g_format] + map(copy(g:ctrl_g_args), {_, arg -> eval(arg)}))<CR>

"===================================================================================================

vnoremap / o<ESC>/\V\C<C-R>=substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')<CR>
vnoremap ? o<ESC>?\V\C<C-R>=substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')<CR>

function! GetVisualSelection() abort
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let i = column_start - 1
    let j = column_end - (&selection == 'inclusive' ? 1 : 2)
    let append_trailing_newline = visualmode() ==# 'V' || j == len(lines[-1])
    let lines[0] = lines[0][i:]
    if len(lines) == 1
        let j -= i
    endif
    let lines[-1] = lines[-1][:j]
    if append_trailing_newline
        let lines[-1] = lines[-1]."\n"
    endif
    return join(lines, "\n")
endfunction

"===================================================================================================

nnoremap <silent> \\s :call <SID>super_s('n')<CR>
vnoremap <silent> \\s :<C-U>call <SID>super_s('v')<CR>

function! s:super_s(mode) abort
    let keys = 'q:'
    if a:mode ==# 'v'
        let word = escape(GetVisualSelection(), '/\')
        let word2 = substitute(word, "\n", '\\n', 'g')
        let word3 = substitute(escape(word, "&~"), "\n", '\\r', 'g')
        let n_chars = strchars(word)
        let keys .= printf('i%%s/\V\C%s/%s/g', word2, word3)
            \.printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys .= printf('i%%s/\V\C\<%s\>/%s/g', word, word)
            \.printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    endif
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

nnoremap <silent> \\d :call <SID>super_d('n')<CR>
vnoremap <silent> \\d :<C-U>call <SID>super_d('v')<CR>

function! s:super_d(mode) abort
    let keys = 'q:'
    if a:mode ==# 'v'
        let word = escape(GetVisualSelection(), '/\')
        let word2 = substitute(word, "\n", '\\n', 'g')
        let n_chars = strchars(word)
        let keys .= printf('ig/\V\C%s/d', word2)
            \.printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys .= printf('ig/\V\C\<%s\>/d', word)
            \.printf("\<esc>%dhv", 3 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    endif
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

nnoremap <silent> \\d :call <SID>super_k('n')<CR>
vnoremap <silent> \\k :<C-U>call <SID>super_k('v')<CR>

function! s:super_k(mode) abort
    let keys = 'q:'
    if a:mode ==# 'v'
        let word = escape(GetVisualSelection(), '/\')
        let word2 = substitute(word, "\n", '\\n', 'g')
        let n_chars = strchars(word)
        let keys .= printf('ig!/\V\C%s/d', word2)
            \.printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys .= printf('ig!/\V\C\<%s\>/d', word)
            \.printf("\<esc>%dhv", 3 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    endif
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

nnoremap <silent> \\e :call <SID>super_e()<CR>
nnoremap <silent> \\w :call <SID>super_w()<CR>

function! s:super_e() abort
    let keys = 'q:'
        \.printf('ie %s', expand('%:p'))
        \."\<esc>T/v$h"
    call feedkeys(keys, 'n')
endfunction

function! s:super_w() abort
    let keys = 'q:'
        \.printf('iw %s', expand('%:p'))
        \."\<esc>T/v$h"
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

vnoremap <silent> \\b :<C-U>call <SID>bash()<CR>

func! s:bash() abort
    let script = GetVisualSelection()
    let output = system('bash -euxo pipefail -', script)
    vnew
    set buftype=nofile
    0put =output
endfunction

"===================================================================================================

onoremap <silent> m :call <SID>goto_end_of_match('o')<CR>
vnoremap <silent> m :call <SID>goto_end_of_match('v')<CR>

function! s:goto_end_of_match(mode) abort
    if a:mode ==# 'v'
        normal! gv
    endif
    let pattern = getreg('/')
    let [line_num, col_num] = searchpos(pattern, 'cenW')
    if line_num == 0 && col_num == 0
        throw 'Pattern not found: '.pattern
    endif
    call cursor(line_num, col_num + (a:mode ==# 'v' ? 0 : 1))
endfunction

"===================================================================================================

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
