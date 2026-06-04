---
paths:
  - "app/views/shuby_chats/**"
  - "app/helpers/shuby_chats_helper.rb"
  - "app/services/shuby_assistant_service*.rb"
  - "app/javascript/controllers/**"
---

# AI Chat Markdown Rendering

The Shuby AI assistant is prompted to emit GitHub-flavored markdown (bold, `##`
headings, bullet/numbered lists, `>` quotes, tables — see
`ShubyAssistantService::BASE_SYSTEM_PROMPT`). That markdown is rendered to HTML in
exactly one place, server-side.

## The single entry point

- **`render_chat_markdown(text)`** in `app/helpers/shuby_chats_helper.rb` is the only
  way assistant content becomes HTML. It runs **redcarpet** (GFM extensions:
  `tables`, `fenced_code_blocks`, `autolink`, `strikethrough`, `lax_spacing`,
  `no_intra_emphasis`) then Rails `sanitize` with a tag/attribute allowlist.
- Both partials call it: `_message.html.erb` (assistant branch, final message) and
  `_assistant_message_streaming.html.erb` (each streamed delta). The Turbo broadcast
  re-renders server-side per delta — there is **no** client-side rendering step.

## Hard rules

- **Never render assistant markdown client-side.** A hand-rolled regex parser
  (`markdown_controller.js`) was removed in 2026-06 — it re-parsed *incomplete*
  markdown on every streamed token (line-anchored regexes broke, blocks glued
  together) and was an unsanitized `innerHTML` XSS surface. Do not reintroduce a
  Stimulus/JS markdown controller for chat.
- **LLM output is untrusted.** Always go through `render_chat_markdown` (it sets
  redcarpet `filter_html: true` + `safe_links_only: true` and post-sanitizes). Never
  `raw`/`html_safe` raw model text, and never widen the sanitize allowlist without a
  security reason.
- **Style by element, not inline classes.** A real parser emits bare
  `<h2>/<ul>/<table>/…`; they are styled via `.shuby-message-content` element
  selectors in `app/assets/tailwind/components/shuby/chat.css` using Shuby tokens.
  Add new prose styling there, not as inline utilities (the parser can't emit them).
- **One renderer only.** Don't add a second markdown gem or a parallel helper. Extend
  `render_chat_markdown`. (Archive's `ArchiveHelper#recommendation_html` is a separate,
  intentionally bold-only formatter for tip snippets — not full markdown; don't conflate.)

## Gem choice (redcarpet, not commonmarker)

We use **redcarpet** (C extension). `commonmarker` (Rust) does **not** build on this
project's Ruby — its vendored `time` crate fails under modern `rustc`, and no
precompiled gem covers the Ruby version, so `bundle install` falls back to a broken
source build (locally and on Render). Do not switch to a Rust-native markdown gem until
precompiled gems cover the project's Ruby version.
