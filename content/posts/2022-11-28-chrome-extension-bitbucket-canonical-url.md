---
title: Chrome 拡張 "Bitbucket Canonical Url" を作った
date: 2022-11-28T18:09:15+09:00
tags: [memo, chrome, typescript]
---

[Bitbucket canonical URL](https://chrome.google.com/webstore/detail/bitbucket-canonical-url/kfckcleaglfgjkobhcbclfflhcllmnmm) という Chrome 拡張を作りました。 Chrome ウェブストアでインストールできます。

![](/images/bitbucket-canonical-url-usage.gif)

Bitbucket の PR を開いて URL が変に長いときに、アイコンをクリックすると短い URL に置き換わるという拡張です。

ソースコード: https://github.com/rokiyama/bitbucket-canonical-url

## 概要

Bitbucket の PR を使っていると URL が妙に長くなることがあります。

```
# 長い
https://bitbucket.org/foo/%7B840d6a13-5d55-4c1a-a86b-3372c3ceeef1%7D/pull-requests/123/branch-name#comment-123456789

↓

# 短くできる
https://bitbucket.org/foo/bar/pull-requests/123#comment-123456789
```

UUID のようなものが埋め込まれていて、リポジトリ名が判別できません。無駄にブランチ名も入っています。
どうやら JIRA から PR に飛んだ時などに発生するようです。

この拡張をインストールしてツールバーのアイコンをクリックすると、短い URL に書き換えられます。

Bitbucket と JIRA を併用していて、かつ URL の見映えを気にする人がターゲットユーザーでしょうか。

## クリックしたら書き換える方式にした理由

[Amazon URL Shortener](https://chrome.google.com/webstore/detail/amazon-url-shortener/bonkcfmjkpdnieejahndognlbogaikdg)
という拡張があり、これを参考に開発を始めました。

最初はこれと同様、ページを開いた瞬間に URL を書き換えるようにしたかったのですが、
PR 内でコメントにジャンプしたりした際にも URL が長くなる現象が起きることがあったため、
任意のタイミングで短縮処理が行えるようにしています。

## background.ts と content.ts

クリック時に行う処理は
[background.ts](https://github.com/rokiyama/bitbucket-canonical-url/blob/main/src/background.ts)
で行っており、これは service worker として動作します。

また URL が
`https://bitbucket.org/foo/%7B840d6a13-5d55-4c1a-a86b-3372c3ceeef1%7D/pull-requests/...`
のような場合、リポジトリ名をどこかから取ってくる必要があり、これは DOM から取得する必要がありました。

DOM の取得は service worker では行えず、 content scripts で行う必要があります。
この処理は
[content.ts](https://github.com/rokiyama/bitbucket-canonical-url/blob/main/src/content.ts)
で行っています。

それぞれのファイルの役割は [マニフェスト](https://github.com/rokiyama/bitbucket-canonical-url/blob/main/vite.config.ts) で指定するようになっています。

## ストアでの公開

開発者登録料として $5 支払いました。一度払えばそれ以降の支払いは不要なようです。

11/19(土) に審査を申請して、 11/21(月) に公開されました。
Eメールで通知などはしてくれないようで、いつの間にか公開されていたという感じでした。

## 今後の課題

- バージョン管理
- GitHub Actions でテスト、リリース

## 参考にした記事

拡張の作り方はこちらの記事と、この筆者の方の作られた拡張を参考にさせていただきました。

- [Chrome拡張をつくるチュートリアル](https://r7kamura.com/articles/2022-05-18-learn-chrome-extention-in-y-minutes)
- [Amazon URL Shortener - Chrome ウェブストア](https://chrome.google.com/webstore/detail/amazon-url-shortener/bonkcfmjkpdnieejahndognlbogaikdg)

こちらも参考にさせていただきました。ストア公開の手順までが簡潔にまとめられていてわかりやすかったです。

- [Chrome拡張をVite+TypeScript+Reactで作る](https://zenn.dev/fjsh/articles/chrome-extension-with-vite)

こちらは開発に必要な概念が詳しく説明されていて参考になりました。内容はマニフェスト V2 に基づいていますが、基本的な考え方は V3 でも大きくは変わらないようです。

- [Chrome Extension の作り方 (その1: 3つの世界) - Qiita](https://qiita.com/sakaimo/items/416f36db1aa982d8d00c)
