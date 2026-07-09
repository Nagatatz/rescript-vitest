# 要求定義: oxlint/oxfmt による JS/JSON 整形・lint 導入

| 項目 | 内容 |
|---|---|
| 機能名 | oxlint/oxfmt による JS/JSON 整形・lint 導入 |
| 作成日 | 2026-06-30 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

本リポジトリは ReScript バインディングを主体とし、JS の大半は `.res.js`（ReScript コンパイル生成物、`.gitignore` 済み）である。一方で手書きの非 ReScript ファイル（`vitest.config.js` などの JS、各種 `*.json`）には整形・lint の仕組みが無く、フォーマットが属人的になっている。

### 目的

ReScript ファイル以外の手書き JS / JSON を、高速な oxc 製ツール（oxfmt = 整形、oxlint = lint）で一貫して整形・検査できるようにする。コミット前に自動検査する pre-commit hook を併設し、フォーマット崩れの混入を防ぐ。

## 2. 変更・追加する機能の説明

- **oxfmt**: 手書き JS / JSON を整形する。`pnpm format`（書き込み）/ `pnpm format:check`（検査）。
- **oxlint**: 手書き JS/TS を lint する。`pnpm lint`。
- **pre-commit hook**: コミット前に `format:check` と `lint` を実行し、不適合なら commit を中断する。
- 生成物（`*.res.js` / `lib/`）と `node_modules` は対象外（oxfmt/oxlint が `.gitignore` を自動尊重）。

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | コントリビューター | `pnpm format` を実行 | 手書き JS/JSON が整形され、生成 `.res.js` は触られない |
| 2 | コントリビューター | `pnpm lint` を実行 | 手書き JS の lint 結果が表示される |
| 3 | コントリビューター | 未整形のまま `git commit` | pre-commit hook が `format:check`/`lint` 失敗を検知し commit を中断する |

## 4. 受け入れ条件

- [ ] `pnpm format` が手書き JS/JSON を整形し、`*.res.js` / `lib/` / `node_modules` を変更しない
- [ ] 整形適用後、`pnpm format:check` が exit 0（差分なし）になる
- [ ] `pnpm lint` が oxlint を実行し exit 0 になる
- [ ] pre-commit hook が `format:check`/`lint` 失敗時に commit を中断する
- [ ] `pnpm build` と `pnpm test` が従来どおり成功する（回帰なし）
- [ ] 関連ドキュメント（CLAUDE.md / README / docs/repository-structure.md / sphinx-docs dev）が更新されている

## 5. 制約事項

- バインディング本体（`src/*.res`）や生成 `.res.js` は整形対象に含めない（ReScript 側の責務）。
- 追加する依存は devDependencies のみ。公開パッケージ（`files`）の内容・配布物に影響を与えない。
- pre-commit hook は追加ランタイム依存を極力増やさない方式を優先する。

## 6. 関連ドキュメント

- `docs/repository-structure.md` — リポジトリ構造定義書
- `.claude/rules/documentation.md` — ドキュメント管理規約
- `.claude/rules/minimal-change.md` — 最小変更原則
