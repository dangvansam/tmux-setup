#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
TMUX_CONF="$HOME/.tmux.conf"
BOOT_CRON_ENTRY='@reboot /bin/bash -lc "/usr/bin/tmux new-session -d -s main" 2>/dev/null'

log() {
  printf '\033[1;32m[tmux-setup]\033[0m %s\n' "$1"
}

warn() {
  printf '\033[1;33m[tmux-setup]\033[0m %s\n' "$1"
}

install_tmux() {
  if command -v tmux >/dev/null 2>&1; then
    log "tmux already installed: $(tmux -V)"
    return
  fi
  log "installing tmux"
  sudo apt-get update -y
  sudo apt-get install -y tmux
}

install_clipboard_tool() {
  if command -v xclip >/dev/null 2>&1 || command -v xsel >/dev/null 2>&1; then
    log "clipboard tool already installed"
    return
  fi
  if sudo -n true 2>/dev/null; then
    sudo apt-get install -y xclip
    log "xclip installed"
  else
    warn "xclip not installed, run manually: sudo apt-get install -y xclip"
    warn "clipboard over SSH still works via OSC 52 (set-clipboard on)"
  fi
}

backup_existing_config() {
  if [ -f "$TMUX_CONF" ] && ! cmp -s "$REPO_DIR/tmux.conf" "$TMUX_CONF"; then
    local backup="$TMUX_CONF.bak.$(date +%Y%m%d%H%M%S)"
    cp "$TMUX_CONF" "$backup"
    log "existing config backed up to $backup"
  fi
}

install_config() {
  cp "$REPO_DIR/tmux.conf" "$TMUX_CONF"
  log "tmux.conf installed to $TMUX_CONF"
}

install_tpm() {
  if [ -d "$TPM_DIR" ]; then
    log "tpm already installed, updating"
    git -C "$TPM_DIR" pull --quiet
    return
  fi
  log "cloning tpm"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
}

install_plugins() {
  log "installing plugins"
  "$TPM_DIR/bin/install_plugins"
}

setup_boot_restore() {
  if crontab -l 2>/dev/null | grep -Fq "$BOOT_CRON_ENTRY"; then
    log "reboot cron entry already present"
    return
  fi
  { crontab -l 2>/dev/null | grep -v 'tmux new-session' || true; echo "$BOOT_CRON_ENTRY"; } | crontab -
  log "reboot cron entry added: tmux auto-starts and continuum restores sessions"
}

reload_running_server() {
  if tmux ls >/dev/null 2>&1; then
    tmux source-file "$TMUX_CONF"
    log "config reloaded in running tmux server"
  fi
}

main() {
  install_tmux
  install_clipboard_tool
  backup_existing_config
  install_config
  install_tpm
  install_plugins
  setup_boot_restore
  reload_running_server
  log "done: start tmux, save with prefix+Ctrl-s, restore with prefix+Ctrl-r"
}

main "$@"
