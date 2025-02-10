let g:ToolInstallCommands = extendnew(get(g:, 'ToolInstallCommands', []), [
\    'CGO_ENABLED=0 go install golang.org/x/tools/gopls@latest',
\    'CGO_ENABLED=0 go install golang.org/x/tools/cmd/goimports@master',
\    'CGO_ENABLED=0 go install github.com/go-delve/delve/cmd/dlv@latest',
\])

let g:FilesToHideInQuickfixByDefault = extendnew(get(g:, 'FilesToHideInQuickfixByDefault', {}), {
\    'go': ['_test\.go$'],
\})

augroup __go__
    autocmd!

    autocmd User lsp_setup call lsp#register_server({
    \    'name': 'go',
    \    'cmd': {server_info->['gopls', 'serve']},
    \    'allowlist': ['go', 'gomod'],
    \    'config': {'filter': {'name': 'none'}},
    \    'initialization_options': {
    \        'linksInHover': v:false,
    \    },
    \})

    autocmd FileType go call s:on_go_buf()
augroup END

function! s:on_go_buf() abort
    augroup __go_buf__
        autocmd! * <buffer>
        autocmd BufWritePre <buffer> call s:goimports()
    augroup END

    setlocal shiftwidth=8 softtabstop=8 noexpandtab
    inoremap <buffer> <expr> <c-x>i <SID>complete_import()
endfunction

function! s:goimports() abort
    let view = winsaveview()
    execute 'keepjumps %!goimports -srcdir '..shellescape(expand('%:p:h'))..' 2>/dev/null || cat /dev/stdin'
    call winrestview(view)
endfunction

let s:list_go_imports_cmd = expand('<sfile>:p:h')..'/scripts/list-go-imports'

function! s:complete_import() abort
    return fzf#vim#complete(s:list_go_imports_cmd)
endfunction

command -nargs=* GoRun call s:command('go run '..<q-args>, v:true)
command -nargs=* GoBuild call s:command('go build '..<q-args>, v:true)
command -nargs=* GoVet call s:command('go vet '..<q-args>, v:true)
command -nargs=* GoTest call s:command('go test '..<q-args>, v:true)
command -nargs=* GoTestFile call s:command('go test '..<q-args>..' '..shellescape(expand('%:p')), v:true)
command -nargs=* GoTestFunc call s:go_test_func(<q-args>)
command -nargs=* DlvDebug call s:command('dlv debug '..<q-args>, v:false)
command -nargs=* DlvTestFunc call s:dlv_test_func(<q-args>)
cabbrev Gtf GoTestFunc
cabbrev Dtf DlvTestFunc

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
        execute 'lcd '..fnameescape(working_dir)
        let term_winnr = winnr()
    else
        if cur_winnr != term_winnr
            execute term_winnr..'wincmd w'
        endif
    endif
    setlocal shell=sh
    execute 'terminal exec '..a:command
    if term_winnr != cur_winnr && a:keep_focus
        execute cur_winnr..'wincmd w'
    endif
endfunction

function! s:go_test_func(q_args) abort
    let test_func_name = s:get_test_func_name()
    if test_func_name == ''
        echohl Error | redraw | echo 'Not in test function' | echohl NONE
        return
    endif
    if test_func_name[:len('Benchmark')-1] ==# 'Benchmark'
        call s:command('go test -run=^$ -bench=^'..test_func_name..'$ '..a:q_args, v:true)
    else
        call s:command('go test -run=^'..test_func_name..'$ '..a:q_args, v:true)
    endif
endfunction

function! s:dlv_test_func(q_args) abort
    let test_func_name = s:get_test_func_name()
    if test_func_name == ''
        echohl Error | redraw | echo 'Not in test function' | echohl NONE
        return
    endif
    if test_func_name[:len('Benchmark')-1] ==# 'Benchmark'
        call s:command('dlv test -- -test.run=^$ -test.bench=^'..test_func_name..'$ '..a:q_args, v:false)
    else
        call s:command('dlv test -- -test.run=^'..test_func_name..'$ '..a:q_args, v:false)
    endif
endfunction

function! s:get_test_func_name() abort
    let [tag, ok] = GetCurrentTag()
    if !ok
        return ''
    endif
    if tag.kind !=# 'func'
        return ''
    endif
    if tag.name !~# '^\(Example\|Test\|Benchmark\)'
        return ''
    endif
    return tag.name
endfunction
