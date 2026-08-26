#!/usr/bin/osascript

-- `launch` starts Things without the run event, so a first capture of the day
-- does not pop its window open in front of whatever you were doing.

on run argv
	launch application "Things3"
	tell application "Things3"
		make new to do with properties {name:(item 1 of argv)} ¬
			at beginning of list "Inbox"
	end tell
end run
