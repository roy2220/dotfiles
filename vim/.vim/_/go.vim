if executable('gopls')
    let g:lsc_server_commands.go = {
    \   'command': 'gopls serve',
    \   'log_level': -1,
    \   'suppress_stderr': v:true,
    \}
endif

if executable('go')
    command -nargs=* GoRun call s:command('go run '.<q-args>, v:true)
    command -nargs=* GoBuild call s:command('go build '.<q-args>, v:true)
    command -nargs=* GoVet call s:command('go vet '.<q-args>, v:true)
    command -nargs=* GoTest call s:command('go test '.<q-args>, v:true)
    command -nargs=* GoTestFunc call s:go_test_func(<q-args>)

    function! s:command(command, keep_focus) abort
        let cur_winnr = winnr()
        let term_winnr = 0
        for winnr1 in range(1, winnr('$'))
            let bufnr1 = winbufnr(winnr1)
            let buf_type = getbufvar(bufnr1, '&buftype')
            if buf_type == 'terminal'
                let term_winnr = winnr1
                break
            endif
        endfor
        if term_winnr == 0
            let working_dir = expand('%:p:h')
            new
            execute 'lcd '.fnameescape(working_dir)
            let term_winnr = winnr()
        else
            if cur_winnr != term_winnr
                execute term_winnr.'wincmd w'
            endif
        endif
        call term_start(['bash', '-c', 'echo '.shellescape(expand('%:p:h').'> '.a:command).'; '.a:command],
        \    {'term_name': a:command, 'curwin': v:true})
        if term_winnr != cur_winnr && a:keep_focus
            execute cur_winnr.'wincmd w'
        endif
    endfunction

    function! s:go_test_func(q_args) abort
        let tag = GetCurrentTag()
        if tag == {}
            return ''
        endif
        if tag.kind !=# 'func'
            return ''
        endif
        if tag.name !~# '^\(Example\|Test\)'
            return ''
        endif
        call s:command('go test -run=^'.tag.name.'$ '.a:q_args, v:true)
    endfunction

    if executable('dlv')
        command -nargs=* DlvDebug call s:command('dlv debug '.<q-args>, v:false)
        command -nargs=* DlvTestFunc call s:dlv_test_func(<q-args>)

        function! s:dlv_test_func(q_args) abort
            let tag = GetCurrentTag()
            if tag == {}
                return ''
            endif
            if tag.kind !=# 'func'
                return ''
            endif
            if tag.name !~# '^\(Example\|Test\)'
                return ''
            endif
            call s:command('dlv test -- -test.run=^'.tag.name.'$ '.a:q_args, v:false)
        endfunction
    endif
endif

augroup __go__
    autocmd!
    autocmd FileType go setlocal shiftwidth=8 softtabstop=8 noexpandtab
    if executable('goimports')
        autocmd BufWritePre *.go call s:goimports()
    endif
augroup END

if executable('goimports')
    function! s:goimports() abort
        let view = winsaveview()
        execute 'keepjumps %!goimports 2>/dev/null || cat /dev/stdin'
        call winrestview(view)
    endfunction
endif
