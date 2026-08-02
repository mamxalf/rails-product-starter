# Catalyst UI Adoption — Design Spec

**Date:** 2026-08-02
**Status:** Approved (brainstormed) → ready for implementation plan
**Reference:** `docs/ui-kit/catalyst-ui-kit/` (Catalyst UI Kit by Tailwind Labs)

## Goal

Port the Catalyst UI Kit's **design language** into this Rails 8.1 product starter as a single design system that spans both frontends: the Svelte 5 + Inertia `/app` SPA and the ERB + Turbo/Stimulus surfaces (auth, marketing, settings, admin). Produce a cohesive, Catalyst-faithful look — zinc palette, `rounded-lg`, Inter, heroicons, `data-*` state styling — without adopting React or Headless UI.

## Decisions (locked during brainstorm)

1. **Strategy — port the design language.** Keep Svelte + ERB. Catalyst is the visual reference, not a literal dependency. Preserves the existing auth/i18n/admin/audit work.
2. **Scope — all four surfaces, one system.** `/app` SPA, auth + marketing, settings, admin. Designed as one cohesive system; implemented surface-by-surface.
3. **Dark mode — light only, dark-mode-ready.** Ship the light theme now. Every component class string keeps its Catalyst `dark:` variants unresolved at `:root`, so adding a dark palette later is fill-in, not a rewrite.
4. **Architecture — CSS-first shared classes.** Catalyst's class recipes live once in CSS; Svelte components and ERB partials both consume them.
5. **Icons — heroicons.** The community `heroicons` gem (jclusso, MIT — Rails view helpers for heroicons SVGs) for ERB; tiny local `.svelte` icon components (copied heroicons SVG markup) for the SPA. No npm icon dependency.
6. **Admin shell — `sidebar-layout`.** Admin gets the same Catalyst sidebar shell as `/app` for a consistent authenticated-app feel.

## Architecture: the three-layer cake

### Layer 1 — Design tokens (`app/frontend/styles/application.css`)

Keep the existing `@import "tailwindcss"`, the two `@source` directives (ERB + Svelte/JS/TS), the Inter `--font-sans`, and the base `html`/focus styles. Add Catalyst's component-theming custom properties at `:root`:

- `--btn-bg`, `--btn-border`, `--btn-hover-overlay`, `--btn-icon` (drive Button color variants)
- focus-ring color (`--color-blue-500`)
- radius token (`--radius-lg`)

Light values now. The `dark:` variants in every Layer-2 class remain in the source but are no-ops until a `@media (prefers-color-scheme: dark)` / `.dark` strategy and dark palette are added later.

### Layer 2 — Component class recipes (`@layer components`)

The IP port. Each Catalyst component's Tailwind class string is translated **verbatim** — including the `data-focus` / `data-hover` / `data-active` / `data-disabled` state hooks, the `[data-slot=icon]` child conventions, and the `dark:` variants — into a semantic CSS class. Both stacks consume `class="btn …"` identically.

Classes to define:

- **Buttons/links:** `.btn`, `.btn--outline`, `.btn--plain`, `.btn--{color}` (`dark/zinc`, `light`, `dark/white`, `dark`, `white`, `zinc`, `indigo`, `cyan`, `red`, `orange`, `amber`, `yellow`, `lime`, `green`, `emerald`, `teal`, `sky`, `blue`, `violet`, `purple`, `fuchsia`, `pink`, `rose`), `.link`
- **Forms:** `.input`, `.textarea`, `.select`, `.checkbox`, `.radio`, `.switch`; `.fieldset`, `.fieldset-group`, `.label`, `.description`, `.field-error`
- **Display:** `.badge`, `.badge--{color}`, `.alert`, `.alert--{tone}` (`success | error | info | warning`), `.card`, `.divider`, `.heading`, `.text`, `.avatar`
- **Sidebar shell:** `.sidebar`, `.sidebar-header`, `.sidebar-body`, `.sidebar-footer`, `.sidebar-section`, `.sidebar-item`, `.sidebar-heading`, `.sidebar-label`, `.sidebar-divider`, `.sidebar-spacer`
- **Navbar shell:** `.navbar`, `.navbar-section`, `.navbar-item`, `.navbar-spacer`
- **Data:** `.table`, `.table-head`, `.table-body`, `.table-row`, `.table-cell`; `.pagination`; `.description-list`
- **Overlays/widgets:** `.dropdown`, `.dropdown-button`, `.dropdown-menu`, `.dropdown-item`, `.dropdown-label`, `.dropdown-divider`; `.dialog`, `.dialog-backdrop`, `.dialog-panel`, `.dialog-title`, `.dialog-description`; `.listbox`, `.listbox-option`, `.combobox`
- **Layouts:** `.sidebar-layout`, `.stacked-layout`, `.auth-layout`

Color recipes are reduced to the Catalyst light-theme subset per decision 3 (the `dark:` lines stay in the string for later).

> Note: `.card` is the one **addition** rather than a verbatim Catalyst component — Catalyst ships no explicit Card; the demo's panel pattern is captured as `.card` for the starter's cards. Every other class above is a direct port.

### Layer 3 — Thin per-stack wrappers (only where reuse earns them)

Default to **direct CSS-class usage** in markup (lazy). Add a wrapper component only for high-reuse or stateful pieces, to prevent drift and give an ergonomic API.

**Svelte (`app/frontend/components/`)** — typed-props + snippet children:
`Button.svelte`, `Link.svelte`, `Input.svelte`, `Textarea.svelte`, `Select.svelte`, `Fieldset.svelte` (+ `Label`, `Description`, `FieldError`), `Checkbox.svelte`, `Switch.svelte`, `Badge.svelte`, `Alert.svelte`, `Divider.svelte`, `Heading.svelte`, `Text.svelte`, `Avatar.svelte`, `Card.svelte`, the `Sidebar*` set, `Navbar*` set, `Table*` set, `Pagination.svelte`, `Dropdown*.svelte`, `Dialog.svelte`, `Listbox.svelte`, `Combobox.svelte`, `DescriptionList.svelte`, plus `SidebarLayout.svelte` / `StackedLayout.svelte` / `AuthLayout.svelte`.

Behavioral components (Dropdown, Dialog, Switch, Listbox, Combobox) implement open/close, focus-trap, escape, click-outside, and keyboard nav **in Svelte** — no Headless UI.

**Icons (`app/frontend/icons/`)** — one tiny `.svelte` per heroicons SVG actually used (e.g. `Home.svelte`, `Bell.svelte`, `Cog6Tooth.svelte`, `UserCircle.svelte`, `ChevronDown.svelte`, `ArrowRightStartOnRectangle.svelte`, …). Each is a `<svg>` with `{...rest}` props and `data-slot="icon"` so Catalyst's icon slot styling applies.

**ERB (`app/views/shared/components/`)** — plain partials mirroring the Svelte set, taking locals (`variant`, `color`, `icon`, `form`, `method`, `errors`, content block): `_button.html.erb`, `_link.html.erb`, `_field.html.erb` (+ label/input/error), `_badge.html.erb`, `_alert.html.erb`, `_card.html.erb`, the `_sidebar*.html.erb` set, `_navbar*.html.erb`, `_table*.html.erb`, `_pagination.html.erb`, `_dropdown*.html.erb`, `_dialog.html.erb`, `_listbox.html.erb`, `_combobox.html.erb`. Icons via `heroicon("name", variant: :solid, class: "size-5")`.

These replace the existing ad-hoc partials: `_auth_card`, `_flash`, `_form_errors`, `_pagination`, `_empty_state`, `_public_nav`, `_footer`, `_admin_navigation`, settings `_nav` / `_errors`. The old partials are deleted as each consuming page is migrated.

### Behavior parity

- **Focus & ARIA:** dialogs and dropdowns/menus trap focus, restore on close, close on `Escape`, and carry the right `aria-*` (Catalyst/Headless UI parity). Implemented in Svelte for the SPA, in Stimulus for ERB.
- **Sidebar active indicator:** Catalyst animates it with `motion/react` `layoutId`. We use a **CSS-only** indicator (background highlight + static left bar).
  > `ponytail:` animated `layoutId` active indicator — ceiling: no motion lib. Upgrade path: add `svelte-motion` (or motion v10) and a shared `LayoutGroup` if animated transitions are later wanted.
- **Transitions:** CSS `transition`/`data-state` for menu and dialog enter/exit. No JS animation library.

## Backend impact

**None structural.** No routes, controllers, models, services, policies, jobs, or mailers change. The auth chain, audit trail (`Auditing::Record`), roles enum, and i18n resolution are untouched.

Additions only:
- `heroicons` gem (Gemfile) — community gem by jclusso, MIT, ~158k downloads; bundler-audit clean.
- The CSS component layer and Stimulus controllers.
- Rewritten/added views and partials; updated Svelte components and pages.

`inertia_share` props (`auth`, `notifications.unread_count`, `locale`, `i18n`, `permissions`, `flash`) keep their exact shapes — the new components simply render them with Catalyst markup.

## Layout mapping

| Surface | Catalyst shell | Replaces |
|---|---|---|
| `/app` SPA | `sidebar-layout` (sidebar + top navbar: avatar dropdown, notification bell w/ unread badge, ID/EN locale toggle) | current basic sidebar `AppLayout.svelte` |
| Auth (login / register / forgot / reset) | `auth-layout` (centered/split card) | `_auth_card` |
| Marketing (home / about / contact / terms / privacy) | `stacked-layout` (top nav + footer) | `_public_nav` + `_footer` |
| Settings | app `sidebar-layout` + settings **sub-nav** (content + secondary nav) | settings `_nav` |
| Admin | `sidebar-layout` (Dashboard / Users / Notifications + navbar) | `_admin_navigation` top nav |

**Locale switch, notifications bell, account dropdown, sign-out** move into the navbar/shell. They keep the same calls — Inertia `router.patch("/locale", …)`, `router.delete("/session")`, link to `/app/notifications` — restyled only.

## Form & flash wiring

- **Field errors:** Catalyst's `FieldError` maps to Rails `object.errors`. ERB `_field.html.erb` takes `form` + `method`, renders `.label` + `.input` + `.field-error` (driven by `form.object.errors[method]`). Svelte `Field.svelte` takes an `errors` prop. Replaces `_form_errors` / `_errors`.
- **Flash:** inline flash blocks become `<Alert>` (Svelte) / `_alert.html.erb` (ERB) in `tone: success | error | info`, driven by existing `flash.notice` / `flash.alert`.

## Stimulus controllers (ERB behavior)

Five small controllers in `app/frontend/controllers/`, each consuming Layer-2 classes only (no per-instance styles):

- `dropdown_controller.js` — toggle, click-outside, escape, keyboard nav.
- `dialog_controller.js` — open/close, focus-trap, backdrop click, escape.
- `switch_controller.js` — toggle state for ERB settings forms (hidden field sync).
- `listbox_controller.js` — open/close, keyboard nav, selection.
- `combobox_controller.js` — listbox + filter input, keyboard nav.

## Testing

- **Backend:** existing RSpec request specs (auth chain unauth → unverified → suspended, page renders) stay green untouched — no routing/controller changes. Add light request specs that complex shared partials render without error (`_field`, `_sidebar_item`).
- **Frontend:** update `AppLayout.test.ts` / `Dashboard.test.ts` for new markup. Add **behavior-focused** Vitest tests for interactive components only — Dropdown, Dialog, Switch, Listbox, Combobox (open/close, escape, click-outside, keyboard nav, focus). Static components (Button, Badge, Alert, Table, …) get no unit tests; `svelte-check` covers their types. (One runnable check for non-trivial logic; trivial components need none.)
- **Quality gate:** `bin/quality` passes — RuboCop, Brakeman, bundler-audit, RSpec, svelte-check, ESLint, Prettier, Vitest, production `assets:precompile`.
- **Visual:** manual side-by-side against `docs/ui-kit/catalyst-ui-kit/demo` per surface. No automated visual regression (not worth the infra for a starter).

## Rollout order

One spec, implemented in this sequence so the app stays green after each step:

1. **Foundation** — tokens + `@layer components` recipes; add `heroicons` gem; create `app/frontend/icons/*` Svelte icon set.
2. **Base Svelte components** — Button, Link, Input, Textarea, Select, Fieldset/Label/FieldError, Badge, Alert, Divider, Heading, Text, Avatar, Card.
3. **Base ERB partials** — mirror the same set.
4. **Behavioral Svelte** — Dropdown, Dialog, Switch, Listbox, Combobox (+ Vitest tests).
5. **Behavioral Stimulus** — `dropdown`, `dialog`, `switch`, `listbox`, `combobox` controllers.
6. **Layout shells** — `sidebar-layout`, `stacked-layout`, `auth-layout` in both Svelte and ERB.
7. **`/app` SPA** — rewrite `AppLayout` as sidebar-layout; restyle Dashboard + Notifications.
8. **Auth surface** — auth-layout → sessions/registrations/passwords new + edit.
9. **Marketing surface** — stacked-layout → home + about/contact/terms/privacy.
10. **Settings surface** — app shell + settings sub-nav → accounts/profiles/preferences/sessions/security.
11. **Admin surface** — sidebar-layout → dashboard + users index/show + notifications index/new.
12. **Quality gate + visual sweep** — fix drift, ship.

Steps are independently mergeable; partials/components land before the pages that consume them.

## Out of scope (deferred)

- **Dark theme palette** — the architecture is ready; filling in `dark:` values is a follow-up.
- **Animated sidebar indicator** (`motion/react` `layoutId`) — CSS-only indicator for now; see `ponytail:` note.
- **Automated visual regression testing.**
- **New pages/features** — this is a restyle only; no behavioral or model changes.
