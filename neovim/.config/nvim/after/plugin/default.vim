if &diff != 1
    if exists('#gitgutter')
        augroup __gitgutter__
            autocmd!
            autocmd! gitgutter CursorHold,CursorHoldI
            autocmd BufWritePost * GitGutter
        augroup END
    endif
end
