# vim-translator

[![Build Status](https://travis-ci.org/voldikss/vim-translator.svg?branch=master)](https://travis-ci.org/voldikss/vim-translator)

Asynchronous translating plugin for Vim/Neovim

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71441598-19596a00-273d-11ea-841e-dc893fc9ae7d.gif" width=900>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71441597-18c0d380-273d-11ea-9248-ae71b2a7ea42.gif" width=900>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71475802-da9ae100-281c-11ea-9eba-c8c4eee04bd9.png" width=900>
</div>

## Installation

```vim
Plug 'voldikss/vim-translator'
```

## Features

- Asynchronous translating
- Floatwin(NeoVim) & popup(Vim8) support
- Multiple engines/languages available
- Allow to save and export translation history
- Proxy available(http, socks4, socks5)
- Doesn't need appid/appkey

## Configuration

#### **`g:translator_target_lang`**

> Target language

- Available: Please refer to [language support for translator API](https://github.com/voldikss/vim-translator/wiki)

- Default: `'zh'`

#### **`g:translator_source_lang`**

> Source language

- Available: Please refer to [language support for translator API](https://github.com/voldikss/vim-translator/wiki)

- Default: `'auto'`

#### **`g:translator_default_engines`**

- Available: `'bing'`, `'ciba'`, `'google'`, `'youdao'`.

- Default: `['ciba', 'youdao']` if `g:translator_target_lang` is `'zh'`, otherwise `['google', 'bing']`

#### **`g:translator_proxy_url`**

> i.e. `let g:translator_proxy_url = 'socks5://127.0.0.1:1080'`

- Default: `v:null`

#### **`g:translator_history_enable`**

- Default: `v:false`

#### **`g:translator_window_max_width`**

> Max width value of the popup/floating window

- Default: `0.6*&columns`

#### **`g:translator_window_max_height`**

> Max height value of popup/floating window

- Default: `0.6*&lines`

#### **`g:translator_window_borderchars`**

- Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:translator_window_enable_icon`**

> Set it to `v:false` if your terminal doesn't support Unicode symbols

- Default: `v:true`

## Key Mappings

This plugin doesn't supply default mappings.

```vim
""" Example configuration
" Echo translation in the cmdline
nmap <silent> <Leader>t <Plug>Translate
vmap <silent> <Leader>t <Plug>TranslateV
" Display translation in a window
nmap <silent> <Leader>w <Plug>TranslateW
vmap <silent> <Leader>w <Plug>TranslateWV
" Replace the text with translation
nmap <silent> <Leader>r <Plug>TranslateR
vmap <silent> <Leader>r <Plug>TranslateRV
```

Once the translation window is opened, type `<Leader>w` again to jump into it and again to jump back

## Commands

#### `:Translate[!] [-e engines] [-w word] [-tl target_lang]`

Translate the `word` to the target language `target_lang` with `engine`, echo the result in the cmdline

If no `engines`, use `g:translator_default_engines`

If no `word`, use the word under the cursor

If no `target_lang`, use `g:translator_target_lang`

If `!` is included, the plugin will perform a reverse translating by switching `target_lang` and `source_lang`

#### `:TranslateW[!] [-e engines] [-w word] [-tl target_lang]`

The same as `:Translate...`, display the translation in a window

#### `:TranslateR[!] [-e engines] [-w word] [-tl target_lang]`

The same as `:Translate...`, replace the current word with the translation

#### `:TranslateH`

Export the translation history

**Example**:

```
:TranslateW -w test -e bing youdao -tl zh
```

## Highlight

Here are the default highlight links. To customize, use `hi link`

```vim
hi def link TranslatorQuery             Identifier
hi def link TranslatorPhonetic          Type
hi def link TranslatorExplain           Statement
hi def link TranslatorDelimiter         Special
```

## Known bugs

Can not translate sentences(which has spaces among words) in Vim8

## References

- [dict.vim](https://github.com/iamcco/dict.vim)
- [translator](https://github.com/skywind3000/translator)

### License

MIT
