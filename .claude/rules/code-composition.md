---
paths:
  - "app/**/*.rb"
  - "app/views/**/*.erb"
  - "app/components/**/*.rb"
---

# Code Composition & DRY Principles

## File Size Limits
- **Views/ERB**: Max 50 lines — extract sections into partials
- **Partials**: Max 100 lines — further decompose if exceeded
- **Controllers**: Max 150 lines — delegate to services
- **Models**: Max 300 lines — extract into modules/concerns
- **Services**: Max 200 lines — split into focused classes
- **Helpers**: Max 200 lines — split by domain concern

## DRY: Don't Repeat Yourself
- If an HTML structure repeats 3+ times with only data changing, extract a helper method
- If an SVG/icon appears in more than one place, use `render_svg` or a shared partial
- If a view section is self-contained (has its own heading), it belongs in a partial
- Define repetitive data (color palettes, nav items, form options) as constants, not inline HTML

## Single Responsibility Principle
- Each partial renders ONE section or concept
- Each helper method does ONE thing (render a swatch, render a specimen)
- Controllers handle routing + auth only — business logic goes in services
- Models handle data + validation only — complex queries go in scopes/services

## View Decomposition Strategy
- Views > 50 lines MUST be decomposed into partials
- Use `render "path/to/partial"` for section-level composition
- Use helpers for micro-patterns (repeated 3+ times)
- Use data constants + loops instead of copy-pasting HTML blocks
- Prefer `app/helpers/` for view-rendering helpers (following BadgesHelper pattern)
- Prefer `app/components/` for stateful/interactive UI elements

## Before Creating Any File
- Check if a similar helper, partial, or component already exists
- Reuse existing patterns (`render_svg`, `badge()`, `JumpstartComponent`)
- Never inline SVGs that exist as assets in `app/assets/images/`
