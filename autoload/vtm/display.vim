" @Author: voldikss
" @Date: 2019-06-20 20:09:44
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-02 20:06:34


function! vtm#display#window(contents) abort
    let translation = s:buildTrans(a:contents)
    let [width, height] = s:winSize(translation)
    let [row, col, vert, hor] = s:winPos(width, height)

    if has('nvim') && exists('*nvim_win_set_config')
        let vtm_window_type = 'floating'
    elseif has('textprop')
        let vtm_window_type = 'popup'
    else
        let vtm_window_type = 'preview'
    endif

    if vtm_window_type == 'floating'
        let options = {
            \ 'relative': 'cursor',
            \ 'anchor': vert . hor,
            \ 'row': row,
            \ 'col': col,
            \ 'width': width,
            \ 'height': height,
            \ }
        call nvim_open_win(bufnr('%'), v:true, options)
        call s:onOpenFloating(translation)
    elseif vtm_window_type == 'popup'
        let vert = vert == 'N' ? 'top' : 'bot'
        let hor = hor == 'W' ? 'left' : 'right'
        let line = vert == 'top' ? 'cursor+1' : 'cursor-1'

        let options = {
            \ 'pos': vert . hor,
            \ 'line': line,
            \ 'col': 'cursor',
            \ 'moved': 'any',
            \ 'minwidth': width,
            \ 'minheight': height
            \ }
        let winid = popup_create('', options)
        call s:onOpenPopup(winid, translation)
    else
        let curr_pos = getpos('.')
        execute 'noswapfile bo pedit!'
        call setpos('.', curr_pos)
        wincmd P
        execute height+1 . 'wincmd _'
        call s:onOpenPreview(translation)
    endif
endfunction

function! s:buildTrans(contents)
    let query_marker = ' 🔍 '
    let paraphrase_marker = ' 🌀 '
    let phonetic_marker = ' 🔉 '
    let explain_marker = ' 📝 '

    let translation = []
    let query = query_marker . a:contents['query']
    call add(translation, query)

    if len(a:contents['paraphrase'])
        let paraphrase = paraphrase_marker . a:contents['paraphrase']
        call add(translation, paraphrase)
    elseif !len(a:contents['explain'])
        let paraphrase = paraphrase_marker . a:contents['query']
        call add(translation, paraphrase)
    endif

    if len(a:contents['phonetic'])
        let phonetic = phonetic_marker . '[' . a:contents['phonetic'] . ']'
        call add(translation, phonetic)
    endif

    if len(a:contents['explain'])
        for expl in a:contents['explain']
            let expl = trim(expl)
            if len(expl)
                let explain = explain_marker . expl
                call add(translation, explain)
            endif
        endfor
    endif

    return translation
endfunction

function! s:onOpenFloating(translation)
    enew!
    call append(0, a:translation)
    normal gg
    nmap <silent> <buffer> q :close<CR>

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal signcolumn=no
    setlocal filetype=vtm
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nocursorline
    setlocal nonumber
    setlocal norelativenumber
    " only available in nvim
    if has('nvim')
        setlocal winhighlight=Normal:vtmFloatingNormal
    endif

    wincmd p

    augroup VtmClosePopup
        autocmd!
        autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:closePopup()
    augroup END
endfunction

function! s:onOpenPopup(winid, translation)
    let bufnr = winbufnr(a:winid)
    for l in range(1, len(a:translation))
        call setbufline(bufnr, l, a:translation[l-1])
    endfor
    call setbufvar(bufnr, '&filetype', 'vtm')
endfunction

function! s:onOpenPreview(translation)
    call s:onOpenFloating(a:translation)
endfunction

function! s:winSize(translation) abort
    let height = 0
    let width = 0

    for line in a:translation
        let line_width = strdisplaywidth(line) + 1
        if line_width > width
            let width = line_width
        endif
        let height += 1
    endfor

    return [width, height]
endfunction

function! s:winPos(width, height) abort
    let bottom_line = line('w0') + winheight(0) - 1
    let curr_pos = getpos('.')
    let rownr = curr_pos[1]
    let colnr = curr_pos[2]
    " a long wrap line
    if colnr > &columns
        let colnr = colnr % &columns
        let rownr += colnr / &columns
    endif

    if rownr + a:height <= bottom_line
        let vert = 'N'
        let row = 1
    else
        let vert = 'S'
        let row = 0
    endif

    if colnr + a:width <= &columns
        let hor = 'W'
        let col = 0
    else
        let hor = 'E'
        let col = 1
    endif

    return [row, col, vert, hor]
endfunction

function! s:closePopup() abort
    for winnr in range(1, winnr('$'))
        if getbufvar(winbufnr(winnr), '&filetype') == 'vtm'
            execute winnr . 'wincmd c'
            autocmd! VtmClosePopup * <buffer>
            return
        endif
    endfor
endfunction

function! vtm#display#echo(contents) abort
    let translation = a:contents['query'] . ' ==> '

    if len(a:contents['phonetic'])
        let translation .= ' [' . a:contents['phonetic'] . '] '
    endif

    if len(a:contents['paraphrase'])
        let translation .= a:contents['paraphrase'] . '. '
    elseif !len(a:contents['explain'])
        let translation .= a:contents['query'] . '. '
    endif

    if len(a:contents['explain'])
        let translation .= join(get(a:contents, 'explain', []), ' ')
    endif

    call vtm#util#showMessage(translation)
endfunction

function! vtm#display#replace(contents) abort
    let paraphrase = a:contents['paraphrase']
    if !len(paraphrase)
        call vtm#util#showMessage('No paraphrases for the replacement', 'warning')
        return
    endif
    let reg_tmp = @a
    let @a = paraphrase
    normal! gv"ap
    let @a = reg_tmp
    unlet reg_tmp
endfunction
