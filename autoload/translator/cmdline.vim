" ============================================================================
" FileName: cmdline.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#cmdline#parse(bang, range, line1, line2, argstr) abort
  call translator#logger#log(a:argstr)
  let options = {
        \ 'text': '',
        \ 'engines': [],
        \ 'target_lang': '',
        \ 'source_lang': ''
        \ }
  let arglist = split(a:argstr)
  if !empty(arglist)
    let c = 0
    for arg in arglist
      if arg =~ '^--\S.*=.*$'
        let opt = split(arg, '=')
        if len(opt) != 2
          call translator#util#show_msg('Argument Error: No value given to option: ' . opt[0], 'error')
          return v:null
        endif
        let [key, value] = [opt[0][2:], opt[1]]
        if key == 'engines'
          let options.engines = split(value, ',')
        else
          let options[key] = value
        endif
      else
        let options.text = join(arglist[c:])
        break
      endif
      let c += 1
    endfor
  endif

  if empty(options.text)
    let options.text = translator#util#visual_select(a:range, a:line1, a:line2)
  endif
  let options.text = translator#util#text_proc(options.text)
  if empty(options.text)
    return v:null
  endif

  if empty(options.engines)
    let options.engines = g:translator_default_engines
  endif

  if empty(options.target_lang)
    let options.target_lang = g:translator_target_lang
  endif

  if empty(options.source_lang)
    let options.source_lang = g:translator_source_lang
  endif

  if a:bang && options.source_lang != 'auto'
    let [options.source_lang, options.target_lang] = [options.target_lang, options.source_lang]
  endif

  return options
endfunction

function! translator#cmdline#complete(arg_lead, cmd_line, cursor_pos) abort
  let opts_key = ['--engines=', '--target_lang=', '--source_lang=']
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

  if prefix == ''
    return candidates
  endif

  let engines = ['bing', 'google', 'haici', 'iciba', 'sdcv', 'trans', 'youdao']
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
  elseif match(prefix, '--engines=') > -1
    let candidates = map(engines, {idx -> "--engines=" . engines[idx]})
  endif
  return filter(candidates, 'v:val[:len(prefix) - 1] == prefix')
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
