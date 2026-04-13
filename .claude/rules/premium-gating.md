---
paths:
  - "app/models/account/**"
  - "app/controllers/**"
  - "app/views/**"
  - "app/helpers/**"
  - "app/policies/**"
---

# Premium Feature Gating

## Source of truth: `docs/SHUBY PIANO DI ABBONAMENTO.pdf`

## Free vs Premium Matrix

| Feature | Free | Premium (6EUR/mese) |
|---------|------|---------------------|
| Children per account | 1 | 3 |
| Additional caregivers | 0 | 2 (deferred: single caregiver in v1.0 per DEC-004) |
| Development milestones | All standard | All standard |
| Growth report | Complete | Complete |
| Measurements | Height, weight, head circ. | + pre/post feeding weight, sleep quality |
| Articles/content | All generic free (DEC-015) | + specialist articles |
| Timeline | Past + Today | + Future |
| AI-Helper | 30 msgs/month (DEC-005, still calibrating) | Unlimited + proactive suggestions |
| Insights | None | None (Phase 2) |

## Implementation Pattern

### Model level
- Use `current_account.premium?` (centralized in `Account::Billing`)
- `Account#children_limit` returns 1 or 3 based on plan
- Never hardcode `payment_processor&.subscribed?` — always go through `premium?`

### Controller level
- `before_action :require_subscription!` for full-page premium gating (Jumpstart built-in)
- Rescue `Pundit::NotAuthorizedError` for graceful paywall fallback

### View level
- `subscribed?` / `not_subscribed?` helpers available in all views (Jumpstart built-in)
- `policy(Model).action?` for checking limits (e.g. `policy(Child).create?`)

### Policy level
- Check limits in Pundit policies (e.g. `ChildPolicy#create?` checks children count)

## Jumpstart Built-in Helpers (don't reinvent)
- `subscribed?(name:)` — controller/view helper, checks current_account subscription
- `not_subscribed?(name:)` — inverse
- `require_subscription!` — before_action, redirects to pricing_path
- Pricing page, checkout flow, billing dashboard all pre-built

## Paywall UI
- Use `shared/_paywall_banner.html.erb` partial (3 icon variants: :lock, :star, :chart)
- Italian: "Funzionalita Premium", "Sblocca con Premium", "Passa a Premium"
- Show blurred/preview content, not empty states
- Include value proposition in paywall copy

## Admin
- Madmin toggle: "Rendi/Rimuovi Premium" on account page (`/admin/accounts/:id`)
- Uses Pay gem fake_processor for test/beta subscriptions
