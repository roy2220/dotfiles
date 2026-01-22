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
source ~/.config/nvim/ft-yaml.vim

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
    Plug 'neoclide/jsonc.vim'
    if &diff != 1
        Plug 'tpope/vim-repeat'
        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'
        Plug 'knsh14/vim-github-link'
        Plug 'lifepillar/vim-mucomplete'
        Plug 'gosukiwi/vim-smartpairs', { 'do': 'git apply ~/.config/nvim/plugin-patches/vim-smartpairs.diff' }
        Plug 'tpope/vim-surround'
        Plug 'arthurxavierx/vim-caser'
        Plug 'tommcdo/vim-exchange'
        Plug 'chrisbra/NrrwRgn'
        Plug 'AndrewRadev/linediff.vim'
        Plug 'hrsh7th/vim-vsnip'
        Plug 'prabirshrestha/vim-lsp', { 'do': join(['git apply ~/.config/nvim/plugin-patches/vim-lsp.diff'] + get(g:, 'ToolInstallCommands', []), ' && ') }
        Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master', 'do': ':'..join([
        \    'TSUpdateSync',
        \    exists('g:TreeSitterParsersToInstall') ? 'TSInstallSync '..join(g:TreeSitterParsersToInstall, ' ') : '',
        \    'call system(''git apply ~/.config/nvim/plugin-patches/nvim-treesitter.diff'')',
        \], '\|') }
        Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'branch': 'master' }
        Plug 'milanglacier/minuet-ai.nvim' | Plug 'nvim-lua/plenary.nvim'
    endif
call plug#end()
let g:plug_timeout=1200

"===================================================================================================
" gruvbox-material
let g:gruvbox_material_better_performance = 1
let g:gruvbox_material_background = 'soft'
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
\        'winnr': '%{'..get(function('s:lightline_winnr'), 'name')..'()}',
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
\    'subseparator': { 'left': '︙', 'right': '︙' },
\}

let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#unnamed = '[No Name]'

set showtabline=2

"===================================================================================================
" indentLine
let g:indentLine_first_char = '┊'
let g:indentLine_char = g:indentLine_first_char
execute "set list lcs=tab:\\"..g:indentLine_first_char.."\\ "
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

nnoremap <silent> <M-_>KB=A-F<M-\> :call <SID>fzf_files(v:false)<CR>
nnoremap <silent> <M-_>KB=A-S-F<M-\> :call <SID>fzf_files(v:true)<CR>
nnoremap <silent> <M-_>KB=A-B<M-\> :Buffers<CR>
nnoremap <silent> <M-_>KB=A-T<M-\> :BTags<CR>
nnoremap <silent> <M-_>KB=A-O<M-\> :History<CR>
nnoremap <silent> <M-_>KB=A-,<M-\> :History:<CR>
nnoremap <silent> <M-_>KB=A-/<M-\> :History/<CR>

function! s:fzf_files(check_cur_file_dir) abort
    let cur_file_dir_path = expand('%:p:h')
    if a:check_cur_file_dir
        call fzf#vim#files(cur_file_dir_path)
        return
    endif

    let cur_dir_path = getcwd()
    if cur_file_dir_path[:len(cur_dir_path)] ==# cur_dir_path.'/'
        let query = cur_file_dir_path[len(cur_dir_path) + 1:].'/'
        call fzf#vim#files('', fzf#vim#with_preview({'options': ['--query='.query]}))
        return
    endif

    call fzf#vim#files('')
endfunction

"===================================================================================================
" easyjump.tmux
let g:easyjump_text_attrs = "\e[0m\e[38;5;245m"
let g:easyjump_label_attrs = "\e[1m\e[31m"

nmap <M-_>KB=A-J<M-\> <Plug>EasyJump
imap <M-_>KB=A-J<M-\> <Plug>EasyJump
vmap <M-_>KB=A-J<M-\> <Plug>EasyJump
omap <M-_>KB=A-J<M-\> <Plug>EasyJump

"===================================================================================================
" eregex.vim
let g:eregex_default_enable = 0

"===================================================================================================
" vim-fugitive
nnoremap <silent> <C-W>g :Git<CR>:execute printf('resize %d', float2nr(&lines*0.382))<CR>
cabbrev G Git

"===================================================================================================
" vim-gitgutter

let g:gitgutter_async = 0
let g:gitgutter_preview_win_floating = 0

nmap <M-_>KB=A-G<M-\>p <Plug>(GitGutterPreviewHunk)
nmap <M-_>KB=A-G<M-\>s <Plug>(GitGutterStageHunk)
nmap <M-_>KB=A-G<M-\>u <Plug>(GitGutterUndoHunk)

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
nmap <M-_>KB=A-C<M-\>c <Plug>CaserCamelCase
vmap <M-_>KB=A-C<M-\>c <Plug>CaserVCamelCase
" for PascalCase
nmap <M-_>KB=A-C<M-\>p <Plug>CaserMixedCase
vmap <M-_>KB=A-C<M-\>p <Plug>CaserVMixedCase
" for snake_case
nmap <M-_>KB=A-C<M-\>s <Plug>CaserSnakeCase
vmap <M-_>KB=A-C<M-\>s <Plug>CaserVSnakeCase
" for SCREAMING_SNAKE_CASE
nmap <M-_>KB=A-C<M-\>S <Plug>CaserUpperCase
vmap <M-_>KB=A-C<M-\>S <Plug>CaserVUpperCase
" for kebab-case
nmap <M-_>KB=A-C<M-\>k <Plug>CaserKebabCase
vmap <M-_>KB=A-C<M-\>k <Plug>CaserVKebabCase
" for HTTP-Header-Case
nmap <M-_>KB=A-C<M-\>h <Plug>CaserTitleKebabCase
vmap <M-_>KB=A-C<M-\>h <Plug>CaserVTitleKebabCase
" for Title Case
nmap <M-_>KB=A-C<M-\>t <Plug>CaserTitleCase
vmap <M-_>KB=A-C<M-\>t <Plug>CaserVTitleCase
" for space case
nmap <M-_>KB=A-C<M-\><Space> <Plug>CaserSpaceCase
vmap <M-_>KB=A-C<M-\><Space> <Plug>CaserVSpaceCase

"===================================================================================================
" vim-exchange
nmap <M-_>KB=A-X<M-\> <Plug>(Exchange)
vmap <M-_>KB=A-X<M-\> <Plug>(Exchange)
nmap <M-_>KB=A-X<M-\><BS> <Esc> <Plug>(ExchangeClear)
nmap <M-_>KB=A-S-X<M-\> <Plug>(ExchangeLine)

"===================================================================================================
" NrrwRgn
let g:nrrw_rgn_nohl = 1
let g:nrrw_topbot_leftright = 'botright'
vmap <C-W>e <Plug>NrrwrgnDo

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
let g:lsp_snippet_expand = [{ item -> vsnip#anonymous(item.snippet) }]

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
    nnoremap <buffer> <silent> gR :call <SID>lsp_restart_server()<CR>
    setlocal keywordprg=:LspHover<CR>
    setlocal completefunc=lsp#complete
    inoremap <buffer> <script><expr> <Tab> <SID>lsp_complete_or_select()
endfunction

function! s:lsp_restart_server() abort
    let servers = filter(lsp#get_allowed_servers(), { _, name -> lsp#is_server_running(name) })
    if empty(servers)
        return
    endif

    execute 'autocmd User lsp_server_exit ++once set filetype= | set filetype='..&filetype
    for server in servers
        call lsp#stop_server(server)
    endfor
endfunction

function! s:lsp_complete_or_select() abort
    if !pumvisible() || empty(v:completed_item)
        return "\<C-X>\<C-U>"
    else
        call timer_start(0, { _ -> feedkeys("\<C-X>\<C-U>") })
        return "\<C-Y>"
    endif
endfunction

augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

"===================================================================================================
" copilot.vim
let g:copilot_proxy = 'https://host.docker.internal:7890'
let g:copilot_filetypes = {'*': v:false}
let g:copilot_no_tab_map = v:true

inoremap <script><expr> <C-L> <SID>copilot_suggest_or_accept()
function! s:copilot_suggest_or_accept() abort
    if pumvisible()
        " retry
        call timer_start(0, { _ -> s:copilot_suggest_or_accept() })
        if empty(v:completed_item)
            return "\<C-E>"
        else
            return "\<C-Y>"
        endif
    endif

    if !exists('b:_copilot.suggestions')
        return copilot#Suggest()
    else
        return copilot#Accept('')
    endif
endfunction

"===================================================================================================
" nvim-treesitter & nvim-treesitter-textobjects
lua << EOF
local ok, module = pcall(require, "nvim-treesitter.configs")
if not ok then
    return
end

module.setup {
    -- nvim-treesitter
    auto_install = false,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = false,
            scope_incremental = false,
            node_incremental = "<C-I>",
            node_decremental = "<C-O>",
        },
    },

    -- nvim-treesitter-textobjects
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["as"] = "@statement.outer",
                ["is"] = "@statement.outer",
            },
            selection_modes = "v",
            include_surrounding_whitespace = false,
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
                ["[a"] = "@parameter.inner",
                ["[f"] = "@function.outer",
                ["[s"] = "@statement.outer",
            },
            goto_next_start = {
                ["]a"] = "@parameter.inner",
                ["]f"] = "@function.outer",
                ["]s"] = "@statement.outer",
            },
            goto_previous_end = {
                ["[A"] = "@parameter.inner",
                ["[F"] = "@function.outer",
                ["[S"] = "@statement.outer",
            },
            goto_next_end = {
                ["]A"] = "@parameter.inner",
                ["]F"] = "@function.outer",
                ["]S"] = "@statement.outer",
            },
        },
    },
}
EOF

"===================================================================================================
" minuet-ai.nvim
lua << EOF
local ok, module = pcall(require, "minuet")
if not ok then
    return
end

local mc = require 'minuet.config'
module.setup {
    virtualtext = {
        auto_trigger_ft = {},
        keymap = {
            next = "<M-_>KB=A-[<M-\\>",
            dismiss = "<M-_>KB=A-S-[<M-\\>",
            accept = "<M-_>KB=A-]<M-\\>",
        },
    },

    provider = "openai_compatible",
    request_timeout = 5,
    n_completions = 1,
    provider_options = {
        openai_compatible = {
            name = "Openrouter",
            end_point = "https://openrouter.ai/api/v1/chat/completions",
            api_key = "OPENROUTER_API_KEY",
            model = "google/gemini-2.0-flash-001",
            optional = {
                max_tokens = 5000,
                top_p = 0.9,
                provider = {
                    sort = "throughput",
                },
                reasoning = {
                    effort = "none",
                },
            },

            -- Prefix-first style
            system = mc.default_system_prefix_first,
            chat_input = mc.default_chat_input_prefix_first,
            few_shots = mc.default_few_shots_prefix_first,
        },
    },
}
EOF
