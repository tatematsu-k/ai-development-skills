# AI Development Skills

AI-DLC (AI-Driven Development Life Cycle) と [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) を組み合わせた開発ワークフロースキル集です。

**対応ハーネス:** Claude Code / Cursor

## 特徴

### aidlc プラグイン — 構造化された開発ワークフロー

- **フェーズ管理**: 要件定義 → 設計 → 人レビュー → サブタスク分割 → 実装 → PR作成 の全フェーズをガイド
- **PR単位のタスク管理**: サブタスク = PR単位で分割。ローカルファイルまたは GitHub Issue で管理
- **デプロイ粒度でPR分離**: サーバー/フロント等を別PRにし、非同期デプロイに対応
- **PRサイズ制御**: ±150行を目安にレビューしやすいPRを維持
- **スクリプト生成ファイルの分離**: `[scripts]` プレフィックス付き別コミットで追跡性を確保
- **Human Review Gate**: 設計フェーズ後に人の承認を必須とするゲート
- **TDDワークフロー強化**: ECCのTDDワークフローを統合し、80%+カバレッジを目標化
- **検証ループ統合**: PR作成前にビルド・型チェック・Lint・テスト・セキュリティスキャンを包括実行

### ecc プラグイン — 実戦で鍛えられたツールキット

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) (v1.8.0) から取り込んだスキル・コマンド・エージェント。Go/Python固有のものを除外し、TypeScript/言語非依存のものを収録。

- **28スキル**: 開発ワークフロー、バックエンド、フロントエンド、コンテンツ作成、リサーチ、外部API連携
- **40コマンド**: 開発、計画、セッション管理、継続学習、メタツール、ドキュメント
- **15エージェント**: 設計・レビュー・テスト・セキュリティ等の専門エージェント（モデル別最適配置）

## インストール

### Claude Code

#### 方法1: プラグインとしてインストール (推奨)

```bash
# Step 1: マーケットプレースを追加 (初回のみ)
/plugin marketplace add tatematsu-k/ai-development-skills

# Step 2: プラグインをインストール
/plugin install aidlc@aidlc-skills
/plugin install ecc@aidlc-skills
```

#### 方法2: 手動コピー

```bash
# このリポジトリをクローン
git clone https://github.com/tatematsu-k/ai-development-skills.git /tmp/ai-development-skills

# aidlc プラグインをコピー
mkdir -p /path/to/your-project/.claude/skills /path/to/your-project/.claude/commands
cp -r /tmp/ai-development-skills/plugins/aidlc/skills/* /path/to/your-project/.claude/skills/
cp /tmp/ai-development-skills/plugins/aidlc/commands/* /path/to/your-project/.claude/commands/

# ecc プラグインをコピー
cp -r /tmp/ai-development-skills/plugins/ecc/skills/* /path/to/your-project/.claude/skills/
cp /tmp/ai-development-skills/plugins/ecc/commands/* /path/to/your-project/.claude/commands/
mkdir -p /path/to/your-project/.claude/agents
cp /tmp/ai-development-skills/plugins/ecc/agents/* /path/to/your-project/.claude/agents/

# CLAUDE.md のルールを対象プロジェクトに追記
cat /tmp/ai-development-skills/CLAUDE.md >> /path/to/your-project/CLAUDE.md
```

#### アンインストール (プラグイン)

```bash
/plugin uninstall aidlc
/plugin uninstall ecc
```

#### 確認

```
/aidlc
```

「要件定義フェーズを開始します」と応答されれば正常にインストールされています。

### Cursor

スキル・コマンド・エージェントを Cursor の `.cursor/rules/` 形式 (`.mdc`) に変換して利用できます。

#### 方法1: インストールスクリプト (推奨)

```bash
# このリポジトリをクローン
git clone https://github.com/tatematsu-k/ai-development-skills.git /tmp/ai-development-skills

# 対象プロジェクトにルールをインストール
bash /tmp/ai-development-skills/scripts/install-cursor-rules.sh /path/to/your-project

# 特定プラグインのみインストールする場合
bash /tmp/ai-development-skills/scripts/install-cursor-rules.sh --plugin=aidlc /path/to/your-project
bash /tmp/ai-development-skills/scripts/install-cursor-rules.sh --plugin=ecc /path/to/your-project

# シンボリックリンクで常に最新を参照する場合
bash /tmp/ai-development-skills/scripts/install-cursor-rules.sh --symlink /path/to/your-project
```

#### 方法2: 手動コピー

```bash
git clone https://github.com/tatematsu-k/ai-development-skills.git /tmp/ai-development-skills
mkdir -p /path/to/your-project/.cursor/rules
cp /tmp/ai-development-skills/cursor/rules/*.mdc /path/to/your-project/.cursor/rules/
```

#### ルールのカスタマイズ

インストール後、各 `.mdc` ファイルのフロントマターを編集して挙動を調整できます:

```yaml
---
description: "ルールの説明 (Cursorが自動判定に使用)"
globs: "**/*.ts"          # 特定ファイルパターンに限定
alwaysApply: true         # 常に適用 (デフォルト: false)
---
```

| フィールド | 説明 |
|-----------|------|
| `description` | ルールの適用条件の説明。Cursor が会話の文脈に基づいて自動適用を判定する |
| `globs` | ファイルパターン指定。マッチするファイルを扱う際に自動で適用される |
| `alwaysApply` | `true` にすると全ての会話で常に適用される |

#### ルールの再生成

元のスキル定義を変更した場合、`.mdc` ファイルを再生成できます:

```bash
bash scripts/generate-cursor-rules.sh
```

#### アンインストール

```bash
rm /path/to/your-project/.cursor/rules/aidlc--*.mdc
rm /path/to/your-project/.cursor/rules/ecc--*.mdc
```

#### Cursor での制約事項

Claude Code と Cursor では利用可能な機能に差異があります:

| 機能 | Claude Code | Cursor |
|------|:-----------:|:------:|
| スキル (開発パターン・ガイドライン) | ✅ | ✅ |
| コマンド (ワークフロー指示) | ✅ `/command` | ✅ ルールとして参照 |
| エージェント (専門レビュアー) | ✅ 自動起動 | ✅ ルールとして参照 |
| フック (PreToolUse/PostToolUse) | ✅ | ❌ 非対応 |
| セッション管理 | ✅ | ❌ 非対応 |
| プラグインマーケットプレース | ✅ | ❌ 非対応 |
| モデルルーティング (opus/sonnet/haiku) | ✅ | ❌ 非対応 |

## 使い方

### aidlc: ワークフローの開始

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

5. 実装 — サブタスク単位でTDD実装・コミット (80%+カバレッジ)
   ↓
6. PR作成 — 検証ループ実行 → PRを作成しタスクステータスを更新
   ↓
   (5→6 をサブタスクの数だけ繰り返し)
```

### ecc: 個別コマンドの利用

```bash
# TDD で実装
/tdd

# コードレビュー
/code-review

# 実装計画を作成
/plan

# エージェントによるオーケストレーション
/orchestrate

# セッションの保存・復帰
/save-session
/resume-session

# ドキュメント更新
/update-docs
/update-codemaps

# 品質ゲート
/quality-gate
/verify
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
│ Stage 5: 実装・テスト  ◄──┤ ← TDD (80%+ coverage)
└────────┬────────────────┘ │
         ▼                  │
┌─────────────────────────┐ │
│ Stage 6: 検証+PR作成     │ │ ← Build/Type/Lint/Test/Security
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

## タスク管理

2つのバックエンドから選択可能 (初回使用時に選択):

| バックエンド | 管理場所 | 適したケース |
|-------------|---------|-------------|
| ローカルファイル | `aidlc-docs/tasks/` | 個人開発・小規模チーム |
| GitHub Issue | GitHub Issues | チーム開発・進捗共有が必要な場合 |

## ディレクトリ構成

```
cursor/
│   └── rules/                # Cursor 用 .mdc ルール (自動生成)
│       ├── aidlc--*.mdc
│       └── ecc--*.mdc
scripts/
│   ├── generate-cursor-rules.sh   # .mdc ルール生成スクリプト
│   └── install-cursor-rules.sh    # プロジェクトへのインストールスクリプト
plugins/
├── aidlc/                    # AI-DLC ワークフロー
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── commands/
│   │   ├── aidlc.md
│   │   └── task-status.md
│   └── skills/
│       ├── aidlc-workflow/
│       ├── requirement-definition/
│       ├── system-architecture/
│       ├── subtask-decomposition/
│       ├── task-management/
│       ├── pr-strategy/
│       ├── implementation/     # TDDワークフロー強化
│       └── pr-creation/        # 検証ループ統合
│
└── ecc/                       # Everything Claude Code
    ├── .claude-plugin/
    │   └── plugin.json
    ├── skills/                 # 31 skills
    │   ├── api-design/
    │   ├── article-writing/
    │   ├── backend-patterns/
    │   ├── bun-runtime/
    │   ├── claude-api/
    │   ├── coding-standards/
    │   ├── content-engine/
    │   ├── crosspost/
    │   ├── deep-research/
    │   ├── dmux-workflows/
    │   ├── documentation-lookup/
    │   ├── e2e-testing/
    │   ├── eval-harness/
    │   ├── exa-search/
    │   ├── fal-ai-media/
    │   ├── frontend-patterns/
    │   ├── frontend-slides/
    │   ├── investor-materials/
    │   ├── investor-outreach/
    │   ├── market-research/
    │   ├── mcp-server-patterns/
    │   ├── nextjs-turbopack/
    │   ├── rails-patterns/
    │   ├── rails-security/
    │   ├── rails-testing/
    │   ├── security-review/
    │   ├── strategic-compact/
    │   ├── tdd-workflow/
    │   ├── verification-loop/
    │   ├── video-editing/
    │   └── x-api/
    ├── commands/               # 40 commands
    │   ├── aside.md
    │   ├── build-fix.md
    │   ├── checkpoint.md
    │   ├── ... (40 files)
    │   └── verify.md
    └── agents/                 # 17 agents
        ├── architect.md
        ├── build-error-resolver.md
        ├── chief-of-staff.md
        ├── ... (17 files)
        ├── rails-reviewer.md
        ├── rails-build-resolver.md
        └── typescript-reviewer.md
```

## ecc スキル詳細

### 開発ワークフロー

| スキル | 説明 |
|--------|------|
| `tdd-workflow` | TDD (Red-Green-Refactor) の強制、80%+カバレッジ、Jest/Vitest/Playwright |
| `verification-loop` | ビルド・型チェック・Lint・テスト・セキュリティの包括的検証 |
| `coding-standards` | TypeScript/JavaScript/React/Node.js のコーディング規約 |
| `e2e-testing` | Playwright E2Eテスト: Page Object Model, CI/CD, フレイキーテスト対策 |
| `eval-harness` | Eval-driven development (EDD): capability/regression evals, pass@k |
| `security-review` | セキュリティチェックリスト: OWASP Top 10, シークレット管理, XSS, CSRF |
| `strategic-compact` | `/compact` の戦略的タイミング管理 |
| `documentation-lookup` | Context7 MCP による最新ドキュメント参照 |
| `dmux-workflows` | dmux によるマルチエージェント並列オーケストレーション |
| `bun-runtime` | Bun ランタイム: パッケージ管理・バンドル・テスト実行 |

### Ruby on Rails

| スキル | 説明 |
|--------|------|
| `rails-patterns` | Rails アーキテクチャ: Active Record, Concerns, Controller設計, Routing, Rails 8+ Defaults (Solid Trifecta, Kamal, Hotwire). 公式ガイド + DHH + コアコミッター (Aaron Patterson, Eileen Uchitelle, Jean Boussier, Xavier Noria) 準拠 |
| `rails-testing` | Rails テスト: Minitest, Fixtures, Integration Tests, TDD. t-wada の質とスピード + テストピラミッド + DHH の System Tests 廃止方針準拠 |
| `rails-security` | Rails セキュリティ: CSRF, SQL Injection, XSS, Session, Credentials, Rate Limiting (Rails 8+), CSP |

### Terraform/IaC

| スキル | 説明 |
|--------|------|
| `terraform-patterns` | Terraform アーキテクチャ: モジュール設計, State 管理, for_each/count, CI/CD, Two-Repo Pattern. HashiCorp公式 + Anton Babenko (terraform-best-practices) + Yevgeniy Brikman (Gruntwork) + Nicki Watt (evolution patterns) 準拠 |
| `terraform-testing` | Terraform テスト: Native testing (.tftest.hcl), Mocking, Checkov/Trivy/TFLint, Terratest, CI統合 |
| `terraform-security` | Terraform セキュリティ: Secrets管理, OIDC認証, 最小権限IAM, State暗号化, Ephemeral Values (v1.10+), Write-Only Attributes (v1.11+), Policy as Code |

### バックエンド

| スキル | 説明 |
|--------|------|
| `api-design` | REST API設計パターン: リソース命名, ステータスコード, ページネーション |
| `backend-patterns` | バックエンドアーキテクチャ: Repository/Service/Controller, N+1対策, Redis |
| `mcp-server-patterns` | MCP サーバー構築: ツール・リソース・Zod バリデーション |

### フロントエンド

| スキル | 説明 |
|--------|------|
| `frontend-patterns` | React/Next.js パターン: コンポーネント設計, Zustand, SWR, パフォーマンス |
| `frontend-slides` | ゼロ依存の HTML プレゼンテーション作成 |
| `nextjs-turbopack` | Next.js 16+ と Turbopack の設定・最適化 |

### コンテンツ

| スキル | 説明 |
|--------|------|
| `article-writing` | 記事・ガイド・チュートリアル・ニュースレターの執筆 |
| `content-engine` | マルチプラットフォームコンテンツ作成 (X, LinkedIn, TikTok, YouTube) |
| `crosspost` | マルチプラットフォーム配信 (X, LinkedIn, Threads, Bluesky) |
| `investor-materials` | ピッチデック・投資家向け資料の作成 |
| `investor-outreach` | コールドメール・ウォームイントロ・フォローアップ |
| `video-editing` | AI動画編集パイプライン: FFmpeg, Remotion, ElevenLabs |

### リサーチ

| スキル | 説明 |
|--------|------|
| `deep-research` | firecrawl/exa MCP を使った多ソースWebリサーチ |
| `market-research` | 市場規模分析・競合分析・技術スキャン |

### 外部API

| スキル | 説明 |
|--------|------|
| `claude-api` | Anthropic Claude API: Messages API, ストリーミング, ツール使用, Agent SDK |
| `exa-search` | Exa MCP によるニューラルWeb検索 |
| `fal-ai-media` | fal.ai MCP による画像・動画・音声生成 |
| `x-api` | X/Twitter API: 投稿, スレッド, タイムライン, OAuth |

## ecc エージェント詳細

| エージェント | モデル | 役割 |
|------------|--------|------|
| `architect` | opus | システム設計・ADR作成・トレードオフ分析 |
| `planner` | opus | 実装計画・フェーズ分割・リスク評価 |
| `chief-of-staff` | opus | コミュニケーショントリアージ (Email/Slack/LINE) |
| `code-reviewer` | sonnet | コード品質・セキュリティレビュー |
| `typescript-reviewer` | sonnet | TypeScript 型安全性・async パターンレビュー |
| `security-reviewer` | sonnet | OWASP Top 10・シークレット検出・緊急対応 |
| `tdd-guide` | sonnet | TDD (Red-Green-Refactor) の強制・カバレッジ管理 |
| `e2e-runner` | sonnet | Playwright E2Eテスト・フレイキーテスト管理 |
| `build-error-resolver` | sonnet | ビルドエラーの最小限修正 |
| `database-reviewer` | sonnet | PostgreSQL最適化・RLS・Supabaseベストプラクティス |
| `refactor-cleaner` | sonnet | デッドコード検出・安全な削除 |
| `docs-lookup` | sonnet | Context7 MCP による最新ドキュメント検索 |
| `harness-optimizer` | sonnet | Claude Code 設定の最適化分析 |
| `loop-operator` | sonnet | 自律ループの監視・ストール検出・介入 |
| `rails-reviewer` | sonnet | Rails コードレビュー: Rails Way 準拠、N+1検出、セキュリティ、規約チェック |
| `rails-build-resolver` | sonnet | Rails ビルド・マイグレーション・ランタイムエラーの最小限修正 |
| `terraform-reviewer` | sonnet | Terraform コードレビュー: HashiCorp Style Guide 準拠、セキュリティ、State管理、モジュール設計 |
| `doc-updater` | haiku | ドキュメント・コードマップの自動更新 |

## ベースとなった手法

- **[AWS AI-DLC](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/)**: Inception → Construction → Operations の3フェーズ構成、Plan-Verify-Generate サイクル
- **[superpowers](https://github.com/obra/superpowers)**: Claude Code スキル形式 (SKILL.md)、REQUIRED SKILL / HARD-GATE パターン、subagent-driven-development
- **[Everything Claude Code](https://github.com/affaan-m/everything-claude-code)**: 10ヶ月以上の実戦で鍛えられたエージェント・スキル・コマンド・フック群

## ライセンス

MIT
