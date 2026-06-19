# タスクリスト: vitest/config 最小バインディング (Tier A)

| 項目 | 内容 |
|---|---|
| 機能名 | vitest/config 最小バインディング (Tier A) |
| 作成日 | 2026-06-19 |
| 進捗 | 10 / 11 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree（機能名: `vitest-config-bindings`）を作成し隔離環境を用意する

## フェーズ2: 実装

- [x] `src/VitestConfig.res` を新設し、`coverageConfig` / `testConfig` / `config` / `configEnv` の optional record 型を定義する（doc コメント付与）
- [x] `defineConfig` / `defineConfigFn`（関数フォーム）/ `mergeConfig` / `defineProject` の external をバインドする
- [x] 各 external・型にコメント規約準拠の doc コメントを付与する（非対象フィールド方針も明記）

## フェーズ3: テスト

- [x] `__tests__/VitestConfig_test.res` を新設し、`defineConfig` が値を素通しすること（同一性）を検証する
- [x] `mergeConfig` が深いマージを行うことを検証する（base + override）
- [x] optional record の主要フィールド（globals/environment/coverage/projects 等）が正しく設定オブジェクトに反映されることを検証する
- [x] `pnpm build` でコンパイルが型エラーなく成功することを確認する
- [x] `pnpm test` で新規テストを含め全件パスすることを確認する（テストファイル 3、新規 6 ケース含め全件パス）

## フェーズ4: 仕上げ

- [x] ドキュメント更新: `README.md`（対象範囲・非対象方針）/ `docs/repository-structure.md`（ファイル表に追記）/ `sphinx-docs/`（en ページ + `make update-po` で ja .po を埋める。`make build-ja` 成功確認済み）
- [ ] 適切な粒度でコミットする（✨ 実装+テスト / 📝 ドキュメント）
- [ ] マージ確認タスク: `AskUserQuestion` で main へのマージ可否を確認し、承認後マージ・worktree/ブランチのクリーンアップ・検証まで一括実行する

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ビルドが成功すること（`pnpm build`）
- [ ] テストが全件パスすること（`pnpm test`）
- [ ] 受け入れ条件（requirements.md §4）をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
