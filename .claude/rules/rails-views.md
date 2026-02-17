---
paths:
  - "app/views/**/*.erb"
  - "app/components/**/*.rb"
---

# Rails View & Component Conventions

## Styling
- Use TailwindCSS v4 utility classes exclusively — no custom CSS unless absolutely necessary
- Mobile-first responsive design (Hotwire Native compatibility)
- Follow existing color palette and spacing patterns in the codebase

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

## Language
- All user-facing text must be in Italian
- Use I18n when available, otherwise hardcode Italian strings
