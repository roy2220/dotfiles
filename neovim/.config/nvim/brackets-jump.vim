if !executable('ctags')
    finish
endif

function! s:additional_tag_info() abort
    let [tag, ok] = GetCurrentTag()
    if !ok
        return ''
    endif
    return ' <'..s:tag_info(tag)..'>'
endfunction
let g:ctrl_g_format ..= '%s'
let g:ctrl_g_args += [get(function('s:additional_tag_info'), 'name')..'()']

function! GetCurrentTag() abort
    let language = get(s:file_type_2_language, &filetype, '')
    if language == ''
        return ['', v:false]
    endif
    let cur_line = line('.')
    for tag in s:get_tags(language)
        if tag.line_start <= cur_line && tag.line_end >= cur_line
            return [tag, v:true]
        endif
    endfor
    return ['', v:false]
endfunction

augroup __bracketsjump__
    autocmd!
    autocmd BufEnter,BufWrite * call s:setup()
augroup END

let s:file_type_2_language = {}
let s:bufnr_2_cache = {}

function! s:setup() abort
    if &filetype == ''
        return
    endif
    if has_key(s:file_type_2_language, &filetype)
        return
    endif

    if !(&buftype == '' && bufname('%') != '')
        return
    endif
    let output = system('ctags --print-language '..shellescape(expand('%')))
    if v:shell_error != 0
        return
    endif

    let language = matchstr(output, ': \zs[^ ]\+\ze\n$')
    if language == 'NONE'
        let language = ''
    endif
    let s:file_type_2_language[&filetype] = language
    if language != ''
        call s:init(language)
        execute 'augroup __bracketsjump_'..&filetype..'__'
            autocmd!
            execute 'autocmd FileType '..&filetype..' call s:init('..string(language)..')'
        augroup END
    endif
endfunction

function! s:init(language) abort
    execute 'nnoremap <buffer> <silent> [[ :<C-U>call <SID>ll_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> [[ :<C-U>call <SID>ll_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> [[ :<C-U>call <SID>ll_jump(v:false, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> ]] :<C-U>call <SID>rr_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> ]] :<C-U>call <SID>rr_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> ]] :<C-U>call <SID>rr_jump(v:false, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> [] :<C-U>call <SID>lr_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> [] :<C-U>call <SID>lr_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> [] :<C-U>call <SID>lr_jump(v:false, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> ][ :<C-U>call <SID>rl_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> ][ :<C-U>call <SID>rl_jump(v:false, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> ][ :<C-U>call <SID>rl_jump(v:false, v:true, '..string(a:language)..', v:count)<CR>'

    execute 'nnoremap <buffer> <silent> [{ :<C-U>call <SID>ll_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> [{ :<C-U>call <SID>ll_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> [{ :<C-U>call <SID>ll_jump(v:true, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> ]} :<C-U>call <SID>rr_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> ]} :<C-U>call <SID>rr_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> ]} :<C-U>call <SID>rr_jump(v:true, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> [} :<C-U>call <SID>lr_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> [} :<C-U>call <SID>lr_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> [} :<C-U>call <SID>lr_jump(v:true, v:true, '..string(a:language)..', v:count)<CR>'
    execute 'nnoremap <buffer> <silent> ]{ :<C-U>call <SID>rl_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'onoremap <buffer> <silent> ]{ :<C-U>call <SID>rl_jump(v:true, v:false, '..string(a:language)..', v:count)<CR>'
    execute 'vnoremap <buffer> <silent> ]{ :<C-U>call <SID>rl_jump(v:true, v:true, '..string(a:language)..', v:count)<CR>'
endfunction

function! s:ll_jump(to_outer, visual_mode, language, num_times) abort
    call s:jump(a:to_outer, a:visual_mode, a:language, a:num_times, { tag -> tag.line_start }, { line1, line2 -> line1 < line2 })
endfunction

function! s:rr_jump(to_outer, visual_mode, language, num_times) abort
    call s:jump(a:to_outer, a:visual_mode, a:language, a:num_times, { tag -> tag.line_start }, { line1, line2 -> line1 > line2 })
endfunction

function! s:lr_jump(to_outer, visual_mode, language, num_times) abort
    call s:jump(a:to_outer, a:visual_mode, a:language, a:num_times, { tag -> tag.line_end }, { line1, line2 -> line1 < line2 })
endfunction

function! s:rl_jump(to_outer, visual_mode, language, num_times) abort
    call s:jump(a:to_outer, a:visual_mode, a:language, a:num_times, { tag -> tag.line_end }, { line1, line2 -> line1 > line2 })
endfunction

function! s:jump(to_outer, visual_mode, language, num_times, get_line, test_line) abort
    if a:visual_mode
        normal! gv
        let line1 = line("'<")
        let line2 = line("'>")
        if line1 == line('v')
            let cur_line = line2
        else
            let cur_line = line1
        endif
    else
        let cur_line = line('.')
    endif

    if a:to_outer
        let outer_scope_level = -1
        for tag in s:get_tags(a:language)
            if tag.line_start <= cur_line && tag.line_end >= cur_line
                let outer_scope_level = tag.scope_level - 1
                break
            endif
        endfor
        if outer_scope_level == -1
            return
        endif
    else
        let outer_scope_level = v:null
    endif

    let i = 0
    let n = a:num_times < 1 ? 1 : a:num_times
    let cur_tag = {}
    while i < n
        let tag = s:get_nearest_tag(a:language, cur_line, outer_scope_level, a:get_line, a:test_line)
        if tag == {}
            break
        endif
        let cur_tag = tag
        let cur_line = a:get_line(tag)
        if a:to_outer
            let outer_scope_level = tag.scope_level - 1
        endif
        let i += 1
    endwhile
    if cur_tag == {}
        return
    endif

    execute printf('normal! %dG0', cur_line)
    call search('\V\C\<'..(cur_tag.name)..'\>', 'c', cur_line)
    redraw | echo s:tag_info(cur_tag)
endfunction

function! s:get_nearest_tag(language, line, scope_level, get_line, test_line) abort
    if !(a:scope_level is v:null) && a:scope_level < 0
        return {}
    endif

    let nearest_tag = {}
    for tag in s:get_tags(a:language)
        if !(a:scope_level is v:null) && tag.scope_level != a:scope_level
            continue
        endif
        if !a:test_line(a:get_line(tag), a:line)
            continue
        endif
        if nearest_tag == {} || a:test_line(a:get_line(nearest_tag), a:get_line(tag))
            let nearest_tag = tag
        endif
    endfor
    return nearest_tag
endfunction

function! s:get_tags(language) abort
    let bufnr = bufnr()
    if has_key(s:bufnr_2_cache, bufnr)
        let cache = s:bufnr_2_cache[bufnr]
        let cache_hit = v:true
    else
        let cache = {}
        let s:bufnr_2_cache[bufnr] = cache
        let cache_hit = v:false
    endif
    let changed_tick = get(b:, 'changedtick', 0)
    if !cache_hit || cache.changed_tick != changed_tick
        let cache.tags = s:do_get_tags(a:language)
        let cache.changed_tick = changed_tick
    endif
    if cache_hit
        call timer_stop(cache.timer_id)
    endif
    let cache.timer_id = timer_start(30*1000, { timer_id -> s:purge_cache(timer_id, bufnr) })
    return cache.tags
endfunction

function! s:purge_cache(timer_id, bufnr) abort
    let cache = s:bufnr_2_cache[a:bufnr]
    if a:timer_id != cache.timer_id
        return
    endif
    call remove(s:bufnr_2_cache, a:bufnr)
endfunction

function! s:do_get_tags(language) abort
    let command_prefix = 'ctags --sort=no --language-force='..a:language..' -x --_xformat=''%N,%K,%n,%e,%s'' '
    let file_name = expand('%')
    if filereadable(file_name) && &modified == 0
        let results = systemlist(command_prefix.shellescape(file_name))
    else
        let temp_file_name = tempname()
        try
            call writefile(getline(1, '$'), temp_file_name)
            let results = systemlist(command_prefix.shellescape(temp_file_name))
        finally
            call delete(temp_file_name)
        endtry
    endif

    let tags = []
    for result in results
        let parts = split(result, ',', v:true)
        let name = parts[0]
        let kind = parts[1]
        let line_start = str2nr(parts[2])
        if parts[3] == ''
            continue
        endif
        let line_end = str2nr(parts[3])
        "if line_start == line_end
        "    continue
        "endif
        let scope_name = parts[4]
        let scope_level = len(split(scope_name, '\.', v:false))
        let tag = {
        \    'name': name,
        \    'kind': kind,
        \    'line_start': line_start,
        \    'line_end': line_end,
        \    'scope_name': scope_name,
        \    'scope_level': scope_level,
        \}
        call add(tags, tag)
    endfor
    call sort(tags, { x, y -> (x.line_end - x.line_start) - (y.line_end - y.line_start) })
    return tags
endfunction

function! s:tag_info(tag) abort
    let tag_info = a:tag.kind..' '
    if a:tag.scope_name != ''
        let tag_info ..= a:tag.scope_name..'.'
    endif
    let tag_info ..= a:tag.name
    return tag_info
endfunction
