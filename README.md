# Pi Here

A tiny macOS droplet app that opens [Ghostty](https://ghostty.org) running [pi](https://pi.dev) in the folder you're looking at in Finder.

- **Click it from the Finder toolbar** → Ghostty + pi in the front Finder window's folder.
- **Drag a folder (or any file) onto it** → Ghostty + pi in that folder / the file's parent folder.

No shell setup, no `cd`, no typing paths.

## Requirements

- macOS
- [Ghostty.app](https://ghostty.org) in `/Applications`
- pi installed at `~/.pi/agent/bin/pi` (its path is resolved from `$HOME` at runtime, never hardcoded)
- Build tools: `osacompile` (macOS), ImageMagick (`magick`) and `sips`/`iconutil` for the icon

## Build

```sh
./build.sh
```

Creates (or replaces) `~/Applications/Pi Here.app`: compiles `pi-here.applescript`, renders `icon.svg` into a full `.icns`, wires up `Info.plist`, and re-signs ad-hoc.

## Install

1. `./build.sh`
2. In Finder, open `~/Applications`, hold **⌘** and drag `Pi Here.app` into a Finder window's toolbar.
3. First click asks *"Pi Here wants to control Finder"* → **Allow**. Without it the folder lookup fails and nothing opens.
   (System Settings → Privacy & Security → Automation → Pi Here → Finder, if it was denied.)

You can also keep it in the Dock and drop folders onto it.

## How it works

Folder resolution, in order: the front Finder window's `target` → Finder's `insertion location` → the Desktop when no window is open.

Then it launches a fresh Ghostty instance:

```sh
open -na Ghostty --args \
  --window-save-state=never \
  --working-directory=<folder> \
  --initial-command="/bin/zsh -lc 'exec ~/.pi/agent/bin/pi'"
```

Each flag earns its place:

- `-n` — a separate Ghostty instance per click, so the args apply to this launch only.
- `--window-save-state=never` — otherwise Ghostty restores the previous session's windows/tabs alongside the new one (extra tabs, sometimes a failed "Ghostty failed to launch the requested command" window).
- `--initial-command` — runs pi in the first surface only. `--command` (or `-e`) would also make ⌘N / ⌘T spawn pi instead of a normal shell.
- `/bin/zsh -lc` — a GUI-launched Ghostty inherits a minimal `PATH` (`/usr/bin:/bin:/usr/sbin:/sbin`), so pi's `#!/usr/bin/env node` fails with `env: node: No such file or directory` when node comes from Homebrew. A login zsh sources your profile and builds the real `PATH` first.

Still a terminal, not magic: `shell`-level startup files apply, so a `cd` in `.zshrc` would fight the requested folder.

## Troubleshooting

Every launch is logged:

```sh
tail -f ~/Library/Logs/pi-here.log
```

Each entry shows what Finder reported (`windows=… front=… target=… insertion=…`), the folder that was chosen, and the exact `open` command that ran. An empty log means the app never ran — usually a stale toolbar item (⌘-drag the app in again) or a denied Automation prompt.

## Files

| File | Purpose |
| --- | --- |
| `pi-here.applescript` | The applet: Finder lookup, droplet handler, Ghostty launch, logging |
| `icon.svg` | Icon artwork (pi's mark on a dark rounded tile) |
| `build.sh` | Builds `~/Applications/Pi Here.app` from the two files above |
