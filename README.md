# tmux-setup

One-command tmux setup with session persistence across reboots.

## Install

```bash
git clone https://github.com/dangvansam/tmux-setup.git
cd tmux-setup
bash setup.sh
```

## What it does

- Installs tmux and xclip (apt, skips if already present)
- Backs up any existing `~/.tmux.conf` before replacing it
- Installs [TPM](https://github.com/tmux-plugins/tpm) and all plugins non-interactively
- Adds an `@reboot` cron entry so the tmux server auto-starts after reboot and continuum restores all sessions
- Reloads config into a running tmux server if one exists

## Plugins

| Plugin | Purpose |
|---|---|
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions, windows, panes, working dirs, pane contents |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save every 15 minutes, auto-restore on tmux start |
| [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat) | Regex search in scrollback, fast match selection |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Copy to system clipboard |
| [tmux-open](https://github.com/tmux-plugins/tmux-open) | Open highlighted file or URL |

## Key bindings

Prefix is the default `Ctrl+b`.

| Keys | Action |
|---|---|
| `prefix + Ctrl-s` | Save environment manually |
| `prefix + Ctrl-r` | Restore environment manually |
| `prefix + /` | Regex search (copycat) |
| `prefix + Ctrl-f` | Search files (copycat) |
| `prefix + Ctrl-u` | Search URLs (copycat) |
| `n` / `N` | Jump between matches |
| `y` (copy mode) | Copy selection to clipboard (yank) |
| `o` (copy mode) | Open highlighted file/URL (open) |
| `Ctrl-o` (copy mode) | Open highlighted file in `$EDITOR` (open) |
| `prefix + I` | Install new plugins |
| `prefix + U` | Update plugins |
| `prefix + r` | Reload tmux.conf |

## Notes

- Continuum auto-saves every 15 minutes; saves live in `~/.local/share/tmux/resurrect/`
- Resurrect restores layout, working directories and pane contents, not running programs; to auto-restart specific programs add e.g. `set -g @resurrect-processes 'ssh htop'` to `tmux.conf`
- Without xclip/xsel, clipboard over SSH still works via OSC 52 if the terminal supports it (iTerm2, kitty, alacritty, wezterm)
- Optional systemd alternative to the cron entry: `sudo loginctl enable-linger $USER`, then continuum's `@continuum-boot 'on'` manages `~/.config/systemd/user/tmux.service`
