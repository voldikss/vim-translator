" ============================================================================
" FileName: logger.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

let s:log = []

function! translator#logger#init() abort
  let s:log = []
endfunction

function! translator#logger#log(info) abort
  let trace = expand('<sfile>')
  let info = {}
  let info[trace] = a:info
  call add(s:log, info)
endfunction

function! translator#logger#open_log() abort
  bo vsplit vim-translator.log
  setlocal buftype=nofile
  setlocal commentstring=@\ %s
  call matchadd('Constant', '\v\@.*$')
  for log in s:log
    for [k,v] in items(log)
      call append('$', '@' . k)
      if type(v) == v:t_dict
        call append('$', string(v))
      else
        call append('$', v)
      endif
      call append('$', '')
    endfor
  endfor
endfunction
