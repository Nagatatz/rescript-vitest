# タスクリスト: バインディング忠実性の修正とドッグフード網羅

| 項目 | 内容 |
|---|---|
| 機能名 | binding-fidelity-and-coverage |
| 作成日 | 2026-06-19 |
| 進捗 | 17 / 18 完了（残: main マージ） |

## フェーズ1: 準備

- [x] worktree `binding-fidelity-and-coverage` を作成し隔離環境を用意する

## フェーズ2: 実装（Part A — 実 API 不一致の修正・破壊的）

- [x] `src/Vitest.res`: `testContext` opaque type を追加し、`onTestFailed` / `onTestFailedAsync` / `onTestFinished` / `onTestFinishedAsync` のコールバック型を `testContext` を受ける形に修正
- [x] `src/Vi.res`: `disposable` opaque type を追加し `doMock` の戻り値型を `disposable` に修正
- [x] `src/Vi.res`: `setTimerTickModeWithInterval: (string, int) => unit` を追加

## フェーズ3: テスト

### Part A 回帰テスト

- [x] `__tests__/Vi_test.res`: `doMock` の戻り値（disposable）と `setTimerTickModeWithInterval` の回帰テストを追加
- [x] `__tests__/Vi_test.res`: `onTestFailed` / `onTestFinished` が `testContext` を受ける形の回帰テストを追加（既存 per-test hooks テストを更新）

### Part B ドッグフード網羅（expect）

- [x] `toStrictEqual` / `Async.toStrictEqual` のテストを追加（`Async.toEqual` 含む）
- [x] `toBeUndefined` / `toBeDefined` / `toBeNaN` のテストを追加
- [x] `toThrowRegExp` のテストを追加
- [x] `not_` の追加組み合わせ（`not_->toHaveBeenCalled`）と `Async.toEqual`、`toHaveBeenLastCalledWith2` のテストを追加

### Part B ドッグフード網羅（Vi）

- [x] `MockFn.calls` / `MockFn.results` のテストを追加
- [x] `MockFn.mockReturnValueOnce` / `mockImplementationOnce` のテストを追加
- [x] `MockFn.mockClear` / `mockReset`（個別呼び出し）と `Vi.resetAllMocks` / `restoreAllMocks` のテストを追加

### Part B ドッグフード網羅（describe / config）

- [x] `describeAsync` のテストを追加
- [x] `VitestConfig.defineConfigFn`（関数形式）のテストを追加

> **スキップ対象（理由明記）:** 低優先度の単純修飾子（`it` 基本形 / `itAsync` / `itOnly` / `itSkip` / `testOnly` 系）は、ランナー上で動作確認が難しく型担保の価値も限定的なため本作業の対象外。必要なら別 steering で扱う。

## フェーズ4: 仕上げ

- [x] `README.md` の API チートシートを更新し、破壊的変更を明記
- [x] `sphinx-docs/user/changelog.md` に破壊的変更を記載し、`make update-po` + ja `msgstr` を更新（`make build-ja` 確認）
- [x] `pnpm build` と `pnpm test` の全件パスを最終確認し、適切な粒度でコミット（119 passed）

## フェーズ5: マージ

- [x] tasklist.md の全タスクを `[x]` に更新してコミット
- [ ] main へのマージ可否をユーザーに確認し、承認後マージ・worktree/ブランチ削除・クリーンアップ検証

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
