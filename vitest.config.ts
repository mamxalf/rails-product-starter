import { fileURLToPath, URL } from "node:url"
import { defineConfig } from "vitest/config"
import { svelte } from "@sveltejs/vite-plugin-svelte"
import { svelteTesting } from "@testing-library/svelte/vite"

export default defineConfig({
  plugins: [svelte(), svelteTesting()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./app/frontend", import.meta.url)),
    },
  },
  test: {
    environment: "jsdom",
    setupFiles: ["./app/frontend/test/setup.ts"],
    include: ["app/frontend/**/*.{test,spec}.{ts,js}"],
  },
})
