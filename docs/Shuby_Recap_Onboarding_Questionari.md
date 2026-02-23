# Shuby App - Recap Domande Onboarding e Questionari Sviluppo

**Documento di Verifica per Supervisore**

---

## 0) Scope & Sources

### Branch/Commit
- **Branch:** main
- **Commit:** `642548a0` - "feat(i18n): set Italian as default locale and enhance translations"
- **Data analisi:** 2026-01-21

### File Analizzati

**Onboarding:**
- `app/controllers/onboarding_controller.rb`
- `app/views/onboarding/` (tutti i file)
- `app/models/family_profile.rb`
- `app/models/child.rb`
- `app/models/child_health_profile.rb`
- `app/models/user/onboarding.rb`
- `config/locales/onboarding.it.yml`
- `config/routes/onboarding.rb`

**Questionari Sviluppo:**
- `db/seeds/data/questionari_completi_5_aree.json`
- `db/seeds/data/campanelli_attivita.json`
- `app/models/questionnaire_session.rb`
- `app/models/question_response.rb`
- `app/models/development_area.rb`
- `app/models/age_band_questionnaire.rb`
- `app/controllers/development_stages_controller.rb`
- `app/controllers/questionnaire_sessions_controller.rb`
- `config/locales/it.yml`

### Note su Dati Mancanti/Ambigui
- **Questionari mesi 29-36:** Presenti solo in `campanelli_attivita.json` (campanelli e attivita), ma NON in `Shuby_Questionari_Completi_5_Aree.json` (manca il questionario vero e proprio)
- **Terminologia:** Il codice e tutti i documenti usano `incerto` (allineamento completato)

---

## 1) Onboarding Flow - Domande Esatte Mostrate agli Utenti

L'onboarding e un flusso a 4 step obbligatorio prima di accedere all'app.

### STEP 1: Profilo della Famiglia

**Titolo schermata:** "Profilo della Famiglia"
**Sottotitolo:** "Raccontaci della tua famiglia per personalizzare la tua esperienza su Shuby"

| # | Domanda/Campo | Testo Italiano Esatto | Chi risponde | Tipo Input | Obbligatorio |
|---|---------------|----------------------|--------------|------------|--------------|
| 1 | Paese di residenza | "Paese di residenza" | Qualsiasi caregiver | Testo libero | **SI** |
| 2 | Nazionalita | "Nazionalita" | Qualsiasi caregiver | Testo libero | No |
| 3 | Lingua madre | "Lingua madre" | Qualsiasi caregiver | Testo libero | No |
| 4 | Struttura familiare | "Struttura familiare" | Qualsiasi caregiver | Select | No |
| 5 | Tipo di coppia | "Tipo di coppia" | Qualsiasi caregiver | Select (condizionale) | No |
| 6 | Numero di bambini | "Numero di bambini" | Qualsiasi caregiver | Numero (1-10) | **SI** |
| 7 | Lingue parlate in casa | "Lingue parlate in casa" | Qualsiasi caregiver | Numero (1-10) | **SI** |

**Opzioni Struttura familiare:**
- "Monogenitoriale"
- "Due genitori"
- "Famiglia affidataria"
- "Famiglia adottiva"
- "Altro"

**Opzioni Tipo di coppia** (appare solo se "Due genitori"):
- "Non specificato"
- "Due padri"
- "Due madri"
- "Preferisco non rispondere"

**Testo di aiuto:**
> "Perche lo chiediamo: la comunicazione cresce grazie alle interazioni; parlare piu lingue non rallenta, ma cambia alcune tappe."

**Pulsante:** "Continua"

---

### STEP 2: I tuoi bambini (Profilo Salute)

**Titolo schermata:** "I tuoi bambini"
**Sottotitolo:** "Inserisci le informazioni per ogni bambino"

*Questo step si ripete per ogni bambino dichiarato nello Step 1.*

#### Sezione: Informazioni base

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 1 | Nome | "Nome" | Testo | **SI** (o soprannome) |
| 2 | Soprannome | "Soprannome" | Testo | **SI** (o nome) |
| 3 | Data di nascita | "Data di nascita" | Data | **SI** |
| 4 | Parto gemellare | "E un parto gemellare/multiplo?" | Checkbox | No |
| 5 | Sesso alla nascita | "Sesso alla nascita" | Select | No |

**Opzioni Sesso:**
- "Preferisco non rispondere"
- "Maschio"
- "Femmina"

#### Sezione: Dettagli nascita

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 6 | Eta gestazionale | "Eta gestazionale alla nascita" | Select | No |
| 7 | Peso alla nascita | "Peso alla nascita (grammi)" | Numero | No |
| 8 | Tipo di gravidanza | "Tipo di gravidanza" | Select | No |
| 9 | Ricovero | "Ricovero subito dopo la nascita?" | Select | No |
| 10 | Complicazioni | "Complicazioni segnalate alla nascita" | Checkbox multipli | No |

**Opzioni Eta gestazionale:**
- "< 28 settimane"
- "28-31+6 settimane"
- "32-34+6 settimane"
- "35-36+6 settimane"
- ">= 37 settimane (a termine)"

**Opzioni Tipo di gravidanza:**
- "Naturale"
- "PMA omologa"
- "PMA con donazione ovociti"
- "PMA con donazione spermatozoi"
- "Inseminazione intrauterina"
- "FIVET/ICSI"
- "Altro"
- "Non lo so"

**Opzioni Ricovero:**
- "Si"
- "No"
- "Non lo so"

**Opzioni Complicazioni nascita:**
- "Difficolta respiratorie"
- "Ittero con fototerapia (lampada)"
- "Infezione"
- "Ipoglicemia"
- "Altro"
- "Non lo so"

#### Sezione: Informazioni prematurita (CONDIZIONALE)

*Appare se eta gestazionale < 37 settimane*

**Sottotitolo:** "Queste informazioni ci aiutano a calcolare l'eta corretta e adattare i consigli"

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 11 | Eta gestazionale esatta | "Eta gestazionale esatta" | Numeri (settimane + giorni) | No |
| 12 | Peso < 1500g | "Peso alla nascita < 1.500g?" | Select | No |
| 13 | Ossigeno/ventilazione | "Ossigeno/ventilazione nelle prime settimane?" | Select | No |
| 14 | Controlli programmati | "Controlli programmati (follow-up)" | Checkbox multipli | No |

**Nota automatica:** "L'eta corretta verra calcolata automaticamente"

**Opzioni Controlli programmati:**
- "Udito"
- "Vista"
- "Motricita"
- "Respiro"
- "Altro"

#### Sezione: Screening e salute

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 15 | Screening uditivo | "Screening uditivo neonatale" | Select | No |
| 16 | Screening vista | "Screening vista/occhi" | Select | No |

**Opzioni Screening uditivo:**
- "Superato (Pass)"
- "Da ripetere (Refer)"
- "Non eseguito"
- "Non lo so"

**Opzioni Screening vista:**
- "Eseguito"
- "Non ancora"
- "Non lo so"

#### Sezione: Alimentazione

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 17 | Alimentazione attuale | "Alimentazione attuale" | Select | No |
| 18 | Svezzamento iniziato | "Avete gia iniziato lo svezzamento (alimentazione complementare)?" | Checkbox | No |
| 19 | Data inizio svezzamento | "Da quando?" | Data | No |
| 20 | Alimenti introdotti | "Principali alimenti introdotti" | Testo area | No |
| 21 | Difficolta alimentari | "Eventuali difficolta" | Testo area | No |

**Opzioni Alimentazione attuale:**
- "Allattamento al seno"
- "Latte in formula"
- "Misto"
- "Altro"

#### Sezione: Sonno e attivita

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 22 | Ore di sonno | "Ore di sonno medie in 24h" | Numero decimale | No |
| 23 | Qualita del sonno | "Qualita del sonno" | Checkbox multipli | No |
| 24 | Tempo gioco a terra | "Tempo di gioco/attivita a terra al giorno" | Numero (minuti) | No |

**Opzioni Qualita del sonno (problemi):**
- "Russa"
- "Si muove molto"
- "Si sveglia spesso"
- "Piange"
- "Difficolta ad addormentarsi"
- "Difficolta a svegliarsi"
- "Digrigna i denti"
- "Altro"

**Pulsanti:** "Indietro" | "Continua"

---

### STEP 3: Storia familiare

**Titolo schermata:** "Storia familiare"
**Sottotitolo:** "Ultime domande sulla vostra famiglia"

| # | Domanda/Campo | Testo Italiano Esatto | Tipo Input | Obbligatorio |
|---|---------------|----------------------|------------|--------------|
| 1 | Caregiver principali | "Con chi trascorre piu tempo il bambino?" | Checkbox multipli | No |
| 2 | Condizioni ereditarie | "Nella vostra famiglia ci sono caratteristiche ereditarie note?" | Checkbox | No |
| 3 | Quali condizioni | "Quali condizioni?" | Checkbox multipli | No |

**Opzioni Caregiver principali:**
- "Genitori"
- "Nonni"
- "Educatori/Tata"
- "Altri"

**Opzioni Condizioni ereditarie:**
- "Difficolta del linguaggio"
- "Difficolta di attenzione/iperattivita"
- "Difficolta del comportamento"
- "Disturbo dello spettro autistico"
- "Altro"

**Pulsanti:** "Indietro" | "Completa"

---

### STEP 4: Completamento

**Titolo schermata:** "Configurazione completata!"

**Messaggio di ringraziamento:**
> "Grazie per aver completato il profilo della tua famiglia. Stiamo ottimizzando la vostra esperienza su Shuby."

**Nota importante (disclaimer):**
> "Nota importante: Shuby non sostituisce il pediatra. Le informazioni servono a sostenere le interazioni quotidiane e a fornire consigli sulla comunicazione, sulla relazione e sul gioco."

**Pulsante:** "Inizia ad usare Shuby"

---

## 2) Development Stages / Questionnaires - Domande Esatte

### Panoramica Sistema

- **Range eta:** 0-36 mesi (ma questionari implementati solo 0-28 mesi)
- **5 Aree di sviluppo:**
  1. Comunicazione e Linguaggio (rosa)
  2. Motricita (verde)
  3. Cognizione e Attenzione (ambra)
  4. Relazione e Regolazione (blu)
  5. Consolidamento (indaco) - verifica competenze mese precedente

### Opzioni di Risposta Standard

Per TUTTE le domande dei questionari:
- **"Si"**
- **"No"**
- **"Non lo so"**

---

### MESE 0 (0 mesi - Neonato)

#### Comunicazione e Linguaggio

| # | Domanda Esatta |
|---|----------------|
| 1 | Reagisce alla voce della mamma? |
| 2 | Piange in modo forte quando ha fame o disagio? |
| 3 | Si calma se parlato con voce dolce? |

#### Motricita

| # | Domanda Esatta |
|---|----------------|
| 1 | Muove gambe e braccia in modo simmetrico? |
| 2 | Tende a chiudere le mani? |
| 3 | Avvicina le mani al volto, per esempio toccando bocca o occhi? |
| 4 | Afferra automaticamente un dito se glielo metti nel palmo? |

#### Cognizione e Attenzione

| # | Domanda Esatta |
|---|----------------|
| 1 | Fissa una luce intensa? |
| 2 | Guarda un volto vicino per qualche secondo? |
| 3 | Reagisce a rumori forti con un sobbalzo? |

#### Relazione e Regolazione

| # | Domanda Esatta |
|---|----------------|
| 1 | Piange quando ha fame o disagio? |
| 2 | Si calma al contatto fisico? |
| 3 | Dorme almeno 14-17 ore al giorno? |

#### Consolidamento

*Nessuna domanda - mese iniziale*

---

### MESE 1 (1 mese)

#### Comunicazione e Linguaggio

| # | Domanda Esatta |
|---|----------------|
| 1 | Emette suoni diversi dal pianto (es. "ehh", "uhh")? |
| 2 | Vocalizza se tranquillo? |
| 3 | Si calma se gli si parla dolcemente? |

#### Motricita

| # | Domanda Esatta |
|---|----------------|
| 1 | Solleva leggermente la testa quando e a pancia in giu? |
| 2 | Inizia ad aprire le mani per brevi momenti? |
| 3 | Allunga braccia o gambe spontaneamente? |

#### Cognizione e Attenzione

| # | Domanda Esatta |
|---|----------------|
| 1 | Segue un oggetto per qualche secondo? |
| 2 | Si gira verso un suono? |

#### Relazione e Regolazione

| # | Domanda Esatta |
|---|----------------|
| 1 | Si calma se preso in braccio? |
| 2 | Mostra calma o agitazione in base a chi lo tiene? |

#### Consolidamento (verifica mese 0)

| # | Domanda Esatta |
|---|----------------|
| 1 | Reagisce alla voce della mamma? |
| 2 | Avvicina le mani al volto, per esempio toccando bocca o occhi? |
| 3 | Guarda un volto vicino per qualche secondo? |

---

### MESI 2-28

*I questionari continuano con lo stesso pattern per ogni mese.*

**Sorgente completa:** `db/seeds/data/questionari_completi_5_aree.json`

**Struttura per ogni mese:**
- 3-4 domande per Comunicazione e Linguaggio
- 3-4 domande per Motricita
- 2-3 domande per Cognizione e Attenzione
- 2-3 domande per Relazione e Regolazione
- 2-3 domande per Consolidamento

---

### MESI 24-36 (Scheda Unica)

**Nota:** Per questa fascia d'eta esiste una scheda unica (non mensile) con obiettivi di sviluppo.

**Obiettivi di sviluppo:**
> Promuovere il linguaggio articolato, le abilita sociali e la motricita fine e grossolana piu avanzata.

#### Motricita

| # | Domanda Esatta |
|---|----------------|
| 1 | Salta con entrambi i piedi? |
| 2 | Pedala un triciclo? |
| 3 | Usa cucchiaio e forchetta con minimi rovesciamenti? |

#### Cognizione e Attenzione

| # | Domanda Esatta |
|---|----------------|
| 1 | Riconosce colori e forme di base? |
| 2 | Completa puzzle semplici? |
| 3 | Conta almeno fino a 3? |

#### Relazione e Regolazione

| # | Domanda Esatta |
|---|----------------|
| 1 | Forma frasi di 3-4 parole? |
| 2 | Partecipa a giochi con altri bambini? |
| 3 | Mostra autonomia in piccole attivita (lavarsi le mani)? |

#### Attivita Consigliate (24-36 mesi)

**Motricita:**
- Proponi giochi di salto e rincorsa.
- Incoraggia a pedalare con triciclo o giochi a spinta.
- Offri pastelli e carta per disegnare linee e cerchi.

**Cognizione e Attenzione:**
- Giochi di incastro e puzzle con poche parti.
- Conta insieme oggetti quotidiani.
- Nomina e abbina colori e forme.

**Relazione e Regolazione:**
- Incoraggia giochi di gruppo (palla, girotondo).
- Fai conversazioni semplici stimolando risposte piu lunghe.
- Offri responsabilita semplici (mettere a posto un gioco).

#### Campanelli d'Allarme (24-36 mesi)

- Non combina parole in frasi.
- Non partecipa a giochi ne mostra interesse per coetanei.
- Ha difficolta motorie evidenti (non salta, non corre).

#### Approfondimento

> Tra i 2 e i 3 anni il bambino rafforza il linguaggio, espande il vocabolario e impara a costruire frasi. Le abilita sociali emergono nel gioco con i pari, mentre le competenze motorie grossolane e fini permettono maggiore autonomia.

---

### NOTA: Differenza di Struttura tra Fasce d'Eta

| Fascia | Struttura | Aree |
|--------|-----------|------|
| 0-28 mesi | Questionari MENSILI (29 questionari) | 5 aree + Consolidamento |
| 24-36 mesi | Scheda UNICA per fascia | 3 aree (Motricita, Cognizione, Relazione) |

**Osservazione:** La fascia 24-36 mesi NON include l'area "Comunicazione e Linguaggio" separata - le domande sul linguaggio sono integrate in "Relazione e Regolazione"

---

## Campanelli d'Allarme (Warning Bells)

**Sorgente:** `db/seeds/data/campanelli_attivita.json`

I campanelli sono segnali d'allarme da condividere con il pediatra.

**UI Label:** "Campanelli d'Allarme"
**Sottotitolo:** "Se noti uno o piu di questi segnali, condividili con il pediatra."

### Mese 0

- Non risponde alla voce o al volto del genitore.
- Non si calma con il contatto o la voce dolce.
- Nessuna reazione a rumori forti o luce intensa.
- Non piange o piange con suoni poco variabili.

### Mese 6

- Non si siede con supporto.
- Non reagisce al nome.
- Nessuna interazione vocale con il caregiver.

### Mese 12

- Non dice alcuna parola con significato.
- Non comprende semplici comandi.
- Non gioca in modo funzionale con oggetti.

### Mese 24

- Non combina 2-3 parole in una frase.
- Non riconosce azioni di routine.
- Non gioca in parallelo con altri bambini.
- Non risponde a domande semplici.

### Mese 36

- Non costruisce frasi articolate.
- Non gioca in modo cooperativo.
- Non verbalizza desideri, bisogni, emozioni.

---

## Stimulation Activities

**Sorgente:** `db/seeds/data/campanelli_attivita.json`

**UI Label:** "Stimulation Activities"
**Sottotitolo:** "Attivita pratiche che puoi fare a casa per favorire lo sviluppo."

### Mese 0

- Parla al neonato con voce calma e guardandolo in volto.
- Offri brevi momenti di tummy time supervisionato.
- Accarezza, culla, canta dolcemente.
- Espone a contrasti visivi (volto, oggetti bianchi e neri).

### Mese 6

- Chiamalo per nome da posizioni diverse.
- Crea giochi di causa-effetto (suoni, luci, stoffe).

### Mese 12

- Leggi libri e chiedi "dov'e...?"
- Stimola giochi di funzione (spingere, scuotere).
- Incoraggia l'autonomia nel camminare.

### Mese 24

- Usa domande quotidiane ("Chi e?", "Cosa fa?").
- Proponi giochi di costruzione con regole (ordina, impila).
- Invita il bambino a simulare azioni quotidiane con i giochi.

### Mese 36

- Stimola il gioco cooperativo con ruoli e turni.
- Chiedi di raccontare una storia inventata.
- Proponi attivita con regole e narrazione strutturata.

---

## Cosa Succede Dopo le Risposte

### Logica "Needs Attention"

**Trigger:** Mostra alert se:
- Questionario completato E
- (2+ risposte "No" OPPURE >30% delle risposte sono "No")

**Messaggio UI:**
> "Abbiamo notato alcune risposte che potrebbero indicare aree su cui concentrarsi. Ricorda che ogni bambino si sviluppa con i propri tempi!"

**Suggerimenti mostrati:**
- "Chiedi a Shuby AI"
- "In caso di dubbi, consulta il pediatra"

---

## 3) Alignment Check - Esperienza per Tipo di Utente

### Esperienza MADRE

**Cosa sembra chiaro/previsto:**
- Domande sulla gravidanza e parto sono dettagliate e complete
- Le opzioni per PMA/fecondazione assistita sono inclusive
- La sezione prematurita e ben strutturata con eta corretta automatica
- Disclaimer chiaro che l'app non sostituisce il pediatra

**Cosa potrebbe sembrare confuso/troppo clinico:**
- Terminologia medica senza spiegazioni: "FIVET/ICSI", "Refer" per screening
- "Ipoglicemia" potrebbe non essere compresa da tutti
- Nessuna spiegazione del perche si chiede lo "screening uditivo neonatale"

**Contesto mancante ("perche chiediamo questo?"):**
- Solo la domanda lingue ha spiegazione esplicita
- Manca spiegazione per: struttura familiare, condizioni ereditarie, tempo a terra

**Friction privacy/fiducia:**
- Domande su condizioni ereditarie familiari molto personali al primo utilizzo
- "Disturbo dello spettro autistico" in famiglia puo creare disagio senza contesto

### Esperienza PADRE

**Cosa sembra chiaro/previsto:**
- Opzione "Due padri" inclusa esplicitamente
- Possibilita di usare soprannome invece del nome
- Caregiver non binario (qualsiasi adulto puo rispondere)

**Cosa potrebbe sembrare confuso/troppo clinico:**
- Domande molto orientate alla gravidanza/parto (il padre potrebbe non sapere dettagli)
- "Non lo so" e una risposta valida ma potrebbe far sentire il padre inadeguato

**Contesto mancante:**
- Chi dovrebbe compilare idealmente (madre/padre insieme?)
- Se le risposte possono essere aggiornate successivamente

### Esperienza PARENTE (Nonno/Nonna/Altro)

**Cosa sembra chiaro/previsto:**
- "Nonni" esplicitamente elencati come caregiver principali
- "Educatori/Tata" come opzione

**Cosa potrebbe sembrare confuso:**
- Molte domande richiedono informazioni che solo i genitori conoscono
- Un nonno potrebbe non sapere: peso alla nascita, settimane gestazionali, tipo di gravidanza

**Contesto mancante:**
- Non e chiaro se un parente POSSA/DEBBA compilare l'onboarding
- Manca indicazione su chi contattare per informazioni mancanti

---

## 4) Gaps / Risks / Ambiguities

### 4.1 Struttura Diversa tra Fasce d'Eta

**Problema:** Due strutture diverse coesistono:
- Mesi 0-28: Questionari MENSILI con 5 aree
- Mesi 24-36: Scheda UNICA con 3 aree (dalla documentazione "Scheda 24-36 mesi")

**File JSON attuale:** `db/seeds/data/questionari_completi_5_aree.json` contiene solo mesi 0-28
**Dati aggiuntivi:** `campanelli_attivita.json` ha campanelli/attivita per mesi 0-36
**Scheda 24-36:** Fornita separatamente (non nel JSON)

**Rischio/Ambiguita:**
- Sovrapposizione mesi 24-28 (presenti in entrambe le strutture)
- Area "Comunicazione e Linguaggio" mancante nella scheda 24-36 (integrata in Relazione)
- Area "Consolidamento" mancante nella scheda 24-36

### 4.2 Terminologia ~~Inconsistente~~ (RISOLTO)

**Stato:** ✅ Risolto - Il codice e tutti i documenti ora usano `incerto` uniformemente
**Precedente problema:** Il codice usava `non_lo_so` mentre i documenti usavano `incerto`

### 4.3 Soglia "Needs Attention" Non Documentata

**Problema:** La logica 2+ no O >30% no non e documentata per l'utente
**Rischio:** Genitori non capiscono perche vedono "Attenzione"

### 4.4 Campanelli - Logica di Visualizzazione

**Ambiguita:** Sono mostrati a tutti o solo se "needs_attention"?

### 4.5 Attivita - Logica di Raccomandazione

**Comportamento attuale:** Mostra TUTTE le attivita del mese, non filtrate
**Manca:** Logica di prioritizzazione basata su aree deboli

### 4.6 Consolidamento - Scopo Non Spiegato

**Problema:** L'area "Consolidamento" non e spiegata all'utente
**Manca:** Spiegazione UI del perche alcune domande si ripetono

---

## 5) Recommendations (Quick Wins)

### Alta Priorita

1. **Decidere struttura per 24-36 mesi** - Chiarire se usare:
   - La scheda unica 24-36 mesi (3 aree, formato diverso)
   - Oppure continuare con questionari mensili 29-36 (5 aree, stesso formato 0-28)
   - Gestire sovrapposizione mesi 24-28

2. **Aggiungere testo "perche chiediamo"** - Replicare il pattern usato per "lingue parlate in casa" ad altre domande sensibili

3. **Semplificare terminologia medica** - Aggiungere tooltip o testo esplicativo per termini tecnici

### Media Priorita

4. **Spiegare soglia "Attenzione"** - Aggiungere testo che spiega quando appare l'alert

5. **Chiarire chi compila l'onboarding** - Aggiungere nota iniziale su chi dovrebbe rispondere

6. **Spiegare area Consolidamento** - Aggiungere nota sul perche alcune domande si ripetono

### Bassa Priorita

7. **Personalizzare attivita su risposte** - Evidenziare attivita relative alle aree con risposte "No"

8. **Aggiungere indicatore progresso** - Mostrare "3/5 aree completate questo mese"

9. **Opzione "Chiedi al partner"** - Per domande che il compilatore non sa rispondere

---

*Fine documento recap - Generato da analisi codebase Shuby*
*Data: 2026-01-21*
