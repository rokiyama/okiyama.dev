---
title: golang でサーバアプリを作る - clean architecture で、テストを書きながら
canonicalLink: golang-clean-architecture-testing-example
date: 2020-07-11
published: false
tags: ['golang', 'clean-architecture', 'testing']
---

作るものは http サーバで、以下のような機能を考えます。

- リクエストを受けたらそれを加工して別の http サーバにリクエストする
- 加工に必要な情報は DB から取得する
- 最初は認証機能なし。後で追加する

執筆時の環境:

- macOS 10.xx
- go 1.xx
- Docker xx
- VSCode

まずはプロジェクトの初期設定を行います。 git の設定後、 go mod init でモジュール名を決めます。

```sh
mkdir example-golang-app
cd example-golang-app
git init
git remote add origin ...

go mod init github.com/<ユーザ名>/example-golang-app
```

ディレクトリ構成を決めます。ここで、 clean architecture を参考にレイヤーを考え、それをディレクトリ構成としましょう。

https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

リンク先に clean architecture の図があります。これを見ると、4つのレイヤーに分かれています。
golang ではディレクトリ名＝パッケージ名とする慣習で、かつ、簡潔なパッケージ名が好まれる傾向があるようですので、少し改名し、以下のディレクトリを作成します。

| The Clean Architecture                | Name (this project) |
| ------------------------------------- | ------------------- |
| Entity (Enterprise Business Rule)     | domain              |
| Use Cases (Application Business Rule) | usecase             |
| Interface Adapters                    | adapter             |
| Frameworks & Drivers                  | infra               |

clean architecture の作者は、レイヤーの数は 4 に限らないと言っています (プロジェクトに応じて、これより多い場合も、少ない場合も考えられる、とのこと) 。

今回作るアプリケーションは単純なので 4 つのレイヤーは多すぎるかもしれませんが、より大きなアプリケーションを開発するための学習として、この構成で進めます。

## 検討中のこと

### unexported struct を使うか、 interface を公開するか

https://github.com/golang/lint/issues/210

- interface を使った方が良さそう。
  - lint 警告、呼び元でその型を使えなくなる、 godoc 出力の対象になる (上記 issue のコメントより)
  - その interface を実装する struct を複数作る際、 struct 毎に関数コメントを書く必要がなくなる https://tyru.hatenablog.com/entry/2018/04/23/000314

CodeReviewComments (go 公式 wiki の一部) の interface に関する記述も、この方向を示唆している:

> Go interfaces generally belong in the package that uses values of the interface type, not the package that implements those values. The implementing package should return concrete (usually pointer or struct) types: that way, new methods can be added to implementations without requiring extensive refactoring.
> 
> Goインタフェースは通常、インタフェースタイプの値を実装するパッケージではなく、それらの値を使用するパッケージに属します。実装パッケージは具象(通常ポインタか構造体)型を返す必要があります。そうすれば、大規模なリファクタリングを必要とせずに新しいメソッドを実装に追加することができます。
> 
> https://github.com/golang/go/wiki/CodeReviewComments#interfaces

一方、これらの方針は、 [こちらで紹介されている Accept interfaces,return structs という考え方](https://qiita.com/weloan/items/de3b1bcabd329ec61709) とは競合するように思われる。

次はこれを読んでみる: https://qiita.com/ogady/items/34aae1b2af3080e0fec4


```
