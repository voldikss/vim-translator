" ============================================================================
" FileName: debug.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" Description:
" ============================================================================

function! translator#debug#open_log() abort
  if !g:translator_debug_mode
    call translator#util#show_msg('Not in debug mode, see `g:translator_debug_mode`', 'warning')
    return
  endif
  let log = []
  call s:add_info(log)
  call s:add_options(log)
  call s:add_log(log)
  bo vsplit vim-translator.log
  setlocal buftype=nofile
  call append(0, log)
endfunction

function! s:add_info(log) abort
  call add(a:log, '## Info')
  call add(a:log, '')
  let vinfo = execute('silent version')
  call add(a:log, printf('- version: %s', split(vinfo, '\n')[0]))
  call add(a:log, printf('- term: %s', $TERM))

  if has("win64") || has("win32")
    let platform = "windows"
  else
    let platform = substitute(system('uname'), '\n', '', '')
  endif
  call add(a:log, printf('- platform: %s', platform))
  call add(a:log, '')
  return a:log
endfunction

function! s:add_options(log) abort
  call add(a:log, '## Options')
  call add(a:log, '')
  call add(a:log, printf('- g:translator_proxy_url: %s', g:translator_proxy_url))
  call add(a:log, printf('- g:translator_target_lang: %s', g:translator_target_lang))
  call add(a:log, printf('- g:translator_source_lang: %s', g:translator_source_lang))
  call add(a:log, printf('- g:translator_history_enable: %s', g:translator_history_enable))
  call add(a:log, printf('- g:translator_window_max_width: %s', g:translator_window_max_width))
  call add(a:log, printf('- g:translator_window_max_height: %s', g:translator_window_max_height))
  call add(a:log, printf('- g:translator_window_borderchars: %s', g:translator_window_borderchars))
  call add(a:log, printf('- g:translator_window_border_highlight: %s', g:translator_window_border_highlight))
  call add(a:log, printf('- g:translator_window_enable_icon: %s', g:translator_window_enable_icon))
  call add(a:log, '')
  return a:log
endfunction

function! s:add_log(log) abort
  if !exists('g:translator_log')
    return
  endif
  call add(a:log, '## Log')
  call add(a:log, '')
  call extend(a:log, g:translator_log)
  call add(a:log, '')
  return a:log
endfunction
