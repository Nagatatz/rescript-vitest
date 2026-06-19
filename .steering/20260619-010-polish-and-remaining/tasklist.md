# タスクリスト: Phase 10 — 仕上げ

| 項目 | 内容 |
|---|---|
| 機能名 | 仕上げ（ドキュメント＋残繰延） (Phase 10) |
| 作成日 | 2026-06-19 |
| 進捗 | 0 / 13 完了 |

## フェーズ1: 準備

- [ ] `EnterWorktree` で worktree (`polish-remaining`) を作成し、`git merge main --ff-only` で同期する

## フェーズ2: 実装（タスク4 — 繰延バインディング）

- [ ] `toMatchFileSnapshot` を `src/Vitest.res` に追加
- [ ] `testSkipIfAsync` / `testRunIfAsync` と `it.*` 変種（todo/concurrent/each/fails/sequential/skipIf/runIf）を追加
- [ ] `module Expect.Not`（否定 asymmetric）を追加
- [ ] `setTimerTickMode` を `src/Vi.res` に追加

## フェーズ3: テスト

- [ ] 上記バインディングのドッグフードテストを追加（toMatchFileSnapshot のスナップショット生成物を commit）
- [ ] `pnpm build` が型エラーなしで通ることを確認
- [ ] `pnpm test` が全件パスすることを確認（不在 API はスモークで検出し非対応へ切替）

## フェーズ4: ドキュメント

- [ ] タスク2: README 冒頭 Features サマリ更新 ＋ 詳細リストに新バインディング追記
- [ ] タスク3: sphinx `user/quickstart.md` / `user/configuration.md` を拡充
- [ ] sphinx 日本語 `.po` を `make update-po` → 記入 → `make build-ja` で検証
- [ ] `sphinx-docs/user/changelog.md` Unreleased に Phase 10 分を追記（EN/JA）

## フェーズ5: 仕上げ

- [ ] コミット（論理単位で `✨`/`📝`）後、main へのマージ可否を確認 → 承認後マージ・worktree クリーンアップ

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
