#!/usr/bin/osascript

-- Safari has no AppleScript command for private windows, so this clicks the
-- menu item. That needs Safari frontmost, and activating Safari would switch
-- spaces when all its windows are elsewhere. The throwaway document anchors
-- Safari to the current space first, then closes.

set wasRunning to application "Safari" is running
set anchorDoc to missing value

if wasRunning then
	tell application "Safari" to set anchorDoc to make new document
end if

tell application "Safari" to activate

repeat 60 times
	if (count of windows of application "Safari") > 0 then exit repeat
	delay 0.05
end repeat

tell application "System Events" to tell process "Safari"
	click menu item "New Private Window" of menu "File" of menu bar 1
end tell

if anchorDoc is not missing value then
	tell application "Safari" to close anchorDoc
else if (count of windows of application "Safari") = 2 then
	-- Safari was launched by this script and opened a window we did not ask
	-- for. Only close it when nothing else is open, so a restored session of
	-- several windows survives.
	tell application "Safari" to close window 2
end if

-- Fill applies to the front window, and the private window stays in front
-- while the anchor closes behind it, so this has to come last.

tell application "System Events" to tell process "Safari"
	click menu item "Fill" of menu "Window" of menu bar 1
end tell
