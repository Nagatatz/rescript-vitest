# 要求定義: .claude ルール群の包括的縮小

| 項目 | 内容 |
|---|---|
| 機能名 | claude-rules-reduction |
| 作成日 | 2026-06-19 |
| ステータス | 計画中 |

## 1. 背景と目的

### 背景

`CLAUDE.md` + `@import` される `.claude/rules/` 10 本（計 718 行）は毎セッションの固定オーバーヘッド。`claude-md-hygiene.md` 自身が「特定状況の知識は skill へ分離」「肥大化は指示を埋もれさせる」と定めながら、`steering-workflow.md`（215 行）が worktree 操作時のみ必要な手順を常時 @import しており、自己矛盾している。さらに steering-workflow ⇔ definition-of-done ⇔ steering skill、git-conventions ⇔ git-workflow skill で手順が重複し SSOT が破綻している。

### 目的

rules を「トリガー条件 + 判断基準 + 常時必要な規約」に純化し、手順の実体は対応する skill に一本化する。固定オーバーヘッドを削減し SSOT を回復する。**規約の意味内容は失わない**（移動先で参照可能に保つ）。

## 2. 変更・追加する機能の説明

`.claude/rules/` と一部 skill 本文のみ変更。コード（`src/`）・公開ドキュメント（`sphinx-docs/`）には触れない。CLAUDE.md の @import チェーンは原則維持（rule ファイル自体は残し、中身を圧縮）。

## 3. 受け入れ条件

- [ ] `steering-workflow.md` の worktree マージ・クリーンアップ手順を `worktree-safety` skill に移し、循環参照を解消した
- [ ] `steering-workflow.md` のアーカイブポリシー詳細を削除し `archive-steering` skill 参照に一本化した
- [ ] `git-conventions.md` のブランチ運用手順を `git-workflow` skill 参照に寄せ、常時必要な規約（絵文字表・ブランチ命名・粒度）のみ残した
- [ ] `permission-modes.md` / `claude-md-hygiene.md` / `delegate-investigation.md` を要点に圧縮した
- [ ] 各 skill 側に移動先の内容が存在し、rule からの参照が有効（リンク切れ無し）
- [ ] CLAUDE.md の @import チェーンが壊れていない（全 rule ファイルが存在）
- [ ] rules 合計行数が大幅に減少（目標: 718 → 約 450 行以下）

## 4. 制約事項

- 規約の**意味内容を失わない**（圧縮であって削除ではない。手順は skill に移して参照可能に保つ）。
- CLAUDE.md の `@import` 行は維持（rule ファイルを消すと警告が出るため、中身を圧縮する方針）。
- 移動先 skill の description（auto-invoke トリガー）は壊さない。

## 5. 関連ドキュメント

- `.claude/rules/claude-md-hygiene.md` — 本作業の根拠（プルーニング原則）
- 改善調査結果（本セッションの .claude 領域エージェント報告）
