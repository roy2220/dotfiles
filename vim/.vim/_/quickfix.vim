nnoremap <silent> <Esc>@q :call <SID>toggle_qf()<CR>
function! s:toggle_qf()
    let winid = getqflist({'winid': 0}).winid
    if winid == 0
        horizontal botright copen
    else
        cclose
    endif
endfunction

augroup __qf__
    autocmd!
    autocmd FileType qf call s:init()
augroup END

function! s:init() abort
    nnoremap <buffer> <silent> K :call <SID>operate_errors('n', 'k')<CR>
    vnoremap <buffer> <silent> K :<C-U>call <SID>operate_errors('v', 'k')<CR>
    nnoremap <buffer> <silent> D :call <SID>operate_errors('n', 'd')<CR>
    vnoremap <buffer> <silent> D :<C-U>call <SID>operate_errors('v', 'd')<CR>
    command! -buffer -nargs=1 -bang Keep call s:keep_errors(<f-args>, v:false, !v:true)
    command! -buffer -nargs=1 -bang Keepf call s:keep_errors(<f-args>, v:true, !v:true)
    command! -buffer -nargs=1 -bang Drop call s:drop_errors(<f-args>, v:false, !v:true)
    command! -buffer -nargs=1 -bang Dropf call s:drop_errors(<f-args>, v:true, !v:true)
endfunction

function! s:operate_errors(mode, op) abort
    if a:mode ==# 'n'
        let pattern = expand('<cword>')
        let i = getcurpos()[2] - 1
    else
        let pattern = GetVisualSelection()
        let i = getpos("'<")[2] - 1
    endif
    let j = match(getline('.'), '|\d\+\( col \d\+\)\?|')
    let match_file_name = i < j
    if a:op ==# 'k'
        call s:keep_errors(pattern, match_file_name, v:true)
    else
        call s:drop_errors(pattern, match_file_name, v:true)
    endif
endfunction

function! s:keep_errors(pattern, match_file_name, pattern_is_fixed) abort
    let MatchError = {_, error -> match(
    \    a:match_file_name ? expand('#'.error.bufnr.':.') : error.text,
    \    (a:pattern_is_fixed ? '\V' : '').a:pattern
    \) >= 0}
    call setqflist(filter(getqflist(), MatchError), 'r')
endfunction

function! s:drop_errors(pattern, match_file_name, pattern_is_fixed) abort
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
    silent horizontal botright copen
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
