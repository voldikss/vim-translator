" @Author: voldikss
" @Date: 2019-04-27 9:31:12
" @Last Modified by: voldikss
" @Last Modified time: 2019-04-28 18:20:21

if exists('b:current_syntax')
    finish
endif

if g:vtm_default_to_lang == 'zh'
    " Chinese
    syn match vtmTitle    #^.\{2}：#
    syn match vtmProperty #^\s\{2}[a-z]\{1,4}\.#
    syn match vtmQuery    #查找：.*$#            contains=vtmTitle
    syn match vtmTrans    #翻译：.*$#            contains=vtmTitle
    syn match vtmPhonetic #音标：.*$#            contains=vtmTitle
    syn match vtmExplain  #^\s\{2}.*#            contains=vtmProperty
else
    " English 
    syn match vtmTitle    #^@\(QUERY\|TRANS\|PHONETIC\|EXPLAIN\): #
    syn match vtmProperty #^\s\{2}[a-z]\{1,4}\.#
    syn match vtmQuery    #@QUERY: .*$#          contains=vtmTitle
    syn match vtmTrans    #@TRANS: .*$#          contains=vtmTitle
    syn match vtmPhonetic #@PHONETIC: .*$#       contains=vtmTitle
    syn match vtmExplain  #^\s\{2}.*#            contains=vtmProperty
endif

hi def link vtmTitle         vtmTitleHL
hi def link vtmQuery         vtmQueryHL
hi def link vtmTrans         vtmTransHL
hi def link vtmPhonetic      vtmPhoneticHL
hi def link vtmExplain       vtmExplainHL
hi def link vtmProperty      vtmPropertyHL

hi vtmTitle      term=None ctermfg=135 guifg=#AE81FF cterm=bold   gui=bold
hi vtmQueryHL    term=None ctermfg=161 guifg=#F92672 cterm=bold   gui=bold
hi vtmTransHL    term=None ctermfg=118 guifg=#A6E22E cterm=bold   gui=bold
hi vtmPhoneticHL term=None ctermfg=193 guifg=#C4BE89 cterm=italic gui=italic
hi vtmExplainHL  term=None ctermfg=144 guifg=#00FFFF 
hi vtmPropertyHL term=None ctermfg=161 guifg=#FF00FF cterm=bold   gui=bold

let b:current_syntax = 'vtm'
