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

- Continuum auto-saves every 5 minutes; saves live in `~/.local/share/tmux/resurrect/`
- Resurrect restores layout, working directories and pane contents; `@resurrect-processes` auto-restarts `ssh`, `htop`, `btop`, any `nvidia-smi` variant (full original command), and Claude Code — extend the list in `tmux.conf` for other programs
- Claude Code restore is per pane: on every save, `scripts/claude-save-sessions.sh` (resurrect `post-save-all` hook) records each pane's session ID from `~/.claude/sessions/<pid>.json` into `~/.local/share/tmux/resurrect/claude-sessions.tsv`; on restore, `scripts/claude-resume.sh` runs `claude --resume <id>` for that exact pane, so split panes in the same directory no longer collapse onto one conversation. Falls back to `claude --continue` when no ID was recorded. Check what a pane would run with `TMUX_PANE=%3 ~/.tmux/scripts/claude-resume.sh --print`
- Without xclip/xsel, clipboard over SSH still works via OSC 52 if the terminal supports it (iTerm2, kitty, alacritty, wezterm)
- Optional systemd alternative to the cron entry: `sudo loginctl enable-linger $USER`, then continuum's `@continuum-boot 'on'` manages `~/.config/systemd/user/tmux.service`
