# Design: vitest5 を 5.0.0-beta.6 に追従

## 方針

`origin/vitest5` から作業ブランチ `chore/vitest5-beta6` を作成し、`origin/main` を
マージ（4 衝突を解消）した上でバージョンを beta.6 に更新。PR は **base=`vitest5`**
に対して作成する（main へのマージではない）。

## 衝突解消方針（main マージ時）

| ファイル | 解消方針 |
|---------|---------|
| `package.json` | main 由来の oxfmt/oxlint スクリプト・devDeps・`packageManager` を採用しつつ、`vitest`/`@vitest/coverage-v8` を `5.0.0-beta.6`、`version` を `0.2.0-beta.6`、`peerDependencies.vitest` を `^4.0.0 \|\| ^5.0.0-0` に維持 |
| `pnpm-lock.yaml` | main 版を採用後 `pnpm install` で再生成（beta.6 を反映） |
| `README.md` | v5 beta の Development 注記 + main の oxfmt/oxlint 行を統合 |
| `changelog.po` | マーカーを main 側で解消 → `make update-po` で正式再生成 → beta.6 の msgstr を記入 |

## バージョン更新

- `vitest`: `5.0.0-beta.5` → `5.0.0-beta.6`
- `@vitest/coverage-v8`: `5.0.0-beta.5` → `5.0.0-beta.6`
- package `version`: `0.2.0-beta.5` → `0.2.0-beta.6`

## ドキュメント

- `sphinx-docs/user/changelog.md` に `0.2.0-beta.6 (2026-07-10)` エントリ追加。
- `changelog.po` に対応する日本語訳を記入（空・fuzzy を残さない）。
