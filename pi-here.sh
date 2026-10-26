#!/bin/sh
# pi-here.sh <folder> [note] - open Ghostty running pi in <folder> (default: current dir).
# The Finder applet calls this; it also works straight from a terminal.
set -eu

dir=${1:-.}
case $dir in
	/*) ;;
	*) dir=$PWD/$dir ;;
esac
[ -d "$dir" ] || { echo "pi-here: not a folder: $dir" >&2; exit 1; }

pi=${PI_HERE_PI:-$HOME/.pi/agent/bin/pi}
[ -x "$pi" ] || { echo "pi-here: pi not executable: $pi" >&2; exit 1; }

if [ -e "$HOME/.pi/here-debug" ]; then
	printf '%s %s %s\n' "$(date '+%F %T')" "${2:-launch}" "$dir" \
		>> "$HOME/Library/Logs/pi-here.log"
fi

exec open -na Ghostty --args \
	--window-save-state=never \
	--working-directory="$dir" \
	--initial-command="/bin/zsh -lc 'exec $pi'"
