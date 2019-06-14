" @Author: voldikss
" @Date: 2019-06-14 23:23:02
" @Last Modified by: voldikss
" @Last Modified time: 2019-06-14 23:50:51

if exists('b:current_syntax')
    finish
endif

syn match vtmDataExplain #\t\(.*\)$#
" where is non-greedy mode in vimL?
syn match vtmDataQuery   #^\(.*\)\t# contains=vtmDataExplain

hi def link vtmDataQuery      Keyword 
hi def link vtmDataExplain    String

let b:current_syntax = 'vtm_data'
