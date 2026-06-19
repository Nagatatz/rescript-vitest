# タスクリスト: Phase 9 — フィクスチャ・カスタムマッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | フィクスチャ・カスタムマッチャー (Phase 9) |
| 作成日 | 2026-06-19 |
| 進捗 | 9 / 10 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`fixtures-custom-matchers`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [x] `testFor`（`test.for`）を `src/Vitest.res` に追加
- [x] `module Expect` に `assertions` / `hasAssertions` / `soft` / `poll` / `unreachable` / `unreachableWithMessage` を追加

## フェーズ3: テスト

- [x] `testFor` と assertion guards（assertions/hasAssertions）のテストを追加
- [x] `soft` / `poll` / `unreachable` のテストを追加
- [x] `pnpm build` が型エラーなしで通ることを確認
- [x] `pnpm test` が全件パスすることを確認（87 passed / 2 expected fail / 4 skipped。実装した全 API が 4.1.9 に存在）

## フェーズ4: 仕上げ

- [x] 非対応 API（`test.extend` / `expect.extend`）の注記を `README.md` に追加（"Not yet bound" セクション）
- [x] ドキュメント更新（`README.md` の matcher/test 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja` 成功）
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
