" ============================================================================
" FileName: translator.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

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
