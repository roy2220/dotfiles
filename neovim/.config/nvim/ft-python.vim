let g:ToolInstallCommands = get(g:, 'ToolInstallCommands', []) + [
\    'npm install -g pyright',
\    'pip install black',
\    'pip install isort',
\    'pip install autoflake',
\]

augroup __python__
    autocmd!

    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'python',
    \    'cmd': {server_info->['pyright-langserver', '--stdio']},
    \    'allowlist': ['python'],
    \    'config': {'filter': {'name': 'none'}},
    \})

    autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
    autocmd FileType python call s:on_python_buf()
augroup END

function! s:on_python_buf() abort
    augroup __python_buf__
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> call s:black()
        autocmd BufWritePre <buffer> call s:isort()
    augroup END
endfunction

function! s:black() abort
    let view = winsaveview()
    silent execute 'keepjumps %!black - 2>/dev/null'
    call winrestview(view)
endfunction

function! s:isort() abort
    let view = winsaveview()
    execute 'keepjumps %!isort --profile=black - 2>/dev/null || cat /dev/stdin'
    call winrestview(view)
endfunction

command -nargs=0 Autoflake call s:autoflake()

function! s:autoflake() abort
    let view = winsaveview()
    silent execute 'keepjumps %!vim-autoflake --remove-all-unused-imports --remove-duplicate-keys --remove-unused-variables'
    call winrestview(view)
endfunction
