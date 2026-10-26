# CR-1180 の依頼の直し（改修28 の依頼の検査で出た error 5 件、10/26）

## 直したもの
- **drafts/req_cr1180.txt の依頼の欄（YAML）だけを直した**。本文・確かめる項目・probe・try_1180_patch.py は変えていない。
  - `decls` から `"func vibrate(ms: int, amplitude: float = -1.0) -> void"` を消した。`decls` に残したのは `"var vibration_amplitudes: Array = []"` だけ。
  - 今ある宣言の形を変えることとして、`changes` を足した:
    ```yaml
    changes:
      scenes/sound.gd:
      - from: "func vibrate(ms: int) -> void"
        to: "func vibrate(ms: int, amplitude: float = -1.0) -> void"
    ```
  - `changes` の書き方の前例は、このリポジトリのどの branch の req_cr*.txt と .autedev/notes にも無かった。from／to の形は決めて書いた。AuteDev の欄の名前や形が違えば合わせてほしい（例: `changes: {scenes/sound.gd: ["func vibrate(ms: int) -> void → ..."]}`）。

## error ごとの見立て
1. **C66（vibrate がすでにある、C3）**: 上の直しで消える見込み。
2〜5. **R-RED（実行時エラーの new・start_tutorial／中身のない版で表明で落ちない CHECK 1・5）**: 1 が元になっていた。手元で同じ形を作って確かめた。
   - **今の main に decls の `func vibrate(ms: int, amplitude ...)` を中身なしで「足した」版（sC）**: sound.gd が `Function "vibrate" has the same name as a previously declared function` で読めなくなった。そこから次の 2 つの誤りが出て、検査の誤りの文と同じになった。
     - CHECK 1: `Nonexistent function 'new' in base 'GDScript'`
     - CHECK 5: `Nonexistent function 'start_tutorial' in base 'Nil'`（main.tscn が Sound を読めず、m が null）
   - **changes の形の版**: 次の 2 つで、probe の 5 件を流した。どちらも 5 件すべてが表明だけで落ち、SCRIPT ERROR は 0 件だった。
     - 宣言どおりの形で中身のない版（sA）: `vibrate(ms, amplitude = -1.0)` の中身は `pass`、`vibration_amplitudes` は []。
     - 形だけ替えて中身は今のままの版（sB）: `vibrations` には ms を足し、`vibration_amplitudes` には足さない。
     - 例: CHECK 1 は `[] != [30, 15]`、CHECK 5 は `[] != [30]` と `[] != [-1.0, 0.4]`。
   - なので probe は直していない。今の main（直しなし）で probe の 4 件が落ちるのは、`vibrate(15, 0.4)` の引数の数と、まだ無い `vibration_amplitudes` を見ているためで、新しい形を確かめる項目として想定どおり。
- CR-1181・CR-1182 の依頼は変えていない（decls は空で、changes も要らない）。

## 流したもの（Godot 4.7.2、main e6cf4ca の写し）
- sA・sB・sC の 3 つの写しで、test/cr/test_cr_1180.gd（probe）を流した。
- 直した依頼と try_1180_patch.py の組み合わせは前と同じなので、前の当て試しの結果がそのまま使える。probe 5 件は通り、既存で落ちるのは test_cr_1177 の 1 件だけ（変わる既存のテストのとおり）。
