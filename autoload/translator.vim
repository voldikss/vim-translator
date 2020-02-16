" ============================================================================
" FileName: translator.vim
" Description:
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

function! translator#translate(bang, args, method, visualmode) abort
  " jump to popup or close popup
  if a:method ==# 'window'
    if &filetype ==# 'translator'
      wincmd c
      return
    elseif translator#ui#try_jump_into()
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

  " Reverse translation
  if a:bang ==# '!'
    echom 'reverse'
    if args_obj.source_lang ==# 'auto'
      call translator#util#show_msg('reverse translate is not possible with "auto" target_lang', 'error')
      return
    endif
    let temp = args_obj.target_lang
    let args_obj.target_lang = args_obj.source_lang
    let args_obj.source_lang = temp
  endif
  let cmd = s:python_executable . ' ' . s:py_file
    \ . ' --text '      . shellescape(args_obj.word)
    \ . ' --engines '   . join(args_obj.engines, ' ')
    \ . ' --target_lang '    . args_obj.target_lang
    \ . ' --source_lang '    . args_obj.source_lang
    \ . (g:translator_proxy_url !=# v:null ? (' --proxy ' . g:translator_proxy_url) : '')
    \ . (len(g:translator_translate_shell_options) > 0 ? (" --options='" . join(g:translator_translate_shell_options, ',')) . "'" : '')

  if g:translator_debug_mode
    call add(g:translator_log, printf('- cmd: "%s"', cmd))
  endif
  call translator#job#job_start(cmd, a:method)
endfunction
