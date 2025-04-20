---
title: Next.js, next-intl のセットアップ
date: 2025-04-20T18:29:36+09:00
tags: [memo, nextjs, react]
---

## プロジェクト作成

[create-next-app](https://nextjs.org/docs/app/api-reference/cli/create-next-app) コマンドで作成する。

パッケージマネージャに pnpm を使用。そのほかデフォルトでないものとしては Tailwind CSS に Yes を指定。

```sh
$ pnpx create-next-app@latest --use-pnpm example-nextjs

✔ Would you like to use TypeScript? … Yes
✔ Would you like to use ESLint? … Yes
✔ Would you like to use Tailwind CSS? … Yes
✔ Would you like your code inside a `src/` directory? … No
✔ Would you like to use App Router? (recommended) … Yes
✔ Would you like to use Turbopack for `next dev`? … Yes
✔ Would you like to customize the import alias (`@/*` by default)? … No
```

`.node-version` ファイルを作成する:

```sh
# .node-version を作成
$ node -v > .node-version

# もしくは major version のみ記載する場合
$ node -p 'process.versions.node.split(".")[0]' > .node-version
```

## 依存パッケージを追加

パッケージをいくつか追加する。

- i18n ライブラリである [next-intl](https://next-intl.dev/)
- Tailwind CSS とあわせてよく使われる [tailwind-variants](https://www.tailwind-variants.org/)
- ESLint と Prettier 関連
	- [eslint-plugin-tailwindcss](https://github.com/francoismassart/eslint-plugin-tailwindcss) は 2025-04-20 時点で Tailwind CSS v4 に対応していないため除外

```sh
# dependencies
$ pnpm add tailwind-variants next-intl

# devDependencies
$ pnpm add -D \
    prettier \
    eslint-config-prettier \
    @trivago/prettier-plugin-sort-imports \
    prettier-plugin-classnames \
    prettier-plugin-merge \
    prettier-plugin-tailwindcss \
```

## ESLint 設定

prettier と TypeScript の未使用変数に関する設定を追加。

```diff
--- a/eslint.config.mjs
+++ b/eslint.config.mjs
@@ -1,16 +1,27 @@
+// @ts-check
+import eslintConfigPrettier from "eslint-config-prettier";
 import { dirname } from "path";
 import { fileURLToPath } from "url";
 import { FlatCompat } from "@eslint/eslintrc";

 const __filename = fileURLToPath(import.meta.url);
 const __dirname = dirname(__filename);

 const compat = new FlatCompat({
   baseDirectory: __dirname,
 });

 const eslintConfig = [
   ...compat.extends("next/core-web-vitals", "next/typescript"),
+  eslintConfigPrettier,
+  {
+    rules: {
+      "@typescript-eslint/no-unused-vars": [
+        "warn",
+        { argsIgnorePattern: "^_" },
+      ],
+    },
+  },
 ];

 export default eslintConfig;
```

## Prettier 設定

import のソート、 Tailwind CSS のクラス名のソートと改行を行うプラグインを有効化。

`.prettierrc` を作成:

```json
{
  "plugins": [
    "@trivago/prettier-plugin-sort-imports",
    "prettier-plugin-tailwindcss",
    "prettier-plugin-classnames",
    "prettier-plugin-merge"
  ],
  "importOrder": ["<THIRD_PARTY_MODULES>", "^@/", "^[./]"],
  "tailwindFunctions": ["tv"],
  "customFunctions": ["tv"],
  "endingPosition": "absolute-with-indent",
  "experimentalOptimization": true
}
```

なお `tailwindFunctions` は [prettier-plugin-tailwindcss](https://github.com/tailwindlabs/prettier-plugin-tailwindcss) の設定で、 `customFunctions` は [prettier-plugin-classnames](https://github.com/ony3000/prettier-plugin-classnames) の設定。

ignore リストに pnpm の lockfile を入れておく。

```sh
$ echo pnpm-lock.yaml >> .prettierignore
```

`package.json` のスクリプト定義に `"format": "prettier --write ."` を追加し、コマンド実行してフォーマットを適用しておく。

```sh
$ pnpm run format
```

## next-intl 設定

ドキュメントの通り設定する。

[App Router setup with i18n routing – Internationalization (i18n) for Next.js](https://next-intl.dev/docs/getting-started/app-router/with-i18n-routing)

- `messages/ja.json` と `messages/en.json` を作成
- `next.config.ts` を変更
- `i18n/navigation.ts` を作成
- `i18n/request.ts` を作成
- `middleware.ts` を作成
- `i18n/routing.ts` を作成
- `app/layout.tsx` を `app/[locale]/layout.tsx` に移動、修正
- `app/page.tsx` を `app/[locale]/page.tsx` に移動、修正

追加で TypeScript 型定義の設定を行う。

[TypeScript augmentation – Internationalization (i18n) for Next.js](https://next-intl.dev/docs/workflows/typescript)

`global.d.ts` を作成:

```ts
import { routing } from "@/i18n/routing";
import messages from "@/messages/ja.json";

declare module "next-intl" {
  interface AppConfig {
    Locale: (typeof routing.locales)[number];
    Messages: typeof messages;
  }
}
```

開発サーバを起動し、ブラウザで `http://localhost:3000` を開く。

`http://localhost:3000/ja` にリダイレクトされてページが表示されれば OK。
