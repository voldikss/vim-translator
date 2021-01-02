" ============================================================================
" FileName: window.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:has_popup = has('textprop') && has('patch-8.2.0286')
let s:has_float = has('nvim') && exists('*nvim_win_set_config')

function! s:win_gettype() abort
  if g:translator_window_type == 'popup'
    if s:has_float
      return 'float'
    elseif s:has_popup
      return 'popup'
    else
      call translator#util#show_msg("popup is not supported, use preview window", 'warning')
      return 'preview'
    endif
  endif
  return 'preview'
endfunction
let s:wintype = s:win_gettype()

function! s:win_getsize(translation, max_width, max_height) abort
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

function! s:win_getoptions(width, height) abort
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

" setwinvar also accept window-ID, which is not mentioned in the document
function! translator#window#init(winid) abort
  call setwinvar(a:winid, '&wrap', 1)
  call setwinvar(a:winid, '&conceallevel', 3)
  call setwinvar(a:winid, '&number', 0)
  call setwinvar(a:winid, '&relativenumber', 0)
  call setwinvar(a:winid, '&spell', 0)
  call setwinvar(a:winid, '&foldcolumn', 0)
  if has('nvim')
    call setwinvar(a:winid, '&winhl', 'Normal:Translator')
  else
    call setwinvar(a:winid, '&wincolor', 'Translator')
  endif
endfunction

function! translator#window#open(content) abort
  let max_width = g:translator_window_max_width
  if type(max_width) == v:t_float | let max_width = max_width * &columns | endif
  let max_width = float2nr(max_width)

  let max_height = g:translator_window_max_height
  if type(max_height) == v:t_float | let max_height = max_height * &lines | endif
  let max_height = float2nr(max_height)

  let [width, height] = s:win_getsize(a:content, max_width, max_height)
  let [anchor, row, col, width, height] = s:win_getoptions(width, height)
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
  call translator#window#{s:wintype}#create(linelist, configs)
endfunction
