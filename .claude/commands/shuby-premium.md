Implement or verify premium feature gating for a specific feature.

## Arguments
$ARGUMENTS — Feature to gate (e.g., "timeline", "ai-chat", "reports", "articles", "children")

## Instructions

1. Read `docs/SHUBY PIANO DI ABBONAMENTO.pdf` for the definitive free vs premium limits
2. Read `docs/DECISIONS.md` for any overrides
3. Check current implementation:
   - Search for existing premium checks (`premium?`, `feature_gate`, `plan`, subscription code)
   - Check Account/billing model for subscription state helpers
4. If gating doesn't exist, implement:
   - `current_account.premium?` check (or `premium_feature?(:name)`)
   - Italian paywall UI matching Figma design
   - Conversion trigger per PRD section 4.3
5. If gating exists, verify it matches the Subscription PDF
6. Run `/shuby-test` for modified code
