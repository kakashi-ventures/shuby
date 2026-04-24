#!/usr/bin/env bash
# Stop hook — remind Claude to update team docs when new pattern/infrastructure
# files are introduced without corresponding updates to .claude/rules/*.md or
# CLAUDE.md.
#
# Conservative: only fires on CREATED files still in the working tree
# (untracked or staged-as-added), not on edits to existing files and not on
# files already landed in a prior commit. A bug fix to an existing layout
# won't trigger; a new layout or helper will.
#
# Escape hatch: Claude can dismiss a "no docs needed" case by creating
# `.claude/.hook-state/ack-no-docs-<sig>` where <sig> is the sha1 of the
# flagged file list. The directory is gitignored so acks don't leak.
#
# Output: JSON with decision=block and a detailed reason. Claude sees this
# after completing a turn and has to reason about whether doc updates are
# needed before stopping.

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0

# Bail silently outside a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# --- Collect NEW files from working tree (untracked + staged-added) ---
# Intentionally excludes `git log -1 --diff-filter=A`: HEAD is sticky across
# a session, so once a commit introduces an unflagged pattern file every
# subsequent stop attempt would re-block, creating an infinite loop.
untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)
staged_added=$(git diff --cached --name-only --diff-filter=A 2>/dev/null || true)

new_files=$(printf '%s\n%s\n' "$untracked" "$staged_added" \
  | grep -v '^$' | sort -u || true)

# Filter to pattern-level paths (places where team-wide conventions tend to live)
pattern_files=$(echo "$new_files" | grep -E '^(app/views/layouts/|app/helpers/|app/assets/tailwind/components/|app/javascript/controllers/|Gemfile$|config/initializers/)' || true)

# Nothing to flag
[ -z "$pattern_files" ] && exit 0

# --- Check for a per-signature ack file (Claude said "no docs needed") ---
sig=$(printf '%s' "$pattern_files" | shasum -a 1 | awk '{print $1}')
ack_file=".claude/.hook-state/ack-no-docs-${sig}"
[ -f "$ack_file" ] && exit 0

# --- Check whether any docs were updated this session ---
# "Updated" = created, staged, modified in working tree, or in most recent commit.
doc_untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)
doc_unstaged=$(git diff --name-only 2>/dev/null || true)
doc_staged=$(git diff --cached --name-only 2>/dev/null || true)
doc_last_commit=$(git log -1 --name-only --pretty=format: 2>/dev/null || true)

doc_changes=$(printf '%s\n%s\n%s\n%s\n' \
    "$doc_untracked" "$doc_unstaged" "$doc_staged" "$doc_last_commit" \
  | grep -v '^$' \
  | sort -u \
  | grep -E '^(\.claude/rules/.*\.md|CLAUDE\.md)$' || true)

# Docs already updated — assume Claude handled it
[ -n "$doc_changes" ] && exit 0

# --- Emit blocking reminder as JSON ---
# The reason field includes the specific files AND the exact ack command so
# Claude has a concrete dismissal path when the honest answer is "no docs".
files_list=$(echo "$pattern_files" | sed 's/^/  - /' | awk '{printf "%s\\n", $0}')
ack_cmd="mkdir -p .claude/.hook-state && touch ${ack_file}"

cat <<JSON
{
  "decision": "block",
  "reason": "Pattern/infrastructure files were introduced without updates to .claude/rules/*.md or CLAUDE.md:\n\n${files_list}\nAsk yourself: does any of this introduce a team-wide convention that future sessions need documented?\n\n- YES → update or create the appropriate rule file under .claude/rules/ (see existing ones for format with 'paths:' frontmatter), then continue.\n- NO → run this exact command to ack and then stop:\n    ${ack_cmd}\n\nIgnoring this silently leaves undocumented conventions that future sessions will miss."
}
JSON
exit 0
