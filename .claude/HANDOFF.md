# Session Handoff

_Last updated: 2026-04-13_

## What Was Done

### Audit
- Full gap analysis of codebase vs PRD + FA + Subscription PDF + DECISIONS.md
- Generated `docs/AUDIT-REPORT.md` with structured tables
- Updated `docs/REMAINING-WORK.md` with Figma-verified priorities

### P0: Premium Feature Gating (DONE)
- `Account#premium?` + `children_limit` in `Account::Billing`
- Child limit enforcement: `ChildPolicy#create?` + controller + views (index, new, child selector)
- Timeline future gating: locked pills (CSS + JS intercept) + server-side guard in controller
- Reusable `shared/_paywall_banner.html.erb` (3 icon variants, Italian copy)
- Madmin admin toggle: "Rendi/Rimuovi Premium" via fake processor
- Refactored `User#chat_premium?` to delegate to `Account#premium?`

### P0: GDPR Compliance (DONE for beta)
- `GdprDataExportService` — JSON download with profile, children, measurements, questionnaires, chats
- Account deletion via Devise with email confirmation
- Privacy settings page redesigned with export + deletion sections
- Cookie consent skipped (no tracking cookies in use)

### P1: Archive & Dashboard Improvements (DONE)
- Dashboard article carousel: bumped from 3 to 4 items
- Article detail: scroll-overlap effect with sticky title (Stimulus `article-scroll` controller)
- Three hero variants: image (articles), white (activities), colored band (tips/games)
- "Articoli collegati" horizontal carousel at bottom of detail pages
- Tip metadata partial (author, publisher, illustrator, ISBN)

### Team Rules & Process
- `.claude/rules/progress-tracking.md` — update REMAINING-WORK.md after every commit
- `.claude/rules/figma-alignment.md` — Figma-first verification before scheduling UI work
- `.claude/rules/fa-ui-behaviors.md` — FA screen-level details for all team members
- `.claude/rules/premium-gating.md` — full matrix + Jumpstart helpers + patterns
- `.claude/rules/ruby-native-ios.md` — added auto_route `/users/` pitfall

## In Progress
(Nothing in progress — all work committed and pushed)

## Blockers
- **Stripe plans**: pricing not confirmed (PRD: 7.99/mo, PDF: 6/mo) — cannot configure actual plans
- **AI chat limit**: code has 30 msgs/month (DEC-005), PDF says 8 — needs client confirmation
- **"Tappe di sviluppo collegate"**: needs content-to-development-area association model, not yet designed

## Next Steps
1. Run `/shuby-next` to pick the next P1 item
2. Remaining P1 (Figma-verified):
   - Archive full-text keyword search (FA 6.1.1.1)
   - Questionnaire integration: warning signs + stimulation activities UI
   - Reports: PDF percentile chart rendering
3. Items needing design team input:
   - Timeline related content links (not in Figma)
   - "Tappe di sviluppo collegate" in content detail (needs model association)
4. Run `/shuby-audit` periodically to re-verify state

## Uncommitted Changes
(None — working tree clean, all pushed to origin/main)

## Recent Commits
```
48899fe9 feat: P1 archive improvements — scroll-overlap, hero variants, related articles
bad13f68 docs: refine Figma-first rule
482ff86b docs: cross-check P1 items against Figma
e6551081 chore: promote local learnings to shared team rules
6e56193e chore: add progress-tracking rule for team workflow
0892c383 docs: update REMAINING-WORK.md with premium gating and GDPR progress
1daf8910 feat: add GDPR data export and account deletion to privacy settings
10f4e7f9 feat: implement premium feature gating infrastructure
b1d4087e docs: add comprehensive audit report and update remaining work
```
