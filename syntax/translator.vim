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

hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special
hi def link TranslatorPhonetic          Type
hi def link TranslatorExplain           Statement

if g:translator_window_enable_icon
  syntax match TranslatorPhonetic            /\v墳.*$/
  syntax match TranslatorExplain             /\v雷.*/
else
  syntax region TranslatorExplain  concealends matchgroup=Keyword start=#_\*_# end=#$#
  syntax region TranslatorPhonetic concealends matchgroup=Keyword start=#_+_# end=#$#
  setlocal conceallevel=3
endif

syntax match TranslatorQuery               /\v⟦.*⟧/
syntax match TranslatorDelimiter           /\v\─.*\─/

let b:current_syntax = 'translator'
