---
title: QMK Firmware でキーマップの変更とコンパイル、自作キーボードへの書き込みを行う
date: 2023-02-23T13:26:33+09:00
tags: [memo,qmk,自作キーボード]
---

[QMK Firmware](https://qmk.fm/ja/) でキーマップの変更とコンパイル、自作キーボードへの書き込みを行う手順のメモです。

[meishi2](https://shop.yushakobo.jp/products/834?variant=37665283571873) という自作キーボード初心者向けのキットで実施しました。

## インストール・セットアップ

macOS の場合、 Homebrew でインストールします。

```sh
brew install qmk/qmk/qmk
```

インストール後にセットアップコマンドを実行します。

```sh
qmk setup
```

セットアップ中に [公式リポジトリ](https://github.com/qmk/qmk_firmware/) の git clone が行われます。事前に任意の場所に clone しておき、そのパスを指定することもできます。

```sh
qmk setup -H ~/ghq/github.com/qmk/qmk_firmware
```

## ファイル作成

QMK のリポジトリ `qmk_firmware` のディレクトリに移動します。このリポジトリの `keyboards/` ディレクトリに、様々なキーボードのキーマップ設定が収められているようです。

meishi2 の場合は以下のディレクトリです。

`keyboards/biacco42/meishi2/keymaps/`

以下のコマンドを実行すると、このディレクトリにある `default` をコピーして、新たなディレクトリが作成されます。

```sh
qmk new-keymap -kb biacco42/meishi2
```

実行すると、名前の入力を求めるプロンプトになります。

```sh
Keymap Name:
```

適当に `my_meishi2` と名付けることにして、プロンプトに入力して enter を入力します。すると、次のように表示されます。

```sh
Ψ my_meishi2 keymap directory created in: /Users/okiyama/ghq/github.com/qmk/qmk_firmware/keyboards/biacco42/meishi2/keymaps/my_meishi2
Ψ Compile a firmware with your new keymap by typing:

        qmk compile -kb biacco42/meishi2 -km my_meishi2
```

メッセージの通り、 `my_meishi2` という名前のディレクトリが作成されます。作成されたファイルを編集し、任意のキーマップに変更します。

## コンパイル・書き込み

以下のコマンドを実行すると、指定したキーマップでファームウェアがコンパイルされます。

```sh
qmk compile -kb biacco42/meishi2 -km my_meishi2
```

コンパイルのログが表示されます。以下は成功時のログです。

```sh
Ψ Compiling keymap with gmake --jobs=1 biacco42/meishi2:my_meishi2


QMK Firmware 0.19.12
Making biacco42/meishi2 with keymap my_meishi2

avr-gcc (Homebrew AVR GCC 8.5.0) 8.5.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Size before:
   text    data     bss     dec     hex filename
      0   20354       0   20354    4f82 biacco42_meishi2_my_meishi2.hex

Compiling: quantum/keymap_introspection.c                                                           [OK]
Compiling: quantum/command.c                                                                        [OK]
Linking: .build/biacco42_meishi2_my_meishi2.elf                                                     [OK]
Creating load file for flashing: .build/biacco42_meishi2_my_meishi2.hex                             [OK]
Copying biacco42_meishi2_my_meishi2.hex to qmk_firmware folder                                      [OK]
Checking file size of biacco42_meishi2_my_meishi2.hex                                               [OK]
 * The firmware size is fine - 20354/28672 (70%, 8318 bytes free)
```

コンパイルに成功したので、キーボードに書き込みます。以下のコマンドを実行します。

```sh
qmk flash -kb biacco42/meishi2 -km my_meishi2
```

実行すると (このとき再びコンパイルが行われるようです)、以下のようにキーボードのリセット待ち状態になります。

```sh
Ψ Compiling keymap with gmake --jobs=1 biacco42/meishi2:my_meishi2:flash
# snip
 * The firmware size is fine - 20354/28672 (70%, 8318 bytes free)
Flashing for bootloader: caterina
Waiting for USB serial port - reset your controller now (Ctrl+C to cancel)......
```

ここでまだキーボードを接続していなければ接続し、リセットスイッチを押します。するとキーボードが認識され、書き込みが行われる様子がログで流れます。

```sh
Device /dev/tty.usbmodem101 has appeared; assuming it is the controller.
Waiting for /dev/tty.usbmodem101 to become writable.

Connecting to programmer: .
Found programmer: Id = "CATERIN"; type = S
    Software Version = 1.0; No Hardware Version given.
Programmer supports auto addr increment.
Programmer supports buffered memory access with buffersize=128 bytes.

Programmer supports the following devices:
    Device code: 0x44

avrdude: AVR device initialized and ready to accept instructions

Reading | ################################################## | 100% 0.00s

avrdude: Device signature = 0x1e9587 (probably m32u4)
avrdude: NOTE: "flash" memory has been specified, an erase cycle will be performed
         To disable this feature, specify the -D option.
avrdude: erasing chip
avrdude: reading input file ".build/biacco42_meishi2_my_meishi2.hex"
avrdude: input file .build/biacco42_meishi2_my_meishi2.hex auto detected as Intel Hex
avrdude: writing flash (20354 bytes):

Writing | ################################################## | 100% 1.57s

avrdude: 20354 bytes of flash written
avrdude: verifying flash memory against .build/biacco42_meishi2_my_meishi2.hex:
avrdude: input file .build/biacco42_meishi2_my_meishi2.hex auto detected as Intel Hex

Reading | ################################################## | 100% 0.17s

avrdude: 20354 bytes of flash verified

avrdude done.  Thank you.
```

上記のように `avrdude done` と表示されれば完了で、キーボードとして使える状態になります。

## 補足

QMK Firmware を使ったファームウェア書き込みは最も基本的な方法の一つですが、他にもいくつかツールがあり、 2023 年現在は [Remap](https://remap-keys.app/) が人気のようです。
