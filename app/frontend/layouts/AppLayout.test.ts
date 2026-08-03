import { render, screen } from "@testing-library/svelte"
import { createRawSnippet } from "svelte"
import { beforeEach, describe, expect, it } from "vitest"
import AppLayout from "./AppLayout.svelte"

describe("AppLayout", () => {
  beforeEach(() => {
    document.head.innerHTML =
      '<meta name="csrf-token" content="test-csrf-token">'
  })

  it("renders navigation, identity, locale controls, flash, and main content", () => {
    render(AppLayout, {
      props: {
        auth: {
          user: { name: "Member", email: "member@example.com", role: "member" },
        },
        notifications: { unread_count: 3 },
        locale: "en",
        i18n: {
          app: {
            layout: {
              dashboard: "Dashboard",
              settings: "Settings",
              notifications: "Notifications",
              sign_out: "Sign out",
            },
          },
        },
        flash: { notice: "Saved", alert: null },
        children: createRawSnippet(() => ({
          render: () => "<p>Account status</p>",
        })),
      },
    })

    expect(screen.getAllByRole("navigation", { name: "Member" })).toHaveLength(
      1,
    )
    expect(
      screen.getByRole("button", { name: "Open sidebar" }),
    ).toBeInTheDocument()
    expect(
      screen.getByRole("button", { name: "Close sidebar" }),
    ).toBeInTheDocument()
    expect(screen.getByText("member@example.com")).toBeInTheDocument()
    expect(screen.getAllByRole("link", { name: "Notifications" })).toHaveLength(
      2,
    )
    expect(
      screen.getAllByRole("link", { name: "Notifications" })[0],
    ).toHaveTextContent("3")
    expect(screen.getByRole("button", { name: "ID" })).toBeInTheDocument()
    const signOutForm = screen
      .getByRole("button", { name: "Sign out" })
      .closest("form")
    expect(signOutForm).toHaveAttribute("method", "post")
    expect(signOutForm).toHaveAttribute("action", "/session")
    expect(signOutForm?.querySelector('input[name="_method"]')).toHaveAttribute(
      "value",
      "delete",
    )
    expect(
      signOutForm?.querySelector('input[name="authenticity_token"]'),
    ).toHaveAttribute("value", "test-csrf-token")
    expect(screen.getByText("Saved")).toBeInTheDocument()
    expect(screen.getByRole("main")).toHaveTextContent("Account status")
  })

  it("renders member shell labels in Indonesian", () => {
    render(AppLayout, {
      props: {
        auth: {
          user: { name: "Member", email: "member@example.com", role: "member" },
        },
        notifications: { unread_count: 0 },
        locale: "id",
        i18n: {
          app: {
            layout: {
              dashboard: "Dasbor",
              settings: "Pengaturan",
              notifications: "Notifikasi",
              sign_out: "Keluar",
            },
          },
        },
        flash: { notice: null, alert: null },
        children: createRawSnippet(() => ({
          render: () => "<p>Status akun</p>",
        })),
      },
    })

    expect(screen.getAllByText("Dasbor")).toHaveLength(3)
    expect(screen.getAllByText("Pengaturan")).toHaveLength(2)
    expect(screen.getByRole("button", { name: "Keluar" })).toBeInTheDocument()
  })

  it("uses injected i18n labels", () => {
    render(AppLayout, {
      props: {
        auth: {
          user: { name: "Member", email: "member@example.com", role: "member" },
        },
        notifications: { unread_count: 0 },
        locale: "en",
        i18n: {
          app: {
            layout: {
              dashboard: "Workspace",
              settings: "Profile",
              notifications: "Alerts",
              sign_out: "Leave",
            },
          },
        },
        flash: { notice: null, alert: null },
        children: createRawSnippet(() => ({
          render: () => "<p>Account status</p>",
        })),
      },
    })

    expect(screen.getAllByText("Workspace")).toHaveLength(3)
    expect(screen.getAllByText("Profile")).toHaveLength(2)
    expect(screen.getAllByLabelText("Alerts")).toHaveLength(2)
    expect(screen.getByRole("button", { name: "Leave" })).toBeInTheDocument()
  })
})
