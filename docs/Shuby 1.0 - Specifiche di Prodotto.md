# **ALLEGATO A**

# **Shuby 1.0 \- Specifiche di Prodotto**

Versione: 1.0  
Data: Novembre 2025  
Destinatari: Founder, Team di Sviluppo, Stakeholder

## **📋 Indice**

1. [Visione e Obiettivi](#1.-visione-e-obiettivi)  
2. [Architettura Tecnica](#2.-architettura-tecnica)  
3. [Funzionalità Core v1.0](#3.-funzionalità-core-v1.0)  
4. [Modello Freemium](#4.-modello-freemium)  
5. [Requisiti Non Funzionali](#5.-requisiti-non-funzionali)  
6. [Fuori Perimetro v1.0](#6.-fuori-perimetro-v1.0)  
7. [Roadmap Post-Lancio](#7.-roadmap-post-lancio)  
8. [Metriche di Successo](#8.-metriche-di-successo)

## **1\. Visione e Obiettivi** {#1.-visione-e-obiettivi}

### **1.1 Cos'è Shuby 1.0**

Shuby è l'applicazione completa che accompagna i genitori nei primi 1000 giorni di vita del bambino (0-36 mesi), offrendo:

* 📊 Monitoraggio dello sviluppo attraverso tappe scientificamente validate  
* 🤖 Assistente AI conversazionale per rispondere a domande basato su knowledge base scientifica  
* 📈 Tracciamento crescita con misurazioni e percentili  
* 📚 Biblioteca di contenuti evidence-based personalizzati  
* 👨‍⚕️ Report per pediatra esportabili e condivisibili  
* 🎯 Consigli personalizzati basati su età, famiglia e contesto

### **1.2 Obiettivi del Lancio v1.0**

Obiettivo Primario: Creare una base solida e funzionale dell'app che copra le esigenze fondamentali dei genitori con gravidanza fisiologica e bambini nati a termine.

Obiettivi Specifici:

* ✅ Offrire un'esperienza utente completa e funzionale  
* ✅ Validare il modello freemium  
* ✅ Raggiungere 1.000+ utenti registrati entro Q2 2026  
* ✅ Ottenere conversione freemium→premium dell'1%  
* ✅ Costruire un'architettura scalabile per future estensioni

### **1.3 Utenti Target**

Primari:

* Genitori di bambini 0-36 mesi  
* Famiglie con gravidanza fisiologica e bambini nati a termine  
* Parlanti italiano

Secondari (da supportare in futuro):

* Famiglie con casistiche speciali (prematuri, adozione, affido, PMA)  
* Caregivers e parenti  
* Utenti internazionali (inglese e altre lingue)

### **1.4 Differenziazione dal Mercato**

| Caratteristica | Shuby | Competitor |
| ----- | ----- | ----- |
| Focus | Family-centered, percorsi personalizzati | Generici o solo tracking |
| Base Scientifica | Knowledge base validata con citazioni | Contenuti generici |
| AI Conversazionale | RAG con fonti scientifiche | Assente o generico |
| Supporto Casistiche | Prematuri, adozione, bilinguismo, ecc. | Visione standard |
| Integrazione Pediatra | Report PDF strutturati | Limitata o assente |

## **2\. Architettura Tecnica** {#2.-architettura-tecnica}

### **2.1 Stack Tecnologico**

Framework Principal: Ruby on Rails 8.1

* Backend API robusto e scalabile  
* Gestione utenti, autenticazione, database  
* Sistema di internazionalizzazione (i18n) nativo

App Mobile: Hotwire Native

* iOS: App nativa generata da Hotwire Native  
* Android: App nativa generata da Hotwire Native  
* Web: Progressive Web App (PWA)  
* Condivisione del 95% del codice tra piattaforme

Vantaggi:

* ✅ Sviluppo più rapido (un solo codebase per 3 piattaforme)  
* ✅ Manutenzione semplificata  
* ✅ Time-to-market ridotto  
* ✅ Costi di sviluppo contenuti

### **2.2 Database e Struttura**

Database: PostgreSQL

* Supporto multilingua tramite tabelle traduzioni  
* Architettura preparata per casistiche multiple  
* Scalabilità verticale e orizzontale

Strutture Dati Chiave:

```
- Users (utenti/genitori)
- Children (bambini con profili completi)
- Families (composizione famiglia)
- Milestones (tappe di sviluppo)
- Measurements (misurazioni crescita)
- Questionnaires (questionari compilati)
- Articles (contenuti editoriali)
- AI_Conversations (storico chat)
```

### **2.3 Integrazione AI**

Provider: OpenAI (gpt-5.4-mini o superiore)

* Sistema RAG (Retrieval Augmented Generation)  
* Vector store con knowledge base scientifica  
* Citazioni automatiche delle fonti

Sicurezza:

* API key lato server (non esposta al client)  
* Rate limiting per utente  
* Logging delle conversazioni per qualità

### **2.4 Internazionalizzazione**

Sistema i18n:

* Rails i18n per tutte le stringhe UI  
* Database strutturato per contenuti multilingua  
* Supporto facile aggiunta nuove lingue

v1.0: Solo Italiano  
Post-v1.0: Inglese, Spagnolo, Francese, etc.

## **3\. Funzionalità Core v1.0** {#3.-funzionalità-core-v1.0}

### **3.1 Registrazione e Onboarding**

#### **3.1.1 Creazione Account**

* Email \+ password  
* OAuth (Google, Apple) opzionale  
* Conferma email  
* Accettazione privacy policy

#### **3.1.2 Onboarding Personalizzato**

Modalità Veloce (5 domande \- 2 minuti):

1. Nome/nickname genitore  
2. Nome bambino \+ data di nascita  
3. Sesso alla nascita  
4. Settimane di gestazione (dropdown semplice: \<37 / ≥37 a termine)  
5. Lingua principale in casa

Modalità Completa (disponibile dopo o durante onboarding):

Dati Famiglia:

* Nazionalità e paese di residenza  
* Lingua madre  
* Tipo famiglia (biparentale, monogenitoriale, altro)  
* Numero bambini e relative età  
* Quante lingue parlate in casa

Dati Bambino (per ogni figlio):

* Nome/nickname  
* Data nascita  
* Parto gemellare/multiplo (Sì/No)  
* Sesso alla nascita (F/M/Preferisco non dirlo)  
* Età gestazionale (settimane dettagliate)  
* Peso alla nascita (grammi)  
* Tipo gravidanza (fisiologica/FIV/altro)  
* Ricovero post-nascita (Sì/No)  
* Complicazioni (lista multi-selezione)  
* Screening uditivo (Pass/Refer/Non fatto)  
* Screening visivo (fatto/non fatto)  
* Alimentazione attuale (allattamento/formula/misto)  
* Svezzamento iniziato (Sì/No \+ dettagli)  
* Sonno medio (ore/24h)  
* Qualità sonno (multi-selezione)  
* Tempo gioco/attività (minuti/giorno)

Contesto Familiare:

* Con chi trascorre più tempo il bambino  
* Caratteristiche ereditarie note (difficoltà linguaggio, attenzione, comportamento, etc.)

🔑 Principio Chiave: L'utente può completare l'onboarding veloce subito e arricchire il profilo in qualsiasi momento dall'app.

### **3.2 Dashboard "Oggi"**

La dashboard è la home dell'app, personalizzata giorno per giorno in base a:

* Età del bambino  
* Tappe in corso  
* Stagionalità  
* Storico attività

#### **Sezioni Dashboard:**

1\. Intestazione Personalizzata

```
"Ciao Federica 👋
Alessandro - 1 mese e 2 settimane"
```

2\. Focus del Giorno Box evidenziato con consiglio/milestone rilevante:

```
"💡 Sta arrivando il sorriso sociale

Garantisci al tuo bambino almeno 30 minuti totali 
di tummy time al giorno. Usa la tua voce e i canti 
e ricorda niente schermi."
```

3\. Tappe di Sviluppo in Corso Card con:

* Area (es. "Comunicazione e linguaggio")  
* Fase corrente (es. "Mese 1")  
* Progresso (es. "Completate 2/6")  
* CTA per continuare questionario

4\. Attività Suggerite 2-3 attività brevi (\~5 min) personalizzate:

```
"🎵 Tummy time musicale" - 5 MIN
"👐 Massaggio mani e piedi" - 5 MIN
```

5\. Articoli e Consigli del Giorno

* 2-3 articoli rilevanti con immagine preview  
* Tag età e tempo lettura  
* Tematiche: sonno, alimentazione, motricità, etc.

6\. Misurazioni da Tracciare Promemoria gentile:

```
"📊 Ricorda di tracciare:
- Circonferenza cranica (aggiornata 15 giorni fa)"
```

7\. Linee Guida 24 Ore Tabella compatta personalizzata per età:

```
Movimento: ≥30 min tummy time
Sonno: 12-16h
Schermi: Sconsigliati
```

### **3.3 Timeline di Sviluppo**

Navigazione per settimane (0-52) e mesi (1-36), visualizzata come:

```
[Sett 3] [Sett 4] [Sett 5] [Sett 6] ... [Mese 3] [Mese 4]
```

#### **Contenuti per Ogni Periodo:**

1\. Descrizione Fase Testo narrativo su cosa aspettarsi, esempi:

```
"Settimana 6
Aumenta il controllo del capo in posizione prona 
e l'interesse per i contrasti. Allunga un po' il 
tummy time e descrivi ciò che osserva."
```

2\. Linee Guida 24 Ore Tabella personalizzata per fascia età con:

* Movimento consigliato  
* Sonno (ore)  
* Sedentarietà di qualità  
* Schermi (limiti)

3\. Focus Sviluppo

* Motricità: cosa sta imparando  
* Comunicazione: vocalizzi, sguardi  
* Cognizione: interessi, gioco  
* Relazione: interazioni sociali

4\. Link a Contenuti

* Articoli rilevanti per l'età  
* Attività suggerite  
* Video-guide (se premium)

Freemium vs Premium:

* Free: Accesso a settimane correnti ±2  
* Premium: Accesso completo a tutte le 0-36 settimane/mesi

### **3.4 Tappe di Sviluppo & Questionari**

#### **3.4.1 Aree Coperte (tutte in v1.0)**

1. Generale \- Sviluppo olistico e milestone fondamentali  
2. Comunicazione e Linguaggio \- Vocalizzi, parole, comprensione  
3. Motricità \- Motricità grossolana e fine  
4. Cognizione e Attenzione \- Problem solving, memoria, focus  
5. Relazione e Regolazione \- Attaccamento, emozioni, autoregolazione

#### **3.4.2 Struttura Questionari**

Organizzazione:

* Questionari specifici per fascia età (es. 0-3 mesi, 3-6 mesi, etc.)  
* Domande multiple choice basate su osservazioni quotidiane  
* Esempi pratici e descrizioni chiare

Esempio Domanda:

```
"Emette suoni diversi dal pianto 
(es. 'ehh', 'uhh')?"

[ ] Sì
[ ] No  
[ ] Non lo so
```

Tracciamento:

* Progressione mostrata (es. "Completate 2/6")  
* Storico risposte salvato  
* Possibilità di ripetere nel tempo per trend

#### **3.4.3 Feedback e Alert**

Sistema Alert Gentili:

* Non giudicanti  
* Focus su osservazione, non diagnosi  
* Suggerimenti di approfondimento

Esempio:

```
"🔔 Alcune risposte suggeriscono di osservare 
con più attenzione la comunicazione.

Cosa puoi fare:
- Leggi l'articolo 'Primi vocalizzi'
- Parla con l'AI-Helper
- Condividi con il pediatra durante la visita
```

🚨 Importante: Shuby non fa diagnosi, solo osservazione guidata.

#### **3.4.4 Report Crescita**

Visualizzazioni:

* Timeline con tappe completate  
* Grafici radar per aree  
* Trend temporale (se ripetuti)

Export:

* Incluso in PDF per pediatra

### **3.5 Misurazioni & Crescita**

#### **3.5.1 Dati Tracciabili**

Obbligatori:

* Peso (grammi)  
* Altezza/Lunghezza (cm)  
* Circonferenza cranica (cm)

Opzionali (future):

* Peso pre/post poppata  
* Temperatura  
* Note libere

#### **3.5.2 Inserimento Dati**

UI Semplice:

* Tastierino numerico ottimizzato  
* Data e ora registrazione  
* Note opzionali  
* Foto opzionale (es. bilancia)

#### **3.5.3 Visualizzazioni**

1\. Lista Storica

```
Peso - 25.08.2025 h.10:34
3900 gr - 50° percentile
[Aggiorna] [Icon]
```

2\. Grafici Crescita

* Curve percentili OMS sovraimposte  
* Zoom temporale (1 mese, 3 mesi, 6 mesi, tutto)  
* Indicatore percentile attuale

3\. Percentili

* Calcolo automatico basato su età, sesso e misura  
* Indicatore visivo (es. colori verde/giallo/rosso)  
* Spiegazione contestuale

Freemium vs Premium:

* Free: Inserimento base \+ grafici semplici  
* Premium: Grafici avanzati, confronti, export dettagliati

### **3.6 AI-Helper**

L'AI-Helper è il chatbot conversazionale basato su RAG con knowledge base scientifica.

#### **3.6.1 Funzionalità**

1\. Chat Conversazionale

* Domande in linguaggio naturale  
* Risposte contestuali e personalizzate  
* Supporto follow-up

2\. RAG (Retrieval Augmented Generation)

* Ricerca semantica nella knowledge base  
* Citazioni automatiche delle fonti  
* Snippet di testo dai documenti

3\. Personalizzazione

* Risposte adattate all'età del bambino  
* Riferimenti al nome del bambino  
* Contesto dalla profilazione

4\. Storico Conversazioni

* Tutte le chat salvate  
* Ricerca nelle conversazioni passate  
* Possibilità di continuare chat

#### **3.6.2 Knowledge Base**

Contenuti:

* Articoli scientifici validati  
* Linee guida OMS, SIP, AAP  
* Schede per genitori  
* Best practices evidence-based

Copertura:

* 0-36 mesi tutte le fasi  
* Tutte le 5 aree sviluppo  
* Temi: sonno, alimentazione, gioco, salute, etc.

Aggiornamenti:

* Knowledge base aggiornabile senza deploy app  
* Versioning dei contenuti  
* Processo di revisione scientifica

#### **3.6.3 Limitazioni**

Disclaimer Sempre Visibile:

```
"⚕️ Consulta sempre il pediatra per situazioni 
specifiche del tuo bambino"
```

Cosa NON fa:

* ❌ Diagnosi mediche  
* ❌ Prescrizioni farmacologiche  
* ❌ Gestione emergenze  
* ❌ Sostituzione consulto medico

Redirect: Se domanda su emergenza o sintomi gravi → suggerire contatto pediatra/112

#### **3.6.4 Freemium vs Premium**

Free:

* 10 domande/mese  
* Chatbot generale  
* Citazioni base

Premium:

* Domande illimitate  
* 7 chatbot specializzati per area  
* Citazioni estese con snippet

### **3.7 Biblioteca Articoli & Consigli**

#### **3.7.1 Organizzazione**

Categorie:

1. 💤 Sonno  
2. 🍼 Alimentazione  
3. 🤸 Motricità  
4. 💬 Comunicazione  
5. 🧠 Cognizione  
6. ❤️ Benessere Famiglia  
7. 👨‍⚕️ Salute e Prevenzione  
8. 🎨 Gioco e Attività

Filtri:

* Per età (0-3m, 3-6m, 6-9m, etc.)  
* Per categoria  
* Per durata lettura (\< 5min, 5-10min, \>10min)  
* Preferiti/Salvati

#### **3.7.2 Formato Articoli**

Struttura Standard:

```
Titolo Accattivante
[Immagine header]

Tag: [Età] [Categoria] [Tempo lettura]

Introduzione breve e chiara

Sottotitoli e sezioni
- Contenuto evidence-based
- Consigli pratici
- Esempi concreti

💡 Box evidenziati con tip chiave

📚 Fonti e riferimenti
```

Esempi:

* "Tummy Time: La Guida Completa (0-12 mesi)"  
* "Il Primo Sorriso: Cosa Aspettarsi"  
* "Sonno Sicuro: Le Regole d'Oro"

#### **3.7.3 Consigli Pratici**

Schede Quick-Start:

* Attività 5 minuti  
* Liste checklist  
* Guide step-by-step  
* Video brevi (premium)

Freemium vs Premium:

* Free: 20-30 articoli selezionati base  
* Premium: Biblioteca completa (100+ articoli), video-corsi, webinar

### **3.8 Report per Pediatra**

#### **3.8.1 Generazione PDF**

Contenuti Report:

1. Intestazione  
   * Nome bambino, data di nascita  
   * Età corrente (corretta se prematuro)  
   * Data generazione report  
2. Informazioni Generali  
   * Dati nascita (peso, altezza, GA, complicazioni)  
   * Alimentazione attuale  
   * Sonno medio  
   * Contesto familiare rilevante  
3. Misurazioni Crescita  
   * Tabella misurazioni recenti  
   * Grafici percentili (ultimo mese/3 mesi)  
   * Alert se fuori range  
4. Tappe di Sviluppo  
   * Riassunto per area (Generale, Comunicazione, Motricità, etc.)  
   * Tappe completate vs attese  
   * Alert se ritardi osservati  
5. Questionari Completati  
   * Lista questionari con data e risultato  
   * Evidenza di eventuali aree da approfondire  
6. Domande per il Pediatra  
   * Lista auto-generata o inserita dal genitore  
   * Spazio per note durante visita  
7. Note Libere  
   * Campo aperto per osservazioni genitore

Formato:

* PDF professionale e leggibile  
* Logo Shuby \+ disclaimer  
* Layout chiaro, stampa-friendly

#### **3.8.2 Condivisione**

Modalità:

* Export PDF → Share OS (email, WhatsApp, etc.)  
* QR code per accesso rapido (futuro)  
* Possibilità invio diretto email al pediatra (futuro)

Privacy:

* Genitore sceglie cosa includere  
* Generazione on-demand  
* Dati non condivisi automaticamente

Freemium vs Premium:

* Free: Report base con dati essenziali  
* Premium: Report avanzato con grafici, analisi trend, note dettagliate

### **3.9 Gestione Account & Famiglia**

#### **3.9.1 Profilo Utente**

Dati Modificabili:

* Nome/nickname  
* Email (con conferma)  
* Password  
* Foto profilo  
* Lingua preferita  
* Impostazioni notifiche

#### **3.9.2 Gestione Famiglia**

Bambini:

* Aggiungere bambini (multi-profilo)  
* Modificare dati bambino  
* Archiviare bambino (se \>36 mesi o altro)  
* Eliminare bambino (con conferma)

Altri Caregiver:

* Aggiungere adulti (es. partner, nonni)  
* Ruoli (genitore 1, genitore 2, caregiver)  
* Condivisione accesso (futuro)

#### **3.9.3 Impostazioni**

Privacy:

* Gestione dati personali  
* Export dati (GDPR compliance)  
* Eliminazione account

Notifiche:

* Push notifications (on/off)  
* Email newsletter (on/off)  
* Reminder tappe/misurazioni

Preferenze:

* Unità di misura (metriche/imperiali)  
* Tema app (chiaro/scuro) \- futuro

Piano Subscription:

* Visualizzazione piano attuale (Free/Premium)  
* Upgrade a Premium  
* Gestione pagamento  
* Storico fatture

#### **3.9.4 Supporto**

Help Center:

* FAQ integrate  
* Video tutorial  
* Contact support

Feedback:

* Possibilità inviare feedback  
* Bug report  
* Feature request

## **4\. Modello Freemium** {#4.-modello-freemium}

### **4.1 Piano GRATUITO**

Obiettivo: Offrire valore sufficiente per engagement, incentivare upgrade.

Funzionalità Incluse:

✅ Onboarding e Profilo

* Registrazione completa  
* Profili illimitati bambini  
* Personalizzazione famiglia

✅ Dashboard "Oggi"

* Consigli giornalieri base  
* Focus del giorno  
* Attività suggerite (2/giorno)

✅ Timeline Sviluppo

* Accesso a settimana corrente ±2 settimane  
* Linee guida 24 ore

✅ Tappe di Sviluppo

* Tutte le 5 aree disponibili  
* Questionari base  
* Tracciamento completamento  
* Alert gentili

✅ Misurazioni

* Inserimento illimitato misurazioni  
* Grafici crescita base  
* Calcolo percentili

✅ AI-Helper

* 10 domande/mese  
* Chatbot generale  
* Citazioni base

✅ Articoli

* 20-30 articoli selezionati  
* Consigli pratici base

✅ Report Pediatra

* Export PDF base (dati essenziali)

✅ Gestione Account

* Tutte funzioni account

Limitazioni:

* ⚠️ Timeline: solo ±2 settimane dalla corrente  
* ⚠️ AI: 10 domande/mese  
* ⚠️ Articoli: biblioteca ridotta  
* ⚠️ Report: versione semplificata

### **4.2 Piano PREMIUM**

Prezzo: €7.99/mese o €49.90/anno (sconto \~48%)

Tutto del FREE, più:

🌟 Timeline Completa

* Accesso tutte le 0-156 settimane / 0-36 mesi  
* Contenuti dettagliati ogni fase  
* Approfondimenti extra

🌟 AI-Helper Illimitato

* Domande illimitate  
* 7 Chatbot specializzati per area:  
  1. Sonno Expert  
  2. Alimentazione Expert  
  3. Motricità Expert  
  4. Comunicazione Expert  
  5. Benessere Famiglia Expert  
  6. Salute & Prevenzione Expert  
  7. Gioco & Sviluppo Expert  
* Citazioni estese con snippet completi

🌟 Biblioteca Completa

* 100+ articoli evidence-based  
* Video-guide e tutorial  
* Webinar con esperti (mensili)  
* Download PDF articoli

🌟 Analisi Avanzate

* Grafici crescita avanzati  
* Trend temporali  
* Confronti tra fratelli  
* Dashboard analytics

🌟 Questionari Validati

* Screening strutturati (M-CHAT, ASQ, etc.)  
* Interpretazione risultati  
* Raccomandazioni personalizzate

🌟 Report Avanzato

* PDF completo con grafici  
* Analisi trend  
* Sezioni espandibili  
* Storico visite

🌟 Attività Premium

* 10+ attività/giorno personalizzate  
* Video-tutorial attività  
* Piani settimanali

🌟 Supporto Prioritario

* Risposta 24h  
* Accesso diretto team scientifico (futuro)

🌟 Early Access

* Nuove funzionalità in anteprima  
* Beta testing features  
* Influenza roadmap

### **4.3 Strategia Conversione**

Punti di Conversione:

1. Hard Limit AI (10 domande)  
   * Messaggio chiaro quando raggiunte  
   * CTA upgrade  
2. Timeline Limitata  
   * Blur su settimane future  
   * "Sblocca con Premium"  
3. Contenuti Esclusivi  
   * Badge "Premium" su articoli/video  
   * Preview gratuita  
4. Funzionalità Avanzate  
   * Tooltip "Solo Premium" su features locked  
   * Trial gratuito 7 giorni (da valutare)

Incentivi:

* Sconto annuale (risparmio \~48%)  
* Offerte lancio (es. 50% primi 3 mesi)  
* Referral program (futuro)

## **5\. Requisiti Non Funzionali** {#5.-requisiti-non-funzionali}

### **5.1 Performance**

Target:

* Caricamento app: \< 2 secondi  
* Response API: \< 500ms (p95)  
* AI response: streaming immediato, risposta completa \< 10s  
* Transizioni UI: fluide 60fps

Ottimizzazioni:

* Caching intelligente  
* Lazy loading immagini  
* Preloading dati critici

### **5.2 Sicurezza**

Autenticazione:

* Password hashing (bcrypt)  
* Session management sicuro  
* 2FA opzionale (futuro)

Dati Sensibili:

* Crittografia database at-rest  
* HTTPS obbligatorio  
* Compliance GDPR

API:

* Rate limiting  
* Authentication tokens  
* CORS policy

### **5.3 Privacy e GDPR**

Conformità:

* ✅ Consenso esplicito trattamento dati  
* ✅ Informativa privacy chiara  
* ✅ Cookie policy  
* ✅ Diritto accesso dati  
* ✅ Diritto cancellazione  
* ✅ Export dati utente  
* ✅ Data retention policy

Dati Minimi:

* Raccogliere solo dati necessari  
* Anonimizzazione analytics  
* Opt-in per tracking

### **5.4 Accessibilità**

Standard:

* WCAG 2.1 Level AA  
* Screen reader compatibility  
* Contrasti colori adeguati  
* Font size scalabile  
* Tap target ≥44px

Internazionalizzazione:

* i18n completo  
* RTL support (futuro arabo, ebraico)  
* Formati data/ora locali  
* Valute locali

### **5.5 Affidabilità**

Uptime:

* Target: 99.5% (max 3.6h downtime/mese)  
* Monitoring 24/7  
* Alerting automatico

Backup:

* Backup database giornalieri  
* Retention 30 giorni  
* Disaster recovery plan

Error Handling:

* Graceful degradation  
* Messaggi errore chiari  
* Retry automatici  
* Fallback offline (futuro)

## **6\. Fuori Perimetro v1.0** {#6.-fuori-perimetro-v1.0}

Le seguenti funzionalità NON saranno incluse nella versione 1.0 ma sono pianificate per versioni successive:

### **6.1 Casistiche Speciali**

❌ Prematuri (\<37 settimane)

* Modulo età corretta  
* Timeline specifica  
* Contenuti personalizzati  
* Follow-up specialistico

❌ Adozione e Affido

* Percorsi dedicati  
* Supporto attaccamento  
* Contenuti specifici

❌ PMA (Procreazione Medicalmente Assistita)

* Supporto specifico gravidanza  
* Contenuti personalizzati

❌ Gravidanze a Rischio

* Monitoraggio specifico  
* Supporto emotivo dedicato

❌ Bilinguismo/Multilinguismo

* Linee guida specifiche  
* Timeline adattate

Motivazione: Focus su casistica principale (gravidanza fisiologica \+ nato a termine) per validare modello e architecture prima di aggiungere complessità.

Timeline: Q2-Q3 2026

### **6.2 Lingue Aggiuntive**

❌ Inglese ❌ Spagnolo ❌ Francese ❌ Tedesco ❌ Altre lingue

Motivazione: Focus su mercato italiano per validazione iniziale. Architettura i18n pronta per espansione rapida.

Timeline: Q2 2026 (Inglese), Q3 2026 (altre lingue)

### **6.3 Funzionalità Avanzate**

❌ Community e Social

* Forum genitori  
* Gruppi per età  
* Condivisione esperienze  
* Moderazione contenuti

❌ Portale Professionisti

* Dashboard pediatri  
* Accesso diretto dati pazienti  
* Strumenti clinici  
* Comunicazione bidirezionale

❌ Integrazione Wearables

* Smartwatch  
* Monitor sonno  
* Sensori vari

❌ Telemedicina

* Video consulti  
* Chat con pediatra  
* Prenotazioni

❌ Reminder Intelligenti

* Push notifications avanzate  
* Calendario integrato  
* Sincronizzazione familiare

❌ Modalità Offline

* Download contenuti  
* Service worker  
* Sync quando online

❌ Gamification

* Badge e achievements  
* Streak tracking  
* Rewards system

Motivazione: Concentrazione su core value proposition. Features avanzate richiedono validazione modello base prima.

Timeline: Q4 2026 \- Q1 2027

### **6.4 Integrazioni Esterne**

❌ Sistemi Sanitari

* FSE (Fascicolo Sanitario Elettronico)  
* Sistemi ospedalieri  
* Laboratori analisi

❌ E-commerce

* Marketplace prodotti  
* Affiliazioni  
* Pubblicità targeting

❌ Partner Commerciali

* Chicco, Prenatal, etc.  
* Kit prodotti  
* Sconti esclusivi

Motivazione: Complessità legale, tecnica e contrattuale. Priorità su prodotto core.

Timeline: 2027+

## **7\. Roadmap Post-Lancio** {#7.-roadmap-post-lancio}

### **7.1 Q2 2026 \- Lancio e Stabilizzazione**

Obiettivi:

* ✅ Soft launch app completa v1.0  
* ✅ Raggiungere 1.000 utenti registrati  
* ✅ Conversione 1% premium (10 utenti paganti)  
* ✅ Raccogliere feedback utenti

Attività:

* Launch PR e marketing  
* Partnership studi pediatrici (150 target)  
* Campagne social e ads  
* Monitoring e bug fixing  
* Ottimizzazioni performance  
* A/B testing conversione

Milestone:

* Beta con 100 famiglie  
* World launch Italia  
* Break-even operativo

### **7.2 Q3 2026 \- Espansione Casistiche**

Obiettivi:

* ➕ Aggiungere supporto Prematuri  
* ➕ Aggiungere supporto Bilinguismo  
* ➕ Migliorare AI con feedback  
* ✅ 2.500 utenti registrati  
* ✅ 25 utenti premium

Attività:

* Sviluppo moduli casistiche speciali  
* Validazione scientifica contenuti  
* Partnership ospedali per prematuri  
* Espansione knowledge base  
* Miglioramento UI/UX da feedback  
* Testing usabilità

Deliverables:

* Modulo Prematuri completo  
* Modulo Bilinguismo completo  
* Timeline personalizzate  
* Contenuti validati

### **7.3 Q4 2026 \- Internazionalizzazione**

Obiettivi:

* 🌍 Lancio versione Inglese  
* ➕ Aggiungere Adozione/Affido  
* ✅ 5.000 utenti totali  
* ✅ 50 utenti premium  
* ✅ Espansione UK, USA, Australia

Attività:

* Traduzione completa app e contenuti in inglese  
* Localizzazione (valute, unità misura, date)  
* Adattamento knowledge base (linee guida AAP, NHS)  
* Marketing internazionale  
* Partnership pediatrici internazionali

Deliverables:

* App bilingue (ITA \+ ENG)  
* Knowledge base localizzata  
* Modulo Adozione/Affido  
* Landing pages internazionali

### **7.4 Q1 2027 \- Features Avanzate**

Obiettivi:

* ➕ Community features (fase 1\)  
* ➕ Portale professionisti (beta)  
* ➕ Reminder avanzati e calendario  
* ✅ 10.000 utenti totali  
* ✅ 100+ utenti premium  
* ✅ Serie A preparazione

Attività:

* Sviluppo community moderata  
* Dashboard pediatri beta  
* Sistema notifiche avanzato  
* Integrazione calendario  
* Analytics avanzate  
* Preparazione scaling infrastructure

Deliverables:

* Forum e gruppi genitori  
* Dashboard professionisti beta  
* Sistema notifiche push  
* Calendario integrato

### **7.5 2027+ \- Scaling e Nuovi Mercati**

Visione:

* 🌍 Espansione 5+ lingue (Spagnolo, Francese, Tedesco, etc.)  
* 🏥 Partnership con sistemi sanitari nazionali  
* 💼 Modello B2B per ospedali e consultori  
* 🎮 Gamification e engagement avanzato  
* 🔗 Integrazioni wearables e IoT  
* 📱 App nativa ottimizzata (post-Hotwire se necessario)  
* 🤖 AI sempre più personalizzato e predittivo

Obiettivi Economici:

* 50.000+ utenti  
* 500+ premium  
* Break-even completo  
* Revenue €300K+ annuali  
* Serie A round

## **8\. Metriche di Successo** {#8.-metriche-di-successo}

### **8.1 KPI Prodotto (v1.0)**

#### **Acquisizione**

* Target Q2 2026: 1.000 utenti registrati  
* Source Mix:  
  * 30% Organic (SEO, word-of-mouth)  
  * 25% Partnership pediatri  
  * 25% Social media  
  * 20% Paid ads

#### **Attivazione**

* Onboarding Completion Rate: \>80%  
  * % utenti che completano onboarding veloce  
* First Action Rate: \>60%  
  * % utenti che compiono almeno 1 azione (questionario, misurazione, AI) entro 24h

#### **Engagement**

* DAU (Daily Active Users): 15% degli utenti registrati  
* WAU (Weekly Active Users): 40% degli utenti registrati  
* Session Length: \>5 minuti media  
* Sessions per Week: \>2 volte/settimana

#### **Retention**

* D1 Retention: \>50%  
* D7 Retention: \>40%  
* D30 Retention: \>30%  
* 3-Month Retention: \>20%

#### **Monetizzazione**

* Conversione Free→Premium: 1% (10 utenti su 1.000)  
* ARPU (Average Revenue Per User): \~€0.08/mese (considerando 1% premium)  
* LTV (Lifetime Value): €3-5 per utente (12-18 mesi utilizzo medio)  
* CAC (Customer Acquisition Cost): \<€10 per utente  
* LTV:CAC Ratio: \>3:1

#### **Utilizzo Funzionalità**

* AI-Helper: 50% utenti fanno ≥1 domanda/mese  
* Tappe Sviluppo: 70% utenti completano ≥1 questionario  
* Misurazioni: 60% utenti inseriscono ≥1 misurazione/mese  
* Articoli: 40% utenti leggono ≥1 articolo/settimana

### **8.2 KPI Business**

#### **Revenue**

* Q2 2026: €80/mese (10 premium \* €7.99)  
* Q3 2026: €200/mese (25 premium)  
* Q4 2026: €400/mese (50 premium)  
* Q1 2027: €800/mese (100 premium)

Target Anno 1: €1.600/mese \= €19.200 annui

#### **Crescita**

* MoM Growth Rate: \>20% utenti registrati  
* Churn Rate Premium: \<5% mensile  
* Viral Coefficient: \>0.2 (ogni utente porta 0.2 nuovi utenti)

#### **Qualità**

* NPS (Net Promoter Score): \>50  
* App Store Rating: \>4.5/5  
* Customer Support Response Time: \<24h  
* Bug Critical Resolution: \<48h

### **8.3 KPI Tecnici**

#### **Performance**

* App Load Time: \<2s (p95)  
* API Response Time: \<500ms (p95)  
* Crash Rate: \<0.5%  
* Error Rate: \<1%

#### **Affidabilità**

* Uptime: \>99.5%  
* Disponibilità AI: \>99%  
* Successful Payments: \>99%

#### **Sicurezza**

* Zero Data Breaches  
* GDPR Compliance: 100%  
* Security Audits: 2/anno passed

### **8.4 KPI Contenuto**

#### **Knowledge Base**

* Coverage: 100% età 0-36 mesi  
* Articles Published: 100+ entro Q4 2026  
* Scientific Sources: 50+ validati  
* Update Frequency: 1 nuovo articolo/settimana minimo

#### **AI Quality**

* Answer Relevance: \>90% (valutazione utente)  
* Citation Accuracy: \>95%  
* Response Completeness: \>85%

### **8.5 Dashboard & Monitoring**

Tools:

* Google Analytics 4 per web/app analytics  
* Mixpanel o Amplitude per product analytics  
* Stripe Dashboard per metriche pagamenti  
* Sentry per error tracking  
* Prometheus/Grafana per infra monitoring

Cadenza Review:

* Daily: Dashboard engagement, errors, uptime  
* Weekly: Funnel conversione, retention cohorts  
* Monthly: Business review completo con team  
* Quarterly: OKR review e pianificazione

## **📊 Conclusioni e Prossimi Passi**

### **Riepilogo v1.0**

Shuby 1.0 rappresenta un prodotto minimo viabile ma completo che:

✅ Copre le esigenze essenziali dei genitori 0-36 mesi  
✅ Integra AI conversazionale con knowledge base scientifica  
✅ Offre tracciamento completo sviluppo e crescita  
✅ Valida modello freemium  
✅ Fornisce base solida per espansione future

### **Perimetro Chiaro**

INCLUSO in v1.0:

* Gravidanza fisiologica \+ nato a termine  
* Lingua italiana  
* Tutte le 5 aree sviluppo  
* Web \+ iOS \+ Android (Hotwire Native)  
* Modello freemium funzionante

ESCLUSO da v1.0:

* Casistiche speciali (prematuri, adozione, etc.)  
* Lingue aggiuntive  
* Features avanzate (community, telemedicina, etc.)

### **Perché Questo Scope?**

1. Focus: Validare modello su casistica principale (70% mercato)  
2. Velocità: Time-to-market ridotto con stack Rails \+ Hotwire  
3. Qualità: Profondità su funzionalità core vs ampiezza superficiale  
4. Scalabilità: Architettura pronta per espansione rapida  
5. Risorse: Scope allineato a team e budget seed round

### **Prossimi Passi Operativi**

#### **Per i Founder:**

1. ✅ Approvare questo documento come reference per sviluppo  
2. 📝 Definire priorità interne tra le funzionalità (se necessario)  
3. 👥 Completare team di sviluppo (Rails devs, designer, QA)  
4. 💰 Finalizzare seed round €300K  
5. 📅 Definire timeline dettagliata (Gantt chart con milestones)  
6. 🤝 Identificare pediatri beta-tester per validazione contenuti

#### **Per il Team Tecnico:**

1. 🏗️ Setup infrastructure (Rails 8.1 \+ PostgreSQL \+ Hotwire)  
2. 📊 Design database schema basato su requisiti  
3. 🎨 Design system e UI components da Figma  
4. 🔐 Setup autenticazione e sicurezza  
5. 🤖 Integrazione OpenAI RAG con knowledge base  
6. 📱 Setup Hotwire Native per iOS/Android

#### **Timeline Suggerita:**

* Dicembre 2026: Setup \+ Design \+ Architettura  
* Gennaio-Marzo 2026: Sviluppo core features  
* Aprile 2026: Testing \+ Bug fixing  
* Maggio 2026: Beta 100 famiglie  
* Giugno 2026: Soft Launch v1.0

---

Documento Versione: 1.0  
Ultima Modifica: 20 Novembre 2025  
Autore: KVA Team

