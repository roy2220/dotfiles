let g:FilesToHideInQuickfixByDefault = extendnew(get(g:, 'FilesToHideInQuickfixByDefault', {}), {
\    '*': ['\.bak$'],
\})

nnoremap <silent> <Esc>_#KB#A-Q<C-G> :call <SID>toggle_qf()<CR>
function! s:toggle_qf()
    let qf_winid = getqflist({'winid': 0}).winid
    if qf_winid == 0
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
    nnoremap <buffer> <silent> H :call <SID>toggle_hidden_errors()<CR>
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
    let MatchError = { _, error -> match(
    \    a:match_file_name ? get(error, 'filename', expand('#'..error.bufnr..':.')) : error.text,
    \    (a:pattern_is_fixed ? '\V' : '').a:pattern
    \) >= 0 }
    call UpdateQuickfix({ qf -> filter(qf, MatchError) })
endfunction

function! s:drop_errors(pattern, match_file_name, pattern_is_fixed) abort
    let MatchError = { _, error -> match(
    \    a:match_file_name ? get(error, 'filename', expand('#'..error.bufnr..':.')) : error.text,
    \    (a:pattern_is_fixed ? '\V' : '').a:pattern
    \) < 0 }
    call UpdateQuickfix({  qf -> filter(qf, MatchError)  })
endfunction

function! s:toggle_hidden_errors() abort
    let qf_info = getqflist({'context': 0})
    let context = qf_info.context
    let number_of_hidden_errors = empty(context) ? 0 : get(context, '__qf__number_of_hidden_errors', 0)
    if number_of_hidden_errors == 0
        return
    endif
    if number_of_hidden_errors > 0
        normal! zR
    else
        normal! zM
    endif
    let context.__qf__number_of_hidden_errors = -number_of_hidden_errors
    let context.__qf__visible_size += number_of_hidden_errors
    call setqflist([], 'a', qf_info)
endfunction

function! ShowQuickfix(qf) abort
    if len(a:qf) == 0
        echohl Error | redraw | echo 'No entries' | echohl NONE
        return
    endif
    let [qf_info, cur_pos_on_error] = s:add_qf(a:qf)
    let last_winid = win_getid()
    silent horizontal botright copen
    call s:refold_hidden_errors(qf_info)
    call win_gotoid(last_winid)
    if !cur_pos_on_error
        normal \e
    endif
endfunction

function! s:add_qf(qf) abort
    let [qf, cur_pos_on_error, number_of_hidden_errors] = s:sort_errors(a:qf)
    let qf_info = {'items': qf, 'context': ''}
    if number_of_hidden_errors >= 1
        let qf_info.context = {
        \    '__qf__number_of_hidden_errors': number_of_hidden_errors,
        \    '__qf__visible_size': len(qf) - number_of_hidden_errors,
        \}
    endif
    call s:save_last_accessed_quickfix_id()
    call setqflist([], ' ', qf_info)
    return [qf_info, cur_pos_on_error]
endfunction

function! s:sort_errors(qf) abort
    let [cur_lnum, cur_col] = getcurpos()[1:2]
    let cur_file_path = expand('%:p')
    let cur_bufnr = bufnr()
    let files_to_hide = get(g:, 'FilesToHideInQuickfixByDefault', {})
    let hidden_file_path_patterns = get(files_to_hide, '*', []) + get(files_to_hide, &filetype, [])
    if len(hidden_file_path_patterns) == 0
        let omni_hidden_file_path_pattern = ''
    else
        let omni_hidden_file_path_pattern = '\('..join(hidden_file_path_patterns, '\|')..'\)'
    endif
    let i = -1
    let n = len(a:qf)
    let error_scores = range(n)
    let cur_pos_on_error = v:false
    let number_of_hidden_errors = 0
    for error in a:qf
        let i += 1
        if has_key(error, 'filename')
            let file_path =fnamemodify(error.filename, ':p')
            if error.lnum == cur_lnum && error.col == cur_col && file_path ==# cur_file_path
                let error_scores[i] = i - n
                let cur_pos_on_error = v:true
                continue
            endif
        elseif has_key(error, 'bufnr')
            if error.lnum == cur_lnum && error.col == cur_col && error.bufnr == cur_bufnr
                let error_scores[i] = i - n
                let cur_pos_on_error = v:true
                continue
            endif
            let file_path = expand('#'..error.bufnr..':p')
        else
            continue
        endif
        if empty(omni_hidden_file_path_pattern) || match(file_path, omni_hidden_file_path_pattern) < 0
            continue
        endif
        let error_scores[i] = i + n
        let error.user_data = 1 " mark as hidden
        let number_of_hidden_errors += 1
    endfor
    if !cur_pos_on_error && number_of_hidden_errors == 0
        return [a:qf, v:false, 0]
    endif
    let error_indexes = range(n)
    call sort(error_indexes, { i1, i2 -> error_scores[i1] - error_scores[i2] })
    let qf = mapnew(error_indexes, { _, i -> a:qf[i] })
    return [qf, cur_pos_on_error, number_of_hidden_errors]
endfunction

function! UpdateQuickfix(qf_modifier) abort
    let qf_info = getqflist({'items': 0, 'context': 0})
    let qf_info.items = call(a:qf_modifier, [qf_info.items])
    let context = qf_info.context
    let number_of_hidden_errors = empty(context) ? 0 : get(context, '__qf__number_of_hidden_errors', 0)
    if number_of_hidden_errors != 0
        let sign = number_of_hidden_errors / abs(number_of_hidden_errors)
        let number_of_hidden_errors = sign * reduce(qf_info.items, { acc, val -> acc + get(val, 'user_data', 0) }, 0)
        if number_of_hidden_errors == 0
            call remove(context, '__qf__number_of_hidden_errors')
            call remove(context, '__qf__visible_size')
        else
            let context.__qf__number_of_hidden_errors = number_of_hidden_errors
            let context.__qf__visible_size = len(qf_info.items)
            if number_of_hidden_errors > 0
                let context.__qf__visible_size -= number_of_hidden_errors
            endif
        endif
    endif
    call setqflist([], 'r', qf_info)
    let last_winid = win_getid()
    silent horizontal botright copen
    call s:refold_hidden_errors(qf_info)
    call win_gotoid(last_winid)
endfunction

function! SwitchToQuickfix(qfnr) abort
    call s:save_last_accessed_quickfix_id()
    silent execute 'chistory'..a:qfnr
    let last_winid = win_getid()
    silent horizontal botright copen
    let qf_info = getqflist({'context': 0, 'size': 0})
    call s:refold_hidden_errors(qf_info)
    call win_gotoid(last_winid)
    if GetQuickfixVisibleSize(qf_info) >= 1
        silent cc
    endif
endfunction

let s:last_accessed_qfid = 0

function! s:save_last_accessed_quickfix_id() abort
    let s:last_accessed_qfid = getqflist({'id': 0}).id
endfunction

function! GetLastAccessedQfnr() abort
    return s:last_accessed_qfid
endfunction

function! GetQuickfixVisibleSize(qf_info) abort
    return empty(a:qf_info.context) ? a:qf_info.size : get(a:qf_info.context, '__qf__visible_size', a:qf_info.size)
endfunction

function! s:refold_hidden_errors(qf_info) abort
    normal! zE
    let context = a:qf_info.context
    let number_of_hidden_errors = empty(context) ? 0 : get(context, '__qf__number_of_hidden_errors', 0)
    if number_of_hidden_errors == 0
        return
    endif
    setlocal foldminlines=0
    let qf_size = line('$')
    execute (qf_size - abs(number_of_hidden_errors) + 1)..',$fold'
    if number_of_hidden_errors < 0
        normal! zR
    endif
endfunction
