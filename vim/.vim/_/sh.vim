if executable('bash-language-server')
    let g:lsc_server_commands.sh = {
    \   'command': 'bash-language-server start',
    \   'log_level': -1,
    \   'suppress_stderr': v:true,
    \}
endif

augroup __sh__
    autocmd!
    autocmd FileType sh setlocal shiftwidth=8 softtabstop=8 noexpandtab
    if executable('shfmt')
        autocmd BufWritePre *.sh,*.bash call s:shfmt()
    endif
augroup END

if executable('shfmt')
    function! s:shfmt() abort
        let view = winsaveview()
        execute 'keepjumps %!shfmt 2>/dev/null || cat /dev/stdin'
        call winrestview(view)
    endfunction
endif

vnoremap <silent> \\b :<C-U>call <SID>bash()<CR>
func! s:bash() abort
    let script = GetVisualSelection()
    let output = system("bash -euxo pipefail -", script)
    vnew
    set buftype=nofile
    0put =output
endfunction
