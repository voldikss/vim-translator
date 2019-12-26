" @Author: voldikss
" @Date: 2019-04-27 9:31:12
" @Last Modified by: voldikss
" @Last Modified time: 2019-07-23 20:35:10

if exists('b:current_syntax')
  finish
endif

syn match TranslatorQuery               /\v⟦.*⟧/
syn match TranslatorParaphrase          /\v⏺.*$/
syn match TranslatorPhonetic            /\v🔉.*$/
syn match TranslatorExplain             /\v⏺.*/
syn match TranslatorDelimiter           /\v\─.*\─/

hi def link TranslatorQuery             Identifier
hi def link TranslatorPhonetic          Type
hi def link TranslatorParaphrase        Statement
hi def link TranslatorExplain           Statement
hi def link TranslatorDelimiter         Special

let b:current_syntax = 'translator'
