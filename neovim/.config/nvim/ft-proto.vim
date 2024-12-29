let g:ToolInstallCommands = get(g:, 'ToolInstallCommands', []) + [
\    'go install github.com/lasorda/protobuf-language-server@latest',
\]

augroup __proto__
    autocmd!

    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'proto',
    \    'cmd': {server_info->['protobuf-language-server']},
    \    'allowlist': ['proto'],
    \    'config': {'filter': {'name': 'none'}},
    \})
augroup END
