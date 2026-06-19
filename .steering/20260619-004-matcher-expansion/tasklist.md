# タスクリスト: Phase 4 — マッチャー拡充

| 項目 | 内容 |
|---|---|
| 機能名 | マッチャー拡充 (Phase 4) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 10 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`matcher-expansion`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [ ] M1: `toBeTypeOf` / `toBeInstanceOf` / `toBeOneOf` / `toSatisfy` を `src/Vitest.res` に追加
- [ ] M9: `toHaveResolved` / `toHaveResolvedTimes` / `toHaveResolvedWith` / `toHaveLastResolvedWith` / `toHaveNthResolvedWith` を mock matchers に追加

## フェーズ3: テスト

- [ ] `__tests__/Expect_test.res` に M1 の検証テストを追加
- [ ] `__tests__/Vi_test.res` に M9 の検証テスト（async）を追加
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認

## フェーズ4: 仕上げ

- [ ] ドキュメント更新（`README.md` の matcher 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
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
