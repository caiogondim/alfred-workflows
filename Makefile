# Entrypoint for this repo: `make` alone lists the targets.
#
# The recipes are zsh scripts held in `define` blocks rather than written as
# recipe lines, because the make macOS ships is 3.81, which has no `.ONESHELL`
# and would otherwise run every line in a shell of its own. Each block is
# exported and handed to zsh whole, so `$$foo` below is a shell variable.

ZSH := /bin/zsh -euo pipefail -c

PLISTS  := $(wildcard */info.plist)
SCRIPTS := $(wildcard */scripts/*.applescript) $(wildcard scripts/*.applescript)

.DEFAULT_GOAL := help
.PHONY: help install fmt check

help: ## List the targets
	@grep -E '^[a-z]+:.*##' $(MAKEFILE_LIST) \
		| sed -E 's/:.*## /\t/' \
		| expand -t 12

# Alfred identifies a workflow by the UUID in its folder name, so each workflow
# pins its own in an `alfred-uuid` file. Changing one makes Alfred treat the
# workflow as a new install and lose its configuration.
define INSTALL
prefs_dir=$$(
	/usr/bin/plutil -extract current raw -o - \
		"$$HOME/Library/Application Support/Alfred/prefs.json"
)
workflows_dir="$$prefs_dir/workflows"

if [[ ! -d "$$prefs_dir" ]]; then
	print -u2 "Alfred preferences folder not found: $$prefs_dir"
	exit 1
fi

# A fresh Alfred install has no workflows folder until the first workflow
# is added, so create it rather than bail.
mkdir -p "$$workflows_dir"

# Everything is checked before anything is linked, so a repo that fails these
# checks leaves the previous install untouched.

typeset -A uuid_of owner_of

for source_dir in $(CURDIR)/*(N/); do
	[[ -f "$$source_dir/info.plist" ]] || continue

	name="$${source_dir:t}"
	uuid_file="$$source_dir/alfred-uuid"

	if [[ ! -f "$$uuid_file" ]]; then
		print -u2 "$$name has no alfred-uuid. Create one: uuidgen > '$$uuid_file'"
		exit 1
	fi

	uuid=$$(<"$$uuid_file")

	# Copying a workflow folder is the documented way to add one, so a
	# forgotten uuidgen is the likely mistake. Both would link to the same
	# target and one would silently win.
	if [[ -n "$${owner_of[$$uuid]-}" ]]; then
		print -u2 "$$name copied $${owner_of[$$uuid]}'s UUID. Run: uuidgen > '$$uuid_file'"
		exit 1
	fi

	target="$$workflows_dir/user.workflow.$$uuid"
	if [[ -e "$$target" && ! -L "$$target" ]]; then
		print -u2 "$$target is a real folder, not a link. Remove it in Alfred first."
		exit 1
	fi

	uuid_of[$$name]="$$uuid"
	owner_of[$$uuid]="$$name"
done

for name uuid in $${(kv)uuid_of}; do
	ln -sfn "$(CURDIR)/$$name" "$$workflows_dir/user.workflow.$$uuid"
	print "linked $$name -> user.workflow.$$uuid"
done

print "\nRelaunch Alfred to pick up new workflows."
endef
export INSTALL

install: ## Symlink the workflows into Alfred, so edits here are live
	@$(ZSH) "$$INSTALL"

define FMT
/usr/bin/plutil -convert xml1 $(PLISTS)
for plist in $(PLISTS); do
	print "converted $$plist"
done
endef
export FMT

fmt: ## Rewrite every info.plist as XML, so git can diff it
	@$(ZSH) "$$FMT"

# Every check runs, so one invocation reports everything that is wrong.
define CHECK
failed=0
fail() { print -u2 "$$1"; failed=1 }

for plist in $(PLISTS); do
	/usr/bin/plutil -lint -s "$$plist" || fail "$$plist is not a valid plist"

	[[ -f "$${plist:h}/alfred-uuid" ]] \
		|| fail "$${plist:h} has no alfred-uuid. Create one: uuidgen > '$${plist:h}/alfred-uuid'"

	# Editing a workflow through Alfred's own UI writes back through the
	# symlink, but as a binary plist, which git cannot diff. The rest of the
	# checks read the plist as text, so they wait for the next run.
	if [[ "$$(head -c 8 "$$plist")" == bplist00 ]]; then
		fail "$$plist is a binary plist. Run: make fmt"
		continue
	fi

	# Each script action names its file relative to the workflow folder.
	for ref in $${(f)"$$(grep -o '\./scripts/[^<]*' "$$plist" || true)"}; do
		[[ -f "$${plist:h}/$$ref" ]] || fail "$$plist references a missing $$ref"
	done
done

typeset -A owner_of
for uuid_file in */alfred-uuid(N); do
	name="$${uuid_file:h}"
	uuid=$$(<"$$uuid_file")
	if [[ -n "$${owner_of[$$uuid]-}" ]]; then
		fail "$$name copied $${owner_of[$$uuid]}'s UUID. Run: uuidgen > '$$uuid_file'"
	fi
	owner_of[$$uuid]="$$name"
done

tmp=$$(mktemp -d)
trap 'rm -rf "$$tmp"' EXIT
for script in $(SCRIPTS); do
	# osacompile resolves an app's terminology as it compiles, so a script
	# that says `new window` or `to do` only compiles where that app is
	# installed. CI has neither Ghostty nor Things.
	missing=()
	for app in $${(fu)"$$(grep -o 'application "[^"]*"' "$$script" | cut -d'"' -f2)"}; do
		osascript -e "id of application \"$$app\"" >/dev/null 2>&1 \
			|| missing+=("$$app")
	done

	if (( $$#missing )); then
		print "skipped $$script, no $${(j:, :)missing}"
		continue
	fi

	osacompile -o "$$tmp/out.scpt" "$$script" || fail "$$script does not compile"
	rm -rf "$$tmp/out.scpt"
done

# CI cannot exercise `make install`, having no Alfred to link into, so the
# recipe bodies are at least parsed. They are readable here because each
# `define` block above is exported for the recipe shells.
for recipe in INSTALL FMT CHECK; do
	print -r -- "$${(P)recipe}" | zsh -n \
		|| fail "the $$recipe recipe has a syntax error"
done

[[ $$failed -eq 0 ]] || exit 1
print "ok"
endef
export CHECK

check: ## Validate the workflows without touching Alfred
	@$(ZSH) "$$CHECK"
