---
title: Jest から Vitest への移行
date: 2024-03-31T10:15:16+09:00
tags: [log, jest, vitest]
---

[前回の記事](/posts/2024-03-30-migrate-to-vite-from-create-react-app) では [Vite](https://vitejs.dev/) に移行しましたが、テストは [Jest](https://jestjs.io/) のままでした。今回は [Vitest](https://vitest.dev/) に移行した際のログです。

## ライブラリのインストール

[happy-dom](https://github.com/capricorn86/happy-dom) だと通らなくなるテストがいくつかありました。 `screen.getByRole` などの取得ができないなどがあり、今回は [jsdom](https://github.com/jsdom/jsdom) で進めることにしました。

```sh
yarn add -D vitest jsdom
```

`package.json` の scripts を変更しておきます。

```diff
     "start": "vite",
     "build": "tsc && vite build",
     "preview": "vite preview",
-    "test": "jest",
-    "test-coverage": "jest --coverage --watchAll=false",
+    "test": "vitest",
+    "test-coverage": "vitest --coverage",
     "compile": "tsc",
     "lint": "eslint src/**/*.ts src/**/*.tsx --quiet && prettier --check .",
     "verify-code": "yarn compile && yarn lint",
```

## 設定

`vitest.config.ts` を作成:

```ts
import { defineConfig, mergeConfig } from "vitest/config";
import viteConfig from "./vite.config";

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      globals: true,
      environment: "jsdom",
    },
  })
);
```

`globals: true` を設定すると、テストコードで `describe`, `it`, `vi` などを import せず使えるようになります。これらの型定義を使えるようにするため tsconfig にも設定が必要です。

`tsconfig.json` を修正:

```diff
     "strict": true,
     //"noUnusedLocals": true,
     //"noUnusedParameters": true,
-    "noFallthroughCasesInSwitch": true
+    "noFallthroughCasesInSwitch": true,
+
+    /* Vitest */
+    "types": ["vitest/globals"]
   },
   "include": ["src", "graphql/codegen.ts"],
   "references": [{ "path": "./tsconfig.node.json" }],
```

また、 `vitest.config.ts` が型チェックに含まれるようにします。

`tsconfig.node.json` を修正:

```diff
     "moduleResolution": "bundler",
     "allowSyntheticDefaultImports": true
   },
-  "include": ["vite.config.ts", ".eslintrc.cjs"]
+  "include": ["vite.config.ts", "vitest.config.ts", ".eslintrc.cjs"]
 }
```

### testPathIgnorePatterns を exclude に移行

Jest 使用時は以下のように testPathIgnorePatterns を正規表現で指定して、ファイル名が `_` で始まるファイルを除外していました。

```json
{
  "testPathIgnorePatterns": ["__tests__/_(.)+.ts(x)?$"]
}
```

Vitest の exclude は glob pattern を指定します。また `defaultExclude` を含めるようにします。

```diff
-import { defineConfig, mergeConfig } from 'vitest/config';
+import { defineConfig, mergeConfig, defaultExclude } from 'vitest/config';
 import viteConfig from './vite.config';

 export default mergeConfig(
   viteConfig,
   defineConfig({
     test: {
       globals: true,
+      exclude: [...defaultExclude, '**/__tests__/_*.ts', '**/__tests__/_*.tsx'],
```

## テストエラー対応

### エラー Invalid Chai property: toHaveTextContent

`toHaveTextContent` の呼び出しでエラーになりいました。 これは `@testing-library/jest-dom` の提供するメソッドです。 `setupTests.ts` に import を追加し、このファイルをロードするよう設定します。

`src/setupTests.ts` を作成:

```ts
import "@testing-library/jest-dom";
```

`vitest.test.config` を修正:

```diff
     test: {
       globals: true,
       exclude: [...defaultExclude, '**/__tests__/_*.ts', '**/__tests__/_*.tsx'],
       environment: 'happy-dom',
+      setupFiles: ['./src/setupTests.ts'],
     },
   }),
 );
```

### クラス名が scoped のものになっていてセレクタで取れずアサーション失敗

このアプリケーションでは module css (scss) を使用しています。 Jest で実行していた際は元のクラス名で render されていたのが、 scoped なクラス名になっていました。

```diff
-      <div class="Info" >
+      <div class="_Info_78db8b" >
```

これをテストで `expect(container.querySelector(".Info")).toHavTextContent(...)` としていて、取得できずエラーになりました。

Jest を使っていた時は [identity-obj-proxy](https://www.npmjs.com/package/identity-obj-proxy) を使ってこの問題に対処していました。 Vitest では以下の設定で対処できます。

```diff
       globals: true,
       exclude: [...defaultExclude, '**/__tests__/_*.ts', '**/__tests__/_*.tsx'],
       environment: 'jsdom',
       setupFiles: ['./src/setupTests.ts'],
+      css: {
+        modules: {
+          classNameStrategy: 'non-scoped',
+        },
+      },
     },
   }),
 );
```

- [Configuring Vitest | Vitest](https://vitest.dev/config/#css-modules-classnamestrategy)

### jest-global-setup.cjs を移行

`jest-global-setup.cjs` で dotenv のロードなどをしていたので移行します。 TypeScript ファイルに変更し、 `vitest.config.ts` でこのファイルをロードするようにします。

```diff
       globals: true,
       exclude: [...defaultExclude, '**/__tests__/_*.ts', '**/__tests__/_*.tsx'],
       environment: 'jsdom',
       setupFiles: ['./src/setupTests.ts'],
+      globalSetup: ['./src/vitestGlobalSetup.ts'],
       css: {
         modules: {
           classNameStrategy: 'non-scoped',
```

### expected "spy" to not be called at all, but actually been called 1 times

特定のケースでモックのアサーションが失敗していました。

```
AssertionError: expected "spy" to not be called at all, but actually been called 1 times

Received:
  1st spy call:
    Array []

Number of calls: 1
```

モックのリセットをしていないことが原因でした。

`vitest.config.ts` を修正:

```diff
      globalSetup: ['./src/vitestGlobalSetup.ts'],
      css: {
        modules: {
           classNameStrategy: 'non-scoped',
         },
       },
+      mockReset: true,
    },
  }),
);
```

### Vitest テスト実行がハングアップする問題

テストがハングアップする問題が起きました。具体的には、コマンドを実行して特定のテストで止まり、そのまま応答がなくなるもののプロセスは動き続けています。

`setupTests.ts` にモックを追加していたのですが、この定義方法に問題がありました。

```ts
vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key: string) => key,
  }),
});
```

`useTranslation` の戻り値のプロパティ `t` がコード内で `useCallback` の依存配列に含まれているとハングアップが発生します。この定義方法だと `t` が毎回新しい関数オブジェクトになるため、 `useCallback` が無限ループのような状態になっていたものと思われます。

以下のように `t` をトップレベルの変数に変更すると解消しました。

```ts
const t = (key: string) => key;
vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t,
  }),
});
```

ちなみに `vi.mock` はファイル上部に移動されます (巻き上げ)。変数定義を `vi.mock` よりも前にしたい場合 `vi.hoisted` を使います。

```ts
const t =  vi.hoisted((key: string) => key);
vi.mock('react-i18next', () => ({
  useTranslation: () => ({
    t,
  }),
});
```

- [ESM の mock 巻き上げ問題と Vitest の vi.hoisted について](https://zenn.dev/ptna/articles/617b0884f6af0e)

## テストコード修正

jest 関数を置換していきます。

- `jest.fn` => `vi.fn`
- `jest.mock` => `vi.mock`
- `jest.requireActual` => `await vi.importActual`
- `jest.spyOn` => `vi.spyOn`

### vi.importActual

`vi.importActual` は Promise を返すため以下のような変更が必要でした。

```diff
@@ -33,8 +33,8 @@ import {
 const mockedNavigate = vi.fn();
-jest.mock('react-router-dom', () => ({
-  ...jest.requireActual('react-router-dom'),
+vi.mock('react-router-dom', async () => ({
+  ...(await vi.importActual('react-router-dom')),
   useNavigate: () => mockedNavigate,
 }));
```

`requireActual` で複数行にわたるものがなかったため正規表現で一括置換できました。 (ただし外側の関数に async をつけるのは手動)

- pattern: `jest\.requireActual\('(.*?)'\)`
- replace: `(await vi.importActual('$1'))`

### spyOn, mockImplementation

mockImplementation に何も渡していないコードがあり、 jest ではこの場合元の処理が使われます。つまりアサーションでコール回数を数えるためだけのために spyOn を使っているということです。

今回は単に削除で対応できました。

```diff
-  const mocked = vi.spyOn(MyClass, 'method').mockImplementation();
+  const mocked = vi.spyOn(MyClass, 'method');
```

### 型エラー `vi.fn<void, []>()`

```diff
-vi.fn<void, []>()
+vi.fn<[], []>()
```

## close timed out after 10000ms

テスト実行の終了後にこのメッセージが表示されて、プロセスが終了しない状態になりました。

> close timed out after 10000ms
> Failed to terminate worker while running `<snip>.test.tsx`.
> See https://vitest.dev/guide/common-errors.html#failed-to-terminate-worker for troubleshooting.
> Tests closed successfully but something prevents Vite server from exiting
> You can try to identify the cause by enabling "hanging-process" reporter. See https://vitest.dev/config/#reporters

ドキュメントの通り `vitest.config.ts` に `pool: 'forks'` を設定して解消しました。

```diff
      css: {
        modules: {
          classNameStrategy: 'non-scoped',
        },
      },
      mockReset: true,
+     pool: 'forks',
    },
```

- [Common Errors | Guide | Vitest](https://vitest.dev/guide/common-errors.html#failed-to-terminate-worker)

## 移行完了

最後に Jest で使っていた設定ファイル、パッケージを削除して完了です。

```sh
rm babel.config.json
yarn remove babel-preset-vite identity-obj-proxy
```

ここまでの修正でほぼ全てのテストが通るようになりました。

Jest を使っていた頃と比べると、テストの実行速度が上がっておよそ半分の時間で実行できるようになりました。 Node v18 から v20 へのアップデートでさらに半分になり、当初の 4 倍速くなりました。
