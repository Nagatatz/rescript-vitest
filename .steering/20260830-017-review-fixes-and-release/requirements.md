# 要求定義: レビュー指摘の一括修正と 0.2.0 リリース

| 項目 | 内容 |
|---|---|
| 機能名 | レビュー指摘の一括修正と 0.2.0 リリース |
| 作成日 | 2026-08-30 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

2026-08-30 にリポジトリ全体をレビュー（バインディング忠実性 / テスト網羅 / ドキュメント整合 / CI 設定）した結果、Vitest 4.1 の実 API と乖離した型定義（`MockFn.calls` / `MockFn.results` / `*Each` 系のスプレッド）、未テストの公開バインディング、CI の lint 未実行、pnpm 10 で無視される設定、ドキュメントの陳腐化が見つかった。

### 目的

指摘事項をすべて解消し、破壊的変更を含むため **0.2.0** として npm に公開する。

## 2. 変更・追加する機能の説明

### A. バインディングの修正（破壊的）

1. `Vi.MockFn.calls` — 実体 `mock.calls: Args[][]` に合わせ `array<array<'arg>>` を返す
2. `Vi.MockFn.results` — 実体 `MockResult<T>[]`（`{type, value}`）に合わせ `array<mockResult<'ret>>` を返す
3. `Vi.setTimerTickMode` — `mode` を `[#manual | #nextTimerAsync | #interval]` に限定。`setTimerTickModeWithInterval` は `"interval"` を固定引数として埋め込み `int => unit` にする

### B. バインディングの追加

4. `describeEach2` / `describeEach3` / `testEach2` / `testEach3` / `itEach2` / `itEach3` — タプル（複数カラム）ケース用。Vitest の `.each` は配列ケースを `fn(...row)` と展開するため、2 引数 / 3 引数のコールバックを取る変種を追加する。既存の `*Each`（1 引数）はスカラー / レコードケース専用であることをコメントで明示する

### C. ドッグフードテストの追加

5. 未テストの公開バインディングにテストを追加: `describeEach`, `testEach`, `*Each2/3`, `testConcurrent`, `onTestFailedAsync`, `onTestFinishedAsync`, `spyOnAccessor`（直接呼び出し）, `describeSkip`/`testSkip`/`itSkip`, `describeOnly`/`testOnly`/`testOnlyAsync`/`itOnly`（専用ファイル）, `mockWithFactory`/`unmock`（専用ファイル。実行時挙動で検証不能なら理由を tasklist に明記）
6. `calls` / `results` のテストを `.length` だけでなく要素の中身まで検証するよう強化する

### D. CI / 設定

7. `ci.yml` に `pnpm lint` と `pnpm format:check` を追加する
8. `pnpm.onlyBuiltDependencies` を `package.json` から `pnpm-workspace.yaml` へ移す
9. devDependencies をセマンティックレンジ内で最新化する（`pnpm update`）
10. `.gitignore` に `CLAUDE.local.md` と `quality-reports/` を追加する

### E. ドキュメント

11. README / `sphinx-docs/user/installation.md`: API 表に `testOnlyAsync` / `spyOnAccessor` / `*Each2/3` を追加、Install スニペットと Requirements 表に `rescript` / `@rescript/runtime` peer を反映
12. `sphinx-docs/dev/setup.md` の日本語混入を英語化（`.po` を同期し日本語訳は維持）
13. `docs/repository-structure.md` / `sphinx-docs/dev/project-structure.md`: `__tests__` の実ファイル、`.devcontainer` / `.env.example` / `.mcp.json.template` / `scripts/` / `quality-datasets/` を反映
14. `CLAUDE.md`: 存在しない README 節への参照を修正、skills 表が抜粋であることを明記
15. `docs/quality-measurement.md`: `typescript-conventions` の言及を除去
16. `sphinx-docs/user/changelog.md` に 0.2.0 を追記、`conf.py` に `version` / `release` を設定
17. `.steering/` 013 / 014 / 016 の未チェック項目を実績確認のうえ `[x]` にする

### F. リリース

18. `package.json` を 0.2.0 に更新し、main へマージ後に `v0.2.0` タグを push（`release.yml` が OIDC で npm publish）

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | バインディング利用者 | `m->Vi.MockFn.calls` の要素を参照する | 各呼び出しの引数配列が型どおりに取れる |
| 2 | バインディング利用者 | `m->Vi.MockFn.results` の要素を参照する | `{type_, value}` が取れ、戻り値・例外を判別できる |
| 3 | バインディング利用者 | `testEach2([(1, "a")])("%i %s", (n, s) => ...)` | 2 列目が捨てられずコールバックに届く |
| 4 | バインディング利用者 | `Vi.setTimerTickMode(#manual)` | 不正な文字列がコンパイル時に弾かれる |
| 5 | メンテナ | lint 違反を含む PR を出す | CI が失敗する |
| 6 | 利用者 | `pnpm add -D @nagatatz/rescript-vitest@0.2.0` | 新型定義で利用できる |

## 4. 受け入れ条件

- [ ] `pnpm build` / `pnpm test` / `pnpm lint` / `pnpm format:check` が全件成功する
- [ ] `calls` / `results` / `*Each2` / `*Each3` / `setTimerTickMode` のリグレッションテストが要素の中身を検証している
- [ ] `ci.yml` が lint / format:check を実行する
- [ ] `pnpm` コマンドで `onlyBuiltDependencies` の警告が出ない
- [ ] `sphinx-docs`: `make html` / `make build-ja` が成功し、更新した英語ソースに対応する `.po` の `msgstr` が埋まっている
- [ ] `npm view @nagatatz/rescript-vitest version` が `0.2.0` を返す

## 5. 制約事項

- `calls` / `results` / `setTimerTickMode` の型変更は破壊的 → 0.x のためマイナーを上げ 0.2.0 とし、changelog に **Breaking** として明記する
- `vi.mock` 系はホイストされるため実行時テストが困難な場合がある。その場合はテスト省略の理由を tasklist に記載する（testing.md 例外）
- 最小変更原則: レビューで指摘された行以外は触らない
- npm publish はタグ push で `release.yml` が実行する。タグ push はユーザー承認後に行う

## 6. 関連ドキュメント

- `docs/repository-structure.md` — リポジトリ構造定義書
- `.steering/20260619-012-binding-fidelity-and-coverage/` — 前回の忠実性・網羅性改善
- `.steering/20260619-015-binding-type-safety-and-coverage/` — 前回の型安全性改善
