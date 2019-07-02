" @Author: voldikss
" @Date: 2019-06-20 19:45:42
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-20 19:45:42


function! vtm#util#showMessage(message, ...) abort
    if a:0 == 0
        let msgType = 'info'
    else
        let msgType = a:1
    endif

    if type(a:message) != 1
        let message = string(message)
    else
        let message = a:message
    endif

    if msgType == 'info'
        echohl String
    elseif msgType == 'warning'
        echohl WarningMsg
    elseif msgType == 'error'
        echohl ErrorMsg
    endif

    echomsg '[vim-translate-me] ' . a:message
    echohl None
endfunction

function! vtm#util#saveHistory(contents) abort
    if !g:vtm_enable_history
        return
    endif

    let query = a:contents['query']
    let paraphrase = a:contents['paraphrase']

    " if paraphrase == query or no paraphrase, it's an invalid translation. 
    " throw it away
    if query ==? paraphrase || !len(paraphrase)
        return
    endif

    if !filereadable(g:vtm_history_file)
        call writefile([], g:vtm_history_file)
    endif

    let item = PadEnd(query, 25). paraphrase
    let trans_data = readfile(g:vtm_history_file)

    " duplicated
    if index(trans_data, item) >= 0
        return
    endif

    " must be improved...
    if len(trans_data) == g:vtm_max_history_count
        call remove(trans_data, 0)
    endif

    let trans_data += [item]
    let result = writefile(trans_data, g:vtm_history_file)
    if result == -1
        let message = 'Failed to save the translation data.'
        call vtm#util#showMessage(message, 'warning')
    endif
endfunction

function! vtm#util#exportHistory() abort
    if !filereadable(g:vtm_history_file)
        let message = 'History file not exist yet'
        call vtm#util#showMessage(message, 'error')
        return
    endif

    execute 'tabnew ' .  g:vtm_history_file
    setlocal filetype=vtm_history
    syn match vtmHistoryQuery #\v^.*\v%25v#
    syn match vtmHistoryTrans #\v%26v.*$#
    hi def link vtmHistoryQuery Keyword
    hi def link vtmHistoryTrans String
endfunction

function! PadEnd(text, length) abort
    let text = a:text
    let len = len(text)
    if len < a:length
        for i in range(a:length-len)
            let text .= ' '
        endfor
    endif
    return text
endfunction

function! vtm#util#visualSelect() abort
    let reg_tmp = @a
    normal! gv"ay
    let select_text=@a
    let @a = reg_tmp
    unlet reg_tmp
    return select_text
endfunction

function! vtm#util#version()
    return '1.1.0'
endfunction

function! vtm#util#breakChangeNotify()
    let notice = 0
    let outdated_options = [
        \ 'g:vtm_preview_position',
        \ 'g:vtm_popup_window',
        \ 'g:vtm_youdao_app_key',
        \ 'g:vtm_youdao_app_secret',
        \ 'g:vtm_baidu_app_key',
        \ 'g:vtm_baidu_app_secret',
        \ 'g:vtm_bing_app_secret_key',
        \ 'g:vtm_yandex_app_secret_key'
        \ ]

    for o in outdated_options
        if exists(o)
            if !notice
                call vtm#util#showMessage('Break Change Notice(Sincerely): ', 'warning')
            endif
            let notice = 1
            let message = "Option '" . o . "' was deprecated"
            call vtm#util#showMessage(message, 'warning')
        endif
    endfor

    if exists('g:vtm_default_api')
        if !notice
            call vtm#util#showMessage('Break Change Notice(Sincerely): ', 'warning')
        endif
        let notice = 1
        let message = "Option 'g:vtm_default_api' has been changed to 'g:vtm_default_engine'"
        call vtm#util#showMessage(message, 'warning')

        let engines = ['bing', 'ciba', 'google', 'youdao']
        if index(engines, g:vtm_default_api) < 0
            let message = "API '" . g:vtm_default_api . "'" . ' was deprecated.'
            let message .= " Available engines: " . string(engines)
            call vtm#util#showMessage(message, 'warning')
        endif
    endif

    if notice
        let message = "Please refer to the lastest change log for more information:"
        call vtm#util#showMessage(message, 'warning')
        let message = "https://github.com/voldikss/vim-translate-me/tree/master#change-log"
        call vtm#util#showMessage(message, 'warning')
    endif
endfunction
