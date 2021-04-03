nnoremap <silent> \b :<C-U>call <SID>go_to_buffer(v:count, v:false)<CR>
nnoremap <silent> \B :<C-U>call <SID>go_to_buffer(v:count, v:true)<CR>
nnoremap <silent> [b :<C-U>call <SID>go_to_previous_buffer(v:count)<CR>
nnoremap <silent> ]b :<C-U>call <SID>go_to_next_buffer(v:count)<CR>
nnoremap <silent> [B :call <SID>go_to_first_buffer()<CR>
nnoremap <silent> ]B :call <SID>go_to_last_buffer()<CR>
nnoremap <silent> <BS>b :<C-U>call <SID>delete_buffer(v:count)<CR>
nnoremap <silent> <BS>B :<C-U>call <SID>delete_other_buffers(v:count)<CR>

nnoremap <silent> \w :<C-U>call <SID>go_to_window(v:count)<CR>
nnoremap <silent> [w :<C-U>call <SID>go_to_previous_window(v:count)<CR>
nnoremap <silent> ]w :<C-U>call <SID>go_to_next_window(v:count)<CR>
nnoremap <silent> [W :call <SID>go_to_first_window()<CR>
nnoremap <silent> ]W :call <SID>go_to_last_window()<CR>
nnoremap <silent> <BS>w :<C-U>call <SID>close_window(v:count)<CR>
nnoremap <silent> <BS>W :<C-U>call <SID>close_other_windows(v:count)<CR>

nnoremap <silent> \q :<C-U>call <SID>go_to_qf(v:count)<CR>
nnoremap <silent> [q :<C-U>call <SID>go_to_previous_qf(v:count)<CR>
nnoremap <silent> ]q :<C-U>call <SID>go_to_next_qf(v:count)<CR>
nnoremap <silent> [Q :call <SID>go_to_first_qf()<CR>
nnoremap <silent> ]Q :call <SID>go_to_last_qf()<CR>

nnoremap <silent> \e :<C-U>call <SID>go_to_error(v:count, v:false)<CR>
nnoremap <silent> \E :<C-U>call <SID>go_to_error(v:count, v:true)<CR>
nnoremap <silent> [e :<C-U>call <SID>go_to_previous_error(v:count)<CR>
nnoremap <silent> ]e :<C-U>call <SID>go_to_next_error(v:count)<CR>
nnoremap <silent> [E :call <SID>go_to_first_error()<CR>
nnoremap <silent> ]E :call <SID>go_to_last_error()<CR>
nnoremap <silent> <BS>e :<C-U>call <SID>remove_error(v:count)<CR>
nnoremap <silent> <BS>E :<C-U>call <SID>remove_other_errors(v:count)<CR>

function! s:go_to_buffer(pseudo_bufnr, new_window) abort
    if a:pseudo_bufnr < 1
        let bufnr1 = bufnr('#')
        if bufnr1 == -1 || bufnr1 == bufnr()
            return
        endif
        if !buflisted(bufnr1)
            return
        endif
    else
        let bufnrs = s:listed_bufnrs()
        if a:pseudo_bufnr > len(bufnrs)
            return
        endif
        let bufnr1 = bufnrs[a:pseudo_bufnr-1]
    endif
    if a:new_window
        vnew
    end
    execute 'buffer'.bufnr1
endfunction

function! s:go_to_previous_buffer(num_times) abort
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    execute num_times.'bprevious'
endfunction

function! s:go_to_next_buffer(num_times) abort
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    execute num_times.'bnext'
endfunction

function! s:go_to_first_buffer() abort
    bfirst
endfunction

function! s:go_to_last_buffer() abort
    blast
endfunction

function! s:delete_buffer(pseudo_bufnr) abort
    if a:pseudo_bufnr < 1
        bdelete
        return
    endif
    let bufnrs = s:listed_bufnrs()
    if a:pseudo_bufnr > len(bufnrs)
        return
    endif
    let bufnr1 = bufnrs[a:pseudo_bufnr-1]
    execute 'bdelete'.bufnr1
endfunction

function! s:delete_other_buffers(pseudo_bufnr) abort
    let bufnrs = s:listed_bufnrs()

    if a:pseudo_bufnr < 1
        let bufnr1 = bufnr()
    else
        if a:pseudo_bufnr > len(bufnrs)
            return
        endif
        let bufnr1 = bufnrs[a:pseudo_bufnr-1]
    endif
    for other_bufnr in bufnrs
        if other_bufnr == bufnr1
            continue
        endif
        execute 'bdelete'.other_bufnr
    endfor
endfunction

function! s:go_to_window(winnr) abort
    if a:winnr < 1
        let winnr1 = winnr('#')
        if winnr1 == 0
            return
        endif
    else
        let num_windows = winnr('$')
        if a:winnr > num_windows
            return
        endif
        let winnr1 = a:winnr
    endif
    execute winnr1.'wincmd w'
endfunction

function! s:go_to_previous_window(num_times) abort
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let num_windows = winnr('$')
    let winnr1 = (winnr() - num_times - num_windows) % num_windows + num_windows
    execute winnr1.'wincmd w'
endfunction

function! s:go_to_next_window(num_times) abort
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let num_windows = winnr('$')
    let winnr1 = (winnr() + num_times - 1) % num_windows + 1
    execute winnr1.'wincmd w'
endfunction

function! s:go_to_first_window() abort
    1wincmd w
endfunction

function! s:go_to_last_window() abort
    $wincmd w
endfunction

function! s:close_window(winnr) abort
    if a:winnr < 1
        wincmd q
    endif
    let num_windows = winnr('$')
    if a:winnr > num_windows
        return
    endif
    execute a:winnr.'wincmd q'
endfunction

function! s:close_other_windows(winnr) abort
    if a:winnr < 1
        wincmd o
    endif
    let num_windows = winnr('$')
    if a:winnr > num_windows
        return
    endif
    execute a:winnr.'wincmd o'
endfunction

function! s:go_to_qf(qfnr) abort
    let num_qfs = s:qfnr('$')
    if num_qfs == 0
        return
    endif
    if a:qfnr < 1
        let qfnr = s:last_accessed_qfnr()
        if qfnr == 0
            return
        endif
    else
        if a:qfnr > num_qfs
            return
        endif
        let qfnr = a:qfnr
    endif
    call SaveLastAccessedQuickfixID()
    silent execute 'chistory'.qfnr
    call s:go_to_current_error()
    call s:show_qf_numbers(qfnr, num_qfs, v:false)
endfunction

function! s:go_to_previous_qf(num_times) abort
    let num_qfs = s:qfnr('$')
    if num_qfs == 0
        return
    endif
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let qfnr = s:qfnr()
    let prev_qfnr = (qfnr - num_times - num_qfs) % num_qfs + num_qfs
    call SaveLastAccessedQuickfixID()
    silent execute 'chistory'.prev_qfnr
    call s:go_to_current_error()
    call s:show_qf_numbers(prev_qfnr, num_qfs, prev_qfnr > qfnr)
endfunction

function! s:go_to_next_qf(num_times) abort
    let num_qfs = s:qfnr('$')
    if num_qfs == 0
        return
    endif
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let qfnr = s:qfnr()
    let next_qfnr = (qfnr + num_times - 1) % num_qfs + 1
    call SaveLastAccessedQuickfixID()
    silent execute 'chistory'.next_qfnr
    call s:go_to_current_error()
    call s:show_qf_numbers(next_qfnr, num_qfs, next_qfnr < qfnr)
endfunction

function! s:go_to_first_qf() abort
    let num_qfs = s:qfnr('$')
    if num_qfs == 0
        return
    endif
    call SaveLastAccessedQuickfixID()
    silent chistory 1
    call s:go_to_current_error()
    call s:show_qf_numbers(1, num_qfs, v:false)
endfunction

function! s:go_to_last_qf() abort
    let num_qfs = s:qfnr('$')
    if num_qfs == 0
        return
    endif
    call SaveLastAccessedQuickfixID()
    silent execute 'chistory'.num_qfs
    call s:go_to_current_error()
    call s:show_qf_numbers(num_qfs, num_qfs, v:false)
endfunction

function! s:go_to_error(errnr, new_window) abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    if a:errnr < 1
        let errnr = s:errnr()
    else
        if a:errnr > num_errors
            return
        endif
        let errnr = a:errnr
    endif
    if a:new_window
        vnew
    end
    silent execute 'cc'.errnr
    normal! zz
    call s:show_error_numbers(errnr, num_errors, v:false)
endfunction

function! s:go_to_previous_error(num_times) abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let errnr = s:errnr()
    let prev_errnr = (errnr - num_times - num_errors) % num_errors + num_errors
    silent execute 'cc'.prev_errnr
    normal! zz
    call s:show_error_numbers(prev_errnr, num_errors, prev_errnr > errnr)
endfunction

function! s:go_to_next_error(num_times) abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    let num_times = a:num_times
    if num_times < 1
        let num_times = 1
    endif
    let errnr = s:errnr()
    let next_errnr = (errnr + num_times - 1) % num_errors + 1
    silent execute 'cc'.next_errnr
    normal! zz
    call s:show_error_numbers(next_errnr, num_errors, next_errnr < errnr)
endfunction

function! s:go_to_first_error() abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    silent cfirst
    normal! zz
    call s:show_error_numbers(1, num_errors, v:false)
endfunction

function! s:go_to_last_error() abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    silent clast
    normal! zz
    call s:show_error_numbers(num_errors, num_errors, v:false)
endfunction

function! s:remove_error(errnr) abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    if a:errnr < 1
        let errnr = s:errnr()
    else
        if a:errnr > num_errors
            return
        endif
        let errnr = a:errnr
    endif
    let qf = getqflist()
    if errnr == 1
        let qf = qf[errnr:]
    else
        let qf = qf[:errnr-2] + qf[errnr:]
    endif
    call setqflist(qf, 'r')
    let num_errors -= 1
    if num_errors == 0
        return
    endif
    if errnr > num_errors
        let errnr = num_errors
    endif
    silent execute 'cc'.errnr
    normal! zz
    call s:show_error_numbers(errnr, num_errors, v:false)
endfunction

function! s:remove_other_errors(errnr) abort
    let num_errors = s:errnr('$')
    if num_errors == 0
        return
    endif
    if a:errnr < 1
        let errnr = s:errnr()
    else
        if a:errnr > num_errors
            return
        endif
        let errnr = a:errnr
    endif
    let qf = getqflist()
    let qf = [qf[errnr - 1]]
    call setqflist(qf, 'r')
    silent cc1
    normal! zz
    call s:show_error_numbers(1, 1, v:false)
endfunction

function! s:listed_bufnrs() abort
    return map(getbufinfo({'buflisted': 1}), 'v:val.bufnr')
endfunction

function! s:qfnr(...) abort
    if a:0 == 0
        let x = 0
    else
        let x = a:1
    endif
    let qfnr = getqflist({'nr': x}).nr
    return qfnr
endfunction

let s:last_accessed_qfid = 0

function! s:last_accessed_qfnr()
    if s:last_accessed_qfid == 0
        return 0
    endif
    return getqflist({'id': s:last_accessed_qfid, 'nr': 0}).nr
endfunction

function! SaveLastAccessedQuickfixID()
    let s:last_accessed_qfid = getqflist({'id': 0}).id
endfunction

function! s:show_qf_numbers(qfnr, num_qfs, warn) abort
    let qf_numbers = printf('Quickfix list (%d/%d)', a:qfnr, a:num_qfs)
    if a:warn
        echohl WarningMsg | redraw | echo qf_numbers | echohl NONE
    else
        redraw | echo qf_numbers
    endif
endfunction

function! s:go_to_current_error() abort
    if s:errnr('$') == 0
        return
    endif
    silent cc
    normal! zz
endfunction

function! s:errnr(...) abort
    if a:0 == 0
        let errnr = getqflist({'idx': 0}).idx
        return errnr
    endif
    if a:1 == '$'
        let errnr = getqflist({'size': 0}).size
        return errnr
    endif
    return 0
endfunction

function! s:show_error_numbers(errnr, num_errors, warn) abort
    let error_numbers = printf('Error (%d/%d)', a:errnr, a:num_errors)
    if a:warn
        echohl WarningMsg | redraw | echo error_numbers | echohl NONE
    else
        redraw | echo error_numbers
    endif
endfunction
