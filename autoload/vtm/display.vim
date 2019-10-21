" @Author: voldikss
" @Date: 2019-06-20 20:09:44
" @Last Modified by: voldikss
" @Last Modified time: 2019-08-01 07:44:58


function! vtm#display#window(translations) abort
  let content = s:buildContent(a:translations)
  let [width, height] = s:winSize(content, g:vtm_popup_max_width, g:vtm_popup_max_height)
  let [row, col, vert, hor] = s:winPos(width, height)

  for i in range(len(content))
    let line = content[i]
    if match(line, '---') == 0 && width > len(line)
      let content[i] = vtm#util#pad(content[i], width, '-')
    elseif match(line, '@') == 0 && width > len(line)
      let content[i] = vtm#util#pad(content[i], width, ' ')
    endif
  endfor

  if has('nvim') && exists('*nvim_win_set_config')
    let vtm_window_type = 'floating'
  elseif has('textprop')
    let vtm_window_type = 'popup'
  else
    let vtm_window_type = 'preview'
  endif

  if vtm_window_type == 'floating'
    " `width + 2`? ==> set foldcolumn=1
    let options = {
      \ 'relative': 'cursor',
      \ 'anchor': vert . hor,
      \ 'row': row,
      \ 'col': col,
      \ 'width': width + 2,
      \ 'height': height,
      \ }
    call nvim_open_win(bufnr('%'), v:true, options)
    call s:onOpenFloating(content)
  elseif vtm_window_type == 'popup'
    let vert = vert == 'N' ? 'top' : 'bot'
    let hor = hor == 'W' ? 'left' : 'right'
    let line = vert == 'top' ? 'cursor+1' : 'cursor-1'

    let options = {
      \ 'pos': vert . hor,
      \ 'line': line,
      \ 'col': 'cursor',
      \ 'moved': 'any',
      \ 'padding': [0, 1, 0, 1],
      \ 'minwidth': width,
      \ 'minheight': height
      \ }
    let winid = popup_create('', options)
    call s:onOpenPopup(winid, content)
  else
    let curr_pos = getpos('.')
    execute 'noswapfile bo pedit!'
    call setpos('.', curr_pos)
    wincmd P
    execute height+1 . 'wincmd _'
    call s:onOpenPreview(content)
  endif
endfunction

function! s:buildContent(translations)
  let paraphrase_marker = '🌀 '
  let phonetic_marker = '🔉 '
  let explain_marker = '📝 '

  let content = []
  call add(content, '@ ' . a:translations['text'] . ' @' )

  for t in a:translations['results']
    call add(content, '')
    call add(content, '------' . t['engine'] . '------')

    if len(t['paraphrase'])
      let paraphrase = paraphrase_marker . t['paraphrase']
      call add(content, paraphrase)
    endif

    if len(t['phonetic'])
      let phonetic = phonetic_marker . '[' . t['phonetic'] . ']'
      call add(content, phonetic)
    endif

    if len(t['explain'])
      for expl in t['explain']
        let expl = vtm#util#safeTrim(expl)
        if len(expl)
          let explain = explain_marker . expl
          call add(content, explain)
        endif
      endfor
    endif
  endfor

  return content
endfunction

function! s:onOpenFloating(translation)
  enew!
  call append(0, a:translation)
  normal gg
  nmap <silent> <buffer> q :close<CR>

  setlocal foldcolumn=1
  setlocal buftype=nofile
  setlocal bufhidden=wipe
  setlocal signcolumn=no
  setlocal filetype=vtm
  setlocal noautoindent
  setlocal nosmartindent
  setlocal wrap
  setlocal nobuflisted
  setlocal noswapfile
  setlocal nocursorline
  setlocal nonumber
  setlocal norelativenumber
  " only available in nvim
  if has('nvim')
    setlocal winhighlight=Normal:vtmFloatingNormal
    setlocal winhighlight=FoldColumn:vtmFloatingNormal
  endif

  noautocmd wincmd p

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

function! s:winSize(translation, max_width, max_height) abort
  let width = 0
  let height = 0

  for line in a:translation
    let line_width = strdisplaywidth(line)
    if line_width > a:max_width
      let width = a:max_width
      let height += line_width / a:max_width + 1
    else
      let width = max([line_width, width])
      let height += 1
    endif
  endfor

  if height > a:max_height
    let height = a:max_height
  endif
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

function! vtm#display#echo(translations) abort
  let has_phonetic = v:false
  let has_paraphrase = v:false
  let has_explain = v:false

  let content = []
  for t in a:translations['results']
    if len(t['phonetic']) && !has_phonetic
      call add(content, '[' . t['phonetic'] . ']')
      let has_phonetic = v:true
    endif
    if len(t['paraphrase']) && !has_paraphrase
      call add(content, t['paraphrase'])
      let has_paraphrase = v:true
    endif
    if len(t['explain']) && !has_explain
      call add(content, join(t['explain'], ' '))
      let has_explain = v:true
    endif
  endfor

  let translation = a:translations['text'] . ' ==> ' . join(content, ' ')
  call vtm#util#showMessage(translation)
endfunction

function! vtm#display#replace(translations) abort
  for t in a:translations['results']
    if len(t['paraphrase'])
      let reg_tmp = @a
      let @a = t['paraphrase']
      normal! gv"ap
      let @a = reg_tmp
      unlet reg_tmp
      return
    endif
  endfor

  call vtm#util#showMessage('No paraphrases for the replacement', 'warning')
endfunction
