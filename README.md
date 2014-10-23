# ドキュメント、コード自動生成

## バリデーション

### string

JSON Schemaの以下をサポートする

* enum
* minLength
* maxLength
* pattern
* format

以下のルールでバリデーションが適用される

* enumがある場合
    * enum のみ適用
* enumがない場合
    * minLenght, maxLengthを適用
    * patternがある場合
        * patternを適用
    * patternがない場合
        * format があれば適用

対応フォーマットは以下

* email
