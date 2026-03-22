---
name: aidlc-workflow
description: "AI-DLC (AI-Driven Development Life Cycle) ベースの開発ワークフロー。3つのモード (新規開発・エンハンス・バグ修正) に応じたフェーズを管理する。"
---

# AI-DLC ベース開発ワークフロー

AWS AI-DLC と superpowers の手法を組み合わせた、人間-AI協調型の開発ワークフロー。

**起動トリガー:** `/aidlc` コマンド、または「AI-DLCで進めて」と指示された時。

## モード一覧

| モード | 用途 |
|--------|------|
| **新規開発** | 新機能をゼロから作る |
| **エンハンス** | 既存機能を改善・拡張する |
| **バグ修正** | 不具合を修正する |

---

## モード別フロー概要

### 新規開発モード

```
┌─────────────────────────────────────────────────────┐
│ Phase 1: Inception (要件定義 + 設計)                  │
│  ├─ Stage 1: 要件定義 (requirement-definition)       │
│  ├─ Stage 2: システム設計 (system-architecture)       │
│  └─ Stage 3: 人によるレビュー (Human Review Gate)     │
├─────────────────────────────────────────────────────┤
│ Phase 2: Construction (実装)                         │
│  ├─ Stage 4: サブタスク分割 (subtask-decomposition)   │
│  ├─ Stage 5: 実装・テスト (implementation)            │
│  └─ Stage 6: PR作成 (pr-creation)                    │
├─────────────────────────────────────────────────────┤
│ Phase 3: Operations (デプロイ・運用) ※将来拡張        │
└─────────────────────────────────────────────────────┘
```

### エンハンスモード

```
┌─────────────────────────────────────────────────────┐
│ Phase 1: Assessment (影響評価)                        │
│  ├─ Stage 1: エンハンス対象評価 (enhance-assessment)  │
│  ├─ Stage 2: システム設計 (system-architecture)       │
│  └─ Stage 3: 人によるレビュー (Human Review Gate)     │
├─────────────────────────────────────────────────────┤
│ Phase 2: Construction (実装)                         │
│  ├─ Stage 4: サブタスク分割 (subtask-decomposition)   │
│  ├─ Stage 5: 実装・テスト (implementation)            │
│  └─ Stage 6: PR作成 (pr-creation)                    │
├─────────────────────────────────────────────────────┤
│ Phase 3: Operations (デプロイ・運用) ※将来拡張        │
└─────────────────────────────────────────────────────┘
```

### バグ修正モード

```
┌─────────────────────────────────────────────────────┐
│ Phase 1: Investigation (バグ調査)                     │
│  └─ Stage 1: バグ調査 (bug-investigation)            │
├─────────────────────────────────────────────────────┤
│ Phase 2: Construction (実装)                         │
│  ├─ Stage 2: 実装・テスト (implementation)            │
│  └─ Stage 3: PR作成 (pr-creation)                    │
├─────────────────────────────────────────────────────┤
│ Phase 3: Operations (デプロイ・運用) ※将来拡張        │
└─────────────────────────────────────────────────────┘
```

---

## 新規開発モード 詳細

### Phase 1: Inception

#### Stage 1: 要件定義

**REQUIRED SKILL:** `aidlc:requirement-definition`

- やりたいことの明確化
- ユーザーとの対話による要件の深掘り
- 成果物: 要件定義書 (`aidlc-docs/requirements/YYYY-MM-DD-<feature>.md`)

#### Stage 2: システムアーキテクト設計

**REQUIRED SKILL:** `aidlc:system-architecture`

- API通信設計
- シーケンス図の整理
- コンポーネント間依存関係の明確化
- デプロイ粒度の特定
- 成果物: 設計書 (`aidlc-docs/designs/YYYY-MM-DD-<feature>.md`)

#### Stage 3: 人によるレビュー (Human Review Gate)

<HARD-GATE>
Stage 2の成果物を人がレビューするまで、Phase 2に進んではならない。
</HARD-GATE>

以下のメッセージを表示して承認を待つ:

> **設計レビュー待ち**
>
> 要件定義書: `aidlc-docs/requirements/YYYY-MM-DD-<feature>.md`
> 設計書: `aidlc-docs/designs/YYYY-MM-DD-<feature>.md`
>
> 上記ドキュメントを確認して、フィードバックまたは承認をお願いします。
> 修正がある場合はお知らせください。承認の場合は「OK」「進めて」等でお伝えください。

### Phase 2: Construction

→ [共通Construction フェーズ](#共通-construction-フェーズ) を参照

---

## エンハンスモード 詳細

### Phase 1: Assessment

#### Stage 1: エンハンス対象評価

**REQUIRED SKILL:** `aidlc:enhance-assessment`

- エンハンス対象機能の特定
- 既存機能への影響範囲分析
- 後方互換性の確認
- 成果物: エンハンス評価書 (`aidlc-docs/requirements/YYYY-MM-DD-<feature>-enhance.md`)

#### Stage 2: システムアーキテクト設計

**REQUIRED SKILL:** `aidlc:system-architecture`

- 既存設計との差分に焦点を当てた設計
- 後方互換性を維持する設計方針の明示
- 成果物: 設計書 (`aidlc-docs/designs/YYYY-MM-DD-<feature>.md`)

#### Stage 3: 人によるレビュー (Human Review Gate)

<HARD-GATE>
Stage 2の成果物を人がレビューするまで、Phase 2に進んではならない。
</HARD-GATE>

以下のメッセージを表示して承認を待つ:

> **設計レビュー待ち (エンハンス)**
>
> エンハンス評価書: `aidlc-docs/requirements/YYYY-MM-DD-<feature>-enhance.md`
> 設計書: `aidlc-docs/designs/YYYY-MM-DD-<feature>.md`
>
> **特に以下の点をご確認ください:**
> - 既存機能への影響範囲は適切か
> - 後方互換性は担保されているか
>
> 修正がある場合はお知らせください。承認の場合は「OK」「進めて」等でお伝えください。

### Phase 2: Construction

→ [共通Construction フェーズ](#共通-construction-フェーズ) を参照

---

## バグ修正モード 詳細

### Phase 1: Investigation

#### Stage 1: バグ調査

**REQUIRED SKILL:** `aidlc:bug-investigation`

- バグ内容のヒアリング
- 再現テストの作成
- 既存仕様の確認とあるべき姿の検討
- 修正方針の策定とユーザー確認
- 成果物: バグ調査レポート (`aidlc-docs/bugs/YYYY-MM-DD-<bug-name>.md`)

<IMPORTANT>
バグ修正モードでは要件定義・設計フェーズをスキップし、調査完了後そのまま実装に入る。
ただし修正方針はユーザーの承認を得てから実装を開始すること。
</IMPORTANT>

### Phase 2: Construction

→ [共通Construction フェーズ](#共通-construction-フェーズ) を参照

---

## 共通 Construction フェーズ

全モード共通の実装フェーズ。

#### サブタスク分割

**REQUIRED SKILL:** `aidlc:subtask-decomposition`

- 設計書またはバグ調査レポートをもとにPR単位のサブタスクに分割
- タスク管理先の選択 (ローカルファイル or GitHub Issue)
- 成果物: タスクリスト

> **注:** バグ修正モードでサブタスク分割が不要なほど小規模な場合はスキップ可。

#### 実装・テスト

**REQUIRED SKILL:** `aidlc:implementation`

- サブタスク単位でのTDD実装
- 意味のある単位でのコミット
- スクリプト生成ファイルの分離コミット

#### PR作成・タスク更新

**REQUIRED SKILL:** `aidlc:pr-creation`

- PRの作成
- タスクステータスの更新
- 次のサブタスクへの遷移

---

## フェーズ遷移ルール

- 各Stageは順序通りに実行する
- Stage間の遷移時に必ずユーザーに報告する
- Human Review Gate は明示的な承認なしにスキップ不可 (新規開発・エンハンスモード)
- バグ修正モードでは修正方針の承認をもって実装に進む
- Construction Phase の 実装→PR作成 のループはサブタスクの数だけ繰り返す

## AI-DLC 基本原則

1. **Plan-Verify-Generate**: AI が計画 → 人が検証 → AI が実行 → 人が確認
2. **タスク分解**: 曖昧さのない、狭いスコープのタスクに分解する
3. **既存パターンの踏襲**: 既存コードのパターンを参照し一貫性を保つ
4. **コンテキスト管理**: 必要な情報のみをフォーカスして作業する
5. **オーナーシップ**: エンジニアがコードの責任者。AIが生成したコードも理解し所有する

## ディレクトリ構成

```
aidlc-docs/
├── requirements/    # 要件定義書・エンハンス評価書
├── designs/         # 設計書 (API設計・シーケンス図)
├── bugs/            # バグ調査レポート
├── tasks/           # タスクリスト (ローカル管理の場合)
└── audit.md         # 作業ログ
```
