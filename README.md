# vim-translate-me
Vim/Neovim 翻译插件

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

    > 显示翻译内容的窗口

    - 可选值： `'preview'`, `'floating'`

    - 默认值：如果检测到`floating`特性支持，则为`'floating'`，否则为`'preview'`

- **`g:vtm_preview_position`**

    > 如果`g:vtm_popup_window`为`'preview'`，此选项决定preview 窗口的位置

    - 可选值：`'to'` 在顶部，`'bo'` 在底部（`:help to`查看详细说明）

    - 默认值：`'bo'`

- **`g:vtm_default_mapping`**

    > 是否使用默认快捷键

    - 可选值：`1` 使用默认快捷键，`0` 不使用默认快捷键

    - 默认值：`1`

- **`g:vtm_youdao_app_key`** & **`g:vtm_youdao_app_secret`**

  > 有道 api 的 `APPKEY` 和 `APP_SECRET` ，可以[自己申请](https://ai.youdao.com/doc.s#guide)，建议不用设置，使用默认值

- **`g:vtm_baidu_app_key`** & **`g:vtm_baidu_app_secret`**

  > 百度 api 的 `APPKEY` 和 `APP_SECRET` ，可以[自己申请](https://api.fanyi.baidu.com/api/trans/product/index)  建议不用设置，使用默认值

- **`g:vtm_default_api`**
  
  > 默认使用的翻译接口

  - 可选值：`'youdao'`, `'baidu'`

  - 默认值：`'youdao'`

- **`g:vtm_default_to_lang`**
  
  > 默认翻译的目标语言

  - 可选值：参考[各 API 支持语言列表](https://github.com/voldikss/vim-translate-me/wiki)

  - 默认值：`'zh'`


#### 快捷键

- 默认快捷键

    你也可以自己更改，把 `<Leader>d`, `<Leader>w` 或者 `<Leader>r` 配置为你设置的快捷键

    ```vim
    " 普通模式，<Leader>d 翻译光标下的文本，在命令行回显翻译内容
    nmap <silent> <Leader>t <Plug>Translate
    " 可视模式，<Leader>d 翻译光标下的文本，在命令行回显翻译内容
    vmap <silent> <Leader>t <Plug>TranslateV
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

- `:Translate<CR>`

    命令不带参数执行，翻译当前光标下的单词并在命令行回显

- `:Translate <word><CR>`

    翻译单词 `<word>`，并在命令行回显翻译内容

- `:Translate <api> <word><CR>`

    使用指定的 `<api>` 翻译单词 `<word>` 并在命令行回显，可用 `<Tab>` 补全 `<api>` 参数

- `:TranslateW`

    用法同上，但是在窗口中显示翻译内容


### Credit
@[iamcco](https://github.com/iamcco)

### Todo
- [ ] Extensable, to be a vim translate manager and support third part translation source 
- [ ] Proxy support
- [ ] Customized highlight

### License
MIT
