if executable('pyright-langserver')
    let g:lsc_server_commands.python = {
    \   'command': 'pyright-langserver --stdio',
    \   'log_level': -1,
    \   'suppress_stderr': v:true,
    \}
endif

augroup __python__
    autocmd!
    autocmd FileType python setlocal shiftwidth=4 softtabstop=4 expandtab
    if executable('black')
        autocmd BufWritePre *.py call s:black()
    endif
    if executable('isort')
        autocmd BufWritePre *.py call s:isort()
    endif
augroup END

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
        execute 'keepjumps %!isort - 2>/dev/null || cat /dev/stdin'
        call winrestview(view)
    endfunction
endif
