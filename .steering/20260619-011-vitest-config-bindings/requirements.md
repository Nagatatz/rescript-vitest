# 要求定義: vitest/config 最小バインディング (Tier A)

| 項目 | 内容 |
|---|---|
| 機能名 | vitest/config 最小バインディング (Tier A) |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

本リポジトリは Vitest の**テストランタイム API**（`describe`/`test`/`expect`/`vi`）をほぼ完全網羅でバインドしているが、**設定 API（`vitest/config`）は未対応**。プラン（`vite-...-steady-liskov.md`）の検討で、vite+ 構成ツールの大半は ReScript wrapping の ROI が低い一方、`vitest/config` だけは「既存 Vitest バインディングの物語を閉じる」という別の動機があり、かつ API 面が小さいため Tier A として確定推奨された。

### 目的

ReScript から型付きで Vitest の設定値（特に `test` フィールド）を構築できるようにする。**全フィールド網羅はせず**、実利用頻度の高い主要フィールドに限定して保守コストを最小化する（YAGNI／minimal-change 原則）。

## 2. 変更・追加する機能の説明

`src/VitestConfig.res` を新設し、`vitest/config` の以下をバインドする:

- `defineConfig` — 設定オブジェクト（および `mode/command` を受ける関数フォーム）
- `mergeConfig` — 2 つの設定の深いマージ
- `defineProject` — `test.projects` の各プロジェクト設定用
- `test` 設定オブジェクトの**主要フィールドのみ**を ReScript の optional record で型付け
- `coverage` サブ設定の主要フィールドのみ

## 3. ユーザーストーリー

| # | ユーザー | 操作 | 期待する結果 |
|---|---|---|---|
| 1 | ReScript 開発者 | `VitestConfig.defineConfig({test: {globals: true, environment: "node"}})` を書く | 型チェックを通り、Vitest が読める設定オブジェクトが得られる |
| 2 | ReScript 開発者 | `VitestConfig.mergeConfig(base, override)` で設定を合成する | 深いマージ結果が得られる |
| 3 | ReScript 開発者 | 主要フィールド（include/exclude/setupFiles/coverage/pool/timeout 等）を型付きで指定する | 誤ったフィールド名・型はコンパイルエラーになる |

## 4. 受け入れ条件

- [ ] `src/VitestConfig.res` に `defineConfig`/`mergeConfig`/`defineProject` がバインドされている
- [ ] `test` 主要フィールド（globals/environment/include/exclude/setupFiles/coverage/pool/testTimeout/hookTimeout/reporters/watch/root/projects）が optional record で型付けされている
- [ ] `coverage` 主要フィールド（provider/enabled/reporter/include/exclude）が型付けされている
- [ ] `__tests__/VitestConfig_test.res` のドッグフードテストが全件パスする（`defineConfig` の同一性・`mergeConfig` の深いマージ挙動を検証）
- [ ] `pnpm build`（ReScript コンパイル）が型エラーなく成功する
- [ ] README / sphinx-docs（日英）に「対象フィールドと非対象（全フィールドは追わない方針）」が明記されている

## 5. 制約事項

- **最小範囲厳守**: 全 `UserConfig` / 全 `test` フィールドは追わない。主要サブセットのみ。
- **faithful 設計**: 既存 `Vitest.res` のイディオム（`@module`/`@scope`、doc コメント）に合わせる。
- **実 config ファイルへの結線**: ReScript は `export default` を直接出力しないため、実際の `vitest.config` として使うには薄い `vitest.config.js` シム（`import {config} from "./Config.res.js"; export default config`）が必要。これは設計で明記する（ROI が低い理由の一部でもある）。
- Vitest 4 を前提（workspace は `test.projects` に統合済み、`defineWorkspace` は対象外）。

## 6. 関連ドキュメント

- プラン: `~/.claude/plans/vite-https-github-com-voidzero-dev-vite-steady-liskov.md`
- `src/Vitest.res` — 既存バインディングのイディオム参照元
- Vitest 設定リファレンス: <https://vitest.dev/config/>
