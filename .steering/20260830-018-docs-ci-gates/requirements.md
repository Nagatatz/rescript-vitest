# 要求定義: Sphinx ドキュメント CI ゲートの補完

| 項目 | 内容 |
|---|---|
| 機能名 | Sphinx ドキュメント CI ゲートの補完 |
| 作成日 | 2026-08-30 |
| ステータス | 完了（PR #27 マージ済み） |

## 1. 背景と目的

### 背景

2026-08-30 のレビュー（`.steering/20260830-017-review-fixes-and-release/`）で、`sphinx-docs/` の品質ゲートが Makefile 上には定義されているが CI で実行されていない箇所が残った:

- `docs.yml` の `lint-and-test` ジョブが `make typecheck`（mypy）と `make check-po`（pofilter）を実行していない
- `dependabot.yml` が `sphinx-docs/pyproject.toml`（uv）と `sphinx-docs/package.json`（pa11y-ci）を監視していない
- `sphinx-docs/tests/` が空の `__init__.py` のみで、Makefile `test` が pytest の exit 5（テスト未収集）を成功扱いにしているため CI の Pytest ステップが空振り
- `make a11y`（pa11y-ci による WCAG2AA チェック）がどこからも実行されていない

また `make check-po` をローカル実行したところ、017 で記入した `.po` に **重複した `msgstr` 行**（`setup.po` 4 件 / `installation.po` 4 件 / `project-structure.po` 1 件）があり pofilter が構文エラーを出すことが判明した。Sphinx（babel）は寛容に読むため HTML ビルドでは検出されなかった。

### 目的

Makefile に定義済みの品質ゲートをすべて CI で実行し、`.po` の構文エラーのような回帰を自動検出できるようにする。あわせて依存関係更新の監視範囲を `sphinx-docs/` まで広げる。

## 2. 変更・追加する機能の説明

1. **`.po` 修正** — 重複 `msgstr` 行を除去し `make check-po` を通す
2. **`docs.yml`** — `lint-and-test` に `make typecheck` / `make check-po` を追加。`build` ジョブに `make a11y` 相当のステップを追加
3. **`dependabot.yml`** — `uv`（`/sphinx-docs`）と `npm`（`/sphinx-docs`）のエコシステムを追加
4. **`sphinx-docs/tests/`** — 実効性のある pytest を追加し、Makefile `test` の exit 5 吸収を撤去
   - `test_po_translations.py`: 日本語 `.po` の構文（重複 msgstr 等）と、プロース msgid の `msgstr` 未記入を検出（documentation.md「日英二言語の同時整備」規約のテスト化）
   - `test_po_coverage.py`: `user/` `dev/` `index.md` の各ソースに対応する `.po` が存在する
   - `test_conf.py`: `conf.py` の `release` が `package.json` の `version` と一致する

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | メンテナ | 英語ソースだけ更新し `.po` を空のまま PR を出す | docs CI の Pytest が失敗する |
| 2 | メンテナ | `.po` を壊した状態で PR を出す | `make check-po` / pytest が失敗する |
| 3 | メンテナ | `conf.py` に型エラーのある Python を追加する | `make typecheck` が失敗する |
| 4 | メンテナ | アクセシビリティを損なうテンプレート変更を入れる | `a11y` ステップが失敗する |
| 5 | メンテナ | Sphinx / pa11y-ci に更新がある | Dependabot が PR を作る |

## 4. 受け入れ条件

- [x] `make check-po` がローカルで exit 0（pofilter の Syntax error なし）
- [x] `make typecheck` / `make test` / `make check` がローカルで exit 0 で、pytest がテストを収集・実行している
- [x] `docs.yml` に typecheck / check-po / a11y のステップがあり、PR の docs CI が green
- [x] `dependabot.yml` に `uv` と `npm`（`/sphinx-docs`）のエントリがある
- [x] 追加した pytest が「未訳のプロース msgid」を実際に検出する（一時的に msgstr を空にして Red を確認）

## 5. 制約事項

- pa11y-ci は Chromium を必要とする。`ubuntu-latest` では puppeteer 同梱の Chromium が動くが、ローカル（WSL）で動かない場合は CI 上でのみ検証する
- 既存の `.po` で `msgstr` が空のエントリは、コード / 識別子 / バージョン見出しのみ（規約の例外）。テストの「プロース判定」はこれらを誤検出しないヒューリスティックにする
- 最小変更原則: Makefile の `a11y` ターゲットの構造は変えない（CI から呼ぶだけ）

## 6. 関連ドキュメント

- `.claude/rules/documentation.md` — 日英二言語の同時整備（必須）
- `.steering/20260830-017-review-fixes-and-release/` — 発端のレビュー
- `sphinx-docs/Makefile` — `check` / `check-po` / `a11y` の定義
