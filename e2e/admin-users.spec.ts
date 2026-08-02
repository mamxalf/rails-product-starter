import { execFileSync } from "node:child_process"
import { expect, test } from "@playwright/test"

const adminEmail = "admin-e2e@example.test"
const memberEmail = "member-e2e@example.test"
const password = "password123"

test.beforeEach(() => {
  execFileSync(
    "bin/rails",
    [
      "runner",
      `
        AuditEvent.delete_all
        Session.delete_all
        User.where(email_address: [${JSON.stringify(adminEmail)}, ${JSON.stringify(memberEmail)}]).delete_all
        User.create!(name: "Admin E2E", email_address: ${JSON.stringify(adminEmail)}, password: ${JSON.stringify(password)}, role: :admin, email_verified_at: Time.current)
        User.create!(name: "Member E2E", email_address: ${JSON.stringify(memberEmail)}, password: ${JSON.stringify(password)}, role: :member, email_verified_at: Time.current)
      `,
    ],
    { env: { ...process.env, RAILS_ENV: "test" } },
  )
})

test("admin suspends and unsuspends a user", async ({ page }) => {
  page.on("dialog", (dialog) => dialog.accept())

  await page.goto("/session/new")
  await page.locator('input[name="email_address"]').fill(adminEmail)
  await page.locator('input[name="password"]').fill(password)
  await page.locator('input[type="submit"]').click()

  await page.getByRole("link", { name: "Admin" }).click()
  await page.getByRole("link", { name: "Users" }).click()
  await page.locator('input[name="search"]').fill("Member E2E")
  await page.getByRole("button", { name: "Filter" }).click()
  await page.getByRole("row", { name: /Member E2E/ }).getByRole("link", { name: "Details" }).click()

  await page.getByRole("button", { name: "Suspend" }).click()
  await expect(page.getByText("admin.users.suspend")).toBeVisible()
  await expect(page.getByText("Suspended").first()).toBeVisible()

  await page.getByRole("button", { name: "Unsuspend" }).click()
  await expect(page.getByText("admin.users.unsuspend")).toBeVisible()
  await expect(page.getByText("Active").first()).toBeVisible()
})
