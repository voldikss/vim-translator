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

hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special

hi def link Translator                  Normal
hi def link TranslatorBorder            Normal

let b:current_syntax = 'translator'
