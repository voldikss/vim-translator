" ============================================================================
" FileName: translator.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:py_file = expand('<sfile>:p:h') . '/../script/translator.py'

if !exists('s:python_executable')
  if exists('g:python3_host_prog')
    let s:python_executable = g:python3_host_prog
  elseif executable('python3')
    let s:python_executable = 'python3'
  elseif executable('python')
    let s:python_executable = 'python'
  else
    call translator#util#show_msg('python is required but not found', 'error')
    finish
  endif
endif

if stridx(s:python_executable, ' ') >= 0
  let s:python_executable = shellescape(s:python_executable)
endif
if stridx(s:py_file, ' ') >= 0
  let s:py_file = shellescape(s:py_file)
endif

function! translator#start(method, bang, range, line1, line2, argstr) abort
  call translator#debug#init()

  " jump to popup or close popup
  if a:method ==# 'window'
    if &filetype ==# 'translator'
      hide
      return
    elseif translator#ui#try_jump_into()
      return
    endif
  endif

  " parse arguments
  let [text, engines, tl, sl] = translator#cmdline#parse(a:bang, a:range, a:line1, a:line2, a:argstr)
  if empty(text)
    return
  endif

  call translator#translate(text, engines, tl, sl, a:method)
endfunction

function! translator#translate(text, engines, tl, sl, method) abort
  let cmd = printf('%s %s', s:python_executable, s:py_file)
  let cmd .= printf(' --text %s', a:text)
  let cmd .= printf(' --engines %s', a:engines)
  let cmd .= printf(' --target_lang %s', a:tl)
  let cmd .= printf(' --source_lang %s', a:sl)
  if g:translator_proxy_url != v:null
    let cmd .= printf(' --proxy %s', g:translator_proxy_url)
  endif
  if match(a:engines, 'trans') >= 0
    let cmd .= printf(" --options='%s'", join(g:translator_translate_shell_options, ','))
  endif

  call translator#debug#info(cmd)
  call translator#job#job_start(cmd, a:method)
  let g:translator_status = 'translating'
endfunction
