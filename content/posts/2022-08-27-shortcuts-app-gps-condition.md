---
title: ショートカットアプリで「現在地」を if の条件にする
date: 2022-08-27T15:28:53+09:00
draft: false
tags: [memo, mac, ios, shortcuts.app]
---

iOS や macOS のショートカットアプリ (Shortcuts.app) で現在地を取得し、住所から文字列を検索して if の条件にしたい場合、「一致するテキスト」を使う。

![](/images/text-match.png)

これを使って、上から順に「現在地取得」→「一致するテキスト」→「if」と並べ、条件は「任意の値」にする。

以下は、現在地が特定の住所ならば [Sesame](https://jp.candyhouse.co/) を実行、そうでなければ確認ダイアログを出すという例。

![](/images/shortcuts-gps.png)

条件の「任意の値」とは `not empty` という意味らしい。擬似コードで表すとこのようなイメージ:

```c
position = getPosition()
matched = position.find("東京都千代田区千代田1-1")
if (matched != "")
// 以下略
```
