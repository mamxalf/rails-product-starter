import { expect, test } from "@playwright/test"

test("application responds", async ({ page }) => {
  await page.goto("/up")
  await expect(page.locator("body")).toHaveAttribute("style", /green/)
})
