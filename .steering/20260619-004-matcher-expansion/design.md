# 設計: Phase 4 — マッチャー拡充

| 項目 | 内容 |
|---|---|
| 機能名 | マッチャー拡充 (Phase 4) |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

`src/Vitest.res` に既存 `@send external` パターンで追加する。
M1 は適切なカテゴリ近辺（truthiness/objects 付近の新セクション）、
M9 は「Mock / spy matchers」セクション（`src/Vitest.res` の `toHaveReturned` 群の隣）に置く。

## 2. 変更するコンポーネント

| ファイル | 変更内容 | 変更種別 |
|---|---|---|
| `src/Vitest.res` | M1（型・述語）と M9（resolve 系 mock）マッチャーを追加 | 修正 |
| `__tests__/Expect_test.res` | M1 の検証テストを追加 | 修正 |
| `__tests__/Vi_test.res` | M9 の検証テスト（async）を追加 | 修正 |

### 追加する external（M1）

```rescript
@send external toBeTypeOf: (assertion<'a>, string) => unit = "toBeTypeOf"
@send external toBeInstanceOf: (assertion<'a>, 'b) => unit = "toBeInstanceOf"
@send external toBeOneOf: (assertion<'a>, array<'a>) => unit = "toBeOneOf"
@send external toSatisfy: (assertion<'a>, 'a => bool) => unit = "toSatisfy"
```

### 追加する external（M9 — mock matchers）

```rescript
@send external toHaveResolved: assertion<'a> => unit = "toHaveResolved"
@send external toHaveResolvedTimes: (assertion<'a>, int) => unit = "toHaveResolvedTimes"
@send external toHaveResolvedWith: (assertion<'a>, 'b) => unit = "toHaveResolvedWith"
@send external toHaveLastResolvedWith: (assertion<'a>, 'b) => unit = "toHaveLastResolvedWith"
@send external toHaveNthResolvedWith: (assertion<'a>, int, 'b) => unit = "toHaveNthResolvedWith"
```

## 3. データ構造の変更

なし。

## 4. 影響範囲の分析

### 直接的な影響

- `src/Vitest.res` の公開 API 追加のみ。既存マッチャーは不変で後方互換。

### 間接的な影響

- ドキュメント（README Features の matcher 行、EN/JA changelog）更新（Phase 4 仕上げ）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| `toBeTypeOf` 引数 | `string` / 型付き variant | `string` | 既存 matcher と一貫・faithful。typo 防止の variant 化は将来拡張 |
| `toSatisfy` 述語型 | `'a => bool` | `'a => bool` | テスト対象と同型の述語で型安全 |
| `toBeOneOf` 候補型 | `array<'a>` | `array<'a>` | テスト対象と同型要素の配列で型安全 |
| resolve 系の検証 | await 前 / await 後 | await 後 | 解決値が記録されるのは Promise settle 後。テストで `await` してから assert |
| `toMatchFileSnapshot` | 含める / 外す | 外す | スナップショットファイル成果物の管理が必要・既存 snapshot matcher もテスト無しの前例（requirements 参照） |
