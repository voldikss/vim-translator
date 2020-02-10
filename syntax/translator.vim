" ============================================================================
" FileName: translator.vim
" Description:
" Author: voldikss <dyzplus@gmail.com>
" GitHub: https://github.com/voldikss
" ============================================================================

scriptencoding utf-8

if exists('b:current_syntax')
  finish
endif

if g:translator_window_enable_icon
  syntax match TranslatorPhonetic            /\v•\s\[.*\]$/
  syntax match TranslatorExplain             /\v•.*/ contains=TranslatorPhonetic
else
  syntax region TranslatorExplain  concealends matchgroup=Keyword start=#_\*_# end=#$#
  syntax region TranslatorPhonetic concealends matchgroup=Keyword start=#_\*_# end=#$#
  setlocal conceallevel=3
endif

syntax match TranslatorQuery               /\v⟦.*⟧/
syntax match TranslatorDelimiter           /\v\─.*\─/

hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special
hi def link TranslatorPhonetic          Type
hi def link TranslatorExplain           Statement

hi def link TranslatorNF                NormalFloat
hi def link TranslatorBorderNF          NormalFloat

let b:current_syntax = 'translator'
