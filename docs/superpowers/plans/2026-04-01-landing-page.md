# Shuby Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the basic landing page with a modern, mobile-first marketing page that showcases all Shuby features with touch-native animations and an empathetic-yet-authoritative tone.

**Architecture:** 9 section partials (`_landing_*.html.erb`) composed in `static#index`, animated by a single `scroll_reveal_controller.js` (IntersectionObserver) and a `landing_touch_controller.js` (touch micro-interactions). All animations are CSS @keyframes in `landing.css`. Old landing preserved at `/app-preview`.

**Tech Stack:** Rails 8 ERB views, TailwindCSS v4, Stimulus controllers, CSS @keyframes, IntersectionObserver API. Zero external dependencies.

**Spec:** `docs/superpowers/specs/2026-04-01-landing-page-design.md`

---

## File Map

### Create
| File | Purpose |
|------|---------|
| `app/views/static/app_preview.html.erb` | Old landing page (moved from index) |
| `app/assets/tailwind/components/shuby/landing.css` | All landing keyframes + utility classes |
| `app/javascript/controllers/scroll_reveal_controller.js` | IntersectionObserver scroll-triggered animations |
| `app/javascript/controllers/landing_touch_controller.js` | Touch micro-interactions (tilt, press, mascot wiggle) |
| `app/views/static/_landing_hero.html.erb` | Section 1: Hero |
| `app/views/static/_landing_trust.html.erb` | Section 2: Trust bar |
| `app/views/static/_landing_growth.html.erb` | Section 3: Growth charts |
| `app/views/static/_landing_milestones.html.erb` | Section 4: Development milestones |
| `app/views/static/_landing_ai.html.erb` | Section 5: AI chat demo |
| `app/views/static/_landing_content.html.erb` | Section 6: Archive carousel |
| `app/views/static/_landing_report.html.erb` | Section 7: Pediatrician report |
| `app/views/static/_landing_howto.html.erb` | Section 8: How it works |
| `app/views/static/_landing_cta.html.erb` | Section 9: Final CTA + footer |

### Modify
| File | Change |
|------|--------|
| `app/controllers/static_controller.rb` | Add `app_preview` action |
| `config/routes.rb` | Add `get :app_preview` in static scope |
| `app/assets/tailwind/application.css` | Import `landing.css` |
| `app/views/static/index.html.erb` | Complete rewrite with new sections |

---

## Task 1: Infrastructure — Route, Controller, Old Page Migration

**Files:**
- Modify: `app/controllers/static_controller.rb`
- Modify: `config/routes.rb`
- Create: `app/views/static/app_preview.html.erb`

- [ ] **Step 1: Copy old index to app_preview view**

Create `app/views/static/app_preview.html.erb` with the exact content of the current `index.html.erb`:

```erb
<% Current.meta_tags.set(
  title: "Shuby - Il tuo compagno per i primi 1000 giorni",
  description: "Shuby ti aiuta a seguire lo sviluppo del tuo bambino da 0 a 36 mesi con un assistente AI dedicato, consigli personalizzati e tracking delle tappe fondamentali."
) %>

<div class="min-h-screen bg-white dark:bg-gray-900 w-full max-w-full">
  <div class="w-full mx-auto px-4 py-6 lg:max-w-lg">

    <%= render "static/section_hero" %>

    <%= render "static/section_features" %>

    <%= render "static/section_activities" %>

    <%= render "static/section_tips" %>

    <%= render "static/section_featured" %>

    <%= render "static/section_ai_showcase" %>

    <%= render "static/section_cta" %>

  </div>
</div>
```

- [ ] **Step 2: Add controller action**

Add `app_preview` action to `app/controllers/static_controller.rb` after the `index` method:

```ruby
def app_preview
end
```

- [ ] **Step 3: Add route**

In `config/routes.rb`, add `get :app_preview` inside the existing `scope controller: :static` block, so it becomes:

```ruby
scope controller: :static do
  get :about
  get :terms
  get :privacy
  get :reset_app
  get :app_preview
end
```

- [ ] **Step 4: Verify old page works at new URL**

Run: `bin/rails routes | grep app_preview`

Expected: `app_preview GET /app_preview(.:format) static#app_preview`

- [ ] **Step 5: Commit**

```bash
git add app/views/static/app_preview.html.erb app/controllers/static_controller.rb config/routes.rb
git commit -m "refactor: preserve old landing page at /app-preview"
```

---

## Task 2: CSS — Landing Page Keyframes & Utilities

**Files:**
- Create: `app/assets/tailwind/components/shuby/landing.css`
- Modify: `app/assets/tailwind/application.css`

- [ ] **Step 1: Create landing.css**

Create `app/assets/tailwind/components/shuby/landing.css`:

```css
/* ==========================================================================
   Landing Page — Animations & Utilities
   ========================================================================== */

/* --- Reveal animations (triggered by scroll_reveal_controller) --- */

.landing-hidden {
  opacity: 0;
}

.landing-fade-up {
  animation: landing-fade-up 0.5s ease both;
}

.landing-scale-in {
  animation: landing-scale-in 0.5s ease both;
}

.landing-scale-bounce {
  animation: landing-scale-bounce 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) both;
}

.landing-slide-right {
  animation: landing-slide-right 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94) both;
}

@keyframes landing-fade-up {
  from { opacity: 0; transform: translateY(24px); }
  to   { opacity: 1; transform: translateY(0); }
}

@keyframes landing-scale-in {
  from { opacity: 0; transform: scale(0.9); }
  to   { opacity: 1; transform: scale(1); }
}

@keyframes landing-scale-bounce {
  from { opacity: 0; transform: scale(0.85); }
  to   { opacity: 1; transform: scale(1); }
}

@keyframes landing-slide-right {
  from { opacity: 0; transform: translateX(-30px); }
  to   { opacity: 1; transform: translateX(0); }
}

/* --- Loop animations --- */

.landing-float {
  animation: landing-float 3s ease-in-out infinite;
}

.landing-wiggle {
  animation: landing-wiggle 0.4s ease;
}

@keyframes landing-float {
  0%, 100% { transform: translateY(0); }
  50%      { transform: translateY(-8px); }
}

@keyframes landing-wiggle {
  0%, 100% { transform: rotate(0deg); }
  25%      { transform: rotate(-5deg); }
  75%      { transform: rotate(5deg); }
}

/* --- Chat section animations --- */

.landing-typing-dot {
  animation: landing-typing-dot 1.4s ease infinite;
}
.landing-typing-dot:nth-child(2) { animation-delay: 0.2s; }
.landing-typing-dot:nth-child(3) { animation-delay: 0.4s; }

.landing-chat-bubble {
  animation: landing-chat-bubble 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) both;
}

@keyframes landing-typing-dot {
  0%, 60%, 100% { opacity: 0.3; transform: scale(0.8); }
  30%           { opacity: 1;   transform: scale(1); }
}

@keyframes landing-chat-bubble {
  from { opacity: 0; transform: translateY(8px) scale(0.95); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}

/* --- Step line draw --- */

.landing-draw-down {
  animation: landing-draw-down 0.8s ease both;
}

@keyframes landing-draw-down {
  from { height: 0; }
  to   { height: 100%; }
}

/* --- Heart float (mascot tap) --- */

.landing-heart {
  position: absolute;
  pointer-events: none;
  animation: landing-heart-float 0.8s ease-out forwards;
}

@keyframes landing-heart-float {
  0%   { opacity: 1; transform: translateY(0) scale(1); }
  100% { opacity: 0; transform: translateY(-40px) scale(0.6); }
}

/* --- Touch feedback --- */

.landing-tilt {
  transform: perspective(600px) rotateY(3deg) !important;
  transition: transform 0.2s ease !important;
}

.landing-press {
  transform: scale(0.95) !important;
  transition: transform 0.15s ease !important;
}

/* --- Carousel (archive section) --- */

.landing-carousel {
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
}
.landing-carousel::-webkit-scrollbar { display: none; }

.landing-carousel-card {
  scroll-snap-align: start;
  flex-shrink: 0;
}

/* --- Reduced motion --- */

@media (prefers-reduced-motion: reduce) {
  .landing-hidden { opacity: 1; }
  .landing-fade-up,
  .landing-scale-in,
  .landing-scale-bounce,
  .landing-slide-right,
  .landing-chat-bubble,
  .landing-draw-down { animation: none !important; opacity: 1; transform: none; }
  .landing-float,
  .landing-wiggle,
  .landing-typing-dot { animation: none !important; }
}
```

- [ ] **Step 2: Register in application.css**

In `app/assets/tailwind/application.css`, add the import after the `growth-chart.css` line (before `utilities.css`):

```css
@import "./components/shuby/landing.css" layer(components);
```

So lines 148-150 become:
```css
@import "./components/shuby/growth-chart.css" layer(components);
@import "./components/shuby/landing.css" layer(components);
@import "./components/shuby/utilities.css";
```

- [ ] **Step 3: Verify CSS loads**

Run: `bin/rails assets:precompile 2>&1 | tail -5` (should succeed with no errors)

- [ ] **Step 4: Commit**

```bash
git add app/assets/tailwind/components/shuby/landing.css app/assets/tailwind/application.css
git commit -m "feat: add landing page CSS keyframes and utility classes"
```

---

## Task 3: Stimulus — Scroll Reveal Controller

**Files:**
- Create: `app/javascript/controllers/scroll_reveal_controller.js`

- [ ] **Step 1: Create the controller**

Create `app/javascript/controllers/scroll_reveal_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

// Reveals elements with CSS animations when they scroll into view.
//
// Usage:
//   <div data-controller="scroll-reveal"
//        data-scroll-reveal-animation-value="landing-fade-up"
//        data-scroll-reveal-stagger-value="120"
//        data-scroll-reveal-threshold-value="0.15">
//     <div data-scroll-reveal-target="item">...</div>
//     <div data-scroll-reveal-target="item">...</div>
//   </div>
//
// If no targets are specified, the controller element itself is animated.
export default class extends Controller {
  static targets = ["item"]
  static values = {
    animation: { type: String, default: "landing-fade-up" },
    stagger: { type: Number, default: 0 },
    threshold: { type: Number, default: 0.15 },
    once: { type: Boolean, default: true }
  }

  connect() {
    // Respect reduced motion preference
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return
    }

    this.elements = this.hasItemTarget ? this.itemTargets : [this.element]
    this.elements.forEach(el => el.classList.add("landing-hidden"))

    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersect(entries),
      { threshold: this.thresholdValue }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersect(entries) {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return

      this.elements.forEach((el, index) => {
        const delay = index * this.staggerValue
        el.style.animationDelay = `${delay}ms`
        el.classList.remove("landing-hidden")
        el.classList.add(this.animationValue)
      })

      if (this.onceValue) {
        this.observer.unobserve(entry.target)
      }
    })
  }
}
```

- [ ] **Step 2: Verify controller is auto-discovered**

Stimulus auto-loads controllers from `app/javascript/controllers/`. Verify:

Run: `ls app/javascript/controllers/scroll_reveal_controller.js`

Expected: file exists. Stimulus will register it as `scroll-reveal` automatically.

- [ ] **Step 3: Commit**

```bash
git add app/javascript/controllers/scroll_reveal_controller.js
git commit -m "feat: add scroll-reveal Stimulus controller for landing animations"
```

---

## Task 4: Stimulus — Landing Touch Controller

**Files:**
- Create: `app/javascript/controllers/landing_touch_controller.js`

- [ ] **Step 1: Create the controller**

Create `app/javascript/controllers/landing_touch_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

// Touch micro-interactions for the landing page.
//
// Targets:
//   tiltable  — 3D tilt on press
//   pressable — scale-down on press
//   mascot    — wiggle + floating heart on tap
export default class extends Controller {
  static targets = ["tiltable", "pressable", "mascot"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return
    }

    this.tiltableTargets.forEach(el => {
      el.addEventListener("touchstart", this.handleTiltStart, { passive: true })
      el.addEventListener("touchend", this.handleTiltEnd, { passive: true })
    })

    this.pressableTargets.forEach(el => {
      el.addEventListener("touchstart", this.handlePressStart, { passive: true })
      el.addEventListener("touchend", this.handlePressEnd, { passive: true })
    })

    this.mascotTargets.forEach(el => {
      el.addEventListener("click", this.handleMascotTap)
    })
  }

  disconnect() {
    this.tiltableTargets.forEach(el => {
      el.removeEventListener("touchstart", this.handleTiltStart)
      el.removeEventListener("touchend", this.handleTiltEnd)
    })
    this.pressableTargets.forEach(el => {
      el.removeEventListener("touchstart", this.handlePressStart)
      el.removeEventListener("touchend", this.handlePressEnd)
    })
    this.mascotTargets.forEach(el => {
      el.removeEventListener("click", this.handleMascotTap)
    })
  }

  handleTiltStart = (e) => {
    e.currentTarget.classList.add("landing-tilt")
  }

  handleTiltEnd = (e) => {
    setTimeout(() => e.currentTarget.classList.remove("landing-tilt"), 200)
  }

  handlePressStart = (e) => {
    e.currentTarget.classList.add("landing-press")
  }

  handlePressEnd = (e) => {
    e.currentTarget.classList.remove("landing-press")
  }

  handleMascotTap = (e) => {
    const mascot = e.currentTarget

    // Wiggle
    mascot.classList.remove("landing-wiggle")
    void mascot.offsetHeight // force reflow
    mascot.classList.add("landing-wiggle")

    // Floating heart
    const heart = document.createElement("span")
    heart.textContent = "\u2764\uFE0F"
    heart.classList.add("landing-heart")
    heart.style.left = "50%"
    heart.style.top = "0"
    heart.style.fontSize = "1.25rem"
    mascot.style.position = "relative"
    mascot.appendChild(heart)
    setTimeout(() => heart.remove(), 800)
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/javascript/controllers/landing_touch_controller.js
git commit -m "feat: add landing touch micro-interactions controller"
```

---

## Task 5: Section 1 — Hero

**Files:**
- Create: `app/views/static/_landing_hero.html.erb`

- [ ] **Step 1: Create hero partial**

Create `app/views/static/_landing_hero.html.erb`:

```erb
<section class="relative overflow-hidden pt-8 pb-12 px-4"
         data-controller="scroll-reveal landing-touch"
         data-scroll-reveal-stagger-value="120">

  <%# Background gradient with organic shapes %>
  <div class="absolute inset-0 bg-gradient-to-br from-[var(--color-shuby-blue-300)] via-[var(--color-shuby-blue-400)] to-white -z-10" aria-hidden="true">
    <div class="absolute top-10 -right-10 w-40 h-40 rounded-full bg-[var(--color-shuby-verde-200)] opacity-30 blur-2xl"></div>
    <div class="absolute bottom-20 -left-10 w-32 h-32 rounded-full bg-[var(--color-shuby-giallo-400)] opacity-20 blur-2xl"></div>
  </div>

  <%# Text content %>
  <div data-scroll-reveal-target="item">
    <%= shuby_tag("0-36 mesi", variant: :bianco, class: "mb-3 inline-block") %>
  </div>

  <h1 class="font-display text-[32px] sm:text-[40px] font-bold leading-tight text-[var(--color-shuby-blue-800)] mb-3"
      data-scroll-reveal-target="item">
    I primi 1000 giorni,<br>insieme a te.
  </h1>

  <p class="font-sans text-base text-[var(--color-shuby-gray-800)] mb-6 max-w-sm"
     data-scroll-reveal-target="item">
    Crescita, sviluppo e consigli personalizzati &mdash; con un assistente AI dedicato.
  </p>

  <%# Store badges %>
  <div class="flex gap-3 mb-8" data-scroll-reveal-target="item">
    <a href="#" class="inline-block" data-landing-touch-target="pressable">
      <%= image_tag "shuby/landing/badge-app-store.svg",
          alt: "Scarica su App Store",
          class: "h-11" %>
    </a>
    <a href="#" class="inline-block" data-landing-touch-target="pressable">
      <%= image_tag "shuby/landing/badge-google-play.svg",
          alt: "Disponibile su Google Play",
          class: "h-11" %>
    </a>
  </div>

  <%# Phone mockup + mascot %>
  <div class="relative flex justify-center items-end mt-4">
    <%# Phone mockup %>
    <div class="relative w-52 sm:w-60 landing-scale-bounce" style="animation-delay: 300ms;">
      <div class="bg-white rounded-[2rem] shadow-lg border-4 border-[var(--color-shuby-gray-500)] p-2 overflow-hidden">
        <div class="rounded-[1.5rem] overflow-hidden aspect-[9/16] bg-[var(--color-shuby-blue-300)] flex items-center justify-center">
          <%# Placeholder — replace with Figma screenshot %>
          <div class="text-center p-4">
            <%= image_tag "shuby/illustrations/mascot-duo-shapes.png",
                alt: "",
                class: "w-24 h-auto mx-auto mb-2",
                aria: { hidden: true } %>
            <p class="shuby-p2 text-[var(--color-shuby-blue-800)]">Dashboard Shuby</p>
          </div>
        </div>
      </div>
    </div>

    <%# Floating mascot %>
    <div class="absolute -right-2 bottom-8 sm:right-4 landing-float cursor-pointer"
         data-landing-touch-target="mascot">
      <%= image_tag "shuby/illustrations/mascot-sorriso-tall.png",
          alt: "Shuby mascotte",
          class: "w-20 sm:w-24 h-auto drop-shadow-md" %>
    </div>
  </div>
</section>
```

- [ ] **Step 2: Create placeholder store badge SVGs**

We need placeholder store badge images. Create two simple SVG badges:

Create `app/assets/images/shuby/landing/badge-app-store.svg`:
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="135" height="40" viewBox="0 0 135 40">
  <rect width="135" height="40" rx="6" fill="#000"/>
  <text x="68" y="16" text-anchor="middle" fill="#fff" font-family="system-ui" font-size="8" font-weight="400">Scarica su</text>
  <text x="68" y="28" text-anchor="middle" fill="#fff" font-family="system-ui" font-size="13" font-weight="600">App Store</text>
</svg>
```

Create `app/assets/images/shuby/landing/badge-google-play.svg`:
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="135" height="40" viewBox="0 0 135 40">
  <rect width="135" height="40" rx="6" fill="#000"/>
  <text x="68" y="16" text-anchor="middle" fill="#fff" font-family="system-ui" font-size="8" font-weight="400">Disponibile su</text>
  <text x="68" y="28" text-anchor="middle" fill="#fff" font-family="system-ui" font-size="13" font-weight="600">Google Play</text>
</svg>
```

These will be replaced with official badge assets later.

- [ ] **Step 3: Commit**

```bash
git add app/views/static/_landing_hero.html.erb app/assets/images/shuby/landing/
git commit -m "feat: add landing page hero section with phone mockup and mascot"
```

---

## Task 6: Section 2 — Trust Bar

**Files:**
- Create: `app/views/static/_landing_trust.html.erb`

- [ ] **Step 1: Create trust bar partial**

Create `app/views/static/_landing_trust.html.erb`:

```erb
<%
  trust_items = [
    { icon: "shuby/icons/icon-neurodevelopment", text: "Standard WHO" },
    { icon: "shuby/icons/icon-reading",          text: "100+ articoli" },
    { icon: "shuby/icons/icon-chatbot",           text: "AI medica" },
    { icon: "shuby/icons/icon-barefoot",           text: "5 aree sviluppo" }
  ]
%>

<section class="py-4 px-4"
         data-controller="scroll-reveal"
         data-scroll-reveal-stagger-value="80">
  <div class="flex gap-3 overflow-x-auto pb-2" style="scrollbar-width: none; -webkit-overflow-scrolling: touch;">
    <% trust_items.each do |item| %>
      <div class="flex items-center gap-2 px-4 py-2 bg-white border border-[var(--color-shuby-blue-300)] rounded-full whitespace-nowrap flex-shrink-0"
           data-scroll-reveal-target="item">
        <%= render_svg item[:icon], size: :md, decorative: true, styles: "text-[var(--color-shuby-blue-800)]" %>
        <span class="font-sans text-sm font-semibold text-[var(--color-shuby-gray-800)]"><%= item[:text] %></span>
      </div>
    <% end %>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_trust.html.erb
git commit -m "feat: add landing trust bar section"
```

---

## Task 7: Section 3 — Growth Charts

**Files:**
- Create: `app/views/static/_landing_growth.html.erb`

- [ ] **Step 1: Create growth section partial**

Create `app/views/static/_landing_growth.html.erb`:

```erb
<section class="py-8 px-4"
         data-controller="scroll-reveal"
         data-scroll-reveal-stagger-value="120">

  <p class="shuby-overline text-[var(--color-shuby-gray-700)] mb-2"
     data-scroll-reveal-target="item">
    MONITORAGGIO CRESCITA
  </p>

  <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-3"
      data-scroll-reveal-target="item">
    Curve di crescita WHO sempre a portata di mano
  </h2>

  <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-6 max-w-sm"
     data-scroll-reveal-target="item">
    Registra peso, altezza e circonferenza cranica. Visualizza i percentili del tuo bambino rispetto agli standard dell'Organizzazione Mondiale della Sanit&agrave;.
  </p>

  <%# Growth chart mockup %>
  <div class="rounded-2xl overflow-hidden border border-[var(--color-shuby-gray-500)] bg-white p-4"
       data-scroll-reveal-target="item"
       data-scroll-reveal-animation-value="landing-scale-in">
    <%# Placeholder — replace with Figma screenshot %>
    <div class="aspect-[4/3] bg-gradient-to-br from-[var(--color-shuby-blue-300)] to-white rounded-xl flex items-center justify-center">
      <%= image_tag "shuby/illustrations/illustration-weight-chart.svg",
          alt: "Grafico percentili WHO esempio",
          class: "w-3/4 h-auto opacity-80" %>
    </div>
  </div>

  <%# Measurement type pills %>
  <div class="flex gap-3 mt-4 justify-center" data-scroll-reveal-target="item">
    <% [
      { icon: "⚖️", label: "Peso", color: "shuby-blue-400" },
      { icon: "📏", label: "Altezza", color: "shuby-verde-200" },
      { icon: "🧠", label: "Testa", color: "shuby-giallo-400" }
    ].each do |m| %>
      <div class="flex items-center gap-1.5 px-3 py-1.5 bg-[var(--color-<%= m[:color] %>)] rounded-full">
        <span class="text-sm"><%= m[:icon] %></span>
        <span class="font-sans text-xs font-semibold text-[var(--color-shuby-gray-800)]"><%= m[:label] %></span>
      </div>
    <% end %>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_growth.html.erb
git commit -m "feat: add landing growth charts section"
```

---

## Task 8: Section 4 — Development Milestones

**Files:**
- Create: `app/views/static/_landing_milestones.html.erb`

- [ ] **Step 1: Create milestones section partial**

Create `app/views/static/_landing_milestones.html.erb`:

```erb
<%
  areas = [
    { name: "Generale",       desc: "Crescita e benessere globale",       bg: "shuby-blue-400",   icon: "shuby/icons/icon-barefoot" },
    { name: "Comunicazione",  desc: "Linguaggio e interazione",           bg: "shuby-verde-200",  icon: "shuby/icons/icon-chatbot" },
    { name: "Motricità",      desc: "Movimenti e coordinazione",          bg: "shuby-magenta-300", icon: "shuby/icons/icon-neurodevelopment" },
    { name: "Cognizione",     desc: "Apprendimento e problem solving",    bg: "shuby-giallo-400", icon: "shuby/icons/icon-reading" },
    { name: "Relazione",      desc: "Socialità e legami affettivi",       bg: "shuby-blue-300",   icon: "shuby/icons/icon-archive" }
  ]
%>

<section class="py-8 px-4"
         data-controller="scroll-reveal landing-touch"
         data-scroll-reveal-stagger-value="120">

  <p class="shuby-overline text-[var(--color-shuby-gray-700)] mb-2"
     data-scroll-reveal-target="item">
    SVILUPPO NEUROEVOLUTIVO
  </p>

  <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-2"
      data-scroll-reveal-target="item">
    5 aree, un quadro completo
  </h2>

  <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-6 max-w-sm"
     data-scroll-reveal-target="item">
    Questionari scientifici personalizzati per ogni fase dello sviluppo del tuo bambino.
  </p>

  <div class="grid grid-cols-2 gap-3">
    <% areas.each_with_index do |area, i| %>
      <div class="<%= 'col-span-2 max-w-[calc(50%-6px)] mx-auto' if i == areas.length - 1 %>"
           data-scroll-reveal-target="item">
        <div class="bg-white border border-[var(--color-shuby-gray-500)] rounded-2xl p-4 h-full
                    active:shadow-md transition-shadow"
             data-landing-touch-target="tiltable">
          <div class="w-10 h-10 rounded-xl bg-[var(--color-<%= area[:bg] %>)] flex items-center justify-center mb-3">
            <%= render_svg area[:icon], size: :md, decorative: true %>
          </div>
          <h3 class="font-sans text-sm font-bold text-[var(--color-shuby-gray-800)] mb-1"><%= area[:name] %></h3>
          <p class="font-sans text-xs text-[var(--color-shuby-gray-700)]"><%= area[:desc] %></p>
        </div>
      </div>
    <% end %>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_milestones.html.erb
git commit -m "feat: add landing development milestones section"
```

---

## Task 9: Section 5 — AI Chat Demo

**Files:**
- Create: `app/views/static/_landing_ai.html.erb`

- [ ] **Step 1: Create AI chat section partial**

Create `app/views/static/_landing_ai.html.erb`:

```erb
<%
  chat_messages = [
    { role: :user,  text: "Il mio bambino di 8 mesi non gattona ancora, è normale?" },
    { role: :shuby, text: "Assolutamente sì! Ogni bambino ha i suoi tempi. Il gattonamento inizia tipicamente tra i 7 e 10 mesi, ma alcuni bambini saltano questa fase e passano direttamente a stare in piedi." },
    { role: :user,  text: "Ci sono esercizi che posso fare?" },
    { role: :shuby, text: "Certo! Prova il tummy time su una superficie morbida, metti un giocattolo appena fuori dalla sua portata e incoraggialo a raggiungerlo. Anche 5 minuti al giorno fanno la differenza!" }
  ]
%>

<section class="py-8 px-4">
  <div class="bg-gradient-to-br from-[var(--color-shuby-blue-800)] to-[var(--color-shuby-blue-700)] rounded-3xl p-5 text-white"
       data-controller="scroll-reveal"
       data-scroll-reveal-stagger-value="0">

    <%# Header %>
    <div class="flex items-center gap-3 mb-5" data-scroll-reveal-target="item">
      <div class="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
        <%= render_svg "shuby/icons/icon-chatbot", size: :lg, styles: "text-white", decorative: true %>
      </div>
      <div>
        <h2 class="font-display text-xl font-bold text-white">Incontra Shuby</h2>
        <p class="font-sans text-sm text-blue-200">Il tuo assistente AI per ogni domanda, 24/7</p>
      </div>
    </div>

    <%# Chat messages %>
    <div class="space-y-3 mb-5"
         data-controller="scroll-reveal"
         data-scroll-reveal-stagger-value="600"
         data-scroll-reveal-animation-value="landing-chat-bubble"
         data-scroll-reveal-threshold-value="0.3">
      <% chat_messages.each do |msg| %>
        <div class="flex items-start gap-2 <%= msg[:role] == :user ? '' : 'flex-row-reverse' %>"
             data-scroll-reveal-target="item">
          <% if msg[:role] == :user %>
            <div class="w-7 h-7 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
              <span class="text-xs">👤</span>
            </div>
            <div class="bg-white/10 rounded-2xl rounded-tl-sm px-3 py-2 max-w-[80%]">
              <p class="font-sans text-sm text-blue-100"><%= msg[:text] %></p>
            </div>
          <% else %>
            <div class="w-7 h-7 rounded-full bg-white flex items-center justify-center flex-shrink-0">
              <%= render_svg "shuby/icons/icon-chatbot", size: :sm, decorative: true %>
            </div>
            <div class="bg-white/15 rounded-2xl rounded-tr-sm px-3 py-2 max-w-[85%]">
              <p class="font-sans text-sm text-white"><%= msg[:text] %></p>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>

    <%# Credibility note %>
    <p class="font-sans text-xs text-blue-300 text-center mb-4">
      Risposte basate su fonti mediche verificate
    </p>

    <%# CTA %>
    <% if user_signed_in? %>
      <%= link_to shuby_chats_path, class: "block w-full text-center py-3 bg-white text-[var(--color-shuby-blue-800)] font-sans font-semibold text-base rounded-full active:scale-95 transition-transform" do %>
        Parla con Shuby
      <% end %>
    <% else %>
      <%= link_to new_user_registration_path, class: "block w-full text-center py-3 bg-white text-[var(--color-shuby-blue-800)] font-sans font-semibold text-base rounded-full active:scale-95 transition-transform" do %>
        Prova Shuby Gratis
      <% end %>
    <% end %>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_ai.html.erb
git commit -m "feat: add landing AI chat demo section with staggered bubbles"
```

---

## Task 10: Section 6 — Archive Content Carousel

**Files:**
- Create: `app/views/static/_landing_content.html.erb`

- [ ] **Step 1: Create content carousel partial**

Create `app/views/static/_landing_content.html.erb`:

```erb
<%
  articles = [
    { title: "Sonno del neonato",           category: "Sonno",         age: "0-6 mesi",  duration: "4 min", bg: "shuby-blue-400",   cat_color: "shuby-blue-800",   image: "shuby/illustrations/mascot-cloud.png" },
    { title: "Svezzamento: quando iniziare", category: "Alimentazione", age: "4-12 mesi", duration: "6 min", bg: "shuby-verde-200",  cat_color: "shuby-verde-500",  image: "shuby/illustrations/mascot-sorriso-small.png" },
    { title: "Giochi sensoriali",           category: "Gioco",         age: "0-12 mesi", duration: "5 min", bg: "shuby-giallo-400", cat_color: "shuby-gray-800",   image: "shuby/illustrations/mascot-pink-shapes.png" },
    { title: "Benessere famigliare",        category: "Benessere",     age: "0-36 mesi", duration: "7 min", bg: "shuby-magenta-300", cat_color: "shuby-fucsia-500", image: "shuby/illustrations/mascot-duo-friends.png" }
  ]
%>

<section class="py-8 pl-4"
         data-controller="scroll-reveal">

  <div class="pr-4" data-scroll-reveal-target="item">
    <p class="shuby-overline text-[var(--color-shuby-gray-700)] mb-2">ARCHIVIO CONTENUTI</p>
    <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-2">
      100+ articoli basati sulla scienza
    </h2>
    <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-5 max-w-sm">
      Sonno, alimentazione, gioco, motricit&agrave;, salute &mdash; filtrati per l'et&agrave; del tuo bambino.
    </p>
  </div>

  <%# Swipeable carousel %>
  <div class="landing-carousel flex gap-3 pr-4" data-scroll-reveal-target="item">
    <% articles.each do |article| %>
      <div class="landing-carousel-card w-[260px] bg-white border border-[var(--color-shuby-gray-500)] rounded-2xl overflow-hidden">
        <%# Thumbnail %>
        <div class="h-32 bg-[var(--color-<%= article[:bg] %>)] flex items-center justify-center p-4">
          <%= image_tag article[:image],
              alt: "",
              class: "h-20 w-auto object-contain",
              aria: { hidden: true } %>
        </div>
        <%# Card body %>
        <div class="p-3">
          <div class="flex items-center gap-2 mb-1.5">
            <span class="font-sans text-[10px] font-semibold uppercase text-[var(--color-<%= article[:cat_color] %>)] bg-[var(--color-<%= article[:bg] %>)] px-2 py-0.5 rounded-full"><%= article[:category] %></span>
            <span class="font-sans text-[10px] text-[var(--color-shuby-gray-700)]"><%= article[:age] %></span>
          </div>
          <h3 class="font-sans text-sm font-bold text-[var(--color-shuby-gray-800)] mb-1"><%= article[:title] %></h3>
          <span class="font-sans text-xs text-[var(--color-shuby-gray-600)]"><%= article[:duration] %> di lettura</span>
        </div>
      </div>
    <% end %>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_content.html.erb
git commit -m "feat: add landing archive content carousel section"
```

---

## Task 11: Section 7 — Pediatrician Report

**Files:**
- Create: `app/views/static/_landing_report.html.erb`

- [ ] **Step 1: Create report section partial**

Create `app/views/static/_landing_report.html.erb`:

```erb
<section class="py-8 px-4"
         data-controller="scroll-reveal"
         data-scroll-reveal-stagger-value="120">

  <div class="bg-[var(--color-shuby-blue-300)] rounded-3xl p-5">
    <div class="flex items-start gap-3 mb-4" data-scroll-reveal-target="item">
      <div class="w-10 h-10 rounded-xl bg-white flex items-center justify-center flex-shrink-0">
        <%= render_svg "shuby/icons/icon-document", size: :md, decorative: true, styles: "text-[var(--color-shuby-blue-800)]" %>
      </div>
      <div>
        <h2 class="font-display text-xl font-bold text-[var(--color-shuby-blue-800)]">
          Un report pronto per il pediatra
        </h2>
      </div>
    </div>

    <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-5"
       data-scroll-reveal-target="item">
      Genera un PDF completo con misurazioni, tappe raggiunte e domande &mdash; da condividere al prossimo appuntamento.
    </p>

    <%# PDF mockup %>
    <div class="bg-white rounded-2xl p-4 shadow-sm"
         data-scroll-reveal-target="item"
         data-scroll-reveal-animation-value="landing-scale-in">
      <div class="border-b border-[var(--color-shuby-gray-500)] pb-3 mb-3">
        <div class="flex items-center gap-2 mb-2">
          <div class="w-8 h-8 rounded-full bg-[var(--color-shuby-blue-400)]"></div>
          <div>
            <p class="font-sans text-xs font-bold text-[var(--color-shuby-gray-800)]">Marco, 8 mesi</p>
            <p class="font-sans text-[10px] text-[var(--color-shuby-gray-600)]">Report del 01/04/2026</p>
          </div>
        </div>
      </div>
      <div class="space-y-2">
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 rounded bg-[var(--color-shuby-verde-200)]"></div>
          <span class="font-sans text-xs text-[var(--color-shuby-gray-700)]">Peso: 8.2 kg (50&deg; percentile)</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 rounded bg-[var(--color-shuby-blue-400)]"></div>
          <span class="font-sans text-xs text-[var(--color-shuby-gray-700)]">Altezza: 70 cm (65&deg; percentile)</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-4 h-4 rounded bg-[var(--color-shuby-giallo-400)]"></div>
          <span class="font-sans text-xs text-[var(--color-shuby-gray-700)]">12 tappe raggiunte su 15</span>
        </div>
      </div>
    </div>

    <div class="flex items-center justify-center gap-2 mt-4" data-scroll-reveal-target="item">
      <span class="font-sans text-xs font-semibold text-[var(--color-shuby-blue-800)]">Condividi via email o WhatsApp</span>
    </div>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_report.html.erb
git commit -m "feat: add landing pediatrician report section"
```

---

## Task 12: Section 8 — How It Works

**Files:**
- Create: `app/views/static/_landing_howto.html.erb`

- [ ] **Step 1: Create how-it-works section partial**

Create `app/views/static/_landing_howto.html.erb`:

```erb
<%
  steps = [
    { num: "1", title: "Scarica l'app",         desc: "Disponibile su App Store e Google Play", color: "shuby-blue-800" },
    { num: "2", title: "Crea il profilo",        desc: "Aggiungi nome, data di nascita e inizia",  color: "shuby-verde-500" },
    { num: "3", title: "Monitora e cresci",      desc: "Shuby ti guida giorno per giorno",         color: "shuby-fucsia-500" }
  ]
%>

<section class="py-8 px-4"
         data-controller="scroll-reveal"
         data-scroll-reveal-stagger-value="300">

  <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-8 text-center"
      data-scroll-reveal-target="item">
    Come funziona
  </h2>

  <div class="relative max-w-xs mx-auto">
    <%# Vertical dashed line %>
    <div class="absolute left-5 top-6 bottom-6 w-px border-l-2 border-dashed border-[var(--color-shuby-blue-400)]"
         aria-hidden="true"></div>

    <div class="space-y-8">
      <% steps.each do |step| %>
        <div class="flex items-start gap-4 relative" data-scroll-reveal-target="item">
          <%# Number circle %>
          <div class="w-10 h-10 rounded-full bg-[var(--color-<%= step[:color] %>)] flex items-center justify-center flex-shrink-0 z-10">
            <span class="font-display text-lg font-bold text-white"><%= step[:num] %></span>
          </div>
          <%# Text %>
          <div class="pt-1">
            <h3 class="font-sans text-base font-bold text-[var(--color-shuby-gray-800)] mb-1"><%= step[:title] %></h3>
            <p class="font-sans text-sm text-[var(--color-shuby-gray-700)]"><%= step[:desc] %></p>
          </div>
        </div>
      <% end %>
    </div>
  </div>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_howto.html.erb
git commit -m "feat: add landing how-it-works section with numbered steps"
```

---

## Task 13: Section 9 — Final CTA + Footer

**Files:**
- Create: `app/views/static/_landing_cta.html.erb`

- [ ] **Step 1: Create CTA + footer partial**

Create `app/views/static/_landing_cta.html.erb`:

```erb
<section class="pt-8 pb-4 px-4"
         data-controller="scroll-reveal landing-touch"
         data-scroll-reveal-stagger-value="120">

  <%# CTA block %>
  <div class="bg-gradient-to-br from-[var(--color-shuby-blue-300)] to-[var(--color-shuby-blue-400)] rounded-3xl p-6 text-center mb-8">
    <%# Mascot %>
    <div class="mb-4 landing-float" data-scroll-reveal-target="item">
      <%= image_tag "shuby/illustrations/mascot-centered.svg",
          alt: "",
          class: "w-20 h-auto mx-auto",
          aria: { hidden: true } %>
    </div>

    <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-2"
        data-scroll-reveal-target="item">
      Ogni giorno conta.<br>Inizia oggi.
    </h2>

    <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-5"
       data-scroll-reveal-target="item">
      Gratuito. Nessuna carta di credito richiesta.
    </p>

    <%# Store badges %>
    <div class="flex gap-3 justify-center" data-scroll-reveal-target="item">
      <a href="#" class="inline-block" data-landing-touch-target="pressable">
        <%= image_tag "shuby/landing/badge-app-store.svg",
            alt: "Scarica su App Store",
            class: "h-11" %>
      </a>
      <a href="#" class="inline-block" data-landing-touch-target="pressable">
        <%= image_tag "shuby/landing/badge-google-play.svg",
            alt: "Disponibile su Google Play",
            class: "h-11" %>
      </a>
    </div>
  </div>

  <%# Footer %>
  <footer class="text-center pb-6">
    <div class="mb-4">
      <%= image_tag "logo.svg",
          alt: "Shuby",
          class: "h-6 mx-auto" %>
    </div>
    <nav class="flex gap-4 justify-center mb-4" aria-label="Footer">
      <%= link_to "Privacy", privacy_path, class: "font-sans text-xs text-[var(--color-shuby-gray-700)] hover:text-[var(--color-shuby-blue-800)]" %>
      <%= link_to "Termini", terms_path, class: "font-sans text-xs text-[var(--color-shuby-gray-700)] hover:text-[var(--color-shuby-blue-800)]" %>
      <a href="mailto:info@shuby.app" class="font-sans text-xs text-[var(--color-shuby-gray-700)] hover:text-[var(--color-shuby-blue-800)]">Contatti</a>
    </nav>
    <p class="font-sans text-[10px] text-[var(--color-shuby-gray-600)]">
      &copy; <%= Date.today.year %> Shuby. Tutti i diritti riservati.
    </p>
  </footer>
</section>
```

- [ ] **Step 2: Commit**

```bash
git add app/views/static/_landing_cta.html.erb
git commit -m "feat: add landing final CTA and footer section"
```

---

## Task 14: Main Index — Wire Up All Sections

**Files:**
- Modify: `app/views/static/index.html.erb`

- [ ] **Step 1: Rewrite index.html.erb**

Replace the entire content of `app/views/static/index.html.erb` with:

```erb
<% Current.meta_tags.set(
  title: "Shuby - I primi 1000 giorni, insieme a te",
  description: "Shuby ti aiuta a seguire lo sviluppo del tuo bambino da 0 a 36 mesi. Curve di crescita WHO, questionari scientifici, assistente AI e 100+ articoli — tutto in un'app."
) %>

<div class="min-h-screen bg-white w-full max-w-full overflow-x-hidden">
  <div class="w-full mx-auto lg:max-w-4xl">

    <%= render "static/landing_hero" %>

    <%= render "static/landing_trust" %>

    <%= render "static/landing_growth" %>

    <%= render "static/landing_milestones" %>

    <%= render "static/landing_ai" %>

    <%= render "static/landing_content" %>

    <%= render "static/landing_report" %>

    <%= render "static/landing_howto" %>

    <%= render "static/landing_cta" %>

  </div>
</div>
```

- [ ] **Step 2: Start dev server and verify**

Run: `bin/dev`

Open `http://localhost:3000` in browser. Verify:
- All 9 sections render without errors
- Scroll animations trigger as sections enter viewport
- Mascot tap produces wiggle + heart
- Carousel swipes horizontally
- No console errors

- [ ] **Step 3: Verify old landing at /app-preview**

Navigate to `http://localhost:3000/app-preview`. Verify the old landing page renders correctly with all its sections.

- [ ] **Step 4: Run tests and linting**

Run: `bin/rails test`
Run: `bin/rubocop`

Both should pass with no new failures.

- [ ] **Step 5: Commit**

```bash
git add app/views/static/index.html.erb
git commit -m "feat: wire up new landing page with 9 animated sections"
```

---

## Task 15: Desktop Responsive & Polish

**Files:**
- Modify: `app/views/static/_landing_hero.html.erb`
- Modify: `app/views/static/_landing_growth.html.erb`
- Modify: `app/views/static/_landing_milestones.html.erb`

- [ ] **Step 1: Add desktop layout to hero**

In `app/views/static/_landing_hero.html.erb`, wrap the text+badges content and the phone+mascot in a responsive flex container. Replace the content between the background div and the closing `</section>` with:

```erb
  <div class="lg:flex lg:items-center lg:gap-12 lg:min-h-[500px]">
    <%# Text content %>
    <div class="lg:flex-1">
      <div data-scroll-reveal-target="item">
        <%= shuby_tag("0-36 mesi", variant: :bianco, class: "mb-3 inline-block") %>
      </div>

      <h1 class="font-display text-[32px] sm:text-[40px] lg:text-[48px] font-bold leading-tight text-[var(--color-shuby-blue-800)] mb-3"
          data-scroll-reveal-target="item">
        I primi 1000 giorni,<br>insieme a te.
      </h1>

      <p class="font-sans text-base lg:text-lg text-[var(--color-shuby-gray-800)] mb-6 max-w-sm"
         data-scroll-reveal-target="item">
        Crescita, sviluppo e consigli personalizzati &mdash; con un assistente AI dedicato.
      </p>

      <%# Store badges %>
      <div class="flex gap-3 mb-8 lg:mb-0" data-scroll-reveal-target="item">
        <a href="#" class="inline-block" data-landing-touch-target="pressable">
          <%= image_tag "shuby/landing/badge-app-store.svg",
              alt: "Scarica su App Store",
              class: "h-11" %>
        </a>
        <a href="#" class="inline-block" data-landing-touch-target="pressable">
          <%= image_tag "shuby/landing/badge-google-play.svg",
              alt: "Disponibile su Google Play",
              class: "h-11" %>
        </a>
      </div>
    </div>

    <%# Phone mockup + mascot %>
    <div class="relative flex justify-center items-end mt-4 lg:mt-0 lg:flex-1">
      <div class="relative w-52 sm:w-60 landing-scale-bounce" style="animation-delay: 300ms;">
        <div class="bg-white rounded-[2rem] shadow-lg border-4 border-[var(--color-shuby-gray-500)] p-2 overflow-hidden">
          <div class="rounded-[1.5rem] overflow-hidden aspect-[9/16] bg-[var(--color-shuby-blue-300)] flex items-center justify-center">
            <div class="text-center p-4">
              <%= image_tag "shuby/illustrations/mascot-duo-shapes.png",
                  alt: "",
                  class: "w-24 h-auto mx-auto mb-2",
                  aria: { hidden: true } %>
              <p class="shuby-p2 text-[var(--color-shuby-blue-800)]">Dashboard Shuby</p>
            </div>
          </div>
        </div>
      </div>

      <div class="absolute -right-2 bottom-8 sm:right-4 landing-float cursor-pointer"
           data-landing-touch-target="mascot">
        <%= image_tag "shuby/illustrations/mascot-sorriso-tall.png",
            alt: "Shuby mascotte",
            class: "w-20 sm:w-24 h-auto drop-shadow-md" %>
      </div>
    </div>
  </div>
```

- [ ] **Step 2: Add desktop layout to growth section**

In `app/views/static/_landing_growth.html.erb`, wrap the text and chart in a responsive flex:

After the opening `<section>` tag, change the structure to:

```erb
  <div class="lg:flex lg:items-center lg:gap-10">
    <div class="lg:flex-1">
      <p class="shuby-overline text-[var(--color-shuby-gray-700)] mb-2"
         data-scroll-reveal-target="item">MONITORAGGIO CRESCITA</p>

      <h2 class="font-display text-2xl font-bold text-[var(--color-shuby-blue-800)] mb-3"
          data-scroll-reveal-target="item">
        Curve di crescita WHO sempre a portata di mano
      </h2>

      <p class="font-sans text-sm text-[var(--color-shuby-gray-800)] mb-6 max-w-sm"
         data-scroll-reveal-target="item">
        Registra peso, altezza e circonferenza cranica. Visualizza i percentili del tuo bambino rispetto agli standard dell'Organizzazione Mondiale della Sanit&agrave;.
      </p>

      <%# Measurement type pills %>
      <div class="flex gap-3 mb-6 lg:mb-0" data-scroll-reveal-target="item">
        <% [
          { icon: "⚖️", label: "Peso", color: "shuby-blue-400" },
          { icon: "📏", label: "Altezza", color: "shuby-verde-200" },
          { icon: "🧠", label: "Testa", color: "shuby-giallo-400" }
        ].each do |m| %>
          <div class="flex items-center gap-1.5 px-3 py-1.5 bg-[var(--color-<%= m[:color] %>)] rounded-full">
            <span class="text-sm"><%= m[:icon] %></span>
            <span class="font-sans text-xs font-semibold text-[var(--color-shuby-gray-800)]"><%= m[:label] %></span>
          </div>
        <% end %>
      </div>
    </div>

    <%# Growth chart mockup %>
    <div class="lg:flex-1 rounded-2xl overflow-hidden border border-[var(--color-shuby-gray-500)] bg-white p-4"
         data-scroll-reveal-target="item"
         data-scroll-reveal-animation-value="landing-scale-in">
      <div class="aspect-[4/3] bg-gradient-to-br from-[var(--color-shuby-blue-300)] to-white rounded-xl flex items-center justify-center">
        <%= image_tag "shuby/illustrations/illustration-weight-chart.svg",
            alt: "Grafico percentili WHO esempio",
            class: "w-3/4 h-auto opacity-80" %>
      </div>
    </div>
  </div>
```

- [ ] **Step 3: Add desktop grid to milestones**

In `app/views/static/_landing_milestones.html.erb`, change the card grid classes from `grid grid-cols-2 gap-3` to:

```erb
<div class="grid grid-cols-2 lg:grid-cols-5 gap-3">
```

And remove the `col-span-2 max-w-[calc(50%-6px)] mx-auto` logic for the last card on desktop by updating the conditional class:

```erb
<div class="<%= 'col-span-2 lg:col-span-1 max-w-[calc(50%-6px)] lg:max-w-none mx-auto lg:mx-0' if i == areas.length - 1 %>"
```

- [ ] **Step 4: Verify desktop layout**

Open `http://localhost:3000` in a wide browser window (>1024px). Verify:
- Hero: text left, phone right, side-by-side
- Growth: text left, chart right
- Milestones: 5 cards in a single row
- Other sections scale gracefully

- [ ] **Step 5: Commit**

```bash
git add app/views/static/_landing_hero.html.erb app/views/static/_landing_growth.html.erb app/views/static/_landing_milestones.html.erb
git commit -m "feat: add desktop responsive layouts for landing page sections"
```

---

## Task 16: Final Verification

- [ ] **Step 1: Full test suite**

Run: `bin/rails test`

Expected: All tests pass, no regressions.

- [ ] **Step 2: RuboCop**

Run: `bin/rubocop`

Expected: No new offenses.

- [ ] **Step 3: Mobile verification**

Open Chrome DevTools → Device Mode → iPhone 14 Pro. Navigate to `/`. Verify:
- All sections render correctly stacked
- Scroll animations trigger smoothly
- Touch interactions work (mascot tap, card tilt, button press)
- Carousel swipes correctly with snap points
- No horizontal overflow

- [ ] **Step 4: Reduced motion verification**

In Chrome DevTools → Rendering → Emulate CSS media feature `prefers-reduced-motion: reduce`. Verify:
- No animations play
- All content is visible immediately
- Page is fully usable

- [ ] **Step 5: Old page verification**

Navigate to `/app-preview`. Verify the old landing renders exactly as before.

- [ ] **Step 6: Final commit if any fixes were needed**

If any fixes were made during verification:
```bash
git add -A
git commit -m "fix: landing page verification fixes"
```
