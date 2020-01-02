---
title: vue-apollo メモ
canonicalLink: vue-apollo-memo
date: 2019-10-02
published: true
tags: ['vue-apollo']
---

## vue-apollo の `result` 関数が呼ばれるタイミング

2 回ある。

1. reactive variables が変更され、ロードが始まったタイミング
    - `result.loading === true` になる。
1. ロードが終わったタイミング
    - `result.loading === false` になる。

## apollo 結果がキャッシュされている時に、リアクティブなプロパティを変更しても反映されない

`fetchPolicy` を変更すると動作する。

- `fetchPolicy: "cache-and-network"` ... OK
- `fetchPolicy: "network-only"` ... OK
- `fetchPolicy: "cache-first"` ... NG

`fetchPolicy` のデフォルト値は `cache-first` である。 (参考: [apollo-client/watchQueryOptions.ts at 7a2067e33f748372aa6342ef0a097679e3239d29 · apollographql/apollo-client](https://github.com/apollographql/apollo-client/blob/7a2067e33f748372aa6342ef0a097679e3239d29/packages/apollo-client/src/core/watchQueryOptions.ts#L11))

参考: [Reactive Variables with 'cache-first' not working in new version · Issue #138 · vuejs/vue-apollo](https://github.com/vuejs/vue-apollo/issues/138)
