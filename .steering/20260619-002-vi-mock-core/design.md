# 設計: Phase 2 — Vi モック中核

| 項目 | 内容 |
|---|---|
| 機能名 | Vi モック中核 (Phase 2) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vi.res` の `MockFn` モジュール（`src/Vi.res:19-64`）末尾に H3 を、
vi 名前空間（「Creating mocks」セクション `src/Vi.res:66-86` 付近）に H4 を、
既存 `@send` / `@module("vitest") @scope("vi")` パターンで追加する。faithful binding 方針を踏襲。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vi.res` | `MockFn` に H3、vi 名前空間に H4 を追加 | 修正 |
| `__tests__/Vi_test.res` | H3/H4 の検証テストを追加 | 修正 |

### 追加する external（H3 — `MockFn` モジュール内）

```rescript
@send external mockResolvedValueOnce: (t<'fn>, 'ret) => t<'fn> = "mockResolvedValueOnce"
@send external mockRejectedValueOnce: (t<'fn>, 'err) => t<'fn> = "mockRejectedValueOnce"
@send external mockReturnThis: t<'fn> => t<'fn> = "mockReturnThis"
@send external getMockName: t<'fn> => string = "getMockName"
@send external mockName: (t<'fn>, string) => t<'fn> = "mockName"
@send @return(nullable) external getMockImplementation: t<'fn> => option<'fn> = "getMockImplementation"
@send external withImplementation: (t<'fn>, 'fn, unit => unit) => t<'fn> = "withImplementation"
```

### 追加する external（H4 — vi 名前空間）

```rescript
@module("vitest") @scope("vi") external mocked: 'fn => MockFn.t<'fn> = "mocked"
@module("vitest") @scope("vi") external isMockFunction: 'a => bool = "isMockFunction"
@module("vitest") @scope("vi") external hoisted: (unit => 'a) => 'a = "hoisted"
```

## 3. データ構造の変更

なし（既存 `MockFn.t<'fn>` を再利用）。`getMockImplementation` の戻り値のみ
`@return(nullable)` により `option<'fn>` へ写す。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vi.res` の公開 API 追加のみ。既存 API のシグネチャは不変で後方互換。

### 間接的な影響

- ドキュメント（README Features の `MockFn` / `Vi` 行、EN/JA changelog）更新が必要（Phase 4 仕上げ）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `getMockImplementation` の戻り | `'fn` / `option<'fn>` | `option<'fn>` | Vitest が `undefined` を返しうる。`@return(nullable)` で安全に option 化 |
| `withImplementation` の対応 | 同期のみ / 同期+async | 同期のみ | Vitest は sync cb で `this` を返す。async 版は YAGNI、需要発生時に追加 |
| `mocked` の型 | 恒等 `'a => 'a` / `'fn => MockFn.t<'fn>` | 後者 | モック操作対象として使う実用形。実行時恒等なので安全 |
| `isMockFunction` 引数 | `MockFn.t` 限定 / generic `'a` | generic `'a` | 任意値の判定が本来の用途。型を狭めない |
