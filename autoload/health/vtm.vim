" @Author: voldikss
" @Date: 2019-04-28 13:32:21
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-20 18:57:36

function! s:check_job() abort
  if exists('*jobstart') || exists('*job_start')
    call health#report_ok('Async is OK')
  else
    call health#report_error('+job feature is required to execute network request')
  endif
endfunction

function! s:check_floating_window() abort
  " vim instead of nvim
  if !has('nvim')
    call health#report_error("Floating window was not supported on Vim")
    return
  endif

  " nvim, but doesn't have floating window
  if !exists('*nvim_open_win')
    call health#report_error(
      \ 'Floating window is missed on the current version Nvim',
      \ 'Upgrade your Nvim to the HEAD of 0.4.0-dev")'
      \ )
    return
  endif

  " has floating window, but different parameters(old version)
  try
    let test_win = nvim_open_win(bufnr('%'), v:false, {
      \ 'relative': 'editor',
      \ 'row': 0,
      \ 'col': 0,
      \ 'width': 1,
      \ 'height': 1,
      \ })
    call nvim_win_close(test_win, v:true)
  catch /^Vim\%((\a\+)\)\=:E119/
    call health#report_error(
      \ 'The newest floating window feature is missed on the current version Nvim',
      \ 'Upgrade your Nvim to the HEAD of 0.4.0-dev")'
      \ )
    return
  endtry

  call health#report_ok('Floating window is OK')
endfunction

function! s:check_python() abort
  if exists('g:python3_host_prog')
    let vtm_python_host = g:python3_host_prog
  elseif executable('python3')
    let vtm_python_host = 'python3'
  elseif executable('python')
    let vtm_python_host = 'python'
  else
    call health#report_error('Python is not executable')
    return
  endif
  call health#report_ok('Using '.vtm_python_host)
endfunction

function! health#vtm#check() abort
  call s:check_job()
  call s:check_floating_window()
  call s:check_python()
endfunction
