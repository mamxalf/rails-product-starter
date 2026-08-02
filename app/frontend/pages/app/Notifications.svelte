<script lang="ts">
  import { router } from "@inertiajs/svelte"
  import AppLayout from "@/layouts/AppLayout.svelte"
  import type { NotificationsPageProps } from "@/types/app"

  let { auth, notifications, locale, i18n, flash }: NotificationsPageProps =
    $props()

  const items = $derived(notifications.items)

  const markRead = (id: number) => router.patch(`/app/notifications/${id}`)
  const markAllRead = () => router.patch("/app/notifications/read_all")
</script>

<AppLayout {auth} {notifications} {locale} {i18n} {flash}>
  <div class="max-w-4xl">
    <div class="flex items-start justify-between gap-4">
      <div>
        <h1 class="text-2xl font-semibold">Notifications</h1>
        <p class="mt-1 text-sm text-zinc-600">
          {notifications.unread_count} unread
        </p>
      </div>
      <button
        class="rounded-md border border-zinc-300 px-3 py-2 text-sm font-medium disabled:opacity-50"
        disabled={notifications.unread_count === 0}
        onclick={markAllRead}>Mark all read</button
      >
    </div>

    {#if items.length === 0}
      <section
        class="mt-6 rounded-md border border-dashed border-zinc-300 bg-white p-6 text-sm text-zinc-600"
      >
        No notifications yet.
      </section>
    {:else}
      <section
        class="mt-6 divide-y divide-zinc-200 rounded-md border border-zinc-200 bg-white"
      >
        {#each items as item (item.id)}
          <article class="p-4">
            <div class="flex items-start justify-between gap-4">
              <div>
                <h2 class="font-medium text-zinc-950">{item.title}</h2>
                <p class="mt-1 text-sm text-zinc-600">{item.body}</p>
                {#if item.action_url}
                  <a
                    class="mt-2 inline-block text-sm font-medium text-blue-700"
                    href={item.action_url}>Open</a
                  >
                {/if}
              </div>
              {#if item.read_at}
                <span class="text-xs text-zinc-500">Read</span>
              {:else}
                <button
                  class="rounded-md border border-zinc-300 px-3 py-2 text-sm font-medium"
                  onclick={() => markRead(item.id)}>Mark read</button
                >
              {/if}
            </div>
          </article>
        {/each}
      </section>
    {/if}
  </div>
</AppLayout>
