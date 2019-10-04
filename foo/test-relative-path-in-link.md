## GitHub Web 上のリンクのパスの書き方色々

- [x.txt](x.txt) 相対パス。
- [bar/y.txt](bar/y.txt) 相対パス。
- [/x.txt](/x.txt) ルート相対パス、これはアクセスできない。
- [/README.md](/README.md) ルート相対パス、これはアクセスできる。
  - これでもブランチやコミットハッシュのパスに対しては相対になってくれる。
- [https://github.com/kjirou/github-playground/blob/master/README.md](https://github.com/kjirou/github-playground/blob/master/README.md) URL。
