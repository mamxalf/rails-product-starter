# Rails General Product Boilerplate — Implementation Roadmap

> **For agentic workers:** implement this document from top to bottom. Track progress by changing each checkbox from `- [ ]` to `- [x]`. Use test-driven development, run the quality gate after every phase, and commit after each independently working task.

**Goal:** Build a reusable, product-agnostic Rails starter repository that already includes authentication, account management, authorization, public and application layouts, admin tooling, internationalization, notifications, file uploads, background jobs, auditing, tests, CI, and production deployment foundations.

**Architecture:** Rails remains a full-stack modular monolith. ERB + Hotwire own public pages and administration; Inertia + Svelte own application-like authenticated screens. PostgreSQL is the system of record, Vite manages all frontend compilation, and Rails' Solid stack is kept for jobs, cache, and WebSockets until actual scale requires replacements.

**Tech stack:** Ruby on Rails 8.1.x, Ruby 3.4.x, PostgreSQL, Vite Ruby, TypeScript, Svelte, Inertia Rails, Turbo, Stimulus, Tailwind CSS, RSpec, Vitest, Playwright, Active Storage, Active Job, Solid Queue, Solid Cache, Solid Cable, Action Mailer, Pundit, Docker, and GitHub Actions.

**Verified baseline:** 2 August 2026. Before executing, compare the pinned versions with the current stable releases and review their upgrade notes. Do not use edge or prerelease versions for the starter's default branch.

---

## 1. Scope and design rules

### 1.1 What belongs in the core boilerplate

- [ ] Session-based authentication.
- [ ] Registration, login, logout, password reset, and email verification.
- [ ] Account settings, profile, preferred locale, and time zone.
- [ ] Simple global roles: `member`, `staff`, and `admin`.
- [ ] Server-side authorization policies.
- [ ] Public ERB layout and authenticated Svelte application layout.
- [ ] Generic member dashboard and admin dashboard.
- [ ] Admin user management.
- [ ] Database notifications and unread count.
- [ ] Generic audit events for sensitive actions.
- [ ] Active Storage configuration and avatar upload example.
- [ ] Background jobs and mail delivery.
- [ ] Indonesian and English application UI.
- [ ] Health checks, error pages, logging, and secure defaults.
- [ ] RSpec, Vitest, and Playwright.
- [ ] GitHub Actions CI.
- [ ] Docker and deployment-ready production configuration.
- [ ] Seeded admin and demonstration member accounts for development only.
- [ ] A documented process for creating a new product from the template.

### 1.2 What must remain optional

Do not place these domains in the core database schema:

- [ ] Payments and subscriptions.
- [ ] Organizations, teams, classrooms, or multi-tenancy.
- [ ] Course, lesson, quiz, or learning-progress models.
- [ ] Marketplace models.
- [ ] AI chat, embeddings, or vector databases.
- [ ] Public API tokens and OAuth provider behavior.
- [ ] Blog or CMS content.
- [ ] Event warehouse and product analytics tables.
- [ ] Complex feature-flag infrastructure.
- [ ] Soft deletion on every model.
- [ ] Search engine integration.

These are installed as product modules only when a product needs them.

### 1.3 Non-negotiable engineering rules

- [ ] Keep one Rails application, one primary PostgreSQL database, and one repository.
- [ ] Do not create a separate Rails API and SvelteKit application by default.
- [ ] Do not add SSR for Inertia unless a real public SEO requirement appears.
- [ ] Do not allow Turbo and Inertia to own navigation inside the same layout.
- [ ] Keep authorization in Rails; hiding a button in Svelte is not authorization.
- [ ] Keep controllers thin and place multi-step business operations in command/service objects.
- [ ] Use database constraints for invariants that can be enforced by PostgreSQL.
- [ ] Avoid generic abstractions before two real product features need them.
- [ ] Never commit credentials, production personal data, or real payment secrets.
- [ ] Every completed phase must pass tests, linting, security checks, and a production asset build.

---

## 2. Target repository structure

```text
rails_product_starter/
├── app/
│   ├── controllers/
│   │   ├── admin/
│   │   ├── app/
│   │   ├── concerns/
│   │   └── settings/
│   ├── frontend/
│   │   ├── components/
│   │   ├── entrypoints/
│   │   ├── layouts/
│   │   ├── pages/
│   │   │   ├── admin_app/
│   │   │   └── app/
│   │   ├── stores/
│   │   ├── styles/
│   │   └── types/
│   ├── jobs/
│   ├── mailers/
│   ├── models/
│   ├── policies/
│   ├── queries/
│   ├── services/
│   └── views/
├── config/
│   ├── locales/
│   └── initializers/
├── db/
│   ├── migrate/
│   └── seeds/
├── docs/
│   ├── architecture/
│   ├── decisions/
│   ├── runbooks/
│   └── product-modules/
├── e2e/
├── spec/
├── scripts/
├── .env.example
├── mise.toml
├── Procfile.dev
├── docker-compose.yml
├── package.json
├── pnpm-lock.yaml
└── vite.config.ts
```

### Responsibility boundaries

| Area | Owner | Purpose |
|---|---|---|
| `/`, marketing, auth pages | ERB + Hotwire | Server-rendered, accessible, low-JavaScript pages |
| `/app/*` | Inertia + Svelte | Authenticated product application shell |
| `/admin/*` | ERB + Hotwire | Generic administration and operational screens |
| Domain behavior | Rails models/services | Source of truth and business rules |
| Frontend state | Svelte components/stores | Temporary presentation state only |
| Realtime server events | Action Cable/Solid Cable | Notifications and background job status |
| CPU-heavy browser behavior | Web Workers | Product module responsibility, not starter core |

---

# Roadmap at a glance

- [ ] Phase 0 — Prepare toolchain and repository.
- [ ] Phase 1 — Generate the Rails application.
- [ ] Phase 2 — Install Ruby and frontend dependencies.
- [ ] Phase 3 — Configure Vite, Svelte, Hotwire, Inertia, and Tailwind.
- [ ] Phase 4 — Establish tests, linting, formatting, and local development commands.
- [ ] Phase 5 — Generate and complete authentication.
- [ ] Phase 6 — Add profiles, roles, policies, and account settings.
- [ ] Phase 7 — Add internationalization and locale persistence.
- [ ] Phase 8 — Build public, authentication, member, and admin application shells.
- [ ] Phase 9 — Add generic admin user management.
- [ ] Phase 10 — Add notifications, uploads, jobs, and mail delivery.
- [ ] Phase 11 — Add auditing, security controls, errors, and observability.
- [ ] Phase 12 — Add CI, Docker, production build verification, and deployment documentation.
- [ ] Phase 13 — Convert the project into a reusable repository template.
- [ ] Phase 14 — Run the final boilerplate acceptance test.

---

# Phase 0 — Toolchain and repository

## Task 0.1: Install runtimes

- [ ] Install `mise` using its official installation method.
- [ ] Install supported runtimes globally so they are available to the Rails generator:

```bash
mise use --global ruby@3.4 node@24 pnpm@10
```

- [ ] Verify:

```bash
ruby --version
node --version
pnpm --version
```

- [ ] Install Rails 8.1.3:

```bash
gem install rails -v 8.1.3
rails _8.1.3_ --version
```

**Expected:** all commands exit successfully and Rails reports `8.1.3`.

## Task 0.2: Prepare a parent workspace

```bash
mkdir -p ~/workspaces
cd ~/workspaces
```

Do not create the `rails_product_starter` directory manually. The Rails generator creates it in Phase 1.

---

# Phase 1 — Generate Rails

## Task 1.1: Generate the full-stack application

From the parent directory, run:

```bash
rails _8.1.3_ new rails_product_starter \
  --database=postgresql \
  --skip-javascript \
  --skip-hotwire \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-jbuilder \
  --skip-test \
  --skip-system-test
```

### Why these components are skipped

| Flag | Reason |
|---|---|
| `--skip-javascript` | Vite becomes the only JavaScript/TypeScript build pipeline. |
| `--skip-hotwire` | Turbo and Stimulus will be installed through Vite, not Importmap. |
| `--skip-action-mailbox` | Receiving inbound email is not a universal product requirement. |
| `--skip-action-text` | A generic product starter should not force Trix or a rich-text storage model. |
| `--skip-jbuilder` | The starter is not a separate JSON API; small JSON responses can use `render json:`. |
| `--skip-test` | RSpec will replace Minitest immediately. |
| `--skip-system-test` | Playwright will be the primary browser E2E framework. |

### What remains enabled

- [ ] Active Record and PostgreSQL.
- [ ] Action Controller and Action View.
- [ ] Active Job and Solid Queue.
- [ ] Active Storage.
- [ ] Action Mailer.
- [ ] Action Cable and Solid Cable.
- [ ] Solid Cache.
- [ ] Propshaft.
- [ ] Dockerfile and entrypoint.
- [ ] Kamal and Thruster unless deployment is deliberately changed later.
- [ ] Bootsnap.
- [ ] RuboCop, Brakeman, dependency auditing, and generated CI foundations.
- [ ] Rails health endpoint.

## Task 1.2: Verify a clean Rails boot

```bash
cd rails_product_starter
mise use ruby@3.4 node@24 pnpm@10
bin/rails about
bin/rails db:create
bin/rails db:migrate
bin/rails runner 'puts Rails.application.class.module_parent_name'
```

**Expected:** database creation succeeds and the runner prints `RailsProductStarter`.

- [ ] Commit runtime pins first, then the generated application:

```bash
git add mise.toml
git commit -m "chore: pin starter runtimes"

git add .
git commit -m "chore: generate Rails product starter"
```

---

# Phase 2 — Dependencies

## Task 2.1: Add Ruby dependencies

Add the following groups to the Gemfile using Bundler commands:

```bash
bundle add vite_rails
bundle add inertia_rails
bundle add pundit
bundle add rack-attack
bundle add pagy

bundle add rspec-rails --group development,test
bundle add factory_bot_rails --group development,test
bundle add faker --group development,test
```

Do not add Devise. Use the Rails authentication generator so the starter owns its authentication code.

Do not add Redis or Sidekiq at this stage. Keep Solid Queue, Solid Cache, and Solid Cable until metrics demonstrate a need to replace them.

- [ ] Run:

```bash
bundle install
bundle exec ruby -e 'require "pundit"; require "pagy"; puts "ruby dependencies ok"'
```

## Task 2.2: Initialize pnpm and Vite Ruby

- [ ] Tell Vite Ruby to use pnpm for installation:

```bash
export VITE_RUBY_PACKAGE_MANAGER=pnpm
bundle exec vite install
```

- [ ] If the installer produced an npm lockfile, remove it and reinstall with pnpm:

```bash
rm -f package-lock.json yarn.lock
pnpm install
```

- [ ] Set the package manager in `package.json` to the exact installed pnpm version:

```bash
pnpm --version
```

Example field:

```json
{
  "private": true,
  "packageManager": "pnpm@10.15.0"
}
```

Use the actual output from `pnpm --version`, not the example version above.

## Task 2.3: Install frontend dependencies

```bash
pnpm add svelte @inertiajs/svelte @hotwired/turbo-rails @hotwired/stimulus
pnpm add -D @sveltejs/vite-plugin-svelte typescript svelte-check
pnpm add -D tailwindcss @tailwindcss/vite
pnpm add -D vitest jsdom @testing-library/svelte @testing-library/jest-dom
pnpm add -D eslint @eslint/js eslint-plugin-svelte prettier prettier-plugin-svelte typescript-eslint
pnpm add -D @playwright/test
```

- [ ] Install Playwright's Chromium browser for local and CI smoke tests:

```bash
pnpm exec playwright install chromium
```

- [ ] Commit dependency manifests:

```bash
git add Gemfile Gemfile.lock package.json pnpm-lock.yaml config/vite.json vite.config.* bin/vite
git commit -m "build: add Rails and frontend dependencies"
```

---

# Phase 3 — Frontend architecture

## Task 3.1: Configure Vite plugins

Replace `vite.config.ts` with:

```ts
import { fileURLToPath, URL } from "node:url"
import { defineConfig } from "vite"
import RubyPlugin from "vite-plugin-ruby"
import { svelte } from "@sveltejs/vite-plugin-svelte"
import tailwindcss from "@tailwindcss/vite"

export default defineConfig({
  plugins: [RubyPlugin(), tailwindcss(), svelte()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
    },
  },
})
```

- [ ] Ensure `config/vite.json` uses:

```json
{
  "all": {
    "sourceCodeDir": "app/frontend",
    "watchAdditionalPaths": ["app/views/**/*.erb", "app/helpers/**/*.rb"]
  }
}
```

Preserve any other installer-generated settings that are still required.

## Task 3.2: Create the frontend directory structure

```bash
mkdir -p app/frontend/{components,controllers,entrypoints,layouts,pages/app,pages/admin_app,stores,styles,types}
```

Create `app/frontend/styles/application.css`:

```css
@import "tailwindcss";

@source "../../views/**/*.erb";
@source "../**/*.{js,ts,svelte}";

@theme {
  --font-sans: Inter, ui-sans-serif, system-ui, sans-serif;
}

@layer base {
  html {
    @apply bg-white text-slate-950 antialiased;
  }

  body {
    @apply min-h-screen;
  }

  button,
  a,
  input,
  select,
  textarea {
    @apply focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-600;
  }
}
```

## Task 3.3: Configure Hotwire entrypoint

Create `app/frontend/controllers/application.ts`:

```ts
import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false

export { application }
```

Create `app/frontend/controllers/index.ts`:

```ts
import { application } from "./application"

const controllerModules = import.meta.glob("./**/*_controller.ts", { eager: true })

for (const path in controllerModules) {
  const module = controllerModules[path] as { default?: unknown }
  const identifier = path
    .replace(/^\.\//, "")
    .replace(/_controller\.ts$/, "")
    .replaceAll("_", "-")
    .replaceAll("/", "--")

  if (module.default) {
    application.register(identifier, module.default as never)
  }
}
```

Create `app/frontend/entrypoints/application.ts`:

```ts
import "@hotwired/turbo-rails"
import "@/controllers"
import "@/styles/application.css"
```

## Task 3.4: Install Inertia with Svelte

Run the Inertia generator and select Svelte, TypeScript, no SSR, and do not allow it to replace the established Vite configuration without reviewing the diff:

```bash
bin/rails generate inertia:install
```

When prompted:

```text
Framework: Svelte
TypeScript: Yes
SSR: No
```

After generation:

- [ ] Keep one Vite configuration.
- [ ] Keep one global CSS entrypoint.
- [ ] Remove duplicate sample pages that are not used.
- [ ] Preserve the generated Inertia page resolver.

Create or normalize `app/frontend/entrypoints/inertia.ts`:

```ts
import { createInertiaApp } from "@inertiajs/svelte"
import { mount } from "svelte"
import "@/styles/application.css"

createInertiaApp({
  resolve: async (name) => {
    const pages = import.meta.glob("../pages/**/*.svelte")
    const importer = pages[`../pages/${name}.svelte`]

    if (!importer) {
      throw new Error(`Unknown Inertia page: ${name}`)
    }

    const page = (await importer()) as { default: unknown }
    return page.default
  },
  setup({ el, App, props }) {
    mount(App, { target: el, props })
  },
  progress: {
    color: "#2563eb",
    showSpinner: false,
  },
})
```

## Task 3.5: Create layouts

Create `app/views/layouts/application.html.erb` for ERB + Hotwire:

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>">
  <head>
    <title><%= content_for(:title) || ENV.fetch("APP_NAME", "Starter App") %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= vite_client_tag %>
    <%= vite_typescript_tag "application.ts" %>
  </head>
  <body>
    <%= render "shared/flash" %>
    <%= yield %>
  </body>
</html>
```

Create `app/views/layouts/inertia.html.erb`:

```erb
<!DOCTYPE html>
<html lang="<%= I18n.locale %>">
  <head>
    <title><%= content_for(:title) || ENV.fetch("APP_NAME", "Starter App") %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= inertia_ssr_head %>
    <%= vite_client_tag %>
    <%= vite_typescript_tag "inertia.ts" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

Create `app/views/layouts/admin.html.erb` using the same Vite `application.ts` entrypoint and an admin navigation partial.

## Task 3.6: Create the development process file

Create `Procfile.dev`:

```procfile
web: bin/rails server -p 3000
vite: bin/vite dev
jobs: bin/jobs start
```

Create or update `bin/dev` to use Foreman or Overmind. Keep the command repository-local and documented.

- [ ] Verify:

```bash
bin/dev
```

- [ ] Open `http://localhost:3000` and confirm no missing Vite entrypoint errors.
- [ ] Run a production build:

```bash
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

- [ ] Commit:

```bash
git add app/frontend app/views/layouts config/vite.json vite.config.ts Procfile.dev bin/dev
git commit -m "feat: configure Vite Hotwire Inertia and Svelte"
```

---

# Phase 4 — Testing and quality tooling

## Task 4.1: Configure RSpec

```bash
bin/rails generate rspec:install
```

Add to `spec/rails_helper.rb`:

```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
end
```

Create `spec/support/request_helpers.rb` and load `spec/support/**/*.rb` from `rails_helper.rb`.

Create a smoke spec at `spec/requests/health_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "Health check", type: :request do
  it "returns success" do
    get "/up"

    expect(response).to have_http_status(:success)
  end
end
```

Run:

```bash
bundle exec rspec spec/requests/health_spec.rb
```

## Task 4.2: Configure Vitest

Create `vitest.config.ts`:

```ts
import { fileURLToPath, URL } from "node:url"
import { defineConfig } from "vitest/config"
import { svelte } from "@sveltejs/vite-plugin-svelte"

export default defineConfig({
  plugins: [svelte()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["./app/frontend/test/setup.ts"],
    include: ["app/frontend/**/*.{test,spec}.{ts,js}"],
  },
})
```

Create `app/frontend/test/setup.ts`:

```ts
import "@testing-library/jest-dom/vitest"
```

Create `app/frontend/components/StatusBadge.svelte`:

```svelte
<script lang="ts">
  let { label, active = false }: { label: string; active?: boolean } = $props()
</script>

<span data-active={active}>{label}</span>
```

Create `app/frontend/components/StatusBadge.test.ts`:

```ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import StatusBadge from "./StatusBadge.svelte"

describe("StatusBadge", () => {
  it("renders its label and active state", () => {
    render(StatusBadge, { props: { label: "Verified", active: true } })

    expect(screen.getByText("Verified")).toHaveAttribute("data-active", "true")
  })
})
```

Create `eslint.config.js`:

```js
import js from "@eslint/js"
import svelte from "eslint-plugin-svelte"
import tseslint from "typescript-eslint"

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...svelte.configs["flat/recommended"],
  {
    files: ["**/*.svelte"],
    languageOptions: {
      parserOptions: {
        parser: tseslint.parser,
      },
    },
  },
  {
    ignores: ["public/vite", "node_modules", "tmp", "vendor"],
  },
)
```

Create `.prettierrc.json`:

```json
{
  "plugins": ["prettier-plugin-svelte"],
  "semi": false,
  "singleQuote": false,
  "trailingComma": "all",
  "overrides": [
    {
      "files": "*.svelte",
      "options": { "parser": "svelte" }
    }
  ]
}
```

Add scripts to `package.json`:

```json
{
  "scripts": {
    "check": "svelte-check --tsconfig ./tsconfig.json",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:e2e": "playwright test",
    "lint": "eslint \"app/frontend/**/*.{ts,svelte}\" vite.config.ts vitest.config.ts playwright.config.ts",
    "format:check": "prettier --check app/frontend vite.config.ts vitest.config.ts playwright.config.ts"
  }
}
```

## Task 4.3: Configure Playwright

Create `playwright.config.ts`:

```ts
import { defineConfig, devices } from "@playwright/test"

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  reporter: process.env.CI ? "github" : "html",
  use: {
    baseURL: "http://127.0.0.1:3000",
    trace: "on-first-retry",
    screenshot: "only-on-failure",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  webServer: {
    command: "bin/rails db:test:prepare && bin/rails server -e test -p 3000",
    url: "http://127.0.0.1:3000/up",
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
})
```

Create `e2e/health.spec.ts`:

```ts
import { expect, test } from "@playwright/test"

test("application responds", async ({ page }) => {
  await page.goto("/up")
  await expect(page.locator("body")).toHaveAttribute("style", /green/)
})
```

## Task 4.4: Add the single local quality command

Create `bin/quality`:

```bash
#!/usr/bin/env bash
set -euo pipefail

bundle exec rubocop
bundle exec brakeman -q
bundle exec bundler-audit check --update
bundle exec rspec
pnpm run check
pnpm run lint
pnpm run format:check
pnpm run test
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
```

Make it executable:

```bash
chmod +x bin/quality
bin/quality
```

## Task 4.5: Add optional local git hooks

Add Lefthook as an optional developer convenience, not as the source of truth for quality. CI and `bin/quality` remain authoritative.

Create a documented `lefthook.yml` with:

- [ ] `pre-commit` runs fast checks only, such as RuboCop on Ruby changes and frontend lint/format checks on frontend changes.
- [ ] `pre-push` runs `bin/quality` by default.
- [ ] Hooks can be skipped only for documented emergencies; skipped checks must be run before opening or merging a pull request.
- [ ] The README explains how to install, enable, disable, and troubleshoot hooks.

Do not use Husky as the default. This is a Rails-first repository with Ruby and frontend checks; Lefthook keeps hooks language-neutral.

- [ ] Commit:

```bash
git add spec e2e app/frontend/test vitest.config.ts playwright.config.ts package.json bin/quality lefthook.yml
git commit -m "test: add Rails frontend and browser quality gates"
```

---

# Phase 5 — Authentication

## Task 5.1: Generate Rails authentication

```bash
bin/rails generate authentication
bin/rails db:migrate
```

The generated authentication must remain session-cookie based. Do not replace it with JWT for the web application.

- [ ] Review generated models, controllers, routes, views, and mailer.
- [ ] Restart the Rails process after the generator adds `bcrypt`.
- [ ] Write request specs for login, logout, invalid credentials, password reset request, and password reset completion.

## Task 5.2: Normalize the User model

Create a migration adding reusable account fields:

```bash
bin/rails generate migration AddProfileFieldsToUsers \
  name:string \
  role:integer \
  preferred_locale:string \
  time_zone:string \
  email_verified_at:datetime \
  suspended_at:datetime \
  deactivated_at:datetime
```

Edit the migration so fields have these rules:

```ruby
add_column :users, :name, :string, null: false, default: ""
add_column :users, :role, :integer, null: false, default: 0
add_column :users, :preferred_locale, :string, null: false, default: "id"
add_column :users, :time_zone, :string, null: false, default: "Asia/Jakarta"
add_column :users, :email_verified_at, :datetime
add_column :users, :suspended_at, :datetime
add_column :users, :deactivated_at, :datetime
add_index :users, :role
add_index :users, :email_verified_at
add_index :users, :suspended_at
add_index :users, :deactivated_at
```

Email uniqueness must be enforced by PostgreSQL, not only by Rails validations:

- [ ] Keep the generated unique index on `email_address` if emails are always normalized before write.
- [ ] Prefer a case-insensitive unique index such as `index_users_on_lower_email_address` when the database can receive mixed-case values.
- [ ] Add a model/request spec proving duplicate emails with different casing cannot create two accounts.

In `app/models/user.rb`:

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { member: 0, staff: 1, admin: 2 }, default: :member, validate: true

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :name, presence: true, length: { maximum: 100 }
  validates :preferred_locale, inclusion: { in: %w[id en] }
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  def email_verified?
    email_verified_at.present?
  end

  def suspended?
    suspended_at.present?
  end

  def deactivated?
    deactivated_at.present?
  end
end
```

Adapt association names to the exact output of the Rails authentication generator. Do not duplicate `has_secure_password` if already generated.

## Task 5.3: Add registration

Create:

```text
app/controllers/registrations_controller.rb
app/views/registrations/new.html.erb
spec/requests/registrations_spec.rb
```

Routes:

```ruby
resource :registration, only: %i[new create]
```

Requirements:

- [ ] Accept `name`, `email_address`, `password`, and `password_confirmation`.
- [ ] Apply controller rate limiting to registration attempts.
- [ ] Never accept `role`, `email_verified_at`, or `suspended_at` from public parameters.
- [ ] Create a session after valid registration.
- [ ] Send verification email asynchronously.
- [ ] Render validation errors without losing entered non-password fields.

## Task 5.4: Add email verification

Create:

```text
app/controllers/email_verifications_controller.rb
app/services/accounts/email_verification_token.rb
app/mailers/email_verification_mailer.rb
app/views/email_verification_mailer/verification.html.erb
spec/requests/email_verifications_spec.rb
```

Use a purpose-scoped signed ID with an expiration rather than storing raw verification tokens.

Create `app/services/accounts/email_verification_token.rb`:

```ruby
module Accounts
  class EmailVerificationToken
    PURPOSE = :email_verification
    EXPIRES_IN = 24.hours

    def self.generate(user)
      user.signed_id(purpose: PURPOSE, expires_in: EXPIRES_IN)
    end

    def self.find(token)
      User.find_signed(token, purpose: PURPOSE)
    end
  end
end
```

Routes:

```ruby
resource :email_verification, only: :create
get "/email_verification/:token", to: "email_verifications#show", as: :verify_email
```

Rules:

- [ ] Token expires after 24 hours.
- [ ] Token is purpose-scoped to email verification.
- [ ] Verification sets `email_verified_at` once and is idempotent.
- [ ] Resend endpoint is rate-limited.
- [ ] Changing email clears verification and sends a new message.

## Task 5.5: Enforce authentication states

Create controller concerns:

```text
app/controllers/concerns/authentication.rb
app/controllers/concerns/verified_user_required.rb
app/controllers/concerns/not_suspended.rb
```

Rules:

- [ ] Public marketing and authentication pages allow guests.
- [ ] `/app/*` requires a logged-in, verified, non-suspended user.
- [ ] `/admin/*` requires `staff` or `admin` according to policy.
- [ ] A suspended account can log out and access support information but cannot use the product.

## Task 5.6: Authentication acceptance tests

- [ ] Guest can register.
- [ ] Registered user receives a verification message in the test queue.
- [ ] Unverified user is redirected away from `/app`.
- [ ] Verification link activates the account.
- [ ] Verified user can open `/app`.
- [ ] User can reset a forgotten password.
- [ ] Logging out invalidates the current session.
- [ ] Reused expired tokens fail safely.

- [ ] Run `bin/quality` and commit:

```bash
git add app config db spec
git commit -m "feat: add complete account authentication"
```

---

# Phase 6 — Accounts, roles, and authorization

## Task 6.1: Install Pundit

```bash
bin/rails generate pundit:install
```

In `ApplicationController`:

```ruby
include Pundit::Authorization

rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
```

Create `ApplicationPolicy` defaults that deny actions unless explicitly allowed.

## Task 6.2: Add account settings

Create controllers and screens:

```text
/settings/profile
/settings/security
/settings/preferences
/settings/sessions
```

Required behavior:

- [ ] Profile: update name and avatar.
- [ ] Security: change password after confirming the current password.
- [ ] Preferences: update locale and time zone.
- [ ] Sessions: list active sessions and revoke another session.
- [ ] Email: change email only after confirming password; clear verification.
- [ ] Account deletion: require password and a typed confirmation phrase; perform a documented deletion policy.

Implement conservative self-service deactivation in the core starter. It sets `deactivated_at`, revokes every session, sends a security email, and blocks future sign-in. Do not physically delete the account until a product defines retention and legal requirements.

## Task 6.3: Add authorization helpers to Inertia shared props

Create an Inertia base controller:

```ruby
class App::BaseController < ApplicationController
  layout "inertia"

  before_action :require_authentication
  before_action :require_verified_user
  before_action :require_not_suspended

  inertia_share do
    {
      auth: {
        user: Current.user && {
          id: Current.user.id,
          name: Current.user.name,
          email: Current.user.email_address,
          role: Current.user.role,
          avatar_url: Current.user.avatar.attached? ? url_for(Current.user.avatar) : nil
        }
      },
      locale: I18n.locale.to_s,
      permissions: {
        access_admin: Current.user && UserPolicy.new(Current.user, Current.user).access_admin?
      },
      flash: {
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
end
```

Keep shared props small. Do not share full database records.

## Task 6.4: Policy test matrix

Create policy specs covering:

| Actor | Member area | Staff admin pages | Manage staff | Manage admins |
|---|---:|---:|---:|---:|
| Guest | No | No | No | No |
| Member | Yes | No | No | No |
| Staff | Yes | Yes | No | No |
| Admin | Yes | Yes | Yes | Yes, except self-demotion safeguards |

- [ ] Run `bin/quality` and commit.

---

# Phase 7 — Internationalization

## Task 7.1: Configure Rails I18n

In `config/application.rb`:

```ruby
config.i18n.available_locales = %i[id en]
config.i18n.default_locale = :id
config.i18n.fallbacks = { en: :id, id: :en }
config.time_zone = "Asia/Jakarta"
config.active_record.default_timezone = :utc
```

Create:

```text
config/locales/id.yml
config/locales/en.yml
```

Store application UI copy in locale files. Do not store product content such as lessons or catalog records in YAML.

## Task 7.2: Locale selection and persistence

Implement locale resolution in this order:

```text
1. Explicit locale parameter for a user action.
2. Authenticated user's preferred_locale.
3. Locale cookie.
4. Rails default locale.
```

Rules:

- [ ] Only `id` and `en` are accepted.
- [ ] Locale parameter is not persisted without an explicit language change action.
- [ ] Authenticated selection updates `users.preferred_locale`.
- [ ] Guest selection uses a signed cookie.
- [ ] `I18n.with_locale` or `around_action` prevents locale leakage between requests.

## Task 7.3: Locale-aware frontend

- [ ] Share current locale through Inertia.
- [ ] Keep frontend navigation labels in Rails-provided props or a small typed locale dictionary.
- [ ] Format dates and numbers with `Intl.DateTimeFormat` and `Intl.NumberFormat` using the active locale.
- [ ] Do not duplicate domain records solely to change the interface language.

## Task 7.4: Locale tests

- [ ] Guest defaults to Indonesian.
- [ ] Guest can switch to English and retain it through the cookie.
- [ ] Authenticated user preference overrides the guest cookie.
- [ ] Unsupported locale values fall back safely.
- [ ] Mailers render using the recipient's preferred locale.

- [ ] Run `bin/quality` and commit.

---

# Phase 8 — Application shells and dashboards

## Task 8.1: Public site shell

Create generic public pages:

```text
/
/about
/privacy
/terms
/contact
```

The home page must contain only reusable starter copy:

- Application name from `APP_NAME`.
- One headline.
- One supporting paragraph.
- Login and registration calls to action.
- No LMS, marketplace, fintech, or SaaS-specific wording.

Create reusable ERB partials:

```text
app/views/shared/_public_nav.html.erb
app/views/shared/_footer.html.erb
app/views/shared/_flash.html.erb
app/views/shared/_pagination.html.erb
app/views/shared/_empty_state.html.erb
app/views/shared/_form_errors.html.erb
```

## Task 8.2: Authentication shell

Create an authentication layout or reusable card with:

- [ ] Product name.
- [ ] Accessible labels.
- [ ] Password manager-friendly fields.
- [ ] Error summary.
- [ ] Link between login, registration, and password reset.
- [ ] No social login buttons until a provider is actually configured.

## Task 8.3: Member Inertia shell

Create `app/frontend/layouts/AppLayout.svelte` with:

- [ ] Desktop sidebar.
- [ ] Mobile navigation.
- [ ] Current-user menu.
- [ ] Locale switcher.
- [ ] Notification indicator.
- [ ] Flash toast region.
- [ ] Main content landmark.
- [ ] Logout action using an Inertia request.

Create `app/frontend/pages/app/Dashboard.svelte` with product-neutral cards:

- Welcome message.
- Account status.
- Recent notifications.
- A placeholder extension region documented for product metrics.

Do not add fake revenue, course progress, sales, or analytics metrics.

## Task 8.4: Admin ERB shell

Create `Admin::BaseController`:

```ruby
class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :require_authentication
  before_action :require_verified_user
  before_action :require_not_suspended
  before_action :authorize_admin_access
end
```

Create admin navigation:

```text
Dashboard
Users
Notifications
Audit events
Jobs/operations documentation link
Back to app
```

Create a product-neutral dashboard containing:

- User counts by role.
- Verified and unverified counts.
- Suspended account count.
- Recent audit events.
- Recent failed mail or job warning when available.

## Task 8.5: Routes

Use this baseline structure:

```ruby
Rails.application.routes.draw do
  root "home#show"

  resource :session
  resource :registration, only: %i[new create]
  resources :passwords, param: :token
  resource :email_verification, only: :create
  get "/email_verification/:token", to: "email_verifications#show", as: :verify_email

  get "/about", to: "pages#about"
  get "/privacy", to: "pages#privacy"
  get "/terms", to: "pages#terms"
  get "/contact", to: "pages#contact"

  namespace :settings do
    resource :profile, only: %i[show update]
    resource :security, only: %i[show update]
    resource :preferences, only: %i[show update]
    resources :sessions, only: %i[index destroy]
    resource :account, only: :destroy
  end

  namespace :app do
    resource :dashboard, only: :show
    resources :notifications, only: %i[index update]
  end

  namespace :admin do
    root "dashboard#show"
    resources :users, only: %i[index show edit update]
    resources :notifications, only: %i[index new create]
    resources :audit_events, only: %i[index show]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
```

- [ ] Add route specs or request specs for access control.
- [ ] Run `bin/rails routes` and confirm there are no duplicate route helpers.
- [ ] Run `bin/quality` and commit.

---

# Phase 9 — Generic admin user management

## Task 9.1: User index

Implement:

- [ ] Search by name or email.
- [ ] Filter by role.
- [ ] Filter by verified/unverified.
- [ ] Filter by active/suspended.
- [ ] Paginate with Pagy.
- [ ] Sort by newest and oldest.
- [ ] Avoid N+1 queries for avatar/session information.

Create a query object:

```text
app/queries/admin/users_query.rb
spec/queries/admin/users_query_spec.rb
```

The query object owns filtering and sorting. The controller owns authorization and response selection.

## Task 9.2: User detail

Show:

- Identity fields.
- Role.
- Verification state.
- Suspension state.
- Created timestamp.
- Active sessions count.
- Recent audit events related to the user.

Do not expose password digests, reset tokens, session tokens, IP history to ordinary staff, or private storage metadata.

## Task 9.3: Safe administrative actions

Implement service objects:

```text
Admin::Users::ChangeRole
Admin::Users::Suspend
Admin::Users::Unsuspend
Admin::Users::RevokeSessions
```

Rules:

- [ ] Staff cannot promote users to admin.
- [ ] Staff cannot modify admins.
- [ ] Admin cannot suspend their own active account.
- [ ] Last remaining admin cannot be demoted.
- [ ] Role and suspension changes create audit events.
- [ ] Suspending a user revokes all sessions.
- [ ] Every service runs in a database transaction.

## Task 9.4: Admin browser test

Create a Playwright flow:

- Log in as admin.
- Open Users.
- Search for the seeded member.
- Open the member detail.
- Suspend the member.
- Confirm an audit event appears.
- Unsuspend the member.

- [ ] Run `bin/quality` and commit.

---

# Phase 10 — Notifications, uploads, jobs, and mail

## Task 10.1: Database notifications

Generate:

```bash
bin/rails generate model Notification \
  user:references \
  kind:string \
  title:string \
  body:text \
  action_url:string \
  read_at:datetime \
  metadata:jsonb
```

Edit migration constraints:

- `user_id`, `kind`, `title`, and `body` are not null.
- `metadata` defaults to `{}` and is not null.
- Index `(user_id, read_at, created_at)`.

Model behavior:

```ruby
scope :unread, -> { where(read_at: nil) }
scope :recent_first, -> { order(created_at: :desc) }
```

Service object:

```text
Notifications::Create.call(user:, kind:, title:, body:, action_url: nil, metadata: {})
```

Do not allow arbitrary notification kinds from public parameters.

## Task 10.2: Notification UI

- [ ] Member notification list.
- [ ] Mark one as read.
- [ ] Mark all as read.
- [ ] Shared unread count.
- [ ] Empty state.
- [ ] Safe internal links only; validate or normalize `action_url`.

## Task 10.3: Admin announcements

Allow admins to create a generic announcement for:

- All active users.
- Members only.
- Staff only.

Use a background job to fan out notifications. Record who initiated the announcement in an audit event.

## Task 10.4: Active Storage avatar

```bash
bin/rails active_storage:install
bin/rails db:migrate
```

In `User`:

```ruby
has_one_attached :avatar
```

Validation rules implemented in model/service code:

- Image only.
- Maximum 5 MB.
- Supported content types: JPEG, PNG, and WebP.
- Strip or reprocess unsafe metadata when the image-processing stack is added.
- Use a generated variant for navigation avatars.

Keep development storage local. Document S3-compatible production configuration using environment variables without committing provider credentials.

## Task 10.5: Mail delivery

Create a generic `AccountMailer` for:

- Email verification.
- Password reset if not already generated separately.
- Security notice after password/email change.

Requirements:

- [ ] Use `deliver_later`.
- [ ] Set default URL options from `APP_HOST` and `APP_PROTOCOL`.
- [ ] Localize per recipient.
- [ ] Provide text and HTML versions.
- [ ] Do not include sensitive tokens in logs.

## Task 10.6: Job queues

Document and configure these queue names:

```text
default
mailers
notifications
low_priority
```

Do not add product-specific queues such as payments, compilations, or media processing to the generic core.

- [ ] Test job enqueueing and idempotency where relevant.
- [ ] Run `bin/quality` and commit.

---

# Phase 11 — Auditing, security, errors, and observability

## Task 11.1: Audit events

Generate:

```bash
bin/rails generate model AuditEvent \
  actor:references \
  target_type:string \
  target_id:bigint \
  action:string \
  metadata:jsonb \
  ip_address:string \
  user_agent:string
```

Modify the actor reference to allow null for system-generated actions and use a foreign key to users.

Constraints and indexes:

- `action` not null.
- `metadata` defaults to `{}` and is not null.
- Index `(target_type, target_id, created_at)`.
- Index `(actor_id, created_at)`.
- Index `(action, created_at)`.

Create:

```text
Auditing::Record.call(action:, actor: Current.user, target: nil, metadata: {}, request: nil)
```

Rules:

- [ ] Never store passwords, tokens, full payment payloads, or file contents.
- [ ] Store only the minimum IP/user-agent information required by the product's privacy policy.
- [ ] Audit role changes, suspension, session revocation, admin announcements, and account email changes.

## Task 11.2: Rack::Attack

Create `config/initializers/rack_attack.rb` with these initial limits:

```ruby
class Rack::Attack
  safelist("health check") { |request| request.path == "/up" }

  throttle("login/ip", limit: 10, period: 1.minute) do |request|
    request.ip if request.post? && request.path == "/session"
  end

  throttle("registration/ip", limit: 5, period: 10.minutes) do |request|
    request.ip if request.post? && request.path == "/registration"
  end

  throttle("password-reset/ip", limit: 5, period: 15.minutes) do |request|
    request.ip if request.post? && request.path == "/passwords"
  end

  throttle("verification-resend/ip", limit: 5, period: 15.minutes) do |request|
    request.ip if request.post? && request.path == "/email_verification"
  end

  self.throttled_responder = lambda do |request|
    retry_after = request.env.fetch("rack.attack.match_data", {}).fetch(:period, 60)
    [
      429,
      { "Content-Type" => "text/plain; charset=utf-8", "Retry-After" => retry_after.to_s },
      ["Too many requests. Please try again later."],
    ]
  end
end
```

Add normalized-email throttles inside the authentication controllers when the email parameter is present. Return a localized `429` page for browser requests. Exclude health checks and static assets.

Do not use rate limiting as the only brute-force protection; preserve strong password hashing and generic authentication error messages.

## Task 11.3: Content Security Policy

Review `config/initializers/content_security_policy.rb` and configure:

- `default-src 'self'`.
- Vite development server allowed only in development.
- Images from self, data URLs where needed, and configured object-storage host.
- No wildcard script sources.
- No `unsafe-eval` in production.
- Frame ancestors restricted to self or none according to product needs.

Run the policy in report-only mode during initial integration, fix violations, then enforce it before the template is marked complete.

## Task 11.4: Error handling

Create branded but product-neutral pages for:

```text
403
404
422
429
500
503
```

Behavior:

- [ ] Production pages reveal no stack traces or internal IDs.
- [ ] Inertia requests receive an Inertia-compatible error page.
- [ ] HTML requests receive ERB/static pages.
- [ ] Errors include a request ID users can send to support.
- [ ] Authorization failures return `403` rather than pretending every resource is missing unless concealment is deliberate.

## Task 11.5: Logging and error reporting interface

- [ ] Preserve Rails request IDs.
- [ ] Add user ID and role as tagged log context after authentication.
- [ ] Filter password, password confirmation, tokens, authorization headers, and sensitive metadata.
- [ ] Document how to connect Sentry, AppSignal, Skylight, or another service without making one provider mandatory.
- [ ] Use Sentry as the primary documented error-tracking example, including `SENTRY_DSN`, environment, release/version tagging, sampling, and PII filtering.
- [ ] Keep APM provider installation optional. Add Skylight or AppSignal only when a real product has production traffic and performance questions.
- [ ] Document external uptime monitoring against `/up`, including alert channel, expected status, and response-time threshold.
- [ ] Use `Rails.error.report` inside rescued background-job failures that need context.

## Task 11.6: Fail-fast production configuration

Create a production-only configuration validation that raises a clear boot error when required production values are missing or placeholder-like.

Validate:

- [ ] `APP_HOST`
- [ ] `APP_PROTOCOL`
- [ ] `MAILER_FROM`
- [ ] `DATABASE_URL` or equivalent production database configuration
- [ ] `SECRET_KEY_BASE` or Rails credentials availability
- [ ] S3-compatible storage variables only when production storage is configured to use S3

Rules:

- [ ] Development and test keep safe defaults.
- [ ] Production does not silently fall back to `localhost`, `.test`, or dummy credentials.
- [ ] The error message names missing keys without printing secret values.
- [ ] A request/config spec covers missing required values.

## Task 11.7: Security test cases

- [ ] Member cannot enter admin routes.
- [ ] Staff cannot alter admins.
- [ ] CSRF protection remains enabled.
- [ ] Open redirects are rejected.
- [ ] Uploaded non-image content is rejected as avatar.
- [ ] Rate limits return 429.
- [ ] Suspended user sessions are revoked.
- [ ] Secrets are filtered from logs.
- [ ] Audit metadata never stores passwords, raw tokens, authorization headers, or signed sensitive URLs.

- [ ] Run `bin/quality` and commit.

---

# Phase 12 — CI, Docker, and deployment readiness

## Task 12.1: Development PostgreSQL with Docker Compose

Create `docker-compose.yml`:

```yaml
services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: rails_product_starter_development
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 10

volumes:
  postgres_data:
```

Use a supported PostgreSQL major version approved by the hosting target. If the production platform does not yet support PostgreSQL 17, use the same supported major locally and in CI.

## Task 12.2: Environment contract

Create `.env.example`:

```dotenv
APP_NAME=Starter App
APP_HOST=localhost:3000
APP_PROTOCOL=http
DEFAULT_LOCALE=id
DEFAULT_TIME_ZONE=Asia/Jakarta

DATABASE_URL=postgres://postgres:postgres@localhost:5432/rails_product_starter_development

MAILER_FROM=no-reply@example.test
SMTP_ADDRESS=
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=
SMTP_DOMAIN=

S3_ENDPOINT=
S3_ACCESS_KEY_ID=
S3_SECRET_ACCESS_KEY=
S3_BUCKET=
S3_REGION=auto
```

Rules:

- [ ] Every required production variable is documented.
- [ ] Development defaults are safe and non-secret.
- [ ] No actual credential appears in `.env.example`.
- [ ] Rails credentials are reserved for stable application secrets; deploy-specific credentials may come from the platform environment.

## Task 12.3: GitHub Actions CI

Create `.github/workflows/ci.yml` with separate jobs or clear steps for:

1. Ruby lint and security.
2. RSpec with PostgreSQL service.
3. TypeScript, Svelte check, ESLint, Prettier, and Vitest.
4. Production asset compilation.
5. Playwright Chromium tests.

Use dependency caching for Bundler, pnpm, and Playwright browser binaries where supported.

Required commands:

```bash
bundle exec rubocop
bundle exec brakeman -q
bundle exec bundler-audit check --update
bundle exec rspec
pnpm run check
pnpm run lint
pnpm run format:check
pnpm run test
RAILS_ENV=production SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile
pnpm run test:e2e
```

The main branch must not accept a change when any required job fails.

Create `.github/dependabot.yml` for:

- [ ] Bundler.
- [ ] pnpm.
- [ ] GitHub Actions.
- [ ] Docker base images when Dependabot supports the generated Dockerfile shape.

Keep dependency update pull requests small and grouped by ecosystem. Security updates should not wait for the quarterly upgrade routine.

## Task 12.4: Production Docker verification

Review the generated Rails Dockerfile and ensure it:

- Installs Ruby dependencies.
- Installs Node and pnpm in the build stage.
- Installs frontend dependencies with a frozen lockfile.
- Builds Vite assets during image build.
- Excludes development/test dependencies from the runtime image.
- Runs as a non-root user.
- Uses `bin/docker-entrypoint` for database preparation behavior.
- Exposes only the Rails/Thruster HTTP port.

Build locally:

```bash
docker build -t rails-product-starter:local .
```

Create `bin/smoke_production` and run it against the local production image with production-like environment variables and a disposable database.

The smoke script must verify:

- [ ] The web process boots.
- [ ] `/up` returns success.
- [ ] Production assets are present and served.
- [ ] The job process can start with the configured queue adapter.
- [ ] Missing required production configuration fails clearly.

## Task 12.5: Deployment runbooks

Create:

```text
docs/runbooks/deploy-kamal.md
docs/runbooks/deploy-dokploy.md
docs/runbooks/database-backup-restore.md
docs/runbooks/email-deliverability.md
docs/runbooks/monitoring.md
docs/runbooks/rollback.md
docs/runbooks/rotate-secrets.md
```

Each deployment runbook must state:

- Required environment variables.
- Web and job process commands.
- Migration command.
- Health-check path.
- Storage configuration.
- Backup requirement.
- Rollback procedure.

`email-deliverability.md` must cover SPF, DKIM, DMARC, sender domain verification, sandbox/test mode, and provider-specific webhook notes without requiring a specific provider.

`monitoring.md` must cover Sentry-style error tracking, optional APM such as Skylight or AppSignal, uptime checks against `/up`, alert routing, and what data must not be sent to providers.

Do not configure two production platforms simultaneously in code. Keep Kamal's generated files as the default and document the changes required for Dokploy.

- [ ] Run `bin/quality`, build the Docker image, and commit.

---

# Phase 13 — Turn the project into a reusable template

## Task 13.1: Product-neutral configuration

Create `config/initializers/app_config.rb`:

```ruby
AppConfig = Data.define(:name, :host, :protocol, :default_locale, :default_time_zone).new(
  name: ENV.fetch("APP_NAME", "Starter App"),
  host: ENV.fetch("APP_HOST", "localhost:3000"),
  protocol: ENV.fetch("APP_PROTOCOL", "http"),
  default_locale: ENV.fetch("DEFAULT_LOCALE", "id"),
  default_time_zone: ENV.fetch("DEFAULT_TIME_ZONE", "Asia/Jakarta")
)
```

Use `AppConfig` consistently in layouts and mailer URL configuration. Do not scatter `ENV.fetch` throughout view templates.

## Task 13.2: Development seeds

Create deterministic seeds:

```text
admin@example.test / Password123!dev
staff@example.test / Password123!dev
member@example.test / Password123!dev
```

Rules:

- [ ] Seeds run only with known development/test values.
- [ ] Production seed execution never creates default-password accounts.
- [ ] Seeded users are verified.
- [ ] Seeds are idempotent using `find_or_initialize_by`.
- [ ] Passwords are documented as local-only and intentionally invalid for production policy.

## Task 13.3: Bootstrap script for a new product

Create `bin/bootstrap_product` that accepts explicit command-line values:

```bash
bin/bootstrap_product \
  --name "Example Product" \
  --module ExampleProduct \
  --database-prefix example_product \
  --host example.test
```

The script must:

- Validate all arguments before changing files.
- Refuse invalid Ruby module names.
- Refuse database prefixes outside lowercase snake case.
- Update `APP_NAME` examples and local database names.
- Update the Rails application module only if automated tests prove the replacement safe.
- Preserve Git history or offer a documented `--fresh-git` mode.
- Run `bundle install`, `pnpm install`, database setup, and `bin/quality`.
- Print a summary of changed files.

If safe Rails module renaming proves brittle, reduce the script scope: keep the internal `RailsProductStarter` module and change only branding, database, host, and repository metadata. Reliability is more important than aesthetic renaming.

## Task 13.4: Product-start questionnaire and module contract

Create `docs/product-modules/new-product-checklist.md` to answer before using the starter for a real product:

- [ ] What is the product's first paid or user-visible workflow?
- [ ] Does it need billing now, or can access stay manual at launch?
- [ ] Does it need organizations or teams now, or only individual accounts?
- [ ] Does it need a public/mobile API now, or only server-rendered web flows?
- [ ] What production host, email provider, storage provider, and deployment target will be used?
- [ ] What data retention, backup, privacy, and support expectations apply?

Create `docs/product-modules/module-contract.md` defining rules for optional modules:

- [ ] Each module owns its namespace, routes, migrations, policies, jobs, tests, seed data, and removal notes.
- [ ] A module may not add global callbacks or tenant scoping without tests proving isolation.
- [ ] A module must document install, upgrade, and removal steps.
- [ ] A module is promoted into core only after two real products need the same behavior.

## Task 13.5: Template documentation

Replace the generated README with sections:

```text
What this starter includes
Architecture
Prerequisites
Local setup
Environment variables
Running web/Vite/jobs
Tests and quality gate
Authentication model
Roles and policies
Layouts and frontend ownership
Creating a new product
Adding an optional module
Deployment
Upgrade policy
Security reporting
```

Create architecture decision records:

```text
docs/decisions/0001-modular-monolith.md
docs/decisions/0002-vite-ruby.md
docs/decisions/0003-erb-hotwire-and-inertia-svelte.md
docs/decisions/0004-session-authentication.md
docs/decisions/0005-solid-stack-first.md
docs/decisions/0006-product-modules-not-core.md
```

## Task 13.6: Upgrade policy

Document a quarterly maintenance routine:

- [ ] Read Rails security announcements and release notes.
- [ ] Run `bundle outdated`.
- [ ] Run `pnpm outdated`.
- [ ] Run `bin/vite upgrade` on a dedicated branch when needed.
- [ ] Update Playwright and reinstall browser binaries.
- [ ] Review PostgreSQL support on the hosting platform.
- [ ] Run full CI and a production Docker smoke test.
- [ ] Merge framework upgrades separately from product features.

- [ ] Tag the first stable starter release as `v1.0.0` only after Phase 14 passes.

---

# Phase 14 — Final acceptance test

The boilerplate is complete only when this clean-room flow works from a fresh clone.

## Task 14.1: Fresh-clone setup

From the completed starter repository:

```bash
REPOSITORY_URL="$(git remote get-url origin)"
cd ..
rm -rf starter-acceptance
git clone "$REPOSITORY_URL" starter-acceptance
cd starter-acceptance
mise install
bundle install
pnpm install --frozen-lockfile
docker compose up -d postgres
bin/rails db:prepare
bin/rails db:seed
bin/quality
```


## Task 14.2: Manual acceptance checklist

- [ ] Public home page loads in Indonesian.
- [ ] Guest switches to English and the choice persists.
- [ ] Guest registers.
- [ ] Verification email is queued and the verification link works.
- [ ] Verified member logs in.
- [ ] Member dashboard renders through Inertia + Svelte.
- [ ] Member updates profile, locale, time zone, and avatar.
- [ ] Member sees a database notification and marks it read.
- [ ] Member cannot access `/admin`.
- [ ] Staff can access admin users but cannot modify an admin.
- [ ] Admin can suspend and unsuspend a member.
- [ ] Suspension revokes sessions.
- [ ] Every sensitive admin action creates an audit event.
- [ ] Password reset works.
- [ ] Rate limiting works without blocking `/up`.
- [ ] `bin/quality` passes.
- [ ] Production assets compile.
- [ ] Docker image builds and responds at `/up`.
- [ ] `bin/smoke_production` passes against a production-like container.
- [ ] A local database backup can be restored into a fresh database and pass the smoke check.
- [ ] No product-specific model exists in the core schema.
- [ ] README is sufficient for a developer with no previous project context.

## Task 14.3: Final release

```bash
git status
git tag -a v1.0.0 -m "Rails general product starter v1.0.0"
git push origin main --tags
```

Do not tag while the working tree is dirty or CI is failing.

---

# Optional product modules

Each module must have its own design document, migration plan, tests, and removal instructions. A module is added only when the first real product needs it.

## Module A — Billing

Add when a product charges money.

Suggested boundary:

```text
Billing::Customer
Billing::Order
Billing::PaymentAttempt
Billing::WebhookEvent
Billing::GrantEntitlement
```

Required before implementation:

- Provider choice.
- One-time versus recurring payments.
- Currency and tax rules.
- Refund policy.
- Idempotent webhook strategy.
- Entitlement model.

## Module B — Organizations and multi-tenancy

Add when multiple users collaborate under an organization.

Suggested boundary:

```text
Organization
Membership
Invitation
Current.organization
OrganizationPolicy
```

Do not add tenant scoping to every query without automated tests proving isolation.

## Module C — Public/API clients

Add when a mobile app or third party needs an API.

Decide first:

- Session cookies versus scoped tokens.
- API versioning.
- Rate limits.
- Serialization format.
- Idempotency keys.
- Audit requirements.

Do not make the browser application use JWT merely because an API exists.

## Module D — CMS/content

Add product-specific content tables and authoring workflows. Keep localized UI strings separate from database content translations.

## Module E — Product analytics

Start with privacy-conscious event capture only after defining:

- Questions the events answer.
- Retention period.
- User consent requirements.
- Anonymous versus identified events.
- Warehouse/provider destination.

## Module F — AI capabilities

Before adding AI:

- Define the user-visible job.
- Decide what data may leave the application.
- Add prompt/version tracking.
- Add cost and rate limits.
- Add evaluation fixtures.
- Add human fallback and failure states.

---

# Vibe-coding execution protocol

Copy the following instruction into the coding agent at the beginning of each implementation session:

```text
Implement the next unchecked task in rails-general-product-boilerplate-roadmap.md.

Rules:
1. Read the task, adjacent architecture rules, and existing code before editing.
2. Do not implement later phases or optional product modules.
3. Start with a failing automated test when behavior is being added or changed.
4. Make the smallest coherent implementation that passes the test.
5. Preserve Rails conventions and existing project patterns.
6. Keep controllers thin; use policies, query objects, and services at the boundaries defined in the roadmap.
7. Do not weaken authentication, CSRF, CSP, authorization, rate limiting, or database constraints to make a test pass.
8. Run the narrow relevant tests first, then run bin/quality.
9. Mark only fully completed checkboxes.
10. Commit with a conventional message after the task passes all checks.
11. Report files changed, tests run, and any deviation from this roadmap.
12. Stop after the current task so the change can be reviewed.
```

## Recommended commit sequence

```text
chore: pin starter runtimes
chore: generate Rails product starter
build: add Rails and frontend dependencies
feat: configure Vite Hotwire Inertia and Svelte
test: add Rails frontend and browser quality gates
feat: add complete account authentication
feat: add account settings and authorization
feat: add internationalization
feat: add member and admin application shells
feat: add admin user management
feat: add notifications storage jobs and mail
feat: add auditing and security controls
ci: add full-stack verification
chore: productize Rails starter template
docs: complete starter runbooks
```

---

# Definition of done

A task is done only when all applicable statements are true:

- [ ] Behavior is covered by automated tests.
- [ ] Database invariants use constraints and indexes where appropriate.
- [ ] Authorization is enforced server-side.
- [ ] Inputs are validated and unsafe parameters are not permitted.
- [ ] Error and empty states are implemented.
- [ ] Indonesian and English UI copy exists.
- [ ] Accessibility basics are present: labels, keyboard focus, landmarks, and semantic controls.
- [ ] No sensitive values appear in logs or rendered pages.
- [ ] No N+1 query is introduced in collection pages.
- [ ] `bin/quality` passes.
- [ ] Production assets compile.
- [ ] Documentation is updated.
- [ ] The checkbox is marked complete.
- [ ] A focused Git commit exists.

---

# Primary references

- Rails Guides — Getting Started: https://guides.rubyonrails.org/getting_started.html
- Rails Guides — Security: https://guides.rubyonrails.org/security.html
- Rails Guides — Command Line: https://guides.rubyonrails.org/command_line.html
- Rails 8 release notes: https://guides.rubyonrails.org/8_0_release_notes.html
- Rails Generators and Application Templates: https://guides.rubyonrails.org/generators.html
- Vite Ruby — Getting Started: https://vite-ruby.netlify.app/guide/
- Vite Ruby — Rails Integration: https://vite-ruby.netlify.app/guide/rails.html
- Inertia Rails — Server-Side Setup: https://inertia-rails.dev/guide/server-side-setup
- Inertia Rails — Client-Side Setup: https://inertia-rails.dev/guide/client-side-setup
- Svelte packages and official Vite plugin: https://svelte.dev/packages
- Tailwind CSS with Vite: https://tailwindcss.com/docs/installation/using-vite
- Playwright installation: https://playwright.dev/docs/intro
