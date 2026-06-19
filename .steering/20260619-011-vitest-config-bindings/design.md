# 設計: vitest/config 最小バインディング (Tier A)

| 項目 | 内容 |
|---|---|
| 機能名 | vitest/config 最小バインディング (Tier A) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/VitestConfig.res` を新設し、ReScript 12 の **optional record fields**（`{ x?: int }`）で設定オブジェクトを表現する。optional record は未指定キーを JS オブジェクトから省略してコンパイルされるため、Vitest の設定オブジェクトと相性が良く、`@obj` external より型が明示的で保守しやすい。

関数バインディングは既存 `Vitest.res` 同様 `@module("vitest/config") external` で行う。`defineConfig` はランタイム上ほぼ恒等関数なので、戻り値型も同じ `config` レコードとして扱い、ドッグフードテストで値を直接検証できる。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/VitestConfig.res` | `vitest/config` バインディング本体（型 + external） | 新規 |
| `__tests__/VitestConfig_test.res` | `defineConfig` 同一性・`mergeConfig` マージ挙動のドッグフードテスト | 新規 |
| `README.md` | 設定バインディングの対象範囲・非対象方針を追記 | 修正 |
| `sphinx-docs/`（en + ja .po） | 設定バインディングのページ追記（日英） | 修正 |
| `docs/repository-structure.md` | `src/VitestConfig.res` を主要ファイル表に追記 | 修正 |

## 3. データ構造の変更

新規型（すべて optional fields、主要サブセットのみ）:

```rescript
type coverageConfig = {
  provider?: string,          // "v8" | "istanbul"
  enabled?: bool,
  reporter?: array<string>,
  include?: array<string>,
  exclude?: array<string>,
}

type rec testConfig = {
  globals?: bool,
  environment?: string,        // "node" | "jsdom" | "happy-dom" | ...
  include?: array<string>,
  exclude?: array<string>,
  setupFiles?: array<string>,
  coverage?: coverageConfig,
  pool?: string,               // "threads" | "forks" | "vmThreads" | ...
  testTimeout?: int,
  hookTimeout?: int,
  reporters?: array<string>,
  watch?: bool,
  projects?: array<config>,    // Vitest 4: workspace は test.projects へ統合
}
and config = {
  test?: testConfig,
  root?: string,               // Vite レベルの最小フィールドのみ
}
```

externals:

```rescript
@module("vitest/config") external defineConfig: config => config = "defineConfig"
// 関数フォーム（mode/command で動的設定）。env はオブジェクトで受ける。
@module("vitest/config") external defineConfigFn: (configEnv => config) => config = "defineConfig"
@module("vitest/config") external mergeConfig: (config, config) => config = "mergeConfig"
@module("vitest/config") external defineProject: config => config = "defineProject"
```

`configEnv` は `{ mode: string, command: string }` の optional/必須レコードとして最小定義する。

**非対象（明示的に追わない）**: `plugins`、`resolve`、`server`、`build` 等の Vite レベル設定、`test` の残り多数フィールド（`deps`/`benchmark`/`browser`/`sequence` 等）、`configDefaults`、`defineWorkspace`。フル設定が必要な場合は JS の config ファイルを使う方針（プラン参照）。

## 4. 影響範囲の分析

### 直接的な影響

- 新規ファイルのみ。既存 `Vitest.res` / `Vi.res` には触れない（API 追加のみ）。
- `package.json` の `files` に `src` は既に含まれるため公開設定の追加変更は不要。

### 間接的な影響

- `__tests__/` にテストファイルが 1 つ増える（`vitest.config.js` の対象パターン `__tests__/**/*_test.res.js` に自動的に含まれる）。
- ドキュメント（README/sphinx）の追記。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| 設定オブジェクト表現 | optional record / `@obj` external / `Dict` | optional record | 型が明示的・未指定キー省略・既存スタイルと整合 |
| フィールド網羅度 | 全網羅 / 主要サブセット | 主要サブセット | YAGNI・保守コスト最小化（プラン Tier A 方針） |
| `defineConfig` 戻り値型 | branded opaque / 同一 `config` | 同一 `config` | 恒等関数でテスト検証が容易・利用側で `export` するだけ |
| 実 config ファイル結線 | ReScript で default export / JS シム | JS シム（ドキュメント明記） | ReScript は `export default` を直接出力しないため |
| workspace 対応 | `defineWorkspace` / `test.projects` | `test.projects` | Vitest 4 で統合済み |
| 検証方法 | 実 vitest 起動 / 値アサート | 値アサート中心 + 任意の手動スモーク | config は恒等的でランタイム挙動が薄く、`mergeConfig` の挙動は値で検証可能 |
