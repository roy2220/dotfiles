let g:ToolInstallCommands = get(g:, 'ToolInstallCommands', []) + [
\    'npm install -g bash-language-server',
\    'go install mvdan.cc/sh/v3/cmd/shfmt@latest',
\]

augroup __sh__
    autocmd!

    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'sh',
    \    'cmd': {server_info->['bash-language-server', 'start']},
    \    'allowlist': ['sh'],
    \    'config': {'filter': {'name': 'none'}},
    \})

    autocmd FileType sh setlocal shiftwidth=8 softtabstop=8 noexpandtab
    autocmd FileType sh call s:on_sh_buf()
augroup END

function! s:on_sh_buf() abort
    augroup __sh_buf__
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> call s:shfmt()
    augroup END
endfunction

function! s:shfmt() abort
    let view = winsaveview()
    execute 'keepjumps %!shfmt 2>/dev/null || cat /dev/stdin'
    call winrestview(view)
endfunction
