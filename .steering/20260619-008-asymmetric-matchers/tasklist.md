# タスクリスト: Phase 8 — asymmetric matchers

| 項目 | 内容 |
|---|---|
| 機能名 | asymmetric matchers (Phase 8) |
| 作成日 | 2026-06-19 |
| 進捗 | 9 / 9 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`asymmetric-matchers`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [x] `module Expect` に `anything` / `any` / `arrayContaining` / `objectContaining` を追加
- [x] `module Expect` に `stringContaining` / `stringMatching` / `stringMatchingRegExp` / `closeTo` / `closeToWithPrecision` を追加

## フェーズ3: テスト（= PoC 検証）

- [x] `toEqual` / `toMatchObject` の期待値位置に埋め込むテストを追加
- [x] `toHaveBeenCalledWith` の期待値位置に埋め込むテストを追加
- [x] `pnpm build` が型エラーなしで通ることを確認（多相戻り値アプローチの型整合確認 = PoC 成立）
- [x] `pnpm test` が全件パスすることを確認（79 passed / 2 expected fail / 4 skipped）

## フェーズ4: 仕上げ

- [x] ドキュメント更新（`README.md` に asymmetric matchers / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja` 成功）
- [x] コミット（`✨` プレフィックス）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

## 完了条件

- [x] すべてのタスクが完了していること
- [x] ビルドが成功すること
- [x] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
