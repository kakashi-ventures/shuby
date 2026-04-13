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
| Timeline (future) | `322:8041` | 02.03_Timeline_Futuro |
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
