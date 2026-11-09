# このブランチでのカスタマイズ

このリポジトリは [hitsmaxft/zmk-keyboard-cornix](https://github.com/hitsmaxft/zmk-keyboard-cornix) のフォークです。
このブランチ（`agent/zmk-studio-keymap`）では、上流の v3.0.0 / Zephyr 4.1 対応を土台に、キーマップと ZMK Studio まわりだけを変更しています。

## キーマップ

変更ファイル: `config/cornix.keymap`

- レイヤ名を用途が分かる名前に整理
  - `Base` / `Symbols` / `Function` / `Adjust` / `Navi` / `NumPad`
  - `Adjust` は `Raise` と `Lower` を同時押しで有効になる conditional layer
- ホームロウモッド（`hm_l` / `hm_r`）は維持
- 使っていなかった汎用 hold-tap（`hm`, `hm_shift_l`, `hm_shift_r`）を削除し、該当箇所は ZMK 標準の `&mt` / `&lt` に置換
- Shift 併用で Backspace が Delete になる `bspc_del`（mod-morph）を追加
- Adjust レイヤーに NumLock / Pause / Scroll Lock / Menu / `&sys_reset` / `&soft_off` を追加
- キー配置とレイヤ構成の早見表を `docs/keymap-cheatsheet.html` に追加（単体でブラウザで開ける）

## ZMK Studio 対応

変更ファイル: `build.yaml`, `boards/jzf/cornix/cornix.zmk.yml`, `boards/jzf/cornix/cornix_dongle_common.dtsi`

- `cornix_left` のビルドに `studio-rpc-usb-uart` スニペットを追加
  - dongle ビルド（`cornix_dongle_nosd`）は上流ですでに対応済み
- ボードメタデータに `studio` 機能を追加
- dongle に `zmk,physical-layout` を指定し、Studio からキー配置を扱えるようにした

使い方:

1. `cornix_left_default_nosd`（dongle なし）または `cornix_dongle_nosd`（dongle あり）を書き込む
2. セントラル側を USB 接続し、Chrome / Edge で [ZMK Studio](https://zmk.studio/) を開く
3. 右 half と `cornix_ph_left` はペリフェラルなので Studio は不要
4. Studio で加えた変更はキーボード側に保存される。新しい `.keymap` を反映するときは、書き込み後に Studio の **Restore Stock Settings** を実行する

## RGB インジケータ（任意）

`cornix_indicator` を有効にしたビルド（`cornix_left_indicator` / `cornix_right_indicator`）では、バッテリー残量と接続状態を RGB LED に表示する。通常のビルドには含まれない。

- Adjust レイヤーの `BAT` / `CON` で、バッテリー・接続状態をオンデマンド表示
- 表示は数秒で消灯し、アイドル 1 秒後に LED の電源レールが切れる
- 明るさは `CONFIG_RGBLED_WIDGET_BRIGHTNESS=64`（シールド側で設定）

## ローカルビルド環境

変更ファイル: `flake.nix`, `flake.lock` は上流のまま, `.envrc`, `.gitignore`, `Justfile`, `CMakeLists.txt`, `Kconfig`, `zephyr/module.yml`

```bash
direnv allow
just init      # 初回のみ: ZMK と各モジュールを取得
just build 'cornix_left_default_nosd$'
just build 'cornix_right_nosd$'
just build 'cornix_dongle_nosd$'
```

- ファームウェアは `firmware/` に出力される
- direnv を使わない場合は `nix develop --command just build '...'` でも可
- このリポジトリ自体を ZMK モジュールとして登録しているため、`west build` に `-DZMK_EXTRA_MODULES` を渡さなくてもボードとスニペットが認識される

## このブランチに含めていない変更

以前のブランチにあった次の変更は、キーマップと無関係なため取り込んでいません。

- `boards/jzf/cornix/Kconfig.defconfig` のデバウンス時間変更（3ms → 5ms）と条件分岐の整理

必要になった場合は、独立したコミットとして追加してください。
