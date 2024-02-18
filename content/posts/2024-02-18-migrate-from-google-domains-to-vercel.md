---
title: ドメイン名を Google Domains から Vercel に移管した
date: 2024-02-18T16:02:41+09:00
tags: [memo]
---

このサイトのドメイン名 `okiyama.dev` を Google Domains から Vercel に移管しました。

もともと Google Domains で購入したドメイン名でしたが、 Google Domains のサービス終了がアナウンスされ Squarespace に移管される予定になっていました。

[Squarespace への Google Domains のドメイン登録の譲渡について - Google Domains ヘルプ](https://support.google.com/domains/answer/13689670?hl=ja)

そのまま Squarespace に移行しても構わなかったのですが、ホスティングを Vercel で行っている関係でドメインの管理も同じサービスに任せることにしました。

以下の手順で移管を行いました。

- Google Domains
  - ドメインのロックを解除
  - 認証コードを取得
- Vercel
  - クレジットカードを登録しておく (設定画面 → Payment method)
  - Domains から Transfer In よりドメイン名と認証コードを入力
  - 元のレジストラの確認待ちと、カスタム DNS ゾーンの設定移行を促すダイアログが表示される
    - 今回はゾーンの設定は不要なので、移行が完了するまで待つ
- Google Domains
  - 移管の承認・キャンセルのメールが届くので、リンクから承認する
- Vercel
  - ドメイン移管完了のメールが届く

今回は Google Domains から承認確認のメールが届くまで 10 分程度、 Vercel から移管完了のメールが届くまで 1 時間程度かかりました。

参考

- [Google Domains から別の登録事業者に移管する - Google Domains ヘルプ](https://support.google.com/domains/answer/3251178?sjid=1035049167829836067-AP)
- [Transferring Domains to Another Team or Project](https://vercel.com/docs/projects/domains/transfer-your-domain#transfer-a-domain-to-vercel)
