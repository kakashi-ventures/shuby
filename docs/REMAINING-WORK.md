# Shuby v1.0 — Remaining Work

_Last verified by `/shuby-audit`: 2026-04-13_
_Source of truth: codebase scan against PRD + FA + DECISIONS + Subscription PDF_
_Full analysis: `docs/AUDIT-REPORT.md`_

## P0: Premium Feature Gating (LAUNCH BLOCKER)

- [ ] Create `Account#premium?` centralized helper (currently does not exist)
- [ ] Child limit: free = 1 child, premium = 3 (no enforcement in `ChildrenController#create`)
- [ ] Timeline gating: free = Past + Today only, premium = includes Future (no gating in `DevelopmentStagesController`)
- [ ] Paywall UI components (Italian: "Sblocca con Premium") with blurred/preview content
- [ ] Configure Stripe/payment processor with Shuby subscription plans
- [ ] AI chat limit: currently 30 msgs/month (DEC-005) — code matches, verify with client
- [x] AI chat rate limiting + CTA UI (`_rate_limit_reached.html.erb`)

## P0: GDPR Compliance (LAUNCH BLOCKER)

- [ ] Data export: user can download their personal data (right to portability)
- [ ] Account deletion: user can request account + all data deletion (right to erasure)
- [ ] Cookie consent banner
- [x] Data sharing consent toggle in onboarding + settings

## P1: Dashboard & Timeline Completeness

- [ ] 24-Hour Guidelines table: age-personalized movement/sleep/screen limits (PRD 3.2, 3.3)
- [ ] Dashboard: article band should be horizontal carousel of 4+ items (FA 3.6)
- [ ] Timeline: related content links (articles, activities) per age band (PRD 3.3)

## P1: Questionnaire Integration

- [ ] Warning signs: data exists in DB (`WarningSign` model + seeds), needs UI integration in questionnaire flow
- [ ] Stimulation activities: data exists in DB (`StimulationActivity` model + seeds), needs linking from questionnaire completion screen
- [ ] Verify post-completion flow matches DEC-010 (report link + AI link + activities)

## P1: Reports Enhancement

- [ ] PDF: WHO percentile chart visualization (data exists, no chart rendering in PDF)
- [ ] PDF: per-period report scope per DEC-014 (currently generates overall child report)
- [ ] Report section selection UI: parent chooses what to include (PRD 3.8)

## P1: Archive Improvements

- [ ] Full-text keyword search (FA 6.1.1.1 describes search bar in filter overlay)
- [ ] Article detail: scroll-overlap effect with sticky title (FA 6.2.1)
- [ ] Advice/activity detail: colored band header variant for no-image content (FA 6.2.2)

## P1: Notification System

- [ ] Notification delivery (push via APNS/FCM for iOS via Ruby Native)
- [ ] Notification triggers: measurement reminders, milestone alerts, content suggestions
- [ ] Notification preferences UI in settings
- [ ] In-app notification center

## P2: Visual & UX Polish

- [ ] Systematic Figma comparison for every screen (Dashboard, Timeline, Archive, Chat, Measurements, Onboarding, Child Profile)
- [ ] Dashboard header: verify scroll bg transition blue-to-white (FA 3.1)
- [ ] Measurement photo upload (PRD 3.5.2 — optional photo attachment)
- [ ] Unit of measure preference (metric/imperial) in settings
- [ ] Verify 3-state milestone box in dashboard (proposed/completed/all-done per FA 3.3)

## P2: Non-Functional Requirements

- [ ] General API rate limiting (Rack::Attack or equivalent — only auth endpoints currently limited)
- [ ] WCAG 2.1 Level AA accessibility audit
- [ ] Performance measurement: app load < 2s, API < 500ms p95
- [ ] Screen reader compatibility testing

## P3: Post-Launch / Deferred

- [ ] FAQ / Help center (PRD 3.9.4)
- [ ] Feedback / bug report mechanism (PRD 3.9.4)
- [ ] Hidden stages — algorithm-driven activation (DEC-013: deferred)
- [ ] Sleep quality tracking (DEC-019: deferred)
- [ ] Gift subscriptions (DEC-016: to-do)
- [ ] Multi-caregiver support (DEC-004: single in v1.0)
- [ ] Proactive AI suggestions — premium feature (Phase 2)
- [ ] Advanced insights / predictive insights (Phase 2)
- [ ] Pre/post feeding weight premium gating
- [ ] Premium PDF report enhancements (evolved layout, annual summary, auto-diary)

## Decisions Needing Client Confirmation

| ID | Topic | Current Code | Conflict |
|---|---|---|---|
| DEC-001 | Sex options (M/F/INTERSEX) | Need to verify child.rb enum | PRD says "Prefer not to say" |
| DEC-005 | AI free limit | 30 msgs/month | PDF says 8, PRD says 10 |
| DEC-012 | Intelligent stage proposal | Daily rotation only | May need smarter algorithm |
| DEC-015 | Free content policy | All content free | PRD says 20-30 free articles |
| DEC-017 | Italian only v1.0 | Italian only, partial translations | EN/FR timeline post-launch |
| — | Premium pricing | Not configured | PRD: 7.99/mo, PDF: 6/mo |

## What's Working Well (Completed)

- Child management with corrected age, health profiles, soft delete
- WHO percentile calculations + interactive growth charts (Chart.js)
- 5-area developmental questionnaires with age-band versioning + stories UI
- Timeline age band navigation with past/current/future states
- Archive with 3 content types, categories, age filtering, favorites
- AI chat with OpenAI streaming, RAG, specialist routing, rate limiting
- Dashboard with daily milestone rotation, content rotation, measurement cards
- PDF pediatrician reports (Prawn)
- Onboarding flow with family profile
- Ruby Native iOS integration (tab bar, safe areas, haptics)
- Multi-tenancy via Account scoping + Pundit policies
- Italian UI throughout
