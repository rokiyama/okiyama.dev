---
title: Xcode 15 beta をインストールすると gopls がエラー
date: 2023-08-26T11:16:55+09:00
tags: [memo, xcode, golang, gopls]
---

要約:

- しばらく Go に触れていなかった
- 最近 Xcode 15 beta 6 をインストールした
- VSCode で Go のプロジェクトを開くと gopls のエラーが出た
- [issue のコメント](https://github.com/golang/go/issues/61190#issuecomment-1663426102)に従って gopls を一度削除して Homebrew で入れ直したら解消した

VSCode で Go のプロジェクトを開くとエラーが２つ通知されました。

```
The gopls server failed to initialize.
```

```
gopls client: couldn't create connection to server.
```

コマンドラインで `gopls` を実行してみるとエラーでした。

```sh
❯ gopls version
R PAKAYAH LI LETTER PHAfish: Job 1, 'gopls version' terminated by signal SIGSEGV (Address boundary error)
```

Issue が上がっていました。

[Language server fails to start · Issue #2909 · golang/vscode-go · GitHub](https://github.com/golang/vscode-go/issues/2909)

[runtime: gopls -v crashes immediately when linked with Xcode 15 beta · Issue #61190 · golang/go · GitHub](https://github.com/golang/go/issues/61190#issuecomment-1663426102)

一度 Go modules でインストールされたバイナリを削除して、 Homebrew のバージョンをインストールし直すと解消するようです。

```sh
# 削除
❯ rm ~/go/bin/gopls

# Homebrew でインストール
❯ brew install gopls
# (snip)

==> Fetching gopls
==> Downloading https://ghcr.io/v2/homebrew/core/gopls/manifests/0.13.2
######################################################################################################################################################### 100.0%
==> Downloading https://ghcr.io/v2/homebrew/core/gopls/blobs/sha256:a70553eebb2218b4062c6b452eb7a5168e33224eaa396e847c45abb1825fbf5e
######################################################################################################################################################### 100.0%
==> Pouring gopls--0.13.2.arm64_ventura.bottle.tar.gz
🍺  /opt/homebrew/Cellar/gopls/0.13.2: 5 files, 25.9MB

# 正常になった
❯ gopls version
golang.org/x/tools/gopls v0.13.2
    golang.org/x/tools/gopls@(devel)
```

この後、 VSCode で `Reload Window` を実行すると正常になりました。
