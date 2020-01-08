" ============================================================================
" FileName: translator.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:py_file = expand('<sfile>:p:h') . '/../script/translator.py'

if !exists('s:python_executable')
  if executable('python3')
    let s:python_executable = 'python3'
  elseif executable('python')
    let s:python_executable = 'python'
  elseif exists('g:python3_host_prog')
    let s:python_executable = g:python3_host_prog
  else
    call translator#util#show_msg('python is required but not found', 'error')
    finish
  endif
endif

function! translator#translate(args, display, visualmode) abort
  " jump to popup or close popup
  if a:display ==# 'window'
    if &filetype ==# 'translator'
      wincmd c
      return
    elseif translator#display#try_jump_into()
      return
    endif
  endif

  if a:args ==# ''
    let select_text = a:visualmode ? translator#util#visual_select() : expand('<cword>')
    let args = '-w ' . select_text
  else
    let args = a:args
  endif
  let args = substitute(args, '^\s*\(.\{-}\)\s*$', '\1', '')

  let [args_obj, success] = translator#cmdline#parse_args(args)
  if success != v:true
    call translator#util#show_msg('Arguments error', 'error')
    return
  endif

  let cmd = s:python_executable . ' ' . s:py_file
    \ . ' --text '      . shellescape(args_obj.word)
    \ . ' --engines '   . join(args_obj.engines, ' ')
    \ . ' --toLang '    . args_obj.target_lang
    \ . ' --fromLang '    . args_obj.source_lang
    \ . (g:translator_proxy_url ? (' --proxy ' . g:translator_proxy_url) : '')

  call translator#job#job_start(cmd, a:display)
endfunction
