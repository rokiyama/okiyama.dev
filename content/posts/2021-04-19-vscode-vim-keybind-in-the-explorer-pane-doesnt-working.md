---
title: VSCode Vim で explorer ペインのキーバインドが使えなくなった時の対処法
date: 2021-04-19T11:52:22+09:00
draft: false
tags: [memo, vscode, vim]
---

[VSCode Vim](http://aka.ms/vscodevim) というエクステンションを入れると vim キーバインドが使える。エディタだけでなく、 explorer ペインでも以下のようなキーバインドが使えるようになる。

- `j`, `k` で選択
- `l`, `h` でツリーの開閉
- `l` でファイルオープン
- `Space` でファイルプレビュー (これは標準機能かも)

ある時これが使えなくなったので調べたところ、以下の二つを設定することで解消した。

- `"workbench.list.keyboardNavigation": "simple"`
- `"workbench.list.automaticKeyboardNavigation": false`

参考: [Navigation in the explorer pane vim way (j , k) doesn't work after window reload](https://github.com/VSCodeVim/Vim/issues/3760)

各設定の意味は以下の通り。

> `workbench.list.keyboardNavigation`
>
> Controls the keyboard navigation style for lists and trees in the workbench. Can be simple, highlight and filter.
>
> - simple: Simple keyboard navigation focuses elements which match the keyboard input. Matching is done only on prefixes.
> - highlight: Highlight keyboard navigation highlights elements which match the keyboard input. Further up and down navigation will traverse only the highlighted elements.
> - filter: Filter keyboard navigation will filter out and hide all the elements which do not match the keyboard input.
>
> `workbench.list.automaticKeyboardNavigation`
>
> Controls whether keyboard navigation in lists and trees is automatically triggered simply by typing. If set to `false`, keyboard navigation is only triggered when executing the `list.toggleKeyboardNavigation` command, for which you can assign a keyboard shortcut.
>
> https://code.visualstudio.com/docs/getstarted/settings
