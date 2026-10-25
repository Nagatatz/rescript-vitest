# 要求定義: Vitest 5 対応

| 項目 | 内容 |
|---|---|
| 機能名 | Vitest 5 対応 |
| 作成日 | 2026-10-25 |
| ステータス | 実装済み（PR レビュー待ち） |

## 1. 背景と目的

### 背景

Dependabot PR #38 が `vitest` / `@vitest/coverage-v8` を 5.0.0 に上げたところ、CI が `describe.sequential is not a function` で失敗した。Vitest 5 は `test.sequential` / `describe.sequential`（`it.sequential` を含む）と `sequential` オプションを削除し、代替として `{concurrent: false}` オプションを提示している（[Migration Guide](https://vitest.dev/guide/migration.html)）。

### 目的

公開 ReScript API を変えずに Vitest 5 で動作させ、可能な限り Vitest 4 も引き続きサポートする。

## 2. 変更・追加する機能の説明

1. **`describeSequential` / `testSequential` / `testSequentialAsync` / `itSequential`** — `.sequential` ではなく `describe` / `test` / `it` に `{concurrent: false}` を渡す形へバインド先を変更する（シグネチャは不変）
2. **peer dependency** — `vitest` を `^4.0.0 || ^5.0.0` に広げる
3. **テスト** — `describeConcurrent` 内で sequential ヘルパーが実際に逐次実行されることを検証する
4. **CI** — 最新 Vitest 4 に差し替えて同じテストを走らせるジョブを追加する
5. **ドキュメント** — README / Sphinx（英語・日本語 `.po`）/ CHANGELOG に Vitest 5 対応と挙動差分を記載する

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | Vitest 5 利用者 | `testSequential` / `describeSequential` を使う | `is not a function` にならず、逐次実行される |
| 2 | Vitest 4 利用者 | 本パッケージを更新する | peer 警告なしにそのまま動作する |

## 4. 受け入れ条件

- Vitest 5 と Vitest 4 の両方で `pnpm build && pnpm test` が全件パス
- sequential ヘルパーを `concurrent` 版に差し替えると逐次性テストが失敗する（テストが意味を持つ）
- `pnpm format:check` / `pnpm lint` / docs の `make check-po` がパス

## 5. スコープ外

- バージョン番号の更新と npm リリース（オーナー判断）
- Vitest 5 で追加された新 API（例: `expect.poll` コールバックの `{signal}` 引数、`toNotFake`）のバインディング追加
