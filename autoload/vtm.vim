" @Author: voldikss
" @Date: 2019-04-24 22:20:55
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-02 07:42:40


call vtm#util#breakChangeNotify()

if exists('g:python3_host_prog')
    let s:vtm_python_host = g:python3_host_prog
elseif executable('python3')
    let s:vtm_python_host = 'python3'
elseif executable('python')
    let s:vtm_python_host = 'python'
else
    let errMsg = 'Python is not installed, please install python3 first'
    call vtm#util#showMessage(errMsg, 'error')
    finish
endif

if !exists('*jobstart') && !exists('*job_start')
    let message = 'Job feature is required, please install lastest Neovim or Vim'
    call vtm#util#showMessage(message, 'error')
    finish
endif

" note: this must be outside the function!!!
let s:py_file = expand('<sfile>:p:h') . '/script/query.py'

function! vtm#Translate(args, type) abort
    " jump to popup or close popup
    if a:type == 'complex'
        if &filetype == 'vtm'
            wincmd c
            return
        else
            for winnr in range(1, winnr('$'))
                if getbufvar(winbufnr(winnr),'&filetype') == 'vtm'
                    noautocmd wincmd p
                    return
                endif
            endfor
        endif
    endif

    let args = substitute(a:args, '^\s*\(.\{-}\)\s*$', '\1', '')

    let argmap = {
        \ 'engines': [],
        \ 'word': '',
        \ 'lang': ''
        \ }
    let flag = ''
    for arg in split(args, ' ')
        if index(['-e', '--engines'], arg) >= 0
            let flag = 'engines'
        elseif index(['-w', '--word'], arg) >= 0
            let flag = 'word'
        elseif index(['-l', '--lang'], arg) >= 0
            let flag = 'lang'
        else
            if flag == 'word'
                let argmap[flag] .= ' ' . arg
            elseif flag == 'lang'
                let argmap[flag] = arg
            else
                call add(argmap[flag], arg)
            endif
        endif
    endfor

    if trim(argmap['word']) == ''
        let word = expand("<cword>")
    else
        let word = argmap['word']
    endif

    if argmap['engines'] == []
        let engines = g:vtm_default_engines
    else
        let engines = argmap['engines']
    endif

    if argmap['lang'] == ''
        let to_lang = g:vtm_default_to_lang
    else
        let to_lang = argmap['lang']
    endif

    let word = substitute(trim(word), '[\n\|\r]\+', '. ', 'g')

    let cmd = s:vtm_python_host . ' ' . s:py_file
        \ . ' --text '      . shellescape(word)
        \ . ' --engines '    . join(engines, ' ')
        \ . ' --toLang '    . to_lang
        \ . (len(g:vtm_proxy_url) > 0 ? (' --proxy ' . g:vtm_proxy_url) : '')

    call vtm#query#jobStart(cmd, a:type)
endfunction

function! vtm#TranslateV(type) abort
    let select_text = vtm#util#visualSelect()
    call vtm#Translate('-w ' . select_text, a:type)
endfunction

function! vtm#Complete(arg_lead, cmd_line, cursor_pos) abort
    let engines = ['bing', 'ciba', 'google', 'youdao']
    let args_prompt = ['-e', '--engines', '-w', '--word', '-l', '--lang']

    let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
    let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
    call remove(args, 0)

    if len(args) == 1
        if args[0] == ''
            return sort(args_prompt)
        else
            let prefix = args[-1]
            let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] == prefix')
            return sort(candidates)
        endif
    elseif len(args) > 1
        if args[-1] == ''
            if index(['-e', '--engines'], args[-2]) >= 0
                return sort(engines)
            elseif index(['-w', '--word'], args[-2]) >= 0
                return
            elseif index(['-l', '--lang'], args[-2]) >= 0
                return
            else
                return sort(engines + args_prompt)
            endif
        else
            let prefix = args[-1]
            let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] == prefix')
            return sort(candidates)
        endif
    endif
endfunction
