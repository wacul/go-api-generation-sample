# Rest API 自動生成テスト

* [Hoge](#hoge)

## Hoge
テストAPI ですね


### Hoge ポストのテスト
テストのAPIです

改行


```
POST /hoge
```

#### Required Parameters
| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **email** | *email* | 招待先のメールアドレス | `"foo@bar.com"` |
| **name** | *string* | ユーザ名 | `"wacul太郎"` |
| **password** | *string* | ユーザパスワード<br/> **pattern:** <code>^[a-zA-Z0-9_]$</code> | `"jfoajiofaj932"` |


#### Optional Parameters
| Name | Type | Description | Example |
| ------- | ------- | ------- | ------- |
| **code** | *string* | 招待コード<br/> **pattern:** <code>^[a-z0-9]+$</code> | `"980ugajfaong9fanjnbakg"` |
| **hogeType** | *string* | <br/> **one of:**`"aiueo"` or `"kakikukeko"` |  |
| **nested1:boolSample** | *bool* | 数値(Number) | `false` |
| **nested1:intSample** | *integer* | 数値(int)<br/> **Range:** `1 <= value <= 100` | `50` |
| **nested1:numberSample** | *number* | 数値(Number)<br/> **Range:** `1.1 <= value <= 111.1` | `50.2` |
| **stringArraySample** | *array* | 文字配列 | `[nil]` |


#### Curl Example
```bash
$ curl -n -X POST https://sure.wacul.com/hoge \
  -H "Content-Type: application/json" \
 \
  -d '{
  "name": "wacul太郎",
  "code": "980ugajfaong9fanjnbakg",
  "email": "foo@bar.com",
  "password": "jfoajiofaj932",
  "stringArraySample": [
    null
  ],
  "hogeType": null,
  "nested1": {
    "intSample": 50,
    "numberSample": 50.2,
    "boolSample": false
  }
}'

```


#### Response Example
```
HTTP/1.1 201 Created
```
```json
{
}
```


