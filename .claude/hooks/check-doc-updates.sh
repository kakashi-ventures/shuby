#!/usr/bin/env bash
# Stop hook — remind Claude to update team docs when new pattern/infrastructure
# files are introduced without corresponding updates to .claude/rules/*.md or
# CLAUDE.md.
#
# Conservative: only fires on CREATED files (untracked, staged-as-added, or
# added in the most recent commit), not on edits to existing files. A bug fix
# to an existing layout won't trigger; a new layout or helper will.
#
# Output: JSON with decision=block and a detailed reason. Claude sees this
# after completing a turn and has to reason about whether doc updates are
# needed before stopping.

set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-$(pwd)}" || exit 0

# Bail silently outside a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# --- Collect NEW files from three sources (session may be pre- or post-commit) ---
untracked=$(git ls-files --others --exclude-standard 2>/dev/null || true)
staged_added=$(git diff --cached --name-only --diff-filter=A 2>/dev/null || true)
last_commit_added=$(git log -1 --name-only --diff-filter=A --pretty=format: 2>/dev/null | grep -v '^$' || true)

new_files=$(printf '%s\n%s\n%s\n' "$untracked" "$staged_added" "$last_commit_added" \
  | grep -v '^$' | sort -u || true)

# Filter to pattern-level paths (places where team-wide conventions tend to live)
pattern_files=$(echo "$new_files" | grep -E '^(app/views/layouts/|app/helpers/|app/assets/tailwind/components/|app/javascript/controllers/|Gemfile$|config/initializers/)' || true)

# Nothing to flag
[ -z "$pattern_files" ] && exit 0

# --- Check whether any docs were updated this session ---
# "Updated" = created, staged, modified in working tree, or in most recent commit.
# Use per-file sources (not git status --porcelain, which collapses untracked dirs).
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
# The reason field includes the specific files so Claude has concrete context.
files_list=$(echo "$pattern_files" | sed 's/^/  - /' | awk '{printf "%s\\n", $0}')

cat <<JSON
{
  "decision": "block",
  "reason": "Pattern/infrastructure files were introduced without updates to .claude/rules/*.md or CLAUDE.md:\n\n${files_list}\nAsk yourself: does any of this introduce a team-wide convention that future sessions need documented?\n\n- YES → update or create the appropriate rule file under .claude/rules/ (see existing ones for format with 'paths:' frontmatter), then continue.\n- NO → briefly explain in your next message why no doc update is needed (e.g., 'just a minor fix to existing pattern'), then stop.\n\nIgnoring this silently leaves undocumented conventions that future sessions will miss."
}
JSON
exit 0
