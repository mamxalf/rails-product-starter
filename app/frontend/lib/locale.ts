export function formatDate(value: Date | string | number, locale: string) {
  return new Intl.DateTimeFormat(locale).format(new Date(value))
}

export function formatNumber(value: number, locale: string) {
  return new Intl.NumberFormat(locale).format(value)
}
