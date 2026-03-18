# AI-DLC Development Skills for Claude Code

AWS [AI-DLC (AI-Driven Development Life Cycle)](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) と [superpowers](https://github.com/obra/superpowers) の手法を組み合わせた、Claude Code 向けの開発ワークフロースキルです。

## 特徴

- **フェーズ管理**: 要件定義 → 設計 → 人レビュー → サブタスク分割 → 実装 → PR作成 の全フェーズをガイド
- **PR単位のタスク管理**: サブタスク = PR単位で分割。ローカルファイルまたは GitHub Issue で管理
- **デプロイ粒度でPR分離**: サーバー/フロント等を別PRにし、非同期デプロイに対応
- **PRサイズ制御**: ±150行を目安にレビューしやすいPRを維持
- **スクリプト生成ファイルの分離**: `[scripts]` プレフィックス付き別コミットで追跡性を確保
- **Human Review Gate**: 設計フェーズ後に人の承認を必須とするゲート

## インストール

### 方法1: Claude Code プラグインとしてインストール (推奨)

Claude Code の `/plugin` コマンドでインストールできます。

```bash
# Step 1: マーケットプレースを追加 (初回のみ)
/plugin marketplace add tatematsu-k/ai-development-skills

# Step 2: プラグインをインストール
/plugin install aidlc
```

または、GitHub リポジトリから直接インストール:

```bash
/plugin install tatematsu-k/ai-development-skills
```

### 方法2: 手動コピー

プラグインシステムを使わず、対象プロジェクトに直接コピーする場合:

```bash
# このリポジトリをクローン
git clone https://github.com/tatematsu-k/ai-development-skills.git /tmp/ai-development-skills

# 対象プロジェクトの .claude/ にスキルとコマンドをコピー
mkdir -p /path/to/your-project/.claude/skills /path/to/your-project/.claude/commands
cp -r /tmp/ai-development-skills/skills/* /path/to/your-project/.claude/skills/
cp /tmp/ai-development-skills/commands/* /path/to/your-project/.claude/commands/

# CLAUDE.md のルールを対象プロジェクトに追記
cat /tmp/ai-development-skills/CLAUDE.md >> /path/to/your-project/CLAUDE.md
```

### アンインストール

```bash
/plugin uninstall aidlc
```

### インストール確認

対象プロジェクトで Claude Code を起動し、以下を実行:

```
/aidlc
```

「要件定義フェーズを開始します」と応答されれば正常にインストールされています。

## 使い方

### ワークフローの開始

```
/aidlc ユーザーのプロフィール画像アップロード機能を追加したい
```

これにより以下のフェーズが順に実行されます:

#### Phase 1: Inception (要件定義 + 設計)

```
1. 要件定義 — 対話を通じて要件を明確化
   成果物: aidlc-docs/requirements/YYYY-MM-DD-<feature>.md

2. システム設計 — API設計・シーケンス図・デプロイ依存関係マップ
   成果物: aidlc-docs/designs/YYYY-MM-DD-<feature>.md

3. Human Review Gate — あなたが設計書をレビューし承認
```

#### Phase 2: Construction (実装)

```
4. サブタスク分割 — PR単位でタスクを分割
   管理先: ローカルファイル or GitHub Issue (初回に選択)

5. 実装 — サブタスク単位でTDD実装・コミット
   ↓
6. PR作成 — PRを作成しタスクステータスを更新
   ↓
   (5→6 をサブタスクの数だけ繰り返し)
```

### タスク進捗の確認

```
/task-status
```

### ワークフロー図

```
/aidlc <やりたいこと>
  │
  ▼
┌─────────────────────────┐
│ Stage 1: 要件定義        │ ← 対話で深掘り
└────────┬────────────────┘
         ▼
┌─────────────────────────┐
│ Stage 2: システム設計     │ ← API・シーケンス図
└────────┬────────────────┘
         ▼
┌─────────────────────────┐
│ Stage 3: Human Review    │ ← あなたの承認が必須
└────────┬────────────────┘
         ▼
┌─────────────────────────┐
│ Stage 4: サブタスク分割   │ ← PR単位で分割
└────────┬────────────────┘
         ▼
┌─────────────────────────┐
│ Stage 5: 実装・テスト  ◄──┤
└────────┬────────────────┘ │
         ▼                  │
┌─────────────────────────┐ │
│ Stage 6: PR作成・更新     │ │
└────────┬────────────────┘ │
         │  次のサブタスク    │
         └──────────────────┘
         │  全完了
         ▼
      完了報告
```

## PR・コミットのルール

### PR分割

| ルール | 説明 |
|--------|------|
| デプロイ粒度 | サーバーAPI追加とフロントのAPI利用は別PR |
| サイズ | ±150行以内を目標 |
| 依存関係 | PR description に依存PRを明記 |

### コミット

| 種別 | ルール |
|------|--------|
| 通常コミット | 意味のある変更ごとに適宜コミット |
| スクリプト生成 | `[scripts]` プレフィックス + 実行コマンドをメッセージに記載 |
| 共著表記 | `Co-Authored-By: Claude <noreply@anthropic.com>` |

#### スクリプト生成コミットの例

```bash
git commit -m "[scripts] rails generate migration AddStatusToOrders status:integer

Executed: bin/rails generate migration AddStatusToOrders status:integer

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## タスク管理

2つのバックエンドから選択可能 (初回使用時に選択):

| バックエンド | 管理場所 | 適したケース |
|-------------|---------|-------------|
| ローカルファイル | `aidlc-docs/tasks/` | 個人開発・小規模チーム |
| GitHub Issue | GitHub Issues | チーム開発・進捗共有が必要な場合 |

## ディレクトリ構成

スキル使用時にプロジェクト内に生成されるドキュメント:

```
aidlc-docs/
├── requirements/    # 要件定義書
├── designs/         # 設計書 (API設計・シーケンス図)
└── tasks/           # タスクリスト (ローカル管理の場合)
```

## スキル一覧

| スキル | フェーズ | 説明 |
|--------|---------|------|
| `aidlc-workflow` | - | 全体フロー管理 (エントリーポイント) |
| `requirement-definition` | Inception | 要件定義・対話による深掘り |
| `system-architecture` | Inception | API設計・シーケンス図・デプロイ依存関係 |
| `subtask-decomposition` | Construction | PR単位のサブタスク分割 |
| `task-management` | Construction | タスク管理 (ローカル/GitHub Issue) |
| `pr-strategy` | Construction | PR分割・コミットルール |
| `implementation` | Construction | TDD実装・コミット |
| `pr-creation` | Construction | PR作成・タスクステータス更新 |

## ベースとなった手法

- **[AWS AI-DLC](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/)**: Inception → Construction → Operations の3フェーズ構成、Plan-Verify-Generate サイクル
- **[superpowers](https://github.com/obra/superpowers)**: Claude Code スキル形式 (SKILL.md)、REQUIRED SKILL / HARD-GATE パターン、subagent-driven-development

## ライセンス

MIT
