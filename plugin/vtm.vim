" @Author: voldikss
" @Date: 2019-04-27 16:44:10
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-30 21:35:52


if exists('g:loaded_vtm')
  finish
endif
let g:loaded_vtm= 1

let g:vtm_target_lang = get(g:, 'vtm_target_lang', 'zh')
let g:vtm_proxy_url = get(g:, 'vtm_proxy_url', '')
let g:vtm_history_enable = get(g:, 'vtm_history_enable', 0)
let g:vtm_history_count = get(g:, 'vtm_history_count', 5000)
let g:vtm_history_dir = get(g:, 'vtm_history_dir', expand('<sfile>:p:h'))
let g:vtm_history_file = g:vtm_history_dir . '/../translation_history.data'
let g:vtm_popup_max_width = get(g:, 'vtm_popup_max_width', v:null)
let g:vtm_popup_max_height = get(g:, 'vtm_popup_max_height', v:null)

if match(g:vtm_target_lang, 'zh') >= 0
  let g:vtm_default_engines = get(g:, 'vtm_default_engines', ['ciba', 'youdao'])
else
  let g:vtm_default_engines = get(g:, 'vtm_default_engines', ['google', 'bing'])
endif

if get(g:, 'vtm_default_mapping', 1)
  if !hasmapto('<Plug>Translate')
    nmap <silent> <Leader>t <Plug>Translate
  endif

  if !hasmapto('<Plug>TranslateV')
    vmap <silent> <Leader>t <Plug>TranslateV
  endif

  if !hasmapto('<Plug>TranslateW')
    nmap <silent> <Leader>w <Plug>TranslateW
  endif

  if !hasmapto('<Plug>TranslateWV')
    vmap <silent> <Leader>w <Plug>TranslateWV
  endif

  if !hasmapto('<Plug>TranslateR')
    nmap <silent> <Leader>r <Plug>TranslateR
  endif

  if !hasmapto('<Plug>TranslateRV')
    vmap <silent> <Leader>r <Plug>TranslateRV
  endif
endif

nmap <silent> <Plug>Translate   :call vtm#translate('-w ' . expand('<cword>'), 'echo')<CR>
vmap <silent> <Plug>TranslateV  :<C-U>call vtm#translate('', 'echo')<CR>
nmap <silent> <Plug>TranslateW  :call vtm#translate('-w ' . expand('<cword>'), 'window')<CR>
vmap <silent> <Plug>TranslateWV :<C-U>call vtm#translate('', 'window')<CR>
nmap <silent> <Plug>TranslateR  viw:<C-U>call vtm#translate('', 'replace')<CR>
vmap <silent> <Plug>TranslateRV :<C-U>call vtm#translate('', 'replace')<CR>

if !exists(':Translate')
  command! -complete=customlist,vtm#complete -nargs=* Translate call vtm#translate(<q-args>, 'echo')
endif

if !exists(':TranslateW')
  command! -complete=customlist,vtm#complete -nargs=* TranslateW call vtm#translate(<q-args>, 'window')
endif

if !exists(':TranslateR')
  command! -complete=customlist,vtm#complete -nargs=* TranslateR exec 'normal viw<Esc>' | call vtm#translate(<q-args>, 'replace')
endif

if !exists(':TranslateH')
  command! -nargs=0   TranslateH call vtm#util#export_history()
endif
