#!/usr/bin/osascript

-- Making the document before activating keeps the window in the space you are
-- in. Activating first would make macOS switch to whichever space already has
-- Safari windows, and the new window would land over there.

if application "Safari" is running then
	tell application "Safari" to make new document
	tell application "Safari" to activate
else
	tell application "Safari" to activate
	repeat 60 times
		if (count of windows of application "Safari") > 0 then exit repeat
		delay 0.05
	end repeat
end if
