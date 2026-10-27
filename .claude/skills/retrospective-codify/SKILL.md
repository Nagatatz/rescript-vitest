---
name: retrospective-codify
description: 評価・実運用・振り返りで得た学びを skill / agent の description や `.claude/rules/` に永続化する。「振り返りをまとめて」「この学びを skill に反映」「次回に活かす形で記録」で使用。
allowed-tools: Read, Edit, Write, Glob, Grep
---

# Retrospective Codify

学びを、次のセッションが自動で読むファイルに変える。単発の学びだけなら `learn` skill。

## 手順

1. 入力を集める: `quality-reports/*.md`（`empirical-prompt-tuning` の結果）、振り返りメモ、バグの根本原因。
2. 永続化先を選ぶ:

   | 学びの性質 | 永続化先 |
   |---|---|
   | skill が発火しない / 関係ない場面で発火する | `.claude/skills/<名前>/SKILL.md` の description（典型発話を足す / 使わない場面を書く） |
   | agent がツールを誤用した | `.claude/agents/<名前>.md` の description / 本文 |
   | プロジェクト共通の振る舞い | 該当する `.claude/rules/<file>.md` |
   | 個別事象の再発防止 | `.claude/rules/learnings.md` |
   | 評価フロー自体の改善 | `.claude/skills/empirical-prompt-tuning/SKILL.md` |

3. 変更差分を提示し、ユーザー承認後に Edit / Write する。
4. リンク切れ・frontmatter の YAML 構文を確認する（Markdown の相対リンクを Read / Glob で辿る）。

## 書き方

- 対策は「気をつける」ではなく、Claude がそのまま実行できる行動で書く。
- description は短く、典型的なユーザー発話と発火条件を含める。長い説明は本文へ。
- learnings.md への追記形式:
  ```markdown
  ## YYYY-MM-DD: <タイトル>
  **観測**: 何が起きたか / **根本原因**: なぜ / **対策**: 次回どうするか / **永続化先**: 他に反映したファイル
  ```
