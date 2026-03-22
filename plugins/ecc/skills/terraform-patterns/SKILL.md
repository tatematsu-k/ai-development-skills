---
name: terraform-patterns
description: "Terraform/OpenTofu architecture patterns, conventions, and module design based on HashiCorp official style guide, Yevgeniy Brikman (Gruntwork/Terragrunt), Anton Babenko (terraform-aws-modules), and Nicki Watt's evolution patterns."
origin: custom
metadata:
  filePattern:
    - "**/*.tf"
    - "**/*.tfvars"
    - "**/*.tftest.hcl"
    - "**/terraform.tf"
    - "**/backend.tf"
    - "**/versions.tf"
    - "**/terragrunt.hcl"
  bashPattern:
    - "terraform|tofu|terragrunt|tflint|checkov|trivy"
---

# Terraform Patterns & Conventions

Based on: [HashiCorp Style Guide](https://developer.hashicorp.com/terraform/language/style), [Terraform Best Practices](https://www.terraform-best-practices.com/) (Anton Babenko), Yevgeniy Brikman (Gruntwork), Nicki Watt (OpenCredo).

## When to Activate

- Writing or reviewing Terraform/OpenTofu configuration
- Designing module structure or state management
- Setting up CI/CD pipelines for infrastructure
- Refactoring existing Terraform code

## File Organization (Official Style Guide)

| ファイル | 用途 |
|---------|------|
| `main.tf` | Resources と data sources |
| `variables.tf` | Input variables（アルファベット順） |
| `outputs.tf` | Outputs（アルファベット順） |
| `locals.tf` | Local values |
| `providers.tf` | Provider ブロック（root module のみ） |
| `versions.tf` / `terraform.tf` | `required_version` と `required_providers` |
| `backend.tf` | Backend 設定 |
| `data.tf` | Data sources（大規模な場合は分離） |

大規模な場合は論理グループで分割: `network.tf`, `compute.tf`, `storage.tf`

## Naming Conventions

### 識別子

- **全て `snake_case`**（resources, variables, outputs, locals）
- リソース名にリソースタイプを含めない

```hcl
# BAD
resource "aws_instance" "web_aws_instance" {}

# GOOD
resource "aws_instance" "web" {}
```

- モジュールリポジトリ: `terraform-<PROVIDER>-<NAME>`
- `_`（アンダースコア）を使う。`-`（ハイフン）は使わない (Anton Babenko)
- 単一リソースのモジュールでは `this` を使う

### Output 命名 (Anton Babenko)

パターン: `{name}_{type}_{attribute}`

```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}
```

### Variable 命名

- 肯定形の boolean を使う（`enable_x`、`disable_x` ではなく）
- list/map 型は複数形
- 必ず `description` を含める

## Formatting Rules

```hcl
resource "aws_instance" "web" {
  # 1. Meta-arguments first
  count = var.instance_count

  # 2. Standard arguments (= を揃える)
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  # 3. Nested blocks (空行で区切る)
  root_block_device {
    volume_size = 50
    encrypted   = true
  }

  # 4. tags (最後の実引数)
  tags = {
    Name        = "web-${count.index}"
    Environment = var.environment
  }

  # 5. lifecycle / depends_on (最後)
  lifecycle {
    create_before_destroy = true
  }
}
```

**Rules:**
- 2スペースインデント
- 連続する単一行引数の `=` を揃える
- `terraform fmt -recursive` と `terraform validate` を毎コミット前に実行
- コメントは `#` を使用（`//` や `/* */` ではなく）

## Variable Declarations

```hcl
variable "db_disk_size" {
  type        = number
  description = "Size of the database disk in GB"
  default     = 100
  sensitive   = false

  validation {
    condition     = var.db_disk_size >= 20
    error_message = "Disk size must be at least 20 GB."
  }
}
```

**必須:** `type` と `description` は全ての variable に必要。

## Output Declarations

```hcl
output "instance_public_ip" {
  description = "The public IP of the web instance"
  value       = aws_instance.web.public_ip
  sensitive   = false
}
```

**必須:** `description` は全ての output に必要。

## Module Design

### Standard Module Structure

```
terraform-aws-vpc/
├── README.md            # Required for registry
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── modules/             # Nested modules
│   ├── public-subnet/   # README あり = public API
│   │   ├── README.md
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── internal/        # README なし = internal only
├── examples/
│   ├── basic/
│   └── complete/
└── tests/               # .tftest.hcl files
```

### 3-Layer Architecture (Anton Babenko)

| レイヤー | 説明 | 例 |
|---------|------|-----|
| **Resource Module** | 関連リソースの集合。1つのアクションを実行 | `terraform-aws-vpc` |
| **Infrastructure Module** | Resource Modules を組み合わせたデプロイ単位 | `terraform-aws-atlantis` |
| **Composition** | Infrastructure Modules のルート構成 | `live/` ディレクトリ |

### Evolution Pattern (Nicki Watt)

```
Terralith → Multi-Terralith → Terramod → Terramod+Registry → Terraservice
(1ファイル)   (環境別分割)     (モジュール化)  (バージョン管理)     (コンポーネント別state)
```

プロジェクトの成長に合わせて進化させる。Terralith に留まり続けるのはアンチパターン。

### When to Create a Module

- 意味のあるアーキテクチャ抽象化を表す場合（例: "consul-cluster"）
- **Anti-pattern:** 単一リソースの薄いラッパー（抽象化を追加しない）

### Provider in Modules

```hcl
# versions.tf (module 内)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
```

**Rule:** 再利用可能なモジュールで provider 設定をハードコードしない。呼び出し元で設定させる。

## `for_each` vs `count`

| `count` を使う場合 | `for_each` を使う場合 |
|-------------------|---------------------|
| 0 or 1 インスタンス（boolean toggle） | リソースがキーで識別される |
| 全インスタンスが完全に同一 | リストの中間からアイテムが削除される可能性がある |
| 単純な数値スケーリング | 安定したリソースアドレスが必要 |

**Critical anti-pattern:** リストで `count` を使い、中間のアイテムを削除 → インデックスがずれて不要な destroy/recreate が発生。`for_each` + map/set で回避。

```hcl
# BAD: count with list
variable "subnet_names" {
  default = ["web", "app", "db"]
}
resource "aws_subnet" "this" {
  count = length(var.subnet_names)
  # Removing "app" shifts "db" from index 2 to 1 → recreate!
}

# GOOD: for_each with map
resource "aws_subnet" "this" {
  for_each   = toset(var.subnet_names)
  cidr_block = cidrsubnet(var.vpc_cidr, 8, index(var.subnet_names, each.key))
  tags       = { Name = each.key }
}
```

## State Management

### Remote Backend（必須）

チーム/本番環境では絶対にローカル state を使わない。

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket       = "my-terraform-state"
    key          = "prod/vpc/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true  # Terraform 1.10+ (replaces DynamoDB locking)
  }
}
```

### State 分離戦略

環境ごと + コンポーネントごとに state を分離（blast radius の最小化）:

```
state/
├── prod/vpc/terraform.tfstate
├── prod/ecs/terraform.tfstate
├── staging/vpc/terraform.tfstate
└── staging/ecs/terraform.tfstate
```

### .gitignore

```gitignore
*.tfstate
*.tfstate.*
.terraform/
.terraform.tfstate.lock.info
crash.log
*.tfvars       # If contains secrets
override.tf
override.tf.json

# Always commit
.terraform.lock.hcl
```

### Refactoring with `moved` Blocks

```hcl
# Rename resource
moved {
  from = aws_instance.old_name
  to   = aws_instance.new_name
}

# Move into module
moved {
  from = aws_instance.web
  to   = module.compute.aws_instance.web
}
```

`terraform state mv` より宣言的で安全。`moved` ブロックは共有モジュールでは永続的に保持する。

## Two-Repo Pattern (Yevgeniy Brikman / Gruntwork)

### infrastructure-modules（再利用可能なモジュール）

```
infrastructure-modules/
├── modules/
│   ├── vpc/
│   ├── ecs-cluster/
│   └── rds/
└── README.md
```

Git tag でバージョニング。

### infrastructure-live（デプロイ構成）

```
infrastructure-live/
├── account-1/
│   ├── _global/             # アカウント全体 (IAM, Route53)
│   └── ap-northeast-1/
│       ├── _global/         # リージョン全体 (ECR)
│       ├── dev/
│       │   ├── vpc/terragrunt.hcl
│       │   └── app/terragrunt.hcl
│       └── prod/
│           ├── vpc/terragrunt.hcl
│           └── app/terragrunt.hcl
```

**Rule:** `infrastructure-live` では immutable なバージョンタグを参照。環境ごとにバージョンを昇格: dev → staging → prod

## Import (Terraform 1.5+)

```hcl
import {
  to = aws_instance.web
  id = "i-1234567890abcdef0"
}
```

```bash
# Config を自動生成
terraform plan -generate-config-out=generated.tf
# 確認後に apply
terraform apply
```

## CI/CD Workflow

```
PR opened → terraform fmt -check → terraform validate → terraform plan → plan をPRコメントに投稿
PR merged → terraform plan → 手動承認ゲート → terraform apply
```

**Rules:**
- CI で Terraform バージョンを固定
- OIDC 認証を使用（長期間有効な credentials は使わない）
- plan（read-only）と apply（write）で IAM ロールを分離
- Drift detection: `terraform plan -refresh-only` を定期実行

## Anti-Pattern Summary

| Anti-Pattern | 推奨 |
|-------------|------|
| ローカル state（チーム環境） | Remote backend + state locking |
| 1つの state に全リソース | コンポーネント別 + 環境別に分離 |
| `count` + 可変リスト | `for_each` + map/set |
| 単一リソースのラッパーモジュール | 意味のある抽象化のみモジュール化 |
| モジュール内で provider をハードコード | 呼び出し元で設定 |
| 手動 `terraform state mv` | `moved` ブロック（宣言的） |
| `.tf` ファイルにシークレット | Vault / Secrets Manager / `sensitive = true` |
| 長期間有効な static credentials | OIDC / dynamic credentials |
| variable の乱用 | デプロイ間で変わるもののみ公開 |
| `terraform.tfvars` を全レベルで使用 | Composition レベルのみ |
| 深いモジュールネスト | フラットに保つ（1-2レベルまで） |
| コンソールでの手動変更 | GitOps: main ブランチ = source of truth |

---

**Sources:**
- [HashiCorp Terraform Style Guide](https://developer.hashicorp.com/terraform/language/style)
- [HashiCorp Module Development](https://developer.hashicorp.com/terraform/language/modules/develop)
- [HashiCorp Recommended Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [Anton Babenko: Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Yevgeniy Brikman: Comprehensive Guide to Terraform](https://blog.gruntwork.io/a-comprehensive-guide-to-terraform-b3d32832baca)
- [Nicki Watt: Evolving Infrastructure with Terraform](https://www.hashicorp.com/en/resources/evolving-infrastructure-terraform-opencredo)
- [AWS Prescriptive Guidance: Terraform](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/)
- [Google Cloud: Terraform Best Practices](https://docs.cloud.google.com/docs/terraform/best-practices/general-style-structure)
