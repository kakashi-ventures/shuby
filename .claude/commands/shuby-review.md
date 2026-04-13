Review current changes against the Shuby product specification.

## Instructions

1. Run `git diff --name-only` to get the list of changed files
2. Read the changed files to understand what was implemented
3. Read relevant sections from:
   - `docs/DECISIONS.md` (client decisions — highest priority when conflicting)
   - `docs/SHUBY PIANO DI ABBONAMENTO.pdf` (subscription plan — source of truth for free/premium)
   - `docs/Shuby 1.0 - Specifiche di Prodotto.md` (product spec)
   - `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (functional analysis)
4. Compare implementation against spec requirements. Follow document hierarchy
   (DECISIONS > Subscription PDF > FA > PRD). Check for:
   - **Feature completeness**: Does the implementation cover all spec requirements?
   - **Italian text**: Are all user-facing strings in Italian?
   - **Premium/free gating**: Is the feature properly gated per the pricing spec?
   - **Edge cases**: Premature baby corrected age, measurement validation ranges, etc.
   - **Accessibility**: ARIA labels, keyboard navigation, semantic HTML
   - **Multi-tenancy**: Data properly scoped to current_account?
   - **Mobile**: Does it work with Hotwire Native patterns?
5. Output a compliance report:
   - Compliant items (what matches the spec)
   - Non-compliant items (what needs fixing, with spec references)
   - Suggestions (improvements not strictly required)
