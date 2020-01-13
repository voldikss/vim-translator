" ============================================================================
" FileName: display.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

function! translator#display#window(translations) abort
  let Lines = s:build_lines(a:translations)
  let max_height =
    \ g:translator_window_max_height ==# v:null
    \ ? float2nr(0.6*&lines)
    \ : float2nr(g:translator_window_max_height)
  let max_width =
    \ g:translator_window_max_width ==# v:null
    \ ? float2nr(0.6*&columns)
    \ : float2nr(g:translator_window_max_width)
  let [width, height] = s:get_floatwin_size(Lines, max_width, max_height)
  let [y_offset, x_offset, vert, hor] = s:get_floatwin_pos(width, height)

  for i in range(len(Lines))
    let line = Lines[i]
    if match(line, '───') ==# 0 && width > strdisplaywidth(line)
      let Lines[i] = translator#util#padding(Lines[i], width, '─')
    elseif match(line, '⟦') ==# 0 && width > strdisplaywidth(line)
      let Lines[i] = translator#util#padding(Lines[i], width, ' ')
    endif
  endfor

  if has('nvim') && exists('*nvim_win_set_config')
    let translator_window_type = 'floating'
  elseif has('textprop') && has('patch-8.1.1522')
    let translator_window_type = 'popup'
  else
    let translator_window_type = 'preview'
  endif

  if translator_window_type ==# 'floating'
    let main_winnr = winnr()
    let cursor_pos=getcurpos()
    let vpos=cursor_pos[1]-line('w0')
    let hpos=cursor_pos[2]

    ""
    " TODO:
    " use 'relative': 'cursor' for the border window
    " use 'relative':'win'(which behaviors not as expected...) for content window
    let opts = {
      \ 'relative': 'win',
      \ 'bufpos': [0,0],
      \ 'anchor': vert . hor,
      \ 'row': vpos + y_offset + (vert ==# 'N' ? 1 : -1),
      \ 'col': hpos + x_offset + (hor ==# 'W' ? 1 : -1),
      \ 'width': width,
      \ 'height': height,
      \ 'style':'minimal'
      \ }
    let s:translator_bufnr = nvim_create_buf(v:false, v:true)
    let translator_winid = nvim_open_win(s:translator_bufnr, v:false, opts)
    call nvim_win_set_option(translator_winid, 'wrap', v:true)
    call nvim_buf_set_lines(s:translator_bufnr, 0, -1, v:false, Lines)
    call nvim_buf_set_option(s:translator_bufnr, 'filetype', 'translator')

    let border_opts = {
      \ 'relative': 'win',
      \ 'bufpos': [0,0],
      \ 'anchor': vert . hor,
      \ 'row': vpos + y_offset,
      \ 'col': hpos + x_offset,
      \ 'width': width + 2,
      \ 'height': height + 2,
      \ 'style':'minimal'
      \ }
    let top = g:translator_window_borderchars[4] .
            \ repeat(g:translator_window_borderchars[0], width) .
            \ g:translator_window_borderchars[5]
    let mid = g:translator_window_borderchars[3] .
            \ repeat(' ', width) .
            \ g:translator_window_borderchars[1]
    let bot = g:translator_window_borderchars[7] .
            \ repeat(g:translator_window_borderchars[2], width) .
            \ g:translator_window_borderchars[6]
    let lines = [top] + repeat([mid], height) + [bot]
    let s:border_bufnr = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:border_bufnr, 0, -1, v:true, lines)
    call nvim_open_win(s:border_bufnr, v:false, border_opts)
    " For translator border highlight
    augroup translator_border_highlight
      autocmd!
      autocmd FileType translator_border ++once execute 'syn match Border /.*/ | hi def link Border ' . g:translator_window_border_highlight
  augroup END
    call nvim_buf_set_option(s:border_bufnr, 'filetype', 'translator_border')

    " Note: this line must be put after creating the border_win!
    let s:translator_winnr = win_id2win(translator_winid)

    augroup translator_close
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:close_translator_window()
      exe 'autocmd BufLeave,BufWipeout,BufDelete <buffer=' . s:translator_bufnr . '> exe "bw ' . s:border_bufnr . '"'
    augroup END

  elseif translator_window_type ==# 'popup'
    let vert = vert ==# 'N' ? 'top' : 'bot'
    let hor = hor ==# 'W' ? 'left' : 'right'
    let line = vert ==# 'top' ? 'cursor+1' : 'cursor-1'

    let options = {
      \ 'pos': vert . hor,
      \ 'line': line,
      \ 'col': 'cursor',
      \ 'moved': 'any',
      \ 'padding': [0, 0, 0, 0],
      \ 'border': [1, 1, 1, 1],
      \ 'borderchars': g:translator_window_borderchars,
      \ 'borderhighlight': [g:translator_window_border_highlight],
      \ 'maxwidth': width,
      \ 'minwidth': width,
      \ 'maxheight': height,
      \ 'minheight': height
      \ }
    let winid = popup_create('', options)
    let bufnr = winbufnr(winid)
    for l in range(1, len(Lines))
      call setbufline(bufnr, l, Lines[l-1])
    endfor
    call setbufvar(bufnr, '&filetype', 'translator')
    call setbufvar(bufnr, '&spell', 0)
    call setbufvar(bufnr, '&wrap', 1)
    call setbufvar(bufnr, '&number', 1)
    call setbufvar(bufnr, '&relativenumber', 0)
    call setbufvar(bufnr, '&foldcolumn', 0)
  else
    let curr_pos = getpos('.')
    execute 'noswapfile bo pedit!'
    call setpos('.', curr_pos)
    wincmd P
    execute height+1 . 'wincmd _'
    enew!
    let s:translator_winnr = winnr()
    let s:translator_bufnr = bufnr() " NOTE: this line must be put after `enew`
    call append(0, Lines)
    call setpos('.', [0, 1, 1, 0])

    setlocal foldcolumn=1
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal signcolumn=no
    setlocal filetype=translator
    setlocal wrap nospell
    setlocal nonumber norelativenumber
    setlocal noautoindent nosmartindent
    setlocal nobuflisted noswapfile nocursorline
    noautocmd wincmd p

    augroup translator_close
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:close_translator_window()
    augroup END
  endif
endfunction

""
" Only available for floating winndow and preview window
function! translator#display#try_jump_into() abort
  if exists('s:translator_bufnr') && bufexists(s:translator_bufnr)
    noautocmd exe s:translator_winnr . ' wincmd w'
    return v:true
  endif
  return v:false
endfunction

""
" Close floating or preview window
function! s:close_translator_window() abort
  if exists('s:translator_bufnr') && bufexists(s:translator_bufnr)
    exe 'bw ' . s:translator_bufnr
  endif
  if exists('s:border_bufnr') && bufexists(s:border_bufnr)
    exe 'bw ' . s:border_bufnr
  endif
  if exists('#translator_close')
    autocmd! translator_close * <buffer>
  endif
endfunction

""
" Style always makes me frantic
function! s:build_lines(translations) abort
  if g:translator_window_enable_icon == v:true
    let marker = "• "
  else
    let marker = '_*_ '
  endif

  let content = []
  call add(content, '⟦ ' . a:translations['text'] . ' ⟧' )

  for t in a:translations['results']
    call add(content, '')
    call add(content, '─── ' . t['engine'] . ' ───')

    if len(t['paraphrase'])
      let paraphrase = marker . t['paraphrase']
      call add(content, paraphrase)
    endif

    if len(t['phonetic'])
      let phonetic = marker . '[' . t['phonetic'] . ']'
      call add(content, phonetic)
    endif

    if len(t['explain'])
      for expl in t['explain']
        let expl = translator#util#safe_trim(expl)
        if len(expl)
          let explain = marker . expl
          call add(content, explain)
        endif
      endfor
    endif
  endfor
  if g:translator_debug_mode
    call add(g:translator_log, printf('build_lines result: %s', string(content)))
  endif
  return content
endfunction

function! s:get_floatwin_size(translation, max_width, max_height) abort
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

""
" x_offset and y_offset values are presetted according to the border's position
" see border_opts
function! s:get_floatwin_pos(width, height) abort
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
    let y_offset = 2
  else
    let vert = 'S'
    let y_offset = 1
  endif

  if colnr + a:width <= &columns
    let hor = 'W'
    let x_offset = -1
  else
    let hor = 'E'
    let x_offset = 0
  endif

  return [y_offset, x_offset, vert, hor]
endfunction

function! translator#display#echo(translations) abort
  let phonetic = ''
  let paraphrase = ''
  let explain = ''

  for t in a:translations['results']
    if len(t['phonetic']) && (phonetic ==# '')
      let phonetic = '[' . t['phonetic'] . ']'
    endif
    if len(t['paraphrase']) && (paraphrase ==# '')
      let paraphrase = t['paraphrase']
    endif
    if len(t['explain']) && (len(explain) ==# 0)
      let explain = join(t['explain'], ' ')
    endif
  endfor

  call translator#util#echo('Function', a:translations['text'])
  call translator#util#echon('Constant', '==>')
  call translator#util#echon('Type', phonetic)
  call translator#util#echon('Normal', paraphrase)
  call translator#util#echon('Normal', explain)
endfunction

function! translator#display#replace(translations) abort
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

  call translator#util#show_msg('No paraphrases for the replacement', 'warning')
endfunction
