# Shuby Design System

Complete design system implementation based on Figma design tokens and screenshot analysis.

## Overview

The Shuby design system is implemented as a DaisyUI/Tailwind CSS theme named `shuby`. It provides:
- Complete color palette (Primary, Verde, Success, Warning, Danger, Neutrals, Fucsia)
- Typography system with Baloo 2 (display) and Montserrat (body) fonts
- Component classes for buttons, tabs, cards, badges, etc.
- Spacing, border-radius, and shadow systems

**Theme Files:**
- `app/assets/tailwind/themes/shuby.css` - Color variables and theme mappings
- `app/assets/tailwind/components/shuby.css` - Component utility classes

**Demo Page:** `/design_system` (development only)

---

## Color Tokens

### Primary Blue Scale

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Blu 300 | `#E5F2FF` | `--color-shuby-blue-300` | Hover states, card borders, subtle backgrounds |
| Blu 400 | `#CAE4FF` | `--color-shuby-blue-400` | Section backgrounds, light blue accent |
| Blu 500 | `#9EC6F0` | `--color-shuby-blue-500` | Mid-tone blue, light accents |
| Blu 600 | `#6BA2DC` | `--color-shuby-blue-600` | Border hover states |
| Blu 700 | `#3B83CF` | `--color-shuby-blue-700` | Form borders, primary hover |
| Blu 800 | `#0159B5` | `--color-shuby-blue-800` | **Primary brand color** |

### Verde (Green/Teal) Scale - Figma: Colori/Verde

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Verde 200 | `#D1F8F9` | `--color-shuby-verde-200` | Light accent backgrounds |
| Verde 300 | `#99E0E2` | `--color-shuby-verde-300` | Medium accents |
| Verde 400 | `#7DCBCD` | `--color-shuby-verde-400` | Character illustrations |
| Verde 500 | `#38A3A5` | `--color-shuby-verde-500` | Primary accent |
| Verde Scuro 400 | `#37A3C1` | `--color-shuby-verde-scuro-400` | Dark accent |
| Verde Scuro 500 | `#007FA3` | `--color-shuby-verde-scuro-500` | Darker accent |

### Yellow (Giallo) - Figma: Colori/Giallo

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Giallo 400 | `#FFF7D4` | `--color-shuby-giallo-400` | Light yellow card backgrounds (Consigli) |
| Giallo 500 | `#FFE882` | `--color-shuby-giallo-500` | Highlights, attention elements, tags |
| Giallo 600 | `#FDD318` | `--color-shuby-giallo-600` | Strong yellow accent |

### Other Accent Colors

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Green 500 | `#2ECC71` | `--color-shuby-green-500` | Success, positive metrics |
| Orange 500 | `#F39C12` | `--color-shuby-orange-500` | Warnings, "Aggiorna" badge |
| Red 500 | `#E74C3C` | `--color-shuby-red-500` | Danger, "Elimina Account" |
| Fucsia 300 | `#F456D8` | `--color-shuby-fucsia-300` | Light fucsia accent |
| Fucsia 400 | `#DC21BB` | `--color-shuby-fucsia-400` | Mid-tone fucsia |
| Fucsia 500 | `#C500A2` | `--color-shuby-fucsia-500` | Vibrant accent |
| Fucsia 600 | `#AB008D` | `--color-shuby-fucsia-600` | Dark fucsia |
| Fucsia 700 | `#91018A` | `--color-shuby-fucsia-700` | Form error text |

### Magenta/Pink Scale (Selection Accent)

Used for date pickers, week selectors, and other selection states.

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| Magenta 300 | `#FF92D9` | `--color-shuby-magenta-300` | Light magenta accent, light selection background |
| Magenta 400 | `#FF56C4` | `--color-shuby-magenta-400` | Selection borders |
| Magenta 500 | `#FD1EAF` | `--color-shuby-magenta-500` | **Primary selection color** |
| Magenta 600 | `#E11097` | `--color-shuby-magenta-600` | Hover on selection |
| Magenta 700 | `#BF007C` | `--color-shuby-magenta-700` | Dark selection accent |
| Purple 300 | `#A5B4FC` | `--color-shuby-purple-300` | Outline borders, today marker |

### Selection Theme Variables

| Variable | Maps To | Description |
|----------|---------|-------------|
| `--bg-selection` | Magenta 500 | Selected pill/week backgrounds |
| `--bg-selection-hover` | Magenta 600 | Hover on selected items |
| `--text-on-selection` | White | Text on selected items |
| `--border-selection` | Magenta 400 | Selection borders |
| `--text-selection` | Magenta 500 | Selection text color |
| `--bg-selection-light` | Magenta 50 | Light selection backgrounds |
| `--border-selection-outline` | Purple 300 | Today marker border |

### Neutral Colors

| Token | HEX | CSS Variable | Usage |
|-------|-----|--------------|-------|
| White | `#FFFFFF` | `--color-shuby-white` | Card backgrounds |
| Grigio 400 | `#F6F8FA` | `--color-shuby-gray-400` | Light backgrounds, hover states |
| Grigio 500 | `#E2E5E8` | `--color-shuby-gray-500` | Borders, subtle backgrounds |
| Grigio 600 | `#B5B7BA` | `--color-shuby-gray-600` | Muted text, chart labels |
| Grigio 700 | `#898D91` | `--color-shuby-gray-700` | Secondary text |
| Grigio 800 | `#616467` | `--color-shuby-gray-800` | Body text, headings |
| Black | `#000000` | `--color-shuby-black` | Body text |

---

## Typography System

### Font Families (from Figma)

The Shuby design system uses two font families from Figma:

**Font Primario: Baloo 2** - Display/headline font (D1, D2 styles)
```css
--font-display: "Baloo 2", ui-sans-serif, system-ui, sans-serif;
```

**Font Secondario: Montserrat** - Body text and UI elements
```css
--font-sans: "Montserrat", ui-sans-serif, system-ui, sans-serif;
```

### Typography Classes

| Class | Font | Size | Weight | Line-Height | Usage |
|-------|------|------|--------|-------------|-------|
| `.shuby-d1` | Baloo 2 | 48px | Bold (700) | 1 | Hero text |
| `.shuby-h1` | Baloo 2 | 38px | Bold (700) | 1 | Page titles (Figma: Headings/H1) |
| `.shuby-h2` | Baloo 2 | 28px | Bold (700) | 1 | Section titles (Figma: Headings/H2) |
| `.shuby-d2` | Baloo 2 | 20px | Bold (700) | 24px | Card titles (Figma: Display/D2) |
| `.shuby-h3` | Montserrat | 20px | Semibold (600) | 150% | Subsection titles (Figma: Headings/H3) |
| `.shuby-p1` | Montserrat | 14px | Regular (400) | 150% | Main body text (Figma: Body/P1/Light) |
| `.shuby-p1-dark` | Montserrat | 14px | Semibold (600) | 150% | Emphasized body text (Figma: Body/P1/Dark) |
| `.shuby-p2` | Montserrat | 12px | Regular (400) | 150% | Secondary text (Figma: Body/P2/Light) |
| `.shuby-p2-dark` | Montserrat | 12px | Semibold (600) | 150% | Emphasized secondary text (Figma: Body/P2/Dark) |
| `.shuby-caption` | Montserrat | 10px | Medium (500) | 150% | Labels (Figma: Caption/Span/Light) |
| `.shuby-caption-dark` | Montserrat | 10px | Semibold (600) | 150% | Emphasized labels, uppercase (Figma: Caption/Span/Dark) |
| `.shuby-overline` | Montserrat | 10px | Regular (400) | 150% | Tags, uppercase (Figma: Overline/OL/Light) |
| `.shuby-overline-dark` | Montserrat | 10px | Semibold (600) | 150% | Form labels, uppercase (Figma: Overline/OL/Dark) |
| `.shuby-btn-text-s` | Montserrat | 16px | Semibold (600) | 150% | Button text small (Figma: Button/Button S) |
| `.shuby-btn-text-l` | Montserrat | 20px | Semibold (600) | 150% | Button text large (Figma: Button/Button L) |

### Usage Example

```erb
<h1 class="shuby-d1">Il tempo speciale con il tuo bambino</h1>
<span class="shuby-overline">0–36 MESI</span>
<p class="shuby-p1">Un dono reciproco di attenzione esclusiva...</p>
```

---

## Spacing System

Based on an 8px unit system:

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight gaps |
| `--space-2` | 8px | Small gaps |
| `--space-3` | 12px | Element gaps |
| `--space-4` | 16px | Component padding |
| `--space-5` | 20px | Section gaps |
| `--space-6` | 24px | Card padding |
| `--space-8` | 32px | Section margins |
| `--space-10` | 40px | Large spacing |

---

## Border Radius

| Token | Value | Figma Token | Usage |
|-------|-------|-------------|-------|
| `--radius-xs` | 4px | Radius/Piccolo | Small elements |
| `--radius-sm` | 8px | - | Buttons |
| `--radius-md` | 12px | Radius/Grande | Cards, containers |
| `--radius-lg` | 16px | - | Large cards |
| `--radius-xl` | 24px | - | Pill buttons, inputs |
| `--radius-full` | 999px | Radius/Tondo | Circles, avatars |
| `--radius-assente` | 0 | Radius/Assente | No radius (square corners) |

**Figma Aliases:**
- `--radius-piccolo` = 4px (alias for `--radius-xs`)
- `--radius-grande` = 12px (alias for `--radius-md`)
- `--radius-tondo` = 999px (alias for `--radius-full`)

---

## Shadows

| Token | Value | Figma Token | Usage |
|-------|-------|-------------|-------|
| `--shadow-blu` | `0 0 10px 0 rgba(158, 198, 240, 0.3)` | Shadow Blu | Modal overlays, cards |
| `--shadow-dark-blue` | `0 0 8px 0 rgba(59, 131, 207, 0.8)` | Shadow Dark Blue | Focus states |

### Shadow Utility Classes

```erb
<%# Blue shadow (modal overlays) %>
<div class="shuby-shadow-blu">
  Card with blue glow shadow
</div>

<%# Shadow on hover %>
<div class="shuby-shadow-blu-hover">
  Card that gets shadow on hover
</div>
```

---

## Component Classes

### Buttons

**Important:** All interactive states use `:active` (not `:hover`) — this is a mobile-first app (Hotwire Native). Disabled/blocked buttons use `pointer-events: none`.

#### Filled Buttons (Figma: Type=Filled)

```erb
<%# Blu (primary) %>
<button class="shuby-btn shuby-btn-lg shuby-btn-primary">Comincia</button>

<%# Fucsia %>
<button class="shuby-btn shuby-btn-lg shuby-btn-fucsia">Fucsia</button>

<%# Bianco (white bg, fucsia text — for dark backgrounds) %>
<button class="shuby-btn shuby-btn-lg shuby-btn-white">Bianco</button>

<%# Grigio %>
<button class="shuby-btn shuby-btn-lg shuby-btn-gray">Grigio</button>

<%# Verde (teal — typically used at Piccolo size) %>
<button class="shuby-btn shuby-btn-sm shuby-btn-verde">Verde</button>

<%# Secondary / Danger / Teal (app-specific) %>
<button class="shuby-btn shuby-btn-lg shuby-btn-secondary">No</button>
<button class="shuby-btn shuby-btn-lg shuby-btn-danger">Elimina</button>
<button class="shuby-btn shuby-btn-lg shuby-btn-teal">Teal</button>

<%# Disabled/Blocked %>
<button class="shuby-btn shuby-btn-lg shuby-btn-primary" disabled>Bloccato</button>
```

#### Outline Buttons (Figma: Type=Outline)

```erb
<%# Blu outline (primary) %>
<button class="shuby-btn shuby-btn-lg shuby-btn-outline">Blu Outline</button>
<button class="shuby-btn shuby-btn-sm shuby-btn-outline-blu">Blu Piccolo</button>

<%# Fucsia outline %>
<button class="shuby-btn shuby-btn-lg shuby-btn-outline-fucsia">Fucsia Outline</button>

<%# Nero outline %>
<button class="shuby-btn shuby-btn-sm shuby-btn-outline-dark">Elimina bambino/a</button>

<%# Bianco outline (for dark backgrounds) %>
<button class="shuby-btn shuby-btn-lg shuby-btn-outline-white">Outline Bianco</button>
```

#### Buttons with Icons (Figma: Icona=Sx/Dx)

```erb
<%# Left icon %>
<button class="shuby-btn shuby-btn-lg shuby-btn-fucsia shuby-btn-icon shuby-btn-icon-left">
  <%= render_svg "shuby/icons/icon-add", size: :lg, decorative: true %>
  Aggiungi
</button>
```

#### Link Styles (Figma: Type=Testo)

```erb
<%# Underlined text link — blue (Icona=Off) %>
<a href="#" class="shuby-link-underline">Bottone</a>

<%# Underlined text link — fucsia %>
<a href="#" class="shuby-link-underline shuby-link-underline-fucsia">Bottone</a>

<%# Arrow text link — blue (Icona=Dx) %>
<a href="#" class="shuby-btn-text">
  Tutti gli Articoli
  <svg class="shuby-btn-text-icon"><!-- arrow_forward icon --></svg>
</a>

<%# Arrow text link — white (for dark backgrounds) %>
<a href="#" class="shuby-btn-text shuby-btn-text-white">
  Bottone
  <svg class="shuby-btn-text-icon"><!-- arrow_forward icon --></svg>
</a>
```

#### Round Buttons (Figma: Round Button)

```erb
<%# Azzurro (light blue) %>
<button class="shuby-icon-btn-azzurro"><%= render_svg "shuby/icons/icon-calendar", size: :md %></button>

<%# Blu (primary) %>
<button class="shuby-icon-btn"><%= render_svg "shuby/icons/icon-calendar", size: :md %></button>

<%# Fucsia %>
<button class="shuby-icon-btn-pink"><%= render_svg "shuby/icons/icon-calendar", size: :md %></button>

<%# Fill (outline with blue border) %>
<button class="shuby-icon-btn-fill"><%= render_svg "shuby/icons/icon-chevron-right", size: :md %></button>

<%# Bianca (white with light blue border) %>
<button class="shuby-icon-btn-bianca"><%= render_svg "shuby/icons/icon-chevron-left", size: :sm %></button>

<%# Selected state %>
<button class="shuby-icon-btn-fill shuby-icon-btn-selected"><%= render_svg "shuby/icons/icon-bookmark-filled", size: :md %></button>

<%# Disabled state %>
<button class="shuby-icon-btn-azzurro shuby-icon-btn-disabled" disabled><%= render_svg "shuby/icons/icon-calendar", size: :md %></button>
```

**Button Sizes (Figma aligned):**
- `.shuby-btn-lg` - Grande (12px 24px padding, 20px font) - Figma: Button/Button L
- `.shuby-btn-md` - Medium (10px 20px padding, 14px font) - app-specific
- `.shuby-btn-sm` - Piccolo (6px 16px padding, 16px font) - Figma: Button/Button S

**Round Button Colors (Figma aligned):**
- `.shuby-icon-btn` - Blu (blue-800 bg, white icon)
- `.shuby-icon-btn-azzurro` - Azzurro (blue-400 bg, blue-800 icon)
- `.shuby-icon-btn-pink` - Fucsia (fucsia-500 bg, white icon)
- `.shuby-icon-btn-fill` - Fill (transparent, blue-800 border)
- `.shuby-icon-btn-bianca` - Bianca (white bg, blue-300 border)

**Round Button States:**
- `.shuby-icon-btn-selected` - Selected (blue-300 bg, blue-800 border)
- `.shuby-icon-btn-disabled` - Disabled (gray-400 bg, pointer-events: none)

### Tabs

```erb
<div class="shuby-tabs">
  <button class="shuby-tab active">Famiglia</button>
  <button class="shuby-tab">Impostazioni</button>
  <button class="shuby-tab">Piano</button>
</div>
```

### Cards

```erb
<%# Standard card %>
<div class="shuby-card">
  <span class="shuby-overline">0–36 MESI</span>
  <h3 class="shuby-d2">Card Title</h3>
  <p class="shuby-p1">Card content...</p>
</div>

<%# Metric card (Percentile - Aggiornato) %>
<div class="shuby-card-metric">
  <div class="shuby-card-metric-info">
    <p class="shuby-card-metric-title">Peso</p>
    <p class="shuby-card-metric-date">25.08.2025 - h. 10:34</p>
  </div>
  <div class="shuby-card-metric-values">
    <div>
      <span class="shuby-card-metric-value">3900</span>
      <span class="shuby-card-metric-unit">grammi</span>
    </div>
    <div>
      <span class="shuby-card-metric-percentile">50°</span>
      <span class="shuby-card-metric-percentile-unit">%</span>
    </div>
  </div>
</div>
```

### Article Cards (Figma: Articolo)

Horizontal cards with image on left and content on right, used in the Archivio screen.

```erb
<div class="shuby-card-article">
  <div class="shuby-card-article-image">
    <img src="illustration.jpg" alt="Article illustration">
  </div>
  <div class="shuby-card-article-content">
    <div class="shuby-card-article-tags">
      <span class="shuby-tag shuby-tag-info">
        <span class="shuby-tag-icon"><!-- icon --></span>
        Abilità motorie
      </span>
      <span class="shuby-tag shuby-tag-default">0-2 mesi</span>
    </div>
    <p class="shuby-card-article-title">Riflessi e scoperte iniziali</p>
    <p class="shuby-card-article-description">
      Come stimolarlo e campanelli di allarme.
    </p>
  </div>
</div>
```

**Article Card Classes:**
| Class | Description |
|-------|-------------|
| `.shuby-card-article` | Container (flex, 117px height) |
| `.shuby-card-article-image` | Image container (94px width, left rounded) |
| `.shuby-card-article-content` | Content area with Blue 300 border |
| `.shuby-card-article-tags` | Tags row container |
| `.shuby-card-article-title` | Title (14px semibold, Blue 800) |
| `.shuby-card-article-description` | Description (10px, 2-line clamp) |

### Consigli Cards (Figma: Scheda Consigli)

Yellow cards for tips, books, and games recommendations.

```erb
<%# Book recommendation card %>
<div class="shuby-card-consigli">
  <div class="shuby-card-consigli-content">
    <div class="shuby-card-consigli-tags">
      <span class="shuby-tag shuby-tag-giallo">
        <span class="shuby-tag-icon"><!-- book icon --></span>
        Lettura
      </span>
      <span class="shuby-tag shuby-tag-light">0-12 Mesi</span>
    </div>
    <div class="shuby-card-consigli-body">
      <p class="shuby-card-consigli-author">Teresa Porcella</p>
      <p class="shuby-card-consigli-title">Quelli là</p>
      <p class="shuby-card-consigli-publisher">Bacchilega Editore</p>
    </div>
  </div>
  <div class="shuby-card-consigli-thumbnail">
    <img src="book-cover.jpg" alt="Book cover">
  </div>
</div>

<%# Game/Activity card (no thumbnail) %>
<div class="shuby-card-consigli">
  <div class="shuby-card-consigli-content">
    <div class="shuby-card-consigli-tags">
      <span class="shuby-tag shuby-tag-giallo">
        <span class="shuby-tag-icon"><!-- game icon --></span>
        Giochi
      </span>
      <span class="shuby-tag shuby-tag-light">0-2 Mesi</span>
    </div>
    <div class="shuby-card-consigli-body">
      <p class="shuby-card-consigli-title">Guarda lo specchio… chi c'è qui?</p>
      <div class="shuby-card-consigli-time">
        <svg class="shuby-card-consigli-time-icon"><!-- alarm icon --></svg>
        <span class="shuby-card-consigli-time-text">3 min</span>
      </div>
    </div>
  </div>
</div>
```

**Consigli Card Classes:**
| Class | Description |
|-------|-------------|
| `.shuby-card-consigli` | Container (Giallo 400 background) |
| `.shuby-card-consigli-content` | Content area (flex column) |
| `.shuby-card-consigli-tags` | Tags row |
| `.shuby-card-consigli-body` | Text content area |
| `.shuby-card-consigli-author` | Author name (12px) |
| `.shuby-card-consigli-title` | Title (Baloo 2, 20px bold) |
| `.shuby-card-consigli-publisher` | Publisher name (10px) |
| `.shuby-card-consigli-thumbnail` | Book cover image (78x99px) |
| `.shuby-card-consigli-time` | Time indicator row |

### Scheda Attività (Activity Cards)

Simple activity list items with title, duration, and arrow.

```erb
<div class="shuby-scheda-attivita">
  <div class="shuby-scheda-attivita-content">
    <p class="shuby-scheda-attivita-title">Tummy time musicale</p>
    <div class="shuby-scheda-attivita-time">
      <svg class="shuby-scheda-attivita-time-icon"><!-- alarm icon --></svg>
      <span class="shuby-scheda-attivita-time-text">5 min</span>
    </div>
  </div>
  <svg class="shuby-scheda-attivita-arrow"><!-- arrow_forward icon --></svg>
</div>
```

**Scheda Attività Classes:**
| Class | Description |
|-------|-------------|
| `.shuby-scheda-attivita` | Container (80px height, Blue 300 border) |
| `.shuby-scheda-attivita-content` | Text content area |
| `.shuby-scheda-attivita-title` | Title (Baloo 2, 20px bold) |
| `.shuby-scheda-attivita-time` | Duration indicator |
| `.shuby-scheda-attivita-arrow` | Arrow icon (24px) |

### Article Body / Prose Styling

Rich text styling for article detail pages with proper paragraph spacing and bold highlights.

```erb
<div class="shuby-article-body">
  <p>Il primo anno di vita del bambino è caratterizzato da importanti <strong>tappe di sviluppo motorio</strong>. Ogni mese porta con sé nuove abilità e possibilità di interazione.</p>

  <h2>Sviluppo tipico</h2>
  <p>Nei primi mesi, il neonato si muove principalmente grazie ai <strong>riflessi primitivi</strong>, come il riflesso di Moro.</p>

  <h3>Come stimolarlo</h3>
  <p>Dedica 1-2 minuti di <strong>tummy time</strong> al giorno, aumentando gradualmente.</p>
</div>
```

| Class | Description |
|-------|-------------|
| `.shuby-article-body` | Container with proper font, line-height (1.7) |
| `.shuby-article-body p` | Paragraphs with bottom margin |
| `.shuby-article-body strong` | Bold text (600 weight) |
| `.shuby-article-body h2` | Section headers (16px, 700 weight) |
| `.shuby-article-body h3` | Sub-section headers (14px, 600 weight) |

### Colored Bullet Lists

Styled unordered lists with colored bullet points for article content.

```erb
<%# Blue bullet list (default for articles) %>
<ul class="shuby-list-blue">
  <li>Le illustrazioni semplici e ad alto contrasto catturano lo sguardo del neonato</li>
  <li>Il testo breve e musicale invita all'ascolto e alla partecipazione</li>
  <li>La ripetizione delle parole sostiene l'attenzione</li>
</ul>

<%# Red/warning bullet list (Campanelli d'allarme) %>
<ul class="shuby-list-red">
  <li>Non reagisce ai suoni forti (assenza del riflesso di Moro)</li>
  <li>Non cerca il seno o non reagisce al tocco sulla guancia</li>
  <li>Non solleva minimamente la testa quando è sdraiato a pancia in giù</li>
</ul>

<%# Verde/teal bullet list %>
<ul class="shuby-list-verde">
  <li>Oggetti consigliati: sonagli morbidi, tappetino per tummy time</li>
  <li>Stimola: controllo visivo, motricità grossolana</li>
</ul>
```

| Class | Description |
|-------|-------------|
| `.shuby-list-blue` | Blue bullet points (Primary Blue 800) |
| `.shuby-list-red` / `.shuby-list-warning` | Red bullet points (Red 500) - for warnings |
| `.shuby-list-verde` | Teal bullet points (Verde 500) |

### Yellow Section Container (TAPPE)

Yellow background section for linked development stages.

```erb
<div class="shuby-section-giallo">
  <div class="shuby-section-giallo-header">
    <span class="shuby-section-giallo-title">TAPPE DI SVILUPPO COLLEGATE</span>
  </div>
  <div class="shuby-section-giallo-content">
    <a href="#" class="shuby-pill-verde">
      <span class="shuby-pill-verde-icon">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2z"/>
        </svg>
      </span>
      Comunicazione e linguaggio
      <svg class="shuby-pill-verde-arrow" viewBox="0 0 24 24" fill="currentColor">
        <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
      </svg>
    </a>
  </div>
</div>
```

| Class | Description |
|-------|-------------|
| `.shuby-section-giallo` | Yellow container (Giallo 400 background) |
| `.shuby-section-giallo-header` | Header with title |
| `.shuby-section-giallo-title` | Uppercase title (11px, 700 weight) |
| `.shuby-section-giallo-content` | Content area with gap spacing |

### Green Linked Pill (Verde)

Clickable green pill for linked content items.

```erb
<a href="#" class="shuby-pill-verde">
  <span class="shuby-pill-verde-icon">
    <svg viewBox="0 0 24 24" fill="currentColor">
      <path d="M21 6h-2v9H6v2c0 .55.45 1 1 1h11l4 4V7c0-.55-.45-1-1-1z"/>
    </svg>
  </span>
  Comunicazione e linguaggio
  <svg class="shuby-pill-verde-arrow" viewBox="0 0 24 24" fill="currentColor">
    <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
  </svg>
</a>
```

| Class | Description |
|-------|-------------|
| `.shuby-pill-verde` | Green pill container (Verde 200 background) |
| `.shuby-pill-verde:hover` | Hover state (Verde 300) |
| `.shuby-pill-verde-icon` | Left icon (20px) |
| `.shuby-pill-verde-arrow` | Right arrow icon (16px) |

### Book Detail Layout

Layout for book/reading detail pages with author information.

```erb
<div class="shuby-book-detail">
  <div class="shuby-book-cover">
    <img src="/book-cover.jpg" alt="Book cover">
  </div>

  <h1 class="shuby-book-title">Quelli là</h1>
  <p class="shuby-book-author">Elisa Mazzoli, Marianna Balducci</p>
  <p class="shuby-book-publisher">Bacchilega Editore, 2019</p>

  <p class="shuby-book-description">
    Quelli là è un libro cartonato, colorato e pieno di ritmo, perfetto per le prime letture condivise.
  </p>

  <div class="shuby-book-meta">
    <div class="shuby-book-meta-row">
      <span class="shuby-book-meta-label">Autore:</span>
      <span class="shuby-book-meta-value">Teresa Porcella</span>
    </div>
    <div class="shuby-book-meta-row">
      <span class="shuby-book-meta-label">Illustrazioni:</span>
      <span class="shuby-book-meta-value">Bruno Zocca</span>
    </div>
    <div class="shuby-book-meta-row">
      <span class="shuby-book-meta-label">Editore:</span>
      <span class="shuby-book-meta-value">Bacchilega Junior</span>
    </div>
  </div>
</div>
```

| Class | Description |
|-------|-------------|
| `.shuby-book-detail` | Container with padding |
| `.shuby-book-cover` | Cover image container (4:3 aspect ratio) |
| `.shuby-book-title` | Title (22px, Blue 800) |
| `.shuby-book-author` | Author name (14px) |
| `.shuby-book-publisher` | Publisher info (12px, secondary color) |
| `.shuby-book-description` | Description text (14px, 1.7 line-height) |
| `.shuby-book-meta` | Metadata section with border-top |
| `.shuby-book-meta-row` | Row with label and value |
| `.shuby-book-meta-label` | Label (600 weight) |
| `.shuby-book-meta-value` | Value text |

### Article Hero Container

Hero section at top of article with gradient background and optional illustration.

```erb
<div class="shuby-article-hero">
  <div class="shuby-article-hero-illustration">
    <img src="/cloud-mascot.png" alt="">
  </div>
  <div class="shuby-article-hero-content">
    <div class="shuby-article-hero-tags">
      <span class="shuby-tag shuby-tag-light shuby-tag-sm">
        <span class="shuby-tag-icon">🏃</span>
        Attività motorie
      </span>
      <span class="shuby-tag shuby-tag-light shuby-tag-sm">0-2 mesi</span>
      <span class="shuby-tag shuby-tag-light shuby-tag-sm">
        <span class="shuby-tag-icon">⏱️</span>
        4 min
      </span>
    </div>
    <div class="shuby-article-hero-icon">
      <svg viewBox="0 0 48 48" fill="currentColor"><!-- icon --></svg>
    </div>
    <h1 class="shuby-article-hero-title">Riflessi e scoperte iniziali</h1>
  </div>
</div>

<%# Full-width illustration variant %>
<div class="shuby-article-hero shuby-article-hero-full">
  <div class="shuby-article-hero-illustration">
    <img src="/cloud-illustration.png" alt="">
  </div>
  <div class="shuby-article-hero-content">
    <!-- content -->
  </div>
</div>
```

| Class | Description |
|-------|-------------|
| `.shuby-article-hero` | Container with gradient (Blue 100 → White) |
| `.shuby-article-hero-full` | Variant with centered top illustration |
| `.shuby-article-hero-content` | Content wrapper (centered) |
| `.shuby-article-hero-tags` | Tags row (centered) |
| `.shuby-article-hero-icon` | Icon container (48px) |
| `.shuby-article-hero-title` | Title (22px, Blue 800) |
| `.shuby-article-hero-illustration` | Illustration container (absolute positioned) |

### Metric Range Cards

Cards showing measurement ranges (e.g., PESO: 2,3 - 4,4 kg).

```erb
<%# Grid of metric range cards %>
<div class="shuby-metric-range-grid">
  <div class="shuby-metric-range-card">
    <span class="shuby-metric-range-label">PESO</span>
    <div class="shuby-metric-range-values">
      <span class="shuby-metric-range-value">2,3</span>
      <span class="shuby-metric-range-value">4,4</span>
    </div>
    <span class="shuby-metric-range-unit">chilogrammi</span>
  </div>

  <div class="shuby-metric-range-card">
    <span class="shuby-metric-range-label">ALTEZZA</span>
    <div class="shuby-metric-range-values">
      <span class="shuby-metric-range-value">46</span>
      <span class="shuby-metric-range-value">55</span>
    </div>
    <span class="shuby-metric-range-unit">centimetri</span>
  </div>

  <div class="shuby-metric-range-card">
    <span class="shuby-metric-range-label">CIRC. CRANICA</span>
    <div class="shuby-metric-range-values">
      <span class="shuby-metric-range-value">33</span>
      <span class="shuby-metric-range-value">36</span>
    </div>
    <span class="shuby-metric-range-unit">centimetri</span>
  </div>
</div>
```

### Info Boxes

```erb
<%# Info box (RICORDA style) %>
<div class="shuby-info-box">
  <div class="shuby-info-box-header">
    <div class="shuby-info-box-icon">ℹ️</div>
    <span class="shuby-info-box-title">RICORDA:</span>
  </div>
  <p class="shuby-info-box-content">Important message here...</p>
</div>

<%# Warning box %>
<div class="shuby-warning-box">
  <p class="shuby-p1">Warning message...</p>
</div>

<%# Success box %>
<div class="shuby-success-box">
  <p class="shuby-p1">Success message...</p>
</div>
```

### Badges

```erb
<span class="shuby-badge shuby-badge-primary">Primary</span>
<span class="shuby-badge shuby-badge-outline">Outline</span>
<span class="shuby-badge shuby-badge-success">Success</span>
<span class="shuby-badge shuby-badge-warning">Aggiorna</span>
<span class="shuby-badge shuby-badge-info">Info</span>
```

### Tags (with Icon)

Pill-shaped tags with optional icon (footprint icon for child tracking features).

```erb
<%# Default gray tag %>
<span class="shuby-tag shuby-tag-default">
  <span class="shuby-tag-icon">
    <svg viewBox="0 0 24 24" fill="currentColor"><!-- footprint icon --></svg>
  </span>
  Tag
</span>

<%# Primary Blue tag %>
<span class="shuby-tag shuby-tag-primary">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Magenta tag %>
<span class="shuby-tag shuby-tag-magenta">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Info (Light Blue) tag %>
<span class="shuby-tag shuby-tag-info">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Yellow/Amber tag (warning) %>
<span class="shuby-tag shuby-tag-yellow">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>

<%# Giallo tag (Figma yellow - for categories like Lettura, Giochi) %>
<span class="shuby-tag shuby-tag-giallo">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Lettura
</span>

<%# Outline tag %>
<span class="shuby-tag shuby-tag-outline">
  <span class="shuby-tag-icon"><!-- icon --></span>
  Tag
</span>
```

**Tag Variants:**

| Class | Background | Text Color | Usage |
|-------|------------|------------|-------|
| `.shuby-tag-default` | Gray 100 | Gray 700 | Default state |
| `.shuby-tag-light` | White + border | Gray 700 | Light variant |
| `.shuby-tag-primary` | Blue 800 | White | Primary/active |
| `.shuby-tag-magenta` | Magenta 500 | White | Selection/highlight |
| `.shuby-tag-info` | Blue 100 | Blue 800 | Informational |
| `.shuby-tag-yellow` | Orange 500 | Gray 700 | Warning/attention |
| `.shuby-tag-giallo` | Giallo 500 | Blue 800 | Category tags (Lettura, Giochi) |
| `.shuby-tag-outline` | Transparent | Blue 800 | Outlined variant |

**Size Variants:**
- Default: 6px 12px padding, 13px font
- `.shuby-tag-sm` - Small: 4px 10px padding, 11px font

**Interactive Tags:**
```erb
<%# Clickable tag with hover effect %>
<span class="shuby-tag shuby-tag-default shuby-tag-clickable">Tag</span>

<%# Selected state (turns magenta) %>
<span class="shuby-tag shuby-tag-default selected">Tag</span>
```

### Form Elements

```erb
<%# Input %>
<input type="text" class="shuby-input" placeholder="Fai una domanda">

<%# Toggle switch %>
<div class="shuby-toggle active">
  <div class="shuby-toggle-knob"></div>
</div>
```

### Underline Form Inputs (Figma: Form component)

Minimalist form inputs with bottom border only, used in edit/profile screens.

```erb
<%# Basic underline input %>
<div class="shuby-form-group">
  <label class="shuby-form-label">NOME *</label>
  <div class="shuby-form-input-wrapper">
    <input type="text" class="shuby-form-input-underline" value="Alessandro">
  </div>
</div>

<%# With icon (calendar, dropdown arrow) %>
<div class="shuby-form-group">
  <label class="shuby-form-label">DATA DI NASCITA</label>
  <div class="shuby-form-input-wrapper">
    <input type="text" class="shuby-form-input-underline" value="17 . 09 . 2023">
    <svg class="shuby-form-icon"><!-- calendar icon --></svg>
  </div>
</div>

<%# With error message %>
<div class="shuby-form-group">
  <label class="shuby-form-label">EMAIL</label>
  <div class="shuby-form-input-wrapper">
    <input type="text" class="shuby-form-input-underline" value="invalid">
  </div>
  <span class="shuby-form-error">Email non valida</span>
</div>
```

**Form Classes:**
| Class | Description |
|-------|-------------|
| `.shuby-form-group` | Container with flex column, 8px gap |
| `.shuby-form-label` | Uppercase label, 10px semibold (Figma: Overline/OL/Dark) |
| `.shuby-form-input-wrapper` | Bottom border container (Blue 700) |
| `.shuby-form-input-underline` | Transparent background input, 14px |
| `.shuby-form-icon` | 16px icon in Blue 800 |
| `.shuby-form-error` | Error text in Fucsia 700 |

### Segmented Switch (Figma: Switch component)

Two-option toggle buttons like "Maschio/Femmina" gender selector.

```erb
<%# Gender switch example %>
<div class="shuby-switch">
  <button class="shuby-switch-option active">Maschio</button>
  <button class="shuby-switch-option">Femmina</button>
</div>

<%# With form label %>
<div class="shuby-form-group">
  <label class="shuby-form-label">SESSO ALLA NASCITA</label>
  <div class="shuby-switch">
    <button class="shuby-switch-option active">Maschio</button>
    <button class="shuby-switch-option">Femmina</button>
  </div>
</div>
```

**Segmented Switch States:**
| State | Background | Text Color |
|-------|------------|------------|
| Active | Blue 800 (`#0159B5`) | White |
| Inactive | Blue 400 (`#CAE4FF`) | Gray 800 |
| Hover (inactive) | Blue 500 | Gray 800 |

**Structure:**
- `.shuby-switch` - Container with inline-flex, rounded pill ends
- `.shuby-switch-option` - Individual option button (min-width: 150px, height: 36px)
- `.active` - Active state modifier

### List Items

```erb
<div class="shuby-list-item">
  <div class="shuby-list-item-content">
    <img src="avatar.jpg" class="shuby-avatar">
    <div class="shuby-list-item-text">
      <span class="shuby-list-item-title">Name</span>
      <span class="shuby-list-item-subtitle">Subtitle</span>
    </div>
  </div>
  <button class="shuby-icon-btn shuby-icon-btn-outline">✏️</button>
</div>
```

### Activity Items with Thumbnail

Activity list items with circular thumbnails (e.g., "Attività" section).

```erb
<div class="shuby-activity-item-with-thumb">
  <div class="shuby-activity-thumbnail">
    <img src="activity.jpg" alt="Tummy time">
  </div>
  <div class="shuby-activity-item-content">
    <span class="shuby-activity-title">Tummy time musicale</span>
    <span class="shuby-activity-duration">
      <span class="shuby-activity-duration-icon">
        <svg><!-- clock icon --></svg>
      </span>
      5 min
    </span>
  </div>
</div>
```

**Thumbnail Sizes:**
- Default: 48px
- `.shuby-activity-thumbnail-sm` - 40px
- `.shuby-activity-thumbnail-lg` - 56px

### Consiglio (Tip) Items

List items for tips/advice with avatar, tags, title, and author.

```erb
<div class="shuby-consiglio-item">
  <div class="shuby-consiglio-thumbnail">
    <img src="author.jpg" alt="Author">
  </div>
  <div class="shuby-consiglio-content">
    <div class="shuby-consiglio-tags">
      <span class="shuby-tag shuby-tag-sm shuby-tag-outline">Lettura</span>
      <span class="shuby-tag shuby-tag-sm shuby-tag-info">0-12 Mesi</span>
    </div>
    <span class="shuby-consiglio-title">Il viaggio di piedino</span>
    <span class="shuby-consiglio-author">Bacchilega Editore</span>
  </div>
</div>
```

### Author/Source Text

```erb
<span class="shuby-author">Bacchilega Editore</span>
<a href="#" class="shuby-author-link">View Source</a>
```

### Progress Indicators

```erb
<div class="shuby-progress">
  <div class="shuby-progress-bar" style="width: 60%;"></div>
</div>

<%# Success variant %>
<div class="shuby-progress">
  <div class="shuby-progress-bar shuby-progress-bar-success" style="width: 100%;"></div>
</div>
```

### Section Backgrounds

```erb
<%# Light blue section background (AI-helper, quiz screens) %>
<div class="shuby-bg-section">
  <h2>Content here...</h2>
</div>
```

### Back Link

Navigation back link with arrow icon.

```erb
<a href="/back" class="shuby-back-link">
  <span class="shuby-back-link-icon">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <path d="M15 18l-6-6 6-6"/>
    </svg>
  </span>
  Timeline
</a>

<%# Small variant %>
<a href="/back" class="shuby-back-link shuby-back-link-sm">
  <span class="shuby-back-link-icon"><!-- arrow icon --></span>
  Back
</a>
```

### Section Label

Uppercase category headers for sections (e.g., "MISURE MEDIE", "TAPPE DI SVILUPPO").

```erb
<%# Simple section label %>
<p class="shuby-section-label">MISURE MEDIE</p>

<%# Section label with border %>
<p class="shuby-section-label shuby-section-label-bordered">TAPPE DI SVILUPPO</p>

<%# Section header with label and link %>
<div class="shuby-section-header-row">
  <p class="shuby-section-label" style="margin-bottom: 0;">TAPPE DI SVILUPPO</p>
  <a href="/completate" class="shuby-link">Completate 6/6</a>
</div>
```

### Bottom Navigation (App Menu)

Mobile app bottom navigation bar with 4 menu items: Oggi, AI-helper, Archivio, Gestione.

```erb
<nav class="shuby-bottom-nav">
  <a href="/oggi" class="shuby-bottom-nav-item active">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Grid icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Oggi</span>
  </a>
  <a href="/ai-helper" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Chat/Robot icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">AI-helper</span>
  </a>
  <a href="/archivio" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Folder icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Archivio</span>
  </a>
  <a href="/gestione" class="shuby-bottom-nav-item">
    <div class="shuby-bottom-nav-icon">
      <svg><!-- Settings icon --></svg>
    </div>
    <span class="shuby-bottom-nav-label">Gestione</span>
  </a>
</nav>
```

**Structure:**
- `.shuby-bottom-nav` - Navigation container (flex, space-around)
- `.shuby-bottom-nav-item` - Individual nav link/button
- `.shuby-bottom-nav-icon` - Icon wrapper (24x24px)
- `.shuby-bottom-nav-label` - Text label (11px font)
- `.active` - Active state modifier

**States:**
| State | Color | Indicator |
|-------|-------|-----------|
| Inactive | Gray 500 (`#6B7280`) | None |
| Active | Blue 800 (`#0159B5`) | Dark underline bar |
| Hover | Blue 800 | Transition to blue |

**Fixed Position Variant:**
```erb
<%# For mobile app footer positioning %>
<nav class="shuby-bottom-nav shuby-bottom-nav-fixed">
  <!-- nav items -->
</nav>
```

### Date Picker Pills (Magenta Selection)

Horizontal scrollable date pills with magenta selection state.

```erb
<%# Date picker container %>
<div class="shuby-date-picker">
  <div class="shuby-date-pill">
    <span class="shuby-date-pill-day">Lu</span>
    <span class="shuby-date-pill-number">12</span>
  </div>
  <div class="shuby-date-pill selected">
    <span class="shuby-date-pill-day">Ma</span>
    <span class="shuby-date-pill-number">13</span>
  </div>
  <div class="shuby-date-pill">
    <span class="shuby-date-pill-day">Me</span>
    <span class="shuby-date-pill-number">14</span>
  </div>
  <div class="shuby-date-pill disabled">
    <span class="shuby-date-pill-day">Gi</span>
    <span class="shuby-date-pill-number">15</span>
  </div>
</div>
```

**States:**
- Default: White background with gray border
- Hover: Light magenta background
- Selected: Magenta background (`--bg-selection`)
- Disabled: Reduced opacity, not clickable

### Week/Step Selector (Magenta Selection)

For selecting weeks, months, or progress steps.

```erb
<%# Week selector %>
<div class="shuby-week-selector">
  <button class="shuby-week-item completed">1</button>
  <button class="shuby-week-item completed">2</button>
  <button class="shuby-week-item selected">3</button>
  <button class="shuby-week-item">4</button>
  <button class="shuby-week-item">5</button>
</div>
```

**States:**
- Default: Transparent background
- Hover: Light magenta background
- Selected: Magenta background (`--bg-selection`)
- Completed: Light magenta with checkmark

### Step Progress Dots

```erb
<div class="shuby-step-dots">
  <span class="shuby-step-dot completed"></span>
  <span class="shuby-step-dot completed"></span>
  <span class="shuby-step-dot active"></span>
  <span class="shuby-step-dot"></span>
</div>
```

### Calendar Grid

Full calendar component with magenta selection.

```erb
<div class="shuby-calendar-header">
  <span class="shuby-calendar-header-day">Lu</span>
  <span class="shuby-calendar-header-day">Ma</span>
  <span class="shuby-calendar-header-day">Me</span>
  <span class="shuby-calendar-header-day">Gi</span>
  <span class="shuby-calendar-header-day">Ve</span>
  <span class="shuby-calendar-header-day">Sa</span>
  <span class="shuby-calendar-header-day">Do</span>
</div>
<div class="shuby-calendar">
  <span class="shuby-calendar-day other-month">30</span>
  <span class="shuby-calendar-day">1</span>
  <span class="shuby-calendar-day today">2</span>
  <span class="shuby-calendar-day selected">3</span>
  <span class="shuby-calendar-day">4</span>
  <!-- ... more days -->
</div>
```

**Day States:**
- `.today` - Purple outline border
- `.selected` - Magenta background
- `.other-month` - Dimmed text
- `.disabled` - Not clickable

### Selection Badges

Magenta-colored badge variants.

```erb
<span class="shuby-badge shuby-badge-selection">Selected</span>
<span class="shuby-badge shuby-badge-selection-outline">Selection Outline</span>
```

---

## Timeline Components

The timeline components are used for navigating weeks and months in the child development tracking features.

### Timeline Container

Bordered container with lavender background for date pills.

```erb
<%# Lavender bordered container (as seen in Figma row 1) %>
<div class="shuby-timeline-container">
  <div class="shuby-timeline-pill selected-outline">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">6</span>
  </div>
  <div class="shuby-timeline-pill">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">7</span>
  </div>
  <!-- more pills -->
</div>

<%# Gray background container (alternate style) %>
<div class="shuby-timeline-container-alt">
  <div class="shuby-timeline-pill selected">
    <span class="shuby-timeline-pill-label">Sett.</span>
    <span class="shuby-timeline-pill-number">6</span>
  </div>
  <!-- more pills -->
</div>
```

**Container Variants:**
- `.shuby-timeline-container` - Lavender background with purple border
- `.shuby-timeline-container-alt` - Gray background, no border

### Timeline Pill States

```erb
<%# Default pill (white) %>
<div class="shuby-timeline-pill">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">3</span>
</div>

<%# Outline selected (purple border, white bg) %>
<div class="shuby-timeline-pill selected-outline">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">6</span>
</div>

<%# Filled selected - Magenta (magenta bg) %>
<div class="shuby-timeline-pill selected">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">6</span>
</div>

<%# Filled selected - Primary Blue (blue bg) %>
<div class="shuby-timeline-pill selected-primary">
  <span class="shuby-timeline-pill-label">Sett.</span>
  <span class="shuby-timeline-pill-number">6</span>
</div>
```

**Pill States:**
- Default: White background
- `.selected-outline` - White background with purple/blue outline border
- `.selected` - Magenta filled background with white text
- `.selected-primary` - Primary Blue filled background with white text

### Settimana (Week) Selector

Full text week labels with progressive selection.

```erb
<div class="shuby-settimana-selector">
  <button class="shuby-settimana-item active">Settimana 1</button>
  <button class="shuby-settimana-item">Settimana 2</button>
  <button class="shuby-settimana-item">Settimana 3</button>
  <button class="shuby-settimana-item">Settimana 4</button>
</div>
```

**States:**
- Default: Transparent background, dark text
- `.active` or `[aria-selected="true"]` - Magenta background, white text
- Hover: Light magenta background

### Timeline Theme Variables

| Variable | HEX | Description |
|----------|-----|-------------|
| `--bg-timeline-container` | `#F5F3FF` | Lavender container background |
| `--border-timeline-container` | `#A5B4FC` | Purple container border |
| `--bg-timeline-container-alt` | `#F3F4F6` | Gray container background |
| `--border-selection-outline` | `#A5B4FC` | Outline selection border |
| `--bg-selection` | `#FD1EAF` | Magenta filled selection |
| `--text-on-selection` | `#FFFFFF` | White text on selection |

---

## Theme Integration

### HTML Setup

The theme is applied via `data-theme="shuby"` on the HTML element:

```erb
<%# app/views/layouts/application.html.erb %>
<html data-theme="shuby">
```

### CSS Variables Usage

Use CSS variables directly in styles:

```css
.my-component {
  color: var(--text-primary);
  background-color: var(--bg-info);
  border-color: var(--base-border-primary);
}
```

### Theme Variable Mappings

| Variable | Maps To | Description |
|----------|---------|-------------|
| `--bg-primary` | Blue 800 | Primary button backgrounds |
| `--text-primary` | Blue 800 | Primary text color |
| `--bg-info` | Blue 100 | Info box backgrounds |
| `--base-bg-section` | Blue 100 | Section backgrounds |
| `--base-border-primary` | Blue 300 | Card borders |
| `--text-success` | Green 500 | Success text |
| `--text-danger` | Red 500 | Danger text |

---

## Celebration/Success Screens

Full-screen celebration modals for milestone completions, achievements, and success states.

### Tappa Completata (Teal Variant)

The teal variant matches the Figma design for milestone completion screens.

```erb
<%# Full celebration screen with teal gradient %>
<div class="shuby-tappa-completed-teal">
  <%# Header with mascot and text %>
  <div class="shuby-tappa-completed-header">
    <div class="shuby-tappa-completed-mascot">
      <%# Pentagon mascot component %>
      <div class="shuby-mascot-pentagon shuby-mascot-pentagon-teal">
        <!-- mascot SVG/HTML -->
      </div>
    </div>
    <span class="shuby-tappa-completed-label">Comunicazione e linguaggio</span>
    <h1 class="shuby-tappa-completed-title">Tappa completata!</h1>
    <p class="shuby-tappa-completed-description">
      Alessandro mostra buoni progressi nella comunicazione...
    </p>
  </div>

  <%# Content area with info box %>
  <div class="shuby-tappa-completed-content">
    <div class="shuby-info-box-dark">
      <p>Il Report di Crescita è stato aggiornato.
         Puoi aprirlo e <strong>condividerlo con il pediatra</strong>
         per un confronto durante le visite di controllo.</p>
    </div>
  </div>

  <%# Footer with CTA button %>
  <div class="shuby-tappa-completed-footer">
    <button class="shuby-btn shuby-btn-lg shuby-btn-teal w-full">
      Apri il Report di Crescita
    </button>
  </div>
</div>
```

### Background Variants

| Class | Background | Usage |
|-------|------------|-------|
| `.shuby-tappa-completed` | Blue gradient | Default blue celebration |
| `.shuby-tappa-completed-teal` | Teal gradient (Verde Scuro) | Teal/green celebration |

### Info Boxes on Dark Backgrounds

```erb
<%# Semi-transparent dark info box %>
<div class="shuby-info-box-dark">
  <p>Message with <strong>bold text</strong> here...</p>
</div>

<%# Blurred glass effect variant %>
<div class="shuby-info-box-dark-blur">
  <p>Message with blur backdrop...</p>
</div>
```

### Button Variants for Dark Backgrounds

```erb
<%# Teal button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-teal">Action</button>

<%# Light transparent button %>
<button class="shuby-btn shuby-btn-lg shuby-btn-light-on-dark">Action</button>
```

---

## File Structure

```
app/assets/tailwind/
├── application.css           # Main CSS, imports theme + components
├── themes/
│   └── shuby.css             # Shuby theme color variables
└── components/
    └── shuby.css             # Shuby component utility classes

app/views/
├── application/
│   └── _head.html.erb        # Baloo 2 + Montserrat font imports
├── design_system/
│   └── show.html.erb         # Design system demo page
└── layouts/
    └── application.html.erb  # data-theme="shuby"

config/routes/
└── dev.rb                    # /design_system route

docs/
└── shuby-design-system.md    # This documentation
```

---

## Development

### View Design System Demo

Start the development server and visit:
```
http://localhost:3000/design_system
```

The demo page displays:
- Complete color palette swatches
- Typography examples
- All button variants and sizes
- Tab components
- Card examples
- Info boxes
- Badges
- Form elements
- List items
- Progress indicators
- CSS variables reference table

### Adding New Components

1. Add CSS to `app/assets/tailwind/components/shuby.css`
2. Use the `shuby-` prefix for class names
3. Use CSS variables for colors (e.g., `var(--bg-primary)`)
4. Add examples to the design system demo page
5. Update this documentation
