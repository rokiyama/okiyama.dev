---
title: macOS Monterey にしたら fish shell で ls がカラー表示されない
date: 2021-11-12T10:22:02+09:00
tags: [memo, fish]
---

## 対処法

環境変数を追加する。

```fish
set -Ux COLORTERM 1
```

もしこれで直らなければシェルを再起動するか、以下 2 つのグローバル変数を消去する。

```fish
set -e __fish_ls_command
set -e __fish_ls_color_opt
```

あるいは [athityakumar/colorls](https://github.com/athityakumar/colorls) をインストールするとそちらが使われるようになる。

また、試していないが coreutils をインストールすることでも解消すると思われる。

## 補足

`type ls` で確認するとわかるが、 fish では `ls` コマンドは標準の関数でラップされており、
カラー化するオプションを追加してくれている。

https://github.com/fish-shell/fish-shell/blob/c16e30931b44628bccf2abc3082ddeb53e08971e/share/functions/ls.fish#L20-L47

分岐を見ると、特定の条件を満たした場合[^1]はカラー化オプションを決定するために

[^1]: 変数 `__fish_ls_color_opt` が未設定で `colorls` コマンドが存在しない場合

- `ls --color=auto` (GNU 系で有効)
- `ls -G` (macOS, BSD 系で有効)
- `ls --color`
- `ls -F`

の順で試行し、エラーにならなければそのオプションを採用するようだ。

しかし macOS Monterey でコマンドを実行してみると、 `ls --color=auto` はエラーにならないしカラーにもならない。

macOS Monterey の `ls --color=auto` は、 stdout が tty でありかつ `COLORTERM` 環境変数が設定されている場合のみカラー表示を行うためだ[^2]。

[^2]: なお `-G` オプションは、 `COLORTERM` を設定した上で `--color=auto` を指定するのと同等

つまり環境変数 `COLORTERM` を定義しておけばカラー表示されるようになる。値はなんでも良いようだ。

## さらに補足

`ls --color=auto` は以前の macOS ではエラーになっていた。 (おそらく Big Sur まで？)

```fish
❯ ls --color=auto
ls: illegal option -- -
usage: ls [-@ABCFGHLOPRSTUWabcdefghiklmnopqrstuwx1%] [file ...]
```

このため以前までは、前述のラッパー関数の判定で `ls -G` が実際に実行されるコマンドになっていた。

man を見るとこのような違いがある。 BSD の実装から独自実装に変わったのだろうか。これについては検索しても情報が見つけられなかった。

Big Sur:

```man
LS(1)                     BSD General Commands Manual                    LS(1)

NAME
     ls -- list directory contents

SYNOPSIS
     ls [-ABCFGHLOPRSTUW@abcdefghiklmnopqrstuwx1%] [file ...]

... (略)

BSD                              May 19, 2002                              BSD
```

Monterey:

```man
LS(1)                            General Commands Manual                            LS(1)

NAME
     ls – list directory contents

SYNOPSIS
     ls [-@ABCFGHILOPRSTUWabcdefghiklmnopqrstuvwxy1%,] [--color=when] [-D format]
        [file ...]

... (略)

macOS 12.0                           August 31, 2020                           macOS 12.0
```
