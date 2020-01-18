" ============================================================================
" FileName: util.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#util#echo(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! translator#util#echon(group, msg) abort
  if a:msg ==# '' | return | endif
  execute 'echohl' a:group
  echon a:msg
  echon ' '
  echohl NONE
endfunction

function! translator#util#show_msg(message, ...) abort
  if a:0 == 0
    let msg_type = 'info'
  else
    let msg_type = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call translator#util#echo('Constant', '[vim-translator]')

  if msg_type ==# 'info'
    call translator#util#echon('Normal', message)
  elseif msg_type ==# 'warning'
    call translator#util#echon('WarningMsg', message)
  elseif msg_type ==# 'error'
    call translator#util#echon('Error', message)
  endif
endfunction

function! translator#util#padding(text, width, char) abort
  let padding_size = (a:width - strdisplaywidth(a:text)) / 2
  let padding = repeat(a:char, padding_size)
  let padend = repeat(a:char, (a:width - strdisplaywidth(a:text)) % 2)
  let text = padding . a:text . padding . padend
  return text
endfunction

function! translator#util#visual_select() abort
  let reg_tmp = @a
  normal! gv"ay
  let select_text=@a
  let @a = reg_tmp
  unlet reg_tmp
  return select_text
endfunction

function! translator#util#safe_trim(text) abort
  return substitute(a:text,'\%#=1^[[:space:]]\+\|[[:space:]]\+$', '', 'g')
endfunction

function! translator#util#get_signcolumn_width() abort
  let option = &signcolumn
  let width = matchstr(option, '\v\d+')
  let width = width ==# '' ? matchstr(option, '\vyes') : width
  let width = width ==# '' ? 0 : (width ==# 'yes' ? 1 : str2nr(width))
  return width*2
endfunction
