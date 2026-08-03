<script lang="ts">
  import { router } from "@inertiajs/svelte"
  import type { Snippet } from "svelte"
  import type { AppLayoutProps } from "@/types/app"

  let {
    auth,
    notifications = { unread_count: 0 },
    locale = "id",
    i18n,
    flash = {},
    children,
  }: AppLayoutProps & {
    locale?: string
    flash?: AppLayoutProps["flash"]
    children?: Snippet
  } = $props()

  const user = $derived(auth.user)
  const text = $derived(i18n.app.layout)
  let sidebarOpen = $state(false)
  const admin = $derived(user?.role === "staff" || user?.role === "admin")
  const csrfToken = $derived(
    globalThis.document
      ?.querySelector('meta[name="csrf-token"]')
      ?.getAttribute("content") ?? "",
  )

  const navItems = $derived([
    { label: text.dashboard, href: "/app/dashboard", initial: "D" },
    { label: text.settings, href: "/settings/profile", initial: "S" },
    ...(admin
      ? [
          { label: "Admin Users", href: "/admin/users", initial: "A" },
          {
            label: "Admin Notifications",
            href: "/admin/notifications",
            initial: "A",
          },
        ]
      : []),
  ])

  function navClass(href: string) {
    const path = globalThis.location?.pathname ?? "/app/dashboard"
    const active =
      path === href ||
      (href === "/settings/profile" && path.startsWith("/settings"))

    return [
      "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold",
      active
        ? "bg-zinc-50 text-zinc-950"
        : "text-zinc-700 hover:bg-zinc-50 hover:text-zinc-950",
    ].join(" ")
  }
</script>

<div class="min-h-screen bg-zinc-50 text-zinc-950">
  <div class:hidden={!sidebarOpen} class="fixed inset-0 z-50 lg:hidden">
    <button
      type="button"
      class="fixed inset-0 bg-zinc-900/80"
      onclick={() => (sidebarOpen = false)}
    >
      <span class="sr-only">Close sidebar backdrop</span>
    </button>
    <div
      class="fixed inset-y-0 left-0 flex w-full max-w-xs flex-col bg-white px-6 pb-4"
    >
      <button
        type="button"
        class="absolute left-full top-5 ml-4 text-white"
        onclick={() => (sidebarOpen = false)}
      >
        <span class="sr-only">Close sidebar</span>
        <span aria-hidden="true" class="text-2xl leading-none">&times;</span>
      </button>
      <div class="flex h-16 shrink-0 items-center">
        <a href="/app/dashboard" class="text-sm font-semibold">Starter App</a>
      </div>
      <nav aria-label="Mobile" class="flex flex-1 flex-col">
        <ul role="list" class="flex flex-1 flex-col gap-y-7">
          <li>
            <ul role="list" class="-mx-2 space-y-1">
              {#each navItems as item (item.href)}
                <li>
                  <a class={navClass(item.href)} href={item.href}>
                    <span
                      class="flex size-6 shrink-0 items-center justify-center rounded-md border border-zinc-200 bg-white text-[0.625rem] font-semibold text-zinc-500"
                      >{item.initial}</span
                    >
                    <span>{item.label}</span>
                  </a>
                </li>
              {/each}
            </ul>
          </li>
        </ul>
      </nav>
    </div>
  </div>

  <aside
    class="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col"
  >
    <div
      class="flex grow flex-col gap-y-5 overflow-y-auto border-r border-zinc-200 bg-white px-6 pb-4"
    >
      <div class="flex h-16 shrink-0 items-center">
        <a href="/app/dashboard" class="text-sm font-semibold">Starter App</a>
      </div>
      <nav aria-label="Member" class="flex flex-1 flex-col">
        <ul role="list" class="flex flex-1 flex-col gap-y-7">
          <li>
            <ul role="list" class="-mx-2 space-y-1">
              {#each navItems as item (item.href)}
                <li>
                  <a class={navClass(item.href)} href={item.href}>
                    <span
                      class="flex size-6 shrink-0 items-center justify-center rounded-md border border-zinc-200 bg-white text-[0.625rem] font-semibold text-zinc-500"
                      >{item.initial}</span
                    >
                    <span>{item.label}</span>
                  </a>
                </li>
              {/each}
            </ul>
          </li>
          <li class="-mx-2 mt-auto space-y-1">
            <a
              class="flex items-center justify-center rounded-full border border-zinc-200 px-3 py-2 text-sm font-semibold text-zinc-700 hover:bg-zinc-50"
              aria-label={text.notifications}
              href="/app/notifications">{notifications.unread_count}</a
            >
            <div class="px-2 py-3 text-sm">
              <p class="font-medium">{user?.name}</p>
              <p class="truncate text-zinc-500">{user?.email}</p>
            </div>
            <div class="flex rounded-md border border-zinc-300 p-1">
              <button
                class:font-semibold={locale === "id"}
                class="flex-1 px-2 py-1 text-sm"
                onclick={() => router.patch("/locale", { locale: "id" })}
                >ID</button
              >
              <button
                class:font-semibold={locale === "en"}
                class="flex-1 px-2 py-1 text-sm"
                onclick={() => router.patch("/locale", { locale: "en" })}
                >EN</button
              >
            </div>
            <form action="/session" method="post">
              <input type="hidden" name="_method" value="delete" />
              {#if csrfToken}
                <input
                  type="hidden"
                  name="authenticity_token"
                  value={csrfToken}
                />
              {/if}
              <button
                class="w-full rounded-md bg-zinc-950 px-3 py-2 text-sm font-medium text-white"
                type="submit">{text.sign_out}</button
              >
            </form>
          </li>
        </ul>
      </nav>
    </div>
  </aside>

  <div class="lg:pl-72">
    <header
      class="sticky top-0 z-40 flex items-center gap-x-6 border-b border-zinc-200 bg-white px-4 py-4 shadow-xs sm:px-6 lg:hidden"
    >
      <button
        type="button"
        class="-m-2.5 p-2.5 text-zinc-700"
        onclick={() => (sidebarOpen = true)}
      >
        <span class="sr-only">Open sidebar</span>
        <span aria-hidden="true" class="text-2xl leading-none">&#9776;</span>
      </button>
      <div class="flex-1 text-sm/6 font-semibold text-zinc-950">
        {text.dashboard}
      </div>
      <a
        aria-label={text.notifications}
        class="min-w-8 rounded-full border border-zinc-300 px-2 py-1 text-center text-sm hover:bg-zinc-100"
        href="/app/notifications">{notifications.unread_count}</a
      >
    </header>

    <div class="px-4 py-6 sm:px-6 lg:px-8">
      {#if flash.notice}
        <div
          role="status"
          class="mb-4 rounded-md border border-emerald-200 bg-emerald-50 p-3 text-sm text-emerald-800"
        >
          {flash.notice}
        </div>
      {/if}
      {#if flash.alert}
        <div
          role="alert"
          class="mb-4 rounded-md border border-red-200 bg-red-50 p-3 text-sm text-red-800"
        >
          {flash.alert}
        </div>
      {/if}
      <main>
        {@render children?.()}
      </main>
    </div>
  </div>
</div>
