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
- [References](#references)
- [License](#license)

## Installation

```vim
Plug 'voldikss/vim-translator'
```

## Features

- Asynchronous & mutithreading translating
- Popup(vim8) & floatwin(neovim) support
- Multiple engines: see [g:translator_default_engines](#gtranslator_default_engines)
- Save and export translation history
- Proxy support
- No requirements for appid/appkey

## Configuration

#### **`g:translator_target_lang`**

> Target language

- Available: Please refer to [language support list](https://github.com/voldikss/vim-translator/wiki)

- Default: `'zh'`

#### **`g:translator_source_lang`**

> Source language

- Available: Please refer to [language support list](https://github.com/voldikss/vim-translator/wiki)

- Default: `'auto'`

#### **`g:translator_default_engines`**

- Available: `'baicizhan'`, `'bing'`, `'google'`, `'haici'`, `'iciba'`, `'sdcv'`, `'trans'`, `'youdao'`

- Default: If `g:translator_target_lang` is `'zh'`, `['baicizhan', 'bing', 'google', 'haici', 'youdao']`, otherwise `['google']`

#### **`g:translator_proxy_url`**

> e.g. `let g:translator_proxy_url = 'socks5://127.0.0.1:1080'`

- Default: `''`

#### **`g:translator_history_enable`**

- Default: `v:false`

#### **`g:translator_window_type`**

- Available: `'popup'`(use floatwin in nvim or popup in vim), `'preview'`

- Default: `'popup'`

#### **`g:translator_window_max_width`**

> Type `int` (number of columns) or `float` (between 0 and 1). If `float`, the width is relative to `&columns`. Default: `0.6`

- Default: `0.6`

#### **`g:translator_window_max_height`**

> Type `int` (number of columns) or `float` (between 0 and 1). If `float`, the height is relative to `&lines`. Default: `0.6`

- Default: `0.6`

#### **`g:translator_window_borderchars`**

> Disable window border will be disabled by setting `g:translator_window_borderchars` to `[]`

- Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

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

Once the translation window is opened, type `<Leader>w` again to jump into it and again to jump back

## Commands

#### `:Translate[!] [engines=] [target_lang=] [source_lang=] [your text]`

Translate the `text` from the source language `source_lang` to the target language `target_lang` with `engine`, echo the result in the cmdline

If no `engines`, use `g:translator_default_engines`

If no `text`, use the text under the cursor

If no `target_lang`, use `g:translator_target_lang`

The command can also be passed to a range, i.e., `:'<,'>Translate ...`, which translates text in visual selection

If `!` is included, the plugin will perform a reverse translating by switching `target_lang` and `source_lang`

Examples(you can use `<Tab>` to get completion):

```vim
:Translate                                  " translate the word under the cursor
:Translate engines=google,youdao are you ok " translate text `are you ok` using google and youdao engines
:2Translate ...                             " translate line 2
:1,3Translate ...                           " translate line 1 to line 3
:'<,'>Translate ...                         " translate selected lines
```

#### `:TranslateW[!] [engines=] [target_lang=] [source_lang=] [your text]`

Like `:Translate...`, but display the translation in a window

#### `:TranslateR[!] [engines=] [target_lang=] [source_lang=] [your text]`

Like `:Translate...`, but replace the current text with the translation

#### `:TranslateX [engines=] [target_lang=] [source_lang=]`

Translate the text in the clipboard

#### `:TranslateH`

Export the translation history

#### `:TranslateL`

Display log

## Highlight

Here are the default highlight links. To customize, use `hi` or `hi link`

```vim
" Text highlight of translator window
hi def link TranslatorQuery             Identifier
hi def link TranslatorDelimiter         Special
hi def link TranslatorExplain           Statement

" Background of translator window border
hi def link TranslatorNF                NormalFloat
hi def link TranslatorBorderNF          NormalFloat
```

## Statusline

- `g:translator_status`

## Known bugs

- Can not translate sentences(because there are some spaces among words) in Vim8(see [#24](https://github.com/voldikss/vim-translator/issues/24))

## FAQ

- ### Can not find python executable?

  Set `g:python3_host_prog` variable in your vimrc. e.g.

  ```vim
  let g:python3_host_prog = /path/to/python_executable
  ```

## References

- [dict.vim](https://github.com/iamcco/dict.vim)
- [translator](https://github.com/skywind3000/translator)

## License

MIT
