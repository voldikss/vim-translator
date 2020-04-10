" ============================================================================
" FileName: translator.vim
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

if exists('b:current_syntax')
  finish
endif

syntax match TranslatorQuery               /\v⟦.*⟧/
syntax match TranslatorDelimiter           /\v\─.*\─/
syntax match TranslatorExplain             /\v\*.*/ contains=TranslatorPhonetic

hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special
hi def link TranslatorExplain           Statement

hi def link TranslatorNF                NormalFloat
hi def link TranslatorBorderNF          NormalFloat

let b:current_syntax = 'translator'
