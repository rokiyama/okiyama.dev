---
title: CRA + TypeScript プロジェクト作成時のメモ
canonicalLink: cra-typescript-memo
date: 2020-06-04
draft: false
tags: ['memo', 'react', 'cra', 'typescript']
---

CRA で作り始める時の手順メモ。入門中なのでおかしい所があるかも。

## プロジェクト作成

参考: https://create-react-app.dev/docs/getting-started#creating-a-typescript-app

```bash
npx create-react-app myapp --template typescript
```

## prettier 追加

prettier と eslint の設定を追加する。

```bash
yarn add -D eslint-config-prettier eslint-plugin-prettier prettier
```

eslint-config-prettier は、一部ルールが prettier と eslint で重複するため、片方をオフにするためのパッケージ。

## eslintConfig 修正

元の `react-app` に `prettier/recommended` を追加。

デフォルト値が https://prettier.io/docs/en/options.html に記載されているので、変更したいものは設定する。

```diff:package.json
   "eslintConfig": {
-    "extends": "react-app"
+    "extends": [
+      "react-app",
+      "plugin:prettier/recommended"
+    ]
+  },
+  "prettier": {
+    "trailingComma": "all",
+    "semi": false,
+    "singleQuote": true,
+    "jsxSingleQuote": true
   },
```

## script 追加

lint (書式チェック) と format (書式修正) を追加する。

```diff:package.json
-    "eject": "react-scripts eject"
+    "eject": "react-scripts eject",
+    "lint": "eslint --ext .js,.jsx,.ts,.tsx ./src --color",
+    "format": "prettier --write ./src"
```
