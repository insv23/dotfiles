tell application "Finder"
	if (count of Finder windows) > 0 then
		set currentDir to POSIX path of (target of front Finder window as alias)
	else
		set currentDir to POSIX path of (path to desktop folder as alias)
	end if
end tell

set kittyBin to "/Applications/kitty.app/Contents/MacOS/kitty"
set cmd to quoted form of kittyBin & " @ --to unix:/tmp/kitty launch --type=tab --cwd " & quoted form of currentDir
do shell script cmd
