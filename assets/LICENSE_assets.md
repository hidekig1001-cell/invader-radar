# assets/ の画像素材について

- 生成: FLUX.2 [klein] 4B（Apache License 2.0、商用利用可）で、2026-10-16 に生成した。
- 透過: BiRefNet（MIT License）で背景を抜いた。
- 生成の手順と候補は、作業 PC の D:\AI\imagegen\assets\invader_radar\README.md にある。
- piece_pink.png は seed 11 の候補（本命の seed 12 は目がつぶれて見えたため）。ほかの駒・×・小惑星は seed 12、bg_1080x1920.png は seed 13、title_bg_1080x1920.png は seed 23。
- autedev_logo.png（1024×1024、背景は透過）: AuteDev のロゴ。「AuteDev」の文字は 2026-10-18 に FLUX.2 [klein] 4B（Apache 2.0）で Mac mini で生成したものの画素のまま。左の絵は 2026-10-19 にユーザーの絵（青い丸に緑の丸 3 つ）をもとに図形として描き直した（画像生成モデル2 のチャット）。起動時の最初の画面に出す。
- piece_*.png（駒 6 色と置きすぎ用の赤い困った顔、a 豆の形）と rock.png（岩、a 顔なし）: 512×512、背景は透過。2026-10-24 に FLUX.2 [klein] 4B（Apache 2.0）で Mac mini で生成し、6 色はピンクの駒の体の色だけ色相を回して作った（画像生成モデル3 のチャット）。ユーザーが選んだ（D-20261024-1347＝A・1347-2＝A）。作り方は作業 PC の F:\AI\imagegen\assets\invader_radar\pieces_kawaii\README.md にある。前の piece_*.png（10/16 の版）は置き換えた。
- title_logo.png（800×359、背景は透過）: タイトル画面の「INVADER RADAR」のロゴ（2 行、INVADER がミント・RADAR がピンク、宇宙人のアンテナ）。2026-10-24 に FLUX.2 [klein] 4B（Apache 2.0）で Mac mini で生成し、綴りを目で確かめて選んだ（画像生成モデル3 のチャット）。ユーザーが選んだ（D-20261024-1317＝A）。作り方は作業 PC の F:\AI\imagegen\assets\invader_radar\title_logo_kawaii\README.md にある。
- piece_<色>_2.png・piece_<色>_3.png・piece_<色>_4.png（6 色×3、256×256、背景は透過）: 駒の宇宙人のポーズ違い（2＝手を振る、3＝跳ねる、4＝ウインク）。2026-10-24 に、元の piece_<色>.png を土台に手・閉じた目・影を図形で足して作った（モデルは使わない。画像生成モデル3 のチャット）。ユーザーの判断 D-20261024-2059＝A（1 色 4 ポーズ）。
- piece_pink.png・piece_orange.png を、白目の透けを直した版に置き換えた（2026-10-24、同じチャット）。作り方は作業 PC の F:\AI\imagegen\assets\invader_radar\poses\README.md にある。
- rules/rules_1.png〜rules_7.png（960×720）: チュートリアルの前の説明のページの図（目的・色・行と列・となり・数字のマス・岩・操作）。2026-10-24 に、ゲームの素材（駒・岩）を組み合わせて作り、指と星は FLUX.2 [klein] 4B（Apache 2.0）で作った（画像生成モデル3 のチャット）。ユーザーの判断 D-20261024-2114＝B。作り方は作業 PC の F:\AI\imagegen\assets\invader_radar\rules\README.md にある。
- piece_pink.png・piece_orange.png を、黒目のあるかわいい版（512×512、5db1c80 で入った絵）に戻した（2026-10-25、画像生成モデル4 のチャット）。10/24 の白目の直しが古い丸い絵柄から作られ、黒目が消えていたため。
- piece_<色>_2.png・piece_<色>_3.png・piece_<色>_4.png（6 色×3）を、同じ色のかわいい版のふつうのポーズから作り直した（512×512、背景は透過、手を振る・跳ねる・ウインクを図形で描いた。モデルは使わない。2026-10-25、画像生成モデル4 のチャット）。作り方は作業 PC の F:\AI\imagegen\assets\invader_radar\pupils_1025\README.md にある。
