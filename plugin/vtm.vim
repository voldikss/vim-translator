" @Author: voldikss
" @Date: 2019-04-27 16:44:10
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 13:35:36

if exists('g:loaded_vtm')
    finish
endif
let g:loaded_vtm= 1

let g:vtm_popup_window = get(g:, 'vtm_popup_window', 'floating')
let g:vtm_preview_position = get(g:, 'vtm_preview_position', 'bo')
let g:vtm_baidu_app_key = get(g:, 'vtm_baidu_app_key', '20190429000292722')
let g:vtm_baidu_app_secret = get(g:, 'vtm_baidu_app_secret', 'sv566pogmFxLFUjaJY4e')
let g:vtm_youdao_app_key = get(g:, 'vtm_youdao_app_key', '70d26c625f056dba')
let g:vtm_youdao_app_secret = get(g:, 'vtm_youdao_app_secret', 'wqbp7g6MloxwmOTUGSkMghnIWxTGOyrp')
let g:vtm_bing_app_secret_key = get(g:, 'vtm_bing_app_secret_key', '81d36c3ed9d4472ab270b165d7bfaf65')
let g:vtm_yandex_app_secret_key = get(g:, 'vtm_yandex_app_secret_key', 'trnsl.1.1.20190430T070040Z.b4d258419bc606c3.c91de1b8a30d1e62228a51de3bf0a036160b2293')
let g:vtm_default_to_lang = get(g:, 'vtm_default_to_lang', 'zh')

if g:vtm_default_to_lang == 'zh'
    let g:vtm_default_api = get(g:, 'vtm_default_api', 'baidu')
else
    let g:vtm_default_api = get(g:, 'vtm_default_api', 'bing')
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

nmap <silent> <Plug>Translate   :call vtm#Translate(expand("<cword>"), "simple")<CR>
vmap <silent> <Plug>TranslateV  :<C-U>call vtm#TranslateV("simple")<CR>
nmap <silent> <Plug>TranslateW  :call vtm#Translate(expand("<cword>"), "complex")<CR>
vmap <silent> <Plug>TranslateWV :<C-U>call vtm#TranslateV("complex")<CR>
nmap <silent> <Plug>TranslateR  viw:<C-U>call vtm#TranslateV("replace")<CR>
vmap <silent> <Plug>TranslateRV :<C-U>call vtm#TranslateV("replace")<CR>

if !exists(':Translate')
    command! -complete=customlist,vtm#Complete -nargs=* Translate call vtm#Translate(<q-args>, 'simple')
endif

if !exists(':TranslateW')
    command! -complete=customlist,vtm#Complete -nargs=* TranslateW call vtm#Translate(<q-args>, 'complex')
endif

if !exists(':TranslateR')
    command! -complete=customlist,vtm#Complete -nargs=* TranslateR exec 'normal viw<Esc>' | call vtm#Translate(<q-args>, 'replace')
endif
