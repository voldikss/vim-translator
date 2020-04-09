" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:parse_args(argstr) abort
  if g:translator_debug_mode
    call add(g:translator_log, printf('- cmdline args: %s', a:argstr))
  endif
  let argsmap = {
    \ 'engines': '',
    \ 'text': '',
    \ 'target_lang': '',
    \ 'source_lang': ''
    \ }
  let flag = ''
  for arg in split(a:argstr, '\v\s+')
    if '-e' ==# arg
      let flag = 'engines'
    elseif '-t' ==# arg
      let flag = 'text'
    elseif '-tl' ==# arg
      let flag = 'target_lang'
    elseif '-sl' ==# arg
      let flag = 'source_lang'
    else
      if flag ==# 'text'
        let argsmap.text .= arg . ' '
      elseif flag ==# 'target_lang'
        let argsmap.target_lang = arg
      elseif flag ==# 'source_lang'
        let argsmap.source_lang = arg
      elseif flag ==# 'engines'
        let argsmap.engines .= arg
      else
        return [argsmap, v:false]
      endif
    endif
  endfor

  if empty(argsmap.engines)
    let argsmap.engines = join(g:translator_default_engines, ' ')
  endif
  if empty(argsmap.target_lang)
    let argsmap.target_lang = g:translator_target_lang
  endif
  if empty(argsmap.source_lang)
    let argsmap.source_lang = g:translator_source_lang
  endif
  return [argsmap, v:true]
endfunction

function! translator#cmdline#parse(visualmode, args, bang, line1, line2, count) abort
  let [argsmap, success] = s:parse_args(a:args)
  if success != v:true
    return [v:null, v:false]
  endif

  if argsmap.text == ''
    if a:visualmode
      let argsmap.text = translator#util#visual_select()
    elseif a:count != -1
      for lnum in range(a:line1, a:line2)
        let argsmap.text .= getline(lnum)
      endfor
    else
      let argsmap.text = expand('<cfile>')
    endif
  endif

  " Trim the text
  let argsmap.text = substitute(argsmap.text, "\n", ' ', 'g')
  let argsmap.text = substitute(argsmap.text, "\n\r", ' ', 'g')
  let argsmap.text = substitute(argsmap.text, '\v^\s+', '', '')
  let argsmap.text = substitute(argsmap.text, '\v\s+$', '', '')
  if argsmap.text == ''
    return [v:null, v:false]
  else
    let argsmap.text = shellescape(argsmap.text)
  endif

  " Reverse translation
  if a:bang ==# '!'
    if argsmap.source_lang ==# 'auto'
      let msg = 'reverse translate is not possible with "auto" target_lang'
      call translator#util#show_msg(msg, 'error')
      return [v:null, v:false]
    endif
    let tmp = argsmap.source_lang
    let argsmap.source_lang = argsmap.target_lang
    let argsmap.target_lang = tmp
  endif

  if g:translator_debug_mode
    call add(g:translator_log, printf('- argsmap: %s', argsmap))
  endif
  return [argsmap, v:true]
endfunction

function! translator#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let engines = ['baicizhan', 'bing', 'ciba', 'google', 'haici', 'iciba', 'sdcv', 'trans', 'youdao']
  let args_prompt = ['-e', '-t', '-tl', '-sl']

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  if len(args) ==# 1
    if args[0] ==# ''
      return sort(args_prompt)
    else
      let prefix = args[-1]
      let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] ==# prefix')
      return sort(candidates)
    endif
  elseif len(args) > 1
    if args[-1] ==# ''
      if '-e' ==# args[-2]
        return sort(engines)
      elseif '-t' ==# args[-2]
        return
      elseif '-tl' ==# args[-2]
        return
      elseif '-sl' ==# args[-2]
        return
      else
        return sort(engines + args_prompt)
      endif
    else
      let prefix = args[-1]
      let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] ==# prefix')
      return sort(candidates)
    endif
  endif
endfunction
