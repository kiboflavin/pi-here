# Pi Here

A tiny macOS droplet app that opens [Ghostty](https://ghostty.org) running [pi](https://pi.dev) in the folder you're looking at in Finder.

- **Click it from the Finder toolbar** → Ghostty + pi in the front Finder window's folder.
- **Drag a folder (or any file) onto it** → Ghostty + pi in that folder / the file's parent folder.
- **From a terminal** → `./pi-here.sh ~/some/project`

No shell setup, no `cd`, no typing paths.

Two parts: `pi-here.applescript` is just the Finder front end (folder lookup + droplet handler), and `pi-here.sh` does all the real work — validate the folder, find pi, log if asked, launch Ghostty. So the launcher is testable and usable outside Finder.

## Requirements

- macOS
- [Ghostty.app](https://ghostty.org) in `/Applications`
- pi at `~/.pi/agent/bin/pi` (resolved from `$HOME` at runtime; override with `PI_HERE_PI=/path/to/pi`)
- Build tools: `osacompile` (macOS), ImageMagick (`magick`) plus `sips`/`iconutil` for the icon

## Build

```sh
./build.sh
```

Creates (or replaces) `~/Applications/Pi Here.app`: compiles `pi-here.applescript`, copies `pi-here.sh` into the bundle's `Resources`, renders `icon.svg` into a full `.icns`, wires up `Info.plist`, and re-signs ad-hoc.

## Install

1. `./build.sh`
2. In Finder, open `~/Applications`, hold **⌘** and drag `Pi Here.app` into a Finder window's toolbar.
3. First click asks *"Pi Here wants to control Finder"* → **Allow**. Without it the folder lookup fails and nothing opens.
   (System Settings → Privacy & Security → Automation → Pi Here → Finder, if it was denied.)

You can also keep it in the Dock and drop folders onto it.

## From a terminal

The script works on its own — handy for keybindings, `pi-here.sh .`, or symlinking into `~/bin`:

```sh
./pi-here.sh                      # current directory
./pi-here.sh ~/Projects/whatever  # that directory
PI_HERE_PI=/opt/pi/bin/pi ./pi-here.sh .
```

The copy inside the app bundle is `~/Applications/Pi Here.app/Contents/Resources/pi-here.sh`, which is what the applet calls.

## How it works

The applet resolves the folder, in order: the front Finder window's `target` → Finder's `insertion location` → the Desktop when no window is open. It then calls the bundled script with that folder. The script launches a fresh Ghostty instance:

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

Still a terminal, not magic: shell startup files apply, so a `cd` in `.zshrc` would fight the requested folder. A `$HOME` containing spaces will confuse `--initial-command` (it is shell-split).

## Troubleshooting

Logging is off by default. To turn it on, create the marker file (no rebuild needed):

```sh
touch ~/.pi/here-debug
tail -f ~/Library/Logs/pi-here.log
```

Each entry shows the trigger (`click` / `drop` / `cli`), what Finder reported (`windows=… front=… target=… insertion=…`) and the folder that was chosen. Delete `~/.pi/here-debug` to switch logging off again.

No log entries at all means the app never ran — usually a stale toolbar item (⌘-drag the app in again) or a denied Automation prompt.

## Files

| File | Purpose |
| --- | --- |
| `pi-here.sh` | The launcher: checks the folder, resolves pi, optional logging, `open -na Ghostty` |
| `pi-here.applescript` | Finder front end: folder lookup and droplet handler, calls the script |
| `icon.svg` | Icon artwork (pi's mark on a dark rounded tile) |
| `build.sh` | Builds `~/Applications/Pi Here.app` from the files above |
