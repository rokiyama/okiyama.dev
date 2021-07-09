---
title: Flutter 入門中のトラブルシューティング
date: 2021-07-09T14:22:50+09:00
draft: false
tags: [memo, flutter]
---

## android ライセンスでエラー

セットアップの手順に `flutter doctor --android-licenses` で正しく出力されることを確認する項目があるが、ここでエラーが発生した。

```fish
❯ flutter doctor --android-licenses
Exception in thread "main" java.lang.NoClassDefFoundError: javax/xml/bind/annotation/XmlSchema
        at com.android.repository.api.SchemaModule$SchemaModuleVersion.<init>(SchemaModule.java:156)
        at com.android.repository.api.SchemaModule.<init>(SchemaModule.java:75)
        at com.android.sdklib.repository.AndroidSdkHandler.<clinit>(AndroidSdkHandler.java:81)
        at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:73)
        at com.android.sdklib.tool.sdkmanager.SdkManagerCli.main(SdkManagerCli.java:48)
Caused by: java.lang.ClassNotFoundException: javax.xml.bind.annotation.XmlSchema
        at java.base/jdk.internal.loader.BuiltinClassLoader.loadClass(BuiltinClassLoader.java:581)
        at java.base/jdk.internal.loader.ClassLoaders$AppClassLoader.loadClass(ClassLoaders.java:178)
        at java.base/java.lang.ClassLoader.loadClass(ClassLoader.java:522)
        ... 5 more
```

Android Studio で設定を行うと解消した。

- Android Studio で設定を開き `Android SDK` を選択
- `SDK Tools` タブを選択
- `Android SDK Command-line tools` をチェックし Apply を実行

参考: https://stackoverflow.com/questions/61993738/flutter-doctor-android-licenses-gives-a-java-error/66363044

## エミュレータの選択でエラー

Chrome でのデバッグはできるが、デバイスから `Create Android emulator` を選ぶと `No device definitions are available` というエラーが発生するが、そもそも create する必要はない。

リストに既に `Pixel_3a` というエミュレータがあり、それを使えば良い。

## セキュリティソフトのファイアウォール機能を切っておかないと emulator が動作しない

セキュリティソフトの種類にもよるが、自分の環境ではオフにする必要があった。

## flutter_driver を追加した際に `incompatible` エラーが発生する

```fish
ERR : Because every version of flutter_driver from sdk depends on args 1.6.0 and flutter_launcher_icons 0.9.0 depends on args 2.0.0, flutter_driver from sdk is incompatible with flutter_launcher_icons 0.9.0.
And because no versions of flutter_launcher_icons match >0.9.0 <0.10.0, flutter_driver from sdk is incompatible with flutter_launcher_icons ^0.9.0.
So, because hello_world depends on both flutter_launcher_icons ^0.9.0 and flutter_driver any from sdk, version solving failed.
```

pubspec.yaml で flutter_launcher_icons を古いバージョンに変更して解消した。

```diff
- flutter_launcher_icons: ^0.9.0
+ flutter_launcher_icons: ^0.8.1
```

参考: https://github.com/fluttercommunity/flutter_launcher_icons/issues/241

## エラー `Unexpected text 'late'` が発生する

```fish
Unexpected text 'late'.
Try removing the text.dart(unexpected_token)
```

dart sdk のバージョンが古いことが原因。 `late` キーワードは dart 2.12.0 以降で使える。 pubspec.yaml でバージョン指定を変更すれば良い。

```diff
 environment:
-  sdk: ">=2.7.0 <3.0.0"
+  sdk: ">=2.12.0 <3.0.0"
```

参考: https://stackoverflow.com/questions/67113942/dart-unexpected-text-late

これを行うと以下のエラーが出るようになるが、これは null-safe ではないコードが残っているため。

エラー:

```fish
The non-nullable local variable 'driver' must be assigned before it can be used.
Try giving it an initializer expression, or ensure that it's assigned on every execution path.dart(not_assigned_potentially_non_nullable_local_variable)
```

以下のように、宣言時に初期化していないメンバー変数がある場合に発生する。これは `late` を追加すると解消する。

```diff
-    FlutterDriver driver;
+    late FlutterDriver driver;
```
