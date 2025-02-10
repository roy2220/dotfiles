if !exists('$TMUX')
    finish
endif

augroup __tmuxclipboard__
    autocmd!
    autocmd TextYankPost * call s:sync_clipboard_to_tmux(v:event)
    autocmd FocusGained * call s:sync_clipboard_from_tmux()
augroup END

function! s:sync_clipboard_to_tmux(event) abort
    if !(v:event.regname == '' && v:event.operator ==# 'y')
        return
    endif
    let data = a:event.regcontents
    if a:event.regtype ==# 'V'
        let data = data + ['']
    endif
    call timer_start(0, { _ -> systemlist('tmux load-buffer -', data) })
endfunction

function! s:sync_clipboard_from_tmux() abort
    let data = system('tmux show-buffer')
    call setreg('"', data)
endfunction
