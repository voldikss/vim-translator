" ============================================================================
" FileName: window.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')
let s:winid = -1
let s:bd_winid = -1

function! s:get_wintype() abort
  if g:translator_window_type == 'popup'
    if s:has_float
      return 'floating'
    elseif s:has_popup
      return 'popup'
    else
      call translator#util#show_msg("popup window is not supported in your vim, fall back to preview window", 'warning')
      return 'preview'
    endif
  endif
  return g:translator_window_type
endfunction
let s:wintype = s:get_wintype()

function! s:winexists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:floatwin_size(translation, max_width, max_height) abort
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

function! s:floatwin_pos(width, height) abort
  let pos = win_screenpos('.')
  let y_pos = pos[0] + winline() - 1
  let x_pos = pos[1] + wincol() -1

  let border = empty(g:translator_window_borderchars) ? 0 : 2
  let y_margin = 2
  let [width, height] = [a:width, a:height]

  if y_pos + height + border + y_margin <= &lines
    let vert = 'N'
    let y_offset = 0
  elseif y_pos - height -border - y_margin >= 0
    let vert = 'S'
    let y_offset = -1
  elseif &lines - y_pos >= y_pos
    let vert = 'N'
    let y_offset = 0
    let height = &lines - y_pos - border - y_margin
  else
    let vert = 'S'
    let y_offset = -1
    let height = y_pos - border - y_margin
  endif

  if x_pos + a:width + border <= &columns
    let hor = 'W'
    let x_offset = -1
  elseif x_pos - width - border >= 0
    let hor = 'E'
    let x_offset = 0
  elseif &columns - x_pos >= x_pos
    let hor = 'W'
    let x_offset = -1
    let width = &columns - x_pos - border
  else
    let hor = 'E'
    let x_offset = 0
    let width = x_pos - border
  endif
  let anchor = vert . hor
  if !has('nvim')
    let anchor = substitute(anchor, '\CN', 'top', '')
    let anchor = substitute(anchor, '\CS', 'bot', '')
    let anchor = substitute(anchor, '\CW', 'left', '')
    let anchor = substitute(anchor, '\CE', 'right', '')
  endif
  let row = y_pos + y_offset
  let col = x_pos + x_offset
  return [anchor, row, col, width, height]
endfunction

function! s:popup_filter(winid, key) abort
  if a:key == "\<c-k>"
    call win_execute(a:winid, "normal! \<c-y>")
    return v:true
  elseif a:key == "\<c-j>"
    call win_execute(a:winid, "normal! \<c-e>")
    return v:true
  elseif a:key == 'q' || a:key == 'x'
    return popup_filter_menu(a:winid, 'x')
  endif
  return v:false
endfunction

function! s:close_translator_window() abort
  if win_getid() == s:winid
    return
  else
    if s:winexists(s:winid)
      if has('nvim')
        call nvim_win_close(s:winid, v:true)
      else
        execute win_id2win(s:winid) . 'hide'
      endif
    endif
    if s:winexists(s:bd_winid)
      call nvim_win_close(s:bd_winid, v:true)
    endif
    if exists('#close_translator_floatwin')
      autocmd! close_translator_floatwin
    endif
  endif
endfunction

function! s:open_float(linelist, configs) abort
  call s:close_translator_window()

  let options = {
    \ 'relative': 'editor',
    \ 'anchor': a:configs.anchor,
    \ 'row': a:configs.row + (a:configs.anchor[0] == 'N' ? 1 : -1),
    \ 'col': a:configs.col + (a:configs.anchor[1] == 'W' ? 1 : -1),
    \ 'width': a:configs.width - 2,
    \ 'height': a:configs.height - 2,
    \ 'style':'minimal',
    \ }
  let buf = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(buf, 0, -1, v:false, a:linelist)
  call nvim_buf_set_option(buf, 'filetype', 'translator')
  call nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  let s:winid = nvim_open_win(buf, v:false, options)
  call nvim_win_set_option(s:winid, 'wrap', v:true)
  call nvim_win_set_option(s:winid, 'conceallevel', 3)
  call nvim_win_set_option(s:winid, 'winhl', 'Normal:Translator')

  let bd_options = {
    \ 'relative': 'editor',
    \ 'anchor': a:configs.anchor,
    \ 'row': a:configs.row,
    \ 'col': a:configs.col,
    \ 'width': a:configs.width,
    \ 'height': a:configs.height,
    \ 'focusable': v:false,
    \ 'style':'minimal',
    \ }
  let bd_bufnr = translator#buffer#create_border(a:configs)
  let s:bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call nvim_win_set_option(s:bd_winid, 'winhl', 'Normal:TranslatorBorder')

  " NOTE: dont use call nvim_set_current_win(s:translator_winid)
  noautocmd call win_gotoid(s:winid)
  noautocmd wincmd p
  augroup close_translator_floatwin
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer>
      \ call timer_start(100, { -> s:close_translator_window() })
  augroup END
endfunction

function! s:open_popup(linelist, options) abort
  let options = {
    \ 'pos': a:options.anchor,
    \ 'col': 'cursor',
    \ 'line': a:options.anchor[0:2] == 'top' ? 'cursor+1' : 'cursor-1',
    \ 'moved': 'any',
    \ 'padding': [0, 0, 0, 0],
    \ 'maxwidth': a:options.width,
    \ 'minwidth': a:options.width,
    \ 'maxheight': a:options.height,
    \ 'minheight': a:options.height,
    \ 'filter': function('s:popup_filter'),
    \ }
  if !empty(g:translator_window_borderchars)
    let options.borderchars = g:translator_window_borderchars
    let options.border = [1, 1, 1, 1]
    let options.borderhighlight = ['TranslatorBorder']
  endif
  let winid = popup_create('', options)
  let bufnr = winbufnr(winid)
  call appendbufline(bufnr, 0, a:linelist)
  call setbufvar(bufnr, '&filetype', 'translator')
  call setbufvar(bufnr, '&spell', 0)
  call setbufvar(bufnr, '&wrap', 1)
  call setbufvar(bufnr, '&number', 1)
  call setbufvar(bufnr, '&relativenumber', 0)
  call setbufvar(bufnr, '&foldcolumn', 0)
  call setwinvar(winid, '&conceallevel', 3)
  call setwinvar(winid, '&wincolor', 'Translator')
endfunction

function! s:open_preview(linelist, options) abort
  call s:close_translator_window()
  let curr_pos = getpos('.')
  execute 'noswapfile bo pedit!'
  call setpos('.', curr_pos)
  wincmd P
  execute height+1 . 'wincmd _'
  enew!
  let s:winid = win_getid()
  call append(0, linelist)
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
  augroup close_translator_preview
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer>
      \ call timer_start(100, { -> s:close_translator_window() })
  augroup END
endfunction

function! translator#window#open(content) abort
  let max_width = g:translator_window_max_width
  if type(max_width) == v:t_float | let max_width = max_width * &columns | endif
  let max_width = float2nr(max_width)

  let max_height = g:translator_window_max_height
  if type(max_height) == v:t_float | let max_height = max_height * &lines | endif
  let max_height = float2nr(max_height)

  let [width, height] = s:floatwin_size(a:content, max_width, max_height)
  let [anchor, row, col, width, height] = s:floatwin_pos(width, height)
  let linelist = translator#util#fit_lines(a:content, width)

  let configs = {
    \ 'anchor': anchor,
    \ 'row': row,
    \ 'col': col,
    \ 'width': width + 2,
    \ 'height': height + 2,
    \ 'title': '',
    \ 'borderchars': g:translator_window_borderchars
    \ }
  if s:wintype == 'floating'
    call s:open_float(linelist, configs)
  elseif s:wintype == 'popup'
    call s:open_popup(linelist, configs)
  else
    call s:open_preview(linelist, configs)
  endif
endfunction
