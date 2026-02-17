Save session context for the next developer/session.

## Instructions

1. Gather session context:
   - Review the conversation to summarize what was done this session
   - Check `git log --oneline -5` for commits made
   - Check `git diff --name-only` for uncommitted changes
   - Check `git status --short` for untracked files

2. Write/update `.claude/HANDOFF.md` with:
   ```markdown
   # Session Handoff

   _Last updated: YYYY-MM-DD_

   ## What Was Done
   (Summary of work completed this session)

   ## In Progress
   (Any partially completed work)

   ## Blockers
   (Any issues or decisions that need resolution)

   ## Next Steps
   (Concrete next actions for the next session)

   ## Uncommitted Changes
   (List of modified/untracked files, if any)
   ```

3. Read `docs/PROGRESS.md` and update it:
   - Mark any newly completed features as `[x]`
   - Move any started features to "In Progress"
   - Add any discovered work items

4. Remind the user:
   - "Remember to commit the handoff file: `git add .claude/HANDOFF.md docs/PROGRESS.md`"
   - If there are other uncommitted changes, remind about those too
