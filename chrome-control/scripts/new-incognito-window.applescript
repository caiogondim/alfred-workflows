#!/usr/bin/osascript

-- Chrome sets `mode` only at creation, so the incognito window is made in one
-- call, and making it before activating keeps it in the space you are in.

set wasRunning to application "Google Chrome" is running
set startupWindow to missing value

if not wasRunning then
	-- Chrome opens a window of its own when it launches, and `launch` does not
	-- suppress it the way it does for Ghostty and Things. Hold a reference to
	-- that window rather than closing one by index afterwards, and leave a
	-- restored session of several windows alone.
	tell application "Google Chrome" to activate
	repeat 60 times
		if (count of windows of application "Google Chrome") > 0 then exit repeat
		delay 0.05
	end repeat
	tell application "Google Chrome"
		if (count windows) = 1 then set startupWindow to window 1
	end tell
end if

tell application "Google Chrome"
	make new window with properties {mode:"incognito"}
	activate
end tell

if startupWindow is not missing value then
	tell application "Google Chrome" to close startupWindow
end if

tell application "System Events" to tell process "Google Chrome"
	click menu item "Fill" of menu "Window" of menu bar 1
end tell
