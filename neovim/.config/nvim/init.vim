source ~/.config/nvim/basic.vim
set shadafile=/workspace/.shada

source ~/.config/nvim/brackets-jump.vim
source ~/.config/nvim/quickfix.vim
source ~/.config/nvim/workflow.vim
source ~/.config/nvim/bang.vim
source ~/.config/nvim/the-silver-searcher.vim
source ~/.config/nvim/tmux-clipboard.vim
source ~/.config/nvim/ai-complete.vim

source ~/.config/nvim/ft-go.vim
source ~/.config/nvim/ft-python.vim
source ~/.config/nvim/ft-sh.vim
source ~/.config/nvim/ft-proto.vim

source ~/.config/nvim/dir-diff.vim

"===================================================================================================
" vim-plug
call plug#begin()
    Plug 'sainnhe/gruvbox-material'
    Plug 'itchyny/lightline.vim'
    Plug 'mengelbrecht/lightline-bufferline', { 'do': 'git apply ~/.config/nvim/plugin-patches/lightline-bufferline.diff' }
    Plug 'psliwka/vim-smoothie'
    Plug 'Yggdroot/indentLine'
    Plug 'tpope/vim-sleuth'
    Plug 'machakann/vim-highlightedyank'
    Plug '~/.zplug/repos/junegunn/fzf' | Plug 'junegunn/fzf.vim', { 'do': 'git apply ~/.config/nvim/plugin-patches/fzf.vim.diff' }
    Plug '~/.tmux/plugins/easyjump.tmux'
    Plug 'othree/eregex.vim'
    if &diff != 1
        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'
        Plug 'lifepillar/vim-mucomplete'
        Plug 'gosukiwi/vim-smartpairs', { 'do': 'git apply ~/.config/nvim/plugin-patches/vim-smartpairs.diff' }
        Plug 'tpope/vim-surround'
        Plug 'arthurxavierx/vim-caser'
        Plug 'tommcdo/vim-exchange'
        Plug 'chrisbra/NrrwRgn'
        Plug 'AndrewRadev/linediff.vim'
        Plug 'hrsh7th/vim-vsnip'
        Plug 'prabirshrestha/vim-lsp', { 'do': join(['git apply ~/.config/nvim/plugin-patches/vim-lsp.diff'] + get(g:, 'ToolInstallCommands', []), ' && ') }
        Plug 'github/copilot.vim'
    endif
call plug#end()
let g:plug_timeout=1200

"===================================================================================================
" gruvbox-material
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_diagnostic_virtual_text = 'highlighted'
set background=dark
colorscheme gruvbox-material

"===================================================================================================
" lightline.vim
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

set showtabline=2

"===================================================================================================
" indentLine
let g:indentLine_first_char = '┊'
let g:indentLine_char = g:indentLine_first_char
execute "set list lcs=tab:\\".g:indentLine_first_char."\\ "
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_bufTypeExclude = ['help', 'terminal']

"===================================================================================================
" vim-highlightedyank
let g:highlightedyank_highlight_duration = 250
highlight HighlightedyankRegion cterm=reverse gui=reverse

"===================================================================================================
" fzf.vim
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

"===================================================================================================
" easyjump.tmux
let g:easyjump_text_attrs = "\e[0m\e[90m"
let g:easyjump_label_attrs = "\e[1m\e[31m"

"===================================================================================================
" eregex.vim
let g:eregex_default_enable = 0

"===================================================================================================
" vim-fugitive
nnoremap <silent> <C-W>g :Git<CR>:execute printf('resize %d', float2nr(&lines*0.382))<CR>
cabbrev G Git

"===================================================================================================
" vim-mucomplete
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_mappings = 1
let g:mucomplete#chains = {}
let g:mucomplete#chains.default = [
\    'c-n',
\    'tags',
\    'path',
\]

"===================================================================================================
" vim-smartpairs
let g:smartpairs_jumps_enabled = 0

"===================================================================================================
" vim-caser
let g:caser_no_mappings = 1
" for camelCase
nmap gsc <Plug>CaserCamelCase
xmap gsc <Plug>CaserVCamelCase
" for PascalCase
nmap gsp <Plug>CaserMixedCase
xmap gsp <Plug>CaserVMixedCase
" for snake_case
nmap gss <Plug>CaserSnakeCase
xmap gss <Plug>CaserVSnakeCase
" for SCREAMING_SNAKE_CASE
nmap gsS <Plug>CaserUpperCase
xmap gsS <Plug>CaserVUpperCase
" for kebab-case
nmap gsk <Plug>CaserKebabCase
xmap gsk <Plug>CaserVKebabCase
" for HTTP-Header-Case
nmap gsh <Plug>CaserTitleKebabCase
xmap gsh <Plug>CaserVTitleKebabCase
" for Title Case
nmap gst <Plug>CaserTitleCase
xmap gst <Plug>CaserVTitleCase
" for space case
nmap gs<space> <Plug>CaserSpaceCase
xmap gs<space> <Plug>CaserVSpaceCase

"===================================================================================================
" vim-exchange
nmap gx <Plug>(Exchange)
xmap gx <Plug>(Exchange)
nmap gxg <Plug>(ExchangeClear)
nmap gxx <Plug>(ExchangeLine)

"===================================================================================================
" NrrwRgn
let g:nrrw_rgn_nohl = 1
let g:nrrw_topbot_leftright = 'botright'
xmap <leader><leader> <Plug>NrrwrgnDo

"===================================================================================================
" vim-vsnip
let g:vsnip_extra_mapping = v:false

"===================================================================================================
" vim-lsp
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_diagnostics_virtual_text_delay = 0
let g:lsp_diagnostics_virtual_text_prefix = '◀ '
let g:lsp_diagnostics_virtual_text_align = 'after'
let g:lsp_diagnostics_virtual_text_padding_left = 2
let g:lsp_document_code_action_signs_enabled = 0
let g:lsp_document_highlight_delay = 0
let g:lsp_signature_help_delay = 0
let g:lsp_completion_documentation_enabled = 0
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
    inoremap <buffer> <expr> <Tab> pumvisible() && len(v:completed_item) >= 1 ? "\<C-Y>" : "\<C-X>\<C-U>"
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

"===================================================================================================
" copilot.vim
imap <silent><script><expr> <C-L> pumvisible() ? "\<C-E>" : copilot#Accept('')
let g:copilot_no_tab_map = v:true
