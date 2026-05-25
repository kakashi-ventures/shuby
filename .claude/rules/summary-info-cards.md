---
paths:
  - "app/views/**/*.erb"
  - "app/helpers/**/*.rb"
  - "app/assets/tailwind/components/shuby/**/*.css"
---

# Summary Info Cards (label → value rows)

Use this pattern when a show page needs a card of read-only key/value rows
(e.g. `/children/:id` "Informazioni", a future `/accounts/:id` profile
card, or `/measurements/:id` detail). Figma source-of-truth: child Info
tab node `434:13573`.

## The trio

1. **Data lives in a domain helper**, returning `[label, value]` tuples
   in display order — not inline arrays in the view.

   ```ruby
   # app/helpers/<domain>_helper.rb
   def child_info_rows(child)
     [
       [t("children.show.field.name"), child.display_name],
       [t("children.show.field.birth_date"), (l(child.birth_date, format: :short_dotted) if child.birth_date)],
       # ...
     ]
   end
   ```

   Reordering, adding, or removing rows is a one-line helper change. No
   view edits needed.

2. **Layout owned by the `_info_row.html.erb` partial** under the same
   resource folder. Accepts `label:` and `value:` locals. Renders an
   em-dash placeholder (`—`) when the value is nil or blank, so the
   visual row count is stable for sparse data.

3. **Visuals owned by `.shuby-info-row`** in
   `app/assets/tailwind/components/shuby/info-rows.css`. Blue-700
   uppercase label, gray-800 value, hairline divider below all but the
   last row. Don't reach for utility chains in the view — extend the CSS
   class if you need a new variant.

## Card wrapper

The container is a plain `.shuby-card` with a header row of
`shuby-h3` title plus an icon-only `.shuby-icon-btn-azzurro
shuby-icon-btn-sm` edit button (light-blue circle, pencil icon, accessible
name via `aria: {label: ...}`). The edit button must carry no visible
text — the icon alone communicates intent at this size.

## Empty values

Always render every configured row. Skip-when-nil hides design rhythm and
makes sparse profiles look broken. Use em-dash; if the row is mandatory
data the user should fill in, that empty cue doubles as a nudge.

## Where to extend

Reuse the partial + CSS class across domains. The helper is per-domain
(name it `<domain>_info_rows`), since label keys and value derivations
differ. Don't push the row-data helper into `ApplicationHelper` — that
couples unrelated screens.
