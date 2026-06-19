# タスクリスト: Phase 10 — 仕上げ

| 項目 | 内容 |
|---|---|
| 機能名 | 仕上げ（ドキュメント＋残繰延） (Phase 10) |
| 作成日 | 2026-06-19 |
| 進捗 | 13 / 13 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree (`polish-remaining`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装（タスク4 — 繰延バインディング）

- [x] `toMatchFileSnapshot` を `src/Vitest.res` に追加
- [x] `testSkipIfAsync` / `testRunIfAsync` と `it.*` 変種（todo/concurrent/each/fails/sequential/skipIf/runIf）を追加
- [x] `module Expect.Not`（否定 asymmetric）を追加
- [x] `setTimerTickMode` を `src/Vi.res` に追加

## フェーズ3: テスト

- [x] 上記バインディングのドッグフードテストを追加（toMatchFileSnapshot のスナップショット生成物を commit）
- [x] `pnpm build` が型エラーなしで通ることを確認
- [x] `pnpm test` が全件パスすることを確認（97 passed / 3 expected fail / 7 skipped / 1 todo。setTimerTickMode 含め全 API が 4.1.9 に存在）

## フェーズ4: ドキュメント

- [x] タスク2: README 冒頭 Features サマリ更新 ＋ 詳細リストに新バインディング追記
- [x] タスク3: sphinx `user/quickstart.md` / `user/configuration.md` を拡充
- [x] sphinx 日本語 `.po` を `make update-po` → 記入 → `make build-ja` で検証
- [x] `sphinx-docs/user/changelog.md` Unreleased に Phase 10 分を追記（EN/JA）

## フェーズ5: 仕上げ

- [x] コミット（論理単位で `✨`/`📝`）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

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
