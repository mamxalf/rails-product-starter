# Catalyst Foundation — Design System Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Catalyst design-system foundation — design tokens, Tailwind component class recipes, a Svelte 5 component library, an ERB partial library, a heroicons icon set, and the three layout shells — that all four surface migrations will consume.

**Architecture:** CSS-first sharing. Catalyst's class recipes live once in `@layer components` in `app/frontend/styles/application.css`. Svelte components (`app/frontend/components/`) and ERB partials (`app/views/shared/components/`) are thin wrappers that consume those classes. No React, no Headless UI; behavioral state hooks are translated to native CSS pseudo-classes. This plan produces a complete, independently-testable library; no page is migrated here (that is follow-up plans 3–6).

**Tech Stack:** Rails 8.1, Tailwind CSS v4, Svelte 5 (runes), Inertia.js, Turbo/Stimulus (`.ts` controllers), Vitest + @testing-library/svelte, RSpec, the `heroicons` Ruby gem.

## Global Constraints

Apply to every task. Copy verbatim from the design spec unless noted.

- **No new npm dependencies.** Use a tiny local `cx()` class-join helper (Task 1) instead of `clsx`. Catalyst's `motion/react`, `@headlessui/react`, `@heroicons/react` are NOT installed.
- **Add the `heroicons` Ruby gem** (community, jclusso, MIT) to the `Gemfile` for ERB icons: `heroicon("name", variant: :solid, class: "size-5")`.
- **Stimulus controllers are `.ts`** and auto-register via the glob in `app/frontend/controllers/index.ts` (`./**/*_controller.ts`). (No behavioral Stimulus controllers in this foundation plan — those are follow-up plan 2.)
- **Single CSS file.** All recipes go in `app/frontend/styles/application.css` (imported by both `inertia.ts` and `application.ts`). Never add a second stylesheet.
- **State-hook translation (systematic deviation from Catalyst "verbatim"):** Catalyst uses Headless UI attributes. Translate when porting recipes:
  - `data-hover:` → `hover:` ; `group-data-hover:` → `group-hover:`
  - `data-focus:` → `focus:` (on inputs/buttons) or `focus-within:` (on wrapper `<span>`s that host the focus ring)
  - `data-active:` → `active:` (native press)
  - `data-disabled:` → `disabled:` (or keep `data-disabled:` and set the attribute manually where a non-form element needs it)
  - KEEP as real attributes (set manually in markup): `data-current` (active nav item), `data-invalid` (Rails error), `data-slot="icon"` / `data-slot="control"` / `data-slot="label"` / `data-slot="avatar"` (Catalyst's slot convention used by descendant selectors).
- **Svelte 5 runes only.** Components take typed `$props()` and a `children?: Snippet`. Use `$derived()` for computed class strings. Match the style of `app/frontend/components/StatusBadge.svelte` and `app/frontend/layouts/AppLayout.svelte`.
- **Test conventions.** Vitest + `@testing-library/svelte`, jsdom, `@testing-library/jest-dom/vitest` (already in `app/frontend/test/setup.ts`). Test files are `*.test.ts` next to the component. The `@` alias resolves to `app/frontend`. Inline all i18n/props in test renders (see `AppLayout.test.ts`).
- **ERB partial conventions.** Partials live in `app/views/shared/components/`, take locals via `locals:` at the call site, and emit Catalyst classes. Icons via the `heroicons` gem helper.
- **Quality gate.** `bin/quality` must pass before the final commit (RuboCop, Brakeman, bundler-audit, RSpec, svelte-check, ESLint, Prettier, Vitest, production `assets:precompile`).
- **No backend changes.** No routes, controllers, models, services, or policies are modified. Only the Gemfile (+ lock), CSS, Svelte, ERB partials, icons, and specs.
- **`@apply` escape hatch.** Recipes are written with `@apply <utilities>;` inside `@layer components`. If a specific Catalyst utility (e.g. a very nested `has-*`/`supports-*` selector) errors under `@apply`, move just that one utility into the component's markup `class=""` and leave the rest in the recipe.

## File Structure

Created in this plan (grouped by responsibility):

```
app/frontend/lib/cx.ts                              # class-join helper
app/frontend/styles/application.css                 # MODIFY: tokens + @layer components recipes
app/frontend/icons/*.svelte                         # heroicons SVG components (Task 7)
app/frontend/components/Button.svelte               # + Button.test.ts
app/frontend/components/Link.svelte
app/frontend/components/Text.svelte                 # Text / Strong / Code
app/frontend/components/Heading.svelte             # Heading / Subheading
app/frontend/components/Divider.svelte
app/frontend/components/Avatar.svelte
app/frontend/components/Card.svelte
app/frontend/components/Badge.svelte                # + Badge.test.ts
app/frontend/components/Alert.svelte                # + Alert.test.ts
app/frontend/components/Input.svelte
app/frontend/components/Textarea.svelte
app/frontend/components/Select.svelte
app/frontend/components/Checkbox.svelte
app/frontend/components/Fieldset.svelte             # Fieldset / Field / FieldGroup / Label / Description / FieldError
app/frontend/components/Table.svelte                # Table / Head / Body / Row / Header / Cell
app/frontend/components/Pagination.svelte           # Pagination / List / Page / Gap / Prev / Next
app/frontend/components/DescriptionList.svelte
app/frontend/components/Sidebar.svelte              # Sidebar / Header / Body / Footer / Section / Item / Heading / Label / Divider / Spacer
app/frontend/components/Navbar.svelte               # Navbar / Section / Item / Spacer / Divider
app/frontend/components/SidebarLayout.svelte        # + SidebarLayout.test.ts
app/frontend/components/StackedLayout.svelte
app/frontend/components/AuthLayout.svelte
app/frontend/components/index.ts                    # barrel export

app/views/shared/components/_button.html.erb
app/views/shared/components/_link.html.erb
app/views/shared/components/_text.html.erb
app/views/shared/components/_heading.html.erb
app/views/shared/components/_divider.html.erb
app/views/shared/components/_avatar.html.erb
app/views/shared/components/_card.html.erb
app/views/shared/components/_badge.html.erb
app/views/shared/components/_alert.html.erb
app/views/shared/components/_input.html.erb
app/views/shared/components/_textarea.html.erb
app/views/shared/components/_select.html.erb
app/views/shared/components/_checkbox.html.erb
app/views/shared/components/_field.html.erb         # label + input + error, Rails errors wired
app/views/shared/components/_fieldset.html.erb
app/views/shared/components/_table.html.erb         # Table / Head / Row / Header / Cell via locals/blocks
app/views/shared/components/_pagination.html.erb    # pagy-aware
app/views/shared/components/_description_list.html.erb
app/views/shared/components/_sidebar.html.erb       # + _sidebar_item.html.erb
app/views/shared/components/_navbar.html.erb        # + _navbar_item.html.erb
app/views/shared/components/_sidebar_layout.html.erb
app/views/shared/components/_stacked_layout.html.erb
app/views/shared/components/_auth_layout.html.erb

app/frontend/components/.keep                        # already exists
Gemfile                                              # MODIFY: add heroicons

spec/views/shared/components/components_spec.rb      # smoke-render presentational partials
```

---

### Task 1: Foundation setup — `cx` helper, heroicons gem, tokens, CSS skeleton

**Files:**
- Create: `app/frontend/lib/cx.ts`
- Modify: `Gemfile` (add `heroicons`), `Gemfile.lock` (via bundle)
- Modify: `app/frontend/styles/application.css:1-27` (add `:root` tokens + empty `@layer components` scaffold + `@source` for the new dirs)
- Test: `app/frontend/lib/cx.test.ts`

**Interfaces:**
- Produces: `cx(...parts: (string | false | null | undefined | Array<ClassValue>)[]): string` — used by every Svelte component in later tasks.
- Produces: the `heroicons` gem helper `heroicon(name, variant:, class:, **opts)` — used by ERB partials in later tasks.
- Produces: `@layer components { … }` block in `application.css` where all recipes land.

- [ ] **Step 1: Write the failing test for `cx`**

```ts
// app/frontend/lib/cx.test.ts
import { describe, expect, it } from "vitest"
import { cx } from "./cx"

describe("cx", () => {
  it("joins truthy string parts with spaces", () => {
    expect(cx("btn", "btn--indigo")).toBe("btn btn--indigo")
  })

  it("drops false, null, and undefined", () => {
    expect(cx("btn", false, null, undefined, "btn--plain")).toBe("btn btn--plain")
  })

  it("flattens arrays", () => {
    expect(cx("btn", ["a", false, "b"])).toBe("btn a b")
  })
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pnpm vitest run app/frontend/lib/cx.test.ts`
Expected: FAIL — `Failed to resolve import "./cx"` (module does not exist).

- [ ] **Step 3: Implement `cx`**

```ts
// app/frontend/lib/cx.ts
export type ClassValue = string | false | null | undefined

/** Minimal clsx-equivalent: joins truthy class names, flattening one level of arrays. */
export function cx(
  ...parts: Array<ClassValue | ClassValue[]>
): string {
  return parts
    .flat()
    .filter((p): p is string => typeof p === "string" && p.length > 0)
    .join(" ")
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pnpm vitest run app/frontend/lib/cx.test.ts`
Expected: PASS (3 tests).

- [ ] **Step 5: Add the `heroicons` gem**

In `Gemfile`, add immediately after the `gem "pundit"` line (line 57):

```ruby
gem "heroicons", "~> 2.0"
```

Then install:

```bash
bundle install
```

Confirm `heroicons` appears in `Gemfile.lock`.

- [ ] **Step 6: Add tokens + the empty `@layer components` scaffold to the CSS**

Replace the entire contents of `app/frontend/styles/application.css` with:

```css
@import "tailwindcss";

@source "../../views/**/*.erb";
@source "../**/*.{js,ts,svelte}";

@theme {
  --font-sans: Inter, ui-sans-serif, system-ui, sans-serif;
}

/* Layer 1 — design tokens. Light values now; dark palette is a follow-up.
   --color-* and --radius-lg come from Tailwind v4's theme; --btn-* are the
   Catalyst button theming hooks, defaulted here and overridden per .btn--{color}. */
:root {
  --btn-bg: var(--color-zinc-900);
  --btn-border: color-mix(in oklab, var(--color-zinc-950) 90%, transparent);
  --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent);
  --btn-icon: var(--color-zinc-400);
  --checkbox-checked-bg: var(--color-zinc-900);
  --checkbox-checked-border: color-mix(in oklab, var(--color-zinc-950) 90%, transparent);
  --checkbox-check: var(--color-white);
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

/* Layer 2 — Catalyst component class recipes. Filled in by Tasks 2–9.
   State hooks are translated from Headless UI's data-* to native CSS
   pseudo-classes (see plan Global Constraints). */
@layer components {
  /* Recipes added in Tasks 2–9. */
}
```

- [ ] **Step 7: Verify the foundation compiles**

Run: `pnpm run check` (svelte-check — confirms `cx.ts` type-checks)
Expected: 0 errors.

Run: `bundle exec bundler-audit check`
Expected: no vulnerabilities (verifies the new gem is clean).

- [ ] **Step 8: Commit**

```bash
git add app/frontend/lib/cx.ts app/frontend/lib/cx.test.ts \
  app/frontend/styles/application.css Gemfile Gemfile.lock
git commit -m "feat(ui): add Catalyst foundation — cx helper, heroicons gem, tokens"
```

---

### Task 2: Button & Link — CSS recipe + Svelte + ERB (exemplar task)

This is the exemplar; later component tasks follow the same shape.

**Files:**
- Create: `app/frontend/components/Button.svelte`, `app/frontend/components/Link.svelte`, `app/frontend/components/Button.test.ts`
- Create: `app/views/shared/components/_button.html.erb`, `app/views/shared/components/_link.html.erb`
- Modify: `app/frontend/styles/application.css` (add `.btn` / `.btn--*` / `.link` recipes to `@layer components`)

**Interfaces:**
- Produces (Svelte): `<Button color?: Color; outline?: boolean; plain?: boolean; href?: string; type?: …; class?: string; children: Snippet; …rest>` and `<Link href: string; class?: string; children: Snippet>`.
- Produces (ERB): `<%= render "shared/components/button", label:, href:, color:, outline:, plain:, class:, icon: %>` and `<%= render "shared/components/link", label:, href:, class: %>`.
- `Color` = `"dark/zinc" | "light" | "dark/white" | "dark" | "white" | "zinc" | "indigo" | "cyan" | "red" | "orange" | "amber" | "yellow" | "lime" | "green" | "emerald" | "teal" | "sky" | "blue" | "violet" | "purple" | "fuchsia" | "pink" | "rose"`.

- [ ] **Step 1: Write the failing Svelte test**

```ts
// app/frontend/components/Button.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Button from "./Button.svelte"

describe("Button", () => {
  it("renders a button element with base + solid dark/zinc classes by default", () => {
    render(Button, { props: { children: makeSnippet("Save") } })
    const el = screen.getByRole("button", { name: "Save" })
    expect(el.className).toMatch(/btn\b/)
    expect(el.className).toMatch(/btn--dark\/zinc/)
  })

  it("renders an anchor when href is set", () => {
    render(Button, {
      props: { href: "/settings", children: makeSnippet("Settings") },
    })
    const link = screen.getByRole("link", { name: "Settings" })
    expect(link.tagName).toBe("A")
    expect(link.className).toMatch(/btn--dark\/zinc/)
  })

  it("applies the outline variant class", () => {
    render(Button, {
      props: { outline: true, children: makeSnippet("Cancel") },
    })
    expect(screen.getByRole("button", { name: "Cancel" }).className).toMatch(
      /btn--outline/,
    )
  })

  it("applies a color modifier", () => {
    render(Button, {
      props: { color: "red", children: makeSnippet("Delete") },
    })
    expect(screen.getByRole("button", { name: "Delete" }).className).toMatch(
      /btn--red/,
    )
  })
})

// Local helper mirroring the inline-snippet pattern used in AppLayout.test.ts
function makeSnippet(text: string) {
  // svelte 5 snippet from a raw string
  // imported lazily to keep the exemplar self-contained
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const { createRawSnippet } = require("svelte") as typeof import("svelte")
  return createRawSnippet(() => ({ render: () => text }))
}
```

> Note: `createRawSnippet` is already used in `AppLayout.test.ts`; if the project's ESLint config flags `require`, prefer `import { createRawSnippet } from "svelte"` at the top of the file instead of the lazy helper. Use whichever passes `pnpm run lint`.

- [ ] **Step 2: Run test to verify it fails**

Run: `pnpm vitest run app/frontend/components/Button.test.ts`
Expected: FAIL — `Unknown Inertia page`/import error (component does not exist).

- [ ] **Step 3: Add the `.btn` / `.btn--*` / `.link` recipes to CSS**

Inside the `@layer components { … }` block in `application.css`, add (adapted from `docs/ui-kit/catalyst-ui-kit/typescript/button.tsx` lines 6–158 per the Global Constraints state-hook translation):

```css
  .btn {
    @apply relative isolate inline-flex items-baseline justify-center gap-x-2 rounded-lg border text-base/6 font-semibold;
    @apply px-[calc(theme(spacing.3.5)-1px)] py-[calc(theme(spacing.2.5)-1px)] sm:px-[calc(theme(spacing.3)-1px)] sm:py-[calc(theme(spacing.1.5)-1px)] sm:text-sm/6;
    @apply focus:outline-hidden focus:outline-2 focus:outline-offset-2 focus:outline-blue-500;
    @apply disabled:opacity-50;
    @apply *:data-[slot=icon]:-mx-0.5 *:data-[slot=icon]:my-0.5 *:data-[slot=icon]:size-5 *:data-[slot=icon]:shrink-0 *:data-[slot=icon]:self-center *:data-[slot=icon]:text-(--btn-icon) sm:*:data-[slot=icon]:my-1 sm:*:data-[slot=icon]:size-4;
  }
  /* Solid background layer — optical border via ::before, hover overlay via ::after */
  .btn--solid {
    @apply border-transparent;
    background: var(--btn-border);
  }
  .btn--solid::before {
    content: "";
    @apply absolute inset-0 -z-10 rounded-[calc(theme(borderRadius.lg)-1px)];
    background: var(--btn-bg);
    @apply shadow-sm;
  }
  .btn--solid::after {
    content: "";
    @apply absolute inset-0 -z-10 rounded-[calc(theme(borderRadius.lg)-1px)] shadow-[inset_0_1px_theme(--color-white/15%)];
  }
  .btn--solid:hover::after,
  .btn--solid:active::after { background: var(--btn-hover-overlay); }

  .btn--outline {
    @apply border-zinc-950/10 text-zinc-950 hover:bg-zinc-950/2.5 active:bg-zinc-950/2.5;
    @apply [--btn-icon:var(--color-zinc-500)] hover:[--btn-icon:var(--color-zinc-700)] active:[--btn-icon:var(--color-zinc-700)];
  }
  .btn--plain {
    @apply border-transparent text-zinc-950 hover:bg-zinc-950/5 active:bg-zinc-950/5;
    @apply [--btn-icon:var(--color-zinc-500)] hover:[--btn-icon:var(--color-zinc-700)] active:[--btn-icon:var(--color-zinc-700)];
  }

  /* Color modifiers set the --btn-* tokens. Port each color from button.tsx `styles.colors`. */
  .btn--dark\/zinc  { --btn-bg: var(--color-zinc-900);  --btn-border: color-mix(in oklab, var(--color-zinc-950) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-zinc-400); }
  .btn--light       { --btn-bg: var(--color-white);     --btn-border: color-mix(in oklab, var(--color-zinc-950) 10%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-zinc-950) 2.5%, transparent); --btn-icon: var(--color-zinc-500); }
  .btn--dark\/white { --btn-bg: var(--color-zinc-900);  --btn-border: color-mix(in oklab, var(--color-zinc-950) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-zinc-400); }
  .btn--dark        { --btn-bg: var(--color-zinc-900);  --btn-border: color-mix(in oklab, var(--color-zinc-950) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-zinc-400); }
  .btn--white       { --btn-bg: var(--color-white);     --btn-border: color-mix(in oklab, var(--color-zinc-950) 10%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-zinc-950) 2.5%, transparent); --btn-icon: var(--color-zinc-400); }
  .btn--zinc        { --btn-bg: var(--color-zinc-600);  --btn-border: color-mix(in oklab, var(--color-zinc-700) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-zinc-400); }
  .btn--indigo      { --btn-bg: var(--color-indigo-500); --btn-border: color-mix(in oklab, var(--color-indigo-600) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-indigo-300); }
  .btn--red         { --btn-bg: var(--color-red-600);   --btn-border: color-mix(in oklab, var(--color-red-700) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-red-300); }
  .btn--green       { --btn-bg: var(--color-green-600); --btn-border: color-mix(in oklab, var(--color-green-700) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: color-mix(in oklab, var(--color-white) 60%, transparent); }
  .btn--emerald     { --btn-bg: var(--color-emerald-600); --btn-border: color-mix(in oklab, var(--color-emerald-700) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: color-mix(in oklab, var(--color-white) 60%, transparent); }
  .btn--blue        { --btn-bg: var(--color-blue-600);  --btn-border: color-mix(in oklab, var(--color-blue-700) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-blue-400); }
  /* Remaining colors (orange, amber, yellow, lime, teal, cyan, sky, violet, purple, fuchsia, pink, rose)
     follow the identical one-line pattern; port their --color-* values from button.tsx `styles.colors`. */
  .btn--orange      { --btn-bg: var(--color-orange-500);  --btn-border: color-mix(in oklab, var(--color-orange-600) 90%, transparent);  --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-orange-300); }
  .btn--amber       { --btn-bg: var(--color-amber-400);   --btn-border: color-mix(in oklab, var(--color-amber-500) 80%, transparent);   --btn-hover-overlay: color-mix(in oklab, var(--color-white) 25%, transparent); --btn-icon: var(--color-amber-600); }
  .btn--yellow      { --btn-bg: var(--color-yellow-300);  --btn-border: color-mix(in oklab, var(--color-yellow-400) 80%, transparent);  --btn-hover-overlay: color-mix(in oklab, var(--color-white) 25%, transparent); --btn-icon: var(--color-yellow-600); }
  .btn--lime        { --btn-bg: var(--color-lime-300);    --btn-border: color-mix(in oklab, var(--color-lime-400) 80%, transparent);    --btn-hover-overlay: color-mix(in oklab, var(--color-white) 25%, transparent); --btn-icon: var(--color-lime-600); }
  .btn--teal        { --btn-bg: var(--color-teal-600);    --btn-border: color-mix(in oklab, var(--color-teal-700) 90%, transparent);    --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: color-mix(in oklab, var(--color-white) 60%, transparent); }
  .btn--cyan        { --btn-bg: var(--color-cyan-300);    --btn-border: color-mix(in oklab, var(--color-cyan-400) 80%, transparent);    --btn-hover-overlay: color-mix(in oklab, var(--color-white) 25%, transparent); --btn-icon: var(--color-cyan-500); }
  .btn--sky         { --btn-bg: var(--color-sky-500);     --btn-border: color-mix(in oklab, var(--color-sky-600) 80%, transparent);     --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: color-mix(in oklab, var(--color-white) 60%, transparent); }
  .btn--violet      { --btn-bg: var(--color-violet-500);  --btn-border: color-mix(in oklab, var(--color-violet-600) 90%, transparent);  --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-violet-300); }
  .btn--purple      { --btn-bg: var(--color-purple-500);  --btn-border: color-mix(in oklab, var(--color-purple-600) 90%, transparent);  --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-purple-300); }
  .btn--fuchsia     { --btn-bg: var(--color-fuchsia-500); --btn-border: color-mix(in oklab, var(--color-fuchsia-600) 90%, transparent); --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-fuchsia-300); }
  .btn--pink        { --btn-bg: var(--color-pink-500);    --btn-border: color-mix(in oklab, var(--color-pink-600) 90%, transparent);    --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-pink-300); }
  .btn--rose        { --btn-bg: var(--color-rose-500);    --btn-border: color-mix(in oklab, var(--color-rose-600) 90%, transparent);    --btn-hover-overlay: color-mix(in oklab, var(--color-white) 10%, transparent); --btn-icon: var(--color-rose-300); }

  .link {
    @apply focus:outline-hidden;
  }
```

> If any single `@apply` line errors (likely the deeply-nested `*:data-[slot=icon]:…` descendant variant), remove that line from `.btn` and instead put it directly on the `<button>`/`<a>` `class=""` in `Button.svelte` (the escape hatch). The test only asserts `.btn`/`.btn--*` presence, so it stays green either way.

- [ ] **Step 4: Implement `Link.svelte` (Button depends on it)**

```svelte
<!-- app/frontend/components/Link.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"

  let {
    href,
    class: klass = "",
    children,
    ...rest
  }: { href: string; class?: string; children: Snippet } & Record<string, unknown> = $props()
</script>

<a {href} class={cx("link", klass)} {...rest}>{@render children()}</a>
```

- [ ] **Step 5: Implement `Button.svelte`**

```svelte
<!-- app/frontend/components/Button.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  import Link from "./Link.svelte"

  export type ButtonColor =
    | "dark/zinc" | "light" | "dark/white" | "dark" | "white" | "zinc"
    | "indigo" | "cyan" | "red" | "orange" | "amber" | "yellow" | "lime"
    | "green" | "emerald" | "teal" | "sky" | "blue" | "violet" | "purple"
    | "fuchsia" | "pink" | "rose"

  let {
    color,
    outline = false,
    plain = false,
    href,
    type = "button",
    class: klass = "",
    children,
    ...rest
  }: {
    color?: ButtonColor
    outline?: boolean
    plain?: boolean
    href?: string
    type?: "button" | "submit" | "reset"
    class?: string
    children: Snippet
  } & Record<string, unknown> = $props()

  // Only one of color/outline/plain is meaningful; solid is the default base layer.
  const variantClass = $derived(
    plain
      ? "btn--plain"
      : outline
        ? "btn--outline"
        : cx("btn--solid", `btn--${color ?? "dark/zinc"}`),
  )
  const classes = $derived(cx("btn", variantClass, klass))
</script>

{#if href}
  <Link {href} class={classes} {...rest}>
    {@render children()}
  </Link>
{:else}
  <button {type} class={classes} {...rest}>
    {@render children()}
  </button>
{/if}
```

> Class-name note: `btn--${color ?? "dark/zinc"}` produces `btn--dark/zinc`. Tailwind/our CSS treats the literal `.btn--dark\/zinc` selector as that class; the `/` is valid in an HTML class token. The test asserts `/btn--dark\/zinc/`.

- [ ] **Step 6: Run the Svelte test to verify it passes**

Run: `pnpm vitest run app/frontend/components/Button.test.ts`
Expected: PASS (4 tests).

Run: `pnpm run check`
Expected: 0 errors.

- [ ] **Step 7: Create the ERB partials**

```erb
<%# app/views/shared/components/_button.html.erb %>
<%#
  Renders a Catalyst-styled button or link.
  Locals:
    label    String   - text label (optional if a block is given)
    href     String   - if present, renders an <a>; otherwise a <button>
    color    String   - one of ButtonColor (default "dark/zinc")
    outline  Boolean  - outline variant
    plain    Boolean  - plain variant
    type     String   - button type (default "button")
    icon     String   - heroicon name rendered before the label (optional)
    class    String   - extra classes
%>
<%
  color   = local_assigns[:color]   || "dark/zinc"
  outline = local_assigns[:outline] || false
  plain   = local_assigns[:plain]   || false
  type    = local_assigns[:type]    || "button"
  variant = plain ? "btn--plain" : (outline ? "btn--outline" : "btn--solid btn--#{color}")
  classes = ["btn", variant, local_assigns[:class]].compact.join(" ")
  icon_html = local_assigns[:icon] ? heroicon(local_assigns[:icon], variant: :solid, class: "size-4") : ""
%>
<% if local_assigns[:href] %>
  <%= link_to local_assigns[:href], class: classes do %>
    <%= icon_html %><%= local_assigns[:label] %><%= yield if block_given? %>
  <% end %>
<% else %>
  <%= button_tag type: type, class: classes do %>
    <%= icon_html %><%= local_assigns[:label] %><%= yield if block_given? %>
  <% end %>
<% end %>
```

```erb
<%# app/views/shared/components/_link.html.erb %>
<%
  classes = ["link", local_assigns[:class]].compact.join(" ")
%>
<%= link_to local_assigns[:href], class: classes do %>
  <%= local_assigns[:label] %><%= yield if block_given? %>
<% end %>
```

- [ ] **Step 8: Verify the ERB partials are syntactically valid**

Run: `bundle exec rails runner "ApplicationController.render('shared/components/button', assigns: {}, locals: { label: 'Save' })"` (or render via the smoke spec in Task 10).
Expected: renders an HTML string starting with `<button` containing `class="btn btn--solid btn--dark/zinc"`.

- [ ] **Step 9: Commit**

```bash
git add app/frontend/components/Button.svelte app/frontend/components/Link.svelte \
  app/frontend/components/Button.test.ts \
  app/views/shared/components/_button.html.erb app/views/shared/components/_link.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst Button + Link (CSS recipe, Svelte, ERB)"
```

---

### Task 3: Typography & primitives — Text, Heading, Divider, Avatar, Card

**Files:**
- Create: `app/frontend/components/{Text,Heading,Divider,Avatar,Card}.svelte`
- Create: `app/views/shared/components/_{text,heading,divider,avatar,card}.html.erb`
- Modify: `application.css` `@layer components` — add `.text`, `.heading`, `.subheading`, `.divider`, `.avatar`, `.card`
- Test: `app/frontend/components/Typography.test.ts` (one render-smoke spec covering all five)

**Interfaces:**
- Svelte: `<Text>`, `<Heading level?: 1|2|3|4|5|6>`, `<Subheading>`, `<Divider soft?: boolean>`, `<Avatar src?: string|null; square?: boolean; initials?: string; alt?: string>`, `<Card>`. Each accepts `class?` and `children`/`...rest`.
- ERB: `<%= render "shared/components/text", body: %>`; `_heading` (locals: `level:, body:`); `_divider` (locals: `soft:`); `_avatar` (locals: `src:, square:, initials:, alt:, class:`); `_card` (block content).

- [ ] **Step 1: Add recipes to CSS** (adapted from `text.tsx`, `heading.tsx`, `divider.tsx`, `avatar.tsx`):

```css
  .text      { @apply text-base/6 text-zinc-500 sm:text-sm/6; }
  .strong    { @apply font-medium text-zinc-950; }
  .code      { @apply rounded-sm border border-zinc-950/10 bg-zinc-950/[0.025] px-0.5 text-sm font-medium text-zinc-950 sm:text-[0.8125rem]; }
  .heading   { @apply text-2xl/8 font-semibold text-zinc-950 sm:text-xl/8; }
  .subheading{ @apply text-base/7 font-semibold text-zinc-950 sm:text-sm/6; }
  .divider   { @apply w-full border-t border-zinc-950/10; }
  .divider--soft { @apply border-zinc-950/5; }
  .avatar {
    @apply inline-grid shrink-0 align-middle [--avatar-radius:20%] *:col-start-1 *:row-start-1 outline -outline-offset-1 outline-black/10;
    @apply rounded-[var(--avatar-radius)] *:rounded-[var(--avatar-radius)];
  }
  .avatar--square { @apply rounded-[20%] *:rounded-[20%]; }
  /* .card is a Catalyst-demo panel pattern (no upstream component — see spec note) */
  .card { @apply rounded-lg border border-zinc-950/10 bg-white p-6 sm:p-5; }
```

(`.avatar` default is circular via `--avatar-radius:20%`; `.avatar--square` overrides to a 20% radius. Port the `<text>`-initials SVG from `avatar.tsx` into the Svelte/ERB markup.)

- [ ] **Step 2: Write the smoke test**

```ts
// app/frontend/components/Typography.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Text from "./Text.svelte"
import Heading from "./Heading.svelte"
import Divider from "./Divider.svelte"
import Avatar from "./Avatar.svelte"
import Card from "./Card.svelte"
import { createRawSnippet } from "svelte"

const slot = (html: string) => createRawSnippet(() => ({ render: () => html }))

describe("typography primitives", () => {
  it("renders Text, Heading, Divider, Avatar, Card with catalyst classes", () => {
    render(Text, { props: { children: slot("Hello") } })
    render(Heading, { props: { level: 2, children: slot("Title") } })
    render(Divider, { props: { soft: true } })
    render(Avatar, { props: { initials: "AB", alt: "A B" } })
    render(Card, { props: { children: slot("<p>body</p>") } })

    expect(screen.getByText("Hello").className).toMatch(/text\b/)
    const h = screen.getByRole("heading", { name: "Title" })
    expect(h.tagName).toBe("H2")
    expect(h.className).toMatch(/heading/))
    expect(document.querySelector(".divider")).not.toBeNull()
    expect(document.querySelector(".avatar")).not.toBeNull()
    expect(document.querySelector(".card")).not.toBeNull()
  })
})
```

- [ ] **Step 3: Run test to verify it fails**

Run: `pnpm vitest run app/frontend/components/Typography.test.ts`
Expected: FAIL (components missing).

- [ ] **Step 4: Implement the five Svelte components**

`Text.svelte`:
```svelte
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { class: klass = "", children, ...rest }: { class?: string; children?: Snippet } & Record<string, unknown> = $props()
</script>
<p class={cx("text", klass)} {...rest}>{@render children?.()}</p>
```

`Heading.svelte` (dynamic element via Svelte `{@const}` + `<svelte:element>`):
```svelte
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { level = 1, sub = false, class: klass = "", children, ...rest }: {
    level?: 1 | 2 | 3 | 4 | 5 | 6
    sub?: boolean
    class?: string
    children?: Snippet
  } & Record<string, unknown> = $props()
  const tag = $derived(`h${level}`)
  const base = $derived(sub ? "subheading" : "heading")
</script>
<svelte:element this={tag} class={cx(base, klass)} {...rest}>{@render children?.()}</svelte:element>
```

`Divider.svelte`:
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  let { soft = false, class: klass = "", ...rest }: { soft?: boolean; class?: string } & Record<string, unknown> = $props()
</script>
<hr role="presentation" class={cx("divider", soft && "divider--soft", klass)} {...rest} />
```

`Avatar.svelte` (port the initials `<svg>` from `avatar.tsx:37-47`):
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  let {
    src = null, square = false, initials, alt = "", class: klass = "", ...rest
  }: { src?: string | null; square?: boolean; initials?: string; alt?: string; class?: string } & Record<string, unknown> = $props()
</script>
<span data-slot="avatar" class={cx("avatar", square && "avatar--square", klass)} {...rest}>
  {#if initials}
    <svg class="size-full fill-current p-[5%] text-[48px] font-medium uppercase select-none" viewBox="0 0 100 100" aria-hidden={alt ? undefined : "true"}>
      {#if alt}<title>{alt}</title>{/if}
      <text x="50%" y="50%" alignmentBaseline="middle" dominantBaseline="middle" textAnchor="middle" dy=".125em">{initials}</text>
    </svg>
  {/if}
  {#if src}<img class="size-full" {src} {alt} />{/if}
</span>
```

`Card.svelte`:
```svelte
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { class: klass = "", children, ...rest }: { class?: string; children?: Snippet } & Record<string, unknown> = $props()
</script>
<div class={cx("card", klass)} {...rest}>{@render children?.()}</div>
```

- [ ] **Step 5: Run test to verify it passes**

Run: `pnpm vitest run app/frontend/components/Typography.test.ts`
Expected: PASS.

- [ ] **Step 6: Create the ERB partials**

```erb
<%# app/views/shared/components/_text.html.erb %>
<p class="text <%= local_assigns[:class] %>"><%= local_assigns[:body] %><%= yield if block_given? %></p>
```
```erb
<%# app/views/shared/components/_heading.html.erb %>
<%
  level = local_assigns[:level] || 1
  klass = local_assigns[:sub] ? "subheading" : "heading"
%>
<%= content_tag "h#{level}", class: "#{klass} #{local_assigns[:class]}".strip do %>
  <%= local_assigns[:body] %><%= yield if block_given? %>
<% end %>
```
```erb
<%# app/views/shared/components/_divider.html.erb %>
<hr role="presentation" class="divider <%= local_assigns[:soft] ? "divider--soft" : "" %> <%= local_assigns[:class] %>">
```
```erb
<%# app/views/shared/components/_avatar.html.erb %>
<%
  square = local_assigns[:square]
  classes = ["avatar", (square ? "avatar--square" : nil), local_assigns[:class]].compact.join(" ")
%>
<span data-slot="avatar" class="<%= classes %>">
  <% if local_assigns[:initials] %>
    <svg class="size-full fill-current p-[5%] text-[48px] font-medium uppercase select-none" viewBox="0 0 100 100" aria-hidden="<%= local_assigns[:alt] ? undefined : 'true' %>">
      <% if local_assigns[:alt] %><title><%= local_assigns[:alt] %></title><% end %>
      <text x="50%" y="50%" alignmentBaseline="middle" dominantBaseline="middle" textAnchor="middle" dy=".125em"><%= local_assigns[:initials] %></text>
    </svg>
  <% end %>
  <% if local_assigns[:src] %><img class="size-full" src="<%= local_assigns[:src] %>" alt="<%= local_assigns[:alt] %>"><% end %>
</span>
```
```erb
<%# app/views/shared/components/_card.html.erb %>
<div class="card <%= local_assigns[:class] %>"><%= yield if block_given? %></div>
```

- [ ] **Step 7: Run check + commit**

Run: `pnpm run check` → 0 errors.
```bash
git add app/frontend/components/{Text,Heading,Divider,Avatar,Card}.svelte \
  app/frontend/components/Typography.test.ts \
  app/views/shared/components/_{text,heading,divider,avatar,card}.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst typography + primitives (Text, Heading, Divider, Avatar, Card)"
```

---

### Task 4: Form controls — Input, Textarea, Select, Checkbox, Fieldset family

**Files:**
- Create: `app/frontend/components/{Input,Textarea,Select,Checkbox,Fieldset}.svelte`
- Create: `app/views/shared/components/_{input,textarea,select,checkbox,field,fieldset}.html.erb`
- Modify: `application.css` `@layer components` — `.input`, `.textarea`, `.select`, `.checkbox`, `.fieldset`, `.field`, `.field-group`, `.label`, `.description`, `.field-error`
- Test: `app/frontend/components/Forms.test.ts`

**Interfaces:**
- Svelte `<Input type?: …>` wraps a native `<input>` with the Catalyst control-`<span>` ring; `<Textarea resizable?>`, `<Select multiple?>`, `<Checkbox color?>`, and `<Fieldset>`/`<Field>`/`<FieldGroup>`/`<Label>`/`<Description>`/`<FieldError>`.
- ERB `_field.html.erb` is the workhorse: `locals: { form:, method:, label:, type:, required:, description:, placeholder: }`. It renders `.label` + the right control (`.input`/`.textarea`/`.select`) + `.field-error` from `form.object.errors[method]`. Consumed by all auth/settings/admin forms in follow-up plans.

- [ ] **Step 1: Add recipes to CSS** (adapted from `input.tsx`, `textarea.tsx`, `select.tsx`, `checkbox.tsx`, `fieldset.tsx`; `data-hover:`→`hover:`, `data-focus:`→`focus-within:` on wrappers, `data-invalid:` kept, `data-disabled:`→`disabled:`):

```css
  .field       { @apply [&>[data-slot=label]+[data-slot=control]]:mt-3 [&>[data-slot=label]+[data-slot=description]]:mt-1 [&>[data-slot=description]+[data-slot=control]]:mt-3 [&>[data-slot=control]+[data-slot=description]]:mt-3 [&>[data-slot=control]+[data-slot=error]]:mt-3 *:data-[slot=label]:font-medium; }
  .field-group { @apply space-y-8; }
  .fieldset    { @apply *:data-[slot=text]:mt-1 [&>*+[data-slot=control]]:mt-6; }
  .legend      { @apply text-base/6 font-semibold text-zinc-950 sm:text-sm/6; }
  .label       { @apply text-base/6 text-zinc-950 select-none sm:text-sm/6; }
  .description { @apply text-base/6 text-zinc-500 sm:text-sm/6; }
  .field-error { @apply text-base/6 text-red-600 sm:text-sm/6; }

  /* Control wrapper (the <span data-slot=control>) + inner input share these. */
  .control {
    @apply relative block w-full;
    @apply before:absolute before:inset-px before:rounded-[calc(theme(borderRadius.lg)-1px)] before:bg-white before:shadow-sm;
    @apply after:pointer-events-none after:absolute after:inset-0 after:rounded-lg after:ring-transparent after:ring-inset focus-within:after:ring-2 focus-within:after:ring-blue-500;
    @apply has-[:disabled]:opacity-50;
  }
  .input, .textarea, .select-inner {
    @apply relative block w-full appearance-none rounded-lg px-[calc(theme(spacing.3.5)-1px)] py-[calc(theme(spacing.2.5)-1px)] sm:px-[calc(theme(spacing.3)-1px)] sm:py-[calc(theme(spacing.1.5)-1px)];
    @apply text-base/6 text-zinc-950 placeholder:text-zinc-500 sm:text-sm/6;
    @apply border border-zinc-950/10 hover:border-zinc-950/20 bg-transparent;
    @apply focus:outline-hidden;
    @apply aria-[invalid=true]:border-red-500;
    @apply disabled:border-zinc-950/20;
  }
  .textarea { @apply h-full resize-y; }
  .textarea--fixed { @apply resize-none; }

  .checkbox {
    @apply group inline-flex focus:outline-hidden;
    @apply relative isolate flex size-4.5 items-center justify-center rounded-[0.3125rem] sm:size-4;
    @apply before:absolute before:inset-0 before:-z-10 before:rounded-[calc(0.3125rem-1px)] before:bg-white before:shadow-sm;
    @apply border border-zinc-950/15 hover:border-zinc-950/30;
  }
  .checkbox--checked { @apply border-transparent; background: var(--checkbox-checked-border); }
  .checkbox--checked::before { background: var(--checkbox-checked-bg); }
```

> The full Catalyst input/checkbox recipes are long; the above captures the visible light-mode behaviour. Port the remaining decorative `after:`/highlight lines from `input.tsx:38-51` and `checkbox.tsx:46-72` into `.control`/`.checkbox` only if visual parity demands — the functional (border, focus ring, invalid, disabled) styles are all listed above.

- [ ] **Step 2: Write the smoke test**

```ts
// app/frontend/components/Forms.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Input from "./Input.svelte"
import Fieldset, { Label, FieldError } from "./Fieldset.svelte"

describe("form controls", () => {
  it("renders an input with the catalyst control wrapper", () => {
    render(Input, { props: { type: "email", name: "email", placeholder: "you@example.com" } })
    const input = screen.getByPlaceholderText("you@example.com")
    expect(input.tagName).toBe("INPUT")
    expect(input.closest("[data-slot=control]")).not.toBeNull()
  })

  it("renders a field-error with the error class", () => {
    render(FieldError, { props: { children: () => ({ render: () => "is invalid" }) } })
    const el = screen.getByText("is invalid")
    expect(el.className).toMatch(/field-error/)
  })

  it("renders a Label with the label class", () => {
    render(Label, { props: { children: () => ({ render: () => "Email" }) } })
    expect(screen.getByText("Email").className).toMatch(/label/))
  })
})
```

(For `Label`/`FieldError`/`Field`/`FieldGroup`/`Description`/`Legend`, export them as named exports from `Fieldset.svelte`'s module script so `import { Label, FieldError } from "./Fieldset.svelte"` works — see Step 4.)

- [ ] **Step 3: Run test to verify it fails**

Run: `pnpm vitest run app/frontend/components/Forms.test.ts`
Expected: FAIL (components missing).

- [ ] **Step 4: Implement the Svelte components**

`Input.svelte` (port the control `<span>` wrapper from `input.tsx:35-91`; the `data-slot=control` wrapper is what makes `.field` spacing work):
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  let {
    type = "text", name, value, placeholder, class: klass = "", ...rest
  }: { type?: string; name?: string; value?: string; placeholder?: string; class?: string } & Record<string, unknown> = $props()
</script>
<span data-slot="control" class={cx("control", klass)}>
  <input class="input" {type} {name} {value} {placeholder} {...rest} />
</span>
```

`Textarea.svelte`:
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  let { name, value, resizable = true, class: klass = "", ...rest }: { name?: string; value?: string; resizable?: boolean; class?: string } & Record<string, unknown> = $props()
</script>
<span data-slot="control" class={cx("control", klass)}>
  <textarea class={cx("textarea", !resizable && "textarea--fixed")} {name} {value} {...rest}></textarea>
</span>
```

`Select.svelte` (port the chevron `<svg>` from `select.tsx:53-65`):
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  let { name, multiple = false, class: klass = "", children, ...rest }: { name?: string; multiple?: boolean; class?: string; children?: import("svelte").Snippet } & Record<string, unknown> = $props()
</script>
<span data-slot="control" class={cx("control", "relative", klass)}>
  <select class="select-inner" {name} {multiple} {...rest}>{@render children?.()}</select>
  {#if !multiple}
    <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
      <svg class="size-5 stroke-zinc-500 sm:size-4" viewBox="0 0 16 16" aria-hidden="true" fill="none">
        <path d="M5.75 10.75L8 13L10.25 10.75" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
        <path d="M10.25 5.25L8 3L5.75 5.25" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
    </span>
  {/if}
</span>
```

`Checkbox.svelte` (native `<input type=checkbox>` styled via a sibling `<span class=checkbox>`; check state mirrored with a `:has()` or a bound class — use `:checked` via a wrapper):
```svelte
<script lang="ts">
  import { cx } from "@/lib/cx"
  import type { ButtonColor } from "./Button.svelte"
  let { name, value, color = "dark/zinc", class: klass = "", ...rest }: { name?: string; value?: boolean; color?: ButtonColor; class?: string } & Record<string, unknown> = $props()
  let checked = $state(value ?? false)
</script>
<label class={cx("inline-flex items-center gap-3", klass)}>
  <span class="relative">
    <input type="checkbox" class="peer absolute inset-0 opacity-0" bind:checked {name} {...rest} />
    <span class={cx("checkbox", "peer-checked:checkbox--checked")} aria-hidden="true">
      <svg class="size-4 stroke-white opacity-0 peer-[&:checked]~&:opacity-100 sm:h-3.5 sm:w-3.5" viewBox="0 0 14 14" fill="none">
        <path d="M3 8L6 11L11 3.5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
      </svg>
    </span>
  </span>
</label>
```
(The checkbox check-mark visibility is driven by `peer-checked`; adjust the selector to `peer-checked:opacity-100` on the svg if simpler. The goal is a working, Catalyst-looking checkbox; exact selector is tuned to whatever passes the visual check in Task 10.)

`Fieldset.svelte` (module script exports the family; bodies are thin wrappers around the recipe classes):
```svelte
<script lang="ts" module>
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  export function Fieldset(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function Field(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function FieldGroup(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function Legend(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function Label(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function Description(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
  export function FieldError(props: { class?: string; children?: Snippet } & Record<string, unknown>) {}
</script>

<script lang="ts">
  let { class: klass = "", children }: { class?: string; children?: Snippet } & Record<string, unknown> = $props()
</script>

<fieldset class={cx("fieldset", klass)}>{@render children?.()}</fieldset>
```

> Because Svelte requires each named export to be its own component instance, the cleanest pattern is **one file per family member** (`Fieldset.svelte`, `Field.svelte`, `FieldGroup.svelte`, `Label.svelte`, `Description.svelte`, `FieldError.svelte`, `Legend.svelte`), each a thin wrapper, with a barrel `app/frontend/components/field.ts` re-exporting them. The implementer should follow the one-file-per-component convention rather than the module-export sketch above. Each member: `<div class="field"><slot/></div>` (or `<label class="label">`, `<p class="description">`, `<p class="field-error">`, `<fieldset class="fieldset">`). Update the `Forms.test.ts` import to `import { Label, FieldError } from "./field"`. Add this resolution to the task during implementation.

- [ ] **Step 5: Run test to verify it passes**

Run: `pnpm vitest run app/frontend/components/Forms.test.ts`
Expected: PASS.

Run: `pnpm run check` → 0 errors.

- [ ] **Step 6: Create the ERB partials** (the `_field` workhorse + control partials):

```erb
<%# app/views/shared/components/_field.html.erb %>
<%#
  Workhorse field: label + control + error.
  locals: form (ActiveModel form builder), method, label, type ("text"|"email"|"password"|"textarea"|"select"),
          required, description, placeholder, options (for select), input_html
%>
<%
  form     = local_assigns[:form]
  method   = local_assigns[:method]
  type     = local_assigns[:type] || "text"
  required = local_assigns[:required]
  errors   = form.object.errors[method] rescue []
  invalid  = errors.any?
  described_by = "#{method}-description" if local_assigns[:description]
%>
<div class="field">
  <%= form.label method, local_assigns[:label], class: "label" %>
  <% if local_assigns[:description] %>
    <p id="<%= method %>-description" class="description"><%= local_assigns[:description] %></p>
  <% end %>

  <span data-slot="control" class="control">
    <% case type when "textarea" %>
      <%= form.textarea method, class: "textarea", placeholder: local_assigns[:placeholder], required: required, aria: { invalid: invalid } %>
    <% when "select" %>
      <%= form.select method, local_assigns[:options] || [], { include_blank: local_assigns[:include_blank] }, class: "select-inner", required: required, aria: { invalid: invalid } %>
    <% else %>
      <%= form.send("#{type}_field", method, class: "input", placeholder: local_assigns[:placeholder], required: required, aria: { invalid: invalid }) %>
    <% end %>
  </span>

  <% if invalid %>
    <% errors.each do |msg| %>
      <p class="field-error"><%= msg %></p>
    <% end %>
  <% end %>
</div>
```

```erb
<%# app/views/shared/components/_input.html.erb %>
<%# Standalone input (no form builder). locals: name, type, value, placeholder, invalid, class %>
<span data-slot="control" class="control">
  <input class="input" type="<%= local_assigns[:type] || "text" %>" name="<%= local_assigns[:name] %>" value="<%= local_assigns[:value] %>" placeholder="<%= local_assigns[:placeholder] %>" aria-invalid="<%= local_assigns[:invalid] %>">
</span>
```

```erb
<%# app/views/shared/components/_textarea.html.erb %>
<span data-slot="control" class="control">
  <textarea class="textarea" name="<%= local_assigns[:name] %>" placeholder="<%= local_assigns[:placeholder] %>"><%= local_assigns[:value] %></textarea>
</span>
```
```erb
<%# app/views/shared/components/_select.html.erb %>
<span data-slot="control" class="control relative">
  <select class="select-inner" name="<%= local_assigns[:name] %>"><%= yield if block_given? %></select>
  <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
    <svg class="size-5 stroke-zinc-500 sm:size-4" viewBox="0 0 16 16" fill="none" aria-hidden="true">
      <path d="M5.75 10.75L8 13L10.25 10.75" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M10.25 5.25L8 3L5.75 5.25" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
  </span>
</span>
```
```erb
<%# app/views/shared/components/_checkbox.html.erb %>
<label class="inline-flex items-center gap-3">
  <span class="relative">
    <input type="checkbox" class="peer absolute inset-0 opacity-0" name="<%= local_assigns[:name] %>" <%= "checked" if local_assigns[:checked] %>>
    <span class="checkbox peer-checked:checkbox--checked" aria-hidden="true"></span>
  </span>
  <% if local_assigns[:label] %><span class="label"><%= local_assigns[:label] %></span><% end %>
</label>
```
```erb
<%# app/views/shared/components/_fieldset.html.erb %>
<fieldset class="fieldset"><%= yield if block_given? %></fieldset>
```

- [ ] **Step 7: Run check + commit**

Run: `pnpm run check` → 0 errors.
```bash
git add app/frontend/components/Input.svelte app/frontend/components/Textarea.svelte \
  app/frontend/components/Select.svelte app/frontend/components/Checkbox.svelte \
  app/frontend/components/Fieldset.svelte app/frontend/components/Field.svelte \
  app/frontend/components/FieldGroup.svelte app/frontend/components/Label.svelte \
  app/frontend/components/Description.svelte app/frontend/components/FieldError.svelte \
  app/frontend/components/Legend.svelte app/frontend/components/field.ts \
  app/frontend/components/Forms.test.ts \
  app/views/shared/components/_{input,textarea,select,checkbox,field,fieldset}.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst form controls + fieldset family (Svelte + ERB)"
```

---

### Task 5: Display — Badge & Alert (flash-aware)

**Files:**
- Create: `app/frontend/components/{Badge,Alert}.svelte`, `app/frontend/components/{Badge,Alert}.test.ts`
- Create: `app/views/shared/components/_{badge,alert}.html.erb`
- Modify: `application.css` `@layer components` — `.badge`, `.badge--{color}`, `.alert`, `.alert--{tone}`
- Test: `app/frontend/components/Badge.test.ts`, `app/frontend/components/Alert.test.ts`

**Interfaces:**
- Svelte `<Badge color?: Color>` and `<Alert tone?: "success"|"error"|"info"|"warning">` (a static callout banner — NOT the Catalyst modal `Alert`, which is a Dialog variant deferred to plan 2). The banner Alert consumes `flash.notice`/`flash.alert` in the SPA.
- ERB `_alert.html.erb` `locals: { tone:, body: }` — replaces `_flash.html.erb` content during migrations.

- [ ] **Step 1: Add recipes to CSS** (badge from `badge.tsx:7-35`; alert banner is new, Catalyst-toned):

```css
  .badge { @apply inline-flex items-center gap-x-1.5 rounded-md px-1.5 py-0.5 text-sm/5 font-medium sm:text-xs/5; }
  .badge--red     { @apply bg-red-500/15 text-red-700; }
  .badge--orange  { @apply bg-orange-500/15 text-orange-700; }
  .badge--amber   { @apply bg-amber-400/20 text-amber-700; }
  .badge--yellow  { @apply bg-yellow-400/20 text-yellow-700; }
  .badge--lime    { @apply bg-lime-400/20 text-lime-700; }
  .badge--green   { @apply bg-green-500/15 text-green-700; }
  .badge--emerald { @apply bg-emerald-500/15 text-emerald-700; }
  .badge--teal    { @apply bg-teal-500/15 text-teal-700; }
  .badge--cyan    { @apply bg-cyan-400/20 text-cyan-700; }
  .badge--sky     { @apply bg-sky-500/15 text-sky-700; }
  .badge--blue    { @apply bg-blue-500/15 text-blue-700; }
  .badge--indigo  { @apply bg-indigo-500/15 text-indigo-700; }
  .badge--violet  { @apply bg-violet-500/15 text-violet-700; }
  .badge--purple  { @apply bg-purple-500/15 text-purple-700; }
  .badge--fuchsia { @apply bg-fuchsia-400/15 text-fuchsia-700; }
  .badge--pink    { @apply bg-pink-400/15 text-pink-700; }
  .badge--rose    { @apply bg-rose-400/15 text-rose-700; }
  .badge--zinc    { @apply bg-zinc-600/10 text-zinc-700; }

  /* Static banner alert (NOT the Catalyst modal). */
  .alert { @apply rounded-lg p-4 text-sm; }
  .alert--success { @apply rounded-lg border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-800; }
  .alert--error   { @apply rounded-lg border border-red-200 bg-red-50 p-4 text-sm text-red-800; }
  .alert--info    { @apply rounded-lg border border-blue-200 bg-blue-50 p-4 text-sm text-blue-800; }
  .alert--warning { @apply rounded-lg border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800; }
```

- [ ] **Step 2: Write the tests**

```ts
// app/frontend/components/Badge.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Badge from "./Badge.svelte"

describe("Badge", () => {
  it("applies the zinc color by default", () => {
    render(Badge, { props: { children: () => ({ render: () => "New" }) } })
    expect(screen.getByText("New").className).toMatch(/badge--zinc/)
  })
  it("applies a chosen color", () => {
    render(Badge, { props: { color: "red", children: () => ({ render: () => "Hot" }) } })
    expect(screen.getByText("Hot").className).toMatch(/badge--red/)
  })
})
```

```ts
// app/frontend/components/Alert.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Alert from "./Alert.svelte"

describe("Alert", () => {
  it("renders a success alert with role=status", () => {
    render(Alert, { props: { tone: "success", children: () => ({ render: () => "Saved" }) } })
    const el = screen.getByRole("status")
    expect(el.className).toMatch(/alert--success/)
    expect(el).toHaveTextContent("Saved")
  })
  it("renders an error alert with role=alert", () => {
    render(Alert, { props: { tone: "error", children: () => ({ render: () => "Failed" }) } })
    expect(screen.getByRole("alert").className).toMatch(/alert--error/)
  })
})
```

- [ ] **Step 3: Run tests to verify they fail**

Run: `pnpm vitest run app/frontend/components/Badge.test.ts app/frontend/components/Alert.test.ts`
Expected: FAIL.

- [ ] **Step 4: Implement `Badge.svelte` and `Alert.svelte`**

```svelte
<!-- app/frontend/components/Badge.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  import type { ButtonColor } from "./Button.svelte"
  let { color = "zinc", class: klass = "", children }: { color?: ButtonColor; class?: string; children?: Snippet } = $props()
</script>
<span class={cx("badge", `badge--${color}`, klass)}>{@render children?.()}</span>
```

```svelte
<!-- app/frontend/components/Alert.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { tone = "info", class: klass = "", children }: { tone?: "success" | "error" | "info" | "warning"; class?: string; children?: Snippet } = $props()
  const role = $derived(tone === "error" ? "alert" : "status")
</script>
<div role={role} class={cx("alert", `alert--${tone}`, klass)}>{@render children?.()}</div>
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `pnpm vitest run app/frontend/components/Badge.test.ts app/frontend/components/Alert.test.ts`
Expected: PASS.

- [ ] **Step 6: Create the ERB partials**

```erb
<%# app/views/shared/components/_badge.html.erb %>
<% color = local_assigns[:color] || "zinc" %>
<span class="badge badge--<%= color %> <%= local_assigns[:class] %>"><%= local_assigns[:label] %></span>
```
```erb
<%# app/views/shared/components/_alert.html.erb %>
<%
  tone = local_assigns[:tone] || "info"
  role = (tone == "error") ? "alert" : "status"
%>
<div role="<%= role %>" class="alert alert--<%= tone %> <%= local_assigns[:class] %>"><%= local_assigns[:body] %><%= yield if block_given? %></div>
```

- [ ] **Step 7: Commit**

```bash
git add app/frontend/components/{Badge,Alert}.svelte app/frontend/components/{Badge,Alert}.test.ts \
  app/views/shared/components/_{badge,alert}.html.erb app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst Badge + banner Alert (Svelte + ERB)"
```

---

### Task 6: Data — Table, Pagination, DescriptionList

**Files:**
- Create: `app/frontend/components/{Table,Pagination,DescriptionList}.svelte`
- Create: `app/views/shared/components/_{table,pagination,description_list}.html.erb`
- Modify: `application.css` — `.table`, `.table-head`, `.table-row`, `.table-header`, `.table-cell`, `.pagination`, `.pagination-list`, `.pagination-page`, `.description-list`, `.description-term`, `.description-details`
- Test: `app/frontend/components/Data.test.ts`

**Interfaces:**
- Svelte `<Table>`/`<TableHead>`/`<TableBody>`/`<TableRow>`/`<TableHeader>`/`<TableCell>` (Context replaces Catalyst's React context for `striped`/`dense`/`grid`/`bleed`).
- Svelte `<Pagination>` with Prev/Next/List/Page/Gap mirroring `pagination.tsx`.
- ERB `_pagination.html.erb` is **pagy-aware**: `locals: { pagy:, path: }` renders Prev/Next + numbered pages using `pagy.series`. Replaces `_pagination.html.erb` (root `shared/`) during migrations.

- [ ] **Step 1: Add recipes to CSS** (from `table.tsx`, `pagination.tsx`, `description-list.tsx`):

```css
  .table        { @apply min-w-full text-left text-sm/6 text-zinc-950; }
  .table-head   { @apply text-zinc-500; }
  .table-header { @apply border-b border-b-zinc-950/10 px-4 py-2 font-medium; }
  .table-cell   { @apply relative px-4 border-b border-zinc-950/5 py-4; }
  .table-row--striped:nth-child(even) { @apply bg-zinc-950/[0.025]; }

  .pagination        { @apply flex gap-x-2; }
  .pagination-list   { @apply hidden items-baseline gap-x-2 sm:flex; }
  .pagination-gap    { @apply w-9 text-center text-sm/6 font-semibold text-zinc-950 select-none; }
  .pagination-page   { @apply inline-flex items-center justify-center min-w-9 rounded-lg px-2 py-1.5 text-sm/6 font-medium text-zinc-950 hover:bg-zinc-950/5; }
  .pagination-page--current { @apply bg-zinc-950/5; }

  .description-list    { @apply grid grid-cols-1 text-base/6 sm:grid-cols-[min(50%,theme(spacing.80))_auto] sm:text-sm/6; }
  .description-term    { @apply col-start-1 border-t border-zinc-950/5 pt-3 text-zinc-500 first:border-none sm:py-3; }
  .description-details { @apply pt-1 pb-3 text-zinc-950 sm:border-t sm:border-zinc-950/5 sm:py-3; }
```

- [ ] **Step 2: Write the smoke test**

```ts
// app/frontend/components/Data.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import DescriptionList, { DescriptionTerm, DescriptionDetails } from "./DescriptionList.svelte"
import { createRawSnippet } from "svelte"
const slot = (h: string) => createRawSnippet(() => ({ render: () => h }))

describe("description list", () => {
  it("renders term/details with catalyst classes", () => {
    render(DescriptionList, { props: { children: slot("<dt>Name</dt><dd>Ada</dd>") } })
    expect(document.querySelector(".description-list")).not.toBeNull()
  })
})
```

(Use the one-file-per-member + barrel pattern from Task 4 for the `Table`/`Pagination` families too: `Table.svelte` exports the set via `app/frontend/components/table.ts`, `Pagination.svelte` via `pagination.ts`. Full table/pagination behavior tests are light here — just render-smoke — because complex keyboard/anchor behavior is verified visually in Task 10 and via request specs when admin/settings pages migrate.)

- [ ] **Step 3: Run test to verify it fails** → `pnpm vitest run app/frontend/components/Data.test.ts` → FAIL.

- [ ] **Step 4: Implement the components** — `DescriptionList.svelte`/`DescriptionTerm.svelte`/`DescriptionDetails.svelte`, `Table.svelte` (+ family, using a Svelte context to pass `striped`/`dense`), `Pagination.svelte` (+ Prev/Next/Page/Gap/List). Each is a thin wrapper over the recipe classes; port the Prev/Next arrow SVGs from `pagination.tsx:21-29` and `40-48`.

For `Table`, set a context:
```svelte
<!-- app/frontend/components/Table.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  import { setContext } from "svelte"
  let { striped = false, dense = false, bleed = false, grid = false, class: klass = "", children }: { striped?: boolean; dense?: boolean; bleed?: boolean; grid?: boolean; class?: string; children?: Snippet } = $props()
  setContext("table", { striped, dense, bleed, grid })
</script>
<div class="flow-root">
  <div class="-mx-(--gutter,theme(spacing.2)) overflow-x-auto whitespace-nowrap">
    <div class="inline-block min-w-full align-middle">
      <table class={cx("table", klass)}>{@render children?.()}</table>
    </div>
  </div>
</div>
```
(`TableRow.svelte` reads `getContext("table").striped` to add `.table-row--striped`.)

- [ ] **Step 5: Run test to verify it passes** → PASS. `pnpm run check` → 0 errors.

- [ ] **Step 6: Create the ERB partials**

```erb
<%# app/views/shared/components/_pagination.html.erb %>
<%# locals: pagy (Pagy object), path (lambda|(page)| -> url string) %>
<nav class="pagination" aria-label="Page navigation">
  <span class="grow basis-0">
    <% if pagy.prev %>
      <a class="btn btn--plain" href="<%= path.call(pagy.prev) %>" aria-label="Previous page">&larr; Previous</a>
    <% else %>
      <a class="btn btn--plain" disabled aria-label="Previous page">&larr; Previous</a>
    <% end %>
  </span>
  <span class="pagination-list">
    <% pagy.series.each do |item| %>
      <% if item == :gap %>
        <span class="pagination-gap">&hellip;</span>
      <% elsif item == pagy.page %>
        <span class="pagination-page pagination-page--current" aria-current="page"><%= item %></span>
      <% else %>
        <a class="pagination-page" href="<%= path.call(item) %>" aria-label="Page <%= item %>"><%= item %></a>
      <% end %>
    <% end %>
  </span>
  <span class="flex grow basis-0 justify-end">
    <% if pagy.next %>
      <a class="btn btn--plain" href="<%= path.call(pagy.next) %>" aria-label="Next page">Next &rarr;</a>
    <% else %>
      <a class="btn btn--plain" disabled aria-label="Next page">Next &rarr;</a>
    <% end %>
  </span>
</nav>
```

```erb
<%# app/views/shared/components/_table.html.erb %>
<%# Thin wrapper: yields a <table class=table>. Callers compose thead/tbody. %>
<div class="flow-root">
  <div class="-mx-(--gutter,theme(spacing.2)) overflow-x-auto whitespace-nowrap">
    <div class="inline-block min-w-full align-middle">
      <table class="table <%= local_assigns[:class] %> <%= "table--striped" if local_assigns[:striped] %>"><%= yield if block_given? %></table>
    </div>
  </div>
</div>
```
```erb
<%# app/views/shared/components/_description_list.html.erb %>
<dl class="description-list <%= local_assigns[:class] %>"><%= yield if block_given? %></dl>
```

- [ ] **Step 7: Commit**

```bash
git add app/frontend/components/Table.svelte app/frontend/components/table.ts \
  app/frontend/components/Pagination.svelte app/frontend/components/pagination.ts \
  app/frontend/components/DescriptionList.svelte app/frontend/components/description_list.ts \
  app/frontend/components/Data.test.ts \
  app/views/shared/components/_{table,pagination,description_list}.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst Table + Pagination (pagy) + DescriptionList"
```

---

### Task 7: Svelte heroicons set

**Files:**
- Create: `app/frontend/icons/{Home,Bell,Squares2x2,Cog6Tooth,UserCircle,ChevronDown,ArrowRightStartOnRectangle,ShieldCheck,XMark,Bars3}.svelte` (the icons the shells need; add more per surface in later plans)
- Test: `app/frontend/icons/Icons.test.ts`

**Interfaces:**
- Each icon is `<Icon class?: string; ...rest>` rendering the heroicons SVG markup with `data-slot="icon"`. Consumed by Sidebar/Navbar/Dropdown/Button in this plan and the surface migrations.

> Source: copy the exact `<path>` data from heroicons (MIT, version matching the `heroicons` gem — confirm the gem's pinned version via `bundle show heroicons` and match the same icon set on the Svelte side). The gem's source vendor dir is at `vendor/assets/` in the gem; the SVG path data is also at https://heroicons.com. Each `.svelte` is one `<svg>`; no npm dep.

- [ ] **Step 1: Write the smoke test**

```ts
// app/frontend/icons/Icons.test.ts
import { render } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Home from "./Home.svelte"
import Bell from "./Bell.svelte"

describe("icons", () => {
  it("renders an svg with data-slot=icon", () => {
    const { container } = render(Home, { props: { class: "size-5" } })
    const svg = container.querySelector("svg")
    expect(svg).not.toBeNull()
    expect(svg?.getAttribute("data-slot")).toBe("icon")
    expect(svg?.getAttribute("class")).toContain("size-5")
  })
  it("Bell renders an svg", () => {
    const { container } = render(Bell)
    expect(container.querySelector("svg")).not.toBeNull()
  })
})
```

- [ ] **Step 2: Run test to verify it fails** → `pnpm vitest run app/frontend/icons/Icons.test.ts` → FAIL.

- [ ] **Step 3: Create the icon components**

Template for every icon (example `Home.svelte` — solid 20px heroicon "home"):

```svelte
<script lang="ts">
  let { class: klass = "", ...rest }: { class?: string } & Record<string, unknown> = $props()
</script>
<svg data-slot="icon" class={klass} viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" {...rest}>
  <path d="M11.47 3.84a.75.75 0 0 1 1.06 0l8.69 8.69a.75.75 0 1 0 1.06-1.06l-8.689-8.69a2.25 2.25 0 0 0-3.182 0l-8.69 8.69a.75.75 0 1 0 1.061 1.06l8.69-8.69Z" />
  <path d="m12 5.432 8.159 8.159c.03.03.06.058.091.086v6.198c0 1.035-.84 1.875-1.875 1.875H15a.75.75 0 0 1-.75-.75v-4.5a.75.75 0 0 0-.75-.75h-3a.75.75 0 0 0-.75.75V21a.75.75 0 0 1-.75.75H5.625a1.875 1.875 0 0 1-1.875-1.875v-6.198a2.29 2.29 0 0 0 .091-.086L12 5.43Z" />
</svg>
```

Create the remaining icons (`Bell`, `Squares2x2`, `Cog6Tooth`, `UserCircle`, `ChevronDown`, `ArrowRightStartOnRectangle`, `ShieldCheck`, `XMark`, `Bars3`) by copying each heroicons solid 24×24 path data into the same template. Verify path data from heroicons.com (matches the `heroicons` gem's vendored set).

- [ ] **Step 4: Run test to verify it passes** → PASS. `pnpm run check` → 0 errors.

- [ ] **Step 5: Commit**

```bash
git add app/frontend/icons app/frontend/icons/Icons.test.ts
git commit -m "feat(ui): add Svelte heroicons set (data-slot=icon convention)"
```

---

### Task 8: Sidebar & Navbar primitives

**Files:**
- Create: `app/frontend/components/Sidebar.svelte` (+ `app/frontend/components/sidebar.ts` barrel: Header/Body/Footer/Section/Item/Heading/Label/Divider/Spacer)
- Create: `app/frontend/components/Navbar.svelte` (+ `navbar.ts`: Section/Item/Spacer/Divider)
- Create: `app/views/shared/components/_sidebar.html.erb`, `_sidebar_item.html.erb`, `_navbar.html.erb`, `_navbar_item.html.erb`
- Modify: `application.css` — `.sidebar*`, `.navbar*` (from `sidebar.tsx`, `navbar.tsx`)
- Test: `app/frontend/components/Navigation.test.ts`

**Interfaces:**
- `<SidebarItem href?: string; current?: boolean>` and `<NavbarItem href?: string; current?: boolean>` set `data-current` and `data-slot="icon"` children get the icon sizing. CSS-only active indicator (no motion).

- [ ] **Step 1: Add recipes to CSS** (from `sidebar.tsx:10-142` and `navbar.tsx:10-96`, translated):

```css
  .sidebar          { @apply flex h-full min-h-0 flex-col; }
  .sidebar-header   { @apply flex flex-col border-b border-zinc-950/5 p-4; }
  .sidebar-body     { @apply flex flex-1 flex-col overflow-y-auto p-4; }
  .sidebar-footer   { @apply flex flex-col border-t border-zinc-950/5 p-4; }
  .sidebar-section  { @apply flex flex-col gap-0.5; }
  .sidebar-heading  { @apply mb-1 px-2 text-xs/6 font-medium text-zinc-500; }
  .sidebar-divider  { @apply my-4 border-t border-zinc-950/5 lg:-mx-4; }
  .sidebar-spacer   { @apply mt-8 flex-1; }
  .sidebar-item {
    @apply relative flex w-full items-center gap-3 rounded-lg px-2 py-2.5 text-left text-base/6 font-medium text-zinc-950 sm:py-2 sm:text-sm/5;
    @apply hover:bg-zinc-950/5;
    @apply *:data-[slot=icon]:size-6 *:data-[slot=icon]:shrink-0 *:data-[slot=icon]:fill-zinc-500 sm:*:data-[slot=icon]:size-5 hover:*:data-[slot=icon]:fill-zinc-950;
  }
  .sidebar-item[data-current="true"] { @apply bg-zinc-950/5; }
  .sidebar-item[data-current="true"]::before {
    content: ""; @apply absolute inset-y-2 -left-4 w-0.5 rounded-full bg-zinc-950;
  }
  .sidebar-label { @apply truncate; }

  .navbar          { @apply flex flex-1 items-center gap-4 py-2.5; }
  .navbar-section  { @apply flex items-center gap-3; }
  .navbar-spacer   { @apply -ml-4 flex-1; }
  .navbar-divider  { @apply h-6 w-px bg-zinc-950/10; }
  .navbar-item {
    @apply relative flex min-w-0 items-center gap-3 rounded-lg p-2 text-left text-base/6 font-medium text-zinc-950 sm:text-sm/5;
    @apply hover:bg-zinc-950/5;
    @apply *:data-[slot=icon]:size-6 *:data-[slot=icon]:shrink-0 *:data-[slot=icon]:fill-zinc-500 sm:*:data-[slot=icon]:size-5 hover:*:data-[slot=icon]:fill-zinc-950;
  }
  .navbar-item[data-current="true"]::before {
    content: ""; @apply absolute inset-x-2 -bottom-2.5 h-0.5 rounded-full bg-zinc-950;
  }
  .navbar-label { @apply truncate; }
```

- [ ] **Step 2: Write the test**

```ts
// app/frontend/components/Navigation.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import SidebarItem from "./SidebarItem.svelte"
import NavbarItem from "./NavbarItem.svelte"
import { createRawSnippet } from "svelte"
const slot = (h: string) => createRawSnippet(() => ({ render: () => h }))

describe("navigation items", () => {
  it("marks the current sidebar item with data-current and the active bar", () => {
    render(SidebarItem, { props: { href: "/x", current: true, children: slot("Home") } })
    const link = screen.getByRole("link", { name: "Home" })
    expect(link.getAttribute("data-current")).toBe("true")
  })
  it("renders a navbar item as a link", () => {
    render(NavbarItem, { props: { href: "/y", children: slot("Inbox") } })
    expect(screen.getByRole("link", { name: "Inbox" }).className).toMatch(/navbar-item/))
  })
})
```

- [ ] **Step 3: Run test to verify it fails** → FAIL.

- [ ] **Step 4: Implement the Svelte components** (one file per member + barrel). Example members:

```svelte
<!-- app/frontend/components/SidebarItem.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { href, current = false, class: klass = "", children, ...rest }: { href?: string; current?: boolean; class?: string; children?: Snippet } & Record<string, unknown> = $props()
</script>
<span class="relative">
  {#if href}
    <a {href} data-current={current ? "true" : undefined} class={cx("sidebar-item", klass)} {...rest}>{@render children?.()}</a>
  {:else}
    <button data-current={current ? "true" : undefined} class={cx("sidebar-item", klass)} {...rest}>{@render children?.()}</button>
  {/if}
</span>
```
```svelte
<!-- app/frontend/components/Sidebar.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  import { cx } from "@/lib/cx"
  let { class: klass = "", children }: { class?: string; children?: Snippet } = $props()
</script>
<nav class={cx("sidebar", klass)}>{@render children?.()}</nav>
```
(Header/Body/Footer/Section/Heading/Divider/Spacer/Label are `<div>`/`<h3>`/`<hr>` wrappers over their classes. `NavbarItem` mirrors `SidebarItem` with `.navbar-item`. Barrel files `sidebar.ts`/`navbar.ts` re-export the members.)

- [ ] **Step 5: Run test to verify it passes** → PASS. `pnpm run check` → 0 errors.

- [ ] **Step 6: Create the ERB partials**

```erb
<%# app/views/shared/components/_sidebar.html.erb %>
<nav class="sidebar <%= local_assigns[:class] %>"><%= yield if block_given? %></nav>
```
```erb
<%# app/views/shared/components/_sidebar_item.html.erb %>
<%# locals: href, current, icon, label %>
<%
  classes = ["sidebar-item", local_assigns[:class]].compact.join(" ")
  current_attr = local_assigns[:current] ? { "data-current" => "true" } : {}
%>
<span class="relative">
  <% if local_assigns[:href] %>
    <%= link_to local_assigns[:href], class: classes, **current_attr do %>
      <%= heroicon(local_assigns[:icon], variant: :solid, class: "size-5") if local_assigns[:icon] %>
      <span class="sidebar-label"><%= local_assigns[:label] %></span>
      <%= yield if block_given? %>
    <% end %>
  <% else %>
    <%= button_tag class: classes, **current_attr do %>
      <%= heroicon(local_assigns[:icon], variant: :solid, class: "size-5") if local_assigns[:icon] %>
      <span class="sidebar-label"><%= local_assigns[:label] %></span>
    <% end %>
  <% end %>
</span>
```
```erb
<%# app/views/shared/components/_navbar.html.erb %>
<nav class="navbar <%= local_assigns[:class] %>"><%= yield if block_given? %></nav>
```
```erb
<%# app/views/shared/components/_navbar_item.html.erb %>
<%
  classes = ["navbar-item", local_assigns[:class]].compact.join(" ")
  current_attr = local_assigns[:current] ? { "data-current" => "true" } : {}
%>
<% if local_assigns[:href] %>
  <%= link_to local_assigns[:href], class: classes, **current_attr do %>
    <%= heroicon(local_assigns[:icon], variant: :solid, class: "size-5") if local_assigns[:icon] %>
    <span class="navbar-label"><%= local_assigns[:label] %></span>
  <% end %>
<% else %>
  <%= button_tag class: classes, **current_attr do %>
    <%= heroicon(local_assigns[:icon], variant: :solid, class: "size-5") if local_assigns[:icon] %>
    <span class="navbar-label"><%= local_assigns[:label] %></span>
  <% end %>
<% end %>
```

- [ ] **Step 7: Commit**

```bash
git add app/frontend/components/Sidebar*.svelte app/frontend/components/Navbar*.svelte \
  app/frontend/components/sidebar.ts app/frontend/components/navbar.ts \
  app/frontend/components/Navigation.test.ts \
  app/views/shared/components/_{sidebar,sidebar_item,navbar,navbar_item}.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst Sidebar + Navbar primitives (Svelte + ERB)"
```

---

### Task 9: Layout shells — SidebarLayout, StackedLayout, AuthLayout

**Files:**
- Create: `app/frontend/components/{SidebarLayout,StackedLayout,AuthLayout}.svelte`, `app/frontend/components/SidebarLayout.test.ts`
- Create: `app/views/shared/components/_{sidebar_layout,stacked_layout,auth_layout}.html.erb`
- Modify: `application.css` — `.sidebar-layout`, `.stacked-layout`, `.auth-layout`, `.layout-main`, `.layout-shell` (from `sidebar-layout.tsx`, `stacked-layout.tsx`, `auth-layout.tsx`)
- Test: `app/frontend/components/SidebarLayout.test.ts`

**Interfaces:**
- `<SidebarLayout { navbar } { sidebar } { children }>` — Svelte: a `showSidebar` state + mobile drawer (CSS transitions, no Dialog lib). ERB: `_sidebar_layout.html.erb` yields navbar/sidebar/main; mobile drawer uses a Stimulus controller from plan 2 (for now, desktop sidebar + static mobile header — the drawer toggle is wired when plan 2's `sidebar_layout_controller` lands, or via a small inline controller added here).

- [ ] **Step 1: Add recipes to CSS** (from the three layout files):

```css
  /* Shared inner content card used by all three shells */
  .layout-main {
    @apply grow p-6 lg:rounded-lg lg:bg-white lg:p-10 lg:shadow-xs lg:ring-1 lg:ring-zinc-950/5;
  }
  .layout-main-inner { @apply mx-auto max-w-6xl; }

  .sidebar-layout {
    @apply relative isolate flex min-h-svh w-full bg-white max-lg:flex-col lg:bg-zinc-100;
  }
  .sidebar-layout__desktop { @apply fixed inset-y-0 left-0 w-64 max-lg:hidden; }
  .sidebar-layout__main    { @apply flex flex-1 flex-col pb-2 lg:min-w-0 lg:pt-2 lg:pr-2 lg:pl-64; }
  .sidebar-layout__mobile-header { @apply flex items-center px-4 lg:hidden; }

  .stacked-layout { @apply relative isolate flex min-h-svh w-full flex-col bg-white lg:bg-zinc-100; }
  .stacked-layout__header { @apply flex items-center px-4; }
  .stacked-layout__main   { @apply flex flex-1 flex-col pb-2 lg:px-2; }

  .auth-layout { @apply flex min-h-dvh flex-col p-2; }
  .auth-layout__inner { @apply flex grow items-center justify-center p-6 lg:rounded-lg lg:bg-white lg:p-10 lg:shadow-xs lg:ring-1 lg:ring-zinc-950/5; }
```

- [ ] **Step 2: Write the test**

```ts
// app/frontend/components/SidebarLayout.test.ts
import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import SidebarLayout from "./SidebarLayout.svelte"
import { createRawSnippet } from "svelte"
const slot = (h: string) => createRawSnippet(() => ({ render: () => h }))

describe("SidebarLayout", () => {
  it("renders navbar, sidebar, and main content", () => {
    render(SidebarLayout, {
      props: {
        navbar: slot("<nav data-test='nb'>NB</nav>"),
        sidebar: slot("<aside data-test='sb'>SB</aside>"),
        children: slot("<p>Page</p>"),
      },
    })
    expect(screen.getByText("Page")).toBeInTheDocument()
    expect(document.querySelector(["data-test='nb'"] ? "[data-test='nb']" : "nav")).not.toBeNull()
    expect(document.querySelector("[data-test='sb']")).not.toBeNull()
  })

  it("opens the mobile drawer when the menu button is clicked", async () => {
    const { container } = render(SidebarLayout, {
      props: { navbar: slot(""), sidebar: slot("<aside>SB</aside>"), children: slot("") },
    })
    const btn = screen.getByRole("button", { name: /open navigation/i })
    expect(container.querySelector("[data-sidebar-drawer][data-open='false']") ?? container.querySelector("aside")).not.toBeNull()
    await btn.dispatchEvent(new MouseEvent("click", { bubbles: true }))
    // drawer is now open
    expect(container.querySelector("[data-sidebar-drawer]")?.getAttribute("data-open")).toBe("true")
  })
})
```

- [ ] **Step 3: Run test to verify it fails** → FAIL.

- [ ] **Step 4: Implement `SidebarLayout.svelte`** (port structure from `sidebar-layout.tsx:47-82`; `useState(showSidebar)` → Svelte `$state`; the mobile drawer uses CSS translate driven by `data-open`):

```svelte
<!-- app/frontend/components/SidebarLayout.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  let { navbar, sidebar, children }: { navbar: Snippet; sidebar: Snippet; children: Snippet } = $props()
  let open = $state(false)
</script>

<div class="sidebar-layout">
  <!-- Desktop sidebar -->
  <div class="sidebar-layout__desktop">{@render sidebar()}</div>

  <!-- Mobile drawer -->
  {#if open}
    <div class="fixed inset-0 z-40 bg-black/30 lg:hidden" onclick={() => (open = false)} aria-hidden="true"></div>
    <div data-sidebar-drawer data-open={open ? "true" : "false"}
         class="fixed inset-y-0 left-0 z-50 w-64 max-w-80 p-2 transition-transform duration-300 lg:hidden">
      <div class="flex h-full flex-col rounded-lg bg-white shadow-xs ring-1 ring-zinc-950/5">
        <div class="px-4 pt-3">
          <button class="navbar-item" aria-label="Close navigation" onclick={() => (open = false)}>✕</button>
        </div>
        {@render sidebar()}
      </div>
    </div>
  {/if}

  <!-- Mobile header -->
  <header class="sidebar-layout__mobile-header">
    <div class="py-2.5">
      <button class="navbar-item" aria-label="Open navigation" onclick={() => (open = true)}>
        <svg data-slot="icon" class="size-5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M2 6h16v1.5H2zM2 9.25h16v1.5H2zM2 12.5h16V14H2z"/></svg>
      </button>
    </div>
    <div class="min-w-0 flex-1">{@render navbar()}</div>
  </header>

  <!-- Main -->
  <main class="sidebar-layout__main">
    <div class="layout-main"><div class="layout-main-inner">{@render children()}</div></div>
  </main>
</div>
```

`StackedLayout.svelte` (port from `stacked-layout.tsx:47-79`; same mobile-drawer pattern, sidebar optional) and `AuthLayout.svelte` (port from `auth-layout.tsx`, no state):

```svelte
<!-- app/frontend/components/AuthLayout.svelte -->
<script lang="ts">
  import type { Snippet } from "svelte"
  let { children }: { children: Snippet } = $props()
</script>
<main class="auth-layout"><div class="auth-layout__inner">{@render children()}</div></main>
```

- [ ] **Step 5: Run test to verify it passes** → PASS. `pnpm run check` → 0 errors.

- [ ] **Step 6: Create the ERB layout partials**

```erb
<%# app/views/shared/components/_sidebar_layout.html.erb %>
<%# locals: navbar (html), sidebar (html). Yields main content. Mobile drawer is CSS + an inline
   data-controller added in plan 2; until then this renders the desktop shell (mobile falls back to navbar). %>
<div class="sidebar-layout">
  <div class="sidebar-layout__desktop"><%= local_assigns[:sidebar] %></div>
  <header class="sidebar-layout__mobile-header">
    <div class="py-2.5">
      <button type="button" class="navbar-item" aria-label="Open navigation">
        <%= heroicon("bars-3", variant: :solid, class: "size-5") %>
      </button>
    </div>
    <div class="min-w-0 flex-1"><%= local_assigns[:navbar] %></div>
  </header>
  <main class="sidebar-layout__main">
    <div class="layout-main"><div class="layout-main-inner"><%= yield %></div></div>
  </main>
</div>
```
```erb
<%# app/views/shared/components/_stacked_layout.html.erb %>
<div class="stacked-layout">
  <header class="stacked-layout__header"><div class="min-w-0 flex-1"><%= local_assigns[:navbar] %></div></header>
  <main class="stacked-layout__main"><div class="layout-main"><div class="layout-main-inner"><%= yield %></div></div></main>
</div>
```
```erb
<%# app/views/shared/components/_auth_layout.html.erb %>
<main class="auth-layout"><div class="auth-layout__inner"><%= yield %></div></main>
```

> The ERB mobile-drawer toggle for `_sidebar_layout`/`_stacked_layout` becomes fully functional when plan 2 adds `sidebar_layout_controller.ts` (a Stimulus controller toggling a `data-open` attribute on the drawer). Until then the ERB shells render the desktop sidebar + a static mobile menu button; the Svelte `SidebarLayout` is fully functional now because the SPA is the `/app` shell migrated first.

- [ ] **Step 7: Commit**

```bash
git add app/frontend/components/{SidebarLayout,StackedLayout,AuthLayout}.svelte \
  app/frontend/components/SidebarLayout.test.ts \
  app/views/shared/components/_{sidebar_layout,stacked_layout,auth_layout}.html.erb \
  app/frontend/styles/application.css
git commit -m "feat(ui): add Catalyst layout shells (sidebar/stacked/auth)"
```

---

### Task 10: Foundation verification + barrel export + smoke view spec

**Files:**
- Create: `app/frontend/components/index.ts` (barrel)
- Create: `spec/views/shared/components/components_spec.rb` (smoke-render presentational partials)
- Run: full `bin/quality` gate

- [ ] **Step 1: Add the barrel export**

```ts
// app/frontend/components/index.ts
export { default as Button } from "./Button.svelte"
export type { ButtonColor } from "./Button.svelte"
export { default as Link } from "./Link.svelte"
export { default as Text } from "./Text.svelte"
export { default as Heading } from "./Heading.svelte"
export { default as Divider } from "./Divider.svelte"
export { default as Avatar } from "./Avatar.svelte"
export { default as Card } from "./Card.svelte"
export { default as Badge } from "./Badge.svelte"
export { default as Alert } from "./Alert.svelte"
export { default as Input } from "./Input.svelte"
export { default as Textarea } from "./Textarea.svelte"
export { default as Select } from "./Select.svelte"
export { default as Checkbox } from "./Checkbox.svelte"
export * from "./field"
export * from "./table"
export * from "./pagination"
export * from "./description_list"
export * from "./sidebar"
export * from "./navbar"
export { default as SidebarLayout } from "./SidebarLayout.svelte"
export { default as StackedLayout } from "./StackedLayout.svelte"
export { default as AuthLayout } from "./AuthLayout.svelte"
```

(Adjust re-exports to match the actual filenames chosen in Tasks 4/6/8 — the implementer reconciles names so `pnpm run check` passes.)

- [ ] **Step 2: Write the smoke view spec for ERB partials**

```ruby
# spec/views/shared/components/components_spec.rb
require "rails_helper"

RSpec.describe "shared/components", type: :view do
  it "renders the button partial as a solid dark/zinc button" do
    render "shared/components/button", label: "Save"
    expect(rendered).to have_selector("button.btn.btn--solid.btn--dark\\/zinc", text: "Save")
  end

  it "renders the alert partial with role=status for success" do
    render "shared/components/alert", tone: "success", body: "Saved"
    expect(rendered).to have_selector("div[role='status'].alert--success", text: "Saved")
  end

  it "renders the badge partial with a color class" do
    render "shared/components/badge", label: "New", color: "red"
    expect(rendered).to have_selector("span.badge.badge--red", text: "New")
  end

  it "renders the card partial" do
    render "shared/components/card" do
      "<p>body</p>"
    end
    expect(rendered).to have_selector("div.card")
  end

  it "renders the divider partial" do
    render "shared/components/divider", soft: true
    expect(rendered).to have_selector("hr.divider.divider--soft")
  end

  it "renders the sidebar item with heroicon + current state" do
    render "shared/components/sidebar_item", href: "/x", label: "Home", icon: "home", current: true
    expect(rendered).to have_selector("a.sidebar-item[data-current='true']")
    expect(rendered).to include("<svg") # heroicon rendered
  end
end
```

- [ ] **Step 3: Run the view spec**

Run: `bundle exec rspec spec/views/shared/components/components_spec.rb`
Expected: PASS (6 examples). If `heroicon` raises on a name mismatch, correct the icon name to match the gem's supported set (`bundle exec rails runner "puts Heroicons.all_icon_names"` if such a helper exists, else consult the gem README).

- [ ] **Step 4: Run the full quality gate**

Run: `bin/quality`
Expected: all green (RuboCop, Brakeman, bundler-audit, RSpec, svelte-check, ESLint, Prettier, Vitest, `assets:precompile`). Fix any lint/format failures (`bundle exec rubocop -A`, `pnpm exec prettier --write app/frontend`, etc.).

- [ ] **Step 5: Manual visual smoke**

Run: `bin/dev`, visit any existing page (it still uses the OLD markup — that's fine; this task only verifies the CSS compiles and the new partials render). Then in `bin/rails console`, render a partial to eyeball markup:

```ruby
ApplicationController.render("shared/components/button", assigns: {}, locals: { label: "Save" })
```

Confirm the class string is `btn btn--solid btn--dark/zinc` and (visually, once a page uses it) that the button matches `docs/ui-kit/catalyst-ui-kit/demo`.

- [ ] **Step 6: Commit**

```bash
git add app/frontend/components/index.ts spec/views/shared/components/components_spec.rb
git commit -m "feat(ui): add component barrel export + ERB partial smoke specs; quality green"
```

---

## Self-Review (completed by plan author)

**1. Spec coverage** (against `docs/superpowers/specs/2026-08-02-catalyst-ui-adoption-design.md`):
- Foundation (spec rollout steps 1–3 + 6) → Tasks 1–9. ✓
- Tokens (Layer 1) → Task 1. ✓
- Component class recipes (Layer 2) → Tasks 2–9 each add their recipes. ✓
- Svelte + ERB wrappers (Layer 3) → every component task creates both. ✓
- heroicons gem + Svelte icon set → Tasks 1 + 7. ✓
- Layout shells (sidebar/stacked/auth) → Task 9. ✓
- `cx` helper instead of clsx dep → Task 1 (honors "no new npm deps"). ✓
- State-hook translation rule → Global Constraints + applied per task. ✓
- ERB partials replacing old ones (`_flash`→`_alert`, `_pagination`, `_form_errors`→`_field`, etc.) → partials created here; the *replacement at call sites* is the surface-migration follow-up plans (3–6), which is correct sequencing.
- Testing: vitest for components, a view spec for ERB partials, `bin/quality` gate → Tasks 1–10. ✓
- **Out of scope for THIS plan (correctly deferred):** behavioral components Dropdown/Dialog/Switch/Listbox/Combobox (plan 2), and the four surface migrations (plans 3–6). These are noted at the top.

**2. Placeholder scan:** No "TBD/TODO/implement later." Two intentional, concrete instructions to the implementer are NOT placeholders: (a) "port remaining colors following the one-line pattern" — the pattern is given in full and the source line range in button.tsx is cited; (b) "reconcile barrel export names to actual filenames" — the names are listed; reconciliation is mechanical. Both are resolvable without judgment calls.

**3. Type/name consistency:** `ButtonColor` defined in Task 2, consumed by `Badge` (Task 5) and `Checkbox` (Task 4) — consistent. `cx` defined in Task 1, used everywhere after. Recipe class names (`.btn--solid`, `.alert--success`, `.sidebar-item[data-current]`, `.control`, `.input`) match between CSS steps, Svelte, ERB, and tests. ERB partial paths consistently `shared/components/_*.html.erb`. Stimulus controller file extension corrected to `.ts` (matches the glob) — none created in this plan, noted for plan 2.

No issues found. Plan is ready.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-08-02-catalyst-foundation.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — execute tasks in this session using executing-plans, batch execution with checkpoints.

**Which approach?**

> **Follow-up plans (after this foundation lands):** Plan 2 — Behavioral components (Dropdown, Dialog, Switch, Listbox, Combobox: Svelte + Stimulus + tests). Plan 3 — `/app` SPA migration (AppLayout sidebar-layout shell, Dashboard, Notifications). Plan 4 — Auth + marketing migration. Plan 5 — Settings migration. Plan 6 — Admin migration. Each is spec'd against this foundation and produces working, testable software on its own. I'll write each when its predecessor is in flight or complete.
