---
title: golang でサーバアプリを作る - clean architecture で、テストを書きながら
date: 2020-07-11
draft: true
tags: ['article', 'golang', 'clean-architecture', 'testing']
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

[こちらの記事](https://tyru.hatenablog.com/entry/2018/04/23/000314) では、

> struct は unexported にしてコンストラクタ的な関数で生成したいという場合がままある

とあり、つまり interface は呼ぶ側で定義することとし、 NewXxx 関数で unexported な struct を返す方法が書かれている。

これは [Accept interfaces,return structs という考え方](https://qiita.com/weloan/items/de3b1bcabd329ec61709) を実践しようとすると自然と行き着くパターンだと思う。なお、この Accept ~ という考え方は、 golang の interface を使うときのプラクティスとしてよく言われているらしい。

記事に戻る。前述のコンストラクタ的な関数を実際に書くと、 golint に `exported func NewXxx returns unexported type xxx, which can be annoying to use` と警告されてしまう。

解決策として、 exported な interface を定義し、それを返すという方法が挙げられている。この方法には他にもメリットがあり、その interface の実装 struct を複数作る際に毎回メソッドの doc コメントを書く必要がなくなる、とのこと。

確かに、 [本家 golang リポジトリの issue](https://github.com/golang/lint/issues/210) のコメントも、 interface を使うべきとの意見が多い (反対意見もあるが) 。理由は、

- unexported struct を返すと、呼び元でその型を使えなくなる。
- godoc 出力の対象になる。

つまり、 exported な interface を返すのが正解なのか。

だがこの方針は、先程の "Accept interfaces,return structs" には反するように思われる。

CodeReviewComments (go 公式 wiki の一部) の interface に関する記述も、この方向を示唆している:

> Go interfaces generally belong in the package that uses values of the interface type, not the package that implements those values. The implementing package should return concrete (usually pointer or struct) types: that way, new methods can be added to implementations without requiring extensive refactoring.
>
> Goインタフェースは通常、インタフェースタイプの値を実装するパッケージではなく、それらの値を使用するパッケージに属します。実装パッケージは具象(通常ポインタか構造体)型を返す必要があります。そうすれば、大規模なリファクタリングを必要とせずに新しいメソッドを実装に追加することができます。
>
> https://github.com/golang/go/wiki/CodeReviewComments#interfaces

個人的には、後者の方法が良さそうに思える。 interface の多重定義のようなことにもなる

では exported にしてしまえば良いのではないか。標準ライブラリもそうなっているものが多いのでは？ (io.Writer などは除く)

次はこれを読んでみる: https://qiita.com/ogady/items/34aae1b2af3080e0fec4
