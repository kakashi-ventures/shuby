# Product Decisions — Shuby v1.0

> This document collects decisions made during client meetings (Sep 2025 – Jan 2026)
> that are **not present** or **contradict** the product specifications.
>
> **Precedence**: When this document contradicts the specs (`Shuby 1.0 - Specifiche di Prodotto`
> or `Analisi Funzionale v.1.0`), **this document takes precedence**.

---

## Child Profile

### DEC-001: Sex at birth — updated options

- **Overrides**: Product spec — "Sex" field (F / M / Prefer not to say)
- **Decision**: Sex at birth options are: **M / F / INTERSEX**. The "Prefer not to say" option is removed.
- **Status**: to-confirm
- **Note**: Needs confirmation from Azia on whether to keep the intersex option.

### DEC-002: Language — bilingualism only

- **Overrides**: Product spec — detailed primary language field in onboarding
- **Decision**: Do not ask for the detailed primary language. Only ask if the child is exposed to multiple languages with options: **monolingual / bilingual / trilingual / four or more languages**.
- **Status**: partial
- **Note**: Currently implemented as a numeric field (1, 2, 3+) instead of the categorical labels. Functionally equivalent.

### DEC-003: Caregiver relationship type

- **Overrides**: Not present in specs
- **Decision**: Add a field for the caregiver's relationship to the child: **dad / mom / other**.
- **Status**: done
- **Note**: Current implementation includes additional options (grandparent, caregiver, other) beyond the original spec.

### DEC-004: Single caregiver per account in v1.0

- **Overrides**: Scope change
- **Decision**: In v1.0, each account has a single caregiver. Multi-caregiver management is deferred to future versions.
- **Status**: done

---

## AI Chat (Shuby Assistant)

### DEC-005: Free chat limit — 30 messages/month

- **Overrides**: Product spec — 10 questions/month for free users
- **Decision**: The limit for free users is **30 messages per month** (not 10 questions).
- **Status**: to-confirm

### DEC-006: Persistent conversational memory for Premium users

- **Overrides**: Not present in specs
- **Decision**: Premium users have **persistent context across chat sessions**. The chatbot remembers previous conversations to offer more personalized responses.
- **Status**: partial
- **Note**: Cross-session context is implemented but not yet gated to Premium users only — all users currently benefit from it.

### DEC-007: Chatbot architecture — generalist dispatcher

- **Overrides**: Not present in specs (which mention 7 separate chatbots)
- **Decision**: A single **generalist chatbot** that dispatches to specialists, not 7 separate chatbots. The user interacts with a single entry point.
- **Status**: done

### DEC-008: Chatbot linking to in-app articles

- **Overrides**: Not present in specs
- **Decision**: The chatbot should **link to articles within the app** when relevant. Articles in turn should **link to international reference sources**.
- **Status**: to-do

---

## Development Stages

### DEC-009: Terminology — "Development Stage" not "Milestone"

- **Overrides**: Product spec — internal "milestone" terminology
- **Decision**: In English use **"Development Stage"** instead of "milestone". In Italian keep existing terminology ("tappe di sviluppo").
- **Status**: done

### DEC-010: Stage completion flow

- **Overrides**: Not present in specs
- **Decision**: Upon completing a stage, show: (1) **"Updated clinical report"**, (2) **link to download the report**, (3) **link to the AI helper** or to **stimulation activities**.
- **Status**: partial
- **Note**: Completion screen exists with link to session report. Missing: direct link to AI helper and direct PDF download from the completion flow.

### DEC-011: Skipped stages — jump to current period

- **Overrides**: Not present in specs
- **Decision**: If a stage is not completed within the expected period, it is **skipped** and the app moves directly to the stages for the **child's current period**.
- **Status**: to-do

### DEC-012: Intelligent stage proposal

- **Overrides**: Not present in specs
- **Decision**: The app proposes the **most relevant stages** based on previous results, not following a purely sequential order.
- **Status**: to-confirm

### DEC-013: Hidden stages — deferred to post-v1.0

- **Overrides**: Scope change
- **Decision**: Hidden stages (triggers to be defined with Azia) are **deferred to after v1.0**.
- **Status**: deferred

---

## Reports & PDF

### DEC-014: PDF report per period

- **Overrides**: Not present in specs (clarification)
- **Decision**: The pediatrician report is **per period**. Typically only the **most recent report** is shared with the pediatrician.
- **Status**: done

---

## Pricing & Content

### DEC-015: Quality content stays free

- **Overrides**: Product spec — 20 free articles / 100+ premium
- **Decision**: **Quality content** (articles, resources) should remain **free** and not be locked behind a paywall. Premium differentiates through other features.
- **Status**: to-confirm

### DEC-016: Gift subscriptions

- **Overrides**: Not present in specs
- **Decision**: Support the ability to **gift a subscription** (e.g., birth gift). Exact mechanism to be defined.
- **Status**: to-do

---

## Internationalization (i18n)

### DEC-017: v1.0 languages — Italian only at launch

- **Overrides**: Product spec — Italian only for v1.0, English from Q2 2026
- **Decision**: v1.0 launches in **Italian only**. Additional languages (English, French) to be added post-launch.
- **Status**: to-confirm
- **Note**: English and French translations are partially in place but completeness needs to be verified before committing to multi-language at launch.

---

## Privacy & Data

### DEC-018: User data sharing opt-in

- **Overrides**: Not present in specs
- **Decision**: Ask users if they want to **participate in product improvement** by sharing anonymous usage data.
- **Status**: partial
- **Note**: Backend consent mechanism exists. Missing: UI in onboarding/settings to actually ask the user.

---

## Deferred Scope

### DEC-019: Sleep quality tracking — deferred

- **Overrides**: Scope change
- **Decision**: Sleep quality tracking is **deferred** to a future version.
- **Status**: deferred
