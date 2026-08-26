#!/usr/bin/osascript

-- Making the window before activating keeps it in the space you are in.
-- Without an explicit target a new window opens on Computer, ignoring the
-- "New Finder windows show" preference.

tell application "Finder"
	set newWindow to make new Finder window to home
	activate
	set sidebar width of newWindow to 0
end tell

-- Window > Fill honours the tiled window margins setting, which setting the
-- bounds directly would not, and Finder has no AppleScript command for it.
-- The Safari workflow waits for a window before clicking a menu; Finder needs
-- no wait, because it is always running and its menu bar is always there.

tell application "System Events" to tell process "Finder"
	click menu item "Fill" of menu "Window" of menu bar 1
end tell
