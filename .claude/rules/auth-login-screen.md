---
paths:
  - "app/views/devise/sessions/**"
  - "app/views/layouts/auth.html.erb"
  - "app/controllers/users/sessions_controller.rb"
  - "app/assets/tailwind/components/shuby/auth.css"
  - "app/javascript/controllers/biometric_login_controller.js"
---

# Login Screen (Devise sessions#new)

Figma source of truth: node `2524:10888` (see `docs/FIGMA-REFERENCE.md` →
Sub-nodes → Login). Full-bleed `blu-300` brand screen — NOT the white-card
`devise/shared/_form_block`.

## Layout routing — login is special

- Login (`sessions#new`) uses the dedicated **`auth` layout**
  (`app/views/layouts/auth.html.erb`): full-bleed `blu-300`, no
  `.minimal-top-nav` (logo lives in the page), safe-area top, decorative blobs.
- The switch lives in `Users::SessionsController#set_layout` (override of the
  `Authentication` concern): `new` → `"auth"`, everything else (`create`, `otp`)
  falls through to `super` → `"minimal"`. **Do not** use `layout "auth", only:`
  — Rails keeps only the last `layout` declaration and would strip the
  concern's `set_layout` from `create`/`otp` (the 2FA screen).
- **Sibling auth pages** (register / password reset / confirmation / unlock)
  still use `minimal` + `devise/shared/_form_block`. Their redesign is a logged
  follow-up in `docs/REMAINING-WORK.md` — keep them on `minimal` until then.

## Reuse the design system — do not reinvent

The login is built entirely from existing `shuby/*` classes. When editing,
reuse these (don't fork new ones):

- **Underline fields** = the Form component (`220:2532`):
  `.shuby-form-group` → `.shuby-form-label` → `.shuby-form-input-wrapper` →
  `.shuby-form-input-underline` (`components/shuby/forms.css`). Labels render
  **uppercase** by the component (`text-transform` on `.shuby-form-label`) —
  this is intentional design-system behavior, shared with the measurement
  overlay; don't "fix" it to title-case on login alone.
- **Pill submit** = `.shuby-btn .shuby-btn-primary .shuby-btn-lg`
  (`.shuby-auth-submit` only trims `padding-block` to hit Figma's 48px).
- **Round button** = `.shuby-icon-btn` (Round Button `159:915`), sized to 48px
  via `.shuby-auth-faceid`.
- Login-only layout/blob/spacing lives in `components/shuby/auth.css`.
- Underline inputs must zero the `@tailwindcss/forms` focus `box-shadow`
  (`.shuby-auth-card .shuby-form-input-underline:focus`) — otherwise the
  autofocused field shows a rectangular ring around a borderless input.

## Face-ID button is AutoFill, NOT biometric auth

The round Face-ID button (`icon-face-id.svg` + `biometric_login_controller.js`)
focuses the email field to surface **iOS Password AutoFill** (Face ID fills the
saved password). This works because associated domains are configured in
`config/ruby_native.yml` and the fields carry `autocomplete` attributes — there
is **no** real biometric/WebAuthn flow in the app. Don't treat the button as
working tap-to-authenticate, and don't add a native biometric bridge
(`ruby_native` 0.10.2 ships none). True passkey/WebAuthn login is a tracked
follow-up in `docs/REMAINING-WORK.md`.
