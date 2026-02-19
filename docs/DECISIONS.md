# Decisioni di Prodotto — Shuby v1.0

> Questo documento raccoglie le decisioni prese durante gli incontri con il cliente (Set 2024 – Gen 2026)
> che **non sono presenti** o **contraddicono** le specifiche di prodotto.
>
> **Precedenza**: Quando questo documento contraddice le specifiche (`Shuby 1.0 - Specifiche di Prodotto.md`
> o `Analisi Funzionale v.1.0`), **questo documento ha la precedenza**.

---

## Profilo Bambino

### DEC-001: Sesso alla nascita — opzioni aggiornate
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — campo "Sesso" (F / M / Preferisco non dirlo)
- **Decisione**: Le opzioni per il sesso alla nascita sono: **M / F / INTERSEX**. L'opzione "Preferisco non dirlo" viene rimossa.
- **Stato**: da-fare
- **Impatto**: `app/models/child.rb` (validazione enum), form di creazione/modifica bambino, fixtures

### DEC-002: Lingua — solo bilinguismo sì/no
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — campo lingua principale dettagliato nell'onboarding
- **Decisione**: Non chiedere la lingua principale dettagliata. Chiedere solo se il bambino è esposto a più lingue con opzioni: **monolingue / bilingue / trilingue / quattro o più lingue**.
- **Stato**: da-fare
- **Impatto**: `app/models/child.rb`, onboarding flow, form bambino

### DEC-003: Tipo di relazione del caregiver
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Aggiungere un campo per il tipo di relazione del caregiver con il bambino: **papà / mamma / altro**.
- **Stato**: da-fare
- **Impatto**: `app/models/user.rb` o `app/models/account_user.rb`, onboarding, profilo utente

### DEC-004: Un solo caregiver per account in v1.0
- **Data**: 2026-01-28
- **Sovrascrive**: Modifica scope
- **Decisione**: Nella v1.0 ogni account ha un solo caregiver. La gestione multi-caregiver è rimandata a versioni successive.
- **Stato**: da-fare
- **Impatto**: Modello `Account`, logica di inviti, UI gestione account

---

## AI Chat (Shuby Assistant)

### DEC-005: Limite chat gratuita — 30 messaggi/mese
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — 10 domande/mese per utenti free
- **Decisione**: Il limite per gli utenti gratuiti è di **30 messaggi al mese** (non 10 domande).
- **Stato**: da-confermare
- **Impatto**: `app/services/shuby_assistant_service.rb`, logica di gating, contatore messaggi

### DEC-006: Memoria conversazionale persistente per utenti Premium
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Gli utenti Premium hanno **contesto persistente tra le sessioni di chat**. Il chatbot ricorda le conversazioni precedenti per offrire risposte più personalizzate.
- **Stato**: da-fare
- **Impatto**: `app/models/shuby_chat.rb`, `app/services/shuby_assistant_service.rb`, system prompt, logica di contesto

### DEC-007: Architettura chatbot specializzati — dispatcher generalista
- **Data**: 2024-09-23
- **Sovrascrive**: Non presente nelle specifiche (che menziona 7 chatbot separati)
- **Decisione**: Un **chatbot generalista** che smista (dispatch) verso specialisti, non 7 chatbot separati. L'utente interagisce con un unico punto di accesso.
- **Stato**: da-fare
- **Impatto**: `app/services/shuby_assistant_service.rb`, architettura tools, system prompt

### DEC-008: Collegamento chatbot → articoli in-app
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Il chatbot deve **linkare agli articoli presenti nell'app** quando pertinenti. Gli articoli a loro volta devono **linkare alle fonti internazionali** di riferimento.
- **Stato**: da-fare
- **Impatto**: `app/tools/file_search_tool.rb`, `app/models/archive_content.rb`, risposte chatbot

---

## Milestone e Sviluppo

### DEC-009: Terminologia — "Stage di sviluppo" non "Milestone"
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — terminologia interna "milestone"
- **Decisione**: In inglese usare **"Development STAGE"** anziché "milestone". In italiano mantenere la terminologia esistente ("tappe di sviluppo" o equivalente).
- **Stato**: da-fare
- **Impatto**: Traduzioni EN, documentazione, API responses

### DEC-010: Flusso completamento milestone
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Al completamento di una tappa, mostrare: (1) **"Report clinico aggiornato"**, (2) **link per scaricare il report**, (3) **link all'AI helper** o alle **attività di stimolazione**.
- **Stato**: da-fare
- **Impatto**: Controller questionari, viste completamento, generazione PDF

### DEC-011: Milestone saltate — skip al periodo corrente
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Se una tappa non viene completata entro il periodo previsto, viene **saltata** e si passa direttamente alle tappe del **periodo corrente** del bambino.
- **Stato**: da-fare
- **Impatto**: Logica di selezione questionari, `app/models/questionnaire.rb`, timeline

### DEC-012: Proposta intelligente delle milestone
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: L'app propone le **tappe più rilevanti** basandosi sui risultati precedenti, non seguendo un ordine puramente sequenziale.
- **Stato**: da-confermare
- **Impatto**: Algoritmo di selezione questionari, modello AI, logica di raccomandazione

### DEC-013: Milestone nascoste — rimandato a post-v1.0
- **Data**: 2026-01-28
- **Sovrascrive**: Modifica scope
- **Decisione**: Le milestone nascoste (trigger da definire con Azia) sono **rimandate a dopo la v1.0**.
- **Stato**: rimandato
- **Impatto**: Nessuno per v1.0

---

## Report e PDF

### DEC-014: Report PDF per periodo
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche (chiarimento)
- **Decisione**: Il report per il pediatra è **per periodo**. Tipicamente si condivide solo il **report più recente** con il pediatra.
- **Stato**: da-fare
- **Impatto**: Generazione PDF, UI lista report, controller report

---

## Pricing e Contenuti

### DEC-015: Contenuti di qualità restano gratuiti
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — 20 articoli free / 100+ premium
- **Decisione**: I **contenuti di qualità** (articoli, risorse) devono restare **gratuiti** e non essere bloccati dietro paywall. Il premium si differenzia per altre funzionalità.
- **Stato**: da-confermare
- **Impatto**: `app/models/archive_content.rb`, logica di gating contenuti, policy Pundit

### DEC-016: Abbonamenti regalo
- **Data**: 2024-09-23
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Supportare la possibilità di **regalare un abbonamento** (es. regalo alla nascita). Meccanismo esatto da definire.
- **Stato**: da-fare
- **Impatto**: Billing, Pay gem, UI regalo, codici promozionali

---

## Internazionalizzazione (i18n)

### DEC-017: Lingue v1.0 — IT + EN + FR
- **Data**: 2026-01-28
- **Sovrascrive**: Specifiche di prodotto — solo italiano per v1.0, inglese dal Q2 2026
- **Decisione**: La v1.0 deve supportare **italiano, inglese e francese** fin dal lancio.
- **Stato**: da-confermare
- **Impatto**: File i18n (`config/locales/`), UI language switcher, contenuti tradotti, test

---

## Privacy e Dati

### DEC-018: Opt-in partecipazione dati utente
- **Data**: 2026-01-28
- **Sovrascrive**: Non presente nelle specifiche
- **Decisione**: Chiedere agli utenti se vogliono **partecipare al miglioramento del prodotto** condividendo dati anonimi di utilizzo.
- **Stato**: da-fare
- **Impatto**: Onboarding/settings, modello User (flag opt-in), privacy policy, analytics

---

## Scope Rimandato

### DEC-019: Tracciamento qualità del sonno — rimandato
- **Data**: 2026-01-28
- **Sovrascrive**: Modifica scope
- **Decisione**: Il tracciamento della qualità del sonno è **rimandato** a una versione successiva.
- **Stato**: rimandato
- **Impatto**: Nessuno per v1.0

---

## Decisioni da Confermare

Le seguenti decisioni presentano **contraddizioni** tra le specifiche e le note degli incontri.
Richiedono conferma con i fondatori prima dell'implementazione.

| ID | Tema | Conflitto | Azione |
|----|------|-----------|--------|
| DEC-005 | Limite chat gratuita | Spec: 10 domande/mese vs Incontro: 30 messaggi/mese | Confermare il limite finale |
| DEC-012 | Proposta intelligente milestone | Quanto AI-driven vs sequenziale per v1.0? | Definire scope v1.0 |
| DEC-015 | Contenuti gratuiti | Spec: 20 free / 100+ premium vs Incontro: contenuti di qualità gratis | Chiarire cosa resta gratuito |
| DEC-017 | Lingue v1.0 | Spec: solo IT, EN dal Q2 2026 vs Incontro: IT+EN+FR dal lancio | Confermare lingue al lancio |
