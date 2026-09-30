# Sync Homebrew with ~/.Brewfile: install/upgrade listed, remove unlisted
function brew_update() {
  if ! command -v brew >/dev/null; then
    print -u2 "brew_update: brew not found"
    return 1
  fi

  brew update &&
    brew bundle install --global --upgrade &&
    brew bundle cleanup --global --force &&
    brew upgrade &&
    brew autoremove &&
    brew cleanup
}
