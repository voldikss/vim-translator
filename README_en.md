# vim-translate-me

[@中文 README@](./README.md)

A naive translate plugin for Vim/Neovim

Supports floating & popup and asynchronous running

## Screenshot

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177114-6aa5a800-6e93-11e9-9ab3-7a6a99bef70e.gif">
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177115-6b3e3e80-6e93-11e9-9a65-7556d5564a28.gif">
</div>

## Installation

Make sure you have Python(2 or 3)
```vim
Plug 'voldikss/vim-translate-me'
```
## Features

- Async running
- Floating(NeoVim) & popup(Vim) window support
- Multiple translation engines
- Allow to save and export translation history
- Proxy available(http, socks4, socks5)
- Doesn't need appid/appkey


## Configuration

#### **`g:vtm_default_mapping`**

> Whether to use the default key mapping

- Default: `1`

#### **`g:vtm_default_to_lang`**

> Target language

- Available: Please refer to [Supported languages for every engine](https://github.com/voldikss/vim-translate-me/wiki)

- Default: `'zh'`

#### **`g:vtm_default_engine`**

- Available: `'bing'`, `'ciba'`, `'google'`, `'youdao'`

- Default: `'google'`

#### **`g:vtm_proxy_url`**

> Proxy url, for example `let g:vtm_proxy_url = 'socks5://127.0.0.1:1080'`

- Default: `''`

#### **`g:vtm_enable_history`**

> Whether to save the translation history

- Default: 1

#### **`g:vtm_max_history_count`**

- Default: 5000

#### **`g:vtm_history_dir`**

> The history file directory

- Default: Directory of this plugin


## Key Mapping

- Default key mappings
    ```vim
    " Echo translation in the cmdline
    nmap <silent> <Leader>t <Plug>Translate
    vmap <silent> <Leader>t <Plug>TranslateV
    " Display translation in the popup window
    nmap <silent> <Leader>w <Plug>TranslateW
    vmap <silent> <Leader>w <Plug>TranslateWV
    " Replace the text with translation
    nmap <silent> <Leader>r <Plug>TranslateR
    vmap <silent> <Leader>r <Plug>TranslateRV
    ```

- Type `Leader>w` again to jump into the popup window and again to jump back

- Type `q` to close the popup window

## Command

#### `:Translate [[engine] [word]]`

Translate the `word` with `engine`, echo the result in the cmdline

If no `engine`, use `g:vtm_default_engine`

If not `word`, use the word under the text

#### `:TranslateW [[engine] [word]]`

The same as `:Translate...`, display the translation in the popup window

#### `:TranslateR [[engine] [word]]`

The same as `:Translate...`, replace the current word with the translation

#### `:TranslateH`

Export the translation history

## Highlight

**Note**: this option is only available in NeoVim

Here is the default highlight link. To customize, use `hi link`
```vim
hi def link vtmQuery             Identifier
hi def link vtmParaphrase        Statement
hi def link vtmPhonetic          Special
hi def link vtmExplain           Comment
hi def link vtmPopupNormal       NormalFloat
```


## References

- [dict.vim](https://github.com/iamcco/dict.vim)


### License

MIT
