" ============================================================================
" FileName: neovim.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#neovim#nvim_create_buf(linelist, filetype) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:false, a:linelist)
  call nvim_buf_set_option(bufnr, 'filetype', a:filetype)
  return bufnr
endfunction


function! translator#neovim#get_floatwin_size(translation, max_width, max_height) abort
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


function! translator#neovim#get_floatwin_pos(width, height) abort
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

  return [y_offset, x_offset, vert, hor, width, height]
endfunction


" @param:
"   winid: translator window id
function! translator#neovim#add_border(winid) abort
  if empty(g:translator_window_borderchars)
    return -1
  endif
  let opts = nvim_win_get_config(a:winid)
  let opts.style = 'minimal'
  let inner_opts = deepcopy(opts)
  let inner_opts.width -= 2
  let inner_opts.row += inner_opts.anchor[0] ==# 'N' ? 1 : -1
  let inner_opts.col += inner_opts.anchor[1] ==# 'W' ? 1 : -1
  call nvim_win_set_config(a:winid, inner_opts)
  call nvim_win_set_option(a:winid, 'foldcolumn', 0)

  let borderlines = s:build_border(inner_opts.width, inner_opts.height)
  let border_bufnr = translator#neovim#nvim_create_buf(borderlines, 'translator_border')
  call nvim_buf_set_option(border_bufnr, 'bufhidden', 'wipe')

  let opts.height += 2
  let opts.focusable = v:false
  let border_winid = nvim_open_win(border_bufnr, v:false, opts)
  call nvim_win_set_option(border_winid, 'winhl', 'NormalFloat:TranslatorBorderNF')
  return border_winid
endfunction


function! s:build_border(width, height) abort
  let top = g:translator_window_borderchars[4] .
          \ repeat(g:translator_window_borderchars[0], a:width) .
          \ g:translator_window_borderchars[5]
  let mid = g:translator_window_borderchars[3] .
          \ repeat(' ', a:width) .
          \ g:translator_window_borderchars[1]
  let bot = g:translator_window_borderchars[7] .
          \ repeat(g:translator_window_borderchars[2], a:width) .
          \ g:translator_window_borderchars[6]
  return [top] + repeat([mid], a:height) + [bot]
endfunction
