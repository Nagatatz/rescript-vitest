# タスクリスト: Phase 1 — expect mock マッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | expect mock マッチャー (Phase 1) |
| 作成日 | 2026-06-19 |
| 進捗 | 10 / 10 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`expect-mock-matchers`) を作成し隔離環境を用意する

## フェーズ2: 実装

- [x] H1: `toHaveBeenCalledWith` / `toHaveBeenCalledWith2` を `src/Vitest.res` に追加（ドキュメントコメント付き）
- [x] H1: `toHaveBeenLastCalledWith` / `toHaveBeenNthCalledWith` / `toHaveBeenCalledExactlyOnceWith` と各 arity-2 変種を追加
- [x] H2: `toHaveReturnedTimes` / `toHaveReturnedWith` / `toHaveLastReturnedWith` / `toHaveNthReturnedWith` を追加

## フェーズ3: テスト

- [x] `__tests__/Expect_test.res` に `describe("Expect — mock matchers", ...)` を追加し H1 マッチャーを検証
- [x] 同 describe に H2 返り値マッチャーの検証を追加
- [x] `pnpm build` が型エラーなしで通ることを確認
- [x] `pnpm test` が全件パスすることを確認（25 件パス）

## フェーズ4: 仕上げ

- [x] ドキュメント更新（`README.md` Features / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja` 成功）
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
