# Shuby Figma Design Reference

**Main file**: https://www.figma.com/design/qriF7HfsvoG8VUSdjUETBd/Shuby_App
**fileKey**: `qriF7HfsvoG8VUSdjUETBd`

## Tools

- **Figma MCP**: `get_design_context` (code + screenshot + hints), `get_screenshot` (visual), `get_metadata` (structure)
- **Playwright CLI**: `playwright-cli screenshot` for local app screenshots (more efficient than Playwright MCP)
- The Figma file is large and complex. Always use `get_metadata` first to navigate to the right nodeId, then `get_design_context` on the specific node.

## Node Map (main screens)

| Screen | Figma nodeId | Figma Name |
|--------|-------------|------------|
| Dashboard (blue header) | `375:5429` | 01.01_Hero/Azzurra |
| Dashboard (white header) | `434:12577` | 01.01_Hero/Bianca |
| Dashboard variant 2 | `499:6713` | 01.03_Hero/Azzurra 2 |
| Timeline (current) | `211:2608` | 02.01_Timeline |
| Timeline (past) | `322:7818` | 02.02_Timeline_Passato |
| Timeline (future, free user) | `2002:8929` | 02.03_Timeline_Futuro (supersedes `322:8041`) |
| Child profile - Info | `434:13573` | 03.01_Scheda bambino_Info |
| Child profile - Measurements 1 | `436:4638` | 03.02_Scheda bambino_Misurazioni_01 |
| Child profile - Measurements 2 | `451:5043` | 03.03_Scheda bambino_Misurazioni_02 |
| Child profile - Stages 1 | `451:5546` | 03.04_Scheda bambino_Tappe/01 |
| Child profile - Stages 2 | `541:7850` | 03.04_Scheda bambino_Tappe/02 |
| AI Helper | `463:5386` | 04.01_AI_helper |
| Archive | `463:6063` | 05.01_Archivio |
| Article detail | `510:22491` | 05.02_Articolo |
| Activity detail | `532:24578` | 05.03_Attività |
| Game detail | `532:25861` | 05.04_Gioco |
| Book detail | `532:26226` | 05.05_Libro |
| Settings/Account | `455:5017` | 06.01_Gestione |
| Add measurement overlay | `621:9860` | 00.05_Overlay_Aggiungi Altezza |
| Questionnaire overlay — intro | `499:5449` | 07.01_Test_01 (Comunicazione e linguaggio cover) |
| Questionnaire overlay — Q1 | `499:5450` | 07.01_Test_01 (Domanda 1, area-specific illustration) |
| Questionnaire overlay — Q2 | `499:5511` | 07.01_Test_01 (Domanda 2, area-specific illustration) |
| Questionnaire overlay — Q3 | `499:5540` | 07.01_Test_01 (Domanda 3, area-specific illustration) |
| Questionnaire overlay — completion | `499:5853` | 07.01_Test_01 (Tappa completata, verde-scuro-500 bg) |

## Components (design system)

Colors section, Typography section, plus:

| Component | nodeId |
|-----------|--------|
| Header | `379:5503` |
| Button | `65:38` |
| Timeline | `322:6922` |
| Scheda Test | `413:3498` |
| Scheda Attivita | `413:3570` |
| Scheda Misurazioni | `413:3671` |
| Scheda Consigli | `413:3942` |
| Tab | `436:4918` |
| Form | `220:2532` |
| Chat | `230:1824` |
| Child selector | `220:2341` |
| Menu | `198:3262` |

## Sub-nodes (detailed screen breakdowns)

## Prototype REST API helper

The Figma MCP server only returns **static** data (layout, tokens, screenshots). For prototype interactions, transition timings, easing and target frames — which live in the Figma file but are not exposed by the MCP — use the REST API helper:

```bash
bin/figma_prototype_info <nodeId> [<nodeId2> ...]
# Example:
bin/figma_prototype_info 2002:8929
```

### Setup (one-time)

1. Create a personal access token at https://www.figma.com/developers/api#access-tokens with scope `files:read`
2. Add it to Rails credentials:
   ```bash
   bin/rails credentials:edit
   ```
   ```yaml
   figma:
     personal_access_token: figd_...
   ```
   (Alternatively, set `ENV["FIGMA_PERSONAL_ACCESS_TOKEN"]` — useful in CI.)
3. Override the file key per invocation with `FIGMA_FILE_KEY=...` if you need to inspect a different file.

### Rate limits

Figma's REST API rate-limit tier depends on the plan of the file owner, not the token owner. On a Starter plan file, a personal token is capped to ~6 requests/month *per file* for the files endpoint. Pro/Org/Enterprise plans are much more generous. The script warns on `X-Figma-Rate-Limit-Type: low` and exits non-zero with `Retry-After` on 429.

### What it extracts

- `interactions[]` — triggers (ON_CLICK, ON_HOVER, AFTER_TIMEOUT, etc.) + actions (NAVIGATE, OVERLAY, SWAP, CHANGE_TO, SCROLL_TO)
- `transition.duration`, `transition.easing`, `transition.type` (smart-animate / dissolve / slide)
- Resolved target frame names (not just IDs)
- Legacy `transitionNodeID` + `transitionDuration` + `transitionEasing` (fallback for older files)

Not exposed by Figma REST API (REST limitations, not ours): per-layer smart-animate property mapping (which layers morph into which). For that level of detail, screen-record the Present mode and analyze frames with Claude vision.

## Animated screens (prototype interactions)

Seed list — populate with additional nodes as new interactions are discovered during `/shuby-figma-check` runs.

| Screen | nodeId | Notes |
|--------|--------|-------|
| Dashboard hero transition (Azzurra ↔ Bianca) | `375:5429` ↔ `434:12577` | Scroll-driven header color change |
| Timeline future paywall CTA | `2002:8929` | CTA "Passa alla versione Premium" → upgrade flow |
| Onboarding | TBD | Multi-step flow; populate on first inspection |

## Animation integration workflow

End-to-end recipe for a future Claude session that needs to audit/implement a Figma animation. Follow the three phases in order.

### Phase 1 — Discover

Goal: find which Shuby screens actually have interactions worth implementing.

1. For each nodeId in the "Node Map" table above, run:
   ```bash
   bin/figma_prototype_info <nodeId> > /tmp/fig-<slug>.md
   ```
   Batch example:
   ```bash
   for id in 375:5429 434:12577 211:2608 463:5386 463:6063 455:5017; do
     echo "=== $id ==="
     bin/figma_prototype_info "$id"
   done
   ```
2. Interpret the output:
   - `destinationId: (no destination set)` → **skip**, the designer left the trigger unconfigured. Flag to the design team; do not implement a dead link.
   - `transition=SMART_ANIMATE` → worth implementing (this is where visual polish lives).
   - `transition=null` with `NAVIGATE` → standard page navigation, Turbo Drive handles it automatically.
   - `transition=MOVE_IN/MOVE_OUT/SLIDE_IN/SLIDE_OUT` → needs a small Stimulus controller or CSS class.
   - `transition=DISSOLVE` → CSS `opacity` transition on the target Turbo frame.
3. Record discoveries in the "Animated screens" table with the nodeId, the transition kind, and a short note.

### Phase 2 — Map to Shuby code

| Figma transition                         | Shuby implementation                                                    |
|------------------------------------------|-------------------------------------------------------------------------|
| `SMART_ANIMATE` (CHANGE_TO same variant) | View Transitions API on the Turbo frame — `view-transition-name: foo` + `::view-transition-*` CSS rules (Turbo 8 enables it via `<meta name="view-transition">`) |
| `SMART_ANIMATE` across navigation        | Turbo cross-document view transitions (`data-turbo-visit-control="reload"` off) + CSS pseudo-elements |
| `DISSOLVE`                               | Tailwind `transition-opacity duration-[Xms] ease-[easing]` on the element |
| `MOVE_IN` / `MOVE_OUT`                   | Stimulus controller with `transform: translate*` + `transition: transform Xms easing` |
| `SLIDE_IN` / `SLIDE_OUT`                 | Same as MOVE but along a single axis — check the `direction` field      |
| `PUSH`                                   | Default Turbo Drive page transition (nothing to implement)              |
| `NAVIGATE` + no transition               | Plain `link_to` / `button_to`                                           |
| `SCROLL_TO`                              | `element.scrollIntoView({ behavior: "smooth" })` or CSS `scroll-behavior: smooth` |
| `OVERLAY`                                | Existing `Overlay` component or Turbo frame with `data-turbo-permanent` |
| `CHANGE_TO` (variant swap)               | Stimulus class toggle — the variants are different frames in the same component |
| `DRAG` trigger                           | Stimulus controller with pointerdown/move/up handlers                   |
| `AFTER_TIMEOUT` trigger                  | `setTimeout` inside a Stimulus `connect()`                              |
| `ON_HOVER` trigger                       | CSS `:hover` (no JS needed)                                             |

Easing mapping: Figma `EASE_OUT` → CSS `ease-out`, `EASE_IN` → `ease-in`, `EASE_IN_OUT` → `ease-in-out`, `LINEAR` → `linear`, `SLOW` → `cubic-bezier(0.4,0,0.6,1)`. Keep the duration in ms exactly as extracted.

Example — mapping the Dashboard SMART_ANIMATE found on `434:11336 → 434:10538` (300ms, EASE_OUT):

```erb
<%# Enable cross-document view transitions (layouts/application.html.erb) %>
<meta name="view-transition" content="same-origin">
```

```erb
<%# Target element on both source and destination pages — same name = morphs %>
<div style="view-transition-name: dashboard-hero"
     class="transition-all duration-300 ease-out">
  <%= render "shared/dashboard_hero" %>
</div>
```

```css
/* app/assets/tailwind/application.css — tune duration/easing per transition */
::view-transition-old(dashboard-hero),
::view-transition-new(dashboard-hero) {
  animation-duration: 300ms;
  animation-timing-function: ease-out;
}
```

### Phase 3 — Verify

1. Start the dev server: `bin/dev`
2. Record the Shuby flow:
   ```bash
   # See .claude/skills/playwright-cli/references/video-recording.md for details
   playwright-cli goto http://localhost:3000/<path>
   playwright-cli video record --filename=/tmp/shuby-<flow>.webm
   # perform the interaction
   playwright-cli video stop
   ```
3. Open the Figma prototype in Present mode on the same starting frame and record the same interaction (Cmd-Shift-5 on macOS, or a Figma plugin like "Export to GIF/Video").
4. Compare side-by-side. Timing mismatches can be verified in DevTools → Performance (durations should match the ms extracted by `bin/figma_prototype_info`).
5. If SMART_ANIMATE mapping is ambiguous (which layers morph into which), take frames at t=0%, 50%, 100% from both videos and feed them to Claude vision for a frame-level diff.

### Known limitations

- **Per-layer smart-animate mapping is not exposed** by the REST API. The script only reports that SMART_ANIMATE is used with a given duration/easing; the *which layer → which layer* decision remains on the designer side and must be inferred visually.
- **Multiple reactions per node**: the script reads `interactions[]` (complete); the legacy `transitionNodeID` field reports only the first.
- **Prototype drafts**: `destinationId: null` means the designer has not yet wired the link. Do not guess a target — ask the design team.

### 02.03_Timeline_Futuro (free-user paywall over future bands) — `2002:8929`

| Sub-element | nodeId | Notes |
|-------------|--------|-------|
| Overlay backdrop (frosted glass) | `2002:9122` | `backdrop-blur: 7.5px`, `bg: rgba(255,255,255,0.76)`, no radius. Positioned inset 4px from page edges. |
| Prompt + CTA frame | `2002:9123` | Flex column, `gap: 16px`. |
| Prompt text | `2002:9126` | "Questi contenuti sono visibili..." — Montserrat Regular 14/1.5, Colori/Nero. |
| CTA button | `2002:9127` | "Passa alla versione Premium" — bg Fucsia-500 `#C500A2`, h=36, `px=20 py=9`, radius 999px, Montserrat Semi-Bold 16/1.5 white. |
| Mascot illustration instance | `2002:9137` | Cloud+star, 121×115, sourced from `Nome=Shuby Premium` component (`NouAcPBMzhwsaS0hMMmJlu` → `309:2269`). |
| Timeline carousel | `2002:8945` | 390×86; 41×60 pills at py-8 px-20, gap 8px; blue-400 bg for past, blue-800 for current, fucsia-500 for selected, transparent+blu-400 border for future. Gold star (19×18) centered on top edge of each future pill. |
| Header | `2002:8946` | 390×102 (44 iOS status bar + 8 gap + 42 nav + 8 pb); `bg: rgba(229,242,255,0.95)` + `backdrop-blur: 2px`; 350px-wide nav row with chevron-left + "Timeline" (Button L 20px) + 40px avatar. |
