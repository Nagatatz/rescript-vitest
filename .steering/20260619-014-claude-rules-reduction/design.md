# 設計: .claude ルール群の包括的縮小

| 項目 | 内容 |
|---|---|
| 機能名 | claude-rules-reduction |
| 作成日 | 2026-06-19 |

## 1. 実装アプローチ

各 rule を「常時必要な規約 + トリガー/判断基準」に圧縮し、手順の実体は対応 skill に移す（または既存 skill 参照に一本化）。CLAUDE.md の @import 行は維持（rule ファイルは残し中身を圧縮）。

## 2. ファイル別の変更計画（移動元 → 移動先）

| ファイル | 現状 | 変更 | 行数目標 |
|---|---|---|---|
| `steering-workflow.md` | 215 | worktree 健全性チェック・マージ/クリーンアップ手順・CWD 復旧を **worktree-safety skill へ移動**。アーカイブポリシー詳細を削除（archive-steering skill が SSOT）。残すのは「いつ steering を使うか」「実装後マージ確認フロー」「worktree 運用の判断基準 + skill 参照」 | ~70 |
| `worktree-safety` skill | 34 | steering-workflow から移した詳細手順（CWD 最優先移動、削除順序、検証コマンド、未コミット時の扱い）を追記。循環参照（"詳細は steering-workflow 参照"）を解消し本 skill を SSOT 化 | ~120 |
| `definition-of-done.md` | 101 | Phase 5 の worktree クリーンアップ検証詳細を worktree-safety skill 参照に短縮。チェックリスト構造は SSOT として維持 | ~90 |
| `git-conventions.md` | 66 | 常時必要な「絵文字表・ブランチ命名表・コミット粒度」を残し、ブランチ運用フロー手順（手順 1-5）を git-workflow skill 参照に短縮 | ~45 |
| `permission-modes.md` | 48 | 判断フロー表 + Think Before Coding を残し、auto/sandbox の冗長説明・外部リンク列挙を圧縮 | ~28 |
| `claude-md-hygiene.md` | 57 | 3 つの自問 + 含める/除外する表を残し、長い公式引用・重複する過剰追加検知節を圧縮 | ~32 |
| `delegate-investigation.md` | 52 | 原則 + 「3 ファイル以上は subagent」判断基準 + subagent 対応表（簡約版）を残し、冗長な前置き引用を圧縮 | ~32 |

合計目標: rules 718 → 約 450 行（約 37% 減）。worktree-safety skill は +86 行（常時ロードではないので可）。

## 3. SSOT 再設計の原則

| 関心事 | SSOT（唯一の正） | 他からの扱い |
|---|---|---|
| worktree 削除・マージ手順 | `worktree-safety` skill | rule は判断基準 + skill 参照のみ |
| steering いつ使うか | `steering-workflow.md` rule | — |
| steering 何を満たすか | `definition-of-done.md` rule | — |
| steering 実行手順 | `steering` skill | rule は概要のみ |
| アーカイブ判定・手順 | `archive-steering` skill | rule から削除 |
| コミット絵文字・ブランチ命名 | `git-conventions.md` rule | git-workflow skill が参照 |
| ブランチ作成→PR の実行手順 | `git-workflow` skill | rule は規約のみ |

## 4. 影響範囲の分析

### 直接的な影響

- 毎セッションの @import オーバーヘッドが減る（rules 約 270 行減）。
- worktree 手順は skill に集約。worktree 操作時は worktree-safety skill が auto-invoke されるため、必要時に必要な情報が得られる。

### 間接的な影響

- 既存の rule 内相互参照（"→ steering-workflow.md の○○節"）のうち、移動した節へのリンクは worktree-safety skill 等に張り替える必要がある。リンク切れを残さない。
- CLAUDE.md 本文の skill 発火タイミング表は現状維持（既に簡潔）。

## 5. 技術的な判断

| 判断項目 | 選択肢 | 採用 | 理由 |
|---|---|---|---|
| rule ファイルの扱い | 削除して @import 削除 / 中身圧縮 | 中身圧縮 | @import 行から rule を消すと警告リスク。ファイルは残し圧縮が安全 |
| worktree 手順の SSOT | rule / skill | worktree-safety skill | 「worktree 操作時のみ必要」= 特定状況 → hygiene 規約に従い skill |
| permission-modes の扱い | skill 化 / 圧縮 | 圧縮 | 明確な auto-invoke トリガーが無く skill 化に不向き。圧縮で対応 |
| 圧縮の depth | 要点のみ / 意味保持圧縮 | 意味保持圧縮 | 規約の意味内容は失わない（要求の制約） |
