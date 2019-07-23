" @Author: voldikss
" @Date: 2019-04-27 9:31:12
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-23 20:35:10

if exists('b:current_syntax')
    finish
endif

syn match vtmQuery               /\v\@.*\@/
syn match vtmParaphrase          /\v🌀.*$/
syn match vtmPhonetic            /\v🔉.*$/
syn match vtmExplain             /\v📝.*/
syn match vtmDelimiter           /\v\-.*\-/
syn match vtmNormal              /\v.*/ contains=
    \ vtmQuery,vtmParaphrase,vtmPhonetic,vtmExplain,vtmDelimiter

hi def link vtmQuery             Identifier
hi def link vtmParaphrase        Statement
hi def link vtmPhonetic          Special
hi def link vtmExplain           Comment
hi def link vtmFloatingNormal    NormalFloat
hi def link vtmDelimiter         Operator
hi def link vtmNormal            NormalFloat

let b:current_syntax = 'vtm'
