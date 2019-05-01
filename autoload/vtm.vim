" @Author: voldikss
" @Date: 2019-04-24 22:20:55
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 13:44:20

if executable('python3')
    let s:vtm_py_version = 'python3'
elseif executable('python')
    let s:vtm_py_version = 'python'
else
    echoerr '[vim-translate-me] Python is not installed, please install python3 first'
    finish
endif

if exists('*jobstart')
    let s:job_cmd = 'jobstart'
elseif exists('*job_start')
    let s:job_cmd = 'job_start'
else
    echoerr '[vim-translate-me] +job feature is required, please install lastest Neovim or Vim'
    finish
endif


" note: this must be outside the function!!!
let s:py_file_path = expand('<sfile>:p:h') . '/source/'

" bing api only requires app secret key
let s:api_key_secret = {
    \ 'baidu': [
        \ g:vtm_baidu_app_key,
        \ g:vtm_baidu_app_secret
    \ ],
    \ 'youdao': [
        \ g:vtm_youdao_app_key,
        \ g:vtm_youdao_app_secret
    \ ],
    \ 'bing': [
        \ 'null',
        \ g:vtm_bing_app_secret_key
    \ ]
    \ }

if g:vtm_default_to_lang == 'zh'
    let s:query_title = '查找：'
    let s:translation_title = '翻译：'
    let s:phonetic_title = '音标：'
    let s:explain_title = '解释：'
else
    let s:query_title = '@QUERY: '
    let s:translation_title = '@TRANS: '
    let s:phonetic_title = '@PHONETIC: '
    let s:explain_title = '@EXPLAIN: '
endif

" sample contents
" {
"   'data': {
"       'query': 'word',
"       'phonetic': 'phonetic',
"       'translation': 'translation1',
"       'explain': ['explain1', 'explain2']
"   }
" }

function! s:Popup(contents) abort
    let [width, height] = s:GetFloatingSize(a:contents)

    if g:vtm_popup_window == 'floating'
        let [row, col, corner] = s:GetFloatingPosition(width, height)
        let s:popup_win_id = nvim_open_win(
            \   bufnr('%'),
            \   v:true,
            \   {
            \      'relative': 'cursor',
            \      'anchor': corner,
            \      'row': row,
            \      'col': col,
            \      'width': width,
            \      'height': height,
            \   }
            \ )
    else
        let curr_pos = getpos('.')
        execute 'noswapfile ' . g:vtm_preview_position . ' pedit!'
        " cursor will be moved to the first line of the window
        " make cursor go back to the original position
        call setpos('.', curr_pos)
        wincmd P
        execute height . 'wincmd _'
        let s:popup_win_id = win_getid()
    endif

    call s:OnOpen(a:contents)
endfunction

function! s:OnOpen(contents) abort
    enew!

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal nomodified
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorline
    setlocal nowrap
    setlocal filetype=vtm
    nmap <silent> <buffer> q :close<CR>

    let query = s:query_title . a:contents['query']
    call setline(1, query)

    let translation = s:translation_title . a:contents['translation']
    call append(line('$'), translation)

    if has_key(a:contents, 'phonetic')
        let phonetic = s:phonetic_title . '[' . a:contents['phonetic'] . ']'
        call append(line('$'), phonetic)
    endif

    if has_key(a:contents, 'explain')
        call append(line('$'), s:explain_title)
        for i in a:contents['explain']
            let explain = '  ' . i
            call append(line('$'), explain)
        endfor
    endif

    setlocal nomodified
    setlocal nomodifiable

    " go to the original window
    wincmd p

    augroup VtmClosePopup
        autocmd CursorMoved,CursorMovedI,InsertEnter <buffer> call <SID>ClosePopup()
    augroup END
endfunction

function! s:GetFloatingSize(contents) abort
    let height = 0
    let width = 0
    for item in keys(a:contents)
        " query or phonetic or translation
        if item == 'query' || item == 'phonetic' || item == 'translation'
            let line_width = strdisplaywidth(a:contents[item])
            if line_width > width
                let width = line_width
            endif
            let height += 1
        " explain
        else
            for line in a:contents[item]
                let line_width = strdisplaywidth(line)
                if line_width > width
                    let width = line_width
                endif
                let height += 1
            endfor
            " `解释` takes one line
            let height += 1
        endif
    endfor

    " no reason about '8' here. I picked it as I like
    if g:vtm_default_to_lang == 'zh'
        let width += 8
    else
        let width += 10
    endif

    return [width, height]
endfunction

function! s:GetFloatingPosition(width, height) abort
    let bottom_line = line('w0') + winheight(0) - 1
    let curr_pos = getpos('.')
    if curr_pos[1] + a:height <= bottom_line
        let vert = 'N'
        let row = 1
    else
        let vert = 'S'
        let row = 0
    endif

    if curr_pos[2] + a:width <= &columns
        let hor = 'W'
        let col = 0
    else
        let hor = 'E'
        let col = 1
    endif

    return [row, col, vert . hor]
endfunction

function! s:IntoPopup() abort
    let popup_winnr = win_id2win(s:popup_win_id)
    if popup_winnr == 0
        return
    endif

    " if inside the popup window, then jump out
    if winnr() == popup_winnr
        execute 'wincmd p'
    else
        execute popup_winnr . 'wincmd w'
    endif
endfunction

function! s:ClosePopup() abort
    let popup_winnr = win_id2win(s:popup_win_id)
    if popup_winnr != 0
        execute popup_winnr . 'wincmd c'
    endif
    autocmd! VtmClosePopup * <buffer>
endfunction

function! s:Echo(contents) abort
    if has_key(a:contents, 'phonetic')
        let phonetic = ' [' . a:contents['phonetic'] . '] '
    else
        let phonetic = ''
    endif

    if has_key(a:contents, 'explain')
        let explain = join(get(a:contents, 'explain', []), ' ')
    else
        let explain = ''
    endif

    let translation = a:contents['query']
        \ . ' ==> '
        \ . a:contents['translation']
        \ . phonetic
        \ . explain

    echomsg translation
endfunction

function! s:GetVisualText() abort
    let reg_tmp = @a
    normal! gv"ay
    let select_text=@a
    let @a = reg_tmp
    unlet reg_tmp
    return select_text
endfunction

function! s:Replace(contents) abort
    let translation = a:contents['translation']
    let reg_tmp = @a
    let @a = translation
    normal! gv"ap
    let @a = reg_tmp
    unlet reg_tmp
endfunction

function! s:Start(type, data, event) abort
    " Since Nvim will return a v:t_list, while Vim will return a v:t_string
    if type(a:data) == 3
        let message = join(a:data, ' ')
    else
        let message = a:data
    endif

    " On Nvim, this function will be executed twice, firstly it returns data, and then an empty string
    " Check the data value in order to prevent overlap
    if message == ''
        let message = join(a:data, ' ')
        return
    endif

    " python2 will return unicode object which is hard to solve in python
    " so solve it in vim
    " 1. remove `u` before strings
    let message = substitute(message, '\(: \|: [\)\(u\)\("\)', '\=submatch(1).submatch(3)', 'g')
    let message = substitute(message, "\\([: \|: \[]\\)\\(u\\)\\('\\)", '\=submatch(1).submatch(3)', 'g')
    " 2. convert unicode to normal chinese string
    let message = substitute(message, '\\u\(\x\{4\}\)', '\=nr2char("0x".submatch(1),1)', 'g')

    if a:event == 'stdout'
        let contents = eval(message)
        if a:type == 'simple'
            call s:Echo(contents)
        elseif a:type == 'complex'
            call s:Popup(contents)
        else
            call s:Replace(contents)
        endif
    elseif a:event == 'stderr'
        echomsg '[vim-translate-me] ' . message
    endif
endfunction

function! s:Handler(...) abort
    if s:job_cmd == 'jobstart'
        " jobstart: (type, job_id, data, event)
        call s:Start(a:1, a:3, a:4)
    else
        " job_start: (type, event, channel, msg)
        call s:Start(a:1, a:4, a:2)
    endif
endfunction

function! s:JobStart(cmd, type) abort
    if s:job_cmd == 'jobstart'
        let callbacks = {
            \ 'on_stdout': function('s:Handler', [a:type]),
            \ 'on_stderr': function('s:Handler', [a:type])
        \ }
    else
        let callbacks = {
            \ 'out_cb': function('s:Handler', [a:type, 'stdout']),
            \ 'err_cb': function('s:Handler', [a:type, 'stderr']),
            \ 'out_io': 'pipe',
            \ 'err_io': 'out',
            \ 'in_io': 'null',
            \ 'out_mode': 'nl',
            \ 'err_mode': 'nl',
            \ 'timeout': '2000'
        \ }
    endif

    call function(s:job_cmd, [a:cmd, callbacks])()
endfunction

function! vtm#Translate(...) abort
    " if there is a popup window already && type == 'complex'
    if a:2 == 'complex' && exists('s:popup_win_id')
        let popup_winnr = win_id2win(s:popup_win_id)
        if popup_winnr != 0
            call s:IntoPopup()
            return
        endif
    endif

    " `:Translate<CR>` == call vtm#Translate(expand("<cword>"), 'simple')
    " argument: ''
    let arg1 = trim(a:1)
    if arg1 == ''
        let word = expand("<cword>")
        let api = g:vtm_default_api
    else
        let pos = match(arg1,' ')
        " `:Translate test<CR>` == call vtm#Translate('test', 'simple')
        " argument: 'test'
        if pos < 0
            let word = arg1
            let api = g:vtm_default_api
        " `:Translate youdao test<CR>` == call vtm#Translate('youdao test', 'simple')
        " argument: 'youdao test'
        else
            " split arg1 to get api and word
            let api = arg1[: pos-1]
            if index(['youdao', 'baidu', 'bing', 'yandex'], api) < 0
                let api = g:vtm_default_api
                let word = arg1
            else
                let word = arg1[l:pos+1 :]
            endif
        endif
    endif

    let type = a:2
    let py_file = s:py_file_path . api . '.py'

    let cmd = s:vtm_py_version . ' ' . py_file
        \ . ' --appKey '    . s:api_key_secret[api][0]
        \ . ' --appSecret ' . s:api_key_secret[api][1]
        \ . ' --word '      . shellescape(word)
        \ . ' --toLang '    . g:vtm_default_to_lang

    call s:JobStart(cmd, type)
endfunction

function! vtm#TranslateV(type) abort
    let select_text = s:GetVisualText()
    call vtm#Translate(select_text, a:type)
endfunction

function! vtm#Complete(arg_lead, cmd_line, cursor_pos)
    let apis = ['youdao', 'baidu', 'bing', 'yandex']
    let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
    let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
    call remove(args, 0)
    if len(args) == 1
        let candidates = apis
        let prefix = args[0]
        if !empty(prefix)
            let candidates = filter(apis, 'v:val[:len(prefix) - 1] == prefix')
        endif
        return sort(candidates)
    endif
endfunction
