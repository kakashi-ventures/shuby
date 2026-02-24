# Shuby v1.0 — Development Status

> Cross-reference of Product Spec, Functional Analysis, DECISIONS.md, and codebase.
> Generated: 2026-02-23 | Target: Q2 2026 soft launch

---

## 1. Executive Summary

| Metric | Value |
|--------|-------|
| **Overall completion** | ~85% of core features |
| **Spec sections covered** | 9/9 (chapter 3 — Funzionalita Core) |
| **Decisions implemented** | 7/19 fully, 4/19 partially |
| **Decisions pending confirmation** | 4 (DEC-005, DEC-012, DEC-015, DEC-017) |
| **Decisions deferred post-v1.0** | 2 (DEC-013, DEC-019) |
| **Major gaps** | Premium gating, notifications, advanced analytics |
| **Tech stack** | Rails 8, Hotwire, TailwindCSS v4, PostgreSQL, RubyLLM + OpenAI |

---

## 2. Implemented Features

### 2.1 Registration & Onboarding (Spec 3.1)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Email + password registration | Yes | Devise authentication |
| OAuth (Google/Apple) | No | Jumpstart Pro infrastructure exists but not configured |
| Email confirmation | Yes | Devise confirmable |
| Privacy policy acceptance | Yes | Agreements module |
| Fast onboarding (5 questions) | Yes | `OnboardingController` — single-step mode |
| Detailed onboarding | Yes | Child health profile, family profile collected |
| Child data: name, birth date, sex | Yes | `Child` model with enum |
| Gestational age | Yes | `ChildHealthProfile` with weeks + days |
| Family data (nationality, languages, structure) | Yes | `FamilyProfile` model |

**Key files:**
- `app/controllers/onboarding_controller.rb`
- `app/models/child.rb`, `app/models/child_health_profile.rb`
- `app/models/family_profile.rb`

### 2.2 Dashboard "Oggi" (Spec 3.2 / Functional Analysis 3.1–3.6)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Personalized header greeting | Yes | "Ciao [Name]" + child name |
| Multi-child selector | Yes | Overlay with child list, encrypted cookie persistence |
| Focus of the day / milestone box | Yes | `DailyMilestoneService` selects daily milestone |
| Activities section (2–3 suggested) | Yes | Activity boxes from archive |
| Articles section (2–3 relevant) | Yes | Article carousel from archive |
| Measurement prompts | Yes | `MeasurementDashboardService` with staleness tracking |
| 24-hour guidelines table | Partial | Growth phase description shown; compact table not standalone |
| Daily content rotation (FA 3.4/3.5) | Partial | Milestones rotate; activities/articles age-filtered but no cyclic rotation algorithm |
| Scroll behavior (sticky header, color transition) | TBD | Not verified in detail |

**Key files:**
- `app/controllers/dashboard_controller.rb`
- `app/controllers/concerns/child_selection.rb`
- `app/services/daily_milestone_service.rb`, `app/services/measurement_dashboard_service.rb`

### 2.3 Development Timeline (Spec 3.3 / Functional Analysis 4.1–4.5)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Week/month navigation (0–36) | Yes | Age band carousel with past/current/future states |
| Growth phase description per period | Yes | `GrowthPhase` model with title, description, illustration |
| 24-hour guidelines per age band | Partial | Integrated in phase description, not separate table |
| Development focus per area | Yes | 5 development areas displayed |
| Link to relevant content | Yes | Cross-links to archive and development stages |
| Free: current ±2 weeks only | No | No premium gating yet |
| Premium: full 0–36 access | No | No premium gating yet |
| Milestone counter (completed/total) | Yes | Progress tracking per session |
| Past/current/future age band states | Yes | Visual differentiation in carousel |

**Key files:**
- `app/controllers/development_stages_controller.rb`
- `app/models/growth_phase.rb`, `app/models/development_area.rb`
- `config/routes/development_stages.rb`

### 2.4 Development Milestones & Questionnaires (Spec 3.4 / FA 4.5)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| 5 development areas | Yes | Motor, Cognitive, Language, Social-Emotional, Adaptive |
| Age-band questionnaires | Yes | `AgeBandQuestionnaire` with monthly/multi-month ranges |
| Multiple-choice responses (Si/No/Incerto) | Yes | `QuestionResponse` with Italian enum |
| Progress tracking (e.g. "2/6 completed") | Yes | `progress_percentage`, `progress_fraction` |
| Response history saved | Yes | All responses persisted |
| 14-day edit window | Yes | `editable?`, `editing_deadline`, `days_until_locked` |
| Gentle alert system | Yes | `CampanelloAllarme` (attention alerts by month) |
| Stimulation activities | Yes | `AttivitaStimolazione` (activities by month) |
| Stories UI for questionnaires | Yes | Story-based flow in controller |
| Recompilation (FA 4.5.1) | Yes | Unlimited recompilation while in current age band |
| Radar charts for areas | No | Not implemented |
| Temporal trend if repeated | Partial | Historical sessions saved; trend visualization not built |

**Key files:**
- `app/models/questionnaire_session.rb`, `app/models/question_response.rb`
- `app/models/age_band_questionnaire.rb`, `app/models/development_area.rb`
- `app/models/campanello_allarme.rb`, `app/models/attivita_stimolazione.rb`
- `app/controllers/questionnaire_sessions_controller.rb`

### 2.5 Measurements & Growth (Spec 3.5)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Weight (kg) | Yes | `Measurement` model |
| Height/length (cm) | Yes | |
| Head circumference (cm) | Yes | |
| Feeding weight (pre/post) | Yes | `feeding_weight` type |
| Automatic percentile calculation | Yes | `PercentileCalculator` service |
| WHO percentile curves | Yes | `WhoGrowthStandard` with full LMS data (male/female, 0–36mo) |
| Growth charts (Chart.js) | Yes | P3, P10, P25, P50, P75, P90, P97 curves |
| Color-coded bands (normal/warning/alert) | Yes | Green (25–75), yellow (10–25, 75–90), red (<10, >90) |
| Zoom levels (1m, 3m, 6m, all) | Yes | Interactive zoom controls |
| Measurement history list | Yes | Full CRUD with notes |
| Date/time recording | Yes | |
| Optional notes | Yes | |
| Staleness tracking | Yes | Age-adaptive thresholds (14d for 0–3mo, 30d for 4–12mo, etc.) |
| Free: basic graphs | N/A | No premium gating yet |
| Premium: advanced graphs + export | N/A | No premium gating yet |

**Key files:**
- `app/models/measurement.rb`, `app/models/who_growth_standard.rb`
- `app/controllers/measurements_controller.rb`
- `app/javascript/controllers/growth_chart_controller.js`
- `app/views/children/_growth_chart.html.erb`
- `app/services/percentile_calculator.rb`

### 2.6 AI-Helper (Spec 3.6)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Natural language chat | Yes | RubyLLM `acts_as_chat` |
| RAG with knowledge base | Yes | OpenAI Vector Store + `FileSearchTool` |
| Automatic source citations | Yes | Vector Store search returns sources |
| Personalized responses (child age, name) | Yes | System prompt includes child context |
| Conversation history | Yes | `ShubyChat` / `ShubyMessage` models |
| Real-time streaming | Yes | Turbo Streams + ActionCable via `ShubyBroadcastService` |
| Medical disclaimer | Yes | In system prompt |
| Emergency redirect | Yes | System prompt includes safety guidance |
| Free: 10 (or 30 per DEC-005) questions/month | No | No message counter implemented |
| Premium: unlimited | No | No premium gating yet |
| 7 specialist chatbots (premium) | No | Single generalist chatbot (per DEC-007 architecture) |
| Search in past conversations | No | List of chats exists; full-text search not built |

**Key files:**
- `app/models/shuby_chat.rb`, `app/models/shuby_message.rb`, `app/models/shuby_tool_call.rb`
- `app/controllers/shuby_chats_controller.rb`
- `app/services/shuby_assistant_service.rb`, `app/services/shuby_broadcast_service.rb`
- `app/tools/file_search_tool.rb`

### 2.7 Article Library (Spec 3.7)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| Content types (article, book, game, tip) | Yes | `ArchiveContent` enum |
| Age range filtering | Yes | `min_age_months`, `max_age_months` |
| Category filtering | Yes | By type |
| Published/unpublished states | Yes | |
| Cover images | Yes | ActiveStorage attachment |
| Sectioned index (articles, books/tips, games) | Yes | |
| Single content show view | Yes | |
| Reading time | Partial | Field exists in model |
| Favorites/saved | No | Not implemented |
| Free: 20–30 selected articles | N/A | No content gating |
| Premium: 100+ full library | N/A | No content gating |

**Key files:**
- `app/models/archive_content.rb`
- `app/controllers/archive_controller.rb`
- `config/routes/archive.rb`

### 2.8 Pediatrician Report (Spec 3.8)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| PDF generation (Prawn) | Yes | Professional layout with Shuby branding |
| Child header (name, DOB, corrected age, sex) | Yes | |
| General info (birth data, feeding, sleep, screening) | Yes | Full data from `ChildHealthProfile` |
| Recent measurements with percentiles | Yes | Percentile alerts for <3% and >97% |
| Development area summary | Yes | Yes-rate percentage per area |
| Questionnaire session summary | Yes | Response counts per session |
| Pediatrician questions section | Yes | `PediatricianQuestion` model with CRUD |
| Ruled lines for handwritten notes | Yes | |
| Disclaimer + page numbers | Yes | |
| Export PDF via OS share | Yes | PDF download on demand |
| Free: basic report | N/A | No premium gating |
| Premium: advanced with graphs/trends | N/A | No premium gating |

**Key files:**
- `app/services/pediatrician_report_pdf.rb`, `app/services/report_data_aggregator.rb`
- `app/controllers/pediatrician_reports_controller.rb`
- `app/models/pediatrician_question.rb`
- `app/controllers/pediatrician_questions_controller.rb`

### 2.9 Account & Family Management (Spec 3.9)

**Status: DONE**

| Spec Requirement | Implemented | Notes |
|-----------------|:-----------:|-------|
| User profile (name, email, password) | Yes | Devise + Jumpstart Pro |
| Photo profile | Yes | ActiveStorage |
| Multi-child support | Yes | Child CRUD with soft-delete |
| Child archiving (>36mo) | Partial | Active flag exists; automated archiving not built |
| Family profile (structure, languages, hereditary) | Yes | `FamilyProfile` with full enums |
| Privacy / GDPR data management | Partial | Jumpstart Pro provides basics |
| Notification preferences | Partial | Framework exists (`Notifiable` module) |
| Subscription plan display | Partial | Jumpstart Pro billing infrastructure |
| Help center / FAQ | No | Not implemented |
| Feedback / bug report | No | Not implemented |

**Key files:**
- `app/controllers/children_controller.rb`
- `app/models/child.rb` (includes `AgeCalculations`, `QuestionnaireManagement`, `ProfileCompleteness`)
- `app/models/family_profile.rb`, `app/models/child_health_profile.rb`
- `app/models/account_user.rb`

---

## 3. Missing / Partial Features (Gap Analysis)

### 3.1 Premium Feature Gating (Spec 4.1 / 4.2)

**Status: NOT STARTED**

The spec defines a comprehensive freemium model (Spec 4.1–4.3) with:
- Free tier: limited timeline (±2 weeks), 10 AI questions/month, 20–30 articles, basic reports
- Premium tier: 7.99/month or 49.90/year — full timeline, unlimited AI, 100+ articles, advanced reports

**Current state:** A single stub method exists in `app/helpers/growth_chart_helper.rb` (`premium_charts?` always returns false). No subscription checks, no feature locks, no conversion CTAs.

**Needs:**
- [ ] Subscription check helpers (leveraging Jumpstart Pro Pay gem)
- [ ] AI message counter and monthly limit enforcement
- [ ] Timeline access restriction (current ±2 weeks for free)
- [ ] Content gating for premium articles
- [ ] Report tier differentiation (basic vs advanced)
- [ ] Conversion CTAs at limit points (Spec 4.3)

### 3.2 Notification System (Spec 3.9.3)

**Status: NOT STARTED (framework only)**

Jumpstart Pro provides `Noticed` gem integration with `NotificationToken` model and basic `NotificationsController`. However:
- No measurement reminders
- No milestone alerts
- No push notification delivery
- No email notification triggers
- No event generators to create notifications

### 3.3 Advanced Analytics Dashboards (Spec 4.2 Premium)

**Status: NOT STARTED**

Spec 4.2 lists premium analytics:
- Advanced growth charts (comparison between siblings)
- Temporal development trends
- Development progress dashboard

Currently only per-child growth charts exist. No cross-child comparison or aggregate analytics.

### 3.4 Dashboard Dynamic Content Logic (FA 3.3–3.5)

**Status: MOSTLY DONE**

The Functional Analysis specifies:
- Daily rotation of development milestone proposals (one different milestone per day until all completed) — **Done** via `DailyMilestoneService`
- Activities retrieved from archive, age-filtered, rotated cyclically to always show new content — **Done** via `DashboardContentService` (deterministic daily rotation)
- Tips section with 3 daily tips, changing every day — **Done** via `DashboardContentService`
- Article carousel with intelligent selection based on age + navigation + caregiver behavior — **Mostly done** via `DashboardContentService` (age filtering + category diversity; behavioral selection deferred post-v1.0)

**Remaining:** Premium/free activity count differentiation (free: 2/day, premium: 10+/day) — blocked on premium gating infrastructure.

### 3.5 OAuth Registration (Spec 3.1.1)

**Status: NOT CONFIGURED**

Google/Apple OAuth infrastructure exists via Jumpstart Pro (OmniAuth) but is not configured with provider credentials.

### 3.6 Milestone Skip Logic (DEC-011)

**Status: NOT STARTED**

When a milestone isn't completed within its expected period, it should be skipped and the app should jump to the current period's milestones. Basic `questionnaire_age_in_months` and `current_age_band` logic exists in the child model, but explicit skip-and-advance behavior is not implemented.

### 3.7 Milestone Completion Flow (DEC-010)

**Status: NOT STARTED**

On milestone completion, the app should show: (1) "Updated clinical report", (2) link to download report, (3) link to AI helper or stimulation activities. Currently questionnaire completion just marks the session as complete.

### 3.8 Intelligent Milestone Proposal (DEC-012)

**Status: NOT STARTED** (also pending confirmation)

The app should propose the most relevant milestones based on previous results, not purely sequential order. No AI recommendation algorithm exists.

### 3.9 Chat-to-Article Linking (DEC-008)

**Status: NOT STARTED**

The chatbot should link to in-app articles when relevant. `FileSearchTool` searches the OpenAI Vector Store but does not cross-reference `ArchiveContent` records to generate in-app links.

### 3.10 Persistent Chat Memory for Premium (DEC-006)

**Status: NOT STARTED**

Premium users should have persistent conversational context across chat sessions. Currently each `ShubyChat` is independent with no cross-session memory.

### 3.11 Dispatcher Chatbot Architecture (DEC-007)

**Status: PARTIAL**

A single generalist chatbot exists (correct per DEC-007), but the dispatcher pattern to route to specialist sub-agents is not implemented. Current architecture uses one system prompt for all queries.

### 3.12 Article Favorites / Saved (Spec 3.7.1)

**Status: NOT STARTED**

Spec mentions "Preferiti/Salvati" filter for articles. No favoriting mechanism exists.

### 3.13 Radar Charts for Development Areas (Spec 3.4.4)

**Status: NOT STARTED**

Spec mentions radar charts for visualizing progress across the 5 development areas. Not implemented.

---

## 4. Pending Decisions (Need Confirmation)

These decisions from `DECISIONS.md` have conflicting information and need stakeholder confirmation before implementation.

| ID | Topic | Conflict | Impact |
|----|-------|----------|--------|
| **DEC-005** | Free chat limit | Spec says 10 questions/month; meeting notes say 30 messages/month | Determines AI message counter logic |
| **DEC-012** | Intelligent milestone proposal | How AI-driven vs sequential for v1.0? | Scope of recommendation algorithm |
| **DEC-015** | Free content policy | Spec says 20 free / 100+ premium; meeting says quality content stays free | Determines content gating strategy |
| **DEC-017** | Launch languages | Spec says IT only; meeting says IT + EN + FR | Scope of i18n work before launch |

---

## 5. Confirmed Decisions Not Yet Implemented

These decisions are confirmed ("da-fare") but not yet reflected in the codebase.

| ID | Decision | Current State | Work Required |
|----|----------|--------------|---------------|
| **DEC-001** | Sex options: M / F / INTERSEX | **DONE** — `child.rb` enum includes `intersex` | None |
| **DEC-002** | Language exposure: mono/bi/tri/4+ | **PARTIAL** — `FamilyProfile` has numeric `languages_spoken_at_home` (1–10) instead of categorical enum | Change to categorical enum (monolingue, bilingue, trilingue, quattro_o_piu) |
| **DEC-003** | Caregiver relationship type | **DONE** — `AccountUser` has `relationship_to_child` enum (dad, mom, grandparent, caregiver, other) | None |
| **DEC-004** | Single caregiver per account in v1.0 | **DONE** — Account has one FamilyProfile; multi-caregiver deferred | None |
| **DEC-006** | Premium persistent chat context | **NOT STARTED** | Cross-session context loading in `ShubyAssistantService` |
| **DEC-007** | Dispatcher generalist chatbot | **PARTIAL** — Single chatbot exists; dispatcher routing not built | Specialist sub-agent routing |
| **DEC-008** | Chat links to in-app articles | **NOT STARTED** | Cross-reference `ArchiveContent` in tool responses |
| **DEC-009** | Terminology: "Development Stage" | **PARTIAL** — Models use `development_area`; EN translations not complete | Update EN locale files |
| **DEC-010** | Milestone completion flow | **NOT STARTED** | Post-completion UI with report + AI helper links |
| **DEC-011** | Skip old milestones | **PARTIAL** — `current_age_band` logic exists | Explicit skip-and-advance behavior |
| **DEC-014** | Report per period | **DONE** — Report shows recent questionnaire sessions | None |
| **DEC-016** | Gift subscriptions | **NOT STARTED** | Billing mechanism, promo codes, gift UI |
| **DEC-018** | Opt-in data sharing | **PARTIAL** — `data_sharing_consent` field exists in onboarding | Full analytics opt-in flow in settings |

---

## 6. Technical Debt

### 6.1 Test Coverage

**Status: MODERATE — needs significant expansion**

- Model tests exist for core models (child, measurement, questionnaire, health profile, family profile)
- ~81 test files total, ~52 model/controller tests
- **Missing tests for:**
  - Growth chart JavaScript controller
  - Turbo Stream / ActionCable broadcasting
  - PDF generation (`PediatricianReportPdf`)
  - Chat streaming end-to-end
  - Archive controller
  - Percentile calculation edge cases
  - Premium gating (N/A — feature not built)

### 6.2 Accessibility (WCAG 2.1 Level AA)

**Status: NOT AUDITED**

Spec 5.4 requires WCAG 2.1 Level AA compliance:
- Screen reader compatibility
- Color contrast ratios
- Tap targets >= 44px
- Font size scalability

No formal audit has been performed.

### 6.3 Performance Targets

**Status: NOT MEASURED**

Spec 5.1 targets:
- App load time: < 2 seconds
- API response time: < 500ms (p95)
- AI response: streaming immediate, complete < 10s
- UI transitions: 60fps

No performance monitoring or benchmarking in place.

### 6.4 Internationalization (i18n)

**Status: ITALIAN COMPLETE, EN/FR INCOMPLETE**

- Italian (`it.yml`): Complete for all major sections
- English (`en.yml`): Partial (Devise, errors, shared, family profiles)
- French: Only example file (`fr.yml.example`) exists
- Some Italian strings hardcoded in Chart.js controller and views
- If DEC-017 is confirmed (IT + EN + FR at launch), significant translation work remains

### 6.5 Security & GDPR

**Status: PARTIAL**

- HTTPS, bcrypt password hashing, session management via Jumpstart Pro
- GDPR basics: account deletion exists
- **Missing:** Full data export, explicit consent management UI, data retention policy enforcement, rate limiting on AI endpoints

### 6.6 UX Items from Functional Analysis

**Status: OPEN**

- Child add overlay (FA 3.1.2) — marked "TBD" in functional analysis
- Article title truncation with ellipsis (FA 3.6.2) — max length TBD
- Content dynamic rotation algorithm (FA 3.4, 3.5)

---

## 7. Out of Scope for v1.0 (Spec Section 6)

Confirmed out-of-scope per spec:

| Category | Items |
|----------|-------|
| **Special cases (6.1)** | Premature babies (<37w), adoption/foster, IVF, high-risk pregnancy, bilingualism-specific modules |
| **Additional languages (6.2)** | English, Spanish, French, German (unless DEC-017 overrides for EN/FR) |
| **Advanced features (6.3)** | Community/social, professional portal, wearable integration, telemedicine, intelligent reminders, offline mode, gamification |
| **External integrations (6.4)** | Healthcare systems (FSE), e-commerce, commercial partners |
| **Deferred decisions** | DEC-013: Hidden milestones, DEC-019: Sleep quality tracking |

**Post-v1.0 roadmap** (from spec section 7):
- Q2 2026: Launch + stabilization (1,000 users)
- Q3 2026: Premature + bilingualism modules (2,500 users)
- Q4 2026: English language, adoption/foster (5,000 users)
- Q1 2027: Community, professional portal, advanced notifications (10,000 users)

---

## 8. Reference Map

### Spec Sections → Code

| Spec Section | Primary Files |
|-------------|---------------|
| 3.1 Registration & Onboarding | `onboarding_controller.rb`, `child.rb`, `family_profile.rb`, `child_health_profile.rb` |
| 3.2 Dashboard | `dashboard_controller.rb`, `daily_milestone_service.rb`, `measurement_dashboard_service.rb` |
| 3.3 Timeline | `development_stages_controller.rb`, `growth_phase.rb` |
| 3.4 Milestones & Questionnaires | `questionnaire_session.rb`, `question_response.rb`, `age_band_questionnaire.rb`, `campanello_allarme.rb` |
| 3.5 Measurements & Growth | `measurement.rb`, `who_growth_standard.rb`, `growth_chart_controller.js`, `percentile_calculator.rb` |
| 3.6 AI-Helper | `shuby_chat.rb`, `shuby_assistant_service.rb`, `shuby_broadcast_service.rb`, `file_search_tool.rb` |
| 3.7 Article Library | `archive_content.rb`, `archive_controller.rb` |
| 3.8 Pediatrician Report | `pediatrician_report_pdf.rb`, `report_data_aggregator.rb`, `pediatrician_question.rb` |
| 3.9 Account & Family | `children_controller.rb`, `account_user.rb`, `family_profile.rb` |
| 4.1–4.3 Freemium Model | **NOT IMPLEMENTED** — stub in `growth_chart_helper.rb` |

### Functional Analysis Sections → Code

| FA Section | Primary Files |
|-----------|---------------|
| 1. Access Flow (Registration/Login) | `onboarding_controller.rb`, Devise controllers |
| 2. App Architecture | `config/routes/` (shuby.rb, children.rb, measurements.rb, etc.) |
| 3. Dashboard (3.1–3.6) | `dashboard_controller.rb`, partials in `app/views/dashboard/` |
| 4. Timeline (4.1–4.5) | `development_stages_controller.rb`, `growth_phase.rb` |
| 5. AI-Helper | `shuby_chats_controller.rb`, `shuby_assistant_service.rb` |
| 6. Archive | `archive_controller.rb`, `archive_content.rb` |
| 7. Child Profile | `children_controller.rb`, `child.rb` |
| 8. Account Management | Jumpstart Pro account controllers |

### DECISIONS.md → Implementation Status

| ID | Status | Summary |
|----|--------|---------|
| DEC-001 | **DONE** | Sex: M/F/INTERSEX in `child.rb` |
| DEC-002 | **PARTIAL** | Numeric not categorical enum |
| DEC-003 | **DONE** | Relationship enum in `account_user.rb` |
| DEC-004 | **DONE** | Single caregiver enforced |
| DEC-005 | **PENDING** | Needs confirmation (10 vs 30) |
| DEC-006 | **NOT STARTED** | Premium persistent context |
| DEC-007 | **PARTIAL** | Single chatbot, no dispatcher |
| DEC-008 | **NOT STARTED** | Chat → article linking |
| DEC-009 | **PARTIAL** | EN translations incomplete |
| DEC-010 | **NOT STARTED** | Completion flow UI |
| DEC-011 | **PARTIAL** | Basic age logic, no skip behavior |
| DEC-012 | **PENDING** | Needs confirmation + design |
| DEC-013 | **DEFERRED** | Hidden milestones → post-v1.0 |
| DEC-014 | **DONE** | Report per period |
| DEC-015 | **PENDING** | Needs confirmation |
| DEC-016 | **NOT STARTED** | Gift subscriptions |
| DEC-017 | **PENDING** | Needs confirmation (IT vs IT+EN+FR) |
| DEC-018 | **PARTIAL** | Consent field exists, full flow not built |
| DEC-019 | **DEFERRED** | Sleep tracking → post-v1.0 |
