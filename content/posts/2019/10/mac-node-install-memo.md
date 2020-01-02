---
title: mac node インストールメモ
canonicalLink: mac-node-install-memo
date: 2019-10-03
published: true
tags: ['mac', 'node']
---

## nvm は git clone で入れる

brew ではインストールしないこと。 (参照: [nvm/README.md at master · nvm-sh/nvm](https://github.com/nvm-sh/nvm/blob/master/README.md))

```bash
git clone https://github.com/nvm-sh/nvm.git .nvm
```

## nvm で node をインストールする

```bash
nvm install node && nvm alias default node
```

## yarn は brew install で入れる

```bash
brew install yarn --ignore-dependencies
```

## fish shell の場合

[FabioAntunes/fish-nvm: nvm wrapper for fish-shell](https://github.com/FabioAntunes/fish-nvm) をインストールする。
