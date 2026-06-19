# ステアリングワークフロー

> **Permission Mode との住み分け**: 軽微な変更（差分を 1 文で説明できる範囲）は Plan Mode で十分。中規模以上で本ワークフローを使う。詳細は `permission-modes.md`。
>
> **手順の実体は skill にある**: 実行手順は `steering` skill、worktree 操作は `worktree-safety` skill、アーカイブは `archive-steering` skill が SSOT。本 rule は「いつ・何のために使うか」の判断を担う。

## いつ使うか

コードの変更を伴う指示を受けたら、**コードを 1 行も書く前に**以下を実行する:

1. `.steering/[YYYYMMDD]-[NNN]-[開発タイトル]/` を作成する
2. `requirements.md` → `design.md` → `tasklist.md` を順に作成し、各々ユーザー承認を得る
3. `EnterWorktree` で隔離環境を用意する（→ git worktree 運用）
4. 承認された `tasklist.md` に従い実装する
5. ビルドが通ることを確認し、適切な粒度でコミットする
6. **完了定義**（`definition-of-done.md`）の全項目を満たす
7. ユーザーに main へのマージ可否を確認し、承認後はマージからクリーンアップまで一括実行する

**例外:** タイポ修正、1 行の設定変更など明らかに軽微な修正はステアリングを省略してよい。

## 実装完了後のマージ確認

worktree での実装を完了しコミットした後:

1. **マージ確認**: `AskUserQuestion` で main へのマージ可否を確認する。選択肢の 1 つ目に「main にマージ (Recommended)」を置く
2. **承認時**: `worktree-safety` skill の「マージ・クリーンアップ手順」に従い、マージからブランチ削除まで途中で停止せず一括実行する
3. **拒否時**: ユーザーの指示に従う（追加修正、レビュー待ち等）

## 必ず守ること

- コード変更前にステアリングファイルを作成する
- 新しい作業には新しい `.steering/` ディレクトリを作る（既存の使い回し禁止）
- tasklist.md の更新タイミングは `definition-of-done.md` の各 Phase に従う

## 調査・リサーチタスク

コード変更を伴わない調査でもステアリングドキュメントを作成しコミットする。`main` に直接コミット可。コミットメッセージは `📝 Add <調査内容>`。

## git worktree 運用

ステアリングを伴うコード実装は **Claude Code のビルトイン worktree 機能**で隔離する。メインリポジトリではステアリングドキュメントの作成・承認のみ行う。

- **単一機能:** `EnterWorktree` ツール（または `claude --worktree <機能名>`）。worktree は `.claude/worktrees/<機能名>/` に作成され、ブランチ `worktree-<機能名>` が HEAD から自動生成される。
- **並列実装:** 各ウィンドウで `claude --worktree <機能名>`。バッチブランチ戦略の詳細は `steering` skill 参照。
- **手動 worktree は使わない**（`git worktree add` による手動作成は非推奨）。

> **健全性チェック・マージ・クリーンアップ・CWD 復旧の手順は `worktree-safety` skill が SSOT。** worktree を削除・prune する前に必ず CWD をメインリポジトリへ移すこと（`git -C` での代用禁止）。順序を誤ると CWD が壊れ全 Bash が実行不能になる。

## アーカイブポリシー

`.steering/` 直下はアクティブな作業のみを置き、最終コミット日が 30 日以上前のディレクトリは `.steering/archive/` へ退避する。**判定基準・手順・運用タイミングは `archive-steering` skill が SSOT**（`/archive-steering` で起動。月初に実行）。判断はディレクトリ名の日付ではなく最終コミット日で行う。
