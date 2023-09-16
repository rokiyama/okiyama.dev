---
title: expo install --check で TypeScript をアップデートしたら ESLint が動かなくなったのでダウングレードした
date: 2023-09-16T10:30:42+09:00
tags: [memo, expo, typescript, eslint]
---

## TL;DR

- `expo install --check` で TypeScript のバージョンを上げたら、 eslint が動かなくなった
- `@typescript-eslint/eslint-plugin` を v6 に上げる必要があるが `@react-native/eslint-config` が v5 系に依存しているためアップデートできない
- TypeScript のバージョンを 5.0.x に落としたら ESLint が実行できるようになった

## expo install --check とは

Expo CLI に用意されている `expo install --check` は、バージョンを検証・修正するコマンドです。

https://docs.expo.dev/more/expo-cli/#version-validation

ローカルで実行すると対話式で修正でき、 CI ではチェック結果に応じてエラーになります。

最近、 Expo SDK のアップデートに合わせて実行したところ、 TypeScript のバージョンが上がりました。

```sh
❯ npx expo install --check
Some dependencies are incompatible with the installed expo version:
  typescript@5.0.4 - expected version: ^5.1.3
Your project may not work correctly until you install the correct versions of the packages.
Fix with: npx expo install --fix
✔ Fix dependencies? … yes
› Installing 1 SDK 49.0.0 compatible native module using npm
> npm install

# snip

changed 1 package, and audited 1600 packages in 9s
```

(実際には SDK アップデートと同時に行ったため、もっとログがありました。上記は後日再実行した際のログです)

上記の通り TypeScript のバージョンが上がりましたが、これにより ESLint が動かなくなりました。

```sh
❯ npm run lint

> eslint ./src

=============

WARNING: You are currently running a version of TypeScript which is not officially supported by @typescript-eslint/typescript-estree.

You may find that it works just fine, or you may not.

SUPPORTED TYPESCRIPT VERSIONS: >=3.3.1 <5.1.0

YOUR TYPESCRIPT VERSION: 5.2.2

Please only submit bug reports when using the officially supported version.
```

確認すると、 `@typescript-eslint/eslint-plugin` のバージョンが古く、最新の v6 系ではなく v5 系を使っていました。

v6 系にアップデートしようとしましたが、 `@react-native-community/eslint-config@3.2.0` が v5 系に依存しておりアップデートできません。そもそもこのパッケージ自体が古く、 React Native 0.72 で名称が変更されています。

https://reactnative.dev/blog/2023/06/21/0.72-metro-package-exports-symlinks#package-renames

- OLD: `@react-native-community/eslint-config`
- NEW: `@react-native/eslint-config`

というわけで `@react-native/eslint-config` の最新をインストールしましたが、こちらも v5 系に依存していました。リポジトリを見たところ以下のようになっています。

| revision                                                                                                                                            | directory                                       | package name                  | version  | 依存している `@typescript-eslint/eslint-plugin` のバージョン |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- | ----------------------------- | -------- | ------------------------------------------------------------ |
| [main](https://github.com/facebook/react-native/blob/61861d21ff71a9451019e0f98e0c0414cf12c153/packages/eslint-config-react-native/package.json#L26) | `packages/eslint-config-react-native`           | `@react-native/eslint-config` | `0.73.0` | `^5.57.1`                                                    |
| [v0.72.4](https://github.com/facebook/react-native/blob/v0.72.4/packages/eslint-config-react-native-community/package.json#L17)                     | `packages/eslint-config-react-native-community` | `@react-native/eslint-config` | `0.72.2` | `^5.30.5`                                                    |

ディレクトリ名が異なる理由は不明ですが、パッケージ名は一致しています。 [npm.js](https://www.npmjs.com/package/@react-native/eslint-config?activeTab=versions) によると 0.72.2 が最新で、 0.73.0 は nightly となっています。いずれにせよ、どちらも `@typescript-eslint/eslint-plugin` の v5 系に依存しています。

依存関係を無視して `@typescript-eslint/eslint-plugin` を最新化することも考えられますが、今回は手っ取り早く対応するため TypeScript のバージョンを下げます。 ESLint のエラーメッセージによると `<5.1.0` が必要なので、 v5.0.x 系にします。

```sh
❯ npm install -D typescript@~5.0.0

changed 1 package, and audited 1600 packages in 2s
```

ESLint が実行できるようになりました。

```sh
❯ npm run lint

> expo-chat-command-gpt@1.0.0 lint
> eslint ./src

Warning: React version not specified in eslint-plugin-react settings. See https://github.com/jsx-eslint/eslint-plugin-react#configuration .
```

## 実際のコミット

https://github.com/rokiyama/gpt-prompter-frontend/commit/2c877c25f13ac8de4bc38d1139bc8591b6ca65cd
