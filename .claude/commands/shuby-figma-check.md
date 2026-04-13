Compare current implementation visually against the Figma design.

## Arguments
$ARGUMENTS — Optional: specific page/section (e.g., "dashboard", "timeline", "archive")

## Instructions

1. Ensure dev server is running (check with `curl -s localhost:3000 > /dev/null` or start with `bin/dev`)
2. Determine which pages to check:
   - If argument provided, check that page
   - Otherwise, check main screens: dashboard, timeline, archive, chat, measurements, onboarding

3. For each page:
   a. Use Playwright CLI: `playwright-cli goto [url]` then `playwright-cli screenshot --filename=/tmp/shuby-[page].png` (mobile viewport 390x844)
   b. Use Figma MCP: `get_design_context` with the nodeId from the Figma Node Map in CLAUDE.md
   c. The Figma file is large — always look up the correct nodeId from the map, don't guess
   d. Compare visually and report:
      - Layout and spacing differences
      - Color and typography mismatches
      - Missing or extra UI elements
      - Component rendering issues
      - Italian text accuracy

4. For each difference found, suggest specific CSS/HTML fixes

5. Output comparison report per page:

   ## Figma vs Implementation — [page]

   ### Matches
   - [list of things that match]

   ### Differences (with suggested fixes)
   - [list of visual differences with descriptions and fix suggestions]

   ### Missing Elements
   - [list of elements in Figma but not implemented]
