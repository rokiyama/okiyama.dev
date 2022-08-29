---
title: Node.js ワンライナーの基本
date: 2022-08-29T14:29:34+09:00
draft: false
tags: [memo, node]
---

node コマンドでワンライナーを書くための基本的な知識をまとめました。

参照: https://nodejs.org/dist/latest-v16.x/docs/api/cli.html

## node コマンドのオプション

使うオプションは基本的にこの 3 つです。おおむね `-p` と `-r` でなんとかなりそうです。

- `-e, --eval "script”` ... スクリプトを実行
- `-p, --print "script"` ... スクリプトを実行し、結果を標準出力に渡す
- `-r, --require module` ... モジュールをロード

## 例: 標準入力を文字列置換する

標準入力を受け取り、先頭の空白を除き、標準出力に渡す例です。

```sh
cat FILE.txt | node -r fs -p 'fs.readFileSync(0, "utf-8").replaceAll(/^\s+/gm, "")'
```

標準入力だけでなく、ファイル名も指定できます。

```sh
node -r fs -p 'fs.readFileSync("FILE.txt", "utf-8").replaceAll(/^\s+/gm, "")'
```

ポイントは以下の通りです。

- `-r fs` ... 標準入力を読むのに fs モジュールを使います。
- `fs.readFileSync(0, "utf-8")` ... 第一引数に `0` を渡すと標準入力を読むことができます[^1]。第二引数に encoding を指定すると `string` が得られます (指定しないと `Buffer` 型になります)。
- `replaceAll` に正規表現を指定する場合は `g` フラグが必須です[^2]。
- 正規表現フラグ `m` で各行にマッチするようになります。ここでは `^\s+` を各行の行頭にマッチさせるため指定しています[^3]。

[^1]: `0` はファイルディスクリプタで、標準入力を表します。参照: [fs.readFileSync(path[, options])](https://nodejs.org/dist/latest-v16.x/docs/api/fs.html#fsreadfilesyncpath-options)
[^2]: [String.prototype.replaceAll()
](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/String/replaceAll)
[^3]: [フラグを用いた高度な検索 - 正規表現 - JavaScript | MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Regular_Expressions#%E3%83%95%E3%83%A9%E3%82%B0%E3%82%92%E7%94%A8%E3%81%84%E3%81%9F%E9%AB%98%E5%BA%A6%E3%81%AA%E6%A4%9C%E7%B4%A2)

## 注意: オプションの順序

- `node -r fs -p "script"` OK
- `node -p "script" -r fs` OK
- `node -p -r fs "script"` これは失敗します。 `"script"` が `-p` オプションの引数であるためだと思われます。
