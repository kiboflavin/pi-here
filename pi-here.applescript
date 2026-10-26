-- Click (Finder toolbar) -> Ghostty+pi in the front Finder folder.
-- Drop a folder or file -> Ghostty+pi there / in its parent folder.
-- Diagnose: tail -f ~/Library/Logs/pi-here.log

on run
	try
		set f to my frontFolder()
		my logLine("click -> folder [" & f & "]")
		my launchPi(f)
	on error errMsg number errNum
		my logLine("click FAILED " & errNum & ": " & errMsg)
		error errMsg number errNum
	end try
end run

on open theItems
	repeat with f in theItems
		try
			set p to POSIX path of (f as alias)
			if p ends with "/" then
				set dirPath to text 1 thru -2 of p
			else
				set dirPath to do shell script "dirname " & quoted form of p
			end if
			my logLine("drop [" & p & "] -> folder [" & dirPath & "]")
			my launchPi(dirPath)
		on error errMsg number errNum
			my logLine("drop FAILED " & errNum & ": " & errMsg)
		end try
	end repeat
end open

on frontFolder()
	set n to 0
	set winName to "-"
	set targetPath to "-"
	set insertPath to "-"
	tell application "Finder"
		try
			set n to count of windows
			if n > 0 then set winName to name of front window
		end try
		if n > 0 then
			try
				set targetPath to POSIX path of (target of front window as alias)
			end try
		end if
		try
			set insertPath to POSIX path of (insertion location as alias)
		end try
	end tell
	my logLine("finder: windows=" & n & " front=" & winName & " target=" & targetPath & " insertion=" & insertPath)
	if targetPath is not "-" then return targetPath
	if insertPath is not "-" then return insertPath
	return POSIX path of (path to desktop folder)
end frontFolder

on launchPi(dirPath)
	set piPath to (POSIX path of (path to home folder)) & ".pi/agent/bin/pi"
	set cmd to "open -na Ghostty --args --window-save-state=never --working-directory=" & quoted form of dirPath & " --initial-command=" & quoted form of ("/bin/zsh -lc 'exec " & piPath & "'")
	my logLine("exec: " & cmd)
	do shell script cmd
end launchPi

on logLine(msg)
	try
		set home to POSIX path of (path to home folder)
		do shell script "test -f " & quoted form of (home & ".pi/here-debug") & " && printf '%s %s\\n' \"$(date '+%F %T')\" " & quoted form of msg & " >> " & quoted form of (home & "Library/Logs/pi-here.log") & " || true"
	end try
end logLine
