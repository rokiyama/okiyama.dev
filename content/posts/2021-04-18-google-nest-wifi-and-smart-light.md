---
title: Google Nest Wifi ルーターで 2.4GHz のみ対応の IoT デバイスをセットアップする方法
date: 2021-04-18T19:44:12+09:00
draft: false
tags: [memo, IoT]
---

Google Nest Wifi ルーターと拡張ポイントを買った。

https://store.google.com/jp/product/nest_wifi

スマホのアプリが良く、セットアップがとても簡単だった。

今まで経験したことがあるのは、たいてい web の設定画面を開いて無線の設定を行うとかだった。 Nest Wifi は Google Home アプリまたは Google Wifi アプリから設定するのだが、最初に繋ぐときはアプリが勝手にやってくれるため SSID などの入力は必要ない (Bluetooth あるいはスマホを Wifi AP にして接続するらしい)。

電源の抜き差しを何度か行った際にインターネット接続がなかなか復帰しないことがあったが、それ以外は特に問題なく使えている。 LAN 側の Ethernet ポートが一個しかない点は少し不便。

つまづいたのが、 2.4GHz と 5GHz が同じ SSID なので 2.4GHz のみ対応のスマート照明に 5GHz で繋がっているスマホから接続できず、セットアップを行えないという問題。なお照明は [+Style というメーカーの製品](https://amzn.to/3mVS1UR) である。

2.4GHz と 5GHz の SSID を分けるのは Nest Wifi ではできないらしい。スマホが 2.4GHz だけに繋がれば良いのだが、今持っているものはそのように設定できない。 2.4GHz のみ対応の古い Fire HD タブレットがあったが、これは Amazon のカスタム OS が入っており +Style のアプリを入れるのがやや面倒だ。

+Style のアプリにはスマホを一時的に Wifi AP にしてセットアップする互換モードという方式が用意されている。今回はこれを使うことでうまくいったが、このような機能がない製品の場合はいくつか対応手段がある。

1. 2.4GHz のみ対応の古いスマホを買う
2. 2.4GHz で接続される程度に家から離れてからセットアップする
3. Nest Wifi を停止した状態でスマホを Wifi AP にし、 Nest Wifi で使う SSID/WPA キーと同じものにしてデバイスを接続・セットアップする

2 の家から離れるというのは、 5GHz は遠くまで届かないが 2.4GHz は低周波で遠くまで届く特性があり、両方の周波数に対応しているスマホは 5GHz に優先して接続するが、ルーターから離れて電波が減衰すると 2.4GHz にフォールバックするのでその状態で IoT デバイスのセットアップをする、ということらしい。

参考: [How do force Google Wifi to 2.4 Ghz only? - Google Nest Community](https://support.google.com/googlenest/thread/611640)
