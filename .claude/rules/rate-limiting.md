---
paths:
  - "config/initializers/rack_attack.rb"
  - "app/controllers/users/sessions_controller.rb"
  - "app/controllers/users/passwords_controller.rb"
  - "app/controllers/users/registrations_controller.rb"
  - "app/controllers/api/**"
  - "test/middleware/**"
  - "test/test_helper.rb"
---

# Rate Limiting

Shuby runs **two complementary** rate-limit layers. They are not duplicates — removing either leaves a hole.

## Layer 1 — middleware (`Rack::Attack`)

`config/initializers/rack_attack.rb`. Runs **before** Rails routing. Cheap rejection of abusive IPs / tokens; cannot see `current_user`. Backed by `Rails.cache` (= SolidCache in prod/staging, MemoryStore in dev).

Five throttles, all ENV-tunable. Defaults below — only override via ENV, never hardcode in environments/*.rb:

| Throttle key | Scope | Default | ENV |
|---|---|---|---|
| `req/ip` | every request | 300 / 5 min | `RACK_ATTACK_GLOBAL_{LIMIT,PERIOD}` |
| `api/ip` | path `^/api(/|_tokens(/|\z))` | 60 / 1 min | `RACK_ATTACK_API_{LIMIT,PERIOD}` |
| `api/token` | path `^/api/...` + `Authorization:` header (key = SHA256(bearer)) | 120 / 1 min | `RACK_ATTACK_API_TOKEN_LIMIT` |
| `auth/ip` | POST `/users/(sign_in|sign_up|password)` or `/api/v1/(auth|password)` | 5 / 20 sec | `RACK_ATTACK_AUTH_{LIMIT,PERIOD}` |
| `report/ip` | path `^/children/\d+/pediatrician-report` | 10 / 1 hour | `RACK_ATTACK_REPORT_{LIMIT,PERIOD}` |

Safelisted (never throttled, regardless of bucket):
- Loopback IPs in `Rails.env.development?` only
- Anything matching `^/(webhooks|pay)(/|\z)` — third-party callers, must always deliver

Response shape — set by `throttled_responder`:
- API path OR `Accept: application/json` → JSON `{error: "rate_limit_exceeded", retry_after: N}`
- Else → self-contained Italian HTML from `app/views/errors/too_many_requests.html.erb` (rendered with `layout: false`)
- Always: status `429`, headers `Retry-After`, `RateLimit-Limit`, `RateLimit-Remaining` (=`0`), `RateLimit-Reset`

## Layer 2 — controller (`rate_limit` from Rails 8)

`rate_limit to: 10, within: 3.minutes` on the three Devise controllers (`sessions`, `passwords`, `registrations`). Action-aware, runs *inside* the controller, can branch on `current_user` and play with the existing 2FA flow. **Keep these alongside the middleware throttles** — they catch different shapes of abuse and have different failure modes.

## Adding a new throttle

1. Add an entry to `config/initializers/rack_attack.rb` matching the existing data shape. Always declare an ENV-overridable `LIMIT` + `PERIOD` constant at the top.
2. If the new throttle should be skipped for known callers (e.g. another webhook source), extend `WEBHOOK_PATHS` or add a new `safelist(...)` block. Do NOT add per-throttle `unless` guards — safelists short-circuit everything in one place.
3. Set sane test defaults in `test/test_helper.rb` (the `ENV[...] ||=` block at the top — must fire BEFORE `require_relative "../config/environment"` so the initializer picks them up).
4. Add a focused test under `test/middleware/rack_attack_test.rb` following the existing setup/teardown pattern.

## The Warden-in-middleware gotcha

`Rack::Attack` runs in middleware, before Warden's manager populates `request.env['warden']`. Any view rendered from the responder **must not** transitively call Devise/Warden helpers (`current_user`, `user_signed_in?`, `impersonation_banner`, etc.). This is why the 429 view uses `layout: false` + inline CSS instead of the app's `minimal` layout.

If you ever change the 429 view, do not switch it to a Rails layout that pulls in Warden — render an `ActionView::Template::Error` at runtime, not at boot, so tests will catch it.

## Testing throttles

Class-level state — three rules:

1. **`Rack::Attack.enabled = false` is the test default** (set by the initializer when `Rails.env.test?`). The 700+ existing tests rely on this. Enable per-test, never globally.
2. **Cache backend must be writable.** `config.cache_store = :null_store` in test silently drops `increment` calls, so any throttle test against `Rails.cache` will be a false negative. The pattern:

   ```ruby
   setup do
     @original_store = Rack::Attack.cache.store
     Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
     Rack::Attack.enabled = true
   end

   teardown do
     Rack::Attack.enabled = false
     Rack::Attack.cache.store = @original_store
   end
   ```

3. **Test limits are intentionally tiny** (`RACK_ATTACK_*_LIMIT` set to 2–5 in `test/test_helper.rb`). This is what makes tests fast and deterministic. Never increase a test ENV default to match the prod default — write fixtures around the small numbers instead.

## Same gotcha applies to `rate_limit` (Rails 8)

`rate_limit to: ..., within: ...` on Devise controllers uses `Rails.cache.increment`. Test env's `:null_store` silently no-ops, so those controller-level limits are **currently untestable** without a similar `Rails.cache = MemoryStore.new` swap. If you need to test them, follow the Rack::Attack pattern but swap `Rails.cache` instead of `Rack::Attack.cache.store`.

## What NOT to do

- ❌ Hardcode throttle limits in `config/environments/*.rb` — always via ENV
- ❌ Add per-throttle `unless WEBHOOK_PATHS.match?(req.path)` guards — use one `safelist` block, it short-circuits everything
- ❌ Switch the 429 view to a Rails layout that pulls Warden (any layout calling `impersonation_banner` or `current_user` will crash in middleware context)
- ❌ Remove the controller-level `rate_limit` calls thinking Rack::Attack covers them — different layers, different failure modes
- ❌ Test Rack::Attack against `Rails.cache` without swapping the backend — null_store eats your increments and the test passes by default (false negative)
- ❌ Throttle `^/webhooks/*` or `^/pay/*` — third-party callers, unpredictable IPs, must always deliver
