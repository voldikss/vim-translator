" ============================================================================
" FileName: util.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

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


function! translator#util#fit_lines(linelist, width) abort
  for i in range(len(a:linelist))
    let line = a:linelist[i]
    if match(line, '───') ==# 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#padding(a:linelist[i], a:width, '─')
    elseif match(line, '⟦') ==# 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#padding(a:linelist[i], a:width, ' ')
    endif
  endfor
  return a:linelist
endfunction


" Style always makes me frantic
function! translator#util#build_lines(translations) abort
  if g:translator_window_enable_icon == v:true
    let marker = '• '
  else
    let marker = '_*_ '
  endif

  let content = []
  if len(a:translations['text']) > 30
    let text = a:translations['text'][:30] . '...'
  else
    let text = a:translations['text']
  endif
  call add(content, printf('⟦ %s ⟧', text))

  for t in a:translations['results']
    if empty(t.paraphrase) && empty(t.explain)
      continue
    endif
    call add(content, '')
    call add(content, printf('─── %s ───', t.engine))

    if !empty(t.paraphrase)
      let paraphrase = marker . t.paraphrase
      call add(content, paraphrase)
    endif

    if !empty(t.phonetic)
      let phonetic = marker . printf('[%s]', t.phonetic)
      call add(content, phonetic)
    endif

    if !empty(t.explain)
      for expl in t.explain
        let expl = translator#util#safe_trim(expl)
        if !empty(expl)
          let explain = marker . expl
          call add(content, explain)
        endif
      endfor
    endif
  endfor
  call translator#debug#info(content)
  return content
endfunction


function! translator#util#visual_select() abort
  let reg_tmp = @a
  silent normal! gv"ay
  let select_text=@a
  let @a = reg_tmp
  unlet reg_tmp
  return select_text
endfunction


function! translator#util#safe_trim(text) abort
  return substitute(a:text,'\%#=1^[[:space:]]\+\|[[:space:]]\+$', '', 'g')
endfunction
