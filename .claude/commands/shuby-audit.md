Run a comprehensive gap analysis of the actual Shuby codebase against ALL reference documents.

IMPORTANT: Do NOT trust generated docs as state indicators.
Determine feature completion solely by reading the actual code.

## Instructions

1. Read ALL reference documents:
   - `docs/DECISIONS.md` (overrides — highest priority)
   - `docs/SHUBY PIANO DI ABBONAMENTO.pdf` (definitive free/premium matrix)
   - `docs/Shuby - Analisi Funzionale - v.1.0.pdf` (functional analysis)
   - `docs/Shuby 1.0 - Specifiche di Prodotto.md` (PRD)

2. For each major feature area in the PRD (sections 3.1-3.9), scan the actual codebase:
   - Check controllers, models, views, services, routes for the feature
   - Compare implemented behaviors against FA screen-by-screen descriptions
   - Verify DECISIONS.md overrides are applied in code
   - Flag discrepancies between documents (PRD vs FA vs PDF vs Figma)

3. Check premium gating against Subscription PDF:
   - Search for subscription/premium checks in models and controllers
   - Are free limits enforced? (1 child, 8 AI questions/mo, timeline past+today, etc.)
   - Is paywall UI implemented?

4. Use Figma MCP + Playwright CLI to spot-check key screens visually:
   - `playwright-cli screenshot --filename=/tmp/shuby-[screen].png` for local app
   - Figma MCP `get_design_context` with nodeId from Figma Node Map in CLAUDE.md

5. Check non-functional requirements (PRD section 5):
   - Rate limiting, GDPR export, accessibility, performance

6. Output structured report and save to `docs/AUDIT-REPORT.md`:

   ## Gap Analysis Report — [date]

   ### Feature Completeness (code vs PRD)
   | Area | Spec Requirement | Code Evidence (files) | Status | Gap |

   ### Behavior Accuracy (code vs Functional Analysis)
   | Screen | FA Description | Actual Code Behavior | Difference |

   ### Subscription Compliance (code vs Piano Abbonamento PDF)
   | Feature | PDF Free | PDF Premium | Code State | Gap |

   ### Decision Compliance (code vs DECISIONS.md)
   | Decision | Expected | Code Evidence | Status |

   ### Document Conflicts Found
   | Topic | PRD says | FA says | PDF says | DECISIONS says | Resolution |

   ### Figma Visual Gaps (spot-check)
   | Screen | Visual Differences |

7. Update `docs/REMAINING-WORK.md` with the actual gaps found
