" ============================================================================
" FileName: ui.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

if g:translator_window_type == 'preview'
  let s:wintype = 'preview'
elseif has('nvim') && exists('*nvim_win_set_config')
  let s:wintype = 'floating'
elseif has('textprop') && has('patch-8.1.1522')
  let s:wintype = 'popup'
endif


function! translator#ui#window(translations) abort
  let linelist = translator#util#build_lines(a:translations)
  let max_width = g:translator_window_max_width
  if type(max_width) == v:t_float | let max_width = max_width * &columns | endif
  let max_width = float2nr(max_width)

  let max_height = g:translator_window_max_height
  if type(max_height) == v:t_float | let max_height = max_height * &lines | endif
  let max_height = float2nr(max_height)

  let [width, height] = translator#neovim#floatwin_size(linelist, max_width, max_height)
  let [y_offset, x_offset, vert, hor, width, height] = translator#neovim#floatwin_pos(width, height)

  let linelist = translator#util#fit_lines(linelist, width)

  if s:wintype ==# 'floating'
    let pos = win_screenpos('.')
    let y_pos = pos[0] + winline() - 1
    let x_pos = pos[1] + wincol() - 1

    let opts = {
      \ 'relative': 'editor',
      \ 'anchor': vert . hor,
      \ 'row': y_pos + y_offset,
      \ 'col': x_pos + x_offset,
      \ 'width': width + 2,
      \ 'height': height,
      \ 'style':'minimal'
      \ }
    let translator_bufnr = translator#neovim#nvim_create_buf(linelist, 'translator')
    call nvim_buf_set_option(translator_bufnr, 'bufhidden', 'wipe')
    let s:translator_winid = nvim_open_win(translator_bufnr, v:false, opts)
    call nvim_win_set_option(s:translator_winid, 'foldcolumn', type(&foldcolumn) == 0 ? 1 : '1')
    call nvim_win_set_option(s:translator_winid, 'wrap', v:true)
    call nvim_win_set_option(s:translator_winid, 'conceallevel', 3)
    call nvim_win_set_option(s:translator_winid, 'winhl', 'NormalFloat:TranslatorNF,FoldColumn:TranslatorNF')
    let s:border_winid = translator#neovim#add_border(s:translator_winid)
    " NOTE: dont use call nvim_set_current_win(s:translator_winid)
    execute win_id2win(s:translator_winid) . 'wincmd w'
    noa wincmd p

    function! s:close_floatwin(...) abort
      if win_getid() == s:translator_winid
        return
      else
        if !empty(getwininfo(s:translator_winid))
          call nvim_win_close(s:translator_winid, v:true)
        endif
        if !empty(getwininfo(s:border_winid))
          call nvim_win_close(s:border_winid, v:true)
        endif
        autocmd! close_translator_floatwin
      endif
    endfunction

    augroup close_translator_floatwin
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call timer_start(200, function('s:close_floatwin'))
    augroup END

  elseif s:wintype ==# 'popup'
    let vert = vert ==# 'N' ? 'top' : 'bot'
    let hor = hor ==# 'W' ? 'left' : 'right'
    let line = vert ==# 'top' ? 'cursor+1' : 'cursor-1'

    let options = {
      \ 'pos': vert . hor,
      \ 'line': line,
      \ 'col': 'cursor',
      \ 'moved': 'any',
      \ 'padding': [0, 0, 0, 0],
      \ 'maxwidth': width,
      \ 'minwidth': width,
      \ 'maxheight': height,
      \ 'minheight': height,
      \ 'filter': function('s:popup_filter'),
      \ }
    if !empty(g:translator_window_borderchars)
      let options.borderchars = g:translator_window_borderchars
      let options.border = [1, 1, 1, 1]
      let options.borderhighlight = ['TranslatorBorderNF']
    endif
    let winid = popup_create('', options)
    let bufnr = winbufnr(winid)
    for l in range(1, len(linelist))
      call setbufline(bufnr, l, linelist[l-1])
    endfor
    call setbufvar(bufnr, '&filetype', 'translator')
    call setbufvar(bufnr, '&spell', 0)
    call setbufvar(bufnr, '&wrap', 1)
    call setbufvar(bufnr, '&number', 1)
    call setbufvar(bufnr, '&relativenumber', 0)
    call setbufvar(bufnr, '&foldcolumn', 0)
    call setwinvar(winid, '&conceallevel', 3)
    call setwinvar(winid, '&wincolor', 'TranslatorNF')
  else
    let curr_pos = getpos('.')
    execute 'noswapfile bo pedit!'
    call setpos('.', curr_pos)
    wincmd P
    execute height+1 . 'wincmd _'
    enew!
    let s:translator_winid = win_getid()
    call append(0, linelist)
    call setpos('.', [0, 1, 1, 0])

    setlocal foldcolumn=1
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal signcolumn=no
    setlocal filetype=translator
    setlocal wrap nospell
    setlocal nonumber norelativenumber
    setlocal noautoindent nosmartindent
    setlocal nobuflisted noswapfile nocursorline
    noautocmd wincmd p

    function! s:close_preview(...) abort
      if win_getid() == s:translator_winid
        return
      else
        if !empty(getwininfo(s:translator_winid))
          execute win_id2win(s:translator_winid) . 'hide'
        endif
        autocmd! close_translator_preview
      endif
    endfunction
    augroup close_translator_preview
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call timer_start(200, function('s:close_preview'))
    augroup END
  endif
endfunction


" Only available for floating winndow and preview window
function! translator#ui#try_jump_into() abort
  if exists('s:translator_winid') && s:winexists(s:translator_winid)
    noautocmd execute win_id2win(s:translator_winid) . 'wincmd w'
    return v:true
  endif
  return v:false
endfunction


function! translator#ui#echo(translations) abort
  let phonetic = ''
  let paraphrase = ''
  let explain = ''

  for t in a:translations['results']
    if !empty(t.phonetic) && empty(phonetic)
      let phonetic = printf('[%s]', t.phonetic)
    endif
    if !empty(t.paraphrase) && empty(paraphrase)
      let paraphrase = t.paraphrase
    endif
    if !empty(t.explain) && empty(explain)
      let explain = join(t.explain, ' ')
    endif
  endfor

  if len(a:translations['text']) > 30
    let text = a:translations['text'][:30] . '...'
  else
    let text = a:translations['text']
  endif
  call translator#util#echo('Function', text)
  call translator#util#echon('Constant', '==>')
  call translator#util#echon('Type', phonetic)
  call translator#util#echon('Normal', paraphrase)
  call translator#util#echon('Normal', explain)
endfunction


function! translator#ui#replace(translations) abort
  for t in a:translations['results']
    if !empty(t.paraphrase)
      let reg_tmp = @a
      let @a = t.paraphrase
      normal! gv"ap
      let @a = reg_tmp
      unlet reg_tmp
      return
    endif
  endfor
  call translator#util#show_msg('No paraphrases for the replacement', 'warning')
endfunction

function! s:winexists(winid) abort
  return !empty(getwininfo(a:winid))
endfunction


" Close floating or preview window
function! s:close_translator_window() abort
  if exists('s:border_winid') && s:winexists(s:border_winid)
    execute win_id2win(s:border_winid) . 'hide'
  endif
  if exists('s:translator_winid') && s:winexists(s:translator_winid)
    execute win_id2win(s:translator_winid) . 'hide'
  endif
  if exists('#translator_close')
    autocmd! translator_close *
  endif
endfunction


" Filter for popup window
function! s:popup_filter(winid, key) abort
  if a:key ==# "\<c-k>"
    call win_execute(a:winid, "normal! \<c-y>")
    return v:true
  elseif a:key ==# "\<c-j>"
    call win_execute(a:winid, "normal! \<c-e>")
    return v:true
  elseif a:key ==# 'q' || a:key ==# 'x'
    return popup_filter_menu(a:winid, 'x')
  endif
  return v:false
endfunction
