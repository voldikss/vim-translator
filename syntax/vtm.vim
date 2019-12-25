" @Author: voldikss
" @Date: 2019-04-27 9:31:12
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-23 20:35:10

if exists('b:current_syntax')
  finish
endif

syn match vtmQuery               /\v⟦.*⟧/
syn match vtmParaphrase          /\v⏺.*$/
syn match vtmPhonetic            /\v🔉.*$/
syn match vtmExplain             /\v⏺.*/
syn match vtmDelimiter           /\v\─.*\─/

hi def link vtmQuery             Identifier
hi def link vtmPhonetic          Type
hi def link vtmParaphrase        Statement
hi def link vtmExplain           Statement
hi def link vtmDelimiter         Special

let b:current_syntax = 'vtm'
