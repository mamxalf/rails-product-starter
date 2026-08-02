import { render, screen } from "@testing-library/svelte"
import { describe, expect, it } from "vitest"
import Dashboard from "./Dashboard.svelte"

describe("Dashboard", () => {
  it("renders neutral account status without fake metrics", () => {
    render(Dashboard, {
      props: {
        auth: {
          user: { name: "Member", email: "member@example.com", role: "member" },
        },
        notifications: { unread_count: 0 },
        locale: "en",
        i18n: {
          app: {
            layout: {
              dashboard: "Dashboard",
              settings: "Settings",
              notifications: "Notifications",
              sign_out: "Sign out",
            },
            dashboard: {
              admin: "Admin",
              title: "Dashboard",
              welcome: "Welcome",
              welcome_line: "Welcome, Member.",
              welcome_body: "Your account workspace is ready.",
              verified: "Verified account",
              verified_body: "Account access is active.",
              notifications: "Notifications",
              no_notifications: "No notifications yet.",
              metrics: "Product metrics",
              metrics_body:
                "Connect real product data here when those models exist.",
            },
          },
        },
        permissions: { access_admin: false },
        flash: { notice: null, alert: null },
      },
    })

    expect(
      screen.getByRole("heading", { name: "Dashboard" }),
    ).toBeInTheDocument()
    expect(screen.getByText("Verified account")).toBeInTheDocument()
    expect(screen.getByText("No notifications yet.")).toBeInTheDocument()
    expect(
      screen.queryByText(/revenue|conversion|growth/i),
    ).not.toBeInTheDocument()
  })

  it("renders dashboard content in Indonesian", () => {
    render(Dashboard, {
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
            dashboard: {
              admin: "Admin",
              title: "Dasbor",
              welcome: "Selamat datang",
              welcome_line: "Selamat datang, Member.",
              welcome_body: "Ruang kerja akun Anda siap.",
              verified: "Akun terverifikasi",
              verified_body: "Akses akun aktif.",
              notifications: "Notifikasi",
              no_notifications: "Belum ada notifikasi.",
              metrics: "Metrik produk",
              metrics_body:
                "Hubungkan data produk nyata di sini saat modelnya tersedia.",
            },
          },
        },
        permissions: { access_admin: false },
        flash: { notice: null, alert: null },
      },
    })

    expect(screen.getByRole("heading", { name: "Dasbor" })).toBeInTheDocument()
    expect(screen.getByText("Akun terverifikasi")).toBeInTheDocument()
    expect(screen.getByText("Belum ada notifikasi.")).toBeInTheDocument()
  })

  it("uses injected i18n content", () => {
    render(Dashboard, {
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
            dashboard: {
              admin: "Admin",
              title: "Workspace",
              welcome: "Hello",
              welcome_line: "Hello, Member.",
              welcome_body: "Ready.",
              verified: "Active account",
              verified_body: "Access enabled.",
              notifications: "Alerts",
              no_notifications: "No alerts.",
              metrics: "Signals",
              metrics_body: "Attach real data later.",
            },
          },
        },
        permissions: { access_admin: false },
        flash: { notice: null, alert: null },
      },
    })

    expect(
      screen.getByRole("heading", { name: "Workspace" }),
    ).toBeInTheDocument()
    expect(screen.getByText("Active account")).toBeInTheDocument()
    expect(screen.getByText("No alerts.")).toBeInTheDocument()
  })
})
