# Shuby Landing Page — Design Spec

## Contesto

Shuby manca di una landing page di presentazione convincente per nuovi utenti. La pagina attuale (`static#index`) e' funzionale ma basica — un hero con mascotte, feature list, e qualche card statica. Serve una landing page moderna, mobile-first, con animazioni touch-native che presenti tutti i benefici dell'app e convinca i genitori a scaricarla.

**Obiettivo**: Pagina di presentazione per il team Shuby, predisposta per distribuzione su app store. CTA principale "Scarica l'app" (store badges), facilmente convertibile in waitlist pre-lancio.

**Taglio comunicativo**: Empatico e autorevole — un amico competente che ti accompagna nei primi 1000 giorni.

**Direzione visiva**: Ibrida — alterna sezioni emotive (mascotte, illustrazioni Shuby) a sezioni con mockup reali dell'app e dati credibili (WHO, fonti mediche).

---

## Architettura tecnica

### Routing

- `GET /` — nuova landing page (sostituisce `static#index`)
- `GET /app-preview` — vecchia landing page, spostata qui per conservarla
- Controller: `StaticController` (azioni esistenti `index` + nuova `app_preview`)

### File da creare

```
app/views/static/index.html.erb                          # Nuovo (sostituisce il vecchio)
app/views/static/_landing_hero.html.erb                   # Sezione 1: Hero
app/views/static/_landing_trust.html.erb                  # Sezione 2: Trust bar
app/views/static/_landing_growth.html.erb                 # Sezione 3: Crescita WHO
app/views/static/_landing_milestones.html.erb             # Sezione 4: Tappe sviluppo
app/views/static/_landing_ai.html.erb                     # Sezione 5: AI chat demo
app/views/static/_landing_content.html.erb                # Sezione 6: Archivio articoli
app/views/static/_landing_report.html.erb                 # Sezione 7: Report pediatra
app/views/static/_landing_howto.html.erb                  # Sezione 8: Come funziona
app/views/static/_landing_cta.html.erb                    # Sezione 9: CTA finale + footer
app/javascript/controllers/scroll_reveal_controller.js    # IntersectionObserver per animazioni
app/javascript/controllers/landing_touch_controller.js    # Interazioni touch giocose
app/assets/tailwind/components/shuby/landing.css          # Stili e keyframes landing
```

### File da modificare

```
app/views/static/index.html.erb           # Riscrittura completa con nuove sezioni
app/controllers/static_controller.rb      # Aggiunta azione app_preview
config/routes.rb                          # Aggiunta route /app-preview
config/importmap.rb                       # Pin nuovi controller (se non auto-detected)
```

### File da spostare (vecchia landing → app_preview)

```
app/views/static/app_preview.html.erb     # Nuovo file, copia del vecchio index.html.erb
```

I partials `_section_*.html.erb` esistenti rimangono invariati — vengono referenziati da `app_preview.html.erb`.

### Dipendenze

**Zero dipendenze esterne.** Tutto implementato con:
- CSS `@keyframes` + `animation` per le animazioni
- CSS `scroll-snap-type: x mandatory` per i carousel
- Stimulus controller + `IntersectionObserver` per scroll-reveal
- CSS `transform` + `transition` per feedback touch
- CSS `prefers-reduced-motion: reduce` per accessibilita'

---

## Sezioni nel dettaglio

### 1. Hero — Above the fold

**Layout**: Full-width, gradiente azzurro pastello (`--color-shuby-blue-400` → `--color-shuby-blue-300`), forme organiche decorative in SVG.

**Contenuto**:
- Tag: "0-36 mesi" (badge bianco)
- Titolo (Baloo 2 Bold): "I primi 1000 giorni, insieme a te."
- Sottotitolo (Montserrat): "Crescita, sviluppo e consigli personalizzati — con un assistente AI dedicato."
- CTA: Badge App Store + Google Play affiancati
- Mockup iPhone con screenshot dashboard dall'app (immagine da Figma)
- Mascotte Shuby (mascot-sorriso-tall.png) posizionata accanto al telefono

**Animazioni**:
- Titolo e sottotitolo: fade-up staggered (0ms, 120ms)
- Mockup telefono: scale-in con leggero bounce (`cubic-bezier(0.34, 1.56, 0.64, 1)`, 600ms)
- Mascotte: float loop dolce (translateY ±8px, 3s infinite)
- Store badges: fade-up con delay 300ms
- **Touch**: tap sulla mascotte → wiggle (rotateZ ±5deg, 400ms) + cuoricino CSS che sale e svanisce

**Desktop**: layout side-by-side (testo a sinistra, mockup+mascotte a destra)
**Mobile**: stack verticale (testo → mockup centrato → CTA)

### 2. Trust Bar — Credibilita' immediata

**Layout**: Riga scrollabile orizzontale con 4 pillole su sfondo bianco.

**Contenuto** (icona + testo):
- "Standard WHO" (icona grafico)
- "100+ articoli" (icona documento)
- "AI medica" (icona chatbot)
- "5 aree sviluppo" (icona barefoot)

**Stile**: Bordo leggero `--color-shuby-blue-300`, border-radius 999px, padding 8px 16px, gap 12px. Scroll orizzontale con `-webkit-overflow-scrolling: touch`, scrollbar nascosta.

**Animazioni**: fade-up simultaneo al scroll-reveal, leggero stagger 80ms.

### 3. Crescita — Grafici WHO

**Layout**: Card bianca con mockup del grafico percentili a sinistra/sopra, testo descrittivo a destra/sotto.

**Contenuto**:
- Overline: "Monitoraggio crescita"
- Titolo (Baloo 2): "Curve di crescita WHO sempre a portata di mano"
- Testo: "Registra peso, altezza e circonferenza cranica. Visualizza i percentili del tuo bambino rispetto agli standard dell'Organizzazione Mondiale della Sanita'."
- Screenshot del grafico percentili dall'app (da Figma)
- Icone piccole: peso, altezza, testa — con valori esempio

**Animazioni**:
- Card: fade-up al scroll
- Grafico (se SVG inline): stroke-dashoffset draw-in animation (le linee percentili si disegnano progressivamente, 1.2s)
- Se screenshot: leggero scale-in 0.95→1 con fade

**Desktop**: split 50/50 (immagine | testo)
**Mobile**: stack (immagine sopra, testo sotto)

### 4. Tappe di Sviluppo — 5 Aree

**Layout**: Titolo + griglia di 5 card colorate, ciascuna per un'area di sviluppo.

**Contenuto**:
- Overline: "Sviluppo neuroevolutivo"
- Titolo: "5 aree, un quadro completo"
- Testo: "Questionari scientifici personalizzati per ogni fase dello sviluppo del tuo bambino."
- 5 Card con icona + nome area + breve descrizione:
  1. **Generale** — colore blue-400, "Crescita e benessere globale"
  2. **Comunicazione** — colore verde-200, "Linguaggio e interazione"
  3. **Motricita'** — colore fucsia (magenta-200), "Movimenti e coordinazione"
  4. **Cognizione** — colore giallo-400, "Apprendimento e problem solving"
  5. **Relazione** — colore blue-300, "Socialita' e legami affettivi"

**Animazioni**:
- Cards che appaiono con fade-up staggered (120ms ciascuna), creando un effetto "a cascata"
- **Touch**: tap su una card → leggero tilt 3D (perspective 600px, rotateY 3deg, 200ms) + ombra che si sposta

**Desktop**: griglia 3+2 o 5 colonne
**Mobile**: griglia 2+2+1 o scroll orizzontale

### 5. Shuby AI — Assistente 24/7

**Layout**: Card a sfondo scuro (gradiente `--color-shuby-blue-800` → `--color-shuby-blue-700`), simula una schermata di chat.

**Contenuto**:
- Icona chatbot in cerchio bianco/semi-trasparente
- Titolo (bianco): "Incontra Shuby"
- Sottotitolo: "Il tuo assistente AI per ogni domanda, 24 ore su 24"
- Chat demo con 2-3 scambi:
  - Utente: "Il mio bambino di 8 mesi non gattona ancora, e' normale?"
  - Shuby: "Assolutamente si'! Ogni bambino ha i suoi tempi. Il gattonamento inizia tipicamente tra i 7 e 10 mesi, ma alcuni bambini saltano questa fase completamente..."
  - Utente: "Ci sono esercizi che posso fare?"
  - Shuby: "Certo! Ecco 3 attivita' per stimolare il gattonamento..."
- Nota in basso: "Risposte basate su fonti mediche verificate"

**Animazioni** (attivate al scroll-reveal, in sequenza):
1. Titolo + icona: fade-up (0ms)
2. Prima bolla utente: slide-right + fade (400ms delay)
3. Typing dots: 3 pallini che pulsano (600ms delay, durata 1.5s)
4. Prima bolla Shuby: typing dots scompaiono, bolla appare con micro-bounce (2100ms delay)
5. Seconda bolla utente: slide-right (2800ms delay)
6. Seconda bolla Shuby: typing dots → bolla (3800ms delay)
- Tutta la sequenza dura ~4.5s, si attiva solo una volta

**Touch**: tap su una bolla → leggero pulse (scale 1.02, 200ms)

### 6. Archivio — Contenuti per ogni eta'

**Layout**: Titolo + carousel orizzontale di card articolo (snap-scroll).

**Contenuto**:
- Overline: "Archivio contenuti"
- Titolo: "100+ articoli basati sulla scienza"
- Testo: "Sonno, alimentazione, gioco, motricita', salute — filtrati per l'eta' del tuo bambino."
- 4-5 card articolo nel carousel:
  - Thumbnail colorato (bg pastello + illustrazione mascot)
  - Tag categoria (es. "Sonno", "Alimentazione")
  - Fascia eta' (es. "0-6 mesi")
  - Titolo articolo
  - Durata lettura

**Stile carousel**: `overflow-x: auto`, `scroll-snap-type: x mandatory`, `scroll-snap-align: start`, scrollbar nascosta, gap 12px. Card width: ~280px.

**Animazioni**:
- Titolo: fade-up al scroll
- Cards: stagger fade-up leggero
- **Touch**: swipe nativo CSS snap, feedback visivo sulla card in drag (leggera ombra)

### 7. Report Pediatra — PDF pronto

**Layout**: Sezione compatta, sfondo chiaro (`--color-shuby-blue-300`), mockup del PDF affiancato al testo.

**Contenuto**:
- Icona documento
- Titolo: "Un report pronto per il pediatra"
- Testo: "Genera un PDF completo con misurazioni, tappe raggiunte e domande — da condividere al prossimo appuntamento."
- Mockup semplificato del PDF (card bianca con preview: nome bambino, grafico mini, checklist)
- Badge: "Condividi via email o WhatsApp"

**Animazioni**: fade-up semplice al scroll. Il mockup PDF fa un leggero scale-in.

### 8. Come Funziona — 3 Step

**Layout**: 3 step verticali collegati da una linea tratteggiata.

**Contenuto**:
1. **Scarica l'app** — icona phone + "Disponibile su App Store e Google Play"
2. **Crea il profilo** — icona baby + "Aggiungi nome, data di nascita e inizia"
3. **Monitora e cresci** — icona grafico + "Shuby ti guida giorno per giorno"

**Stile**: Cerchi numerati (1, 2, 3) con colori brand (blue, verde, fucsia), linea verticale tratteggiata tra i cerchi, testo a destra del cerchio.

**Animazioni** (scroll-triggered, sequenziali):
- Linea tratteggiata che si "disegna" dall'alto in basso (stroke-dashoffset, 800ms)
- Cerchi che appaiono con scale-in + fade al passaggio della linea (stagger 300ms)
- Testo che appare con fade-up in sync col cerchio

### 9. CTA Finale + Footer

**Layout**: Due parti — CTA emozionale + footer minimale.

**CTA**:
- Sfondo: gradiente blu pastello
- Mascotte Shuby che saluta (mascot-centered.svg o mascot-sorriso.png)
- Titolo: "Ogni giorno conta. Inizia oggi."
- Badge App Store + Google Play
- Testo secondario: "Gratuito. Nessuna carta di credito richiesta."

**Footer**:
- Logo Shuby piccolo
- Link: Privacy · Termini · Contatti
- Copyright

**Animazioni**: fade-up per il CTA. Mascotte con float loop.

---

## Stimulus Controllers

### `scroll_reveal_controller.js`

Controller riutilizzabile per animazioni on-scroll. Si applica a qualsiasi elemento con `data-controller="scroll-reveal"`.

**Attributi**:
- `data-scroll-reveal-animation-value`: classe CSS da aggiungere (default: `"landing-fade-up"`)
- `data-scroll-reveal-stagger-value`: delay in ms tra figli (default: `0`)
- `data-scroll-reveal-threshold-value`: soglia IntersectionObserver (default: `0.15`)
- `data-scroll-reveal-once-value`: animare solo la prima volta (default: `true`)

**Comportamento**:
- All'init, aggiunge `opacity: 0` agli elementi target
- Quando l'elemento entra nel viewport, aggiunge la classe di animazione
- Se `stagger > 0`, applica `animation-delay` incrementale ai figli diretti
- Rispetta `prefers-reduced-motion`: se attivo, mostra tutto senza animazione

### `landing_touch_controller.js`

Controller per micro-interazioni touch.

**Targets**:
- `tiltable`: elementi con tilt 3D al tap
- `pressable`: elementi con scale-down al press
- `mascot`: mascotte con wiggle + cuoricino al tap

**Comportamento**:
- `tiltable`: `touchstart` → aggiunge classe `landing-tilt`, `touchend` → rimuove dopo 200ms
- `pressable`: `touchstart` → `transform: scale(0.95)`, `touchend` → reset
- `mascot`: `click` → wiggle animation + spawn elemento cuoricino che sale con fade-out

---

## CSS Keyframes (`landing.css`)

```css
/* Reveal animations */
@keyframes landing-fade-up { from { opacity: 0; transform: translateY(24px); } to { opacity: 1; transform: translateY(0); } }
@keyframes landing-scale-in { from { opacity: 0; transform: scale(0.88); } to { opacity: 1; transform: scale(1); } }
@keyframes landing-scale-bounce { from { opacity: 0; transform: scale(0.85); } to { opacity: 1; transform: scale(1); } }
  /* con easing: cubic-bezier(0.34, 1.56, 0.64, 1) */

/* Loop animations */
@keyframes landing-float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
@keyframes landing-wiggle { 0%,100% { transform: rotate(0); } 25% { transform: rotate(-5deg); } 75% { transform: rotate(5deg); } }

/* Chat-specific */
@keyframes landing-typing-dot { 0%,60%,100% { opacity: 0.3; transform: scale(0.8); } 30% { opacity: 1; transform: scale(1); } }
@keyframes landing-chat-bubble { from { opacity: 0; transform: translateY(8px) scale(0.95); } to { opacity: 1; transform: translateY(0) scale(1); } }

/* Draw-in per grafici/linee */
@keyframes landing-draw-line { from { stroke-dashoffset: var(--dash-length, 200); } to { stroke-dashoffset: 0; } }

/* Step line */
@keyframes landing-draw-down { from { height: 0; } to { height: 100%; } }

/* Heart float (mascot tap) */
@keyframes landing-heart-float { 0% { opacity: 1; transform: translateY(0) scale(1); } 100% { opacity: 0; transform: translateY(-40px) scale(0.6); } }

/* Touch feedback */
.landing-tilt { transform: perspective(600px) rotateY(3deg); transition: transform 0.2s ease; }
```

Tutte le animazioni hanno `animation-fill-mode: both` e durata 400-600ms salvo dove specificato.

---

## Responsive

**Mobile (< 640px)** — Design primario:
- Stack verticale per tutte le sezioni
- Hero: testo → mockup → CTA centrato
- Feature cards: griglia 2 colonne
- Carousel articoli: swipe orizzontale full-width
- Padding: 16px laterale
- Font hero: shuby-h1 (38px)

**Tablet (640-1024px)**:
- Hero: side-by-side leggero
- Feature cards: griglia 3 colonne
- Padding: 24px laterale

**Desktop (> 1024px)**:
- Max-width: 1080px centrato
- Hero: split 50/50 (testo | mockup)
- Feature sections: alternano immagine sx/dx
- Carousel diventa griglia visibile

---

## Screenshots da Figma

Le seguenti schermate vanno esportate dal file Figma (`Shuby_App`) come immagini PNG @2x e salvate in `app/assets/images/shuby/landing/`:

1. `screenshot-dashboard.png` — Dashboard principale con saluto e card
2. `screenshot-growth-chart.png` — Grafico percentili WHO
3. `screenshot-questionnaire.png` — Schermata questionario
4. `screenshot-chat.png` — Chat con Shuby AI
5. `screenshot-archive.png` — Archivio articoli

Se le schermate non sono immediatamente disponibili, creare placeholder HTML/CSS stilizzati con lo stesso look dell'app (colori brand, icone, testo finto) — non semplici box grigi. I placeholder devono essere visivamente gradevoli anche da soli. Saranno sostituiti con screenshot reali quando disponibili.

---

## Accessibilita'

- `prefers-reduced-motion: reduce` → nessuna animazione, tutti gli elementi visibili
- Semantic HTML: `<section>`, `<nav>`, `<article>`, heading hierarchy corretta
- Alt text su tutte le immagini e mockup
- Touch targets minimo 44x44px
- Contrasto WCAG AA su tutti i testi
- Skip-to-content link nascosto ma accessibile via keyboard
- `aria-hidden="true"` su elementi decorativi (forme SVG, mascotte)

---

## Verifica

1. `bin/rails test` — nessun test rotto
2. `bin/rubocop` — nessuna violazione
3. Navigare a `/` — nuova landing page funzionante
4. Navigare a `/app-preview` — vecchia landing page preservata
5. Test mobile: Chrome DevTools → device mode → iPhone 14 Pro
6. Verificare animazioni scroll su mobile
7. Verificare `prefers-reduced-motion` disabilitando animazioni nel browser
8. Test touch interactions su device reale o emulatore
9. Verificare che utenti autenticati vanno al dashboard (`authenticated :user` root rimane `dashboard#show`), utenti non autenticati vedono la nuova landing
10. Verificare che `/app-preview` funzioni sia per utenti autenticati che non
