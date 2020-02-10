" ============================================================================
" FileName: ui.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

if has('nvim') && exists('*nvim_win_set_config')
  let s:wintype = 'floating'
elseif has('textprop') && has('patch-8.1.1522')
  let s:wintype = 'popup'
else
  let s:wintype = 'preview'
endif

function! translator#ui#window(translations) abort
  let linelist = s:build_lines(a:translations)
  let max_height =
    \ g:translator_window_max_height ==# v:null
    \ ? float2nr(0.6*&lines)
    \ : float2nr(g:translator_window_max_height)
  let max_width =
    \ g:translator_window_max_width ==# v:null
    \ ? float2nr(0.6*&columns)
    \ : float2nr(g:translator_window_max_width)
  let [width, height] = s:get_floatwin_size(linelist, max_width, max_height)
  let [y_offset, x_offset, vert, hor, width, height] = s:get_floatwin_pos(width, height)

  let linelist = s:fit_lines(linelist, width)

  if s:wintype ==# 'floating'
    let pos = win_screenpos('.')
    let y_pos = pos[0] + winline() - 1
    let x_pos = pos[1] + wincol() - 1

    let yy_offset = vert ==# 'N' ? 1 : -1
    let xx_offset = hor ==# 'W' ? 1 : -1
    let opts = {
      \ 'relative': 'editor',
      \ 'anchor': vert . hor,
      \ 'row': y_pos + y_offset + yy_offset,
      \ 'col': x_pos + x_offset + xx_offset,
      \ 'width': width,
      \ 'height': height,
      \ 'style':'minimal'
      \ }
    if g:translator_window_borderchars is v:null
      let opts.row -= yy_offset
      let opts.col -= xx_offset
      let opts.width += 2
    endif
    let s:translator_bufnr = s:nvim_create_buf(linelist, 'translator')
    let translator_winid = nvim_open_win(s:translator_bufnr, v:false, opts)
    call nvim_win_set_option(translator_winid, 'wrap', v:true)
    call nvim_win_set_option(translator_winid, 'winhl', 'NormalFloat:TranslatorNF')
    call nvim_win_set_option(translator_winid, 'conceallevel', 3)

    if g:translator_window_borderchars is v:null
      call nvim_win_set_option(translator_winid, 'foldcolumn', 1)
      call nvim_win_set_option(translator_winid, 'winhl', 'FoldColumn:TranslatorNF')
    endif

    if g:translator_window_borderchars isnot v:null
      let border_opts = {
        \ 'relative': 'editor',
        \ 'anchor': vert . hor,
        \ 'row': y_pos + y_offset,
        \ 'col': x_pos + x_offset,
        \ 'width': width + 2,
        \ 'height': height + 2,
        \ 'style':'minimal'
        \ }
      let top = g:translator_window_borderchars[4] .
              \ repeat(g:translator_window_borderchars[0], width) .
              \ g:translator_window_borderchars[5]
      let mid = g:translator_window_borderchars[3] .
              \ repeat(' ', width) .
              \ g:translator_window_borderchars[1]
      let bot = g:translator_window_borderchars[7] .
              \ repeat(g:translator_window_borderchars[2], width) .
              \ g:translator_window_borderchars[6]
      let borderlines = [top] + repeat([mid], height) + [bot]
      let s:border_bufnr = s:nvim_create_buf(borderlines, 'translator_border')
      let border_winid = nvim_open_win(s:border_bufnr, v:false, border_opts)
      call nvim_win_set_option(border_winid, 'winhl', 'NormalFloat:TranslatorBorderNF')
    endif

    " Note: this line must be put after creating the border_win!
    let s:translator_winnr = win_id2win(translator_winid)

    augroup translator_close
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:close_translator_window()
      exe 'autocmd BufLeave,BufWipeout,BufDelete <buffer=' . s:translator_bufnr . '> call s:close_translator_window()'
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
      \ 'border': [1, 1, 1, 1],
      \ 'borderhighlight': [
        \ 'TranslatorBorderNF',
        \ 'TranslatorBorderNF',
        \ 'TranslatorBorderNF',
        \ 'TranslatorBorderNF'
      \ ],
      \ 'maxwidth': width,
      \ 'minwidth': width,
      \ 'maxheight': height,
      \ 'minheight': height
      \ }
    if g:translator_window_borderchars isnot  v:null
      let options.borderchars = g:translator_window_borderchars
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
    let s:translator_winnr = winnr()
    let s:translator_bufnr = bufnr() " NOTE: this line must be put after `enew`
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

    augroup translator_close
      autocmd!
      autocmd CursorMoved,CursorMovedI,InsertEnter,BufLeave <buffer> call s:close_translator_window()
    augroup END
  endif
endfunction

""
" Only available for floating winndow and preview window
function! translator#ui#try_jump_into() abort
  if exists('s:translator_bufnr') && bufexists(s:translator_bufnr)
    noautocmd exe s:translator_winnr . ' wincmd w'
    return v:true
  endif
  return v:false
endfunction

function! s:nvim_create_buf(linelist, filetype) abort
  let bufnr = nvim_create_buf(v:false, v:true)
  call nvim_buf_set_lines(bufnr, 0, -1, v:false, a:linelist)
  call nvim_buf_set_option(bufnr, 'filetype', a:filetype)
  return bufnr
endfunction

""
" Close floating or preview window
function! s:close_translator_window() abort
  if exists('s:translator_bufnr') && bufexists(s:translator_bufnr)
    exe 'bw ' . s:translator_bufnr
  endif
  if exists('s:border_bufnr') && bufexists(s:border_bufnr)
    exe 'bw ' . s:border_bufnr
  endif
  if exists('#translator_close')
    autocmd! translator_close * <buffer>
  endif
endfunction

""
" Style always makes me frantic
function! s:build_lines(translations) abort
  if g:translator_window_enable_icon == v:true
    let marker = '• '
  else
    let marker = '_*_ '
  endif

  let content = []
  if len(a:translations['text']) > 30
    let text = a:translations['text'][:30] . '...'
  else
    let text = a:translations['text']
  endif
  call add(content, printf('⟦ %s ⟧', text))

  for t in a:translations['results']
    if empty(t.paraphrase) && empty(t.explain)
      continue
    endif
    call add(content, '')
    call add(content, printf('─── %s ───', t.engine))

    if !empty(t.paraphrase)
      let paraphrase = marker . t.paraphrase
      call add(content, paraphrase)
    endif

    if !empty(t.phonetic)
      let phonetic = marker . printf('[%s]', t.phonetic)
      call add(content, phonetic)
    endif

    if !empty(t.explain)
      for expl in t.explain
        let expl = translator#util#safe_trim(expl)
        if !empty(expl)
          let explain = marker . expl
          call add(content, explain)
        endif
      endfor
    endif
  endfor
  if g:translator_debug_mode
    call add(g:translator_log, printf('build_lines result: %s', string(content)))
  endif
  return content
endfunction

function! s:fit_lines(linelist, width) abort
  for i in range(len(a:linelist))
    let line = a:linelist[i]
    if match(line, '───') ==# 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#padding(a:linelist[i], a:width, '─')
    elseif match(line, '⟦') ==# 0 && a:width > strdisplaywidth(line)
      let a:linelist[i] = translator#util#padding(a:linelist[i], a:width, ' ')
    endif
  endfor
  return a:linelist
endfunction

function! s:get_floatwin_size(translation, max_width, max_height) abort
  let width = 0
  let height = 0

  for line in a:translation
    let line_width = strdisplaywidth(line)
    if line_width > a:max_width
      let width = a:max_width
      let height += line_width / a:max_width + 1
    else
      let width = max([line_width, width])
      let height += 1
    endif
  endfor

  if height > a:max_height
    let height = a:max_height
  endif
  return [width, height]
endfunction

function! s:get_floatwin_pos(width, height) abort
  let pos = win_screenpos('.')
  let y_pos = pos[0] + winline() - 1
  let x_pos = pos[1] + wincol() -1

  let border = (g:translator_window_borderchars is v:null) ? 0 : 2
  let y_margin = 2
  let [width, height] = [a:width, a:height]

  if y_pos + height + border + y_margin <= &lines
    let vert = 'N'
    let y_offset = 0
  elseif y_pos - height -border - y_margin >= 0
    let vert = 'S'
    let y_offset = -1
  elseif &lines - y_pos >= y_pos
    let vert = 'N'
    let y_offset = 0
    let height = &lines - y_pos - border - y_margin
  else
    let vert = 'S'
    let y_offset = -1
    let height = y_pos - border - y_margin
  endif

  if x_pos + a:width + border <= &columns
    let hor = 'W'
    let x_offset = -1
  elseif x_pos - width - border >= 0
    let hor = 'E'
    let x_offset = 0
  elseif &columns - x_pos >= x_pos
    let hor = 'W'
    let x_offset = -1
    let width = &columns - x_pos - border
  else
    let hor = 'E'
    let x_offset = 0
    let width = x_pos - border
  endif

  return [y_offset, x_offset, vert, hor, width, height]
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
