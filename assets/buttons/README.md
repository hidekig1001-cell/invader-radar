# assets/buttons/ のボタンの素材（見本 C、星を飾ったクリーム色）

ユーザーが 2026-10-16 に見本 A・B・C から C を選んだ（判断 D-20261016-2043-2）。画像生成のチャットが図形で描いた（tools/make_buttons.py）。見本の絵は mock_buttons_C.png（左が起動画面、右がゲーム中の画面）。

- button_normal.png・button_pressed.png・button_disabled.png: 360×140、透過、文字なし。StyleBoxTexture で 9 分割して伸ばす。

## 数値（button_spec.json の C）

```json
{
 "common": {},
 "C": {
  "title": "星を飾ったクリーム色（四隅に小さな星）",
  "states": {
   "normal": {
    "face": "#FFE38A",
    "edge": "#E0A83C",
    "line": "#5A3D12",
    "band": "#FFEDB3",
    "text": "#4A320A",
    "alpha": 255
   },
   "pressed": {
    "face": "#E0C879",
    "edge": "#C59435",
    "line": "#5A3D12",
    "band": "#E6D291",
    "text": "#4A320A",
    "alpha": 255
   },
   "disabled": {
    "face": "#CAC0B6",
    "edge": "#A19082",
    "line": "#64564F",
    "band": "#DDD6D0",
    "text": "#4E4A60",
    "alpha": 140
   }
  }
 }
}
```
