" @Author: voldikss
" @Date: 2019-06-20 19:45:42
" @Last Modified by: voldikss
" @Last Modified time: 2019-08-01 07:40:53


function! vtm#util#show_msg(message, ...) abort
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

  if msgType == 'info'
    echohl String
  elseif msgType == 'warning'
    echohl WarningMsg
  elseif msgType == 'error'
    echohl ErrorMsg
  endif

  echomsg '[vim-translate-me] ' . message
  echohl None
endfunction

function! vtm#util#save_history(translations) abort
  if !g:vtm_history_enable
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

  if !filereadable(g:vtm_history_file)
    call writefile([], g:vtm_history_file)
  endif

  let trans_data = readfile(g:vtm_history_file)

  " already in
  if match(string(trans_data), text) >= 0
    return
  endif

  if len(trans_data) == g:vtm_history_count
    call remove(trans_data, 0)
  endif

  let trans_data += [item]
  let result = writefile(trans_data, g:vtm_history_file)
  if result == -1
    let message = 'Failed to save the translation data.'
    call vtm#util#show_msg(message, 'warning')
  endif
endfunction

function! vtm#util#export_history() abort
  if !filereadable(g:vtm_history_file)
    let message = 'History file not exist yet'
    call vtm#util#show_msg(message, 'error')
    return
  endif

  execute 'tabnew ' .  g:vtm_history_file
  setlocal filetype=vtm_history
  syn match vtmHistoryQuery #\v^.*\v%25v#
  syn match vtmHistoryTrans #\v%26v.*$#
  hi def link vtmHistoryQuery Keyword
  hi def link vtmHistoryTrans String
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

function! vtm#util#padding(text, width, char)
  let padding_size = (a:width - strdisplaywidth(a:text)) / 2
  let padding = repeat(a:char, padding_size)
  let padend = repeat(a:char, (a:width - strdisplaywidth(a:text)) % 2)
  let text = padding . a:text . padding . padend
  return text
endfunction

function! vtm#util#visual_select() abort
  let reg_tmp = @a
  normal! gv"ay
  let select_text=@a
  let @a = reg_tmp
  unlet reg_tmp
  return select_text
endfunction

function! vtm#util#safe_trim(text)
  return substitute(a:text, "^\\s*\\(.\\{-}\\)\\(\\n\\|\\s\\)*$", '\1', '')
endfunction
