# [10/28 ブログ記事](http://blog.wacul.jp/blog/2014/10/28/go-rest-api/) 用サンプルプロジェクト

## 概要

* [prmd](https://github.com/interagent/prmd) を使って、JSON Schemaからドキュメントを生成する
* Go のAPI実装用のコードを自動生成する

詳細は、ブログ記事:  http://blog.wacul.jp/blog/2014/10/24/go-rest-api/

## ディレクトリ構成

```
Cakefile            # ビルドタスク定義
README.md
bin/                # ビルド用スクリプト
package.json
templates/          # 共通 go ファイル(自動生成時にパッケージ名だけ変えてコピーされる)
test/               # テスト用のスキーマ定義
    gen/            # 生成されたGoパッケージの出力先
    meta.yml        # prmd メタ情報
    overview.md     # ドキュメントのトップに挿入されるマークダウン
    schema.json     # prmd で出力される schemaファイル
    schema.md       # prmd で出力されるドキュメント
    schemata/       # prmd で使うスキーマ定義
test-build.sh       # ビルド用スクリプト
```

## 動かし方

```
npm install -g coffee-script 
gem install prmd
npm install -d
sh test-build.sh
```
