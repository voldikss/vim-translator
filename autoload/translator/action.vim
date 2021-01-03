" ============================================================================
" FileName: action.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#action#window(translations) abort
  let marker = '• '
  let content = []
  if len(a:translations['text']) > 30
    let text = a:translations['text'][:30] . '...'
  else
    let text = a:translations['text']
  endif
  call add(content, printf('⟦ %s ⟧', text))

  for t in a:translations['results']
    if empty(t.paraphrase) && empty(t.explains)
      continue
    endif
    call add(content, '')
    call add(content, printf('─── %s ───', t.engine))
    if !empty(t.phonetic)
      let phonetic = marker . printf('[%s]', t.phonetic)
      call add(content, phonetic)
    endif
    if !empty(t.paraphrase)
      let paraphrase = marker . t['paraphrase']
      call add(content, paraphrase)
    endif
    if !empty(t.explains)
      for expl in t.explains
        let expl = translator#util#safe_trim(expl)
        if !empty(expl)
          let explains = marker . expl
          call add(content, explains)
        endif
      endfor
    endif
  endfor
  call translator#logger#log(content)
  call translator#window#open(content)
endfunction

function! translator#action#echo(translations) abort
  let phonetic = ''
  let paraphrase = ''
  let explains = ''

  for t in a:translations['results']
    if !empty(t.phonetic) && empty(phonetic)
      let phonetic = printf('[%s]', t.phonetic)
    endif
    if !empty(t.paraphrase) && empty(paraphrase)
      let paraphrase = t.paraphrase
    endif
    if !empty(t.explains) && empty(explains)
      let explains = join(t.explains, ' ')
    endif
  endfor

  if len(a:translations['text']) > 30
    let text = a:translations['text'][:30] . '...'
  else
    let text = a:translations['text']
  endif
  call translator#util#echo('Function', text)
  call translator#util#echon('Constant', '==>')
  call translator#util#echon('Type', phonetic)
  call translator#util#echon('Normal', paraphrase)
  call translator#util#echon('Normal', explains)
endfunction

function! translator#action#replace(translations) abort
  for t in a:translations['results']
    if !empty(t.paraphrase)
      let reg_tmp = @a
      let @a = t.paraphrase
      normal! gv"ap
      let @a = reg_tmp
      unlet reg_tmp
      return
    endif
  endfor
  call translator#util#show_msg('No paraphrases for the replacement', 'warning')
endfunction
