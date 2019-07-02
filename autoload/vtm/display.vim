" @Author: voldikss
" @Date: 2019-06-20 20:09:44
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-01 08:13:04

let s:query_marker = ' 🔍 '
let s:paraphrase_marker = ' 🌀 '
let s:phonetic_marker = ' 🔉 '
let s:explain_marker = ' 📝 '

function! vtm#display#popup(contents) abort
    let [width, height] = s:floatingSize(a:contents)

    if has('nvim') && exists('*nvim_win_set_config')
        let vtm_popup_window = 'floating'
    else
        let vtm_popup_window = 'preview'
    endif

    if vtm_popup_window == 'floating'
        let [row, col, corner] = s:floatingPosition(width, height)
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
        execute 'noswapfile bo pedit!'
        " cursor will be moved to the first line of the window
        " make cursor go back to the original position
        call setpos('.', curr_pos)
        wincmd P
        execute height . 'wincmd _'
        let s:popup_win_id = win_getid()
    endif

    call s:onOpen(a:contents)
endfunction

function! s:onOpen(contents) abort
    enew!

    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal signcolumn=no
    setlocal filetype=vtm
    setlocal nomodified
    setlocal nobuflisted
    setlocal noswapfile
    setlocal nonumber
    setlocal norelativenumber
    setlocal nocursorline
    setlocal nowrap
    nmap <silent> <buffer> q :close<CR>

    let query = s:query_marker . a:contents['query']
    call setline(1, query)

    if len(a:contents['paraphrase'])
        let paraphrase = s:paraphrase_marker . a:contents['paraphrase']
        call append(line('$'), paraphrase)
    elseif !len(a:contents['explain'])
        let paraphrase = s:paraphrase_marker . a:contents['query']
        call append(line('$'), paraphrase)
    endif

    if len(a:contents['phonetic'])
        let phonetic = s:phonetic_marker . '[' . a:contents['phonetic'] . ']'
        call append(line('$'), phonetic)
    endif

    if len(a:contents['explain'])
        for expl in a:contents['explain']
            let expl = trim(expl)
            if len(expl)
                let explain = s:explain_marker . expl
                call append(line('$'), explain)
            endif
        endfor
    endif

    setlocal nomodified
    setlocal nomodifiable

    " set the background and foreground color of the popup window
    " only available in nvim
    if has('nvim')
        setlocal winhighlight=Normal:vtmPopupNormal
    endif

    wincmd p

    augroup VtmClosePopup
        autocmd!
        autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:closePopup()
    augroup END
endfunction

function! s:floatingSize(contents) abort
    let height = 0
    let width = 0

    for item in keys(a:contents)
        if index(['query', 'phonetic'], item) >= 0
            if len(a:contents[item])
                " 5: marker(4) + right margin(1)
                let line_width = strdisplaywidth(a:contents[item]) + 5
                let height += 1
            endif
        elseif item == 'paraphrase'
            if len(a:contents['paraphrase'])
                let line_width = strdisplaywidth(a:contents['paraphrase']) + 5
                let height += 1
            elseif !len(a:contents['explain'])
                let height += 1
            endif
        else
            for line in a:contents[item]
                let line = trim(line)
                if len(line)
                    let line_width = strdisplaywidth(line) + 5
                    if line_width > width | let width = line_width | endif
                    let height += 1
                endif
            endfor
        endif

        if line_width > width
            let width = line_width
        endif
    endfor

    return [width, height]
endfunction

function! s:floatingPosition(width, height) abort
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

    return [row, col, vert . hor]
endfunction

function! s:closePopup() abort
    let popup_winnr = win_id2win(s:popup_win_id)
    if popup_winnr
        execute popup_winnr . 'wincmd c'
        autocmd! VtmClosePopup * <buffer>
    endif
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
