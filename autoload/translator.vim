" ============================================================================
" FileName: translator.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:py_file = expand('<sfile>:p:h') . '/../script/translator.py'
let g:translator_log = []

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
if has('win32') || has('win64')
  let s:python_executable = shellescape(s:python_executable)
endif

function! translator#translate(method, visualmode, args, bang, ...) abort
  " jump to popup or close popup
  if a:method ==# 'window'
    if &filetype ==# 'translator'
      hide
      return
    elseif translator#ui#try_jump_into()
      return
    endif
  endif

  if a:0 > 0
    let [argsmap, success] = translator#cmdline#parse(a:visualmode, a:args, a:bang, a:1, a:2, a:3)
  else
    let [argsmap, success] = translator#cmdline#parse(a:visualmode, a:args, a:bang, -1, -1, -1)
  endif
  if success != v:true
    call translator#util#show_msg('Arguments error', 'error')
    return
  endif

  let cmd = s:python_executable . ' ' . s:py_file
    \ . ' --text '        . argsmap.text
    \ . ' --engines '     . argsmap.engines
    \ . ' --target_lang ' . argsmap.target_lang
    \ . ' --source_lang ' . argsmap.source_lang
    \ . (g:translator_proxy_url !=# v:null ? (' --proxy ' . g:translator_proxy_url) : '')
    \ . (match(argsmap.engines, 'trans') >=0 ? (" --options='" . join(g:translator_translate_shell_options, ',')) . "'" : '')

  if g:translator_debug_mode
    call add(g:translator_log, printf('- cmd: "%s"', cmd))
  endif
  call translator#job#job_start(cmd, a:method)
endfunction
