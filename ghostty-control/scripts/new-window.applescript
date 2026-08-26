#!/usr/bin/osascript

-- `launch` starts Ghostty without the run event, so Ghostty does not open a
-- window of its own and this script owns the only one. Making the window
-- before activating keeps it in the space you are in, because activating
-- first would make macOS switch to whichever space already has Ghostty.

launch application "Ghostty"

tell application "Ghostty"
	new window
	activate
end tell
