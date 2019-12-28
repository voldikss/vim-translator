" @Author: voldikss
" @Date: 2019-06-20 19:45:42
" @Last Modified by: voldikss
" @Last Modified time: 2019-08-01 07:40:53

let s:history_file = expand('<sfile>:p:h') . '/../../translation_history.data'

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
    let msgType = 'info'
  else
    let msgType = a:1
  endif

  if type(a:message) != 1
    let message = string(a:message)
  else
    let message = a:message
  endif

  call translator#util#echo('Constant', '[vim-translator] ')

  if msgType == 'info'
    call translator#util#echon('Normal', message)
  elseif msgType == 'warning'
    call translator#util#echon('WarningMsg', message)
  elseif msgType == 'error'
    call translator#util#echon('Error', message)
  endif
endfunction

function! translator#util#save_history(translations) abort
  if !g:translator_history_enable
    return
  endif

  let text = a:translations['text']
  for t in a:translations['results']
    let paraphrase = t['paraphrase']
    let explain = t['explain']

    if len(explain)
      let item = s:padding_end(text, 25) . explain[0]
      break
    elseif len(paraphrase) && text !=? paraphrase
      let item = s:padding_end(text, 25) . paraphrase
      break
    else
      return
    endif
  endfor

  if !filereadable(s:history_file)
    call writefile([], s:history_file)
  endif

  let trans_data = readfile(s:history_file)

  " already in
  if match(string(trans_data), text) >= 0
    return
  endif

  " default history count
  if len(trans_data) == 1000
    call remove(trans_data, 0)
  endif

  let trans_data += [item]
  let result = writefile(trans_data, s:history_file)
  if result == -1
    let message = 'Failed to save the translation data.'
    call translator#util#show_msg(message, 'warning')
  endif
endfunction

function! translator#util#export_history() abort
  if !filereadable(s:history_file)
    let message = 'History file not exist yet'
    call translator#util#show_msg(message, 'error')
    return
  endif

  execute 'tabnew ' .  s:history_file
  setlocal filetype=translator_history
  syn match TranslateHistoryQuery #\v^.*\v%25v#
  syn match TranslateHistoryTrans #\v%26v.*$#
  hi def link TranslateHistoryQuery Keyword
  hi def link TranslateHistoryTrans String
endfunction

function! s:padding_end(text, length) abort
  let text = a:text
  let len = len(text)
  if len < a:length
    for i in range(a:length-len)
      let text .= ' '
    endfor
  endif
  return text
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
  return substitute(a:text, "^\\s*\\(.\\{-}\\)\\(\\n\\|\\s\\)*$", '\1', '')
endfunction
