source ~/.vim/_/base.vim
source ~/.vim/_/tmux-clipboard.vim

" vim-plug
call plug#begin('~/.vim/plugged')
    Plug '~/.tmux/plugins/easyjump.tmux'
    Plug '~/.zplug/repos/junegunn/fzf' | Plug 'junegunn/fzf.vim', { 'do': 'git apply ~/.vim/_/fzf.vim.patch' }
    Plug 'AndrewRadev/linediff.vim'
    Plug 'Yggdroot/indentLine'
    Plug 'airblade/vim-gitgutter'
    Plug 'itchyny/lightline.vim' | Plug 'mengelbrecht/lightline-bufferline', { 'do': 'git apply ~/.vim/_/lightline-bufferline.patch' }
    Plug 'jiangmiao/auto-pairs'
    Plug 'junegunn/gv.vim'
    Plug 'machakann/vim-highlightedyank'
    Plug 'majutsushi/tagbar', { 'do': 'GO111MODULE=on go get github.com/jstemmer/gotags@master' }
    Plug 'mg979/vim-visual-multi'
    Plug 'mogelbrod/vim-jsonpath'
    Plug 'lifepillar/vim-gruvbox8' | Plug 'sainnhe/gruvbox-material'
    Plug 'lifepillar/vim-mucomplete'
    Plug 'natebosch/vim-lsc', { 'do': '
    \    git apply ~/.vim/_/vim-lsc.patch &&
    \    GO111MODULE=on go get golang.org/x/tools/gopls@latest
    \        && GO111MODULE=on go get golang.org/x/tools/cmd/goimports@master
    \        && GO111MODULE=on go get github.com/go-delve/delve/cmd/dlv@latest &&
    \    npm install -g pyright
    \        && pip install black isort &&
    \    npm install -g bash-language-server
    \        && GO111MODULE=on go get mvdan.cc/sh/v3/cmd/shfmt@latest &&
    \    npm install -g yaml-language-server
    \        && pip install openapi2jsonschema
    \        && ~/.vim/_/yaml/schemas/download
    \', 'for': ['go', 'python', 'sh', 'yaml'] }
    Plug 'othree/eregex.vim'
    Plug 'preservim/nerdtree'
    Plug 'psliwka/vim-smoothie'
    Plug 'TaDaa/vimade'
    Plug 'tommcdo/vim-exchange'
    Plug 'tmux-plugins/vim-tmux-focus-events'
    Plug 'tpope/vim-abolish'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-sleuth'
    Plug 'tpope/vim-surround'
call plug#end()

" gruvbox
set background=dark
colorscheme gruvbox8

" lightline.vim
set laststatus=2
set showtabline=2

function! s:lightline_winnr() abort
    return [
    \    '①', '②', '③', '④', '⑤', '⑥', '⑦', '⑧', '⑨', '⑩',
    \    '⑪', '⑫', '⑬', '⑭', '⑮', '⑯', '⑰', '⑱', '⑲', '⑳',
    \][winnr()-1]
endfunction

function! s:lightline_buffers() abort
    execute printf('highlight LightlineLeft_tabline_tabsel ctermbg=%d', &modified ? 13 : 7)
    return lightline#bufferline#buffers()
endfunction

let g:lightline = {
\    'colorscheme': 'gruvbox_material',
\    'active': {
\        'left': [['mode', 'paste'], ['readonly', 'filename', 'fugitive', 'modified'], ['winnr']],
\        'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']],
\    },
\    'inactive': {
\        'left': [['filename'], [], ['winnr']],
\        'right': [['lineinfo'], ['percent']],
\    },
\    'component': {
\        'lineinfo': '%l/%L',
\        'winnr': '%{'.get(function('s:lightline_winnr'), 'name').'()}',
\    },
\    'tabline': {
\        'left': [['buffers']],
\        'right': [[]],
\    },
\    'component_expand': {
\        'buffers': get(function('s:lightline_buffers'), 'name'),
\        'fugitive': 'FugitiveStatusline',
\    },
\    'component_type': {
\        'buffers': 'tabsel',
\    },
\    'subseparator': { 'left': '│', 'right': '│' },
\}

let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#unnamed = '[No Name]'

source ~/.vim/_/workflow.vim
source ~/.vim/_/quickfix.vim
source ~/.vim/_/ag.vim

" Tagbar
let g:tagbar_position = 'left'
let g:tagbar_width = 40
let g:tagbar_sort = 0
let g:tagbar_autofocus = 1
let g:tagbar_silent = 1

nnoremap <silent> <F8> :call <SID>toggle_tagbar()<CR>
function! s:toggle_tagbar() abort
    NERDTreeClose
    TagbarToggle
endfunction

source ~/.vim/_/brackets-jump.vim

" NERDTree
let g:NERDTreeWinPos = g:tagbar_position
let g:NERDTreeWinSize = g:tagbar_width

nnoremap <silent> <F9> :call <SID>toggle_nerd_tree()<CR>
function! s:toggle_nerd_tree() abort
    TagbarClose
    if g:NERDTree.IsOpen()
        NERDTreeClose
    else
        if expand('%:p') =~# '^\V'.getcwd().(getcwd() == '/' ? '' : '/') && filereadable(expand('%'))
            NERDTreeFind
        else
            NERDTree
        endif
    endif
endfunction

" fzf
let g:fzf_action = {
\    'ctrl-t': 'tab split',
\    'ctrl-s': 'split',
\    'ctrl-v': 'vsplit',
\}

nnoremap <silent> <leader>f :execute trim(system('git rev-parse --is-inside-work-tree')) == 'true'
\ ? 'GFiles --cached --others --exclude-standard'
\ : 'Files'<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>t :BTags<CR>
nnoremap <silent> <leader>w :Windows<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <silent> <leader>o :History<CR>
nnoremap <silent> <leader>, :History:<CR>
nnoremap <silent> <leader>/ :History/<CR>

" Auto Pairs
let g:AutoPairsShortcutToggle = '<F7>'
let g:AutoPairsShortcutJump = '<C-L>'
let g:AutoPairsShortcutFastWrap = ''
let g:AutoPairsShortcutBackInsert = ''
let g:AutoPairsMoveCharacter = ''

" indentLine
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_first_char = '┊'
let g:indentLine_char = g:indentLine_first_char
let g:indentLine_indentLevel = 24
let g:indentLine_fileTypeExclude = ['nerdtree', 'tagbar', 'gitcommit']
let g:indentLine_bufTypeExclude = ['help', 'terminal']
execute "set list lcs=tab:\\".g:indentLine_first_char."\\ "

" commentary.vim
set commentstring=#\ %s
augroup __commentary__
    autocmd!
    autocmd FileType c setlocal commentstring=//\ %s
    autocmd FileType cpp setlocal commentstring=//\ %s
    autocmd FileType vim setlocal commentstring=\"\ %s
augroup END

" MUcomplete
set shortmess+=c
set belloff+=ctrlg
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_mappings = 1
let g:mucomplete#chains = {}
let g:mucomplete#chains.default = [
\    'c-n',
\    'tags',
\    'path',
\]

" vim-visual-multi
let g:VM_maps = {
\    'Find Under': '<leader>n',
\    'Find Subword Under': '<leader>n',
\}

" vim-exchange
nmap <leader>x <Plug>(Exchange)
xmap <leader>x <Plug>(Exchange)
nmap <leader>X <Plug>(ExchangeLine)
nmap <BS>x <Plug>(ExchangeClear)

" vim-highlightedyank
let g:highlightedyank_highlight_duration = 250

" eregex.vim
let g:eregex_default_enable = 0

" vim-jsonpath
augroup __json__
    autocmd!
    autocmd FileType json setlocal keywordprg=:call\ jsonpath#echo()\|Nop
augroup END
command -nargs=* Nop

" vim-lsc
let g:lsc_auto_map = v:false
let g:lsc_enable_autocomplete = v:false
let g:lsc_auto_completeopt = v:false
let g:lsc_server_commands = {}

source ~/.vim/_/go.vim
source ~/.vim/_/python.vim
source ~/.vim/_/sh.vim
source ~/.vim/_/yaml.vim

if len(g:lsc_server_commands) >= 1
    augroup __lsc__
        autocmd!
        execute 'autocmd FileType '.join(keys(g:lsc_server_commands), ',').' call s:lsc_init()'
    augroup END
endif

function! s:lsc_init() abort
    nnoremap <buffer> <silent> gd :LSClientGoToDefinition<CR>
    nnoremap <buffer> <silent> <C-]> :LSClientGoToDefinition<CR>
    nnoremap <buffer> <silent> <C-W>] :LSClientGoToDefinitionSplit<CR>
    nnoremap <buffer> <silent> gr :LSClientFindReferences<CR>
    nnoremap <buffer> <silent> gi :LSClientFindImplementations<CR>
    nnoremap <buffer> <silent> gh :LSClientSignatureHelp<CR>
    inoremap <buffer> <silent> <C-G>h <C-O>:LSClientSignatureHelp<CR>
    nnoremap <buffer> <silent> gs :LSClientWorkspaceSymbol<CR>
    nnoremap <buffer> <silent> [d :call <SID>lsc_diagnostic(v:false)<CR>
    nnoremap <buffer> <silent> ]d :call <SID>lsc_diagnostic(v:true)<CR>
    nnoremap <buffer> <silent> gD :LSClientAllDiagnostics<CR>
    nnoremap <buffer> <silent> <leader>r :LSClientRename<CR>
    nnoremap <buffer> <silent> [r :LSClientPreviousReference<CR>
    nnoremap <buffer> <silent> ]r :LSClientNextReference<CR>
    nnoremap <buffer> <silent> gR :LSClientRestartServer<CR>
    execute 'setlocal completefunc='.get(function('s:lsc_complete'), 'name')
    inoremap <buffer> <C-K> <C-X><C-U>
    setlocal keywordprg=:LSClientShowHover<CR>
endfunction

function! s:lsc_diagnostic(next) abort
    if a:next
        let ComparePositions = {x, y -> x[0] > y[0] || (x[0] == y[0] && x[1] > y[1])}
    else
        let ComparePositions = {x, y -> x[0] < y[0] || (x[0] == y[0] && x[1] < y[1])}
    endif
    let pos = getpos('.')[1:2]
    let nearest_match_pos = []
    for match1 in getmatches()
        if match1.group !~# '^lscDiagnostic'
            continue
        endif
        if has_key(match1, 'pos1')
            let match_pos = match1.pos1
        else
            let match_pos = searchpos(match1.pattern, 'n')
        endif
        if !ComparePositions(match_pos, pos)
            continue
        endif
        if nearest_match_pos == [] || ComparePositions(nearest_match_pos, match_pos)
            let nearest_match_pos = match_pos
        endif
    endfor
    if nearest_match_pos == []
        return
    endif
    let line = nearest_match_pos[0]
    let column = virtcol([line, nearest_match_pos[1]])
    execute printf('normal! %dG%d|', line, column)
endfunction

function! s:lsc_complete(findstart, base) abort
    if !a:findstart
        return lsc#complete#complete(v:false, a:base)
    endif
    call lsc#message#show('Completing...')
    let result = lsc#complete#complete(v:true, a:base)
    if exists('b:lsc_completion') && len(b:lsc_completion) == 0
        unlet b:lsc_completion
        let result = lsc#complete#complete(v:true, a:base)
    endif
    return result
endfunction

highlight link lscCurrentParameter IncSearch
