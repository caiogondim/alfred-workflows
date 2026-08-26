#!/usr/bin/osascript

-- Making the window before activating keeps it in the space you are in.
-- Activating first would make macOS switch to whichever space already has
-- Chrome windows, and the new window would land over there.

if application "Google Chrome" is running then
	tell application "Google Chrome" to make new window
	tell application "Google Chrome" to activate
else
	tell application "Google Chrome" to activate
	-- A cold launch opens its window on its own schedule, and Fill below needs
	-- that window to exist before it can size it.
	repeat 60 times
		if (count of windows of application "Google Chrome") > 0 then exit repeat
		delay 0.05
	end repeat
end if

-- Window > Fill honours the tiled window margins setting, which setting the
-- bounds directly would not, and Chrome has no AppleScript command for it.

tell application "System Events" to tell process "Google Chrome"
	click menu item "Fill" of menu "Window" of menu bar 1
end tell
