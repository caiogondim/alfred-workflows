#!/bin/zsh
#
# Symlinks the workflows in this repo into Alfred, so edits here are live.
#
# Alfred identifies a workflow by the UUID in its folder name, so each workflow
# pins its own in an `alfred-uuid` file. Changing one makes Alfred treat the
# workflow as a new install and lose its configuration.

set -euo pipefail

repo_dir="${0:A:h}"

prefs_dir=$(
	/usr/bin/plutil -extract current raw -o - \
		"$HOME/Library/Application Support/Alfred/prefs.json"
)
workflows_dir="$prefs_dir/workflows"

if [[ ! -d "$workflows_dir" ]]; then
	print -u2 "Alfred workflows folder not found: $workflows_dir"
	exit 1
fi

for source_dir in "$repo_dir"/*(N/); do
	[[ -f "$source_dir/info.plist" ]] || continue

	name="${source_dir:t}"
	uuid_file="$source_dir/alfred-uuid"

	if [[ ! -f "$uuid_file" ]]; then
		print -u2 "$name has no alfred-uuid. Create one: uuidgen > '$uuid_file'"
		exit 1
	fi

	uuid=$(<"$uuid_file")
	target="$workflows_dir/user.workflow.$uuid"

	if [[ -e "$target" && ! -L "$target" ]]; then
		print -u2 "$target is a real folder, not a link. Remove it in Alfred first."
		exit 1
	fi

	ln -sfn "$source_dir" "$target"
	print "linked $name -> user.workflow.$uuid"
done

print "\nRelaunch Alfred to pick up new workflows."
