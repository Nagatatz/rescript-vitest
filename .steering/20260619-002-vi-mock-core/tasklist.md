# タスクリスト: Phase 2 — Vi モック中核

| 項目 | 内容 |
|---|---|
| 機能名 | Vi モック中核 (Phase 2) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 10 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`vi-mock-core`) を作成し隔離環境を用意する

## フェーズ2: 実装

- [ ] H3: `mockResolvedValueOnce` / `mockRejectedValueOnce` / `mockReturnThis` を `MockFn` に追加
- [ ] H3: `getMockName` / `mockName` / `getMockImplementation`(`@return(nullable)`) / `withImplementation` を追加
- [ ] H4: `mocked` / `isMockFunction` / `hoisted` を vi 名前空間に追加

## フェーズ3: テスト

- [ ] `__tests__/Vi_test.res` に H3 の検証テストを追加（once 系は async）
- [ ] `__tests__/Vi_test.res` に H4 の検証テストを追加
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認

## フェーズ4: 仕上げ

- [ ] ドキュメント更新（`README.md` の `MockFn`/`Vi` 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
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
