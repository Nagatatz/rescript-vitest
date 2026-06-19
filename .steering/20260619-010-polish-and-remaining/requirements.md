# 要求定義: Phase 10 — 仕上げ（ドキュメント刷新＋残繰延バインディング）

| 項目 | 内容 |
|---|---|
| 機能名 | 仕上げ（ドキュメント＋残繰延） (Phase 10) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

ロードマップ Phase 1〜9 完了後の仕上げ。(2) README 冒頭サマリの追従、(3) sphinx ユーザードキュメント拡充、
(4) 実現可能な繰延バインディングの取り込みを行う。`test.extend` / `expect.extend` は型安全に
faithful 表現できないため **非対応のまま維持**（ユーザー決定済み）。

### 目的

公開ドキュメントを最新サーフェスに追従させ、実現可能な繰延 API を網羅して区切りをつける。

## 2. 変更・追加する内容

### タスク2 — README 冒頭 Features サマリ更新（docs）
- 冒頭の 5 箇条書きを新サーフェス（型・述語/asymmetric/resolve/guards、waitFor/stubs/async timers/アクセサスパイ）に追従。

### タスク3 — sphinx ユーザードキュメント拡充（docs, 日英）
- `sphinx-docs/user/quickstart.md` — インストール→テスト記述→実行の実例を拡充。
- `sphinx-docs/user/configuration.md` — ReScript + Vitest 設定の基本を拡充。
- `make update-po` → 日本語 `msgstr` 記入 → `make build-ja`。

### タスク4 — 実現可能な繰延バインディング（code）
- `toMatchFileSnapshot`（`src/Vitest.res`, async, スナップショットファイル）
- `setTimerTickMode`（`src/Vi.res`, mode 文字列）
- 否定 asymmetric: `module Expect.Not`（`arrayContaining`/`objectContaining`/`stringContaining`/`stringMatching`(+RegExp)/`closeTo`(+Precision)）
- `it.*` 変種: `itTodo` / `itConcurrent` / `itEach` / `itFails` / `itSequential` / `itSkipIf` / `itRunIf`
- 条件付き test body の async 版: `testSkipIfAsync` / `testRunIfAsync`（describe body は同期のため対象外）

### 非対応維持
- `test.extend`（フィクスチャ）、`expect.extend`（カスタムマッチャー）— README の "Not yet bound" を維持。

## 3. 受け入れ条件

- [ ] タスク4 の全バインディングが追加され、ドッグフードテストが併設・全件パス
- [ ] README 冒頭サマリと詳細リストが最新サーフェスに追従
- [ ] sphinx quickstart/configuration が拡充され、日本語 `.po` も記入、`make build-ja` 成功
- [ ] `pnpm build` / `pnpm test` が通る

## 4. 制約事項

- `toMatchFileSnapshot` は初回実行でスナップショットファイルを生成する。生成物は専用ディレクトリに置き commit する。
- `setTimerTickMode` は mode 文字列のみ束ねる（optional interval は将来）。ランタイム不在ならスモークで検出し非対応へ切替。
- `it.*` 変種は `test.*` と対称な範囲のみ（全網羅はしない）。
- 否定 asymmetric は `expect.not` 上の "Containing" 系のみ（`anything`/`any` は `.not` に無い）。

## 5. 関連ドキュメント

- 見積もり計画: `/Users/ngtz/.claude/plans/async-stirring-pixel.md`（繰延項目）
- Phase 9 ステアリング: `.steering/20260619-009-fixtures-and-custom-matchers/`
