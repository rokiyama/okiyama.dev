---
title: CRA から Vite への移行
date: 2024-03-30T14:10:13+09:00
tags: [log, react, vite, jest, cloudflare, momentjs, vitest]
---

[CRA](https://create-react-app.dev/) と [react-scripts](https://www.npmjs.com/package/react-scripts) で構築していた React アプリを [Vite](https://vitejs.dev/) に移行した際のログです。

## ライブラリのインストール

```sh
yarn add -D vite @vitejs/plugin-react
```

## index.html をルートフォルダに移動

Vite ではここに置く必要があるようです。

また `public/` ディレクトリにあるファイルへは `/` でアクセスできるので、以下のような変更をします。

```diff
- <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
+ <link rel="icon" href="/favicon.ico" />
```

## import path を `~/` で絶対参照できるようにする

`vite.config.ts` で alias を設定します。

```ts
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: [
      {
        find: "~",
        replacement: path.resolve(__dirname, "./src"),
      },
    ],
  },
});
```

## エラー: sass の import ~@

この状態で起動してブラウザで表示すると以下のエラーが発生しました。

```
[plugin:vite:css] [sass] Can't find stylesheet to import.
  ╷
6 │ @import '~@progress/kendo-theme-default/scss/core/_index.scss';
  │         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  ╵
  src/index.scss 6:9  root stylesheet
```

[Error: Can't find stylesheet to import. · Issue #5764 · vitejs/vite · GitHub](https://github.com/vitejs/vite/issues/5764 "https://github.com/vitejs/vite/issues/5764")

`vitest.config.ts` の alias に以下を追加して解消しました。

```
      {
        find: /^~@progress\/kendo-theme-default/,
        replacement: '@progress/kendo-theme-default',
      },
```

## エラー: sass の import ~/

起動時に以下のエラーが表示されました。

```
[plugin:vite:css] [sass] ENOENT: no such file or directory, open '<snip>/src/themes/mixin'
  ╷
1 │ @import '~/src/themes/mixin';
  │         ^^^^^^^^^^^^^^^^^^^^
  ╵
```

scss ファイルにある import を以下のように修正して解消しました。

```diff
-@import '~/src/themes/mixin';
+@import '~/themes/mixin';
```

## エラー: process is not defined

ブラウザ画面が何も表示されなくなり、 devtools の console にエラーが出力されていました:

```
Uncaught ReferenceError: process is not defined
    at index.ts:2:24
```

Vite では環境変数の扱いが異なるためです。以下の変更で解消しました。

- `process.env` を `import.meta.env` に変更
- 環境変数の prefix を `REACT_APP_` から `VITE_` に変更
- `react-app-env.d.ts` を `vite-app-env.d.ts` にリネーム＆修正

## エラー: require is not defined

一部で require を使っていた箇所があったためエラーになりました。

```
Uncaught ReferenceError: require is not defined
```

require を全て import に置き換えて解消しました。なお moment のロケールを条件付きで require していた処理があり、以下のように置き換えました。

```diff
+import 'moment/locale/ja';
+import moment from 'moment';

+moment.locale('en');
 if (i18n.language.startsWith('ja')) {
-  require('moment/locale/ja');
+  moment.locale('ja');
 }
```

- [Vite だと require() が使えないよ〜](https://azukiazusa.dev/blog/vite-require/)

## Uncaught TypeError: moment.duration(...).format is not a function

ここまでの変更で `yarn start` で起動してブラウザで動作することを確認できました。

しかし、 devtools の console に以下のエラーが出ています。

```
Uncaught TypeError: moment.duration(...).format is not a function
    at setDuration (index.tsx:39:37)
    at setTime (index.tsx:42:53)
    at index.tsx:46:42
```

`src/index.tsx` に以下を追加して解消しました。 ESM になった影響と思われます。

```ts
import momentDurationFormatSetup from "moment-duration-format";
// eslint-disable-next-line @typescript-eslint/no-explicit-any
momentDurationFormatSetup(moment as any);
```

なお [Moment.js](https://momentjs.com/) 自体が現在は非推奨とされているようです。今回のアプリケーションでは [date-fns](https://date-fns.org/) へと段階的に移行しています。

> We now generally consider Moment to be a legacy project in maintenance mode. It is not dead, but it is indeed done.
>
> https://momentjs.com/docs/#/-project-status/

## ESLint エラー: require() of ES Module .eslintrc.js from node_modules/@eslint/eslintrc/dist/eslintrc.cjs not supported.

公式サイトに以下の説明がありました。 `.eslintrc.cjs` にリネームして解消しました。

> **JavaScript (ESM)** - use `.eslintrc.cjs` when running ESLint in JavaScript packages that specify `"type":"module"` in their `package.json`. Note that ESLint does not support ESM configuration at this time.
>
> [Configuration Files - ESLint - Pluggable JavaScript Linter](https://eslint.org/docs/latest/use/configure/configuration-files#configuration-file-formats "https://eslint.org/docs/latest/use/configure/configuration-files#configuration-file-formats")

## global is not defined

特定の処理で `global is not defined` というエラーが発生することがありました。 Webpack ではこの変数がデフォルトで含まれていましたが、 Vite では設定をすることで含まれるようになります。

`vite.config.ts` を修正:

```diff
@@ -20,4 +20,7 @@ export default defineConfig({
       },
     ],
   },
+  define: {
+    global: 'window',
+  },
 });
```

- [vite import dragula error: global is not defined · Issue #2778 · vitejs/vite · GitHub](https://github.com/vitejs/vite/issues/2778#issuecomment-810086159)

## TypeError: Cannot read properties of undefined

class 構文を使っている処理で `TypeError: Cannot read properties of undefined` が発生することがありました。

TS のコンパイラオプションで `useDefineForClassFields` というものがあり、[Vite+React のテンプレート](https://github.com/vitejs/vite/blob/e0a6ef2b9e6f1df8c5e71efab6182b7cf662d18d/packages/create-vite/template-react-ts/tsconfig.json#L4)が true だったためそれに倣って設定していましたが、これにより class のトランスパイル結果が変わってエラーになっていました。

`tsconfig.json` を修正:

```diff
@@ -2,7 +2,7 @@
   "extends": "./tsconfig.paths.json",
   "compilerOptions": {
     "target": "ES2020",
-    "useDefineForClassFields": true,
+    "useDefineForClassFields": false,
     "lib": ["ESNext", "DOM", "DOM.Iterable"],
     "module": "ESNext",
     "skipLibCheck": true,
```

最近の React では class 構文はほとんど使わなくなっていますが、今回のアプリケーションでは一部にレガシーなコードベースが残っており、その中で以前のトランスパイル結果に依存している箇所があったようです。

- [特徴 | Vite](https://ja.vitejs.dev/guide/features.html#usedefineforclassfields)
- [TypeScript v3.7.2 変更点 #TypeScript - Qiita](https://qiita.com/vvakame/items/60d8d43ded0b160a99cc#%E3%82%88%E3%82%8A%E5%8E%B3%E5%AF%86%E3%81%AAes%E4%BB%95%E6%A7%98%E3%81%B8%E3%81%AE%E8%BF%BD%E5%BE%93%E3%81%A8-usedefineforclassfields-%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E8%BF%BD%E5%8A%A0)

# デプロイ関連のエラー

ここまでの変更でローカルでは問題なく動作するようになりました。次にデプロイ周りで起きた問題を記載します。

## CI デプロイジョブがエラー: The user-provided path ./build does not exist

ビルド結果の出力先ディレクトリ名が Vite のデフォルトは `dist` になっています。今までは `build` だったので、デプロイコマンドを変更しました。

## Cloudflare の最適化で JS ファイルが壊れる

デプロイはできたものの、アクセスしても何も表示されません。 devtools の console には以下のように出力されていました。

```
index-SKSNfXQs.js:3
Uncaught SyntaxError: Invalid or unexpected token (at index-SKSNfXQs.js:3:8090)

881 Unchecked runtime.lastError: A listener indicated an asynchronous response by returning true, but the message channel closed before a response was received
```

エラーの発生箇所を見ると、 minify されたコードですが `1.toString` という箇所でエラーになっていました。

```js
...Lot=Math.random(),Rot=jot(1.toString),OA=function(e){return"Symbol(...
                             ^^^^^^^^^^
```

原因は Cloudflare の最適化機能である minify によって JavaScript ファイルが変わってしまっていたためでした。

- ["Auto Minify" breaks javascript syntax](https://community.cloudflare.com/t/auto-minify-breaks-javascript-syntax/417399)

このアプリケーションは AWS S3 でホストして Cloudflare で配信する構成になっています。 Cloudflare の設定で minify をオフにすることで解消しました。[^1]

[^1]: 正確には Cloudflare の設定変更後、再度デプロイすると解消しました。

元のコード<br/>
`Rot=jot(1 .toString)` のスペースが除去されて<br/>
`Rot=jot(1.toString)` になって SyntaxError が起きていたようです。

これは [esbuild](https://esbuild.github.io/) によるビルド特有のようで、 Vite はビルドに esbuild を使用しているためこれが起きるようになりました。

- [Cloudflare Auto Minify breaks esbuild minified JS](https://community.cloudflare.com/t/cloudflare-auto-minify-breaks-esbuild-minified-js/547036)
- [Cloudflare Minification breaks esbuild's "1 .toString" · Issue #3116 · evanw/esbuild · GitHub](https://github.com/evanw/esbuild/issues/3116)

そもそもビルド時に minify しているので Cloudflare 側でさらに minify する意味はなかったわけですが、たまたまオンにしてしまっていました。

ところで `1 .toString` というコードは何を意味するのでしょうか。 minify された結果なのではっきりとはわかりませんが、 [Number.prototype.toString](https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Number/toString) を関数として取り出しているように見えます。書き方としては `(1).toString` と等価で、 `1 .toString` の方が 1 文字節約できるため esbuild がこのような出力をしているのだと思われます。

- [What happened inside of (1).toString() and 1.toString() in Javascript](https://stackoverflow.com/questions/38968598/what-happened-inside-of-1-tostring-and-1-tostring-in-javascript)

# Jest 関連の移行

のちに [Vitest](https://vitest.dev/) へと移行するのですが、まずは [Jest](https://jestjs.io/) のまま動かすことにしました。

## Jest をインストールしてみたがうまく動かない

インストールして多少の設定をしてみましたが、うまく動きませんでした。

```sh
yarn add -D jest @types/jest
```

テスト実行するとエラー:

```
ReferenceError: Jest: Got error running globalSetup - <snip>/jest-global-setup.js, reason: module is not defined in ES module scope
This file is being treated as an ES module because it has a '.js' file extension and '<snip>/package.json' contains "type": "module". To treat it as a CommonJS script, rename it to use the '.cjs' file extension.
    at file:///<snip>/jest-global-setup.js:3:1
    at ModuleJob.run (node:internal/modules/esm/module_job:194:25)
```

→ `jest-global-setup.cjs` にリネーム。ファイル内容も変更が必要で、 require を import に置き換えました。

この状態でテスト実行すると走り始めるようになりましたが、すべてのテストケースが以下のエラーになります。

> Jest encountered an unexpected token
>
> Jest failed to parse a file. This happens e.g. when your code or its dependencies use non-standard JavaScript syntax, or when Jest is not configured to support such syntax.
>
> Out of the box Jest supports Babel, which will be used to transform your files into valid JS based on your Babel configuration.

このアプローチは諦めて、 eject して必要な設定をしていくことにしました。

## eject 実行時のエラー

eject コマンドを実行したところエラーになりました。

```sh
❯ yarn run eject
NOTE: Create React App 2+ supports TypeScript, Sass, CSS Modules and more without ejecting: https://reactjs.org/blog/2018/10/01/create-react-app-v2.html

✔ Are you sure you want to eject? This action is permanent. … yes
Ejecting...

Out of the box, Create React App only supports overriding these Jest options:

  • clearMocks
  • collectCoverageFrom
  • coveragePathIgnorePatterns
  • coverageReporters
  • coverageThreshold
  • displayName
  • extraGlobals
  • globalSetup
  • globalTeardown
  • moduleNameMapper
  • resetMocks
  • resetModules
  • restoreMocks
  • snapshotSerializers
  • testMatch
  • transform
  • transformIgnorePatterns
  • watchPathIgnorePatterns.

These options in your package.json Jest configuration are not currently supported by Create React App:

  • testPathIgnorePatterns
  • collectCoverage

If you wish to override other Jest options, you need to eject from the default setup. You can do so by running npm run eject but remember that this is a one-way operation. You may also file an issue with Create React App to discuss supporting more options out of the box.
```

Jest の config から `testPathIgnorePatterns` と `collectCoverage` を削除して再実行すると eject できました。

## eject した設定から必要なものを残す

その後はこちらの記事の [Jest の CRA 依存を外す](https://zenn.dev/akineko/articles/765f8388e84c06#jest-%E3%81%AE-cra-%E4%BE%9D%E5%AD%98%E3%82%92%E5%A4%96%E3%81%99) に書いてあるとおり修正を行い、正常にテスト実行ができるようになりました。内容そのままなので詳細は記事に譲ります。

- [create-react-app から Vite への移行](https://zenn.dev/akineko/articles/765f8388e84c06)

## Vitest 移行

まずは Jest 環境を維持したまま移行したのですが、その後 Vitest に移行しました。次の記事を参照してください。

- [Jest から Vitest への移行](/posts/2024-03-31-migrate-to-vitest-from-jest)
