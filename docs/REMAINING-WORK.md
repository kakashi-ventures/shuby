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

- [x] Data export: JSON download with all personal data (`GdprDataExportService`) — now includes terms/privacy/informed-consent timestamps
- [x] Account deletion: confirmation dialog with email verification (Devise)
- [x] Data sharing consent toggle in onboarding + settings
- [x] Privacy page redesigned with export + deletion sections
- [x] Lawyer-drafted legal docs integrated: Termini, Informativa Privacy, Modulo di Consenso Informato — 3 dedicated public pages (`/terms`, `/privacy`, `/consenso-informato`), forced re-acceptance modal, 3 signup checkboxes (Terms+Privacy combined, mandatory Informed Consent, optional research consent), Settings rows + research toggle, footer link. Dormant `Agreement` infra activated. Placeholders (sede, PEC, emails, DPO) live in `legal.placeholders.*` i18n keys for client confirmation.
- [ ] Cookie consent banner (skipped for beta — no tracking cookies in use)
- [ ] **TBD client**: legal entity contacts (sede legale Shuby S.r.l., PEC, email contatto/recesso/privacy, telefono, DPO) — substitute the `[da confermare]` markers in `config/locales/it.yml` `legal.placeholders.*` once provided
- [ ] **TBD client**: confirm Disclaimer §4 "abbonamenti annuali con rinnovo automatico" matches the actual subscription model (currently undecided 6 vs 7.99 EUR/mo, frequency unconfirmed)
- [ ] **TBD client**: confirm Disclaimer §6 / Privacy §3 references to "commissione tecnico-scientifica interna" — entity not yet formalized in product

## P1: Dashboard & Timeline Completeness

- [x] ~~24-Hour Guidelines table~~ — Not in Figma as separate table. Guidelines embedded in growth phase narrative text. Verify growth phase texts include these tips.
- [x] Dashboard: article carousel bumped to 4 items (was 3, carousel already horizontal)
- [x] Dashboard hero: per-month + per-week narrative seeded from April 2026 client drop (`docs/content_4_21/Dashboard generale_0-36.docx` + `Dashboard generale_prime settimane_0-2.docx`) — new `DashboardStageContent` model resolves child age to one of 4 weekly + 35 monthly rows; hero illustration still driven by `GrowthPhase` (9 broad phases) until per-month illustrations land
- [ ] Dashboard hero: per-month illustrations (35 monthly + 4 weekly) — currently reuses the 9 `GrowthPhase` broad-phase illustrations. **Needs design**: illustration brief + asset delivery.
- [ ] Dashboard hero: evocative titles per stage — currently "Mese N" / "Settimane N–M" placeholders. Client to provide titles per stage (e.g. "Il mondo dei sensi" style) in a follow-up content drop; the `label` column on `DashboardStageContent` is ready.
- [ ] Dashboard hero: Premium weeks 9–12 narrative from the prime-settimane docx draft (Settimane 9–10 / 11 / 12) — intentionally skipped in the initial seed (overlaps MESE 2–3 content, marked "bozza"). Revisit once the client finalises this draft + decides whether it's free or premium.
- [x] Timeline: per-pill long descriptions seeded from `docs/content_4_21/Timeline descrizione lunga_ 0-36.docx` — new `TimelineStageContent` model holds 1 row per pill (8 weekly + 34 monthly = 42 rows) keyed by pill_key, replacing the GrowthPhase-driven narrative that collapsed sett_1..sett_4 onto a single "Il mondo dei sensi" paragraph. Weekly rows carry a "Cosa puoi favorire:" suggestions paragraph rendered below the body via `t("timeline.show.suggestions_label")`.
- [ ] Timeline: pill schema does not yet cover Settimane 9–12 or MESE 0/1/2 (content available in the new Timeline docx but no corresponding pill in `Timeline::AgeBands::ALL`). If the client wants weekly precision in months 2–3 or month-0/1/2 entry points, extend `Timeline::AgeBands` and re-run the JSON extractor.
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

- [x] Notification delivery (push via APNS for iOS via Ruby Native) — Noticed v3 `:ios` adapter wired through `ApplicationNotifier.apns_defaults` (`app/notifiers/application_notifier.rb`); JWT token-based auth with `.p8` credentials in `Rails.application.credentials.apns.*`; bundle id `app.shuby.rubynative`; in test env `IOS_ADAPTER` swaps to `:test` (no HTTP). FCM left dormant (iOS-only per memory). Smoke-tested via Account::OwnershipNotifier + Account::AcceptedInviteNotifier
- [x] Notification triggers: measurement reminders, milestone alerts — 4 notifier classes (`Children::MeasurementReminderNotifier`, `Children::MilestoneReminderNotifier`, `Children::QuestionnaireResumeNotifier`, `Users::OnboardingNudgeNotifier`) + 4 SolidQueue scan jobs in `app/jobs/{children,users}/`, scheduled daily 09:00/09:15/09:30/10:00 Europe/Rome via `config/recurring.yml`. Quiet hours 22:00–08:00 per recipient time zone (default Europe/Rome). Dedupe via `Noticed::Event` row presence (7-day rolling for reminders, lifetime for questionnaire-resume + onboarding-nudge). GDPR-safe payloads: child display_name only — no measurement values or medical context. **Content-suggestion push deferred to Phase 2** (overlaps with Premium "Suggerimenti proattivi" per PDF)
- [x] Notification preferences UI in settings — three toggles in `_section_notifications.html.erb` (push default on, email newsletter default off, stage reminders default on); persisted via `User#preferences` JSONB store_accessors in `User::Notifiable`
- [x] In-app notification center — `NotificationsController` (index/show/nav/mark_as_read), `app/views/notifications/`, navbar bell-icon partial, Stimulus controller subscribing to `Noticed::NotificationChannel` and syncing `RubyNative.setBadge(unread)` on the iOS shell
- [ ] **APNS credentials provisioning** — Apple Developer portal: create APNs Auth Key for `app.shuby.rubynative`, download `.p8`, note Team ID + Key ID, paste into `bin/rails credentials:edit -e production` (and `-e development`, `-e staging`) under `apns:` block. Test env uses `:test` adapter so credentials may be absent there. Steps documented in `/Users/faeze/.claude/plans/p1-notification-system-zazzy-newell.md` §A.5

## Gestione (Settings) — Post-Redesign Tracking

Items surfaced by `/shuby-review` after the Figma 06.01_Gestione redesign
(Family + Configuration tabs aligned to nodes 455:5017 + 506:6066).

- [x] **Piano tab — inlines /pricing template**. Third tab in `/settings` segmented bar (`Famiglia | Piano | Impostazioni`). `SettingsController#show` seeds `@monthly_plans` + `@yearly_plans` from `Plan.visible.sorted` (same as `PricingController#show`); `_tab_plan.html.erb` calls `render template: "pricing/show"` so the Plan tab is the pricing page UI in-tab. No duplicated markup; design refinement still pending Figma but the Plan tab is now feature-complete on top of the existing Pay-gem pricing surface.
- [ ] **Supporto / Help Center (PRD §3.9.4)** — FAQ, video tutorials, contact, feedback. Out of Figma 06.01_Gestione scope. Blocked on design + content from team. `BetaFeedback` model already exists (`app/models/beta_feedback.rb`) for the feedback flow. Supersedes the older FAQ + Feedback bullets in P3.
- [ ] **Email-change re-confirmation (PRD §3.9.1 "Email con conferma")** — `/users/edit` currently mutates `User#email` without triggering Devise `confirmable` re-confirmation. Pre-existing gap, not introduced by the Gestione redesign. Lives in `Users::RegistrationsController` / Devise registration flow, not in the Gestione tab itself.

## P2: Visual & UX Polish

- Systematic Figma comparison per screen:
  - [x] Timeline 
  - [x] Dashboard
  - Archive (split into per-screen sub-audits):
    - [x] Archive — index home view (Figma `463:6063`) — header round-buttons rebuilt as filled blue (`--bg-primary` + white icon, was transparent); brand navbar suppressed via `hide_navbar`; sticky translucent header (`bg-white/95 backdrop-blur-sm` + `.shuby-archive-index-header` with iOS safe-area inset) extracted to shared `_index_header.html.erb` partial used by home + search-results; section headings + cards verified against tokens
    - [x] Archive — Article detail (Figma `510:22491`) — sticky header now backed by `.shuby-article-sticky-header` class with `Shadow Blu` drop-shadow + native safe-area inset (`hotwire_native.css`); white panel radius corrected to `radius/grande` (12px); bookmark switched to `:outlined` variant on the white-panel context (reuses `.shuby-icon-btn-fill`) AND mirrored into the sticky header right slot (FA 6.2.1 "Title + bookmark become sticky header") via a `frame_suffix: :sticky` second turbo frame, with `ArchiveFavoritesController` emitting both stream replacements in lockstep; reading time renders inline via `.shuby-reading-time-primary` instead of a tag pill; body subheadings now H3 (20px Semi-Bold) and anchors blu-800; defensive `<hr>` rule for editorial separators
    - [x] Archive — Activity detail (Figma `532:24578`) — hero band switched from white to `bg-shuby-blue-400` (per FA 6.2.2 "blue for activities"); tags row now activity-aware (suppresses category + age, keeps duration only); rich-text wrapper gets a new `shuby-activity-body` companion class that overrides article default green markers to blue-700 for `ol` numerals and nested `ul` bullets while leaving the new `.shuby-list-hearts` benefits list untouched; new `text[]` `benefits` column on `archive_contents` rendered via `_section_benefits.html.erb` partial with a `mask-image` heart bullet (fucsia-500 token, themable; mask shape sourced from canonical `app/assets/images/shuby/icons/icon-heart-filled.svg` via Propshaft URL rewriting — no duplicated path data) — chosen over an Action Text class allowlist so the global rich-text sanitizer stays unchanged. Madmin: `benefits_text` virtual attribute on `ArchiveContent` exposes the array as a newline-separated textarea in the admin form (one benefit per line, blank lines stripped). Coverage: new `ArchiveControllerTest` (5 tests) verifies hero band, tags-row scoping, `shuby-activity-body` application, benefits render, and article-side regression; new model tests (4) verify the `benefits_text` round-trip (getter, setter strip+split, blank clear, nil-safe).
    - [x] Archive — Game detail (Figma `532:25861`)
    - [x] Archive — Book detail (Figma `532:26226`)
  - [x] Chat (AI Helper)
  - [x] Measurements — type-picker overlay added (Figma `463:5785` empty / `463:5995` with data / `795:8492`); global `+` on tab heading + detail header opens picker; picker reuses `_measurement_box` driven by `MeasurementDashboardService.picker_boxes` (returns 4 boxes including feeding_weight); detail header `+` replaced same-type-direct flow per design intent
  - [ ] Onboarding
  - [x] Child Profile
  - [x] Child Selector — Figma `220:2341` + `315:3672` audit; chrome refactored into shared `.shuby-bottom-sheet-*` (new `bottom-sheet.css` + `bottom_sheet_controller.js`) covering child-selector + measurement form + measurement picker; sheet bg → blu-500, drag handle → 146×6 black per Figma, footer-actions gap → space-4, pill stack gap → 2px, "Gestione account" element swapped from `.shuby-tag-outline` to canonical `.shuby-btn .shuby-btn-outline-dark .shuby-btn-sm` (Figma "Type=Outline, Colore=Nero"). System tests updated to use identifier-scoped target selectors (form/picker share `.shuby-bottom-sheet--open` so disambiguation needs `[data-<identifier>-overlay-target='overlay']`). Stimulus inheritance attempted then dropped — CSS extraction is what guarantees parity.
  - [x] Settings
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
