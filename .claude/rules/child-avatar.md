---
paths:
  - "app/views/**/*.erb"
  - "app/assets/tailwind/components/shuby/icon-buttons.css"
  - "app/assets/tailwind/components/shuby/settings.css"
  - "app/helpers/**_helper.rb"
---

# Child Avatar — Source of Truth

Figma node `159:935` is the canonical avatar component for **every child**
rendered anywhere in the app. There is exactly one fallback shape and it
is never an initial letter.

## Ring color

The default (unselected) ring is **`--color-shuby-blue-800`** (#0159b5)
on every child avatar. This is the dark navy ring you see around photos
and smiley fallbacks alike. Already encoded on `.shuby-avatar-btn` and
`.shuby-avatar`.

The selected / on-dark-surface variant uses the `.-bianco` modifier
which flips the ring to white. Do not invent intermediate ring colors
(blue-400, blue-500, etc.) — they were the old spec and have been
removed.

## The three states

1. **Photo attached** — render `image_tag child.avatar` clipped to the
   circular wrapper. Wrapper supplies the blue-800 ring (`.shuby-avatar-btn`
   / `.shuby-avatar`).
2. **No photo, light surface** — render
   `render_svg "shuby/icons/icon-baby"` inside the wrapper. The SVG uses
   `fill="currentColor"`, so set `color: var(--color-shuby-blue-800)` on
   the wrapper (already on `.shuby-avatar-btn` and `.shuby-member-avatar`).
   The ring + glyph thus share a single token — change the token, both
   re-color in lockstep.
3. **No photo, on a dark blue-800 surface** — apply the `.-bianco`
   modifier on `.shuby-avatar-btn`. That flips the ring to white,
   background to transparent, and `color` to white so the same icon
   recolors via `currentColor`.

## What you must NOT do

- **No initial-letter fallback.** Classes `.shuby-avatar-initials` and
  `.shuby-member-avatar-emoji` were removed precisely so this can't drift
  back. If a future caller needs a placeholder, it is `icon-baby` —
  always.
- **Do not add a new "smiley" SVG.** `app/assets/images/shuby/icons/icon-baby.svg`
  is the single canonical glyph. Reuse it; don't compose a new one from
  Figma even if the Figma export looks different — the export is the
  source-of-truth shape, but our SVG already matches it.
- **Do not omit the wrapper color.** Without `color:
  var(--color-shuby-blue-800)`, the SVG renders in the ambient document
  color (typically gray/black) and looks broken.

## Glyph sizing — owned by the wrapper, not the callsite

**Callsites must NOT pass `styles: "w-X h-X"` or `size:` for avatar SVGs.**
Every wrapper class ships with a CSS rule sizing its descendant SVG, so
the callsite renders only `<%= render_svg "shuby/icons/icon-baby" %>`
(plus `decorative: true` if the icon is purely visual). The wrapper
decides; callers can't drift.

CSS rules (do not duplicate inline):

| Wrapper                         | Wrapper size | SVG (auto, via CSS) |
|---------------------------------|--------------|---------------------|
| `.shuby-avatar-btn`             | 40px         | 32px                |
| `.shuby-avatar`                 | 48px         | 36px                |
| `.shuby-avatar.shuby-avatar-sm` | 32px         | 24px                |
| `.shuby-avatar.shuby-avatar-md` | 40px         | 32px                |
| `.shuby-avatar.shuby-avatar-lg` | 80px         | 64px                |
| `.shuby-avatar.shuby-avatar-xl` | 120px        | 96px                |

Source-of-truth ratio is ~80% wrapper → glyph, derived from visual
measurement of Figma 159:935 (the avatar component). The earlier
inset-from-React-snippet derivation gave 60% and was wrong: the React
snippet's inset is the icon's own padding within its source clip-mask,
not the rendered glyph-to-wrapper ratio. When Figma screenshot disagrees
with snippet math, screenshot wins.

To add a new size, add the wrapper class AND a matching `> svg { width:
...; height: ...; }` rule in the same file. Do NOT introduce a
per-callsite override — that's how the smell came back the first time.

**Single exception**: the 96px upload-preview circle (class
`.shuby-avatar-upload-preview`, used in `children/_form.html.erb` AND
`devise/registrations/edit.html.erb`) keeps its explicit
`styles: "w-16 h-16"` on the inner `icon-baby` placeholder. It is not
part of the canonical avatar component (custom upload-form wrapper, see
`.claude/rules/avatar-upload-form.md`), so the wrapper-owned-sizing rule
does not apply there.

**Canonical wrapper is `.shuby-avatar-btn`.** Backs the dashboard profile
button, timeline header, child-selector pill, settings family-member
card, AND the family-profiles children list. A previous
`.shuby-member-avatar` carved out its own ring color, background, AND
glyph size — all three have been removed. If a new context needs an
avatar, use `.shuby-avatar-btn` (or the size-variant `.shuby-avatar`
for non-button contexts).

## Adult / account avatars

Parent / User avatars come from the `avatar_url_for(record, ...)` helper
(Gravatar fallback) when displayed inline (custom headers, lists). For
upload forms, the same `shared/ui/_avatar.html.erb` partial handles both
user and child avatars — pass `form:` plus `fallback: :gravatar` for the
user-style preview (image_tag from `avatar_url_for`) or `fallback: :baby`
for the child-style preview (icon-baby placeholder + hidden preview img).
See `.claude/rules/avatar-upload-form.md` for the full local contract.

This rule's display-avatar ring + sizing guidance (above) applies to
children. User/account inline display surfaces (e.g. dashboard profile
button) don't share the `.shuby-avatar` wrapper styling — they use their
own per-context CSS.

## Existing call sites

The unified partial at `app/views/shared/ui/_avatar.html.erb` is the
preferred entry point for both display and upload. Display callers pass
`child:`; upload callers pass `form:`. When inline rendering is necessary
(custom layout, header context that needs a non-standard wrapper), follow
the wrapper + `render_svg "shuby/icons/icon-baby"` pattern shown in
`shared/dashboard_header/_profile_button.html.erb` or
`shared/dashboard_header/_child_selector_overlay.html.erb`.
