# タスクリスト: Phase 3 — テストライフサイクルフック

| 項目 | 内容 |
|---|---|
| 機能名 | テストライフサイクルフック (Phase 3) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 9 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`lifecycle-hooks`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [ ] `onTestFailed` / `onTestFailedAsync` を `src/Vitest.res` に追加（ドキュメントコメント付き）
- [ ] `onTestFinished` / `onTestFinishedAsync` を追加

## フェーズ3: テスト

- [ ] `onTestFinished` の ref 挙動テストを追加（実発火を検証）
- [ ] `onTestFailed` のスモークテストを追加（成功テスト内で登録）
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認

## フェーズ4: 仕上げ

- [ ] ドキュメント更新（`README.md` のフック行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
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
