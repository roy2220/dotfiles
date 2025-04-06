vnoremap <silent> <leader>p !:<C-U>call <SID>ai_complete()<CR>

function! s:ai_complete() abort
    normal! gv
    let input = GetVisualSelection()
    let query = s:make_query(input)
    let output = s:chatgpt(query)
    let vmode = visualmode()
    call setreg('"', output, vmode)
    normal! P
    call setreg('"', input, vmode)
endfunction

function! s:make_query(input) abort
    if &filetype ==# ''
        let pl_hint = ''
    else
        let pl_hint = printf(' (vim filetype=%s)', &filetype)
    endif
    let lines =<< trim END
代码片段B和代码片段A的结构应该相同, 但目前代码片段B还不完整, 请严格参照代码片段A, 对代码片段B进行补全, 然后完整输出补全后的代码.
注意输出的代码需要保留原始缩进.

>>>>> 开始: 代码片段A%s <<<<<
%s
>>>>> 结束: 代码片段A%s <<<<<

>>>>> 开始: 代码片段B%s <<<<<
%s
>>>>> 结束: 代码片段B%s <<<<<
END
    return printf(join(lines, "\n"), pl_hint, getreg('"'), pl_hint, pl_hint, a:input, pl_hint)
endfunction

function! s:chatgpt(query) abort
    let lines = systemlist('chatgpt -q --track-token-usage=false '..shellescape(a:query))
    if v:shell_error != 0
        throw 'Failed to execute: '..a:command
    endif
    if len(lines) == 0
        let lines = ['']
    else
        if lines[0][:2] ==# '```'
            let lines = lines[1:]
        endif
        if lines[-1] ==# ''
            let lines = lines[:-2]
        endif
        if lines[-1][:2] ==# '```'
            let lines = lines[:-2]
        endif
    endif
    let output = join(lines, "\n")
    return output
endfunction
