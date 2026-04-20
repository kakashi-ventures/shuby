---
paths:
  - "app/views/layouts/**"
  - "app/assets/tailwind/**"
  - "config/ruby_native.yml"
  - "app/views/**/_*nav*.erb"
  - "app/views/**/_*header*.erb"
---

# Ruby Native / iOS

## CSS scoping
- ALL native-only CSS scoped to `html.hotwire-native`
- `env(safe-area-inset-*)` safe unconditionally (0px in browsers)
- New sticky headers: add safe-area padding in `hotwire_native.css`

## Navigation
- NO `native_navbar_tag` — custom web headers per Figma
- Native iOS tab bar replaces web bottom nav
- `/today` = Oggi tab route (not `/`)

## Forms
- `<%= native_form_tag %>` on form pages
- `data: native_haptic_data(:success)` on submit buttons
- auto_route: `/children/*` -> Oggi tab

## CRITICAL: auto_route pitfall
- **NEVER** add `/users/*` as an auto_route prefix — it intercepts Devise auth paths (`/users/sign_in`, `/users/sign_out`) and breaks pre-auth navigation completely
- Keep auto_route entries minimal and specific

## Conditionals
- Use `hotwire_native_app?` (not `native_app?`) — it's overridden in `app/controllers/concerns/authentication.rb` to match Ruby Native's UA too
- Jumpstart bridge controllers (`bridge--form`, `bridge--sign-out`) do NOT load in Ruby Native — the `shouldLoad` mechanism finds no registered components. This is fine.
- Test both web and native when modifying layouts

## Native UA detection — single point of truth
- Ruby Native 0.7 sends `"Ruby Native"` / `"RubyNative/0.7.0"` in User-Agent; turbo-rails' default `hotwire_native_app?` only matches `/(Turbo|Hotwire) Native/` so it silently returns `false` in the iOS shell
- Shuby overrides `hotwire_native_app?` in `app/controllers/concerns/authentication.rb` with regex `/(Turbo|Hotwire|Ruby) Native/` — this is the ONLY place that parses the UA
- Never add new UA-parsing code elsewhere; always call the helper. JS-side: read `document.documentElement.classList.contains("hotwire-native")` (set server-side by the same helper) or feature-detect `typeof RubyNative !== 'undefined'`
- If a new native-only check is needed, scope CSS to `html.hotwire-native` — never to specific UA strings
