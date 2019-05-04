" @Author: voldikss
" @Date: 2019-04-27 9:31:12
" @Last Modified by: voldikss
" @Last Modified time: 2019-05-02 00:07:30

if exists('b:current_syntax')
    finish
endif

if g:vtm_default_to_lang == 'zh'
    " Chinese
    syn match vtmTitle    #^\s.\{2}：#
    syn match vtmProperty #^\s\{3}[a-z]\{1,4}\.#
    syn match vtmQuery    #\s查找：.*$#            contains=vtmTitle
    syn match vtmTrans    #\s翻译：.*$#            contains=vtmTitle
    syn match vtmPhonetic #\s音标：.*$#            contains=vtmTitle
    syn match vtmExplain  #^\s\{3}.*#            contains=vtmProperty
else
    " English 
    syn match vtmTitle    #^\s@\(QUERY\|TRANS\|PHONETIC\|EXPLAIN\): #
    syn match vtmProperty #^\s\{3}[a-z]\{1,4}\.#
    syn match vtmQuery    # @QUERY: .*$#          contains=vtmTitle
    syn match vtmTrans    # @TRANS: .*$#          contains=vtmTitle
    syn match vtmPhonetic # @PHONETIC: .*$#       contains=vtmTitle
    syn match vtmExplain  #^\s\{3}.*#            contains=vtmProperty
endif

hi def vtmTitle       term=None ctermfg=135 guifg=#AE81FF cterm=bold    gui=bold
hi def vtmQuery       term=None ctermfg=161 guifg=#F92672 cterm=bold    gui=bold
hi def vtmTrans       term=None ctermfg=118 guifg=#A6E22E cterm=bold    gui=bold
hi def vtmPhonetic    term=None ctermfg=193 guifg=#C4BE89 cterm=italic  gui=italic
hi def vtmExplain     term=None ctermfg=144 guifg=#00FFFF
hi def vtmProperty    term=None ctermfg=161 guifg=#FF00FF cterm=bold    gui=bold
hi def vtmPopupNormal term=None ctermfg=255 ctermbg=234   guibg=#303030 guifg=#EEEEEE

let b:current_syntax = 'vtm_popup'
