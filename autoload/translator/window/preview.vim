" ============================================================================
" FileName: preview.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:win_exists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction

function! s:win_close_preview() abort
  if win_getid() == s:winid
    return
  else
    if s:win_exists(s:winid)
      execute win_id2win(s:winid) . 'hide'
    endif
    if exists('#close_translator_window')
      autocmd! close_translator_window
    endif
  endif
endfunction

let s:winid = -1
function! translator#window#preview#create(linelist, configs) abort
  call s:win_close_preview()
  let curr_pos = getpos('.')
  noswapfile bo new
  set previewwindow
  call setpos('.', curr_pos)
  wincmd P
  execute a:configs.height + 1 . 'wincmd _'
  enew!
  let s:winid = win_getid()
  call append(0, a:linelist)
  call setpos('.', [0, 1, 1, 0])
  call translator#buffer#init(bufnr('%'))
  call translator#window#init(s:winid)
  noautocmd wincmd p
  augroup close_translator_window
    autocmd!
    autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer>
      \ call timer_start(100, { -> s:win_close_preview() })
  augroup END
endfunction
