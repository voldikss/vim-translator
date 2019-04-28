# vim-translate-me
Vim/Neovim 翻译插件。

支持悬浮窗口（目前只有Neovim支持）和异步（Vim 8 和 Neovim 都支持）

### 预览

![](https://user-images.githubusercontent.com/20282795/56863017-aba94280-69e3-11e9-8002-e6ed8e38d02c.gif)
![](https://user-images.githubusercontent.com/20282795/56863018-aba94280-69e3-11e9-9c4c-d903a80cb893.gif)

### 安装
 - 确保已经安装了 Python(2或3都行)

 - 安装(这里用 vim-plug)

    ```vim
    Plug 'voldikss/vim-translate-me'

    :PlugInstall
    ```

### 用法

#### 变量
- **`g:vtm_popup_window`**

    显示翻译内容的窗口，可选值有 `'preview'` 和 `'floating'`。

    默认如果检测到`floating`特性支持，则为`'floating'`，否则为`'preview'`

- **`g:vtm_preview_position`**

    如果`g:vtm_popup_window`为`'preview'`，此选项决定preview 窗口的位置。

    可选值：`'to'`在顶部，`'bo'`在底部（`:help to`查看详细说明）。

    默认为`'bo'`

- **`g:vtm_youdao_app_key`**
- **`g:vtm_youdao_app_secret`**

    有道 api 的 `APPKEY` 和 `APP_SECRET` ，推荐[自己申请](https://ai.youdao.com/doc.s#guide)，也可以使用内置的（会过期）

#### 快捷键

- 默认快捷键

    你也可以自己更改，把 `<Leader>d`, `<Leader>w` 或者 `<Leader>r` 配置为你设置的快捷键

    ```vim
    " 普通模式，<Leader>d 翻译光标下的文本，在命令行回显翻译内容
    nmap <silent> <Leader>d <Plug>Translate
    " 可视模式，<Leader>d 翻译光标下的文本，在命令行回显翻译内容
    vmap <silent> <Leader>d <Plug>TranslateV
    " 普通模式，<Leader>w 翻译光标下的文本，在窗口中显示翻译内容
    nmap <silent> <Leader>w <Plug>TranslateW
    " 可视模式，<Leader>w 翻译光标下的文本，在窗口中显示翻译内容
    vmap <silent> <Leader>w <Plug>TranslateWV
    " 普通模式，<Leader>r 替换光标下的文本为翻译内容
    nmap <silent> <Leader>r <Plug>TranslateR
    " 可视模式，<Leader>r 替换光标下的文本为翻译内容
    vmap <silent> <Leader>r <Plug>TranslateRV
    ```

- 在翻译窗口打开的情况下，通过 `<Leader>d` 在主窗口和翻译窗口之间跳转
- 在翻译窗口中按 `q` 键关闭窗口

#### 命令
- `:Translate <word>`

    翻译文本，仅在命令行回显翻译内容

- `:TranslateW <word>`

    翻译文本，在窗口显示翻译内容


### Credit
@[iamcco](https://github.com/iamcco)

### Todo
- [ ] Extensable, to be a vim translate manager and support third part translation source 
- [ ] Proxy support
- [ ] Customized highlight

### License
MIT
