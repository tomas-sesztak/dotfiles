# Sync Homebrew with ~/.Brewfile + ~/.Brewfile_dotfiles: install/upgrade listed, remove unlisted
function brew_update() {
  if ! command -v brew >/dev/null; then
    print -u2 "brew_update: brew not found"
    return 1
  fi

  local brewfile
  brewfile=$(mktemp) || return 1
  {
    local entries
    entries=$(cat ~/.Brewfile_dotfiles ~/.Brewfile 2>/dev/null |
      sed -e 's/[[:space:]]*#.*$//' -e 's/[[:space:]]*$//' -e '/^$/d' |
      sort -u)
    # Taps first so formulae from them resolve
    { grep '^tap ' <<<"$entries"; grep -v '^tap ' <<<"$entries"; } >"$brewfile"

    brew update &&
      brew bundle install --file="$brewfile" --upgrade &&
      brew bundle cleanup --file="$brewfile" --force &&
      brew upgrade &&
      brew autoremove &&
      brew cleanup
  } always {
    rm -f "$brewfile"
  }
}
