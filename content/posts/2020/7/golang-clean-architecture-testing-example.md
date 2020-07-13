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

![](https://blog.cleancoder.com/uncle-bob/images/2012-08-13-the-clean-architecture/CleanArchitecture.jpg)

リンク先に clean architecture の図があります。これを見ると、4つのレイヤーに分かれています。
golang ではディレクトリ名＝パッケージ名とする慣習で、かつ、簡潔なパッケージ名が好まれる傾向があるようですので、少し改名し、以下のディレクトリを作成します。

| The Clean Architecture                | Name (this project) |
| ------------------------------------- | ------------------- |
| Entity (Enterprise Business Rule)     | domain              |
| Use Cases (Application Business Rule) | usecase             |
| Interface Adapters                    | adapter             |
| Frameworks & Drivers                  | infra               |

*clean architecture の作者は、レイヤーの数は 4 に限らないと言っている。プロジェクトに応じて、これより多い場合も、少ない場合も考えられる、と。今回、私たちが作るアプリケーションは極めて単純ですので、 4 つのレイヤーは多すぎるかもしれませんが、より大きなアプリケーションを開発するための学習用として、この構成で進めます。*


memo:

unexported struct を使うか、 interface を公開するか https://github.com/golang/lint/issues/210
