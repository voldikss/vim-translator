" @Author: voldikss
" @Date: 2019-04-27 16:44:10
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 13:35:36

if exists('g:loaded_vtm')
    finish
endif
let g:loaded_vtm= 1

if exists('*nvim_open_win')
    let g:vtm_popup_window = get(g:, 'vtm_popup_window', 'floating')
else
    let g:vtm_popup_window = 'preview'
endif

let g:vtm_preview_position = get(g:, 'vtm_preview_position', 'bo')
let g:vtm_default_api = get(g:, 'vtm_default_api', 'youdao')
let g:vtm_baidu_app_key = get(g:, 'vtm_baidu_app_key', '20190429000292722')
let g:vtm_baidu_app_secret = get(g:, 'vtm_baidu_app_secret', 'sv566pogmFxLFUjaJY4e')
let g:vtm_youdao_app_key = get(g:, 'vtm_youdao_app_key', '70d26c625f056dba')
let g:vtm_youdao_app_secret = get(g:, 'vtm_youdao_app_secret', 'wqbp7g6MloxwmOTUGSkMghnIWxTGOyrp')

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
    command! -nargs=1 Translate call vtm#Translate(<q-args>, 'simple')
endif

if !exists(':TranslateW')
    command! -nargs=1 TranslateW call vtm#Translate(<q-args>, 'complex')
endif
