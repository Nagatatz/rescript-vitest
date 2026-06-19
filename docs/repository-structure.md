# リポジトリ構造定義書

`@nagatatz/rescript-vitest` — Vitest 4 向けの型安全な ReScript バインディング。

## プロジェクト構成

```
rescript-vitest/
├── CLAUDE.md                   # Claude Code の常時ロードコンテキスト
├── .claude/
│   ├── agents/                 # サブエージェント定義
│   ├── commands/               # スラッシュコマンド
│   ├── examples/               # ゴールドスタンダード参考集
│   ├── hooks/                  # ライフサイクル hook スクリプト
│   ├── output-styles/          # 出力スタイル
│   ├── rules/                  # 常時 @import されるルール
│   ├── settings.json           # 権限・hook 登録・statusLine 設定（要手動有効化）
│   ├── skills/                 # 状況発火型スキル
│   └── statusline.sh           # statusLine コマンド
├── docs/                       # 永続的設計ドキュメント
├── sphinx-docs/                # 外部公開ドキュメント（日英対応 / Sphinx）
├── src/
│   ├── Vitest.res              # describe / test / expect マッチャーのバインディング
│   └── Vi.res                  # Vi — モック / スパイ / モジュールモック / フェイクタイマー
├── __tests__/
│   ├── Expect_test.res         # expect マッチャーのドッグフードテスト
│   └── Vi_test.res             # Vi モック/タイマーのドッグフードテスト
├── rescript.json               # ReScript ビルド設定（in-source, .res.js 出力）
├── vitest.config.js            # Vitest 設定（__tests__/**/*_test.res.js を対象）
└── package.json                # パッケージ定義 / npm スクリプト
```

## レイヤー責務

このパッケージは薄い FFI バインディング層であり、アプリケーションのようなレイヤー構造は持たない。

- **`src/Vitest.res`** — テスト構造（`describe` / `test` / `it` とその変種）、ライフサイクルフック、`expect` マッチャー一式、`not_` / `resolves` / `rejects` モディファイア。マッチャーは Vitest 本体と同様に副作用を持ち、失敗時に例外を投げる *faithful* な設計。
- **`src/Vi.res`** — `Vi` 名前空間。モック関数・スパイ・モジュールモック・グローバル状態操作・フェイクタイマー。
- **`__tests__/`** — バインディング自身を Vitest 4 上で検証するドッグフードテスト。バインディング追加・変更時は対応するテストを必ず併設する（→ Verification-first）。

## ビルドフロー

1. `pnpm build` → `rescript build` が `.res` を in-source の `.res.js`（ESM）にコンパイル。
2. `pnpm test` → `vitest run` がコンパイル済み `__tests__/**/*_test.res.js` を実行。

`.res.js` / `lib/` はビルド成果物で `.gitignore` 済み。

## 主要ファイルの役割

| ファイル | 役割 |
|---------|------|
| `CLAUDE.md` | Claude Code 用の常時コンテキスト。`@import` で `.claude/rules/` をロード |
| `.claude/settings.json` | hooks 登録 / 権限 / statusLine 設定（`.template` から手動コピーで有効化） |
| `rescript.json` | ReScript コンパイラ設定。`src`（公開）と `__tests__`（dev）をソース指定 |
| `vitest.config.js` | Vitest のテスト対象パターン定義 |
| `.steering/<日付>-<連番>-<タイトル>/` | 作業単位のステアリングドキュメント |

## 関連ドキュメント

- `.claude/rules/documentation.md` — ドキュメント管理規約
- `.claude/rules/steering-workflow.md` — ステアリングワークフロー
- `sphinx-docs/` — 公開ユーザー/開発者ドキュメント（日英）
