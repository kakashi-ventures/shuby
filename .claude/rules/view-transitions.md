---
paths:
  - "app/views/**/*.erb"
  - "app/assets/tailwind/components/view_transitions.css"
  - "app/controllers/**/*.rb"
---

# View Transitions & Page Animations

Shuby uses Turbo 8's View Transitions API for smooth page-to-page animations. The infrastructure is in place — new views must opt into the right bucket, nothing more.

## Tag every non-root view

At the top of the view (after `content_for :title`), add:

```erb
<% content_for :page_type, "detail" %>   <%# drill-down, slide iOS-style %>
<% content_for :page_type, "wizard" %>   <%# linear step flow, slide iOS-style %>
<% content_for :page_type, "immersive" %> <%# no Turbo VT — for custom Stimulus animations %>
```

Omit entirely for "root" (crossfade, default — tab roots, index lists).

**Decision table for new views**:

| View type                                     | page_type   |
|-----------------------------------------------|-------------|
| Tab root, index list, section landing         | (omit)      |
| Resource `show`, `new`, `edit`                | `detail`    |
| Multi-step form, onboarding, questionnaire wizard | `wizard`  |
| Fullscreen takeover with own Stimulus animations | `immersive` |

## Non-obvious: `data-page-type` is on `<body>`, not `<html>`

Turbo swaps `<body>` across visits but preserves `<html>` attributes. Putting `data-page-type` on `<body>` means the value updates on every Turbo visit automatically. The CSS uses `:has()` to let `::view-transition-*` pseudo-elements (which are rooted at `<html>`) match against body:

```css
html:has(body[data-page-type="detail"])::view-transition-new(root) { ... }
```

**Do not move `data-page-type` to `<html>`** — it would stick at the initial-load value and never update.

## Turbo Stream insertions: `streamed:` local contract

Partials rendered both initially AND via Turbo Stream append must accept a `streamed:` local and conditionally add `.turbo-stream-enter`:

```erb
<%# _message.html.erb — dual-purpose partial %>
<% enter_class = local_assigns[:streamed] ? " turbo-stream-enter" : "" %>
<div class="flex ...<%= enter_class %>">...</div>
```

Controllers/stream templates pass `streamed: true` only when appending:

```ruby
# shuby_chats_controller.rb
streams << turbo_stream.append("messages", partial: "shuby_chats/message",
  locals: { message: user_message, streamed: true })
```

Partials only ever rendered via stream (e.g., `_assistant_message_placeholder.html.erb`) can hardcode the class.

## Accessibility

`prefers-reduced-motion: reduce` disables all VT animations via `@media` query in `view_transitions.css`. Do not add new keyframes to this file without preserving that fallback.

## iOS Ruby Native compatibility

- iOS 18.2+ WKWebView: native support, all animations work
- iOS <18.2: graceful degradation (no animation, no error, no regression)
- `#native-tabs-signal` (data-turbo-permanent) is preserved across transitions — do not add `view-transition-name` to permanent elements

## Files

- `app/assets/tailwind/components/view_transitions.css` — all keyframes + CSS rules
- `app/helpers/application_helper.rb` → `page_transition_type` — reads content_for
- `app/views/application/_head.html.erb` — meta tags (`view-transition`, `turbo-refresh-method`, `turbo-refresh-scroll`)
- `app/views/layouts/{application,minimal,onboarding,stories}.html.erb` — body carries `data-page-type`
