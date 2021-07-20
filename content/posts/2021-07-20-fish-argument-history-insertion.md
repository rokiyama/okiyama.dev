---
title: fish shell は `Alt + ↑` で引数の履歴を補完してくれる
date: 2021-07-20T13:38:13+09:00
draft: false
tags: [memo, fish]
---

fish shell では他のシェルと同じように `↑`, `↓` や `Ctrl + n`, `Ctrl + p` で行ごとに履歴をたどることができる。これに加えて `Alt + ↑`, `Alt + ↓` で単語ごとの履歴をたどって補完することができる。

例えば `git status` で変更のあるファイルを一覧し、特定のファイルだけをコミットしたいとする。

```fish
git status -sb
# ## master...origin/master
#  M dotconfig/karabiner/karabiner.json
#  M init.sh
# ?? dotconfig/flutter/
```

いくつか変更があるが `init.sh` だけをコミットしたい。 `git diff` で差分確認してから `git add` を行う。

```fish
git diff init.sh
# diff --git a/init.sh b/init.sh
# (snip)

git add init.sh
```

ここで `git add` を入力してから `Alt + ↑` を押すと `init.sh` が補完される。 (もう一度押すと `diff` に変わる)

この例だとファイル名が短いのであまりメリットはないが、長いパスを指定する時などに便利。

{{< youtube nVoCdwBpaYc >}}

