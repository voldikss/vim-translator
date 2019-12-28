" @Author: voldikss
" @Date: 2019-04-27 16:44:10
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-30 21:35:52


if exists('g:loaded_translator')
  finish
endif
let g:loaded_translator= 1

let g:translator_target_lang = get(g:, 'translator_target_lang', 'zh')
let g:translator_proxy_url = get(g:, 'translator_proxy_url', v:null)
let g:translator_history_enable = get(g:, 'translator_history_enable', v:false)
let g:translator_window_max_width = get(g:, 'translator_window_max_width', v:null)
let g:translator_window_max_height = get(g:, 'translator_window_max_height', v:null)
let g:translator_window_borderchars = get(g:, 'translator_window_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:translator_window_border_highlight = get(g:, 'translator_window_border_highlight', 'NormalFloat')

" For old variables
function! s:transfer(var1, var2) abort
  if exists(a:var2)
    execute 'let '. a:var1 . '=' . a:var2
  endif
endfunction

call s:transfer('g:translator_target_lang', 'g:vtm_target_lang')
call s:transfer('g:translator_proxy_url', 'g:vtm_proxy_url')
call s:transfer('g:translator_history_enable', 'g:vtm_history_enable')
call s:transfer('g:translator_window_max_width', 'g:vtm_popup_max_width')
call s:transfer('g:translator_window_max_height', 'g:vtm_popup_max_height')
call s:transfer('g:translator_default_mappings', 'g:vtm_default_mapping')

if match(g:translator_target_lang, 'zh') >= 0
  let g:translator_default_engines = get(g:, 'translator_default_engines', ['ciba', 'youdao'])
else
  let g:translator_default_engines = get(g:, 'translator_default_engines', ['google', 'bing'])
endif

nmap <silent> <Plug>Translate   :call translator#translate('-w ' . expand('<cword>'), 'echo', v:false)<CR>
vmap <silent> <Plug>TranslateV  :<C-U>call translator#translate('', 'echo', v:true)<CR>
nmap <silent> <Plug>TranslateW  :call translator#translate('-w ' . expand('<cword>'), 'window', v:false)<CR>
vmap <silent> <Plug>TranslateWV :<C-U>call translator#translate('', 'window', v:true)<CR>
nmap <silent> <Plug>TranslateR  viw:<C-U>call translator#translate('', 'replace', v:false)<CR>
vmap <silent> <Plug>TranslateRV :<C-U>call translator#translate('', 'replace', v:true)<CR>
nmap <silent> <Plug>TranslateH  :call translator#util#export_history()

if !exists(':Translate')
  command! -complete=customlist,translator#cmdline#complete -nargs=* Translate call translator#translate(<q-args>, 'echo', v:false)
endif

if !exists(':TranslateW')
  command! -complete=customlist,translator#cmdline#complete -nargs=* TranslateW call translator#translate(<q-args>, 'window', v:false)
endif

if !exists(':TranslateR')
  command! -complete=customlist,translator#complete -nargs=* TranslateR exec 'normal viw<Esc>' | call translator#translate(<q-args>, 'replace', v:false)
endif

if !exists(':TranslateH')
  command! -nargs=0   TranslateH call translator#util#export_history()
endif
