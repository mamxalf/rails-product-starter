import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import StatusBadge from "./StatusBadge.svelte"

describe("StatusBadge", () => {
  it("renders its label and active state", () => {
    render(StatusBadge, { props: { label: "Verified", active: true } })

    expect(screen.getByText("Verified")).toHaveAttribute("data-active", "true")
  })
})
