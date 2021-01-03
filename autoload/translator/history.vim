" ============================================================================
" FileName: history.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:history_file = expand('<sfile>:p:h') . '/../../translation_history.data'

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

function! translator#history#save(translations) abort
  if !g:translator_history_enable
    return
  endif

  let text = a:translations['text']
  for t in a:translations['results']
    let paraphrase = t['paraphrase']
    let explains = t['explains']

    if !empty(explains)
      let item = s:padding_end(text, 25) . explains[0]
      break
    elseif !empty(paraphrase) && text !=? paraphrase
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

  execute 'redir >> ' . s:history_file
  silent! echon item . "\n"
  redir END
endfunction

function! translator#history#export() abort
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
