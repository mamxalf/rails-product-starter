<script lang="ts">
  let { label, active = false }: { label: string; active?: boolean } = $props()
</script>

<span data-active={active}>{label}</span>
