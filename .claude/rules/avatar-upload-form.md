---
paths:
  - "app/views/**/*.erb"
  - "app/javascript/controllers/**/*_controller.js"
  - "app/assets/tailwind/components/shuby/forms.css"
---

# Avatar Upload Form Pattern

Live-preview avatar upload (file input → instant in-page preview swap before
submit) is implemented ONCE and shared across forms. Do not reinvent per form.
The pattern lives in three pieces. Reuse all three together; never partially
adopt.

## The trio

1. **Stimulus controller** — `app/javascript/controllers/avatar_upload_controller.js`.
   Targets: `preview` (the `<img>` whose `src` is swapped), optional `placeholder`
   (element to hide on selection). Action: `preview(event)` reads
   `FileReader.readAsDataURL(file)` and assigns the data URL to
   `previewTarget.src`. Uses defensive `has<X>Target` checks so the same
   controller works whether the form has a fallback element or not.

2. **CSS wrapper** — `.shuby-avatar-upload-preview` in
   `app/assets/tailwind/components/shuby/forms.css`. 96px circle, white border,
   drop shadow, blue-400 background. Domain-neutral name (no `-child-` /
   `-user-` prefix) — used by both `children/_form.html.erb` and
   `devise/registrations/edit.html.erb`. If a third upload form lands, reuse
   this class; don't fork a parallel wrapper.

3. **Camera-icon button partial** — `app/views/shared/ui/_avatar_upload_camera_btn.html.erb`.
   Required local: `for_id:` — id of the hidden `<input type="file">` that
   this `<label for=…>` triggers. Carries `aria-label` from
   `shared.ui.avatar_upload_camera_btn.label` (i18n).

## Wiring template

```erb
<div class="flex flex-col items-center" data-controller="avatar-upload">
  <div class="relative">
    <div class="shuby-avatar-upload-preview">
      <%# Either:
          (a) image_tag with data-avatar-upload-target="preview" — for
              user/account forms, since avatar_url_for always returns a URL
              (gravatar fallback)
          or
          (b) a fallback <span data-avatar-upload-target="placeholder">
              containing the icon SVG, alongside a hidden
              <img data-avatar-upload-target="preview"> — for child forms
              when child.avatar isn't attached %>
    </div>
    <%= render "shared/ui/avatar_upload_camera_btn", for_id: "<unique_id>" %>
  </div>
  <%= form.file_field :avatar, accept: "image/*", class: "hidden", id: "<unique_id>",
        direct_upload: true,
        data: { action: "change->avatar-upload#preview" } %>
</div>
```

## Fallback element — when do you need a `placeholder` target?

- **User / account forms**: NO. `avatar_url_for(record, size: 96)` always
  returns a URL (Gravatar fallback if no attachment). The preview `<img>` is
  always rendered; selecting a new file swaps its `src`.
- **Child forms**: YES, when no avatar is attached. The fallback is the
  `icon-baby` glyph (per `child-avatar.md`), wrapped in a
  `data-avatar-upload-target="placeholder"` span. A hidden
  `<img data-avatar-upload-target="preview">` sits alongside; the controller
  unhides it on file selection.

## What NOT to do

- ❌ Inline `onchange="…"` FileReader strings on the `file_field`. Wire the
  Stimulus controller instead. (Inline JS was previously in
  `children/_form.html.erb`; it has been removed. Don't reintroduce.)
- ❌ Fork a `.shuby-<context>-form-avatar-preview` class. The wrapper is
  domain-neutral; reuse it.
- ❌ Hard-code the camera SVG inline. Render
  `shared/ui/_avatar_upload_camera_btn` instead.
- ❌ Forget `aria-label` on the camera label — the partial supplies it via
  i18n.
- ❌ Reuse `app/views/shared/ui/_avatar.html.erb` for the upload preview.
  That partial is **display-only** (no file input, no preview wiring) and
  uses the `icon-baby` fallback — wrong for user/account forms.

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
