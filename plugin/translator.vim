" ============================================================================
" FileName: translator.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

if exists('g:loaded_translator')
  finish
endif
let g:loaded_translator= 1

let g:translator_history_enable          = get(g:, 'translator_history_enable', v:false)
let g:translator_proxy_url               = get(g:, 'translator_proxy_url', '')
let g:translator_source_lang             = get(g:, 'translator_source_lang', 'auto')
let g:translator_target_lang             = get(g:, 'translator_target_lang', 'zh')
let g:translator_translate_shell_options = get(g:, 'translator_translate_shell_options', [])
let g:translator_window_borderchars      = get(g:, 'translator_window_borderchars', ['─', '│', '─', '│', '┌', '┐', '┘', '└'])
let g:translator_window_max_height       = get(g:, 'translator_window_max_height', 999)
let g:translator_window_max_width        = get(g:, 'translator_window_max_width', 999)
let g:translator_window_type             = get(g:, 'translator_window_type', 'popup')

if match(g:translator_target_lang, 'zh') >= 0
  let g:translator_default_engines = get(g:, 'translator_default_engines', ['bing', 'google', 'haici', 'youdao'])
else
  let g:translator_default_engines = get(g:, 'translator_default_engines', ['google'])
endif

let g:translator_status = ''

nnoremap <silent> <Plug>Translate   :Translate<CR>
vnoremap <silent> <Plug>TranslateV  :Translate<CR>
nnoremap <silent> <Plug>TranslateW  :TranslateW<CR>
vnoremap <silent> <Plug>TranslateWV :TranslateW<CR>
nnoremap <silent> <Plug>TranslateR  viw:<C-u>TranslateR<CR>
vnoremap <silent> <Plug>TranslateRV :TranslateR<CR>
nnoremap <silent> <Plug>TranslateX  :TranslateX<CR>

command! -complete=customlist,translator#cmdline#complete -nargs=* -bang -range
  \ Translate
  \ call translator#start('echo', <bang>0, <range>, <line1>, <line2>, <q-args>)

command! -complete=customlist,translator#cmdline#complete -nargs=* -bang -range
  \ TranslateW
  \ call translator#start('window', <bang>0, <range>, <line1>, <line2>, <q-args>)

command! -complete=customlist,translator#cmdline#complete -nargs=* -bang -range
  \ TranslateR
  \ call translator#start('replace', <bang>0, <range>, <line1>, <line2>, <q-args>)

command! -complete=customlist,translator#cmdline#complete -nargs=* -bang -range
  \ TranslateX
  \ call translator#start('echo', <bang>0, <range>, <line1>, <line2>, <q-args> . ' ' . @*)

command! -nargs=0   TranslateH call translator#history#export()

command! -nargs=0   TranslateL call translator#logger#open_log()
