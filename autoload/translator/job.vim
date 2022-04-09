" ============================================================================
" FileName: job.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

if has('nvim')
  function! s:on_stdout_nvim(type, jobid, data, event) abort
    call s:start(a:type, a:data, a:event)
  endfunction

  function! s:on_exit_nvim(jobid, code, event) abort
  endfunction
else
  function! s:on_stdout_vim(type, event, ch, msg) abort
    call s:start(a:type, a:msg, a:event)
  endfunction

  function! s:on_exit_vim(ch, code) abort
  endfunction
endif

function! translator#job#jobstart(cmd, type) abort
  let g:translator_status = 'translating'
  let s:stdout_save = {}
  if has('nvim')
    let callback = {
          \ 'on_stdout': function('s:on_stdout_nvim', [a:type]),
          \ 'on_stderr': function('s:on_stdout_nvim', [a:type]),
          \ 'on_exit': function('s:on_exit_nvim')
          \ }
    call jobstart(a:cmd, callback)
  else
    let callback = {
          \ 'out_cb': function('s:on_stdout_vim', [a:type, 'stdout']),
          \ 'err_cb': function('s:on_stdout_vim', [a:type, 'stderr']),
          \ 'exit_cb': function('s:on_exit_vim'),
          \ 'out_io': 'pipe',
          \ 'err_io': 'pipe',
          \ 'in_io': 'null',
          \ 'out_mode': 'nl',
          \ 'err_mode': 'nl',
          \ 'timeout': '2000'
          \ }
    call job_start(join(a:cmd,' '), callback)
  endif
endfunction

function! s:start(type, data, event) abort
  let g:translator_status = ''
  " Nvim will return a v:t_list, while Vim will return a v:t_string
  if type(a:data) == 3
    let message = join(a:data, ' ')
  else
    let message = a:data
  endif

  " On Nvim, this function will be executed twice, firstly it returns data, and then an empty string
  " Check the data value in order to prevent overlap
  if translator#util#safe_trim(message) == '' | return | endif
  call translator#logger#log(message)

  " 1. remove `u` before strings
  let message = substitute(message, '\(: \|: [\|{\)\(u\)\("\)', '\=submatch(1).submatch(3)', 'g')
  let message = substitute(message, "\\(: \\|: [\\|{\\)\\(u\\)\\('\\)", '\=submatch(1).submatch(3)', 'g')
  let message = substitute(message, "\\([: \\|: \[]\\)\\(u\\)\\('\\)", '\=submatch(1).submatch(3)', 'g')
  " 2. convert hex code to normal chars
  let message = substitute(message, '\\u\(\x\{4\}\)', '\=nr2char("0x".submatch(1),1)', 'g')
  call translator#logger#log(message)

  if a:event == 'stdout'
    let translations = eval(message)
    if type(translations) != 4 && !translations['status']
      call translator#util#show_msg('Translation failed', 'error')
    endif

    let s:stdout_save = translations
    if a:type == 'echo'
      call translator#action#echo(translations)
    elseif a:type == 'window'
      call translator#action#window(translations)
    else
      call translator#action#replace(translations)
    endif
    call translator#history#save(translations)
  elseif a:event == 'stderr'
    call translator#util#show_msg(message, 'error')
    if !empty(s:stdout_save) && a:type == 'echo'
      call translator#action#echo(s:stdout_save)
    endif
  endif
endfunction
