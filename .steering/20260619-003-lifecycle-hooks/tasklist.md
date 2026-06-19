# タスクリスト: Phase 3 — テストライフサイクルフック

| 項目 | 内容 |
|---|---|
| 機能名 | テストライフサイクルフック (Phase 3) |
| 作成日 | 2026-06-19 |
| 進捗 | 9 / 9 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`lifecycle-hooks`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [x] `onTestFailed` / `onTestFailedAsync` を `src/Vitest.res` に追加（ドキュメントコメント付き）
- [x] `onTestFinished` / `onTestFinishedAsync` を追加

## フェーズ3: テスト

- [x] `onTestFinished` の ref 挙動テストを追加（実発火を検証）
- [x] `onTestFailed` のスモークテストを追加（成功テスト内で登録）
- [x] `pnpm build` が型エラーなしで通ることを確認
- [x] `pnpm test` が全件パスすることを確認（36 件パス）

## フェーズ4: 仕上げ

- [x] ドキュメント更新（`README.md` のフック行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja` 成功）
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
