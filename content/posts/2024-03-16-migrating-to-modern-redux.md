---
title: レガシーな Redux コードの移行
date: 2024-03-16T09:04:28+09:00
tags: [memo, react, redux, redux-toolkit]
---

レガシーな Redux コードを移行する機会があったのでメモ

基本的に [Migrating to Modern Redux](https://redux.js.org/usage/migrating-to-modern-redux) という公式のガイドの通り。
比較的スムーズに移行できたポイントとして、古い書き方と現代的な書き方を共存したまま進めることができるのが大きかった。

> Many users are working on older Redux codebases that have been around since before these "modern Redux" patterns existed. Migrating those codebases to today's recommended modern Redux patterns will result in codebases that are much smaller and easier to maintain.
>
> The good news is that **you can migrate your code to modern Redux incrementally, piece by piece, with old and new Redux code coexisting and working together!**
>
> https://redux.js.org/usage/migrating-to-modern-redux#overview

## 移行作業の概要

大まかな流れは以下の通り:

1. `redux`, `react-redux` のバージョン最新化と `@reduxjs/toolkit` のインストール
1. `createStore` から `configureStore` への移行
1. `connect` から Hooks API への移行
1. `action`, `actionCreator`, `reducer` の構成から `createSlice` または RTK Query への移行

1, 2 は npm の依存関係とアプリケーションの初期化プロセスの変更で、主に一箇所を書き換えるだけの変更。 3, 4 は機能ごとに書き換えの作業が必要だった。

すべての機能を移行できたわけではなく、 3, 4 の変更は段階的に進めていてレガシーな部分も残っている。
移行が終わったコンポーネントはテストも書きやすくなったが、古い構成の Redux コードに依存しているコンポーネントはテストコードも以前のままである。

ユニットテストについては [Enzyme](https://enzymejs.github.io/enzyme) から [React Testing Library](https://testing-library.com/) と [MSW](https://mswjs.io/) の導入も必要だった。

## その他の公式ドキュメント

- [Writing Tests | Redux](https://redux.js.org/usage/writing-tests)
  - ユニットテストで `preloadedState` を渡せる `configureStore` の書き方
- [Usage With TypeScript | Redux](https://redux.js.org/usage/usage-with-typescript)
  - [Define Typed Hooks](https://redux.js.org/usage/usage-with-typescript#usage-with-react-redux) に Hooks API にアプリケーション固有の `useAppSelector`, `useAppDispatcher` 型を作る例
- [Tutorials Overview | Redux Toolkit](https://redux-toolkit.js.org/tutorials/overview)
  - Redux とは別のリポジトリに Redux Toolkit のドキュメントがある。 `createSlice` や RTK Query の詳しい使い方はこちらを参照
- [Writing Reducers with Immer | Redux Toolkit](https://redux-toolkit.js.org/usage/immer-reducers)
  - reducer に渡されるステートが Immer のオブジェクトになっている
