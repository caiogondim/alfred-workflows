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

if [[ ! -d "$prefs_dir" ]]; then
	print -u2 "Alfred preferences folder not found: $prefs_dir"
	exit 1
fi

# A fresh Alfred install has no workflows folder until the first workflow
# is added, so create it rather than bail.
mkdir -p "$workflows_dir"

# Everything is checked before anything is linked, so a repo that fails these
# checks leaves the previous install untouched.

typeset -A uuid_of owner_of

for source_dir in "$repo_dir"/*(N/); do
	[[ -f "$source_dir/info.plist" ]] || continue

	name="${source_dir:t}"
	uuid_file="$source_dir/alfred-uuid"

	if [[ ! -f "$uuid_file" ]]; then
		print -u2 "$name has no alfred-uuid. Create one: uuidgen > '$uuid_file'"
		exit 1
	fi

	uuid=$(<"$uuid_file")

	# Copying a workflow folder is the documented way to add one, so a
	# forgotten uuidgen is the likely mistake. Both would link to the same
	# target and one would silently win.
	if [[ -n "${owner_of[$uuid]-}" ]]; then
		print -u2 "$name copied ${owner_of[$uuid]}'s UUID. Run: uuidgen > '$uuid_file'"
		exit 1
	fi

	target="$workflows_dir/user.workflow.$uuid"
	if [[ -e "$target" && ! -L "$target" ]]; then
		print -u2 "$target is a real folder, not a link. Remove it in Alfred first."
		exit 1
	fi

	uuid_of[$name]="$uuid"
	owner_of[$uuid]="$name"
done

for name uuid in ${(kv)uuid_of}; do
	ln -sfn "$repo_dir/$name" "$workflows_dir/user.workflow.$uuid"
	print "linked $name -> user.workflow.$uuid"
done

print "\nRelaunch Alfred to pick up new workflows."
