---
title: tpm (Tmux Plugin Manager) を導入
date: 2021-05-01T01:17:52+09:00
draft: false
tags: [memo, tmux]
---

tpm (Tmux Plugin Manager) を導入した。

https://github.com/tmux-plugins/tpm

tpm の導入後、 `.tmux.conf` に使いたいプラグインを記述して `prefix` + `I` を押すとプラグインをインストール・ロードしてくれる。

プラグインのリストもあり、いくつかインストールしてみた。

https://github.com/tmux-plugins/list

私の設定ファイルは [GitHub](https://github.com/rokiyama/dotfiles/blob/2f3092b79928bd7ac2979339a042fef9c3cc87f3/.tmux.conf) に置いてある。

## tmux-sensible, tmux-yank

自分は `.tmux.conf` をほとんどカスタムしておらず、基本的な設定とクリップボード連携の設定をしていたくらいだったが、プラグインを導入することでその記述すら不要になった。

`tmux-sensible` はいくつかの基本的な設定に、多くのユーザにとって快適になるようなデフォルト値を提供してくれる (ユーザが変更している場合はそれを上書きしないよう配慮されている) 。

https://github.com/tmux-plugins/tmux-sensible

`tmux-yank` はクリップボード連携の設定をしてくれる。

https://github.com/tmux-plugins/tmux-yank

## tmux-prefix-highlight

ステータスラインに `#{prefix_highlight}` と記述すると prefix キーの状態が表示されるようになる。

https://github.com/tmux-plugins/tmux-prefix-highlight

## tmux-urlview

現在の画面から URL を探し、ブラウザで開くプラグイン。 `prefix` + `u` で URL リストが開き、選ぶとブラウザが立ち上がる。

https://github.com/tmux-plugins/tmux-urlview

## extrakto

現在の画面から単語を探し、コマンドラインにペーストできるプラグイン。 `prefix` + `Tab` で単語リストのポップアップが開き、リストから fzf で絞り込んで選択する。

mac で使う場合は最新の bash を入れておく必要がある。

https://github.com/laktak/extrakto

## vim プラグイン: tmuxline.vim

tmux ではなく vim プラグインだが、実行すると vim のステータスラインを元に tmux のステータスライン設定を生成してくれる。

https://github.com/edkolev/tmuxline.vim

## プラグインにより用意されるキーバインド

以上のプラグインが用意してくれるキーバインドをリストしておく。

- tpm
  - `prefix` + `I`
    - Installs new plugins from GitHub or any other git repository
    - Refreshes TMUX environment
  - `prefix` + `U` ... updates plugin(s)
  - `prefix` + `M-u` ... remove/uninstall plugins not on the plugin list
- urlview
  - `prefix` + `u` ... listing all urls on bottom pane
- extrakto
  - `prefix` + `Tab` ... start extrakto

## プラグインが有効にならない場合は

プラグインをインストールしたのに有効にならない時は、エラーになっていないかを確認する。

プラグインファイルは実行ファイルになっており、以下のように実行するとエラーメッセージを確認できる。

```bash
❯ ~/.tmux/plugins/extrakto/extrakto.tmux
/Users/p563/.tmux/plugins/extrakto/extrakto.tmux: line 10: ${extrakto_key,,}: bad substitution
```

上記のエラーは mac の古い bash を使っているために発生しているエラーで、 homebrew で bash をインストールすると解消する

## 参考

tmux プラグインの仕組みについてはこちらの記事が参考になった。

[tmuxを使いこなす / プラグイン開発で機能を拡張 | DevelopersIO](https://dev.classmethod.jp/articles/mastering-tmux-with-tpm-plugin/)
