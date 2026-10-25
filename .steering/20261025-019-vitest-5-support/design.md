# 設計: Vitest 5 対応

| 項目 | 内容 |
|---|---|
| 機能名 | Vitest 5 対応 |
| 作成日 | 2026-10-25 |

## 1. 実装アプローチ

ReScript の定数引数 `@as(json`{"concurrent": false}`) _` を使い、sequential ヘルパーを base の `describe` / `test` / `it` に束縛する。生成される JS は `describe(name, {concurrent: false}, body)` となり、呼び出し側のシグネチャ（`(string, body) => unit`）は変わらない。

`{concurrent: false}` は Vitest 4 でも有効（`@vitest/runner` 4.1 で `describe(name, {concurrent: false})` は `describe.sequential` と同じく sequential 指定として扱われ、`test(name, {concurrent: false})` は concurrent スイート内でも逐次実行される）。そのため peer は `^4.0.0 || ^5.0.0` とする。

## 2. バインディング面の確認結果

`src/` の `@module("vitest")` external 全件を Vitest 4.1.12 / 5.0.5 の実行時に解決し、`@send` / `@get` のマッチャー・`MockFn` メソッドも両方に存在することを確認した。欠落していたのは `.sequential` 3 種のみ。その他の Vitest 5 の変更はバインディングの型・存在に影響しない挙動差分のため、doc コメントとドキュメントで注記する:

- `clearMocks` のデフォルトが `true`
- `vi.mock` / `vi.unmock` / `vi.hoisted` のネスト呼び出しが例外に
- `expect.poll` がタイムアウト時に失敗
- 未 await の非同期アサーション（`resolves` / `rejects` / `toMatchFileSnapshot`）がテスト失敗に
- `toThrow("")` が任意のメッセージにマッチ
- Node.js >= 22.12、Vite >= 6.4（Vite は Vitest の必須 peer）

## 3. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | sequential ヘルパーのバインド先変更、doc コメント追記 | 修正 |
| `src/Vi.res` | `mock` / `hoisted` のトップレベル要件を注記 | 修正 |
| `__tests__/Expect_test.res` | concurrent スイート内の逐次性テスト追加 | 修正 |
| `package.json` | peer `vitest` を `^4.0.0 || ^5.0.0` に | 修正 |
| `.github/workflows/ci.yml` | `test-vitest-4` ジョブ追加 | 修正 |
| `README.md` / `CLAUDE.md` / `docs/repository-structure.md` | 対応バージョン表記 | 修正 |
| `sphinx-docs/user/*.md` / `sphinx-docs/dev/*.md` / `.po` | 対応バージョン・移行メモ・CHANGELOG | 修正 |

## 4. semver

公開 ReScript 型は不変、peer 範囲は追加のみのため破壊的変更ではない。Vitest 5 自体の挙動差分（上記）は利用者のテストに影響しうるが、それは Vitest 側のメジャーアップデートに起因する。
