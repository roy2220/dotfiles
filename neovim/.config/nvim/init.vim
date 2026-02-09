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
        Plug 'milanglacier/minuet-ai.nvim', { 'do': 'git apply ~/.config/nvim/plugin-patches/minuet-ai.nvim.diff' } | Plug 'nvim-lua/plenary.nvim'
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
let g:lsp_signature_help_enabled = 0
let g:lsp_document_highlight_delay = 0
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
    inoremap <buffer> <M-_>KB=A-G<M-\>h <C-O>:LspSignatureHelp<CR>
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
" nvim-treesitter & nvim-treesitter-textobjects
lua << EOF
local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then
    return
end

configs.setup {
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
local ok, minuet = pcall(require, "minuet")
if not ok then
    return
end

local config = require("minuet.config")
minuet.setup {
    provider = "openai_compatible",
    request_timeout = 5,
    n_completions = 1,
    provider_options = {
        openai_compatible = {
            name = "Openrouter",
            end_point = "https://openrouter.ai/api/v1/chat/completions",
            api_key = "OPENROUTER_API_KEY",
            model = "google/gemini-2.5-flash",
            optional = {
                max_tokens = 512,
                top_p = 0.9,
                provider = {
                    sort = "throughput",
                },
                reasoning = {
                    effort = "none",
                },
            },

            -- Prefix-first style
            system = {
                template = [[
# 你的角色

你是一个极度严谨的代码补全引擎，擅长推断用户意图，帮助用户补全代码片段。


# 用户引言

当我们说某个事物“是什么”，通常会找一个宽泛的概念，将事物囊括进来，例如：狗是哺乳动物。
反之描述“不是什么”， 我们会找一个锚点，然后强调它的差异性，比如：狗不是狼，它已被驯服。
相较于“是什么”，“不是什么”的信息密度更大，也更具象——“是什么”描绘轮廓，“不是什么”雕琢细节。

在处理工作任务之前，我们脑海里只是清楚要干的活“是什么”。随后在执行过程中，随着细节深入，
我们才逐渐感知到理想和现实的摩擦，一系列需要动态决策的点开始浮现，我们被迫明确它“不是什么”。
最终在反复打磨后，我们才得到高质量的工作成果。“是什么”决定木桶的高度，“不是什么”决定木桶的短板。

近似的，我们让AI干活之前，只能告诉它“要什么”，却很难说清楚“不要什么”。因为“不要什么”是执行过程中，
一系列动态决策的结果。由于自身没有参与执行，信息量不足，我们难以察觉这些隐性决策空间的存在，
这便默认成了AI自由发挥的空间，这是个巨大的隐患。


# 用户输入

用户会向你提供正在编辑中的文件——其中的局部代码片段。

具体格式：代码上文<<<CURSOR>>>代码下文


# 你的行为准则

- 补全<<<CURSOR>>>处最可能的代码。

- 如果你在上下文找到*置信度大于90%*的线索，依据线索补全完整的代码。

- 如果你没有在上下文找到*置信度大于90%*的线索，或者你察觉到这里存在隐性决策空间，禁止补全代码，
  而是将你的问题、困惑以*代码注释*的形式补全在光标处，随后用户会在注释中与你进一步讨论。

  生成代码注释的规格：
    - 使用中文。
    - 控制注释行的长度，必要时进行换行。
    - 如果给用户提供了选项，给每个选项附上唯一标识。
    - 在且仅在第一行注释署名“AI: ”。
    - 在且仅在最后一行注释署名“USER: ”留白，示意用户答复。

- 生成的代码、注释，要严格遵循上下文的缩进，禁止包含上下文已有的代码。

- 直接输出<<<CURSOR>>>处的代码、注释本身。
]],
            },
            chat_input = {
                template = [[
{{{code_outline}}}
{{{language}}}
{{{tab}}}

{{{context_before_cursor}}}<<<CURSOR>>>{{{context_after_cursor}}}
]],
                code_outline = function()
                    local commentstring = vim.bo.commentstring
                    if commentstring == nil or commentstring == "" then
                        commentstring = "# %s"
                    end
                    local lines = vim.fn.systemlist({
                        vim.fn.stdpath("config").."/scripts/extract-code-outline",
                        vim.fn.expand("%:p"),
                        "     ",
                    })
                    if #lines == 0 then
                        return "code outline: none"
                    end
                    for i, line in ipairs(lines) do
                        lines[i] = string.format(commentstring, line)
                    end
                    lines[1] = string.format(commentstring, "code outline:\n")..lines[1]
                    return table.concat(lines, "\n")
                end,
                language = config.default_chat_input_prefix_first.language,
                tab = config.default_chat_input_prefix_first.tab,
                context_before_cursor = config.default_chat_input_prefix_first.context_before_cursor,
                context_after_cursor = config.default_chat_input_prefix_first.context_after_cursor,
            },
            few_shots = {}
        },
    },

    virtualtext = {
        auto_trigger_ft = {},
        keymap = {
            accept = "<M-_>KB=A-]<M-\\>",
            accept_line = "<M-_>KB=A-S-]<M-\\>",
        },
    },
}

local action = require("minuet.virtualtext").action
vim.keymap.set(
    "i",
    "<M-_>KB=A-[<M-\\>",
    function()
        if action.is_visible then
            action.dismiss()
        end
        return action.next()
    end,
    {
        desc = "[minuet.virtualtext] next suggestion",
        silent = true,
    }
)
EOF
