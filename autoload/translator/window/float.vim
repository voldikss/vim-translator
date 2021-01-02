" ============================================================================
" FileName: float.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" Description: thanks coc.nvim
" ============================================================================

" max firstline of lines, height > 0, width > 0
function! s:max_firstline(lines, height, width) abort
  let max = len(a:lines)
  let remain = a:height
  for line in reverse(copy(a:lines))
    let w = max([1, strdisplaywidth(line)])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    if remain - dh < 0
      break
    endif
    let remain = remain - dh
    let max = max - 1
  endfor
  return min([len(a:lines), max + 1])
endfunction

function! s:content_height(bufnr, width, wrap) abort
  if !bufloaded(a:bufnr)
    return 0
  endif
  if !a:wrap
    return has('nvim') ? nvim_buf_line_count(a:bufnr) : len(getbufline(a:bufnr, 1, '$'))
  endif
  let lines = has('nvim') ? nvim_buf_get_lines(a:bufnr, 0, -1, 0) : getbufline(a:bufnr, 1, '$')
  let total = 0
  for line in lines
    let dw = max([1, strdisplaywidth(line)])
    let total += float2nr(ceil(str2float(string(dw))/a:width))
  endfor
  return total
endfunction

" Get best lnum by topline
function! s:get_cursorline(topline, lines, scrolloff, width, height) abort
  let lastline = len(a:lines)
  if a:topline == lastline
    return lastline
  endif
  let bottomline = a:topline
  let used = 0
  for lnum in range(a:topline, lastline)
    let w = max([1, strdisplaywidth(a:lines[lnum - 1])])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    let g:l = a:lines
    if used + dh >= a:height || lnum == lastline
      let bottomline = lnum
      break
    endif
    let used += dh
  endfor
  let cursorline = a:topline + a:scrolloff
  let g:b = bottomline
  let g:h = a:height
  if cursorline + a:scrolloff > bottomline
    " unable to satisfy scrolloff
    let cursorline = (a:topline + bottomline)/2
  endif
  return cursorline
endfunction

" Get firstline for full scroll
function! s:get_topline(topline, lines, forward, height, width) abort
  let used = 0
  let lnums = a:forward ? range(a:topline, len(a:lines)) : reverse(range(1, a:topline))
  let topline = a:forward ? len(a:lines) : 1
  for lnum in lnums
    let w = max([1, strdisplaywidth(a:lines[lnum - 1])])
    let dh = float2nr(ceil(str2float(string(w))/a:width))
    if used + dh >= a:height
      let topline = lnum
      break
    endif
    let used += dh
  endfor
  if topline == a:topline
    if a:forward
      let topline = min([len(a:lines), topline + 1])
    else
      let topline = max([1, topline - 1])
    endif
  endif
  return topline
endfunction

" topline content_height content_width
function! s:get_options(winid) abort
  if has('nvim')
    let width = nvim_win_get_width(a:winid)
    if getwinvar(a:winid, '&foldcolumn', 0)
      let width = width - 1
    endif
    let info = getwininfo(a:winid)[0]
    return {
          \ 'topline': info['topline'],
          \ 'height': nvim_win_get_height(a:winid),
          \ 'width': width
          \ }
  else
    let pos = popup_getpos(a:winid)
    return {
          \ 'topline': pos['firstline'],
          \ 'width': pos['core_width'],
          \ 'height': pos['core_height']
          \ }
  endif
endfunction

function! s:win_execute(winid, command) abort
  let curr = nvim_get_current_win()
  noa keepalt call nvim_set_current_win(a:winid)
  exec a:command
  noa keepalt call nvim_set_current_win(curr)
endfunction

function! s:win_setview(winid, topline, lnum) abort
  let cmd = 'call winrestview({"lnum":'.a:lnum.',"topline":'.a:topline.'})'
  call s:win_execute(a:winid, cmd)
endfunction

function! s:win_exists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:win_close_float() abort
  if win_getid() == s:winid
    return
  else
    if s:win_exists(s:winid)
      call nvim_win_close(s:winid, v:true)
    endif
    if s:win_exists(s:bd_winid)
      call nvim_win_close(s:bd_winid, v:true)
    endif
    if exists('#close_translator_window')
      autocmd! close_translator_window
    endif
  endif
endfunction

function! translator#window#float#has_scroll() abort
  return s:win_exists(s:winid)
endfunction

function! translator#window#float#scroll(forward, ...) abort
  let amount = get(a:, 1, 0)
  if !s:win_exists(s:winid)
    call translator#util#show_msg('No translator windows')
  else
    call translator#window#float#scroll_win(s:winid, a:forward, amount)
  endif
  return mode() =~ '^i' || mode() ==# 'v' ? "" : "\<Ignore>"
endfunction

function! translator#window#float#scroll_win(winid, forward, amount) abort
  let opts = s:get_options(a:winid)
  let lines = getbufline(winbufnr(a:winid), 1, '$')
  let maxfirst = s:max_firstline(lines, opts['height'], opts['width'])
  let topline = opts['topline']
  let height = opts['height']
  let width = opts['width']
  let scrolloff = getwinvar(a:winid, '&scrolloff', 0)
  if a:forward && topline >= maxfirst
    return
  endif
  if !a:forward && topline == 1
    return
  endif
  if a:amount == 0
    let topline = s:get_topline(opts['topline'], lines, a:forward, height, width)
  else
    let topline = topline + (a:forward ? a:amount : - a:amount)
  endif
  let topline = a:forward ? min([maxfirst, topline]) : max([1, topline])
  let lnum = s:get_cursorline(topline, lines, scrolloff, width, height)
  call s:win_setview(a:winid, topline, lnum)
  let top = s:get_options(a:winid)['topline']
  " not changed
  if top == opts['topline']
    if a:forward
      call s:win_setview(a:winid, topline + 1, lnum + 1)
    else
      call s:win_setview(a:winid, topline - 1, lnum - 1)
    endif
  endif
endfunction

let s:winid = -1
let s:bd_winid = -1
function! translator#window#float#create(linelist, configs) abort
  call s:win_close_float()

  let options = {
        \ 'relative': 'editor',
        \ 'anchor': a:configs.anchor,
        \ 'row': a:configs.row + (a:configs.anchor[0] == 'N' ? 1 : -1),
        \ 'col': a:configs.col + (a:configs.anchor[1] == 'W' ? 1 : -1),
        \ 'width': a:configs.width - 2,
        \ 'height': a:configs.height - 2,
        \ 'style':'minimal',
        \ }
  let bufnr = translator#buffer#create_scratch_buf(a:linelist)
  call translator#buffer#init(bufnr)
  let winid = nvim_open_win(bufnr, v:false, options)
  call translator#window#init(winid)

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
  let bd_winid = nvim_open_win(bd_bufnr, v:false, bd_options)
  call nvim_win_set_option(bd_winid, 'winhl', 'Normal:TranslatorBorder')

  " NOTE: dont use call nvim_set_current_win(s:translator_winid)
  noautocmd call win_gotoid(winid)
  noautocmd wincmd p
  augroup close_translator_window
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer>
          \ call timer_start(100, { -> s:win_close_float() })
  augroup END
  let s:winid = winid
  let s:bd_winid = bd_winid
  return [winid, bd_winid]
endfunction
