---
title: eslint-config-prettier と eslint-plugin-prettier
date: 2023-08-09T08:34:43+09:00
tags: [memo, eslint, prettier]
---

[Prettier 公式サイトの説明](https://prettier.io/docs/en/integrating-with-linters) によると、 eslint-config-prettier が紹介される一方、 eslint-plugin-prettier は非推奨とされています。

## eslint-config-prettier: Prettier と競合する ESLint ルールを無効にする

https://github.com/prettier/eslint-config-prettier

ESLint には、不具合の原因となるコードを検出するためのルールのほか、フォーマットに関するルールも存在します。 Prettier を使っている場合、フォーマットのルールは不要なだけでなく、 Prettier の設定とコンフリクトする場合もあります。

eslint-config-prettier はそのようなルールを無効にします。

## eslint-plugin-prettier: ESLint 実行時に Prettier によるフォーマットを実行する

https://github.com/prettier/eslint-plugin-prettier

eslint-plugin-prettier は ESLint 実行時に Prettier によるフォーマットを実行する ESLint プラグインです。フォーマットが適用されていないファイルを検出する機能もあります。

Prettier が登場した当初は、エディタとの統合はまだ存在していませんでした。一方で ESLint (などの Linter ツール) は以前から存在していたため、多くのエディタがサポートしていました。このような時代に、 ESLint 経由で実行できる eslint-plugin-prettier は有用だったようです。

しかし現在は多くのエディタが Prettier をサポートしています。そして、 ESLint のプラグインとして Prettier を実行することにはデメリットがあり (不要な警告が出る・パフォーマンスが悪いなど) 、現在では eslint-plugin-prettier を使う理由はありません。

## ESLint 設定の extends に plugin:prettier/recommended を書くとどうなるのか

[README](https://github.com/prettier/eslint-plugin-prettier/tree/910aeb60a7456beb6193c634bb8dec1b7181312d#recommended-configuration) によると、これ一つで eslint-config-prettier と eslint-plugin-prettier の両方が有効になります。以下のように展開されます。

```json
{
  "extends": ["prettier"],
  "plugins": ["prettier"],
  "rules": {
    "prettier/prettier": "error",
    "arrow-body-style": "off",
    "prefer-arrow-callback": "off"
  }
}
```

eslint-config-prettier だけを有効にする場合、 `extends` に `prettier` を追加するだけでよいです。

また、 `prettier/react` や `prettier/vue` のように他のプラグインと共存するための設定は [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier/blob/19826807f2d668a05bb9c29a5f6f6a6e6e3287e4/CHANGELOG.md#version-800-2021-02-21) の 8.0.0 から不要になったようです。

## CI で ESLint と同時に Prettier のチェックも実行する

CI で ESLint を実行しているなら、 `prettier --check` コマンドも同時に実行するとよいかもしれません。エディタ設定の不備を検出できます。

例として CI で `npm run lint` を実行している場合、以下のように設定します。

```json
{
  "scripts": {
    "lint": "eslint ./src && prettier --check ."
  }
}
```

## 参考文献

- [Integrating with Linters · Prettier](https://prettier.io/docs/en/integrating-with-linters)
- [いつのまにか eslint-plugin-prettier が推奨されないものになってた | K note.dev](https://knote.dev/post/2020-08-29/duprecated-eslint-plugin-prettier/)
- [eslint と prettier を併用する時の設定 - すな.dev](https://www.sunapro.com/eslint-with-prettier/)
