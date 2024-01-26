if &diff != 1
    finish
endif

function! DirDiff(left_dir_path, right_dir_path) abort
    call chdir(a:left_dir_path)

    set diffopt-=horizontal
    set diffopt+=internal,filler,vertical,closeoff,hiddenoff,followwrap

    let cmd_tmpl = '
    \    git diff%s --src-prefix=/ --dst-prefix=/ --output-indicator-new=''~'' --output-indicator-old=''~'' %s %s
    \    | grep ''^[+-@]''
    \'
    let lines = systemlist(printf(cmd_tmpl, s:make_git_diff_opts(), shellescape(a:left_dir_path), shellescape(a:right_dir_path)))
    let i = 0
    let qf = []
    while i < len(lines)
        let left_file_path = lines[i][4:]
        let right_file_path = lines[i+1][4:]
        let i += 2

        if left_file_path ==# '/dev/null'
            let file_rel_path = right_file_path[len(a:right_dir_path)+1:]
            let left_file_path = a:left_dir_path.'/'.file_rel_path
        else
            let file_rel_path = left_file_path[len(a:left_dir_path)+1:]
            let right_file_path = a:right_dir_path.'/'.file_rel_path
        endif

        while i < len(lines)
            let line = lines[i]
            if stridx(line, '@@ ') != 0
                break
            endif
            let i += 1

            let lnum = -str2nr(line[3:])
            let j = stridx(line, ' @@ ', 3)
            if j < 0
                let text = ''
            else
                let text = line[j+4:]
            endif

            call add(qf, {
            \   'filename': file_rel_path,
            \   'lnum': lnum,
            \   'text': text,
            \   'user_data': right_file_path,
            \})
        endwhile
    endwhile

    call setqflist(qf, 'r')
    horizontal botright copen
    cfirst

    call s:rearrange_windows(bufnr())
endfunction

function! s:make_git_diff_opts() abort
    let opts = ' --no-index --unified=0'
    if &diffopt =~# 'iblank'
        let opts .=' --ignore-blank-lines'
    endif
    if &diffopt =~# 'iwhite'
        let opts .=' --ignore-space-change'
    endif
    if &diffopt =~# 'iwhiteall'
        let opts .=' --ignore-all-space'
    endif
    if &diffopt =~# 'iwhiteeol'
        let opts .=' --ignore-space-at-eol'
    endif
    if &diffopt =~# 'algorithm:myers'
        let opts .=' --diff-algorithm=myers'
    endif
    if &diffopt =~# 'algorithm:minimal'
        let opts .=' --diff-algorithm=minimal'
    endif
    if &diffopt =~# 'algorithm:patience'
        let opts .=' --diff-algorithm=patience'
    endif
    if &diffopt =~# 'algorithm:histogram'
        let opts .=' --diff-algorithm=histogram'
    endif
    return opts
endfunction

let s:left_bufnr = -2
let s:left_winid = -3
let s:right_bufnr = -2
let s:right_winid = -3

function! s:rearrange_windows(bufnr) abort
    try
        let win_infos = getwininfo(s:left_winid) + getwininfo(s:right_winid)
        if len(win_infos) == 2 && win_infos[0].bufnr == s:left_bufnr && win_infos[1].bufnr == s:right_bufnr
            return
        endif

        let qf_info = getqflist({'idx': 0, 'qfbufnr': 0, 'winid': 0, 'items': v:none})
        let qf_item_info = qf_info.items[qf_info.idx-1]
        let s:left_bufnr = qf_item_info.bufnr
        let left_winids = win_findbuf(s:left_bufnr)
        if len(left_winids) == 0
            execute printf('horizontal topleft buffer %d', s:left_bufnr)
            let s:left_winid = win_getid()
        else
            let s:left_winid = left_winids[-1]
            call win_gotoid(s:left_winid)
        endif
        setlocal readonly nomodifiable wrap colorcolumn=

        for win_info in getwininfo()
            if win_info.winid == qf_info.winid || win_info.winid == s:left_winid
                continue
            endif
            call win_execute(win_info.winid, 'close')
        endfor
        for buf_info in getbufinfo({'buflisted': 1})
            if buf_info.bufnr == qf_info.qfbufnr || buf_info.bufnr == s:left_bufnr
                continue
            endif
            silent execute printf('bdelete %d', buf_info.bufnr)
        endfor

        let right_file_path = qf_item_info.user_data
        silent execute printf('diffsplit %s', right_file_path)
        setlocal readonly nomodifiable wrap colorcolumn=
        let s:right_bufnr = bufnr()
        let s:right_winid = win_getid()

        call win_gotoid(s:left_winid)
        normal! zizz
    finally
        autocmd BufWinEnter * ++once call s:on_buf_win_enter()
    endtry
endfunction

function! s:on_buf_win_enter() abort
    call timer_start(0, {_ -> s:rearrange_windows(bufnr())})
endfunction
