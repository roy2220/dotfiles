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
代码片段B和片段A的代码结构应该相同, 但目前并不相同. 请严格参照片段A的代码结构, 对片段B进行清理、调整和补全, 最终输出和片段A结构一致的代码.
注意输出的代码, 对应的基本缩进也要和片段A一致.

>>>>> 开始: 代码片段A%s <<<<<
%s
>>>>> 结束: 代码片段A%s <<<<<

>>>>> 开始: 代码片段B%s <<<<<
%s
>>>>> 结束: 代码片段B%s <<<<<
END
    let query = printf(join(lines, "\n"), pl_hint, getreg('"'), pl_hint, pl_hint, a:input, pl_hint)
    return query
endfunction

function! s:chatgpt(query) abort
    let lines = systemlist('tee /tmp/ai_complete_query.txt | chatgpt -q --track-token-usage=false', a:query)
    if v:shell_error != 0
        throw 'Failed to execute: '..a:query
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
