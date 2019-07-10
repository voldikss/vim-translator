" @Author: voldikss
" @Date: 2019-06-20 20:10:08
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-30 21:35:47

if has('nvim')
    function! s:onStdoutNvim(type, jobid, data, event)
        call s:start(a:type, a:data, a:event)
    endfunction

    function! s:onExitNvim(jobid, code, event)
    endfunction
else
    function! s:onStdoutVim(type, event, ch, msg)
        call s:start(a:type, a:msg, a:event)
    endfunction

    function! s:onExitVim(ch, code)
    endfunction
endif

function! vtm#query#jobStart(cmd, type) abort
    if has('nvim')
        let callback = {
            \ 'on_stdout': function('s:onStdoutNvim', [a:type]),
            \ 'on_stderr': function('s:onStdoutNvim', [a:type]),
            \ 'on_exit': function('s:onExitNvim')
        \ }
        call jobstart(a:cmd, callback)
    else
        let callback = {
            \ 'out_cb': function('s:onStdoutVim', [a:type, 'stdout']),
            \ 'err_cb': function('s:onStdoutVim', [a:type, 'stderr']),
            \ 'exit_cb': function('s:onExitVim'),
            \ 'out_io': 'pipe',
            \ 'err_io': 'pipe',
            \ 'in_io': 'null',
            \ 'out_mode': 'nl',
            \ 'err_mode': 'nl',
            \ 'timeout': '2000'
        \ }
        call job_start(a:cmd, callback)
    endif
endfunction

function! s:start(type, data, event) abort
    " Since Nvim will return a v:t_list, while Vim will return a v:t_string
    if type(a:data) == 3
        let message = join(a:data, ' ')
    else
        let message = a:data
    endif

    " On Nvim, this function will be executed twice, firstly it returns data, and then an empty string
    " Check the data value in order to prevent overlap
    if message == ''
        return
    endif

    " python2 will return unicode object which is hard to solve in python
    " so solve it in vim
    " 1. remove `u` before strings
    let message = substitute(message, '\(: \|: [\|{\)\(u\)\("\)', '\=submatch(1).submatch(3)', 'g')
    let message = substitute(message, "\\(: \\|: [\\|{\\)\\(u\\)\\('\\)", '\=submatch(1).submatch(3)', 'g')
    let message = substitute(message, "\\([: \\|: \[]\\)\\(u\\)\\('\\)", '\=submatch(1).submatch(3)', 'g')
    " 2. convert unicode to normal chinese string
    let message = substitute(message, '\\u\(\x\{4\}\)', '\=nr2char("0x".submatch(1),1)', 'g')

    if a:event == 'stdout'
        let translations = eval(message)

        let has_trans = 0
        for t in translations
            for i in keys(t)
                if len(t[i]) && i != 'engine'
                    let has_trans = 1
                    break
                endif
            endfor
        endfor

        if has_trans
            if a:type == 'simple'
                call vtm#display#echo(translations)
            elseif a:type == 'complex'
                call vtm#display#window(translations)
            else
                call vtm#display#replace(translations)
            endif
            call vtm#util#saveHistory(translations)
        endif
    elseif a:event == 'stderr'
        call vtm#util#showMessage(message)
    endif
endfunction
