# alfred-workflows

My [Alfred](https://www.alfredapp.com) workflows, one folder each. Each folder
holds an `info.plist` in XML rather than Alfred's binary format, so git can diff
it, and keeps its scripts as plain files instead of strings inside the plist.

## Install

```sh
./install.sh
```

This symlinks each workflow folder into Alfred and prints what it linked.
Relaunch Alfred afterwards. Because the workflows are links, an edit in this
repo takes effect on the next trigger — no reinstall.

Editing a workflow through Alfred's own UI writes back through the symlink, but
it rewrites `info.plist` as a binary plist. Run
`plutil -convert xml1 <workflow>/info.plist` before committing.

`install.sh` treats every folder holding an `info.plist` as a workflow. To add
one, copy the nearest existing workflow and then:

```sh
uuidgen > <workflow>/alfred-uuid          # Alfred's identity for it; never change it later
sips -s format png --resampleHeightWidthMax 256 \
  /Applications/<App>.app/Contents/Resources/<Icon>.icns \
  --out <workflow>/icon.png
```

Then edit `info.plist`: `bundleid`, `name`, `description`, `readme`, and the
keyword object's `keyword`, `text`, and `subtext`. The object UUIDs inside a
plist only have to be unique within that one file, so copied ones are fine.

## Workflows

Every workflow here opens its window in the space you are currently in, and
works when its app is not running. They all depend on ordering: the window is
made first, and the app is activated only after. Activating first makes macOS
switch to whichever space already holds that app's windows, and the new window
lands over there.

### Finder Control

| Keyword | Action |
| --- | --- |
| `fw` | New Finder window at home, filled, no sidebar |

The window is sized by triggering `Window ▸ Fill` rather than by setting its
bounds, so it follows whatever tiled window margins you have set. Fill is a
menu action with no AppleScript equivalent, hence the System Events click.

### Ghostty Control

| Keyword | Action |
| --- | --- |
| `gw` | New Ghostty window |

Ghostty has its own `new window` AppleScript command, so this one needs no UI
scripting.

### Safari Control

| Keyword | Action |
| --- | --- |
| `sw` | New Safari window |
| `swp` | New private Safari window |

Safari has no AppleScript command for private browsing, so `swp` clicks
`File ▸ New Private Window` instead. To keep that click from switching spaces,
it anchors Safari to the current space with a throwaway window that it closes
right after.

## Permissions

Alfred needs, under System Settings ▸ Privacy & Security:

- **Automation** → Finder, Ghostty, Safari, and System Events
- **Accessibility** → for the workflows that click menu items
