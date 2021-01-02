# vim-translator

![CI](https://github.com/voldikss/vim-translator/workflows/CI/badge.svg)

Asynchronous translating plugin for Vim/Neovim

![](https://user-images.githubusercontent.com/20282795/89249090-e3218880-d643-11ea-83a5-44915445690e.gif)

- [Installation](#installation)
- [Features](#features)
- [Configuration](#configuration)
- [Keymaps](#key-mappings)
- [Commands](#commands)
- [Highlight](#highlight)
- [Statusline](#statusline)
- [Know bugs](#know-bugs)
- [FAQ](#faq)
- [Breaking changes](#breaking-changes)
- [References](#references)
- [License](#license)

## Installation

```vim
Plug 'voldikss/vim-translator'
```

## Features

- Asynchronous & mutithreading translating
- Popupwin(vim8) & floatwin(neovim) support
- Multiple engines: see [g:translator_default_engines](#gtranslator_default_engines)
- Proxy support
- No requirements for appid/appkey

## Configuration

#### **`g:translator_target_lang`**

Type `String`.

Default: `'zh'`

Please refer to [language support list](https://github.com/voldikss/vim-translator/wiki)

#### **`g:translator_source_lang`**

Type `String`.

Default: `'auto'`

Please refer to [language support list](https://github.com/voldikss/vim-translator/wiki)

#### **`g:translator_default_engines`**

Type `List` of `String`.

Available: `'bing'`, `'google'`, `'haici'`, `'iciba'`(expired), `'sdcv'`, `'trans'`, `'youdao'`

Default: If `g:translator_target_lang` is `'zh'`, this will be `['bing', 'google', 'haici', 'youdao']`, otherwise `['google']`

#### **`g:translator_proxy_url`**

Type `String`. Default: `''`

Example: `let g:translator_proxy_url = 'socks5://127.0.0.1:1080'`

#### **`g:translator_history_enable`**

Type `Boolean`.

Default: `v:false`

#### **`g:translator_window_type`**

Type `String`.

Default: `'popup'`

Available: `'popup'`(use floatwin in nvim or popup in vim), `'preview'`

#### **`g:translator_window_max_width`**

Type `Number` (number of columns) or `Float` (between 0 and 1). If `Float`,
the width is relative to `&columns`.

Default: `0.6`

#### **`g:translator_window_max_height`**

Type `Number` (number of lines) or `Float` (between 0 and 1). If `Float`, the
height is relative to `&lines`.

Default: `0.6`

#### **`g:translator_window_borderchars`**

Type `List` of `String`. Characters of the floating window border.

Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

## Key Mappings

This plugin doesn't supply any default mappings.

```vim
""" Configuration example
" Echo translation in the cmdline
nmap <silent> <Leader>t <Plug>Translate
vmap <silent> <Leader>t <Plug>TranslateV
" Display translation in a window
nmap <silent> <Leader>w <Plug>TranslateW
vmap <silent> <Leader>w <Plug>TranslateWV
" Replace the text with translation
nmap <silent> <Leader>r <Plug>TranslateR
vmap <silent> <Leader>r <Plug>TranslateRV
" Translate the text in clipboard
nmap <silent> <Leader>x <Plug>TranslateX
```

Once the translation window is opened, type `<C-w>p` to jump into it and again to jump back

Beside, there is a function which can be used to scroll window, only works in neovim.

```vim
nnoremap <silent><expr> <M-f> translator#window#float#has_scroll() ?
                            \ translator#window#float#scroll(1) : "\<M-f>"
nnoremap <silent><expr> <M-b> translator#window#float#has_scroll() ?
                            \ translator#window#float#scroll(0) : "\<M-f>"
```

## Commands

#### `Translate`

`:Translate[!] [--engines=ENGINES] [--target_lang=TARGET_LANG] [--source_lang=SOURCE_LANG] [your text]`

Translate the `text` from the source language `source_lang` to the target language `target_lang` with `engine`, echo the result in the cmdline

If `engines` is not given, use `g:translator_default_engines`

If `text` is not given, use the text under the cursor

If `target_lang` is not given, use `g:translator_target_lang`

The command can also be passed to a range, i.e., `:'<,'>Translate ...`, which translates text in visual selection

If `!` is provided, the plugin will perform a reverse translating by switching `target_lang` and `source_lang`

Examples(you can use `<Tab>` to get completion):

```vim
:Translate                                  " translate the word under the cursor
:Translate --engines=google,youdao are you ok " translate text `are you ok` using google and youdao engines
:2Translate ...                             " translate line 2
:1,3Translate ...                           " translate line 1 to line 3
:'<,'>Translate ...                         " translate selected lines
```

#### `TranslateW`

`:TranslateW[!] [--engines=ENGINES] [--target_lang=TARGET_LANG] [--source_lang=SOURCE_LANG] [your text]`

Like `:Translate...`, but display the translation in a window

#### `TranslateR`

`:TranslateR[!] [--engines=ENGINES] [--target_lang=TARGET_LANG] [--source_lang=SOURCE_LANG] [your text]`

Like `:Translate...`, but replace the current text with the translation

#### `TranslateX`

`:TranslateX[!] [--engines=ENGINES] [--target_lang=TARGET_LANG] [--source_lang=SOURCE_LANG] [your text]`

Translate the text in the clipboard

#### `TranslateH`

`:TranslateH`

Export the translation history

#### `TranslateL`

`:TranslateL`

Display log message

## Highlight

Here are the default highlight links. To customize, use `hi` or `hi link`

```vim
" Text highlight of translator window
hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special
hi def link TranslatorExplain           Statement

" Background of translator window border
hi def link Translator                  Normal
hi def link TranslatorBorder            NormalFloat
```

## Statusline

- `g:translator_status`

## FAQ

https://github.com/voldikss/vim-translator/issues?q=label%3AFAQ

## Breaking Changes

https://github.com/voldikss/vim-translator/issues?q=label%3A%22breaking+change%22

## References

- [dict.vim](https://github.com/iamcco/dict.vim)
- [translator](https://github.com/skywind3000/translator)

## License

MIT
