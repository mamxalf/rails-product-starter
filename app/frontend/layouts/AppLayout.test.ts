import { render, screen } from "@testing-library/svelte"
import { createRawSnippet } from "svelte"
import { describe, expect, it } from "vitest"
import AppLayout from "./AppLayout.svelte"

describe("AppLayout", () => {
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
      2,
    )
    expect(screen.getByText("member@example.com")).toBeInTheDocument()
    expect(
      screen.getByRole("link", { name: "Notifications" }),
    ).toHaveTextContent("3")
    expect(screen.getByRole("button", { name: "ID" })).toBeInTheDocument()
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

    expect(screen.getAllByText("Dasbor")).toHaveLength(2)
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

    expect(screen.getAllByText("Workspace")).toHaveLength(2)
    expect(screen.getAllByText("Profile")).toHaveLength(2)
    expect(screen.getByLabelText("Alerts")).toBeInTheDocument()
    expect(screen.getByRole("button", { name: "Leave" })).toBeInTheDocument()
  })
})
