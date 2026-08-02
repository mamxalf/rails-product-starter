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
</script>

<div class="min-h-screen bg-zinc-50 text-zinc-950">
  <aside
    class="fixed inset-y-0 hidden w-64 border-r border-zinc-200 bg-white p-6 md:block"
  >
    <a href="/app/dashboard" class="text-sm font-semibold">Starter App</a>
    <nav aria-label="Member" class="mt-8 space-y-1 text-sm">
      <a
        class="block rounded-md bg-zinc-100 px-3 py-2 font-medium"
        href="/app/dashboard">{text.dashboard}</a
      >
      <a
        class="block rounded-md px-3 py-2 text-zinc-600 hover:bg-zinc-100"
        href="/settings/profile">{text.settings}</a
      >
    </nav>
  </aside>

  <div class="md:pl-64">
    <header class="border-b border-zinc-200 bg-white">
      <div class="flex items-center justify-between gap-4 px-4 py-3 md:px-6">
        <nav aria-label="Member" class="flex gap-3 text-sm md:hidden">
          <a class="font-medium" href="/app/dashboard">{text.dashboard}</a>
          <a class="text-zinc-600" href="/settings/profile">{text.settings}</a>
        </nav>

        <div class="ml-auto flex items-center gap-3 text-sm">
          <a
            aria-label={text.notifications}
            class="min-w-8 rounded-full border border-zinc-300 px-2 py-1 text-center hover:bg-zinc-100"
            href="/app/notifications">{notifications.unread_count}</a
          >
          <div class="text-right">
            <p class="font-medium">{user?.name}</p>
            <p class="text-zinc-500">{user?.email}</p>
          </div>
          <div class="flex rounded-md border border-zinc-300 p-1">
            <button
              class:font-semibold={locale === "id"}
              class="px-2 py-1"
              onclick={() => router.patch("/locale", { locale: "id" })}
              >ID</button
            >
            <button
              class:font-semibold={locale === "en"}
              class="px-2 py-1"
              onclick={() => router.patch("/locale", { locale: "en" })}
              >EN</button
            >
          </div>
          <button
            class="rounded-md bg-zinc-950 px-3 py-2 font-medium text-white"
            onclick={() => router.delete("/session")}>{text.sign_out}</button
          >
        </div>
      </div>
    </header>

    <div class="px-4 py-4 md:px-6">
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
