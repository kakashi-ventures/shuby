# Shuby v1.0 — Remaining Work

_Last verified by `/shuby-audit`: 2026-04-13_
_Source of truth: codebase scan against PRD + FA + DECISIONS + Subscription PDF_
_Full analysis: `docs/AUDIT-REPORT.md`_

## P0: Premium Feature Gating (LAUNCH BLOCKER)

- [x] Create `Account#premium?` centralized helper (`Account::Billing`)
- [x] `Account#children_limit` (free=1, premium=3)
- [x] Child limit enforcement in `ChildPolicy#create?` + controller + views
- [x] Timeline gating: future pills locked for free users (JS + CSS + server guard)
- [x] Paywall UI: reusable `shared/_paywall_banner.html.erb` (Italian, 3 icon variants)
- [x] Madmin admin toggle: "Rendi/Rimuovi Premium" on account page
- [x] AI chat rate limiting + CTA UI (`_rate_limit_reached.html.erb`)
- [ ] Configure Stripe with actual Shuby plans (blocked on pricing confirmation: 6 vs 7.99/mo)
- [ ] AI chat limit: currently 30 msgs/month (DEC-005) — verify with client (PDF says 8)
- [ ] AI chat: daily cap (1 question/day) not implemented — Subscription PDF row "AI-Helper" (free) reads "8 domande al mese, **oppure** 1 domanda al giorno". Currently only the monthly bound exists in `User::ChatRateLimit`. Suggest pre-prepping `DAILY_MESSAGE_LIMIT = nil` so the client decision becomes a one-line flip.

## P0: GDPR Compliance (LAUNCH BLOCKER)

- [x] Data export: JSON download with all personal data (`GdprDataExportService`)
- [x] Account deletion: confirmation dialog with email verification (Devise)
- [x] Data sharing consent toggle in onboarding + settings
- [x] Privacy page redesigned with export + deletion sections
- [ ] Cookie consent banner (skipped for beta — no tracking cookies in use)

## P1: Dashboard & Timeline Completeness

- [x] ~~24-Hour Guidelines table~~ — Not in Figma as separate table. Guidelines embedded in growth phase narrative text. Verify growth phase texts include these tips.
- [x] Dashboard: article carousel bumped to 4 items (was 3, carousel already horizontal)
- [ ] Timeline: related content links per age band (PRD 3.3) — **needs design**: not in current Figma, ask design team if intended for v1.0

## P1: Questionnaire Integration

- [x] Warning signs: show page has `_section_warning_signs` partial; completion slide shows attention hint when `needs_attention?`
- [x] Stimulation activities: show page has `_section_stimulation_activities` partial; completion slide links to activities section
- [x] Post-completion flow matches DEC-010: report PDF + AI link + activities link + attention hint
- [ ] **Seed audit**: weekly age-band granularity for months 0–2 (FA requires per-week, current seed is monthly only)
- [ ] **Question content**: per-question `uncertain_label` copy from product/design (column added in `worktree-elegant-mixing-eclipse`; falls back to "Non lo so" when nil)
- [ ] **Question illustrations**: design-team delivery of remaining per-question PNGs under `app/assets/images/shuby/illustrations/questions/<area_slug>/<key>.png` (only `comunicazione-linguaggio` months 0–10 currently shipped)

## P1: Reports Enhancement

- [x] PDF: per-period report scope per DEC-014 — already done (report shows latest data per type)
- [ ] Report section selection UI: parent chooses what to include (PRD 3.8)
- ~~PDF: WHO percentile chart in PDF~~ — **deferred, Premium-only** (PRD 4.2: "PDF completo con grafici"); pediatri hanno già le curve nei loro sistemi

## P1: Archive Improvements (Figma-verified)

- [x] Full-text keyword search (FA 6.1.1.1 — filter icon toggles search panel with keyword input + type pills)
- [x] Article detail: scroll-overlap effect with sticky title (Stimulus `article-scroll` controller)
- [x] Activity detail: white header without image (hero partial variant)
- [x] Game/advice detail: yellow/blue header band for content type (hero partial variant)
- [ ] Content detail: "Tappe di sviluppo collegate" section at bottom — **needs design**: requires association between content and development areas, not yet modeled
- [x] Content detail: "Articoli collegati" horizontal carousel at bottom (age-range matching)
- [ ] Filter panel: age-bracket filter + per-type standard tags (FA 6.1.1.1) — **needs design**: Figma `463:6063` shows only keyword search + 4 type pills; FA describes additional age + tag filters not yet drawn. Found during home-view audit (2026-04-29).

## P1: Notification System

- [ ] Notification delivery (push via APNS/FCM for iOS via Ruby Native)
- [ ] Notification triggers: measurement reminders, milestone alerts, content suggestions
- [ ] Notification preferences UI in settings
- [ ] In-app notification center

## P2: Visual & UX Polish

- Systematic Figma comparison per screen:
  - [x] Timeline 
  - [x] Dashboard
  - Archive (split into per-screen sub-audits):
    - [x] Archive — index home view (Figma `463:6063`) — header round-buttons rebuilt as filled blue (`--bg-primary` + white icon, was transparent); brand navbar suppressed via `hide_navbar`; sticky translucent header (`bg-white/95 backdrop-blur-sm` + `.shuby-archive-index-header` with iOS safe-area inset) extracted to shared `_index_header.html.erb` partial used by home + search-results; section headings + cards verified against tokens
    - [x] Archive — Article detail (Figma `510:22491`) — sticky header now backed by `.shuby-article-sticky-header` class with `Shadow Blu` drop-shadow + native safe-area inset (`hotwire_native.css`); white panel radius corrected to `radius/grande` (12px); bookmark switched to `:outlined` variant on the white-panel context (reuses `.shuby-icon-btn-fill`) AND mirrored into the sticky header right slot (FA 6.2.1 "Title + bookmark become sticky header") via a `frame_suffix: :sticky` second turbo frame, with `ArchiveFavoritesController` emitting both stream replacements in lockstep; reading time renders inline via `.shuby-reading-time-primary` instead of a tag pill; body subheadings now H3 (20px Semi-Bold) and anchors blu-800; defensive `<hr>` rule for editorial separators
    - [x] Archive — Activity detail (Figma `532:24578`) — hero band switched from white to `bg-shuby-blue-400` (per FA 6.2.2 "blue for activities"); tags row now activity-aware (suppresses category + age, keeps duration only); rich-text wrapper gets a new `shuby-activity-body` companion class that overrides article default green markers to blue-700 for `ol` numerals and nested `ul` bullets while leaving the new `.shuby-list-hearts` benefits list untouched; new `text[]` `benefits` column on `archive_contents` rendered via `_section_benefits.html.erb` partial with a `mask-image` heart bullet (fucsia-500 token, themable; mask shape sourced from canonical `app/assets/images/shuby/icons/icon-heart-filled.svg` via Propshaft URL rewriting — no duplicated path data) — chosen over an Action Text class allowlist so the global rich-text sanitizer stays unchanged. Madmin: `benefits_text` virtual attribute on `ArchiveContent` exposes the array as a newline-separated textarea in the admin form (one benefit per line, blank lines stripped). Coverage: new `ArchiveControllerTest` (5 tests) verifies hero band, tags-row scoping, `shuby-activity-body` application, benefits render, and article-side regression; new model tests (4) verify the `benefits_text` round-trip (getter, setter strip+split, blank clear, nil-safe).
    - [ ] Archive — Game detail (Figma `532:25861`)
    - [ ] Archive — Book detail (Figma `532:26226`)
  - [x] Chat (AI Helper)
  - [x] Measurements — type-picker overlay added (Figma `463:5785` empty / `463:5995` with data / `795:8492`); global `+` on tab heading + detail header opens picker; picker reuses `_measurement_box` driven by `MeasurementDashboardService.picker_boxes` (returns 4 boxes including feeding_weight); detail header `+` replaced same-type-direct flow per design intent
  - [ ] Onboarding
  - [ ] Child Profile
  - [x] Questionnaire overlay (Figma `499:5449/5450/5511/5540/5853`) — single-current progress bar, all-complete state on completion, per-question `uncertain_label` infra, per-question illustration rendering with graceful asset fallback
- [x] Dashboard header: verify scroll bg transition blue-to-white (FA 3.1)
- [x] Measurement photo upload (PRD 3.5.2 — optional photo attachment) — Active Storage `has_one_attached :photo` on `Measurement`, form field with Stimulus preview, embedded as JPEG thumbnail in pediatrician PDF
- [x] Unit of measure preference (metric/imperial) in settings — `User::MeasurementUnit` preference module, segmented toggle in `/settings/privacy`, inline overlay toggle syncs via async PATCH, display respects pref across measurements tab (PDF intentionally stays metric for Italian pediatric medical convention)
- [ ] Verify 3-state milestone box in dashboard (proposed/completed/all-done per FA 3.3)

## P2: Non-Functional Requirements

- [ ] General API rate limiting (Rack::Attack or equivalent — only auth endpoints currently limited)
- [ ] WCAG 2.1 Level AA accessibility audit
- [ ] Performance measurement: app load < 2s, API < 500ms p95
- [ ] Screen reader compatibility testing
- [ ] AI chat streaming: replace `Thread.new` fire-and-forget at `app/controllers/shuby_chats_controller.rb:106` with a SolidQueue job. Current pattern loses the assistant response if the puma worker dies mid-stream; SolidQueue is already configured per CLAUDE.md.
- [ ] Stub `https://api.openai.com/v1/responses` in `test/test_helper.rb` to silence WebMock thread-leak noise from `ShubyBroadcastService` background streaming during `ShubyChatsControllerTest` runs (tests pass, but stderr fills with the system prompt on every test run).
- [ ] `ShubyChatPolicy` (Pundit) — controller currently does manual `current_user.shuby_chats.find` + rescue `RecordNotFound`. A `show?/destroy?` policy would centralize the rule and match the project's Pundit-everywhere pattern (`.claude/rules/rails-controllers.md`).

## P3: Post-Launch / Deferred

- [ ] FAQ / Help center (PRD 3.9.4)
- [ ] Feedback / bug report mechanism (PRD 3.9.4)
- [ ] Hidden stages — algorithm-driven activation (DEC-013: deferred)
- [ ] Sleep quality tracking (DEC-019: deferred)
- [ ] Gift subscriptions (DEC-016: to-do)
- [ ] Multi-caregiver support (DEC-004: single in v1.0)
- [ ] Proactive AI suggestions — premium feature (Phase 2)
- [ ] AI Specialist (premium tier) — Subscription PDF lists "AI Specialist" in the premium AI-Helper column; current code runs the same generalist system prompt regardless of subscription tier (DEC-066 explicitly chose a single generalist for v1.0, so this is a Phase-2 deferral, but tracking it here so it isn't lost)
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
- **Premium gating**: Account#premium?, child limit, timeline future lock, paywall UI, admin toggle
- **GDPR**: data export (JSON), account deletion, privacy settings page
