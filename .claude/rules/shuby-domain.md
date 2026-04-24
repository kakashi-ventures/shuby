---
paths:
  - "app/models/shuby*.rb"
  - "app/models/child*.rb"
  - "app/models/measurement*.rb"
  - "app/models/questionnaire*.rb"
  - "app/controllers/shuby*.rb"
  - "app/services/shuby*.rb"
  - "app/controllers/measurements*.rb"
  - "app/controllers/children*.rb"
---

# Shuby Domain Rules

## Child Development (0-36 months)
- Always handle **corrected age** for premature babies (gestational age < 37 weeks)
- Use corrected age for milestone assessments and growth chart plotting
- 5 development areas: motor, cognitive, language, social-emotional, adaptive

## Measurements & Growth
- Support weight (kg), height (cm), head circumference (cm)
- Use **WHO percentile standards** for growth chart calculations
- Validate measurement ranges (e.g., weight 0.5-25kg for 0-36mo)
- Store measurement date alongside values for accurate plotting

## AI Chat (Shuby Assistant)
- Uses RubyLLM with OpenAI (gpt-5.4-mini default)
- FileSearchTool for RAG against OpenAI Vector Store
- System prompt configured in `ShubyAssistantService`
- Stream responses via Turbo Streams

## Language
- All UI text in **Italian** — this is non-negotiable
- Medical/developmental terms should use standard Italian terminology
- Error messages, labels, placeholders — everything user-facing is Italian

## Language Boundary
- **User-facing text** (labels, messages, placeholders, content): **Italian**
- **Code** (routes, URLs, CSS classes, filenames, identifiers, params, locale keys, comments): **English**
- Italian in code should ONLY appear inside string values displayed to users (e.g., locale `.yml` values, hardcoded UI text)
- Route `path:` options, CSS class names, partial filenames, tab/active identifiers, JS URLs: always English

## Subscription & Premium
- Source of truth for free vs premium limits: `docs/SHUBY PIANO DI ABBONAMENTO.pdf`
- Cross-check `docs/DECISIONS.md` but note it may be partially outdated
- See `.claude/rules/premium-gating.md` for implementation patterns

## Specification Compliance
- Always verify implementations against:
  - `docs/Shuby 1.0 - Specifiche di Prodotto.md` (product spec)
  - `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (functional analysis)
  - `docs/DECISIONS.md` (client decisions — **OVERRIDE** the spec when conflicting)
- When in doubt about a feature's behavior, check the spec before guessing
