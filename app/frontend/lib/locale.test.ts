import { describe, expect, it } from "vitest"
import { formatDate, formatNumber } from "./locale"

describe("locale formatting", () => {
  it("formats dates and numbers with the active locale", () => {
    expect(formatDate("2026-08-02T00:00:00Z", "id")).toContain("2026")
    expect(formatNumber(1234.5, "id")).toBe("1.234,5")
  })
})
