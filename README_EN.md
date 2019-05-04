# vim-translate-me

[@中文 README@](./README.md)

A naive translate plugin for Vim/Neovim

Supports floating window(for Neovim currently) and asynchronous run 

## Screenshot

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177114-6aa5a800-6e93-11e9-9ab3-7a6a99bef70e.gif">
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177115-6b3e3e80-6e93-11e9-9a65-7556d5564a28.gif">
</div>

## Installation
 - Make sure you have Python installed

 - Use vim-plug for example:

    ```vim
    Plug 'voldikss/vim-translate-me'
    " and then run
    :PlugInstall
    ```

## Variables
#### **`g:vtm_popup_window`**

> The window that displays the translation

- Available: `'preview'`, `'floating'`

- Default：`floating` if `api-floatwin` was detected, otherwise `'preview'`

#### **`g:vtm_preview_position`**

> If you have set `g:vtm_popup_window` to `'preview'`, this option specifies preview-window's position

- Available: `'to'` indicates the preview-window should be opened on the top of the main window, `'bo'` bottom instead(run `:help to` in vim to get instructions)

- Default: `'bo'`

#### **`g:vtm_default_mapping`**

> Whether to use the default key mapping

- Available: `1` `0` 

- Default: `1`

#### **`g:vtm_youdao_app_key`** & **`g:vtm_youdao_app_secret`**

> `APPKEY` and `APP_SECRET` for [Youdao API](https://ai.youdao.com/doc.s#guide), apply for your own API key or use the built-in one

#### **`g:vtm_baidu_app_key`** & **`g:vtm_baidu_app_secret`**

> `APPKEY` and `APP_SECRET` for [Baidu API](https://api.fanyi.baidu.com/api/trans/product/index), apply for your own API key or use the built-in one

#### **`g:vtm_bing_app_secret_key`**
  
> `APPKEY` and `APP_SECRET` for [Bing API](https://docs.microsoft.com/en-us/azure/cognitive-services/translator/translator-text-how-to-signup), 
>  apply for your own API key or use the built-in one

#### **`g:vtm_yandex_app_secret_key`**
  
> `APPKEY` and `APP_SECRET` for [Yandex API](https://translate.yandex.com/developers/keys), you can apply for your own API key or use the built-in one

#### **`g:vtm_default_to_lang`**
  
> Which language that the text should be translated to

- Available: Please refer to [Supported languages for every API](https://github.com/voldikss/vim-translate-me/wiki)

- Default: `'zh'`

#### **`g:vtm_default_api`**
  
> The default translation API you use

- Available: `'youdao'`, `'baidu'`, `'bing'`, `'yandex'`

- Default: `'baidu'` if `g:vtm_default_to_lang` is set to `'zh'`, otherwise `'bing'`


## Key Mapping

- Here are some default key mappings

    You can also define your own mappings, by remapping `<Leader>d`, `<Leader>w` or `<Leader>r`

    ```vim
    " Type <Leader>t to translate the text under the cursor, print in the cmdline
    nmap <silent> <Leader>t <Plug>Translate
    vmap <silent> <Leader>t <Plug>TranslateV
    " Type <Leader>w to translate the text under the cursor, display in the popup window
    nmap <silent> <Leader>w <Plug>TranslateW
    vmap <silent> <Leader>w <Plug>TranslateWV
    " Type <Leader>r to translate the text under the cursor and replace the text with the translation
    nmap <silent> <Leader>r <Plug>TranslateR
    vmap <silent> <Leader>r <Plug>TranslateRV
    ```

- Type `<Leader>d` again to jump into the popup window or back to the main window
- Type `q` to close the popup window

## Command

#### `:Translate<CR>`

> Run the command without arguments to translate the text under the cursor, print in the cmdline

#### `:Translate <word><CR>`

> Translate `<word>`, print in the cmdline

#### `:Translate <api> <word><CR>`

> Translate `<word>` with specified `<api>`, print in the cmdline. Use <Tab> to complete `<api>` argument

#### `:TranslateW...`

> The same as `:Translate...`, but it displays the translation in the popup window instead

#### `:TranslateR...`

> The same as `:Translate...`, but it replaces the current word with the translation

## Highlight

**Note**: this option is only available in NeoVim

This plugin has set syntax highlight for the popup window by default. 
But you can also specify your own highlight color

Here is the example on which you can just change the color value of each item:

```vim
hi vtmTitle       term=None ctermfg=135 guifg=#AE81FF cterm=bold    gui=bold
hi vtmQuery       term=None ctermfg=161 guifg=#F92672 cterm=bold    gui=bold
hi vtmTrans       term=None ctermfg=118 guifg=#A6E22E cterm=bold    gui=bold
hi vtmPhonetic    term=None ctermfg=193 guifg=#C4BE89 cterm=italic  gui=italic
hi vtmExplain     term=None ctermfg=144 guifg=#00FFFF
hi vtmProperty    term=None ctermfg=161 guifg=#FF00FF cterm=bold    gui=bold
" This item determines the background and foreground of the whole window
hi vtmPopupNormal term=None ctermfg=255 ctermbg=234   guibg=#303030 guifg=#EEEEEE
```


### Credit
@[iamcco](https://github.com/iamcco)

### Todo
- [ ] Allow users to define their own translation functions with other APIs
- [ ] Proxy support, not necessary

### License
MIT
