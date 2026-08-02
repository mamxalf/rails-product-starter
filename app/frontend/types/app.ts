export type User = {
  id?: number
  name: string
  email: string
  role: string
  avatar_url?: string | null
}

export type Flash = {
  notice?: string | null
  alert?: string | null
}

export type NotificationsSummary = {
  unread_count: number
}

export type LayoutCopy = {
  dashboard: string
  settings: string
  notifications: string
  sign_out: string
}

export type DashboardCopy = {
  admin: string
  title: string
  welcome: string
  welcome_line: string
  welcome_body: string
  verified: string
  verified_body: string
  notifications: string
  no_notifications: string
  metrics: string
  metrics_body: string
}

export type AppLayoutI18n = {
  app: {
    layout: LayoutCopy
  }
}

export type AppI18n = {
  app: {
    layout: LayoutCopy
    dashboard: DashboardCopy
  }
}

export type AppLayoutProps = {
  auth: { user: User | null }
  notifications: NotificationsSummary
  locale: string
  i18n: AppLayoutI18n
  flash: Flash
}

export type DashboardProps = Omit<AppLayoutProps, "i18n"> & {
  i18n: AppI18n
  permissions: { access_admin: boolean }
}

export type NotificationItem = {
  id: number
  kind: string
  title: string
  body: string
  action_url?: string | null
  read_at?: string | null
  created_at: string
}

export type NotificationsPageProps = AppLayoutProps & {
  notifications: NotificationsSummary & {
    items: NotificationItem[]
  }
}
