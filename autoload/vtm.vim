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

if exists('*jobstart')
    let g:job_cmd = 'jobstart'
elseif exists('*job_start')
    let g:job_cmd = 'job_start'
else
    let message = 'Job feature is required, please install lastest Neovim or Vim'
    call vtm#util#showMessage(message, 'error')
    finish
endif

" note: this must be outside the function!!!
let s:py_file = expand('<sfile>:p:h') . '/script/query.py'

function! vtm#Translate(args, type) abort
    " a:args: 'word' or 'word engine'

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

    let arg1 = substitute(a:args, '^\s*\(.\{-}\)\s*$', '\1', '')

    " `:Translate<CR>` == call vtm#Translate(expand("<cword>"), 'simple')
    " argument: ''
    if arg1 == ''
        let word = expand("<cword>")
        let engine = g:vtm_default_engine
    else
        let pos = match(arg1,' ')
        " `:Translate test<CR>` == call vtm#Translate('test', 'simple')
        " argument: 'test'
        if pos < 0
            let word = arg1
            let engine = g:vtm_default_engine
        " `:Translate youdao test<CR>` == call vtm#Translate('youdao test', 'simple')
        " argument: 'youdao test'
        else
            " split arg1 to get engine and word
            let engine = arg1[: pos-1]
            if index(['bing', 'ciba', 'google', 'youdao'], engine) < 0
                let engine = g:vtm_default_engine
                let word = arg1
            else
                let word = arg1[l:pos+1 :]
            endif
        endif
    endif

    let word = substitute(word, '[\n\|\r]\+', '. ', 'g')

    let cmd = s:vtm_python_host . ' ' . s:py_file
        \ . ' --text '      . shellescape(word)
        \ . ' --engine '    . engine
        \ . ' --toLang '    . g:vtm_default_to_lang
        \ . (len(g:vtm_proxy_url) > 0 ? (' --proxy ' . g:vtm_proxy_url) : '')

    call vtm#query#jobStart(cmd, a:type)
endfunction

function! vtm#TranslateV(type) abort
    let select_text = vtm#util#visualSelect()
    call vtm#Translate(select_text, a:type)
endfunction

function! vtm#Complete(arg_lead, cmd_line, cursor_pos) abort
    let engines = ['bing', 'ciba', 'google', 'youdao']
    let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
    let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
    call remove(args, 0)
    if len(args) == 1
        let candidates = engines
        let prefix = args[0]
        if !empty(prefix)
            let candidates = filter(engines, 'v:val[:len(prefix) - 1] == prefix')
        endif
        return sort(candidates)
    endif
endfunction
