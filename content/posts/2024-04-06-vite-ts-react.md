---
title: Vite, TypeScript, React のセットアップ
date: 2024-04-06T13:45:40+09:00
tags:
  - memo
  - vite
  - typescript
  - react
  - prettier
  - eslint
  - tailwindcss
  - redux-toolkit
  - react-router
  - vitest
  - react-testing-library
  - msw
  - storybook
---

Vite で TypeScript の React プロジェクトを作る手順のメモです。

Tailwind や Redux など常に必要なわけではないライブラリも含まれるのでご注意ください。

# プロジェクト作成

以前は Create React App というツールが使われていましたが、現在ではメンテナンスされていないようです。

- [Create React App は役割を終えました](https://zenn.dev/nekoya/articles/dd0f0e8a2fa35f)
- [Vite にたどり着くまで（Webpack 以降のモジュールバンドラー振り返り）](https://zenn.dev/ishiyama/scraps/a8abf192857f9f)

[公式](https://react.dev/learn/start-a-new-react-project) には [Next.js](https://nextjs.org/) や [Remix](https://remix.run/) が推奨されていますが、フレームワークを使わずに始めたい場合は [Vite](https://vitejs.dev/) がよく使われるようです。

- [はじめに | Vite](https://ja.vitejs.dev/guide/#%E6%9C%80%E5%88%9D%E3%81%AE-vite-%E3%83%95%E3%82%9A%E3%83%AD%E3%82%B7%E3%82%99%E3%82%A7%E3%82%AF%E3%83%88%E3%82%92%E7%94%9F%E6%88%90%E3%81%99%E3%82%8B)

テンプレートに [`react-ts`](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) を指定して作成します。

```sh
pnpm create vite@latest --template react-ts <app-name>
```

`.node-version` ファイルを作成しておきます。

```sh
# .node-version を作成
node -v > .node-version
# もしくは major version のみ記載する場合
node -p 'process.versions.node.split(".")[0]' > .node-version
```

# Prettier

[Install · Prettier](https://prettier.io/docs/en/install)

コードフォーマッターです。テンプレートのスタイルに合わせて singleQuote と semi を設定します。

```sh
pnpm install -D prettier eslint-config-prettier

echo '{
  "singleQuote": true,
  "semi": false
}' > .prettierrc

echo pnpm-lock.yaml > .prettierignore
```

`.eslintrc.cjs` の extends に追加:

```diff
@@ -5,6 +5,7 @@ module.exports = {
     'eslint:recommended',
     'plugin:@typescript-eslint/recommended',
     'plugin:react-hooks/recommended',
+    'prettier',
   ],
   ignorePatterns: ['dist', '.eslintrc.cjs'],
   parser: '@typescript-eslint/parser',
```

`package.json` の scripts にコマンドを追加:

```diff
@@ -7,7 +7,8 @@
     "dev": "vite",
     "build": "tsc && vite build",
     "lint": "eslint . --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
-    "preview": "vite preview"
+    "preview": "vite preview",
+    "format": "prettier --write ."
   },
   "dependencies": {
     "react": "^18.2.0",
```

フォーマットを適用します。

```sh
❯ pnpm run format
```

## @trivago/prettier-plugin-sort-imports

https://github.com/trivago/prettier-plugin-sort-imports

import をソートするプラグインです。

```sh
pnpm install -D @trivago/prettier-plugin-sort-imports
```

`.pretterrc` を修正:

```diff
@@ -1,4 +1,6 @@
 {
   "singleQuote": true,
-  "semi": false
+  "semi": false,
+  "plugins": ["@trivago/prettier-plugin-sort-imports"],
+  "importOrder": ["<THIRD_PARTY_MODULES>", "^[./]"]
 }
```

# ESLint の追加設定

テンプレートの ESLint の設定はいくつかの recommended 設定が最初から有効ですが、 `@typescript-eslint/recommended-type-checked` も追加します。

## @ts-check をオンにする

`.eslintrc.cjs` を修正:

```diff
@@ -1,3 +1,6 @@
+// @ts-check
+
+/** @type {import('eslint').Linter.Config} */
 module.exports = {
   root: true,
   env: { browser: true, es2020: true },
```

## @typescript-eslint/recommended-type-checked をオンにする

[no-floating-promises](https://typescript-eslint.io/rules/no-floating-promises/) などのルールが含まれる設定です。

`.eslintrc.cjs` を修正:

```diff
@@ -7,11 +7,15 @@ module.exports = {
   extends: [
     'eslint:recommended',
     'plugin:@typescript-eslint/recommended',
+    'plugin:@typescript-eslint/recommended-type-checked',
     'plugin:react-hooks/recommended',
     'prettier',
   ],
   ignorePatterns: ['dist', '.eslintrc.cjs'],
   parser: '@typescript-eslint/parser',
+  parserOptions: {
+    project: ['./tsconfig.json', './tsconfig.node.json'],
+  },
   plugins: ['react-refresh'],
   rules: {
     'react-refresh/only-export-components': [
```

## tsconfig の noUnused... をオフ + ESLint の @typescript-eslint/no-unused-vars を warn に

noUnusedLocals と noUnusedParameters を無効にし、 ESLint の [@typescript-eslint/no-unused-vars](https://typescript-eslint.io/rules/no-unused-vars/) を warn にします。

`tsconfig.json`:

```diff
@@ -16,9 +16,10 @@

     /* Linting */
     "strict": true,
-    "noUnusedLocals": true,
-    "noUnusedParameters": true,
+    "noUnusedLocals": false,
+    "noUnusedParameters": false,
     "noFallthroughCasesInSwitch": true
   },
   "include": ["src"],
   "references": [{ "path": "./tsconfig.node.json" }]
```

`.eslintrc.cjs`:

```diff
@@ -22,5 +22,6 @@ module.exports = {
       'warn',
       { allowConstantExport: true },
     ],
+    '@typescript-eslint/no-unused-vars': 'warn',
   },
 }
```

この設定は tsconfig と ESLint で重複するため ESLint に任せることにします。また新しい変数を書いたそばからエラーになるのは邪魔に感じるため、個人的には error でなく warn にしたい。

@typescript-eslint/no-unused-vars は recommended 設定だと error に設定されているため、 warn に変更しています。この場合 CI で warn を許さないようにチェックするとよいでしょう。

## tsconfig の compileOptions noUncheckedIndexedAccess を有効にする

[noUncheckedIndexedAccess | TypeScript 入門『サバイバル TypeScript』](https://typescriptbook.jp/reference/tsconfig/nouncheckedindexedaccess)

`"strict": true` で有効にならないオプションですが、配列を安全に扱うのに有用なので設定しておきます。

```diff
@@ -16,9 +16,10 @@

     /* Linting */
     "strict": true,
     "noUnusedLocals": false,
     "noUnusedParameters": false,
+    "noFallthroughCasesInSwitch": true,
+    "noUncheckedIndexedAccess": true
   },
   "include": ["src"],
   "references": [{ "path": "./tsconfig.node.json" }]
```

# Tailwind CSS

[Install Tailwind CSS with Vite - Tailwind CSS](https://tailwindcss.com/docs/guides/vite)

CSS フレームワークです。

```sh
pnpm install -D tailwindcss postcss autoprefixer

# 設定ファイルは TypeScript を選択
pnpx tailwindcss init --ts --postcss
```

`tailwind.config.ts` を修正:

```diff
 import type { Config } from 'tailwindcss'

 export default {
-  content: [],
+  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
   theme: {
     extend: {},
   },
   plugins: [],
 } satisfies Config
```

`index.css` を修正:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## tsconfig.node.json に tailwind ファイルを含める

この状態で lint を実行すると以下のエラーが発生します。

```sh
pnpm run lint
#(snip)
<snip>/tailwind.config.ts
  0:0  error  Parsing error: ESLint was configured to run on `<tsconfigRootDir>/tailwind.config.ts` using `parserOptions.project`:
- <snip>/tsconfig.json
- <snip>/tsconfig.node.json
```

`tsconfig.node.json` の include に `tailwind.config.ts` を追加すると解消します。

```diff
@@ -7,5 +7,5 @@
     "allowSyntheticDefaultImports": true,
     "strict": true
   },
-  "include": ["vite.config.ts"]
+  "include": ["vite.config.ts", "tailwind.config.ts"]
 }
```

## prettier-plugin-tailwindcss

[Editor Setup - Tailwind CSS](https://tailwindcss.com/docs/editor-setup#automatic-class-sorting-with-prettier)
https://github.com/tailwindlabs/prettier-plugin-tailwindcss

`className` をソートする Tailwind 公式の Prettier プラグインです。

```sh
pnpm install -D prettier-plugin-tailwindcss
```

`.prettierrc` を修正:

```diff
 {
   "singleQuote": true,
   "semi": false,
-  "plugins": ["@trivago/prettier-plugin-sort-imports"],
+  "plugins": ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
+  "importOrder": ["<THIRD_PARTY_MODULES>", "^[./]"]
 }
```

## clsx

https://github.com/lukeed/clsx

クラス名を結合する関数を提供するライブラリで、条件付きでクラスを切り替えたりする場合に使います。
同種のツールでより高機能な tailwind-merge が存在しますが、今回は clsx を選択。

- https://github.com/dcastil/tailwind-merge

```sh
pnpm install clsx
```

`.pretterrc` を修正:

```diff
   "plugins": ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
-  "importOrder": ["<THIRD_PARTY_MODULES>", "^[./]"]
+  "importOrder": ["<THIRD_PARTY_MODULES>", "^[./]"],
+  "tailwindFunctions": ["clsx"]
 }
```

## prettier-plugin-classnames

長いクラス名を改行する Prettier プラグインです。詳細は [prettier-plugin-classnames でクラス名を改行する | okiyama.dev](https://okiyama.dev/posts/2024-03-17-prettier-plugin-classnames/) を参照。

```sh
pnpm install -D prettier-plugin-classnames prettier-plugin-merge
```

`.prettierrc` を修正:

```diff
 {
   "singleQuote": true,
   "semi": false,
-  "plugins": ["@trivago/prettier-plugin-sort-imports", "prettier-plugin-tailwindcss"],
+  "plugins": [
+    "@trivago/prettier-plugin-sort-imports",
+    "prettier-plugin-tailwindcss",
+    "prettier-plugin-classnames",
+    "prettier-plugin-merge"
+  ],
+  "endingPosition": "absolute-with-indent",
   "tailwindFunctions": ["clsx"]
 }
```

# Redux Toolkit, react-redux

[Installation | Redux](https://redux.js.org/introduction/installation)

ステート管理ライブラリです。 Redux Toolkit が出てから以前にもまして重量級の雰囲気ですが、 Toolkit の流儀に従っておけばボイラープレートも少なくシンプルに書けるようになっています。

[redux](https://www.npmjs.com/package/redux) は [@reduxjs/toolkit](https://www.npmjs.com/package/@reduxjs/toolkit) の依存に含まれているため個別にインストールする必要はなく、このふたつだけでよいです。

```sh
pnpm install @reduxjs/toolkit react-redux
```

`src/redux/store.ts` を作成:

```ts
import { configureStore } from "@reduxjs/toolkit";

export const rootReducer = {};

export const setupStore = () => {
  const store = configureStore({
    reducer: rootReducer,
  });
  // TODO: hot reloading の設定
  return store;
};

type AppStore = ReturnType<typeof setupStore>;
export type AppState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
```

`src/redux/hooks.ts` を作成:

```ts
import { useDispatch, useSelector } from "react-redux";
import { AppDispatch, AppState } from "./store";

export const useAppDispatch = useDispatch.withTypes<AppDispatch>();
export const useAppSelector = useSelector.withTypes<AppState>();
```

`src/main.tsx` を修正:

```diff
@@ -2,9 +2,15 @@ import React from 'react'
 import ReactDOM from 'react-dom/client'
 import App from './App.tsx'
 import './index.css'
+import { Provider } from 'react-redux'
+import { setupStore } from './redux/store.ts'
+
+const store = setupStore()

 ReactDOM.createRoot(document.getElementById('root')!).render(
   <React.StrictMode>
-    <App />
+    <Provider store={store}>
+      <App />
+    </Provider>
   </React.StrictMode>,
 )
```

## 課題: Redux のホットリロード

ホットリロードの設定方法が書かれていますが、 Vite だとうまく動作しませんでした。

[Configuring Your Store | Redux](https://redux.js.org/usage/configuring-your-store#hot-reloading)

このように設定してみたのですが、ファイル保存時にページ全体がリロードされてしまう。未解決です。

```ts
// rootReducer を ./reducers.ts に移動したうえで以下を追加
if (import.meta.env.DEV && import.meta.hot) {
  import.meta.hot.accept("./reducers", async () =>
    store.replaceReducer((await import("./reducers")).rootReducer)
  );
}
```

関連するかもしれない Discussion: https://github.com/reduxjs/redux-toolkit/discussions/4281

# React Router

[Tutorial v6.22.3 | React Router](https://reactrouter.com/en/main/start/tutorial#setup)

ルーターライブラリです。この例は React Router ですが、今新しく始めるなら [TanStack Router](https://tanstack.com/router/latest) もよいかもしれません。

```sh
pnpm install react-router-dom
```

`main.tsx` を修正:

```diff
 import React from 'react'
 import ReactDOM from 'react-dom/client'
 import { Provider } from 'react-redux'
+import { RouterProvider, createBrowserRouter } from 'react-router-dom'
 import App from './App.tsx'
 import './index.css'
 import { setupStore } from './redux/store.ts'

 const store = setupStore()

+const router = createBrowserRouter([
+  {
+    path: '/',
+    element: <App />,
+  },
+])
+
 ReactDOM.createRoot(document.getElementById('root')!).render(
   <React.StrictMode>
     <Provider store={store}>
-      <App />
+      <RouterProvider router={router} />
     </Provider>
   </React.StrictMode>,
 )
```

# Vitest

[Getting Started | Guide | Vitest](https://vitest.dev/guide/)

テストフレームワークです。 DOM ライブラリである [happy-dom](https://github.com/capricorn86/happy-dom/wiki/Getting-started) もインストールします。

```sh
pnpm install -D vitest happy-dom
```

`vitest.config.ts` を作成:

```ts
import { defineConfig, mergeConfig } from "vitest/config";
import viteConfig from "./vite.config";

export default mergeConfig(
  viteConfig,
  defineConfig({
    test: {
      globals: true,
      environment: "happy-dom",
    },
  })
);
```

`globals: true` の設定で `describe`, `test` などをインポートせずに使えるようになります。この設定を使う場合は tsconfig の設定も必要です。

`tsconfig.json` を修正:

```diff
@@ -19,7 +19,10 @@
     "noUnusedLocals": false,
     "noUnusedParameters": false,
     "noFallthroughCasesInSwitch": true,
-    "noUncheckedIndexedAccess": true
+    "noUncheckedIndexedAccess": true,
+
+    /* Vitest */
+    "types": ["vitest/globals"]
   },
   "include": ["src"],
   "references": [{ "path": "./tsconfig.node.json" }]
```

また、このファイルも `tsconfig.node.json` の `include` に追加しておきます。

`tsconfig.json` を修正:

```diff
@@ -7,5 +7,5 @@
     "allowSyntheticDefaultImports": true,
     "strict": true
   },
-  "include": ["vite.config.ts", "tailwind.config.ts"]
+  "include": ["vite.config.ts", "vitest.config.ts", "tailwind.config.ts"]
 }
```

## React Testing Library, user-event, jest-dom

- [React Testing Library | Testing Library](https://testing-library.com/docs/react-testing-library/intro)
- [Installation | Testing Library](https://testing-library.com/docs/user-event/install)
- [jest-dom | Testing Library](https://testing-library.com/docs/ecosystem-jest-dom)

テストコードでの DOM 要素の取得やアサーションに使うライブラリです。

```sh
pnpm install -D @testing-library/react @testing-library/user-event @testing-library/jest-dom
```

`vitest-setup.ts` を追加:

```ts
import "@testing-library/jest-dom/vitest";
```

`vitest.config.ts` を修正:

```diff
@@ -7,6 +7,7 @@ export default mergeConfig(
     test: {
       globals: true,
       environment: 'happy-dom',
+      setupFiles: ['./vitest-setup.ts'],
     },
   }),
 )
```

`tsconfig.json` を修正:

```diff
@@ -24,6 +24,6 @@
     /* Vitest */
     "types": ["vitest/globals"]
   },
-  "include": ["src"],
+  "include": ["src", "vitest-setup.ts"],
   "references": [{ "path": "./tsconfig.node.json" }]
 }
```

## MSW

[Mock Service Worker - API mocking library for browser and Node.js](https://mswjs.io/)

テストで HTTP API, GraphQL API をモック化するのに使います。 [React Testing Library のドキュメント](https://testing-library.com/docs/react-testing-library/example-intro/) でも推奨されていました。

```sh
pnpm install -D msw@latest
```

`src/__mocks__/server.ts` を作成:

```ts
import { http, HttpResponse } from "msw";
import { setupServer } from "msw/node";

export const server = setupServer(
  http.get("https://example.com/greeting", () => {
    return HttpResponse.json({ greeting: "hello there" });
  })
);
```

`src/setupTests.ts` を作成:

```ts
import { server } from "./__mocks__/server";

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

`vitest-setup.ts` に追記:

```diff
@@ -1 +1,6 @@
 import '@testing-library/jest-dom/vitest'
+import { server } from './src/__mocks__/server'
+
+beforeAll(() => server.listen())
+afterEach(() => server.resetHandlers())
+afterAll(() => server.close())
```

以下のようにテストします。

```ts
import { HttpResponse, http } from "msw";
import { server } from "../__mocks__/server";

it("api success", async () => {
  const res = await fetch("https://example.com/greeting");
  expect(await res.json()).toStrictEqual({ greeting: "hello there" });
});

it("api error", async () => {
  server.use(
    http.get("https://example.com/greeting", () => {
      return new HttpResponse(null, { status: 500 });
    })
  );
  const res = await fetch("https://example.com/greeting");
  expect(res.status).toBe(500);
});
```
