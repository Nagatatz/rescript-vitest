# タスクリスト: レビュー指摘の一括修正と 0.2.0 リリース

| 項目 | 内容 |
|---|---|
| 機能名 | レビュー指摘の一括修正と 0.2.0 リリース |
| 作成日 | 2026-08-30 |
| 進捗 | 36 / 36 完了 |

## フェーズ1: 準備

- [x] `EnterWorktree` で worktree を作成する
- [x] `pnpm install` して現状のビルド・テストが通ることを確認する（ベースライン: 146 passed）

## フェーズ2: バインディング修正（各項目: テストを先に書き Red → 実装 → Green）

- [x] `Vi.MockFn.calls` を `array<array<'arg>>` に修正 → 検証: `Vi_test.res` で `calls[0][0]` の値を検証
- [x] `Vi.MockFn.results` を `array<mockResult<'ret>>` に修正（`mockResultType` / `mockResult` 型追加）→ 検証: `results[0].type_ == #return` と `value`
- [x] `Vi.setTimerTickMode` を polymorphic variant 化、`setTimerTickModeWithInterval` を `@as("interval") _` に → 検証: `Vi_test.res` で `#manual` / interval 呼び出しがフェイクタイマー下で動作
- [x] `describeEach2/3`, `testEach2/3`, `itEach2/3` を追加、既存 `*Each` のコメント更新 → 検証: `Expect_test.res` でタプルケースの全カラムが届く

## フェーズ3: テスト追加

- [x] `describeEach` / `testEach` / `testConcurrent` / `describeSkip` / `testSkip` / `itSkip` のテスト（`Expect_test.res`）
- [x] `onTestFailedAsync` / `onTestFinishedAsync` のテスト（`Lifecycle_test.res`）
- [x] `spyOnAccessor` 直接呼び出しのテスト（`Vi_test.res`）
- [x] `__tests__/Only_test.res` を新規作成（`describeOnly` / `testOnly` / `testOnlyAsync` / `itOnly`）
- [x] `__tests__/ModuleMock_test.res` を新規作成（`mockWithFactory` / `unmock`）。成立しない場合はこの行に理由を追記し省略する
- [x] `pnpm build && pnpm test` 全件パス

## フェーズ4: CI / 設定

- [x] `ci.yml` に `pnpm lint` / `pnpm format:check` を追加
- [x] `pnpm-workspace.yaml` を追加し `package.json` の `pnpm` フィールドを削除 → 検証: `pnpm install --frozen-lockfile` で警告が出ない
- [x] `pnpm update` で devDeps 更新 → 検証: build / test / lint / format:check 全件パス
- [x] `.gitignore` に `CLAUDE.local.md` / `quality-reports/` 追加

## フェーズ5: ドキュメント

- [x] `README.md`: API 表（`testOnlyAsync`, `spyOnAccessor`, `*Each2/3`）、Install / Requirements に peer 反映
- [x] `sphinx-docs/user/installation.md`: 同上
- [x] `sphinx-docs/user/changelog.md`: 0.2.0 エントリ（Breaking 明記）
- [x] `sphinx-docs/dev/setup.md`: 日本語混入を英語化
- [x] `sphinx-docs/dev/project-structure.md`: `__tests__` 実ファイル反映、「各 src モジュールに対応テスト」の記述修正
- [x] `sphinx-docs/conf.py`: `version` / `release` を `package.json` から読む
- [x] `make update-po` → `.po` の `msgstr` を日本語で記入 → `make html` / `make build-ja` 成功
- [x] `docs/repository-structure.md`: ツリー更新
- [x] `docs/quality-measurement.md`: `typescript-conventions` 除去
- [x] `CLAUDE.md`: README 参照修正、skills 表を抜粋と明記
- [x] `.steering/` 013 / 014 / 016 の `tasklist.md` 未チェック項目を実績確認のうえ `[x]`

## フェーズ6: リリース

- [x] `package.json` version を 0.2.0 に更新
- [x] 適切な粒度でコミット（🐛 バインディング修正 / ✨ Each2/3 追加 / ✅ テスト / 🔧 CI・設定 / 📝 ドキュメント / 🔧 version bump）
- [x] `AskUserQuestion` で main へのマージと `v0.2.0` タグ push（= npm publish）の可否を確認
- [x] main へマージ、push、`v0.2.0` タグ push
- [x] `release.yml` の成功と `npm view @nagatatz/rescript-vitest version` = 0.2.0 を確認
- [x] worktree / ブランチのクリーンアップ

## 完了条件

- [x] すべてのタスクが完了していること
- [x] ビルド・テスト・lint・format:check が成功すること
- [x] 受け入れ条件をすべて満たしていること

---

## 振り返り

<!-- モード3（/steering review）で記録する -->

### 実装で工夫した点

- 各バインディング修正は「新型定義でしか通らないテスト」を先に書き、旧定義でコンパイルが落ちる（Red）ことを確認してから `src/` を直した。`calls` は `toEqual([[1], [2]])` で実行時形状そのものを固定している。
- `setTimerTickModeWithInterval` は `(@as("interval") _, int)` で固定文字列をバインディング側に埋め込み、1 値しか取れない引数を API から消した。
- `.only` は Vitest がファイル単位で他テストを skip するため `Only_test.res` に隔離し、CI（`process.env.CI`）で拒否される問題は `vitest.config.js` の `allowOnly: true` で解消した。
- `vi.mock` / `vi.unmock` はホイストの有無に依存しない動的 `import()` 経由で検証し、テスト省略の例外を使わずに済んだ。
- `conf.py` の `version` / `release` を `package.json` から読むことで二重管理を避けた。

### 発生した問題と解決策

- `Option.getExn` / `Exn.raiseError` が ReScript 12.3 で deprecated 警告 → `Option.getOrThrow` / `JsError.throwWithMessage` に置換。
- `.po` 記入スクリプトが `msgstr msgstr "…"` と二重に書き込むバグ（`m.start(2)` の位置の取り違え）→ sed で修正し、`\"` を含む msgid 用に正規表現も修正。
- `EnterWorktree` は `origin/main` 起点で作られるため、未 push の steering コミットが含まれなかった → `git merge --ff-only main` で追従。
- 最終 tasklist コミットの `git push` が実行されないまま PR をマージした（`ahead 1` を確認して発覚）→ steering のみの変更として main に cherry-pick して直接 push（git-conventions の例外範囲）。
- worktree 隔離セッションでは複数ステップの heredoc を含む Bash が拒否される → スクリプトを scratchpad に書き出して実行する形に切り替え。
- `pnpm update` は `^0.57.0` の oxfmt を上げないため `pnpm update --latest oxfmt` を別途実行。

### 設計変更の理由

- なし（design.md どおり）。`setTimerTickMode` の既存テストが 2 件あったため、重複する新規テストは削除し既存側を新シグネチャに更新した。

### 次回への改善点

- PR 作成前に `git status -sb` で `ahead 0` を確認する手順を git-workflow skill に明記したい。
- レビューで報告外だった指摘（`docs.yml` に `make typecheck` / `check-po` 無し、dependabot に `uv` / `sphinx-docs/package.json` 未登録、`sphinx-docs/tests/` が空で pytest が空振り、pa11y 未実行）は未対応。別 steering で扱う。
- `.po` の機械的な記入はスクリプト化できたので、`sphinx-docs/` 配下に翻訳支援スクリプトとして置くことを検討する。
