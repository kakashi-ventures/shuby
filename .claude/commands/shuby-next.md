Pick up the next work item intelligently and start working.

## Instructions

1. Read `docs/REMAINING-WORK.md` to find the highest-priority incomplete item
2. If `.claude/HANDOFF.md` exists, check for any in-progress work from the last session — resume that first
3. For the selected feature, read the relevant sections from:
   - `docs/SHUBY PIANO DI ABBONAMENTO.pdf` (subscription plan — source of truth for free/premium)
   - `docs/Shuby 1.0 - Specifiche di Prodotto.md` (product spec)
   - `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (functional analysis)
   - `docs/DECISIONS.md` for decisions with matching impact (note: file may be partially outdated)
   - Note `deferred` decisions that remove scope from v1.0
   - Note `to-confirm` decisions that need client confirmation before implementing
4. Scan the actual codebase for existing related code (models, controllers, views, tests) to verify the gap still exists
5. Check Figma ONLY if the selected item is a major visual work item (whole page, new screen, redesign, or multi-component refactor). For minor edits (single card/component/icon/badge/label/text tweak) and for non-visual work (backend, data-model, logic, tooling, tests), skip this step. When Figma is warranted, use the Node Map in `docs/FIGMA-REFERENCE.md` first (local, free) before any MCP call.
6. Propose a concrete implementation plan:
   - Files to create or modify
   - Key decisions to make
   - Figma nodeIds to reference
   - Estimated scope (small/medium/large)
7. Ask the user to confirm before starting implementation
