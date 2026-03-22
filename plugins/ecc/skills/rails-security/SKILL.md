---
name: rails-security
description: "Ruby on Rails security best practices based on the official Rails Security Guide. Covers CSRF, SQL injection, XSS, session security, credentials management, rate limiting, and Content Security Policy."
origin: custom
metadata:
  filePattern:
    - "**/app/controllers/**"
    - "**/config/initializers/**"
    - "**/config/credentials*"
    - "**/app/views/**/*.erb"
  bashPattern:
    - "bin/rails credentials|brakeman|bundler-audit"
---

# Rails Security

Based on: [Rails Security Guide](https://guides.rubyonrails.org/security.html) and Rails core team practices.

## When to Activate

- Writing controllers, views, or authentication logic
- Reviewing code for security vulnerabilities
- Configuring credentials, sessions, or CORS
- Setting up Content Security Policy

## CSRF Protection

Rails のデフォルトで有効。

```erb
<!-- レイアウトに必須 -->
<%= csrf_meta_tags %>
```

**Rules:**
- GET は読み取りのみ。状態変更は POST/PATCH/DELETE
- Turbo が CSRF トークンを自動処理
- API-only アプリでは `protect_from_forgery with: :null_session`

## SQL Injection

```ruby
# CRITICAL: 絶対にやってはいけない
User.where("name = '#{params[:name]}'")
User.where("name = " + params[:name])

# SAFE: パラメータ化クエリ
User.where("name = ?", params[:name])
User.where(name: params[:name])
User.where("name = :name", name: params[:name])

# SAFE: LIKE クエリ
User.where("name LIKE ?", "%#{sanitize_sql_like(params[:query])}%")
```

## XSS (Cross-Site Scripting)

Rails はテンプレートの出力を自動エスケープする。

```erb
<!-- 自動エスケープ（安全） -->
<%= @user.bio %>

<!-- html_safe は信頼できるデータのみ -->
<%= sanitize(@user.bio, tags: %w[p br strong em]) %>

<!-- DANGER: 絶対に使わない -->
<%= raw @user.bio %>
<%= @user.bio.html_safe %>
```

## Content Security Policy

```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, "https:"
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self, "https://fonts.googleapis.com"
    policy.connect_src :self
  end

  # Nonce を使用（推奨）
  config.content_security_policy_nonce_generator = ->(request) {
    request.session.id.to_s
  }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
```

## Session Security

```ruby
# ログイン後に必ず reset_session（セッション固定攻撃防止）
def create
  user = User.authenticate(params[:email], params[:password])
  if user
    reset_session
    session[:user_id] = user.id
    redirect_to root_path
  end
end
```

**Rules:**
- セッションには `user_id` のみ保存（複雑なオブジェクトは不可）
- CookieStore はデフォルトで暗号化
- HttpOnly フラグを Cookie に設定

## Credentials Management

```bash
# 暗号化クレデンシャルの編集
bin/rails credentials:edit

# 環境別クレデンシャル
bin/rails credentials:edit --environment production
```

```ruby
# 使用
Rails.application.credentials.secret_api_key
Rails.application.credentials.dig(:aws, :access_key_id)
```

**Rules:**
- `config/master.key` は絶対にコミットしない（.gitignore に含まれる）
- `config.require_master_key = true` で本番環境での起動を保証
- 環境変数よりクレデンシャルを優先

## Rate Limiting (Rails 8+)

```ruby
class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create
end

class PasswordsController < ApplicationController
  rate_limit to: 5, within: 1.minute, only: :create,
    with: -> { redirect_to login_path, alert: "Too many attempts" }
end
```

## Authorization

```ruby
# 常に current_user でスコープ（IDOR防止）
@project = current_user.projects.find(params[:id])

# BAD: ID直接検索（他ユーザーのデータにアクセス可能）
@project = Project.find(params[:id])
```

## Strong Parameters

```ruby
# Rails 8: expect（推奨 — 構造不一致で 400）
def article_params
  params.expect(article: [:title, :body, :status])
end

# permit! は絶対に使わない
params.permit!  # DANGER: 全パラメータを許可
```

## Regex Safety

```ruby
# BAD: 行境界（改行で回避可能）
validates :url, format: { with: /^https?:\/\// }

# GOOD: 文字列境界
validates :url, format: { with: /\Ahttps?:\/\// }
```

Ruby の `^`/`$` は行境界。`\A`/`\z` が文字列境界。

## HTTP Security Headers

Rails がデフォルトで設定:
- `X-Frame-Options: SAMEORIGIN` — クリックジャッキング防止
- `X-Content-Type-Options: nosniff` — MIME スニッフィング防止
- `Referrer-Policy: strict-origin-when-cross-origin`

```ruby
# HSTS の有効化
config.force_ssl = true
```

## File Upload Security

```ruby
# Active Storage でのバリデーション
class User < ApplicationRecord
  has_one_attached :avatar

  validates :avatar, content_type: %w[image/png image/jpeg],
                     size: { less_than: 5.megabytes }
end
```

**Rules:**
- ユーザーがアップロードしたファイル名を直接使わない
- Content-Type を検証する（拡張子だけでなく）
- パブリックディレクトリに直接保存しない

## Mass Assignment

```ruby
# config/application.rb
# Rails 8 ではデフォルトで strict
config.active_record.store_full_class_name_in_sti_column = true
```

## Security Audit Tools

```bash
# Brakeman: 静的解析
gem install brakeman
brakeman

# bundler-audit: Gem の脆弱性チェック
gem install bundler-audit
bundler-audit check --update

# Rails 組み込み
bin/rails routes  # 不要なルートの確認
```

## Checklist

- [ ] CSRF トークンがフォームとレイアウトに含まれている
- [ ] SQL クエリがパラメータ化されている
- [ ] ユーザー入力が `sanitize` でエスケープされている
- [ ] `reset_session` がログイン後に呼ばれている
- [ ] Strong Parameters で許可するパラメータを明示している
- [ ] Authorization が current_user でスコープされている
- [ ] `config.force_ssl = true` が本番で有効
- [ ] `master.key` が `.gitignore` に含まれている
- [ ] Rate limiting が認証エンドポイントに設定されている
- [ ] Regex が `\A`/`\z` を使用している
- [ ] Brakeman が CI で実行されている

---

**Sources:**
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [Rails 8 Rate Limiting](https://rubyonrails.org/2024/11/7/rails-8-no-paas-required)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
