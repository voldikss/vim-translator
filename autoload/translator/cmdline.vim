" ============================================================================
" FileName: cmdline.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#cmdline#parse_args(argstr) abort
  if g:translator_debug_mode
    call add(g:translator_log, printf('- cmdline args: %s', a:argstr))
  endif
  let argmap = {
    \ 'engines': [],
    \ 'word': '',
    \ 'target_lang': '',
    \ 'source_lang': ''
    \ }
  let flag = ''
  for arg in split(a:argstr, ' ')
    if index(['-e', '--engines'], arg) >= 0
      let flag = 'engines'
    elseif index(['-w', '--word'], arg) >= 0
      let flag = 'word'
    elseif index(['-tl', '--target_lang'], arg) >= 0
      let flag = 'target_lang'
    elseif index(['-sl', '--source_lang'], arg) >= 0
      let flag = 'source_lang'
    else
      if flag ==# 'word'
        let argmap[flag] .= arg . ' '
      elseif flag ==# 'target_lang'
        let argmap[flag] = arg
      elseif flag ==# 'source_lang'
        let argmap[flag] = arg
      elseif flag ==# 'engines'
        call add(argmap.engines, arg)
      else
        return [argmap, v:false]
      endif
    endif
  endfor

  if translator#util#safe_trim(argmap.word) ==# ''
    let argmap.word= translator#util#safe_trim(expand('<cword>'))
  endif

  let argmap.word = substitute(argmap.word, '[\n\|\r]\+', '. ', 'g')
  let argmap.word = translator#util#safe_trim(argmap.word)
  if argmap.word ==# ''
    return [argmap, v:false]
  endif

  if argmap.engines == []
    let argmap.engines = g:translator_default_engines
  endif

  if argmap.target_lang ==# ''
    let argmap.target_lang = g:translator_target_lang
  endif

  if argmap.source_lang ==# ''
    let argmap.source_lang = g:translator_source_lang
  endif

  return [argmap, v:true]
endfunction

function! translator#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let engines = ['bing', 'ciba', 'google', 'youdao', 'trans']
  let args_prompt = ['-e', '--engines', '-w', '--word', '-tl', '--target_lang', '-sl', '--source_lang']

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
      if index(['-e', '--engines'], args[-2]) >= 0
        return sort(engines)
      elseif index(['-w', '--word'], args[-2]) >= 0
        return
      elseif index(['-tl', '--target_lang'], args[-2]) >= 0
        return
      elseif index(['-sl', '--source_lang'], args[-2]) >= 0
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
