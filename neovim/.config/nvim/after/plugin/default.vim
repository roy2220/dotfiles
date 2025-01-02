if &diff != 1
    augroup __gitgutter__
        autocmd!
        autocmd! gitgutter CursorHold,CursorHoldI
        autocmd BufWritePost * GitGutter
    augroup END
end
