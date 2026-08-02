import { createInertiaApp, type ResolvedComponent } from "@inertiajs/svelte"
import { mount } from "svelte"
import "@/styles/application.css"

createInertiaApp({
  resolve: async (name) => {
    const pages = import.meta.glob("../pages/**/*.svelte")
    const importer = pages[`../pages/${name}.svelte`]

    if (!importer) {
      throw new Error(`Unknown Inertia page: ${name}`)
    }

    return (await importer()) as ResolvedComponent
  },
  setup({ el, App, props }) {
    if (!el) {
      throw new Error("Missing Inertia mount element")
    }

    mount(App, { target: el, props })
  },
  progress: {
    color: "#2563eb",
    showSpinner: false,
  },
})
