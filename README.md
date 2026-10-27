# Yabadabadoo-Pak

[Yabadabadoo](https://github.com/ProRapSuperstarOriginalMaster/Yabadabadoo)（Yabause ベースのセガサターン用 libretro コア）を
[NextUI](https://github.com/LoveRetro/NextUI) 用のエミュレータ Pak（`SATURN.pak`）としてパッケージングしたものです。

Packages the Yabadabadoo Sega Saturn libretro core as a NextUI emulator pak (`SATURN.pak`) for
`tg5040` (TrimUI Smart Pro / Brick), `tg5050` (TrimUI Smart Pro S) and `h700` (Anbernic RG*XX).

## インストール

[Releases](../../releases) から次のどちらかをダウンロードします。

- `Yabadabadoo.pakz` — SD カードのルートに置いて再起動すると、NextUI が起動時に自動で展開します。
- `Yabadabadoo-<version>.zip` — SD カードのルートに展開します。

どちらも以下を追加します（3 プラットフォーム分すべて入っています）。

    Emus/tg5040/SATURN.pak/
    Emus/tg5050/SATURN.pak/
    Emus/h700/SATURN.pak/
    Bios/SATURN/
    Roms/Sega Saturn (SATURN)/

## BIOS

実機のサターン BIOS が必要です（同梱していません）。`Bios/SATURN/` に次のいずれかを置いてください。

| ファイル名        | 内容                | MD5                                |
| ----------------- | ------------------- | ---------------------------------- |
| `sega_101.bin`    | Japan v1.01         | `85ec9ca47d8f6807718151cbcca8b964` |
| `mpr-17933.bin`   | USA/Europe v1.00    | `3240872c70984b6cbfda1586cab68dbe` |
| `saturn_bios.bin` | 上記のどれかを改名  |                                    |

## ゲーム

`Roms/Sega Saturn (SATURN)/` に置きます。対応形式: `.cue`（+ `.bin`）, `.chd`, `.iso`, `.mds`, `.ccd`, `.m3u`（複数ディスク）, `.zip`。
フォルダ名末尾の `(SATURN)` で `SATURN.pak` が選ばれるので、フォルダ名を変える場合もこのタグは残してください。

ログは `.userdata/<platform>/logs/SATURN.txt` に出力されます。

## 注意事項

- Yabadabadoo は Miyoo Mini（32 ビット ARM）向けに調整されたコアです。SH-2 の動的リコンパイラは 32 ビット ARM / x86 専用のため、
  aarch64 の本 Pak ではインタプリタで動作します。そのため重いゲームは速度が出ないことがあります。
- CPU 速度は既定で `Performance` にしています（`default.cfg`）。ゲーム中のメニュー > Options から変更できます。
- 上流の README にある通り、Miyoo Mini 以外は上流で公式にサポートされていない実験的なコアです。
  NextUI の作者もサードパーティ Pak のサポートは行っていません。不具合はまずこのリポジトリの Issues へどうぞ。

## ビルド

上流のソースはサブモジュール `yabadabadoo/` として固定しています。ビルドには Docker（または Podman）を使い、
NextUI 公式のツールチェーンイメージ `ghcr.io/loveretro/<platform>-toolchain` の中でクロスコンパイルします。

    git clone --recursive https://github.com/elderica/Yabadabadoo-Pak.git
    cd Yabadabadoo-Pak
    make            # 3 プラットフォームをビルドして dist/ にパッケージを作成
    make tg5040     # 1 プラットフォームだけビルド（build/tg5040/）
    make package    # build/ にあるコアから dist/ を作成

ツールチェーンのシェル内で直接ビルドする場合は `make core PLATFORM=tg5040` を使います。

## リリース

GitHub Actions（`.github/workflows/build.yml`）が push と pull request のたびに 3 プラットフォームをビルドし、
パッケージを Actions の成果物としてアップロードします。`v` で始まるタグを push するとリリースページに
`.zip` と `.pakz` が公開されます。

    git tag v0.3-1
    git push origin v0.3-1

上流の新しいバージョンに追従するには、サブモジュールを更新してコミットします。

    git -C yabadabadoo fetch --tags
    git -C yabadabadoo checkout <新しいタグ>
    git add yabadabadoo
    git commit -m "Update Yabadabadoo to <新しいタグ>"

## ライセンス

このリポジトリのスクリプト類は MIT License（`LICENSE`）です。Pak に含まれる Yabadabadoo コアは GPL v2 以降で、
各 Pak に `LICENSE-yabadabadoo.txt` と `THIRD-PARTY-NOTICES.txt` を同梱しています。コアのソースコードは
サブモジュールが指す上流リポジトリのコミット（リリース時のタグ）です。

Sega and Sega Saturn are trademarks of Sega. This project is not affiliated with or endorsed by Sega.
No BIOS files or games are included.
