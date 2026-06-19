# タスクリスト: Phase 7 — test/describe 修飾子

| 項目 | 内容 |
|---|---|
| 機能名 | test/describe 修飾子 (Phase 7) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 10 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`test-describe-modifiers`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [ ] M7: `testSkipIf` / `testRunIf` / `testFails` / `testFailsAsync` / `testSequential` / `testSequentialAsync` を追加
- [ ] M8: `describeTodo` / `describeConcurrent` / `describeSequential` / `describeShuffle` / `describeSkipIf` / `describeRunIf` / `describeFor` を追加

## フェーズ3: テスト

- [ ] M7 の修飾子テストを追加（skipIf/runIf/fails/sequential）
- [ ] M8 の修飾子テストを追加（concurrent/sequential/shuffle/todo/skipIf/runIf/for）
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認

## フェーズ4: 仕上げ

- [ ] ドキュメント更新（`README.md` の Test structure 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
- [ ] コミット（`✨` プレフィックス）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ビルドが成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
