import { application } from "./application"

const controllerModules = import.meta.glob("./**/*_controller.ts", { eager: true })

for (const path in controllerModules) {
  const module = controllerModules[path] as { default?: unknown }
  const identifier = path
    .replace(/^\.\//, "")
    .replace(/_controller\.ts$/, "")
    .replaceAll("_", "-")
    .replaceAll("/", "--")

  if (module.default) {
    application.register(identifier, module.default as never)
  }
}
