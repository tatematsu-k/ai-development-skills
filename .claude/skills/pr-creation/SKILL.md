---
name: pr-creation
description: "AI-DLC Construction Phase Stage 6: PRの作成とタスクステータスの更新。サブタスク実装完了後に使用。"
---

# PR作成・タスク更新 (PR Creation)

## Overview

実装完了したサブタスクのPRを作成し、タスクステータスを更新する。

**Announce at start:** 「PR作成フェーズを開始します。」

**REQUIRED SUB-SKILL:** `aidlc:pr-strategy` — PR作成ルールに従うこと
**REQUIRED SUB-SKILL:** `aidlc:task-management` — タスクステータス更新

## The Process

### Step 1: PR作成前チェック

以下を確認する:

- [ ] 全テストがパスしている
- [ ] PRサイズが ±150行以内 (超過する場合は理由を明記)
- [ ] スクリプト生成ファイルが `[scripts]` コミットで分離されている
- [ ] 各コミットが意味のある単位になっている
- [ ] デプロイ粒度で適切に分離されている

### Step 2: リモートにプッシュ

```bash
git push -u origin <branch-name>
```

### Step 3: PR作成

```bash
gh pr create --title "<type>: <description>" --body "$(cat <<'EOF'
## Summary
- [変更内容の要約 1-3行]

## Related
- 要件定義書: `aidlc-docs/requirements/<file>`
- 設計書: `aidlc-docs/designs/<file>`
- タスク: #<issue-number> (GitHub Issue管理の場合)

## Dependencies
- Depends on: #<pr-number> (依存PRがある場合)

## Changes
- [具体的な変更リスト]

## Test Plan
- [ ] ユニットテスト
- [ ] 動作確認

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 4: タスクステータス更新

**REQUIRED SKILL:** `aidlc:task-management`

1. 現在のサブタスクを `in_review` に更新
2. PRのURLをタスクに記録

### Step 5: 次のサブタスクへの遷移

残りのサブタスクがあるか確認:

**残りあり:**
> 「PR #X を作成しました: <PR URL>
> サブタスク #N を `in_review` に更新しました。
>
> 次のサブタスク #M の実装に進みます: [サブタスク名]」

**REQUIRED NEXT SKILL:** `aidlc:implementation` (次のサブタスクへ)

**全サブタスク完了:**
> 「全サブタスクのPRが作成されました。
>
> ## 進捗サマリ
> | # | サブタスク | PR | ステータス |
> |---|-----------|-----|-----------|
> | 1 | ... | #PR-1 | in_review |
> | 2 | ... | #PR-2 | in_review |
>
> PRのレビューをお願いします。」

## PR作成後のフロー

```
PR作成 → タスク更新 → 次のサブタスクあり？
                         ├─ はい → implementation スキルへ
                         └─ いいえ → 全体完了報告
```
