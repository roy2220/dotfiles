source ~/.vim/_/base.vim | set viminfofile=/workspace/.viminfo
source ~/.vim/_/tmux-clipboard.vim

" vim-plug
let g:plug_timeout=1200
call plug#begin('~/.vim/plugged')
    if &diff != 1
        Plug '~/.zplug/repos/junegunn/fzf'
        Plug 'junegunn/fzf.vim', { 'do': 'git apply ~/.vim/_/fzf.vim.patch' }
        Plug 'AndrewRadev/linediff.vim'
        Plug 'arthurxavierx/vim-caser'
        Plug 'airblade/vim-gitgutter'
        Plug 'chrisbra/NrrwRgn'
        Plug 'gosukiwi/vim-smartpairs', { 'do': 'git apply ~/.vim/_/vim-smartpairs.patch' }
        Plug 'hrsh7th/vim-vsnip'
        Plug 'junegunn/gv.vim'
        Plug 'majutsushi/tagbar', { 'do': 'go install github.com/jstemmer/gotags@master' }
        Plug 'mg979/vim-visual-multi'
        Plug 'mogelbrod/vim-jsonpath'
        Plug 'lifepillar/vim-mucomplete'
        Plug 'prabirshrestha/vim-lsp', { 'do': '
        \    git apply ~/.vim/_/vim-lsp.patch &&
        \    go install golang.org/x/tools/gopls@latest
        \        && go install golang.org/x/tools/cmd/goimports@master
        \        && go install github.com/go-delve/delve/cmd/dlv@latest &&
        \    npm install -g pyright
        \        && pip install autoflake black isort &&
        \    npm install -g bash-language-server
        \        && go install mvdan.cc/sh/v3/cmd/shfmt@latest &&
        \    go install github.com/lasorda/protobuf-language-server@latest
        \' }
        Plug 'othree/eregex.vim'
        Plug 'preservim/nerdtree'
        Plug 'tommcdo/vim-exchange'
        Plug 'tpope/vim-commentary'
        Plug 'tpope/vim-fugitive'
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-sleuth'
        Plug 'tpope/vim-surround'
    endif

    Plug '~/.tmux/plugins/easyjump.tmux'
    Plug 'sainnhe/gruvbox-material'
    Plug 'itchyny/lightline.vim'
    Plug 'Yggdroot/indentLine'
    Plug 'mengelbrecht/lightline-bufferline', { 'do': 'git apply ~/.vim/_/lightline-bufferline.patch' }
    Plug 'psliwka/vim-smoothie'
    Plug 'machakann/vim-highlightedyank'
    Plug 'tmux-plugins/vim-tmux-focus-events'
call plug#end()

" easyjump.vim
let g:easyjump_text_attrs = "\e[0m\e[90m"
let g:easyjump_label_attrs = "\e[1m\e[31m"

" gruvbox8
let g:gruvbox_material_better_performance = 1
set background=dark
colorscheme gruvbox-material

" lightline.vim
set laststatus=2
set showtabline=2

function! s:lightline_winnr() abort
    return [
    \   '‹1›', '‹2›', '‹3›', '‹4›', '‹5›', '‹6›', '‹7›', '‹8›', '‹9›', '‹10›',
    \   '‹11›', '‹12›', '‹13›', '‹14›', '‹15›', '‹16›', '‹17›', '‹18›', '‹19›', '‹20›',
    \][winnr()-1]
endfunction

function! s:lightline_buffers() abort
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
source ~/.vim/_/exchange.vim
source ~/.vim/_/ai-complete.vim
let $PATH = $HOME.'/.vim/_/chatgpt:'.$PATH

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
let g:NERDTreeMouseMode = 3

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
let g:fzf_colors = {}
let g:fzf_layout = {'tmux': '-p62%,62%'}
let g:fzf_preview_window = []
let g:fzf_action = {
\    'ctrl-t': 'tab split',
\    'ctrl-s': 'split',
\    'ctrl-v': 'vsplit',
\}

nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>t :BTags<CR>
nnoremap <silent> <leader>a :call fzf#vim#grep('ag --nogroup --color ''(?<=^.)''', fzf#vim#with_preview({'options': '--delimiter=: --nth=3..'}))<CR>
nnoremap <silent> <leader>w :Windows<CR>
nnoremap <silent> <leader>c :Commands<CR>
nnoremap <silent> <leader>o :History<CR>
nnoremap <silent> <leader>, :History:<CR>
nnoremap <silent> <leader>/ :History/<CR>

" fugitive.vim
nnoremap <silent> <C-W>g :Git<CR>:execute printf('resize %d', float2nr(&lines*0.382))<CR>
cabbrev G Git

" smartpairs.vim
let g:smartpairs_jumps_enabled = 0

" caser.vim
let g:caser_no_mappings = 1
" * camelCase
nmap gsc <Plug>CaserCamelCase
xmap gsc <Plug>CaserVCamelCase
" * PascalCase
nmap gsp <Plug>CaserMixedCase
xmap gsp <Plug>CaserVMixedCase
" * snake_case
nmap gss <Plug>CaserSnakeCase
xmap gss <Plug>CaserVSnakeCase
" * SCREAMING_SNAKE_CASE
nmap gsS <Plug>CaserUpperCase
xmap gsS <Plug>CaserVUpperCase
" * kebab-case
nmap gsk <Plug>CaserKebabCase
xmap gsk <Plug>CaserVKebabCase
" * HTTP-Header-Case
nmap gsh <Plug>CaserTitleKebabCase
xmap gsh <Plug>CaserVTitleKebabCase
" * Title Case
nmap gst <Plug>CaserTitleCase
xmap gst <Plug>CaserVTitleCase
" * space case
nmap gs<space> <Plug>CaserSpaceCase
xmap gs<space> <Plug>CaserVSpaceCase

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

" vim-exchange
nmap gx <Plug>(Exchange)
xmap gx <Plug>(Exchange)
nmap gxg <Plug>(ExchangeClear)
nmap gxx <Plug>(ExchangeLine)

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

" NrrwRgn
let g:nrrw_rgn_nohl = 1
let g:nrrw_topbot_leftright = 'botright'
xmap <leader><leader> <Plug>NrrwrgnDo

" vim-highlightedyank
let g:highlightedyank_highlight_duration = 250
highlight HighlightedyankRegion cterm=reverse gui=reverse

" eregex.vim
let g:eregex_default_enable = 0

" vim-jsonpath
augroup __json__
    autocmd!
    autocmd FileType json setlocal keywordprg=:call\ jsonpath#echo()\|Nop
augroup END
command -nargs=* Nop

" vim-vsnip
let g:vsnip_extra_mapping = v:false

" vim-lsp
set maxmem=2000000
set maxmemtot=2000000
set maxmempattern=2000000
let g:lsp_use_native_client = 1
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_diagnostics_virtual_text_delay = 0
let g:lsp_diagnostics_virtual_text_prefix = '👈 '
let g:lsp_diagnostics_virtual_text_align = 'after'
let g:lsp_diagnostics_virtual_text_padding_left = 2
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_document_highlight_delay = 0
let g:lsp_signature_help_delay = 0
function! s:lsp_get_supported_capabilities(server_info) abort
    let capabilities = lsp#default_get_supported_capabilities(a:server_info)
    let capabilities.textDocument.completion.completionItem.snippetSupport = v:true
    return capabilities
endfunction
let g:lsp_get_supported_capabilities = [function('s:lsp_get_supported_capabilities')]
let g:lsp_snippet_expand = [{item -> vsnip#anonymous(item.snippet)}]

function! s:on_lsp_buffer_enabled() abort
    nnoremap <buffer> gd <plug>(lsp-definition)
    nnoremap <buffer> <C-]> <plug>(lsp-definition)
    nnoremap <buffer> gr <plug>(lsp-references)
    nnoremap <buffer> gi <plug>(lsp-implementation)
    nnoremap <buffer> gh <plug>(lsp-signature-help)
    nnoremap <buffer> [d <plug>(lsp-previous-diagnostic)
    nnoremap <buffer> ]d <plug>(lsp-next-diagnostic)
    nnoremap <buffer> <silent> gD :LspDocumentDiagnostics --buffers=*<CR>
    nnoremap <buffer> <leader>r <plug>(lsp-rename)
    nnoremap <buffer> [r <plug>(lsp-previous-reference)
    nnoremap <buffer> ]r <plug>(lsp-next-reference)
    nnoremap <buffer> <silent> gR :call <SID>restart_lsp_server()<CR>
    setlocal keywordprg=:LspHover<CR>
    setlocal completefunc=lsp#complete
    inoremap <buffer> <Tab> <C-X><C-U>
endfunction

function! s:restart_lsp_server() abort
    let ft=&filetype
    set filetype=
    execute 'autocmd User lsp_server_exit ++once set filetype='.ft
    call lsp#stop_server(ft)
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

source ~/.vim/_/go.vim
source ~/.vim/_/python.vim
source ~/.vim/_/sh.vim
source ~/.vim/_/proto.vim
source ~/.vim/_/dir-diff.vim
