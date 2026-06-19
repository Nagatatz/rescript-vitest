# タスクリスト: Phase 9 — フィクスチャ・カスタムマッチャー

| 項目 | 内容 |
|---|---|
| 機能名 | フィクスチャ・カスタムマッチャー (Phase 9) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 10 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`fixtures-custom-matchers`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装

- [ ] `testFor`（`test.for`）を `src/Vitest.res` に追加
- [ ] `module Expect` に `assertions` / `hasAssertions` / `soft` / `poll` / `unreachable` / `unreachableWithMessage` を追加

## フェーズ3: テスト

- [ ] `testFor` と assertion guards（assertions/hasAssertions）のテストを追加
- [ ] `soft` / `poll` / `unreachable` のテストを追加
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認（存在しない API があれば非対応へ切替）

## フェーズ4: 仕上げ

- [ ] 非対応 API（`test.extend` / `expect.extend`）の注記を `README.md` に追加
- [ ] ドキュメント更新（`README.md` の matcher/test 行 / `sphinx-docs/user/changelog.md` Unreleased + 日本語 `.po`、`make build-ja`）
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
