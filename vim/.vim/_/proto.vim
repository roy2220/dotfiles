if executable('pyright-langserver')
    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'proto',
    \    'cmd': {server_info->['protobuf-language-server']},
    \    'allowlist': ['proto'],
    \    'config': {'filter': {'name': 'none'}},
    \})
endif
