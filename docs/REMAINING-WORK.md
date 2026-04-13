# Shuby v1.0 — Remaining Work

_Last verified by `/shuby-audit`: not yet run_
_Source of truth: codebase scan against PRD + FA + DECISIONS + Subscription PDF + Figma_

## P0: Figma Design Alignment (VISUAL QUALITY)
- [ ] Systematic comparison of every screen vs Figma
- [ ] Dashboard, Timeline, Archive, Chat, Measurements, Onboarding, Child Profile
- [ ] Fix layout, spacing, colors, typography discrepancies

## P0: Premium Feature Gating (LAUNCH BLOCKER)
- [ ] Account#premium? helper using Pay gem subscription state
- [ ] Free limits: 1 child, 0 extra caregivers, 8 AI questions/mo, Timeline past+today only
- [ ] Premium unlocks: 3 children, 2 caregivers, unlimited AI, future timeline, specialist content
- [ ] Paywall UI (Italian: "Sblocca con Premium")
- [ ] Stripe integration (6€/mese)

## P1: Notification System
- [ ] Measurement reminders, milestone alerts
- [ ] In-app notification center UI
- [ ] iOS push via Ruby Native (`action_push_native`)

## P2: Advanced Analytics
- [ ] Development progress radar charts (5 areas)
- [ ] Growth velocity trends

## P3: Technical Debt
- [ ] Test coverage for critical paths
- [ ] WCAG 2.1 Level AA audit
- [ ] Performance: <2s load, <500ms API p95
- [ ] GDPR: data export

## Gap Details
(Populated by `/shuby-audit` — see `docs/AUDIT-REPORT.md` for full analysis)
