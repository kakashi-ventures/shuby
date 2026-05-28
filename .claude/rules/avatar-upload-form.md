---
paths:
  - "app/views/**/*.erb"
  - "app/javascript/controllers/**/*_controller.js"
  - "app/assets/tailwind/components/shuby/forms.css"
---

# Avatar Upload Form Pattern

Live-preview avatar upload (file input → instant in-page preview swap before
submit) is rendered via the **unified avatar partial** at
`app/views/shared/ui/_avatar.html.erb`. The same partial also handles
read-only avatar display. Branch is determined by which local is passed:

- Pass `child:` → DISPLAY mode (read-only image / icon-baby fallback).
- Pass `form:` → UPLOAD mode (file input + Stimulus controller + camera
  button + live preview).

Do not reinvent per form, and do not maintain a parallel upload-only partial.

## Upload mode

Required local:

- `form:` — FormBuilder.

Optional locals:

- `field:` — file attribute name (default `:avatar`).
- `fallback:` —
  - `:gravatar` for user / account forms (image_tag always rendered via
    `avatar_url_for`, no placeholder target needed).
  - `:baby` for child forms (icon-baby placeholder span with hidden preview
    img that the Stimulus controller un-hides on file selection).
  - Default `:baby`.
- `help:` — optional help text (Italian, usually i18n string) rendered as
  `<p class="shuby-caption text-gray-400 mt-2">` under the preview.

Example callsites:

```erb
<%# Devise user edit form (Gravatar fallback) %>
<%= render "shared/ui/avatar",
      form: form,
      fallback: :gravatar,
      help: t("devise.registrations.edit.avatar_help") %>

<%# Child profile edit form (icon-baby fallback) %>
<%= render "shared/ui/avatar",
      form: form,
      fallback: :baby,
      help: t("children.form.avatar_help") %>
```

The partial wires three primitives — reuse them as-is, never fork:

1. **Stimulus controller** — `app/javascript/controllers/avatar_upload_controller.js`.
   Targets: `preview` (the `<img>` whose `src` is swapped), optional
   `placeholder` (element to hide on selection). Action `preview(event)` reads
   `FileReader.readAsDataURL(file)` and assigns the data URL to
   `previewTarget.src`. Uses defensive `has<X>Target` checks so the same
   controller works whether the form has a fallback element or not.

2. **CSS wrapper** — `.shuby-avatar-upload-preview` in
   `app/assets/tailwind/components/shuby/forms.css`. 96px circle, white
   border, drop shadow, blue-400 background. Domain-neutral name. If a third
   upload form lands, reuse this class; don't fork a parallel wrapper.

3. **Camera-icon button partial** —
   `app/views/shared/ui/_avatar_upload_camera_btn.html.erb`. Required local:
   `for_id:` — id of the hidden `<input type="file">` that this `<label for=…>`
   triggers. Carries `aria-label` from
   `shared.ui.avatar_upload_camera_btn.label` (i18n).

The unified partial computes `input_id` from
`form.object.model_name.singular + "_" + field`, producing the same ids
(`user_avatar`, `child_avatar`) as the previous inlined forms.

## Display mode

Required local: `child:` (Child record). Optional: `size:`
(`"sm"`/`"md"`/`"base"`/`"lg"`/`"xl"`), `class:`. Renders an `<img>` when the
avatar is attached, or a sized `.shuby-avatar-fallback` div containing the
`icon-baby` SVG when not.

## What NOT to do

- ❌ Inline `onchange="…"` FileReader strings on the file_field. The shared
  Stimulus controller handles it.
- ❌ Fork a `.shuby-<context>-form-avatar-preview` CSS class. The wrapper is
  domain-neutral.
- ❌ Re-inline the upload trio in a new form view. Pass `form:` to
  `shared/ui/avatar` instead.
- ❌ Hard-code the camera SVG inline. Render
  `shared/ui/_avatar_upload_camera_btn` instead.
- ❌ Forget `aria-label` on the camera label — the partial supplies it via
  i18n.

## Verifying Stimulus wiring without authentication

The Devise edit view can't be rendered via `ApplicationController.renderer`
in a `rails runner` script — `resource` / `resource_name` / `devise_mapping`
are controller-instance methods set by `Devise::Controllers::Helpers`, not
bare assigns. To verify the wiring contract without signing in, render
`children/_form` (it shares the partial, controller, and class with the user
form) and grep for `data-controller="avatar-upload"`,
`avatar-upload-target="preview"`, and the absence of `onchange=` or
`.shuby-child-form-avatar-preview`. Remember that ERB HTML-escapes `>` in
data attributes, so `change->avatar-upload#preview` appears as
`change-&gt;avatar-upload#preview` in the raw output (browser unescapes on
parse — Stimulus reads the value correctly at runtime).
