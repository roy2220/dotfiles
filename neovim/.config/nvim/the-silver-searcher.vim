if !executable('ag')
    finish
endif

command! -nargs=1 -bang Ag call s:ag(<bang>v:false, <f-args>, v:true)|set hlsearch
command! -nargs=1 -bang Agp call s:ag(<bang>v:false, <f-args>, v:false)|set hlsearch

command! -nargs=0 AgConflicts call s:ag('^(<{7,9} .+|\|{7,9} .+|={7,9}|>{7,9} .+)$', v:false)|set hlsearch

function! s:ag(invert_match, pattern, pattern_is_fixed) abort
    let command = 'ag --vimgrep '
    if &ignorecase
        if &smartcase
            let command ..= '--smart-case '
        else
            let command ..= '--ignore-case '
        endif
    else
        let command ..= '--case-sensitive '
    endif
    if a:pattern_is_fixed
        let command ..= '--fixed-strings '
    endif
    if a:invert_match
        let command ..= '--files-without-matches '
    endif
    let command ..= '-- '..shellescape(a:pattern)
    if &buftype == 'quickfix'
        let qf_info = getqflist({'items': 0})
        let file_names = []
        for qf_item_info in qf_info.items
            let file_name = bufname(qf_item_info.bufnr)
            if file_name ==# ""
                continue
            endif
            call add(file_names, file_name)
        endfor
        if len(file_names) == 0
            let qf = []
        else
            let results = systemlist('xargs --delimiter=\\n -- '..command, join(file_names, "\n"))
            if v:shell_error != 0
                if len(results) >= 1
                    echoerr join(results, "\n")
                    return
                endif
            endif
            if a:invert_match
                let i = 0
                for qf_item_info in qf_info.items
                    let file_name = bufname(qf_item_info.bufnr)
                    if file_name ==# ''
                        continue
                    endif
                    if index(results, file_name) >= 0
                        let qf_info.items[i] = qf_item_info
                        let i += 1
                    endif
                endfor
                if i == 0
                    let qf = []
                else
                    let qf = qf_info.items[:i-1]
                endif
            else
                let qf = map(results, { _, result -> s:ag_result_to_error(result, v:false) })
            endif
        endif
    else
        let results = systemlist(command)
        if v:shell_error != 0
            if len(results) >= 1
                echoerr join(results, "\n")
                return
            endif
        endif
        let qf = map(results, { _, result -> s:ag_result_to_error(result, a:invert_match) })
    endif
    call ShowQuickfix(qf)
    if a:pattern_is_fixed
        let escaped_pattern = '\V'..substitute(escape(a:pattern, '/\'), "\n", '\\n', 'g')
    else
        let escaped_pattern = E2v(a:pattern)
    endif
    let @/ = escaped_pattern
endfunction

function! s:ag_result_to_error(result, invert_match) abort
    if a:invert_match
        return {
        \    'filename': a:result,
        \    'lnum': 1,
        \    'col': 1,
        \    'text': ''
        \}
    else
        let parts = split(a:result, ':')
        return {
        \    'filename': parts[0],
        \    'lnum': parts[1],
        \    'col': parts[2],
        \    'text': join(parts[3:], ':')
        \}
    endif
endfunction

nnoremap <silent> ga :let g:_ = 'Ag '..expand('<cword>')
    \\|execute g:_
    \\|call histadd('cmd', g:_)
    \\|unlet g:_
    \\|set hlsearch<CR>

nnoremap <silent> gA :let g:_ = 'Ag! '..expand('<cword>')
    \\|execute g:_
    \\|call histadd('cmd', g:_)
    \\|unlet g:_
    \\|set hlsearch<CR>

vnoremap <silent> ga :<C-U>let g:_ = 'Ag '..GetVisualSelection()
    \\|execute g:_
    \\|call histadd('cmd', g:_)
    \\|unlet g:_
    \\|set hlsearch<CR>

vnoremap <silent> gA :<C-U>let g:_ = 'Ag! '..GetVisualSelection()
    \\|execute g:_
    \\|call histadd('cmd', g:_)
    \\|unlet g:_
    \\|set hlsearch<CR>
