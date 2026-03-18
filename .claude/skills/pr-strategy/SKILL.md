---
name: pr-strategy
description: "PR分割戦略スキル。デプロイ粒度・PRサイズ・コミット戦略のルールを定義する。サブタスク分割時とPR作成時に参照される。"
---

# PR分割戦略 (PR Strategy)

## Overview

PRの分割単位・サイズ・コミット戦略のルールを定義する。
このスキルは他のスキル (`subtask-decomposition`, `implementation`, `pr-creation`) から参照される。

## PR分割ルール

### Rule 1: デプロイ粒度で分離

各コンポーネントは非同期でデプロイされるため、依存関係がある修正を1つのPRに入れない。

**例:**
```
❌ 1つのPR: サーバーAPIの追加 + フロントのAPI利用
✅ 分離: PR-1: サーバーAPIの追加
         PR-2: フロントのAPI利用 (PR-1のデプロイ後にマージ可能)
```

**デプロイ粒度の例:**
- サーバー (API)
- フロントエンド (Web/Mobile)
- バッチ処理
- インフラ (IaC)
- データベースマイグレーション
- 共通ライブラリ

### Rule 2: PRサイズ制限

**目安: +150行 / -150行 以内**

人間がレビューしやすいサイズに保つ。超える場合は以下を検討:

1. さらに細かいサブタスクに分割できないか
2. リファクタリングと機能追加を別PRにできないか
3. テストとプロダクションコードを分けられないか (原則は一緒だが、テストが大量の場合)

### Rule 3: スクリプト生成ファイルの分離

スクリプトによって作成・更新されるファイル (マイグレーション、コード生成、ロックファイル等) は:

1. **別コミットにする**
2. **コミットメッセージに `[scripts]` プレフィックスを付ける**
3. **実際に実行したスクリプトをコミットメッセージに記載する**

```bash
# 例
git commit -m "[scripts] rails generate migration AddStatusToOrders

Executed: bin/rails generate migration AddStatusToOrders status:integer"
```

### Rule 4: 意味のあるコミット単位

- 1つのコミットは1つの論理的変更を表す
- WIP コミットは避ける
- テストとそのテストを通す実装は同じコミットにする (TDDの場合はfailing test → implementation の2コミットも可)

## コミットメッセージ規約

```
<type>: <description>

[optional body]

Co-Authored-By: Claude <noreply@anthropic.com>
```

**type:**
- `feat`: 新機能
- `fix`: バグ修正
- `refactor`: リファクタリング
- `test`: テストの追加・修正
- `docs`: ドキュメント
- `chore`: ビルド・設定の変更
- `[scripts]`: スクリプト生成ファイル

## PR間の依存関係管理

PRに依存関係がある場合、PR descriptionに明記する:

```markdown
## Dependencies
- Depends on: #123 (サーバーAPI追加)
- Blocked by: なし
```

## チェックリスト

PR作成前に確認:
- [ ] PRサイズが ±150行以内か
- [ ] デプロイ粒度で適切に分離されているか
- [ ] スクリプト生成ファイルが `[scripts]` コミットで分離されているか
- [ ] 各コミットが意味のある単位か
- [ ] PR descriptionに依存関係が記載されているか
