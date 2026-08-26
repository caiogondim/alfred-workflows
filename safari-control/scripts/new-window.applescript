#!/usr/bin/osascript

-- Making the document before activating keeps the window in the space you are
-- in. Activating first would make macOS switch to whichever space already has
-- Safari windows, and the new window would land over there.

if application "Safari" is running then
	tell application "Safari" to make new document
	tell application "Safari" to activate
else
	tell application "Safari" to activate
	-- A cold launch opens its window on its own schedule, and Fill below needs
	-- that window to exist before it can size it.
	repeat 60 times
		if (count of windows of application "Safari") > 0 then exit repeat
		delay 0.05
	end repeat
end if

-- Window > Fill honours the tiled window margins setting, which setting the
-- bounds directly would not, and Safari has no AppleScript command for it.

tell application "System Events" to tell process "Safari"
	click menu item "Fill" of menu "Window" of menu bar 1
end tell
