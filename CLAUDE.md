# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Rails 8.1 product starter (auth, accounts, admin, notifications, i18n) with a split frontend: an Inertia.js + Svelte 5 SPA for the authenticated app, and traditional Turbo/Stimulus + ERB for marketing pages and the admin panel. Ruby styling is Rails Omakase; run `bundle exec rubocop -A` to auto-correct.

## Commands

**Quality gate (run before PR):** `bin/quality` — chains RuboCop, Brakeman, bundler-audit, RSpec, svelte-check, ESLint, Prettier, Vitest, and a production `assets:precompile`. This is authoritative; Lefthook only mirrors part of it.

**Dev server:** `bin/dev` (runs `web`, `vite`, and `jobs` via Procfile.dev → foreman). First-time setup: `bin/setup`.

**Backend (Ruby):**
- `bin/rails server` / `bin/rails console`
- `bin/jobs start` — Solid Queue worker (mailers, notifications, default, low_priority queues)
- Tests: `bundle exec rspec` · single file `bundle exec rspec spec/requests/foo_spec.rb` · single example append `:LINE`
- Lint/security: `bundle exec rubocop` · `bundle exec brakeman -q --no-pager` · `bundle exec bundler-audit check --update`

**Frontend (pnpm):**
- `pnpm run check` (svelte-check) · `pnpm run lint` · `pnpm run format:check`
- Unit tests: `pnpm run test` (Vitest) · watch `pnpm run test:watch` · filter `pnpm run test -- <pattern>`
- E2E: `pnpm run test:e2e` (Playwright, `e2e/` + `playwright.config.ts`)

`bin/quality` must pass; hooks are optional (`LEFTHOOK=0` to skip in emergencies, then run quality manually).

## Architecture

### Two frontends, one asset pipeline
Vite (`vite_rails`) is the only asset pipeline — there is no importmap/sprockets for JS. Two Vite entrypoints under `app/frontend/entrypoints/`:
- **`inertia.ts`** → Inertia + Svelte SPA, mounted in `app/views/layouts/inertia.html.erb`. Used by the authenticated `/app` shell.
- **`application.ts`** → Turbo + Stimulus (`app/frontend/controllers/`), mounted in `app/views/layouts/application.html.erb` and `admin.html.erb`. Used by marketing pages and the admin panel.

Inertia pages resolve by name: a controller calling `render inertia: "app/Dashboard"` maps to `app/frontend/pages/app/Dashboard.svelte` (globbed in `inertia.ts`).

### Controller layering
`ApplicationController` includes `Authentication`, `Pundit::Authorization`, and an `around_action :switch_locale`. Three shells branch from it:
- **`App::BaseController`** (`layout "inertia"`) — authenticated user app. Includes `VerifiedUserRequired` + `NotSuspended` concerns, and exposes shared props (auth user, unread notification count, permissions, flash) to every Inertia page via `inertia_share`.
- **`Admin::BaseController`** (`layout "admin"`) — ERB-rendered; `before_action :authorize_admin` gates on `UserPolicy#access_admin?`.
- **`Settings::BaseController`** — account/profile/security/preferences/sessions.

Access control is layered through controller concerns: `Authentication` (cookie-backed `Session` model + `Current`), `VerifiedUserRequired`, `NotSuspended`, `StaffAccessRequired`. There is **no Devise** — auth is hand-rolled with `has_secure_password` + a persisted `Session` per device.

### Request-scoped state
`Current` (`ActiveSupport::CurrentAttributes`) holds `Current.session` → `Current.user`. Set by the `Authentication` concern; read everywhere (policies, `inertia_share`, auditing). `ApplicationController#pundit_user` returns `Current.user`.

### Business logic location
Controllers stay thin. Mutations and domain operations live in **`app/services`**, namespaced per domain (`Admin::Users::ChangeRole`, `Notifications::Create`, `Accounts::EmailVerificationToken`), each a class with a `.call` class method. Read-side aggregations live in **`app/queries`** (Query objects, paginated with `pagy`). Authorization rules live in **`app/policies`** (Pundit).

### Audit trail
Anything security-sensitive calls `Auditing::Record.call(...)` to write an `AuditEvent` (polymorphic `target`, optional `actor`/`request` for IP + user agent). Follow this pattern for new privileged operations.

### Roles
`User#role` enum: `member` (0), `staff` (1), `admin` (2). `staff` is a limited moderator tier — service objects (e.g. `Admin::Users::ChangeRole`) enforce explicit rules about what staff can/cannot do, including protecting the last remaining admin.

### Jobs
Background work uses **Solid Queue** (DB-backed, no Redis). Queue names are fixed: `default`, `mailers`, `notifications`, `low_priority`. Mailers go to `:mailers` (set in `config/initializers/action_mailer.rb`). Recurring tasks live in `config/recurring.yml`.

### i18n
Two locales: `en`, `id` (`config/locales/`). Locale resolves in `ApplicationController#current_locale` with priority: `params[:locale]` → user's `preferred_locale` → signed `cookies[:locale]` → default. Persisted via the `locale` resource route.

## Testing conventions

RSpec request specs (`spec/requests/`) are the primary integration layer and verify the full auth/concern chain (unauthenticated → unverified → suspended all redirect to login). There is **no factories directory** — specs define inline helpers (`create_user(**)`, `sign_in(user)` via `post session_path`) rather than using FactoryBot, even though `factory_bot_rails` is installed. Match this inline-helper style in new request specs. Service and query objects have their own specs under `spec/services`, `spec/queries`.

## Environment notes
- Mail: `MAILER_FROM`, `APP_HOST`, `APP_PROTOCOL` env vars.
- Active Storage: S3-compatible via `S3_*` env vars in `config/storage.yml`; avatar uses an `image_processing` variant.
- `config/master.key` / `credentials.yml.enc` for secrets.
