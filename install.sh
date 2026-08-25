#!/bin/zsh
#
# Symlinks the workflows in this repo into Alfred, so edits here are live.
#
# Alfred identifies a workflow by its folder name, so each entry below pins a
# fixed UUID. Changing one makes Alfred treat the workflow as a new install and
# lose its configuration.

set -euo pipefail

typeset -A WORKFLOWS=(
	safari-control 72A4D10C-ED2D-4588-A9E6-52995EE1988E
)

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

for name uuid in ${(kv)WORKFLOWS}; do
	source_dir="$repo_dir/$name"
	target="$workflows_dir/user.workflow.$uuid"

	if [[ ! -d "$source_dir" ]]; then
		print -u2 "No such workflow in this repo: $name"
		exit 1
	fi

	if [[ -e "$target" && ! -L "$target" ]]; then
		print -u2 "$target is a real folder, not a link. Remove it in Alfred first."
		exit 1
	fi

	chmod +x "$source_dir"/scripts/*.applescript(N)
	ln -sfn "$source_dir" "$target"
	print "linked $name -> user.workflow.$uuid"
done

print "\nRelaunch Alfred to pick up new workflows."
