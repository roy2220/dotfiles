if executable('pyright-langserver')
    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'python',
    \    'cmd': {server_info->['pyright-langserver', '--stdio']},
    \    'allowlist': ['python'],
    \    'config': {'filter': {'name': 'none'}},
    \})
endif

if executable('vim-autoflake')
    command -nargs=0 Autoflake call s:autoflake()
endif

if executable('vim-autoflake')
    function! s:autoflake() abort
        let view = winsaveview()
        silent execute 'keepjumps %!vim-autoflake --remove-all-unused-imports --remove-duplicate-keys --remove-unused-variables'
        call winrestview(view)
    endfunction
endif

augroup __python__
    autocmd!
    autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
    autocmd FileType python call s:on_python_buf()
augroup END

function! s:on_python_buf() abort
    augroup __python_buf__
        autocmd! * <buffer>
        if executable('black')
            autocmd BufWritePre <buffer> call s:black()
        endif
        if executable('isort')
            autocmd BufWritePre <buffer> call s:isort()
        endif
    augroup END
endfunction

if executable('black')
    function! s:black() abort
        let view = winsaveview()
        silent execute 'keepjumps %!black - 2>/dev/null'
        call winrestview(view)
    endfunction
endif

if executable('isort')
    function! s:isort() abort
        let view = winsaveview()
        execute 'keepjumps %!isort --profile=black - 2>/dev/null || cat /dev/stdin'
        call winrestview(view)
    endfunction
endif
