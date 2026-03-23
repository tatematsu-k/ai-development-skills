# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [aidlc-v1.1.0 / ecc-v1.9.0] - 2026-03-23

### aidlc v1.1.0

#### Added
- TDD ワークフロー強化版と検証ループの統合 (`implementation`, `pr-creation`)
- Cursor サポート（`.mdc` ルール自動生成）

#### Changed
- マーケットプレイス形式にリストラクチャ（`plugins/` ディレクトリ構成）

### ecc v1.9.0

#### Added
- doc-architect エージェント（ドキュメント構造化・可視化）
- Terraform スキル・エージェント（HashiCorp / コミュニティベストプラクティス）
- Rails スキル・エージェント（公式ガイド / コアチーム知見ベース）
- Cursor サポート（`.mdc` ルール自動生成）

## [aidlc-v1.0.0 / ecc-v1.8.0] - 2026-03-18

### aidlc v1.0.0

#### Added
- 初回リリース
- AI-DLC ワークフロー全体管理 (`aidlc-workflow`)
- 要件定義 (`requirement-definition`)
- システム設計 (`system-architecture`)
- サブタスク分割 (`subtask-decomposition`)
- タスク管理 — ローカル / GitHub Issue 対応 (`task-management`)
- PR 分割戦略 (`pr-strategy`)
- 実装・TDD (`implementation`)
- PR 作成・タスク更新 (`pr-creation`)
- `/aidlc`, `/task-status` コマンド

### ecc v1.8.0

#### Added
- 初回取り込み（[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) v1.8.0 ベース）
- 28 スキル、40 コマンド、15 エージェント
