## Account Demo

### 1. Maria Rossi — `maria@demo.shuby` / `testtest`

**Famiglia completa** con 3 figli e tutti i dati pre-popolati. Usare questo account per esplorare tutte le funzionalità.

| Figlio | Età | Note |
|--------|-----|------|
| **Sofia** | ~3 mesi, femmina | Fase neonatale, 7 misurazioni, 2 questionari completati + 1 in corso |
| **Marco** | ~12 mesi, maschio | Fase attiva, 9 misurazioni, 3 questionari completati + 1 in corso |
| **Giulia** | ~24 mesi, femmina | Prematura (34 settimane) — scenario età corretta, 10 misurazioni, 2 questionari completati |

**Cosa testare:**
- Dashboard con saluto e età del bambino
- Selettore bambini (switch tra Sofia, Marco, Giulia)
- Grafici di crescita con punti dati e bande WHO
- Stadi di sviluppo con sessioni completate e in corso
- Risultati questionari (conteggi sì/no/incerto)
- Archivio con 3 contenuti preferiti
- Cronologia chat (2 conversazioni con messaggi)
- Report PDF per qualsiasi bambino
- Profilo famiglia completo (due genitori, italiano + inglese)
- Domande per il pediatra (2 per Sofia, 1 per Marco)

### 2. Luca Bianchi — `luca@demo.shuby` / `testtest`

**Utente premium** con un figlio e dati minimi. Usare per testare le funzionalità premium e l'esperienza con meno dati.

| Figlio | Età | Note |
|--------|-----|------|
| **Lorenzo** | ~6 mesi, maschio | 5 misurazioni dalla nascita, 1 questionario completato |

**Cosa testare:**
- Chat **senza limite** (abbonamento premium — messaggi illimitati)
- Grafico di crescita con 5 punti dati
- Un'area di sviluppo con sessione completata
- Cronologia chat (1 conversazione)
- Possibilità di aggiungere misurazioni, avviare questionari, creare nuove chat
- Profilo famiglia minimale (genitore singolo, solo italiano)

---

## Note Importanti

| Argomento | Dettaglio |
|-----------|-----------|
| **Chat AI** | Richiede chiave OpenAI nelle credenziali Rails. La cronologia pre-popolata funziona sempre. |
| **Limite messaggi** | Maria (free) = 30 msg/mese. Luca (premium) = illimitati. |
| **Report PDF** | Generati offline con Prawn, nessuna API esterna. Funzionano sempre. |
| **Lingua UI** | Tutto in italiano, come da design. |
| **Riesecuzione** | `rails demo:setup` può essere rieseguito in sicurezza — aggiorna senza duplicare. |
