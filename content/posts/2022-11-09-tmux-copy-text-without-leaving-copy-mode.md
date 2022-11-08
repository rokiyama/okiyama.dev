---
title: tmux で文字列をコピーした後にコピーモードを抜けないようにする
date: 2022-11-09T08:06:00+09:00
tags: [memo]
---

`copy-pipe` を使うようキーバインドを設定します。

```properties
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe
```

プラグイン
[tmux-yank](https://github.com/tmux-plugins/tmux-yank)
を使用している場合は以下を設定します。

```properties
set -g @yank_action 'copy-pipe'
```

tmux 3.3a, tmux-yank 2.3.0 で確認しました。

## キーバインドを確認する

コマンド `tmux list-key` で、現在のキーバインドが確認できます。

```sh
# デフォルト状態の tmux キーバインド一覧
❯ tmux -f /dev/null list-key | rg 'copy-pipe'
bind-key    -T copy-mode    C-k                  send-keys -X copy-pipe-end-of-line-and-cancel
bind-key    -T copy-mode    C-w                  send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    MouseDragEnd1Pane    send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    DoubleClick1Pane     select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    TripleClick1Pane     select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode    M-w                  send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi C-j                  send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi Enter                send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi D                    send-keys -X copy-pipe-end-of-line-and-cancel
bind-key    -T copy-mode-vi MouseDragEnd1Pane    send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi DoubleClick1Pane     select-pane \; send-keys -X select-word \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T copy-mode-vi TripleClick1Pane     select-pane \; send-keys -X select-line \; run-shell -d 0.3 \; send-keys -X copy-pipe-and-cancel
bind-key    -T root         DoubleClick1Pane     select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-word ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel }
bind-key    -T root         TripleClick1Pane     select-pane -t = \; if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -H ; send-keys -X select-line ; run-shell -d 0.3 ; send-keys -X copy-pipe-and-cancel }
```

vi モードのデフォルトでは Enter にコピー機能が割り当てられていて、コマンドは `copy-pipe-and-cancel` となっています。
キーバインドを上書きして `copy-pipe` に変更すれば、コピーモードから抜けないようになります。

## プラグイン tmux-yank について

コピー機能は OS 特有の対応が必要な場合があります。

現在は不要になりましたが、 tmux 2.6 以前は macOS では `reattach-to-user-namespace` が必要で、
これを使うようなキーバインドを設定する必要がありました。
Linux では `xsel` や `xclip` を使う、 WSL では `clip.exe` を使うなど OS によって異なります。

[tmux-yank](https://github.com/tmux-plugins/tmux-yank)
はこの問題にまとめて対処するプラグインです。
インストールすると、使用している環境に合わせたコマンドでいくつかのキーバインドが追加されます。

このプラグインにも `copy-pipe` に変更する方法が用意されていて、記事冒頭に記載の方法で変更できます。

## 参考にした記事

- [tmux 3.0でコピーモードの設定を行う - りんごとバナナとエンジニア](https://udomomo.hatenablog.com/entry/2020/01/12/235955)
