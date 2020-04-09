# vim-translator

![CI](https://github.com/voldikss/vim-translator/workflows/CI/badge.svg)

Asynchronous translating plugin for Vim/Neovim

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71441598-19596a00-273d-11ea-841e-dc893fc9ae7d.gif" width=750>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71441597-18c0d380-273d-11ea-9248-ae71b2a7ea42.gif" width=750>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/71475802-da9ae100-281c-11ea-9eba-c8c4eee04bd9.png" width=750>
</div>

## Installation

```vim
Plug 'voldikss/vim-translator'
```

## Features

- Asynchronous & mutithreading translating
- Floatwin(NeoVim) & popup(Vim8) support
- Multiple engines: see [g:translator_default_engines](#g%3Atranslator_default_engines)
- Save and export translation history
- Proxy support(http, socks4, socks5)
- No need for appid/appkey

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

- Available: `'bing'`, `'ciba'`, `'google'`, `'iciba'`, `'sdcv'`, `'trans'`, `'youdao'`,

- Default: `['ciba', 'youdao']` if `g:translator_target_lang` is `'zh'`, otherwise `['google', 'bing']`

#### **`g:translator_proxy_url`**

> e.g. `let g:translator_proxy_url = 'socks5://127.0.0.1:1080'`

- Default: `v:null`

#### **`g:translator_history_enable`**

- Default: `v:false`

#### **`g:translator_window_type`**

- Available: `'popup'`(use floatwin in nvim or popup in vim), `'preview'`

- Default: `'popup'`

#### **`g:translator_window_max_width`**

> Max width value of the popup/floating window

- Default: `0.6*&columns`

#### **`g:translator_window_max_height`**

> Max height value of popup/floating window

- Default: `0.6*&lines`

#### **`g:translator_window_borderchars`**

> Floating window border will be disabled if `g:translator_window_borderchars` is `v:null`

- Default: `['─', '│', '─', '│', '┌', '┐', '┘', '└']`

#### **`g:translator_window_enable_icon`**

> Set it to `v:false` if your terminal doesn't support Unicode symbols

- Default: `v:true`

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
```

Once the translation window is opened, type `<Leader>w` again to jump into it and again to jump back

## Commands

#### `:Translate[!] [-e engines] [-t text] [-tl target_lang] [-sl source_lang]`

Translate the `text` from the source language `source_lang` to the target language `target_lang` with `engine`, echo the result in the cmdline

If no `engines`, use `g:translator_default_engines`

If no `text`, use the text under the cursor

If no `target_lang`, use `g:translator_target_lang`

The command can also be passed to a range, i.e., `:'<,'>Translate ...`, which translates text in visual selection

If `!` is included, the plugin will perform a reverse translating by switching `target_lang` and `source_lang`

#### `:TranslateW[!] [-e engines] [-t text] [-tl target_lang] [-sl source_lang]`

Like `:Translate...`, but display the translation in a window

#### `:TranslateR[!] [-e engines] [-t text] [-tl target_lang] [-sl source_lang]`

Like `:Translate...`, but replace the current text with the translation

#### `:TranslateH`

Export the translation history

**Example**:

```
:TranslateW -t text -e bing youdao -tl zh -sl en
```

## Highlight

Here are the default highlight links. To customize, use `hi` or `hi link`

```vim
" Text highlight of translator window
hi def link TranslatorQuery             Identifier
hi def link TranslatorPhonetic          Type
hi def link TranslatorExplain           Statement
hi def link TranslatorDelimiter         Special

" Background of translator window border
hi def link TranslatorNF                NormalFloat
hi def link TranslatorBorderNF          NormalFloat
```

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
