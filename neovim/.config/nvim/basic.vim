set noswapfile
set shada='10000

set termguicolors
set number
set nowrap
set virtualedit=onemore

set cursorline
set cursorlineopt=line
set colorcolumn=101

set scrolloff=10
set sidescrolloff=10
set startofline

set ignorecase
set smartcase

set shiftwidth=4
set softtabstop=4
set expandtab

set completeopt=menuone,noselect

set splitbelow
set splitright

set updatetime=500

nnoremap gp `[v`]

noremap : ,
noremap , :
noremap q: q,
noremap q, q:

let g:vim_json_conceal = 0
let g:markdown_syntax_conceal = 0

augroup __markdown__
    autocmd!
    autocmd FileType markdown call s:on_markdown_buf()
augroup END

function! s:on_markdown_buf() abort
    if &diff != 1
        let win_id = win_getid()
        call timer_start(0, { _ -> win_execute(win_id, 'setlocal conceallevel=0') })

        setlocal colorcolumn=
        setlocal wrap
        setlocal linebreak
    endif
endfunction

augroup __rstrip__
    autocmd!
    autocmd BufWritePre * retab|%s/\s\+$//e
augroup END

nnoremap <silent> <M-_>#KB#A-H<M-\> :execute (v:hlsearch == '0' ? 'set hlsearch' : 'nohlsearch')<CR>

nnoremap <M-_>#KB#A-W<M-\> :w<CR>
inoremap <M-_>#KB#A-W<M-\> <C-O>:w<CR><esc>

inoremap <M-_>#KB#S-CR<M-\> <C-O>O

inoremap <M-_>#KB#A-A<M-\> <C-O>^
cnoremap <M-_>#KB#A-A<M-\> <Home>

inoremap <M-_>#KB#A-E<M-\> <End>
cnoremap <M-_>#KB#A-E<M-\> <End>

inoremap <M-_>#KB#A-B<M-\> <Left>
cnoremap <M-_>#KB#A-B<M-\> <Left>

inoremap <M-_>#KB#A-F<M-\> <Right>
cnoremap <M-_>#KB#A-F<M-\> <Right>

inoremap <M-_>#KB#A-S-B<M-\> <S-Left>
cnoremap <M-_>#KB#A-S-B<M-\> <S-Left>

inoremap <M-_>#KB#A-S-F<M-\> <S-Right>
cnoremap <M-_>#KB#A-S-F<M-\> <S-Right>

"===================================================================================================

let g:ctrl_g_format = '▶ %s:%d:%d'
let g:ctrl_g_args = ['expand(''%'')', 'line(''.'')', 'virtcol(''.'')']
nnoremap <silent> <C-G> :<C-U>echomsg call('printf', [g:ctrl_g_format] + map(copy(g:ctrl_g_args), { _, arg -> eval(arg) }))<CR>

"===================================================================================================

vnoremap <silent> / :<C-U>let @/='\V\C'..substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')\|set hlsearch<CR>
vnoremap <silent> ? :<C-U>let @/='\V\C'..substitute(escape(GetVisualSelection(), '/\'), "\n", '\\n', 'g')\|set hlsearch<CR>

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
        let lines[-1] = lines[-1].."\n"
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
        let keys ..= printf('i%%s/\V\C%s/%s/g', word2, word3)
            \..printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys ..= printf('i%%s/\V\C\<%s\>/%s/g', word, word)
            \..printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
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
        let keys ..= printf('ig/\V\C%s/d', word2)
            \..printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys ..= printf('ig/\V\C\<%s\>/d', word)
            \..printf("\<esc>%dhv", 3 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    endif
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

nnoremap <silent> \\k :call <SID>super_k('n')<CR>
vnoremap <silent> \\k :<C-U>call <SID>super_k('v')<CR>

function! s:super_k(mode) abort
    let keys = 'q:'
    if a:mode ==# 'v'
        let word = escape(GetVisualSelection(), '/\')
        let word2 = substitute(word, "\n", '\\n', 'g')
        let n_chars = strchars(word)
        let keys ..= printf('ig!/\V\C%s/d', word2)
            \..printf("\<esc>%dhv", 1 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    else
        let word = expand('<cword>')
        if word ==# ''
            return
        endif
        let n_chars = strchars(word)
        let keys ..= printf('ig!/\V\C\<%s\>/d', word)
            \..printf("\<esc>%dhv", 3 + n_chars).(n_chars >= 2 ? printf('%dl', n_chars - 1) : '')
    endif
    call feedkeys(keys, 'n')
endfunction

"===================================================================================================

nnoremap <silent> \\e :call <SID>super_e()<CR>
nnoremap <silent> \\w :call <SID>super_w()<CR>

function! s:super_e() abort
    let keys = 'q:'
        \..printf('ie %s', expand('%:p'))
        \.."\<esc>T/v$h"
    call feedkeys(keys, 'n')
endfunction

function! s:super_w() abort
    let keys = 'q:'
        \..printf('iw %s', expand('%:p'))
        \.."\<esc>T/v$h"
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

nnoremap <silent> gm :call <SID>goto_end_of_match('n')<CR>
onoremap <silent> m :call <SID>goto_end_of_match('o')<CR>
vnoremap <silent> m :call <SID>goto_end_of_match('v')<CR>

function! s:goto_end_of_match(mode) abort
    if a:mode ==# 'v'
        normal! gv
    endif
    let pattern = getreg('/')
    let [line_num, col_num] = searchpos(pattern, 'cenW')
    if line_num == 0 && col_num == 0
        throw 'Pattern not found: '..pattern
    endif
    call cursor(line_num, col_num + (a:mode ==# 'n' || a:mode ==# 'v' ? 0 : 1))
endfunction

nnoremap <silent> gM :call <SID>goto_begin_of_match('n')<CR>
onoremap <silent> M :call <SID>goto_begin_of_match('o')<CR>
vnoremap <silent> M :call <SID>goto_begin_of_match('v')<CR>

function! s:goto_begin_of_match(mode) abort
    if a:mode ==# 'v'
        normal! gv
    endif
    let pattern = getreg('/')
    let [line_num, col_num] = searchpos(pattern, 'bcnW')
    if line_num == 0 && col_num == 0
        throw 'Pattern not found: '..pattern
    endif
    call cursor(line_num, col_num)
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
        call timer_start(0, { _ -> systemlist('clip', data) })
    else
        call timer_start(0, { _ -> systemlist('pbcopy', data) })
    endif
endfunction
