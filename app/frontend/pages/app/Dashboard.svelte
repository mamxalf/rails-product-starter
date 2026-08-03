<script lang="ts">
  import AppLayout from "@/layouts/AppLayout.svelte"
  import type { DashboardProps } from "@/types/app"

  let {
    auth,
    notifications,
    locale,
    i18n,
    permissions,
    flash,
  }: DashboardProps = $props()
  const text = $derived(i18n.app.dashboard)
</script>

<AppLayout {auth} {notifications} {locale} {i18n} {flash}>
  <div class="mx-auto max-w-6xl">
    <div class="flex items-start justify-between gap-4">
      <div>
        <h1 class="text-2xl font-semibold text-zinc-950">{text.title}</h1>
        <p class="mt-1 text-sm text-zinc-600">{text.welcome_line}</p>
      </div>
      {#if permissions.access_admin}
        <a
          class="rounded-md border border-zinc-300 px-3 py-2 text-sm font-medium"
          href="/admin">{text.admin}</a
        >
      {/if}
    </div>

    <section class="mt-6 grid gap-4 lg:grid-cols-3">
      <article class="rounded-md border border-zinc-200 bg-white p-5">
        <h2 class="text-sm font-medium text-zinc-600">{text.welcome}</h2>
        <p class="mt-2 text-lg font-semibold text-zinc-950">
          {text.welcome_body}
        </p>
      </article>
      <article class="rounded-md border border-zinc-200 bg-white p-5">
        <h2 class="text-sm font-medium text-zinc-600">{text.verified}</h2>
        <p class="mt-2 text-lg font-semibold text-zinc-950">
          {text.verified_body}
        </p>
      </article>
      <article class="rounded-md border border-zinc-200 bg-white p-5">
        <h2 class="text-sm font-medium text-zinc-600">{text.notifications}</h2>
        <p class="mt-2 text-lg font-semibold text-zinc-950">
          {text.no_notifications}
        </p>
      </article>
    </section>

    <section
      class="mt-6 rounded-md border border-dashed border-zinc-300 bg-white p-4"
    >
      <h2 class="font-medium">{text.metrics}</h2>
      <p class="mt-2 text-sm text-zinc-600">{text.metrics_body}</p>
    </section>
  </div>
</AppLayout>
