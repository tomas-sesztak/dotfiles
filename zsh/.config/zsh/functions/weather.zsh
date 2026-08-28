function weather() {
  city="${1:-Prague}"
  curl "wttr.in/${city}"
}
