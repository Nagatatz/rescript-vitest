# 設計: レビュー指摘の一括修正と 0.2.0 リリース

| 項目 | 内容 |
|---|---|
| 機能名 | レビュー指摘の一括修正と 0.2.0 リリース |
| 作成日 | 2026-08-30 |

## 1. 実装アプローチ

Vitest 4.1.9 の型定義（`node_modules/@vitest/spy`, `@vitest/runner`）を正として `src/` を修正し、各修正に対して「修正前なら失敗する」ドッグフードテストを先に書く（Red → Green）。設定・ドキュメントは指摘行のみを修正する。最後に version を 0.2.0 に上げ、main マージ後にタグを push して `release.yml` に publish させる。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vi.res` | `mockResultType` / `mockResult<'ret>` 型を追加。`calls` → `array<array<'arg>>`、`results` → `array<mockResult<'ret>>`。`setTimerTickMode` を polymorphic variant に、`setTimerTickModeWithInterval` を `(@as("interval") _, int) => unit` に | 修正 |
| `src/Vitest.res` | `describeEach2/3`, `testEach2/3`, `itEach2/3` を追加。既存 `*Each` のコメントにスカラー/レコード専用と明記 | 修正 |
| `__tests__/Vi_test.res` | `calls` / `results` の要素検証、`setTimerTickMode(#manual)`、`spyOnAccessor` 直接呼び出し | 修正 |
| `__tests__/Expect_test.res` | `describeEach` / `testEach` / `*Each2` / `*Each3` / `testConcurrent` / `*Skip` | 修正 |
| `__tests__/Lifecycle_test.res` | `onTestFailedAsync` / `onTestFinishedAsync` | 修正 |
| `__tests__/Only_test.res` | `describeOnly` / `testOnly` / `testOnlyAsync` / `itOnly`（`.only` はファイル単位で他テストを skip するため専用ファイル） | 新規 |
| `__tests__/ModuleMock_test.res` | `mockWithFactory` / `unmock`（動的 import で検証。ホイストで成立しなければ削除し理由を tasklist に記載） | 新規 |
| `.github/workflows/ci.yml` | `pnpm lint` / `pnpm format:check` ステップ追加 | 修正 |
| `pnpm-workspace.yaml` | `onlyBuiltDependencies: [esbuild]` | 新規 |
| `package.json` | `pnpm` フィールド削除、version 0.2.0、devDeps 更新 | 修正 |
| `pnpm-lock.yaml` | `pnpm update` の結果 | 修正 |
| `.gitignore` | `CLAUDE.local.md`, `quality-reports/` | 修正 |
| `README.md` | API 表追記、Install / Requirements に peer 反映 | 修正 |
| `sphinx-docs/user/installation.md` | 同上 | 修正 |
| `sphinx-docs/user/changelog.md` | 0.2.0 エントリ | 修正 |
| `sphinx-docs/dev/setup.md` | 日本語混入の英語化 | 修正 |
| `sphinx-docs/dev/project-structure.md` | `__tests__` 実ファイル反映、誤った主張の修正 | 修正 |
| `sphinx-docs/conf.py` | `version` / `release` を `package.json` から読む | 修正 |
| `sphinx-docs/locale/ja/LC_MESSAGES/**/*.po` | `make update-po` + 日本語訳 | 修正 |
| `docs/repository-structure.md` | ツリー更新 | 修正 |
| `docs/quality-measurement.md` | `typescript-conventions` 除去 | 修正 |
| `CLAUDE.md` | 参照修正、skills 表を抜粋と明記 | 修正 |
| `.steering/20260619-013,014` / `20260630-016` の `tasklist.md` | 実績確認のうえ `[x]` | 修正 |

## 3. データ構造の変更

```rescript
/* src/Vi.res */
module MockFn = {
  /** `mock.results[i].type` */
  type mockResultType = [#return | #throw | #incomplete]
  /** One entry of `mock.results`. `value` is the return value for `#return`,
      the thrown error for `#throw`, and absent for `#incomplete`. */
  type mockResult<'ret> = {@as("type") type_: mockResultType, value: 'ret}

  @get @scope("mock") external calls: t<'fn> => array<array<'arg>> = "calls"
  @get @scope("mock") external results: t<'fn> => array<mockResult<'ret>> = "results"
}

type timerTickMode = [#manual | #nextTimerAsync | #interval]
external setTimerTickMode: timerTickMode => unit = "setTimerTickMode"
external setTimerTickModeWithInterval: (@as("interval") _, int) => unit = "setTimerTickMode"

/* src/Vitest.res */
external testEach2: array<('a, 'b)> => (string, ('a, 'b) => unit) => unit = "each"
external testEach3: array<('a, 'b, 'c)> => (string, ('a, 'b, 'c) => unit) => unit = "each"
/* describe / it も同形 */
```

## 4. 影響範囲の分析

### 直接的な影響

- `calls` / `results` / `setTimerTickMode` の既存利用者はコンパイルエラーになる（changelog に移行方法を記載）
- CI で lint / format 違反が検出されるようになる

### 間接的な影響

- `pnpm update` による devDeps 更新（oxlint の新ルールで lint が落ちる可能性 → 検証タスクで確認）
- `pnpm-workspace.yaml` 追加でロックファイルの `settings` が変わる可能性 → `--frozen-lockfile` で確認

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `calls` の要素型 | (a) `array<array<'arg>>` (b) `array<'args>`（タプル） | (a) | ReScript には 1 要素タプルが無く、(b) は 1 引数モックで実体 `[x]` と型 `x` が食い違う。(a) は常に実体と一致する |
| `*Each` のスプレッド対応 | (a) `*Each2/3` を追加 (b) 既存 `*Each` の型を `array<'a> => unit` に変える | (a) | 既存の `…With2` 命名と一貫し、スカラーケースの既存利用を壊さない |
| `setTimerTickModeWithInterval` の第 1 引数 | (a) `[#interval]` を受ける (b) `@as("interval") _` で固定 | (b) | 1 値しか取れない引数をユーザーに書かせない |
| `.only` のテスト | (a) 既存ファイルに追加 (b) 専用ファイル | (b) | `.only` はファイル内の他テストを skip するため |
| `conf.py` の version | (a) 文字列直書き (b) `package.json` から読む | (b) | 二重管理による乖離を防ぐ |
| 対応範囲 | レビュー報告に含めた項目のみ | — | 報告外の指摘（docs.yml の typecheck、dependabot uv、sphinx pytest の空実装、pa11y）はユーザー承認を得ていないため対象外とし、完了報告で言及する |
