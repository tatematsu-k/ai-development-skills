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

### Step 1: PR作成前 検証ループ (Verification Loop)

PR作成前に包括的な検証を実行する。全フェーズをパスするまでPRは作成しない。

#### Phase 1: ビルド検証
```bash
npm run build 2>&1 | tail -20
```
ビルドが失敗した場合は **STOP** — 修正してから続行。

#### Phase 2: 型チェック
```bash
npx tsc --noEmit 2>&1 | head -30
```
型エラーがある場合はクリティカルなものを修正。

#### Phase 3: Lint チェック
```bash
npm run lint 2>&1 | head -30
```

#### Phase 4: テストスイート
```bash
npm run test -- --coverage 2>&1 | tail -50
```
カバレッジ目標: 80%以上

#### Phase 5: セキュリティスキャン
```bash
# シークレットの混入チェック
grep -rn "sk-" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
# console.log の残存チェック
grep -rn "console.log" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | head -10
```

#### Phase 6: Diff レビュー
```bash
git diff --stat
git diff HEAD~1 --name-only
```
変更ファイルを確認: 意図しない変更、エラーハンドリング漏れ、エッジケースがないか。

#### 検証レポート出力
```
VERIFICATION REPORT
==================
Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X issues)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR
```

**Overall が NOT READY の場合:** 問題を修正してから Step 2 に進む。

#### 従来のチェックリスト（検証レポートと合わせて確認）

- [ ] PRサイズが ±150行以内 (超過する場合は理由を明記)
- [ ] スクリプト生成ファイルが `[scripts]` コミットで分離されている
- [ ] 各コミットが意味のある単位になっている
- [ ] デプロイ粒度で適切に分離されている

### Step 2: リモートにプッシュ

```bash
git push -u origin <branch-name>
```

### Step 3: PR作成

PR作成前に、要件定義書と設計書の内容を読み込む:

1. `aidlc-docs/requirements/` 配下から該当する要件定義書 (`.md`) を特定し、内容を読み込む
2. `aidlc-docs/designs/` 配下から該当する設計書 (`.md`) を特定し、内容を読み込む

**注意:** ファイルが見つからない場合は「(ドキュメントなし)」と記載する。

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

---

<details>
<summary>📋 要件定義書</summary>

[要件定義書の内容をここに展開する]

</details>

<details>
<summary>📐 設計書</summary>

[設計書の内容をここに展開する]

</details>

---

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
