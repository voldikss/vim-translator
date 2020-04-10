" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:parse_args(argstr) abort
  call translator#debug#info(a:argstr)
  let opts = {
    \ 'engines': '',
    \ 'text': '',
    \ 'target_lang': '',
    \ 'source_lang': ''
    \ }

  let arglist = split(a:argstr)
  if !empty(arglist)
    let c = 0
    for arg in arglist
      let opt = split(arg, '=')
      if len(opt) == 1
        let opts.text = join(arglist[c:])
        break
      elseif len(opt) == 2
        if opt[0] == 'engines'
          let opts.engines = substitute(opt[1], ',', ' ', 'g')
        else
          let opts[opt[0]] = opt[1]
        endif
      endif
      let c += 1
    endfor
  endif

  if empty(opts.engines)
    let opts.engines = join(g:translator_default_engines, ' ')
  endif
  if empty(opts.target_lang)
    let opts.target_lang = g:translator_target_lang
  endif
  if empty(opts.source_lang)
    let opts.source_lang = g:translator_source_lang
  endif
  return [opts, v:true]
endfunction

function! translator#cmdline#parse(visualmode, argstr, bang, line1, line2, count) abort
  let [argsmap, success] = s:parse_args(a:argstr)
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

  call translator#debug#info(argsmap)
  return [argsmap, v:true]
endfunction

function! translator#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let opts_key = ['engines=', 'target_lang=', 'source_lang=']
  let candidates = opts_key

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  for key in opts_key
    if match(cmd_line_before_cursor, key) != -1
      let idx = index(candidates, key)
      call remove(candidates, idx)
    endif
  endfor

  let prefix = args[-1]

  if prefix ==# ''
    return candidates
  endif

  let engines = ['baicizhan', 'bing', 'ciba', 'google', 'haici', 'iciba', 'sdcv', 'trans', 'youdao']
  if match(prefix, ',') > -1
    let pos = s:matchlastpos(prefix, ',')
    let preprefix = prefix[:pos]
    let unused_engines = []
    for e in engines
      if match(prefix, e) == -1
        call add(unused_engines, e)
      endif
    endfor
    let candidates = map(unused_engines, {idx -> preprefix . unused_engines[idx]})
  elseif match(prefix, 'engines=') > -1
    let candidates = map(engines, {idx -> "engines=" . engines[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] ==# prefix')
endfunction

function! s:matchlastpos(expr, pat) abort
  let pos = -1
  for i in range(1, 10)
    let p = match(a:expr, a:pat, 0, i)
    if p > pos
      let pos = p
    endif
  endfor
  return pos
endfunction
