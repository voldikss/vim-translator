" ============================================================================
" FileName: popup.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! s:popup_filter(winid, key) abort
  if a:key == "\<c-k>"
    call win_execute(a:winid, "normal! \<c-y>")
    return v:true
  elseif a:key == "\<c-j>"
    call win_execute(a:winid, "normal! \<c-e>")
    return v:true
  elseif a:key == 'q' || a:key == 'x'
    return popup_filter_menu(a:winid, 'x')
  endif
  return v:false
endfunction

function! translator#window#popup#create(linelist, configs) abort
  let options = {
        \ 'pos': a:configs.anchor,
        \ 'col': 'cursor',
        \ 'line': a:configs.anchor[0:2] == 'top' ? 'cursor+1' : 'cursor-1',
        \ 'moved': 'any',
        \ 'padding': [0, 0, 0, 0],
        \ 'maxwidth': a:configs.width - 2,
        \ 'minwidth': a:configs.width - 2,
        \ 'maxheight': a:configs.height,
        \ 'minheight': a:configs.height,
        \ 'filter': function('s:popup_filter'),
        \ 'borderchars' : a:configs.borderchars,
        \ 'border': [1, 1, 1, 1],
        \ 'borderhighlight': ['TranslatorBorder'],
        \ }
  let winid = popup_create('', options)
  call translator#window#init(winid)
  let bufnr = winbufnr(winid)
  call appendbufline(bufnr, 0, a:linelist)
  call translator#buffer#init(bufnr)
endfunction
