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
