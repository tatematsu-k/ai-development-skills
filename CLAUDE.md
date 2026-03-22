# AI Development Skills

このリポジトリは Claude Code 向けの開発ワークフロースキルを2つのプラグインとして提供します。

## プラグイン

### aidlc — AI-DLC ワークフロー

AI-DLC (AI-Driven Development Life Cycle) ベースの開発ワークフロー。

| スキル | 用途 |
|--------|------|
| `aidlc:aidlc-workflow` | ワークフロー全体の管理 |
| `aidlc:requirement-definition` | 要件定義 |
| `aidlc:system-architecture` | システム設計 |
| `aidlc:subtask-decomposition` | サブタスク分割 |
| `aidlc:task-management` | タスク管理 (ローカル/GitHub Issue) |
| `aidlc:pr-strategy` | PR分割戦略 |
| `aidlc:implementation` | 実装・テスト (TDDワークフロー強化版) |
| `aidlc:pr-creation` | PR作成・タスク更新 (検証ループ統合) |

**コマンド:** `/aidlc <やりたいこと>`, `/task-status`

### ecc — Everything Claude Code

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) から取り込んだ、実戦で鍛えられたスキル・コマンド・エージェント。

#### Skills (31個)

| カテゴリ | スキル |
|---------|--------|
| 開発ワークフロー | `tdd-workflow`, `verification-loop`, `coding-standards`, `e2e-testing`, `eval-harness`, `security-review`, `strategic-compact`, `documentation-lookup`, `dmux-workflows`, `bun-runtime` |
| Ruby on Rails | `rails-patterns`, `rails-testing`, `rails-security` |
| バックエンド | `api-design`, `backend-patterns`, `mcp-server-patterns` |
| フロントエンド | `frontend-patterns`, `frontend-slides`, `nextjs-turbopack` |
| コンテンツ | `article-writing`, `content-engine`, `crosspost`, `investor-materials`, `investor-outreach`, `video-editing` |
| リサーチ | `deep-research`, `market-research` |
| 外部API | `claude-api`, `exa-search`, `fal-ai-media`, `x-api` |

#### Commands (40個)

| カテゴリ | コマンド |
|---------|---------|
| 開発 | `/build-fix`, `/code-review`, `/e2e`, `/tdd`, `/test-coverage`, `/quality-gate`, `/verify`, `/refactor-clean` |
| 計画 | `/plan`, `/orchestrate`, `/devfleet` |
| セッション | `/save-session`, `/resume-session`, `/sessions`, `/checkpoint`, `/aside` |
| 学習 | `/learn`, `/learn-eval`, `/evolve`, `/instinct-export`, `/instinct-import`, `/instinct-status`, `/projects`, `/promote` |
| メタ | `/context-budget`, `/model-route`, `/prompt-optimize`, `/harness-audit`, `/skill-create`, `/skill-health`, `/rules-distill` |
| ドキュメント | `/docs`, `/update-docs`, `/update-codemaps` |
| その他 | `/eval`, `/loop-start`, `/loop-status`, `/setup-pm`, `/pm2`, `/claw` |

#### Agents (17個)

| モデル | エージェント |
|--------|------------|
| opus | `architect`, `chief-of-staff`, `planner` |
| sonnet | `build-error-resolver`, `code-reviewer`, `database-reviewer`, `docs-lookup`, `e2e-runner`, `harness-optimizer`, `loop-operator`, `refactor-cleaner`, `security-reviewer`, `tdd-guide`, `typescript-reviewer`, `rails-reviewer`, `rails-build-resolver` |
| haiku | `doc-updater` |

## 重要ルール

### PR分割
- デプロイ粒度で分離する (サーバーAPI + フロント利用 → 別PR)
- PRサイズは ±150行以内を目標
- スクリプト生成ファイルは `[scripts]` プレフィックス付き別コミット

### コミット
- 意味のある単位で適宜コミットする
- スクリプト生成ファイルはコミットを分け、実行したスクリプトをメッセージに記載

### ワークフロー
- 要件定義 → 設計 → **人レビュー (必須)** → サブタスク分割 → 実装 → PR作成
- 設計レビューは人の承認なしにスキップ不可
