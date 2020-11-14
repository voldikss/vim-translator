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

function! translator#start(displaymode, bang, range, line1, line2, argstr) abort
  call translator#logger#init()
  let options = translator#cmdline#parse(a:bang, a:range, a:line1, a:line2, a:argstr)
  if options is v:null | return | endif
  call translator#translate(options, a:displaymode)
endfunction

function! translator#translate(options, displaymode) abort
  let cmd = printf(
    \ '%s %s --text %s --engines %s --target_lang %s --source_lang %s',
    \ s:python_executable,
    \ s:py_file,
    \ a:options.text,
    \ a:options.engines,
    \ a:options.target_lang,
    \ a:options.source_lang
    \ )
  if !empty(g:translator_proxy_url)
    let cmd .= printf(' --proxy %s', g:translator_proxy_url)
  endif
  if match(a:options.engines, 'trans') >= 0
    let cmd .= printf(" --options='%s'", join(g:translator_translate_shell_options, ','))
  endif

  call translator#logger#log(cmd)
  call translator#job#jobstart(cmd, a:displaymode)
  let g:translator_status = 'translating'
endfunction
