" ============================================================================
" FileName: util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#util#echo(group, msg) abort
  if a:msg == '' | return | endif
  execute 'echohl' a:group
  echo a:msg
  echon ' '
  echohl NONE
endfunction

function! translator#util#echon(group, msg) abort
  if a:msg == '' | return | endif
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

  if msg_type == 'info'
    call translator#util#echon('Normal', message)
  elseif msg_type == 'warning'
    call translator#util#echon('WarningMsg', message)
  elseif msg_type == 'error'
    call translator#util#echon('Error', message)
  endif
endfunction

function! translator#util#pad(text, width, char) abort
  let padding_size = (a:width - strdisplaywidth(a:text)) / 2
  let padding = repeat(a:char, padding_size / strdisplaywidth(a:char))
  let padend = repeat(a:char, (a:width - strdisplaywidth(a:text)) % 2)
  let text = padding . a:text . padding
  if a:width >= strdisplaywidth(text) + strdisplaywidth(padend)
    let text .= padend
  endif
  return text
endfunction

function! translator#util#fit_lines(linelist, width) abort
  for i in range(len(a:linelist))
    let line = a:linelist[i]
    if match(line, '───') == 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#pad(a:linelist[i], a:width, '─')
    elseif match(line, '⟦') == 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#pad(a:linelist[i], a:width, ' ')
    endif
  endfor
  return a:linelist
endfunction

function! translator#util#visual_select(range, line1, line2) abort
  if a:range == 0
    let lines = [expand('<cword>')]
  elseif a:range == 1
    let lines = [getline('.')]
  else
    if a:line1 == a:line2
      " https://vi.stackexchange.com/a/11028/17515
      let [lnum1, col1] = getpos("'<")[1:2]
      let [lnum2, col2] = getpos("'>")[1:2]
      let lines = getline(lnum1, lnum2)
      if empty(lines)
        call floaterm#util#show_msg('No lines were selected', 'error')
        return
      endif
      let lines[-1] = lines[-1][: col2 - 1]
      let lines[0] = lines[0][col1 - 1:]
    else
      let lines = getline(a:line1, a:line2)
    endif
  endif
  return join(lines)
endfunction

function! translator#util#safe_trim(text) abort
  return substitute(a:text,'\%#=1^[[:space:]]\+\|[[:space:]]\+$', '', 'g')
endfunction

function! translator#util#text_proc(text) abort
  let text = substitute(a:text, "\n", ' ', 'g')
  let text = substitute(text, "\n\r", ' ', 'g')
  let text = substitute(text, '\v^\s+', '', '')
  let text = substitute(text, '\v\s+$', '', '')
  let text = escape(text, '"')
  let text = printf('"%s"', text)
  return text
endfunction
