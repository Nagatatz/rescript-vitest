# タスクリスト: oxlint/oxfmt による JS/JSON 整形・lint 導入

| 項目 | 内容 |
|---|---|
| 機能名 | oxlint/oxfmt による JS/JSON 整形・lint 導入 |
| 作成日 | 2026-06-30 |
| 進捗 | 13 / 14 完了（残: マージ可否確認） |

> テスト方針: 本変更はツール設定のためユニットテストは作成しない（testing.md 例外）。検証は `format:check` / `lint` / `build` / `test` の成功で代替する。

## フェーズ1: 準備

- [x] `chore/oxlint-oxfmt-formatting` ブランチを main から作成する

## フェーズ2: 実装

- [x] `oxlint` / `oxfmt` を devDependencies に追加する（`pnpm add -D`）
- [x] `.oxfmtrc.json` を追加する（最小構成）
- [x] `.oxlintrc.json` を追加する（最小構成、correctness 中心）
- [x] `package.json` に `format` / `format:check` / `lint` / `prepare` スクリプトを追加する
- [x] `.githooks/pre-commit` を追加し実行権限を付与する（`format:check` + `lint`）
- [x] `pnpm format` を実行し、手書き JS/JSON へ初回整形を適用する（対象を `**/*.{js,mjs,cjs,json}` に限定。既定の `.` は md/yaml/html まで対象化しエラーになるため）

## フェーズ3: 検証

- [x] `pnpm format:check` が exit 0（差分なし）になることを確認する
- [x] `pnpm lint` が exit 0 になることを確認する（違反検知も probe で確認: exit 1）
- [x] `pnpm build` と `pnpm test` が成功する（回帰なし: 146 passed）ことを確認する
- [x] pre-commit hook が `core.hooksPath` 有効化後に発火することを確認する（未整形コミットをブロック）

## フェーズ4: 仕上げ

- [x] ドキュメント更新（CLAUDE.md / README.md / docs/repository-structure.md / sphinx-docs dev + .po 同期）
- [x] 適切な粒度でコミットする（🔧 プレフィックス）
- [ ] tasklist.md を全 `[x]` 更新のうえ、main へのマージ可否をユーザーに確認する

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ビルド・テストが成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
