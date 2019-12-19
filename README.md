# vim-translate-me

[@English Readme@](./README_en.md)

Vim/Neovim 翻译插件

<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60756783-78fb7600-a034-11e9-8e3c-e9d098910077.gif" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60756784-79940c80-a034-11e9-8eec-401eab18a23a.gif" width=800>
</div>
<div align="center">
	<img src="https://user-images.githubusercontent.com/20282795/60757869-c1ba2b80-a042-11e9-8e81-80a2bbfa1427.PNG" width=800>
</div>

## 安装

```vim
Plug 'voldikss/vim-translate-me'
```

## 特性

- 浮窗支持(floating & popup)
- 不会阻塞当前编辑
- 多个可选翻译引擎
- 保存和导出查询记录
- 支持代理(http, socks4, socks5)
- 不需要 appid/appkey

## 配置

#### **`g:vtm_default_mapping`**

> 是否使用默认快捷键

- 默认：`1`

#### **`g:vtm_target_lang`**

> 默认翻译的目标语言

- 可选：参考[各 engine 支持语言列表](https://github.com/voldikss/vim-translate-me/wiki)

- 默认：`'zh'`

#### **`g:vtm_default_engines`**

> 默认翻译接口

- 可选：`'bing'`, `'ciba'`, `'google'`(可直连), `youdao`。可选多个

- 默认：`['ciba', 'youdao']`

#### **`g:vtm_proxy_url`**

> 代理地址，如 `let g:vtm_proxy_url = 'socks5://127.0.0.1:1080'`

- 默认：`''`

#### **`g:vtm_history_enable`**

> 是否保存查询历史记录

- 默认：0

#### **`g:vtm_history_count`**

> 保存查询记录的数目

- 默认：5000

#### **`g:vtm_history_dir`**

> 历史记录文件的目录

- 默认：插件根目录

#### **`g:vtm_popup_max_width`**

> 弹窗的最大宽度

- 默认：`0.6*&columns`

#### **`g:vtm_popup_max_height`**

> 弹窗的最大高度

- 默认：`0.6*&lines`

## 快捷键

- 默认快捷键

  ```vim
  " <Leader>t 翻译光标下的文本，在命令行回显
  nmap <silent> <Leader>t <Plug>Translate
  vmap <silent> <Leader>t <Plug>TranslateV
  " Leader>w 翻译光标下的文本，在窗口中显示
  nmap <silent> <Leader>w <Plug>TranslateW
  vmap <silent> <Leader>w <Plug>TranslateWV
  " Leader>r 替换光标下的文本为翻译内容
  nmap <silent> <Leader>r <Plug>TranslateR
  vmap <silent> <Leader>r <Plug>TranslateRV
  ```

- 再次使用`<Leader>w`，光标跳到翻译窗口

- 按 `q` 键关闭翻译窗口

## 命令

#### `:Translate [-e engine] [-w word] [-l to_lang]`

使用 `engine` 将单词 `word` 翻译为目标语言 `to_lang`并在命令行回显

如果未指定 `engine`，使用 `g:vtm_default_engines`

如果未指定 `word`, 使用光标下单词

如果未指定 `to_lang`, 使用 `g:vtm_target_lang`

#### `:TranslateW [-e engine] [-w word] [-l to_lang]`

用法同上，但在窗口中显示

#### `:TranslateR [-e engine] [-w word] [-l to_lang]`

用法同上，但会用翻译内容替换光标下单词

#### `:TranslateH`

导出历史记录

## 颜色高亮

下面是默认高亮配置，使用 `hi link` 配置自己喜欢的高亮

```vim
hi def link vtmQuery             Identifier
hi def link vtmParaphrase        Statement
hi def link vtmPhonetic          Special
hi def link vtmExplain           Comment
hi def link vtmPopupNormal       NormalFloat
```

## References

- [dict.vim](https://github.com/iamcco/dict.vim)
- [translator](https://github.com/skywind3000/translator)

## License

MIT
