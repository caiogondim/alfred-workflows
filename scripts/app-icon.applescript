#!/usr/bin/osascript
--
-- Write an app's icon to a PNG: app-icon.applescript <app path> <output path>
--
-- For apps whose icon is in an asset catalog rather than an .icns file, where
-- the sips recipe in the README has nothing to read. NSWorkspace does not care
-- where the icon comes from. The result is 1024px, so run sips afterwards to
-- match the 256px the other icons use.

use framework "Foundation"
use framework "AppKit"
use scripting additions

on run argv
	set appIcon to current application's NSWorkspace's sharedWorkspace()'s ¬
		iconForFile:(item 1 of argv)
	set bitmap to current application's NSBitmapImageRep's ¬
		imageRepWithData:(appIcon's TIFFRepresentation())

	-- `properties` is a reserved word, so the label needs escaping.
	set png to bitmap's representationUsingType:(current application's NSBitmapImageFileTypePNG) ¬
		|properties|:(current application's NSDictionary's dictionary())

	png's writeToFile:(item 2 of argv) atomically:true
	return (bitmap's pixelsWide() as text) & "x" & (bitmap's pixelsHigh() as text)
end run
