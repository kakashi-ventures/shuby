---
paths:
  - "app/models/account/**"
  - "app/controllers/**"
  - "app/views/**"
  - "app/helpers/**"
---

# Premium Feature Gating

## Source of truth: `docs/SHUBY PIANO DI ABBONAMENTO.pdf`

## Pattern
- Use `current_account.premium?` helper (centralized, never hardcode checks)
- Gate at controller level (before_action) for page-level restrictions
- Gate at view level (if/unless) for in-page element restrictions

## Free Limits (from Subscription PDF)
- 1 child per account
- 0 additional caregivers
- AI Chat: 8 domande/mese o 1 al giorno (still being calibrated)
- Timeline: Passata + Oggi only
- Articles: all generic content free
- Measurements: Altezza, Peso, Circ. cranica only
- Report: completo (both tiers get full report)

## Paywall UI
- Italian: "Funzionalità Premium", "Sblocca con Premium", "Passa a Premium"
- Show blurred/preview content, not empty states
- Include value proposition in paywall copy
