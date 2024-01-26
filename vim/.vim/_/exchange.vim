nnoremap <silent> ! :call <SID>exchange_n(input('!'))<CR>
vnoremap <silent> ! :<C-U>call <SID>exchange_v(input('!'))<CR>

function! s:exchange_n(command) abort
    let lines = getline(1, '$')
    let lines[-1] ..= "\n"
    let input = join(lines, "\n")
    let output = s:systemx(a:command, input)
    call setreg('"', output, 'V')
    normal! 1GV$GP
    call setreg('"', input, 'V')
endfunction

function! s:exchange_v(command) abort
    normal! gv
    let input = GetVisualSelection()
    let output = s:systemx(a:command, input)
    let vmode = visualmode()
    call setreg('"', output, vmode)
    normal! P
    call setreg('"', input, vmode)
endfunction

function! s:systemx(command, input) abort
    let lines = systemlist(a:command, a:input)
    if v:shell_error != 0
        throw 'Failed to execute: '..a:command
    endif
    if len(lines) == 0
        let lines = ['']
    endif
    if a:input[len(a:input) - 1] ==# "\n"
        let lines[-1] ..= "\n"
    endif
    let output = join(lines, "\n")
    return output
endfunction
