" ============================================================================
" FileName: buffer.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

function! translator#buffer#create_border(configs) abort
  let repeat_width = a:configs.width - 2
  let title_width = strdisplaywidth(a:configs.title)
  let [c_top, c_right, c_bottom, c_left, c_topleft, c_topright, c_botright, c_botleft] = a:configs.borderchars
  let content = [c_topleft . a:configs.title . repeat(c_top, repeat_width - title_width) . c_topright]
  let content += repeat([c_left . repeat(' ', repeat_width) . c_right], a:configs.height-2)
  let content += [c_botleft . repeat(c_bottom, repeat_width) . c_botright]
  let bd_bufnr = translator#buffer#create_scratch_buf(content)
  call nvim_buf_set_option(bd_bufnr, 'filetype', 'translatorborder')
  return bd_bufnr
endfunction

function! translator#buffer#create_scratch_buf(...) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  call nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  call nvim_buf_set_option(bufnr, 'swapfile', v:false)
  call nvim_buf_set_option(bufnr, 'undolevels', -1)
  let lines = get(a:, 1, v:null)
  if type(lines) != 7
    call nvim_buf_set_option(bufnr, 'modifiable', v:true)
    call nvim_buf_set_lines(bufnr, 0, -1, v:false, lines)
    call nvim_buf_set_option(bufnr, 'modifiable', v:false)
  endif
  return bufnr
endfunction

function! translator#buffer#init(bufnr) abort
  call setbufvar(a:bufnr, '&filetype', 'translator')
  call setbufvar(a:bufnr, '&buftype', 'nofile')
  call setbufvar(a:bufnr, '&bufhidden', 'wipe')
  call setbufvar(a:bufnr, '&buflisted', 0)
  call setbufvar(a:bufnr, '&swapfile', 0)
endfunction
