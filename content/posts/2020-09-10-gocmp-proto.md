---
title: Golang の go-cmp で protobuf の struct を Diff する時、 cannot handle unexported field のような panic になる場合は protocmp.Transform() を試してみると良い
canonicalLink: go-cmp-diff-protobuf
date: 2020-09-11
draft: false
tags: ['memo', 'golang', 'protobuf']
---

https://pkg.go.dev/google.golang.org/protobuf/testing/protocmp より:

> The primary feature is the Transform option, which transform proto.Message types into a Message map that is suitable for cmp to introspect upon. All other options in this package must be used in conjunction with Transform.


before

```
	if diff := cmp.Diff(want, got); diff != "" {
		t.Errorf("mismatch (-want +got):\n%s", diff)
	}
```

after

```
	if diff := cmp.Diff(want, got, protocmp.Transform()); diff != "" {
		t.Errorf("mismatch (-want +got):\n%s", diff)
	}
```

サンプルコードは https://pkg.go.dev/github.com/google/go-cmp/cmp?tab=doc#example-Diff-Testing を参照。
