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
    let lines =<< trim END
理想情况下，代码片段B和代码片段A应当拥有相同结构和缩进，并且B是A的「完整版」。
但当前B的情况并不理想，请严格参照A的代码结构，对B进行清理、调整和补全，得到理想的B，然后输出其代码。
注意：请使用<code_c>和</code_c>标签标记框定输出的代码。

<code_a>
%s
</code_a>

<code_b>
%s
</code_b>
END
    let query = printf(join(lines, "\n"), getreg('"'), a:input)
    return query
endfunction

function! s:chatgpt(query) abort
    let output = system('tee /tmp/ai_complete.txt | xargs -- chatgpt -- | tee -a /tmp/ai_complete.txt', a:query)
    if v:shell_error != 0
        throw 'Failed to execute: '..a:query
    endif
    let i = stridx(output, '<code_c>')
    if i == -1
        throw 'Failed to locate code_c'
    endif
    let j = i + len('<code_c>')
    let k = stridx(output, '</code_c>', j)
    if k == -1
        throw 'Failed to locate code_c'
    endif
    return output[j:k-1]
endfunction
