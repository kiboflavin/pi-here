#!/bin/sh
# pi-here.sh <folder> [note] - open Ghostty running pi in <folder> (default: current dir).
# The Finder applet calls this; it also works straight from a terminal.
set -eu

# GUI launches (Finder) get a minimal PATH; include the usual binary dirs.
PATH=$PATH:/opt/homebrew/bin:/usr/local/bin
export PATH

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

# Herdr running: open the folder as a workspace there instead of a new window.
if command -v herdr >/dev/null 2>&1 && command -v jq >/dev/null 2>&1 \
	&& herdr status server 2>/dev/null | grep -q '^status: running'; then
	if pane=$(herdr workspace create --cwd "$dir" --label "$(basename "$dir")" --focus \
			| jq -r '.result.root_pane.pane_id') \
		&& [ -n "$pane" ] && [ "$pane" != null ] \
		&& herdr pane run "$pane" "exec '$pi'" >/dev/null; then
		exit 0
	fi
	echo "pi-here: herdr launch failed, falling back to Ghostty" >&2
fi

exec open -na Ghostty --args \
	--window-save-state=never \
	--working-directory="$dir" \
	--initial-command="/bin/zsh -lc 'exec $pi'"
