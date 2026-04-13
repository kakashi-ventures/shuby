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
- auto_route: `/children/*` -> Oggi tab. NEVER route `/users/*`

## Conditionals
- Use `hotwire_native_app?` (not `native_app?`)
- Test both web and native when modifying layouts
