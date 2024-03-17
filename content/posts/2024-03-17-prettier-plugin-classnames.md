---
title: prettier-plugin-classnames でクラス名を改行する
date: 2024-03-17T16:49:36+09:00
tags: [memo, tailwind-css, prettier]
---

Tailwind CSS はクラス名の記述が長くなりがちという問題がある。

```jsx
<div className="transform bg-red-500 text-center text-xl text-red-900 duration-500 ease-in hover:bg-blue-500 hover:text-blue-900">
  ...
</div>
```

改行を入れることで多少改善するが、 Prettier にやって欲しいところ。

```jsx
<div
  className="transform bg-red-500 text-center text-xl text-red-900
    duration-500 ease-in hover:bg-blue-500 hover:text-blue-900"
>
  ...
</div>
```

公式の Prettier プラグインでも検討はされているが実装されていない[^1]。

[^1]: 一度実装されたが revert されたらしい: [Tailwind CSS のクラス属性長くなりがちな問題について](https://zenn.dev/makotot/articles/781b09850b4e6c#%E3%83%90%E3%83%AA%E3%82%A8%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E6%AF%8E%E3%81%AB%E5%88%86%E9%A1%9E%E3%81%99%E3%82%8B)

非公式であるが `prettier-plugin-classnames` というプラグインがクラス名を改行する機能を提供している。 ([Discussion のコメント](https://github.com/tailwindlabs/tailwindcss/discussions/7763#discussioncomment-7904679) より)

[prettier-plugin-classnames - npm](https://www.npmjs.com/package/prettier-plugin-classnames)

公式のプラグインと併用するには `prettier-plugin-merge` も必要。

[prettier-plugin-merge - npm](https://www.npmjs.com/package/prettier-plugin-merge)

```sh
pnpm install -D prettier-plugin-classnames prettier-plugin-merge
```

`.prettierrc`:

```diff
 {
   "singleQuote": true,
   "semi": false,
-  "plugins": ["prettier-plugin-tailwindcss"]
+  "plugins": [
+    "prettier-plugin-tailwindcss",
+    "prettier-plugin-classnames",
+    "prettier-plugin-merge"
+  ],
+  "endingPosition": "absolute-with-indent",
   "tailwindFunctions": ["clsx"]
 }
```

https://github.com/rokiyama/example-vite-react-app/blob/507b5f91df552016413fa53217f8f6d27c861c47/.prettierrc

`endingPosition` は改行位置を決めるもの。 `relative`, `absolute`, `absolute-with-indent` のいずれかを設定する。
デフォルトは `relative` であるが、 `absolute-with-indent` が自然な挙動に思えたので設定。
