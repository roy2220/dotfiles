if !executable('ag')
    finish
endif

command! -nargs=1 -bang Ag call s:ag(<f-args>, <bang>v:true)|set hlsearch

command! -nargs=0 AgConflicts call s:ag('^(<<<<<<< .+|=======|>>>>>>> .+)$', v:false)|set hlsearch

function! s:ag(pattern, pattern_is_fixed) abort
    let command = 'ag --hidden --column '
    if &ignorecase
        if &smartcase
            let command .= '--smart-case '
        else
            let command .= '--ignore-case '
        endif
    else
        let command .= '--case-sensitive '
    endif
    if a:pattern_is_fixed
        let command .= '--fixed-strings '
    endif
    let command .= '-- ' . shellescape(a:pattern)
    let result = systemlist(command)
    if v:shell_error != 0
        if len(result) >= 1
            echoerr join(result, "\n")
            return
        endif
    endif
    let qf = map(result, 's:ag_result_to_quickfix(v:val)')
    call ShowQuickfix(qf)
    if a:pattern_is_fixed
        let escaped_pattern = '\V'.substitute(escape(a:pattern, '/\'), "\n", '\\n', 'g')
    else
        let escaped_pattern = E2v(a:pattern)
    endif
    let @/ = escaped_pattern
endfunction

function! s:ag_result_to_quickfix(result) abort
    let parts = split(a:result, ':')
    return {
\       'filename': parts[0],
\       'lnum': parts[1],
\       'col': parts[2],
\       'text': join(parts[3:], ':')
\   }
endfunction

nnoremap <silent> ga :let g:tmp = 'Ag '.expand('<cword>')
    \\|execute g:tmp
    \\|call histadd('cmd', g:tmp)
    \\|unlet g:tmp
    \\|set hlsearch<CR>

vnoremap <silent> ga :<C-U>let g:tmp = 'Ag '.GetVisualSelection()
    \\|execute g:tmp
    \\|call histadd('cmd', g:tmp)
    \\|unlet g:tmp
    \\|set hlsearch<CR>
