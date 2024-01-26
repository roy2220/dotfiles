if executable('bash-language-server')
    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'sh',
    \    'cmd': {server_info->['bash-language-server', 'start']},
    \    'allowlist': ['sh'],
    \    'config': {'filter': {'name': 'none'}},
    \})
endif

augroup __sh__
    autocmd!
    autocmd FileType sh setlocal shiftwidth=8 softtabstop=8 noexpandtab
    autocmd FileType sh call s:on_sh_buf()
augroup END

function! s:on_sh_buf() abort
    augroup __sh_buf__
        autocmd! * <buffer>
        if executable('shfmt')
            autocmd BufWritePre <buffer> call s:shfmt()
        endif
    augroup END
endfunction

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
