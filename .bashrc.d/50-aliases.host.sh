#!/usr/bin/env bash
advantage360() {
  local cache
  cache="$HOME/.cache/adv360"
  if [ ! -d "$cache" ]; then
    if ! git clone https://github.com/enckse/Adv360-Pro-ZMK "$cache"; then
      return
    fi
  fi
  if ! git -C "$cache" fetch; then
    return
  fi
  if ! git -C "$cache" pull; then
    return
  fi
  git -C "$cache" diff 0fb8e5824fee2fb11f263de745f5b1c0efbcd78a > "$HOME/.config/voidedtech/adv360/mappings.patch"
}
