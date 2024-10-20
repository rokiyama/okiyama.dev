---
title: pnpm コマンドのシェル補完
date: 2024-10-20T16:52:17+09:00
tags: [memo, fish, pnpm]
---

fish の場合以下コマンドで設定する。

```fish
pnpm completion fish > ~/.config/fish/completions/pnpm.fish
```

[Command line tab-completion | pnpm](https://pnpm.io/completion)

最近まで知らずに設定していなかった。
内容は執筆時点では以下のようになっていて、将来変更された時にコマンド再実行が必要になるかもしれない。

```fish
###-begin-pnpm-completion-###
function _pnpm_completion
  set cmd (commandline -o)
  set cursor (commandline -C)
  set words (count $cmd)

  set completions (eval env DEBUG=\"" \"" COMP_CWORD=\""$words\"" COMP_LINE=\""$cmd \"" COMP_POINT=\""$cursor\"" SHELL=fish pnpm completion-server -- $cmd)

  if [ "$completions" = "__tabtab_complete_files__" ]
    set -l matches (commandline -ct)*
    if [ -n "$matches" ]
      __fish_complete_path (commandline -ct)
    end
  else
    for completion in $completions
      echo -e $completion
    end
  end
end

complete -f -d 'pnpm' -c pnpm -a "(_pnpm_completion)"
###-end-pnpm-completion-###
```
