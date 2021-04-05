if executable('bash-language-server')
    let g:lsc_server_commands.yaml = {
    \   'command': 'yaml-language-server --stdio',
    \   'log_level': -1,
    \   'suppress_stderr': v:true,
    \   'workspace_config': {
    \        'yaml': {
    \            'schemas': {
    \                'kubernetes': '*.k8s.yaml',
    \                'file://'.expand('<sfile>:p:h').'/yaml/schemas/compose-spec.json': ['docker-compose.yml', 'docker-compose.override.yml'],
    \            },
    \            'schemaStore': {
    \                'enable': v:false,
    \            },
    \        },
    \   },
    \}
endif

augroup __sh__
    autocmd!
    autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 expandtab
augroup END
