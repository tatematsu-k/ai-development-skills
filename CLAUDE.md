# AI-DLC Development Skills

このリポジトリは AI-DLC (AI-Driven Development Life Cycle) ベースの開発ワークフロースキルを提供します。

## スキル一覧

| スキル | 用途 |
|--------|------|
| `aidlc:aidlc-workflow` | ワークフロー全体の管理 |
| `aidlc:requirement-definition` | 要件定義 |
| `aidlc:system-architecture` | システム設計 |
| `aidlc:subtask-decomposition` | サブタスク分割 |
| `aidlc:task-management` | タスク管理 (ローカル/GitHub Issue) |
| `aidlc:pr-strategy` | PR分割戦略 |
| `aidlc:implementation` | 実装・テスト |
| `aidlc:pr-creation` | PR作成・タスク更新 |
| `aidlc:onboarding` | リポジトリオンボーディング・基礎ドキュメント生成 |
| `aidlc:security-audit` | セキュリティ監査 (OWASP Top 10 ベース) |

## コマンド

- `/aidlc <やりたいこと>` — AI-DLCワークフロー開始
- `/task-status` — タスク進捗表示
- `/onboarding [補足情報]` — リポジトリオンボーディング・ドキュメント生成
- `/security-audit [対象範囲]` — セキュリティ監査の実行

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
