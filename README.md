# vim-translate-me

[@English Readme@](./README_EN.md)

Vim/Neovim 翻译插件

支持悬浮窗口（目前只有Neovim支持）和异步（Vim 8 和 Neovim 都支持）

## 预览

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177114-6aa5a800-6e93-11e9-9ab3-7a6a99bef70e.gif">
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/57177115-6b3e3e80-6e93-11e9-9a65-7556d5564a28.gif">
</div>

## 安装
 - 确保已经安装了 Python(2或3都行)

 - 安装(这里用 vim-plug)

    ```vim
    Plug 'voldikss/vim-translate-me'

    :PlugInstall
    ```

## 变量
#### **`g:vtm_popup_window`**

> 显示翻译内容的窗口

- 可选值： `'preview'`, `'floating'`

- 默认值：如果检测到`floating`特性支持，则为`'floating'`，否则为`'preview'`

#### **`g:vtm_preview_position`**

> 如果`g:vtm_popup_window`为`'preview'`，此选项决定preview 窗口的位置

- 可选值：`'to'` 在顶部，`'bo'` 在底部（`:help to`查看详细说明）

- 默认值：`'bo'`

#### **`g:vtm_default_mapping`**

> 是否使用默认快捷键

- 可选值：`1` `0`

- 默认值：`1`

#### **`g:vtm_youdao_app_key`** & **`g:vtm_youdao_app_secret`**

> 有道 api 的 `APPKEY` 和 `APP_SECRET` ，可以[自己申请](https://ai.youdao.com/doc.s#guide)，也可以使用默认的

#### **`g:vtm_baidu_app_key`** & **`g:vtm_baidu_app_secret`**

> 百度 api 的 `APPKEY` 和 `APP_SECRET` ，可以[自己申请](https://api.fanyi.baidu.com/api/trans/product/index)，也可以使用默认的

#### **`g:vtm_bing_app_secret_key`**
  
> 必应 api 的密钥，可以[自己申请](https://docs.microsoft.com/zh-cn/azure/cognitive-services/translator/translator-text-how-to-signup)，也可以使用默认的

#### **`g:vtm_yandex_app_secret_key`**
  
> Yandex api 的密钥，可以[自己申请](https://translate.yandex.com/developers/keys)，也可以使用默认的

#### **`g:vtm_default_to_lang`**
  
> 默认翻译的目标语言

- 可选值：参考[各 API 支持语言列表](https://github.com/voldikss/vim-translate-me/wiki)

- 默认值：`'zh'`

#### **`g:vtm_default_api`**
  
> 默认使用的翻译接口

- 可选值：`'youdao'`, `'baidu'`, `'bing'`, `yandex`

- 默认值：如果 `g:vtm_default_to_lang` 设置为 `'zh'` 则该项默认为 `'baidu'`，否则为 `'bing'`


## 快捷键

- 默认快捷键

    你也可以自己更改，把 `<Leader>d`, `<Leader>w` 或者 `<Leader>r` 配置为你设置的快捷键

    ```vim
    " <Leader>t 翻译光标下的文本，在命令行回显翻译内容
    nmap <silent> <Leader>t <Plug>Translate
    vmap <silent> <Leader>t <Plug>TranslateV
    " Leader>w 翻译光标下的文本，在窗口中显示翻译内容
    nmap <silent> <Leader>w <Plug>TranslateW
    vmap <silent> <Leader>w <Plug>TranslateWV
    " Leader>r 替换光标下的文本为翻译内容
    nmap <silent> <Leader>r <Plug>TranslateR
    vmap <silent> <Leader>r <Plug>TranslateRV
    ```

- 在翻译窗口打开的情况下，通过 `<Leader>d` 在主窗口和翻译窗口之间跳转
- 在翻译窗口中按 `q` 键关闭窗口

## 命令

#### `:Translate<CR>`

> 命令不带参数执行，翻译当前光标下的单词并在命令行回显

#### `:Translate <word><CR>`

> 翻译单词 `<word>`，并在命令行回显翻译内容

#### `:Translate <api> <word><CR>`

> 使用指定的 `<api>` 翻译单词 `<word>` 并在命令行回显，可用 `<Tab>` 补全 `<api>` 参数

#### `:TranslateW ...`

> 用法同上，但是在窗口中显示翻译内容

#### `:TranslateR ...`

> 用法同上，但是会用翻译内容替换光标下单词

## 颜色高亮

**注意**：此选项仅在 NeoVim 上有效

插件默认定义了一套颜色高亮，你也可以指定你自己的配色

下面是配置示例，你只需要更改每个项目的颜色值即可
```vim
hi vtmTitle       term=None ctermfg=135 guifg=#AE81FF cterm=bold    gui=bold
hi vtmQuery       term=None ctermfg=161 guifg=#F92672 cterm=bold    gui=bold
hi vtmTrans       term=None ctermfg=118 guifg=#A6E22E cterm=bold    gui=bold
hi vtmPhonetic    term=None ctermfg=193 guifg=#C4BE89 cterm=italic  gui=italic
hi vtmExplain     term=None ctermfg=144 guifg=#00FFFF
hi vtmProperty    term=None ctermfg=161 guifg=#FF00FF cterm=bold    gui=bold
" 这一选项决定了窗口整体的前景色和背景色
hi vtmPopupNormal term=None ctermfg=255 ctermbg=234   guibg=#303030 guifg=#EEEEEE
```


## Credit
@[iamcco](https://github.com/iamcco)

## Todo
- [ ] Allow users to define their own translation functions with other APIs
- [ ] Proxy support, not necessary

## License
MIT
