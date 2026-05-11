---
paths:
  - "app/notifiers/**"
  - "app/jobs/children/**"
  - "app/jobs/users/**"
  - "config/recurring.yml"
  - "config/initializers/apns.rb"
  - "config/locales/it.yml"
---

# Notification System Conventions

Shuby uses the **Noticed v3** gem with two channels per event: `:action_cable` (in-app real-time + bell-icon) and `:ios` (APNS push). FCM/Android stays dormant (iOS-only deployment).

## Source of truth files
- `config/initializers/apns.rb` — APNS config (bundle id, token-based JWT credentials, kill switch)
- `app/notifiers/application_notifier.rb` — base class with `apns_defaults`, `push_allowed?`, `deliverable_to?`, `IOS_ADAPTER`

## Adding a new notifier

1. Place it under `app/notifiers/<domain>/` (e.g. `app/notifiers/children/`, `app/notifiers/users/`). Class name namespaced (`Children::FooNotifier < ApplicationNotifier`).
2. Declare BOTH delivery methods — never skip `:action_cable`, the in-app bell relies on it:

```ruby
deliver_by :action_cable do |config|
  config.channel = "Noticed::NotificationChannel"
  config.stream = -> { recipient }
  config.message = :to_websocket
end

deliver_by ApplicationNotifier::IOS_ADAPTER do |config|
  ApplicationNotifier.apns_defaults(config)
  config.format = ->(apn) { event.format_apns(apn, recipient) }
end
```

3. Implement `format_apns(apn, recipient)` — set `apn.alert`, `apn.sound`, `apn.badge`. Read i18n keys, never inline Italian strings.
4. Implement `message` (for in-app card) and `url` (for tap deep-link).

## Preference gating — channel vs event

Two distinct toggles in `User::Notifiable`, gated at DIFFERENT layers:

| Preference | Layer | Where to enforce |
|---|---|---|
| `push_notifications_enabled` (default ON) | Channel | Inside `apns_defaults` → `config.if = -> { event.push_allowed?(recipient) }`. Blocks the `:ios` channel only. In-app `:action_cable` still fires so the bell icon updates. |
| `stage_reminders_enabled` (default ON) | Event | Inside scan jobs → `recipients = account.users.select(&:stage_reminders_enabled)`. Prevents `Noticed::Event` row creation entirely for opted-out users. |
| `email_newsletter_enabled` (default OFF) | Channel | Future email notifiers — same pattern as push, `config.if = -> { recipient.email_newsletter_enabled }` on `deliver_by :email`. |

**Do NOT add `config.if = push_allowed?` to `:action_cable`** — that would silence the in-app bell during quiet hours, which is wrong. Push is channel-specific. The bell-icon real-time update must always fire.

## GDPR-safe payload rule

The APNS push body travels through Apple's servers in cleartext. Never include:
- Measurement values (weight/height/head circumference numbers)
- Questionnaire answers or scores
- Medical history fields
- Specific developmental stage clinical content

**OK**: child `display_name`, generic event description ("nuova tappa da osservare").
**NOT OK**: "Sofia pesa 8.2 kg", "Sofia ha completato il questionario X".

Enforced by convention via i18n key contracts. The `%{name}` interpolation is the only variable that should appear in `push.body` strings.

## Italian I18n key structure

Under `config/locales/it.yml`:

```yaml
notifications:
  <domain>:                # account / children / users
    <notifier_name>:       # snake_case of class name minus "Notifier"
      push:
        title: "..."       # ≤ 30 chars ideally (iOS truncates ~40)
        body: "..."        # ≤ 100 chars, includes %{name} or similar
      message: "..."       # for in-app card display
```

Example: `Children::MeasurementReminderNotifier` → `notifications.children.measurement_reminder.{push.title, push.body, message}`.

The `message` key is what `event.message` returns and what the in-app bell-icon card displays. `push.*` keys are what `format_apns` reads.

## Scan job pattern (scheduled triggers)

Add scan jobs under `app/jobs/<domain>/<event>_scan_job.rb`. Register in `config/recurring.yml` under the `production:` block (staggered 15 min apart at minimum to spread DB + APNS load).

Canonical structure:

```ruby
class Children::FooScanJob < ApplicationJob
  queue_as :default
  COOLDOWN = 7.days  # or "lifetime" via no time filter

  def perform
    Time.use_zone("Europe/Rome") do
      Child.active.includes(:account).find_each do |child|
        next if recently_notified?(child)
        next unless trigger_condition?(child)

        recipients = child.account.users.select(&:stage_reminders_enabled)
        next if recipients.empty?

        Children::FooNotifier.with(account: child.account, record: child).deliver(recipients)
      end
    end
  end

  private

  def recently_notified?(child)
    Noticed::Event.where(
      type: "Children::FooNotifier",
      record_type: "Child",
      record_id: child.id
    ).where(created_at: COOLDOWN.ago..).exists?
  end
end
```

**Critical: always include `record_type:` in the `Noticed::Event` dedupe query.** Polymorphic `record_id` alone can collide across model types. Forgetting this is a classic Rails bug.

**Always wrap in `Time.use_zone("Europe/Rome")`**. SolidQueue cron expressions like `at 9am Europe/Rome` set the trigger time, but inside the job the default Time zone may still be UTC. Use the zone block so `<n>.days.ago.beginning_of_day` resolves to Italian local time.

## Quiet hours

`ApplicationNotifier.deliverable_to?(recipient)` returns false during 22:00–08:00 in the recipient's `time_zone` (default Europe/Rome when nil). Wired into `push_allowed?`. Behavior: **skip, don't defer** — next day's scan will pick up still-relevant events. Avoids queue bloat from re-queued items.

In-app `:action_cable` does NOT respect quiet hours — silent in-app updates at night are fine; only push wakes the device.

## Testing notifiers

- `IOS_ADAPTER == :test` in `Rails.env.test?` — Noticed's `Test` delivery method appends to `Noticed::DeliveryMethods::Test.delivered`. No HTTP, no WebMock allowlist changes.
- Notifier-level tests: assert via `Children::FooNotifier.count` (STI scope on `Noticed::Event`).
- Job-level tests: explicit polymorphic filter for assertions:
  ```ruby
  Noticed::Event.where(type: "Children::FooNotifier", record_type: "Child", record_id: child.id).exists?
  ```
- `.with(...).save!` creates the Event row without enqueuing delivery jobs — sufficient for "event row created" assertions. For "delivery actually ran" assertions, wrap `.deliver(users)` in `perform_enqueued_jobs { ... }`.

## APNS credentials

Token-based JWT auth (`.p8` AuthKey from Apple Developer → Keys). Cert-based is NOT supported by Noticed v3's `:ios` adapter. Credentials live in encrypted Rails credentials under:

```yaml
apns:
  team_id: "XXXXXXXXXX"   # 10 chars
  key_id:  "YYYYYYYYYY"   # 10 chars
  auth_key: |
    -----BEGIN PRIVATE KEY-----
    <full .p8 contents>
    -----END PRIVATE KEY-----
```

Edit per-environment: `bin/rails credentials:edit -e production` (+ development, staging). Test env uses `:test` adapter so credentials can be absent there.

## Global kill switch

`Rails.application.config.x.push_notifications_enabled` defaults to `true`. Flip to `false` in `config/environments/<env>.rb` or via a Rails console override during a production incident to suppress all APNS delivery without touching code. ActionCable in-app delivery continues unaffected.

## What NOT to do

- ❌ Add `config.if = push_allowed?` to `:action_cable` (silences in-app bell — wrong)
- ❌ Inline Italian strings in `format_apns` (always use I18n keys)
- ❌ Include measurement values or questionnaire answers in push body (GDPR violation)
- ❌ Use cert-based APNS auth (Noticed v3 only supports token-based)
- ❌ Forget `record_type:` in `Noticed::Event` dedupe queries
- ❌ Forget `Time.use_zone("Europe/Rome")` wrapper in scan jobs
- ❌ Wire `deliver_by :fcm` for v1.0 (Shuby ships iOS-only — keeps `fcm: true` flag dormant)
