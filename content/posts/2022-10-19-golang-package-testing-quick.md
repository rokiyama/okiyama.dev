---
title: golang の標準パッケージ testing/quick は非推奨？
date: 2022-10-19T19:29:17+09:00
tags: [memo, golang, testing]
---

結論: 非推奨ではありませんが今後積極的に使うものではなく、
gopter, rapid など別のライブラリを検討するのが良さそうです。

## frozen だが deprecated とは書かれていない

2016 年の時点で「このパッケージはフリーズし、今後修正や機能追加はしない」と宣言されています。

ドキュメントには以下のように書かれていて

> The testing/quick package is frozen and is not accepting new features.
>
> https://pkg.go.dev/testing/quick

[ソースの blame](https://github.com/golang/go/blame/19309779ac5e2f5a2fd3cbb34421dafb2855ac21/src/testing/quick/quick.go)
を見ると 2016/10 のコミットで追加されたようです。関連 issue は [golang/go#15557](https://github.com/golang/go/issues/15557) です。

その後 2017 年に出された [機能追加プロポーザルの issue](https://github.com/golang/go/issues/23135) を読むと、
サードパーティのライブラリの利用が示唆されるなど、開発の方針がわかります。

比較のため他のパッケージを見ると、 2020 年に廃止となった [x/lint](https://pkg.go.dev/golang.org/x/lint) は
_deprecated and frozen_ と書かれています[^1]。

[^1]: ただし x 配下のパッケージは法則が異なるかもしれない

## サードパーティのライブラリはどんなものがある？

testing/quick のようなランダム値によるテスト手法は Property based testing と呼ばれています。

golang で Property based testing の実践をサポートするライブラリとしては
[leanovate/gopter](https://github.com/leanovate/gopter) と
[flyingmutant/rapid](https://github.com/flyingmutant/rapid) が有名なようです。

[![GitHub Star History](/images/star-history-20221019.png)](https://star-history.com/#leanovate/gopter&flyingmutant/rapid&Date)

## 参考記事

- [gopterを使ってGoでProperty Based Testingする - Qiita](https://qiita.com/rerorero/items/568e227da3939dbf9532)
- [Goにproperty based testingを布教したい - These Walls](https://kazchimo.com/2021/03/30/go-pbt-testing/)
