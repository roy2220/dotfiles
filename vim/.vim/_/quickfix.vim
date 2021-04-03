nnoremap <silent> <F10> :call <SID>toggle_qf()<CR>
function! s:toggle_qf()
    let winid = getqflist({'winid': 0}).winid
    if winid == 0
        copen
    else
        cclose
    endif
endfunction

augroup __qf__
    autocmd!
    command! -nargs=1 -bang Qkeep call s:qf_keep(<f-args>, v:false, !v:true)
    command! -nargs=1 -bang Qkick call s:qf_kick(<f-args>, v:false, !v:true)
    command! -nargs=1 -bang Qkeepf call s:qf_keep(<f-args>, v:true, !v:true)
    command! -nargs=1 -bang Qkickf call s:qf_kick(<f-args>, v:true, !v:true)
augroup END

function! s:qf_keep(pattern, match_file_name, pattern_is_fixed) abort
    let MatchError = {_, error -> match(
    \    a:match_file_name ? expand('#'.error.bufnr.':.') : error.text,
    \    (a:pattern_is_fixed ? '\V' : '').a:pattern
    \) >= 0}
    call setqflist(filter(getqflist(), MatchError), 'r')
endfunction

function! s:qf_kick(pattern, match_file_name, pattern_is_fixed) abort
    let MatchError = {_, error -> match(
    \    a:match_file_name ? expand('#'.error.bufnr.':.') : error.text,
    \    (a:pattern_is_fixed ? '\V' : '').a:pattern
    \) < 0}
    call setqflist(filter(getqflist(), MatchError), 'r')
endfunction

function! ShowQuickfix(qf) abort
    if len(a:qf) == 0
        echohl Error | redraw | echo 'No entries' | echohl NONE
        return
    endif
    let cur_pos_on_error = s:add_qf(a:qf)
    copen
    wincmd p
    if !cur_pos_on_error
        normal \e
    endif
endfunction

function! s:add_qf(qf) abort
    let buffer_no = bufnr()
    let file_name = expand('%:p')
    let [line, column] = getcurpos()[1:2]
    let i = 0
    let qf = a:qf
    let cur_pos_on_error = v:false
    while i < len(qf)
        let error = qf[i]
        if error.lnum == line && error.col == column &&
        \    (get(error, 'bufnr', 0) == buffer_no || fnamemodify(error.filename, ':p') ==# file_name)
            if i >= 1
                let qf = qf[i:] + qf[:i-1]
            endif
            let cur_pos_on_error = v:true
            break
        endif
        let i += 1
    endwhile
    call SaveLastAccessedQuickfixID()
    call setqflist(qf)
    return cur_pos_on_error
endfunction
