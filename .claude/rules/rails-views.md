---
paths:
  - "app/views/**/*.erb"
  - "app/components/**/*.rb"
---

# Rails View & Component Conventions

## Styling
- Default to TailwindCSS v4 utility classes for one-off layout and spacing
- For named design-system elements (buttons, cards, toggles, badges, etc.) or any pattern that repeats, use or add a semantic class in `app/assets/tailwind/components/shuby/`
  - Class names describe the domain role, not the HTML shape (e.g. `.shuby-btn-danger-subtle`, not `.shuby-red-button`)
  - Before adding a new class, grep the existing `shuby/*.css` files — many variants already exist
  - Prefer existing tokens (`--bg-danger-secondary`, `--color-shuby-blue-600`, etc.) over hardcoded colors
- Avoid long inline utility chains that reimplement an existing component (e.g. rebuilding the toggle switch with `peer-checked:after:*` when `.shuby-toggle` already exists)
- Mobile-first responsive design (Hotwire Native compatibility); native-only rules scoped to `html.hotwire-native` in `hotwire_native.css`

## Hotwire
- Use Turbo Frames (`<turbo-frame>`) for partial page updates
- Use Turbo Streams for server-pushed updates (create, update, destroy actions)
- Use Stimulus controllers for JavaScript behavior — no inline JS

## View Components
- Use view components (`app/components/`) for reusable UI elements
- Components should be self-contained with their own templates
- Prefer components over partials for complex, reusable UI

## Accessibility
- Include proper ARIA labels and roles
- Ensure keyboard navigation works
- Use semantic HTML elements (nav, main, section, article)

## View Decomposition (DRY)
- Views MUST stay under 50 lines — extract into partials immediately
- If an HTML block repeats 3+ times, extract a helper method in `app/helpers/`
- Use data constants + `.each` loops for repetitive structures (color swatches, nav items, card grids)
- Inline SVGs that exist in `app/assets/images/` MUST use `render_svg` from `ImagesHelper`
- Every self-contained section (with its own h2/h3 heading) should be its own partial

## Partials
- Name with `_section_` prefix for page sections: `_section_colors.html.erb`
- Name with `_` prefix for reusable fragments: `_card.html.erb`
- Keep partials under 100 lines — further decompose if exceeded
- Pass data via locals, not instance variables (except for main page views)

## Language
- All user-facing text must be in Italian
- Use I18n when available, otherwise hardcode Italian strings
