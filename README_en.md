# vim-translate-me

[@中文 README@](./README.md)

A naive translate plugin for Vim/Neovim

Supports floating & popup and asynchronous running

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

#### **`g:vtm_target_lang`**

> Target language

- Available: Please refer to [Supported languages for every engine](https://github.com/voldikss/vim-translate-me/wiki)

- Default: `'zh'`

#### **`g:vtm_default_engines`**

- Available: `'bing'`, `'ciba'`, `'google'`, `'youdao'`. You can specify more than one engines

- Default: `['google', 'bing']`

#### **`g:vtm_proxy_url`**

> Proxy url, for example `let g:vtm_proxy_url = 'socks5://127.0.0.1:1080'`

- Default: `''`

#### **`g:vtm_history_enable`**

> Whether to save the translation history

- Default: 1

#### **`g:vtm_history_count`**

- Default: 5000

#### **`g:vtm_history_dir`**

> The history file directory

- Default: Directory of this plugin

#### **`g:vtm_popup_max_width`**

> Max-width of the popup/floating window

- Default: 80

#### **`g:vtm_popup_max_height`**

> Max-height of popup/floating window

- Default: 20

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

#### `:Translate [-e engine] [-w word] [-l to_lang]`

Translate the `word` to target language `to_lang` with `engine`, echo the result in the cmdline

If no `engine`, use `g:vtm_default_engines`

If no `word`, use the word under the cursor

If no `to_lang`, use `g:vtm_target_lang`

#### `:TranslateW [-e engine] [-w word] [-l to_lang]`

The same as `:Translate...`, display the translation in the popup window

#### `:TranslateR [-e engine] [-w word] [-l to_lang]`

The same as `:Translate...`, replace the current word with the translation

#### `:TranslateH`

Export the translation history

## Highlight

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

## Screenshots

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60756783-78fb7600-a034-11e9-8e3c-e9d098910077.gif" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60756784-79940c80-a034-11e9-8eec-401eab18a23a.gif" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60757869-c1ba2b80-a042-11e9-8e81-80a2bbfa1427.PNG" width=800>
</div>
