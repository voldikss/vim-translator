" @Author: voldikss
" @Date: 2019-04-24 22:20:55
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-02 07:42:40

let s:py_file = expand('<sfile>:p:h') . '/../script/query.py'
let s:vtm_healthcheck = v:false

if exists('g:python3_host_prog')
  let s:vtm_python_host = g:python3_host_prog
elseif executable('python3')
  let s:vtm_python_host = 'python3'
else
  let s:vtm_python_host = 'python'
endif

function! vtm#translate(args, display, visualmode) abort
  " jump to popup or close popup
  if a:display == 'window'
    if &filetype == 'vtm'
      wincmd c
      return
    elseif vtm#display#try_jump_into()
      return
    endif
  endif

  if !s:vtm_healthcheck
    let s:vtm_healthcheck = vtm#util#healthcheck(s:vtm_python_host)
    if !s:vtm_healthcheck
      return
    endif
  endif

  if a:args == ''
    let select_text = a:visualmode ? vtm#util#visual_select() : expand('<cword>')
    let args = '-w ' . select_text
  else
    let args = a:args
  endif
  let args = substitute(args, '^\s*\(.\{-}\)\s*$', '\1', '')

  let [args_obj, success] = s:parse_args(args)
  if success != v:true
    call vtm#util#show_msg('Arguments error', 'error')
    return
  endif

  let cmd = shellescape(s:vtm_python_host) . ' ' . s:py_file
    \ . ' --text '      . shellescape(args_obj.word)
    \ . ' --engines '    . join(args_obj.engines, ' ')
    \ . ' --toLang '    . args_obj.to_lang
    \ . (len(g:vtm_proxy_url) > 0 ? (' --proxy ' . g:vtm_proxy_url) : '')

  call vtm#query#job_start(cmd, a:display)
endfunction

function! s:parse_args(argstr) abort
  let argmap = {
    \ 'engines': [],
    \ 'word': '',
    \ 'lang': ''
    \ }
  let flag = ''
  for arg in split(a:argstr, ' ')
    if index(['-e', '--engines'], arg) >= 0
      let flag = 'engines'
    elseif index(['-w', '--word'], arg) >= 0
      let flag = 'word'
    elseif index(['-l', '--lang'], arg) >= 0
      let flag = 'lang'
    else
      if flag == 'word'
        let argmap[flag] .= ' ' . arg
      elseif flag == 'lang'
        let argmap[flag] = arg
      elseif flag == 'engines'
        call add(argmap.engines, arg)
      else
        return [argmap, v:false]
      endif
    endif
  endfor

  if vtm#util#safe_trim(argmap.word) == ''
    let argmap.word= vtm#util#safe_trim(expand('<cword>>'))
  endif

  if argmap.word == ''
    return [argmap, v:false]
  endif
  let argmap.word = substitute(argmap.word, '[\n\|\r]\+', '. ', 'g')

  if argmap.engines == []
    let argmap.engines = g:vtm_default_engines
  endif

  if argmap.lang == ''
    let argmap.to_lang = g:vtm_target_lang
  endif

  return [argmap, v:true]
endfunction

function! vtm#complete(arg_lead, cmd_line, cursor_pos) abort
  let engines = ['bing', 'ciba', 'google', 'youdao']
  let args_prompt = ['-e', '--engines', '-w', '--word', '-l', '--lang']

  let cmd_line_before_cursor = a:cmd_line[:a:cursor_pos - 1]
  let args = split(cmd_line_before_cursor, '\v\\@<!(\\\\)*\zs\s+', 1)
  call remove(args, 0)

  if len(args) == 1
    if args[0] == ''
      return sort(args_prompt)
    else
      let prefix = args[-1]
      let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] == prefix')
      return sort(candidates)
    endif
  elseif len(args) > 1
    if args[-1] == ''
      if index(['-e', '--engines'], args[-2]) >= 0
        return sort(engines)
      elseif index(['-w', '--word'], args[-2]) >= 0
        return
      elseif index(['-l', '--lang'], args[-2]) >= 0
        return
      else
        return sort(engines + args_prompt)
      endif
    else
      let prefix = args[-1]
      let candidates = filter(engines+args_prompt, 'v:val[:len(prefix) - 1] == prefix')
      return sort(candidates)
    endif
  endif
endfunction
