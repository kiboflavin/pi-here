-- Finder front end for pi-here.sh: click (toolbar) or drop (folder/file).
-- All launching, checking and logging lives in the shell script.

on run
	set r to my finderFolder()
	my launchPi((item 1 of r), "click | " & (item 2 of r))
end run

on open theItems
	repeat with f in theItems
		set p to POSIX path of (f as alias)
		if p ends with "/" then
			my launchPi(text 1 thru -2 of p, "drop")
		else
			my launchPi(do shell script "dirname " & quoted form of p, "drop")
		end if
	end repeat
end open

on finderFolder()
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
	set folderPath to "-"
	if targetPath is not "-" then
		set folderPath to targetPath
	else if insertPath is not "-" then
		set folderPath to insertPath
	else
		set folderPath to POSIX path of (path to desktop folder)
	end if
	return {folderPath, "finder: windows=" & n & " front=" & winName & " target=" & targetPath & " insertion=" & insertPath}
end finderFolder

on launchPi(dirPath, src)
	set sh to (POSIX path of (path to me)) & "Contents/Resources/pi-here.sh"
	do shell script quoted form of sh & " " & quoted form of dirPath & " " & quoted form of src
end launchPi
