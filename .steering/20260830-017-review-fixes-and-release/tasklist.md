# タスクリスト: レビュー指摘の一括修正と 0.2.0 リリース

| 項目 | 内容 |
|---|---|
| 機能名 | レビュー指摘の一括修正と 0.2.0 リリース |
| 作成日 | 2026-08-30 |
| 進捗 | 15 / 36 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree を作成する
- [x] `pnpm install` して現状のビルド・テストが通ることを確認する（ベースライン: 146 passed）

## フェーズ2: バインディング修正（各項目: テストを先に書き Red → 実装 → Green）

- [x] `Vi.MockFn.calls` を `array<array<'arg>>` に修正 → 検証: `Vi_test.res` で `calls[0][0]` の値を検証
- [x] `Vi.MockFn.results` を `array<mockResult<'ret>>` に修正（`mockResultType` / `mockResult` 型追加）→ 検証: `results[0].type_ == #return` と `value`
- [x] `Vi.setTimerTickMode` を polymorphic variant 化、`setTimerTickModeWithInterval` を `@as("interval") _` に → 検証: `Vi_test.res` で `#manual` / interval 呼び出しがフェイクタイマー下で動作
- [x] `describeEach2/3`, `testEach2/3`, `itEach2/3` を追加、既存 `*Each` のコメント更新 → 検証: `Expect_test.res` でタプルケースの全カラムが届く

## フェーズ3: テスト追加

- [x] `describeEach` / `testEach` / `testConcurrent` / `describeSkip` / `testSkip` / `itSkip` のテスト（`Expect_test.res`）
- [ ] `onTestFailedAsync` / `onTestFinishedAsync` のテスト（`Lifecycle_test.res`）
- [x] `spyOnAccessor` 直接呼び出しのテスト（`Vi_test.res`）
- [x] `__tests__/Only_test.res` を新規作成（`describeOnly` / `testOnly` / `testOnlyAsync` / `itOnly`）
- [x] `__tests__/ModuleMock_test.res` を新規作成（`mockWithFactory` / `unmock`）。成立しない場合はこの行に理由を追記し省略する
- [x] `pnpm build && pnpm test` 全件パス

## フェーズ4: CI / 設定

- [x] `ci.yml` に `pnpm lint` / `pnpm format:check` を追加
- [x] `pnpm-workspace.yaml` を追加し `package.json` の `pnpm` フィールドを削除 → 検証: `pnpm install --frozen-lockfile` で警告が出ない
- [x] `pnpm update` で devDeps 更新 → 検証: build / test / lint / format:check 全件パス
- [x] `.gitignore` に `CLAUDE.local.md` / `quality-reports/` 追加

## フェーズ5: ドキュメント

- [ ] `README.md`: API 表（`testOnlyAsync`, `spyOnAccessor`, `*Each2/3`）、Install / Requirements に peer 反映
- [ ] `sphinx-docs/user/installation.md`: 同上
- [ ] `sphinx-docs/user/changelog.md`: 0.2.0 エントリ（Breaking 明記）
- [ ] `sphinx-docs/dev/setup.md`: 日本語混入を英語化
- [ ] `sphinx-docs/dev/project-structure.md`: `__tests__` 実ファイル反映、「各 src モジュールに対応テスト」の記述修正
- [ ] `sphinx-docs/conf.py`: `version` / `release` を `package.json` から読む
- [ ] `make update-po` → `.po` の `msgstr` を日本語で記入 → `make html` / `make build-ja` 成功
- [ ] `docs/repository-structure.md`: ツリー更新
- [ ] `docs/quality-measurement.md`: `typescript-conventions` 除去
- [ ] `CLAUDE.md`: README 参照修正、skills 表を抜粋と明記
- [ ] `.steering/` 013 / 014 / 016 の `tasklist.md` 未チェック項目を実績確認のうえ `[x]`

## フェーズ6: リリース

- [ ] `package.json` version を 0.2.0 に更新
- [ ] 適切な粒度でコミット（🐛 バインディング修正 / ✨ Each2/3 追加 / ✅ テスト / 🔧 CI・設定 / 📝 ドキュメント / 🔧 version bump）
- [ ] `AskUserQuestion` で main へのマージと `v0.2.0` タグ push（= npm publish）の可否を確認
- [ ] main へマージ、push、`v0.2.0` タグ push
- [ ] `release.yml` の成功と `npm view @nagatatz/rescript-vitest version` = 0.2.0 を確認
- [ ] worktree / ブランチのクリーンアップ

## 完了条件

- [ ] すべてのタスクが完了していること
- [ ] ビルド・テスト・lint・format:check が成功すること
- [ ] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

### 発生した問題と解決策

### 設計変更の理由

### 次回への改善点
