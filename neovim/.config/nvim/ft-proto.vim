let g:ToolInstallCommands = extendnew(get(g:, 'ToolInstallCommands', []), [
\    'CGO_ENABLED=0 go install github.com/lasorda/protobuf-language-server@latest',
\])

let g:RequiredTreeSitterParsers = extendnew(get(g:, 'RequiredTreeSitterParsers', []), [
\    'proto',
\])

augroup __proto__
    autocmd!

    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'proto',
    \    'cmd': {server_info->['protobuf-language-server', '-stdio', '-logs', '/dev/null']},
    \    'allowlist': ['proto'],
    \    'config': {'filter': {'name': 'none'}},
    \})
augroup END
