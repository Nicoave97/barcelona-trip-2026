# Note di conversione HTML/JS → Flutter

La conversione non è una traduzione riga-per-riga di `app.js`.

La vecchia SPA generava HTML manualmente; la nuova versione divide le responsabilità:

- **Screen** = pagina completa (`ItineraryScreen`, `NearbyScreen`, ecc.)
- **Widget** = componente riutilizzabile (`PlaceCard`, `TagPill`, rating dialog)
- **TripController** = stato condiviso e sincronizzazione backend
- **BackendService** = sole chiamate HTTP alle Edge Functions
- **Models** = oggetti Dart tipizzati
- **ThemeData** = colori e stile centralizzati

Questo elimina gran parte dei problemi che avevamo avuto con CSS sovrapposto, funzioni JavaScript mancanti e markup duplicato.

## Dati pubblici e dati privati

`assets/data/public_data.json` contiene solo luoghi, ristoranti, cibi e metadati non sensibili.

Dopo il PIN il backend restituisce:

- alloggio reale
- itinerario reale
- profili del gruppo
- checklist / rating / note / preferiti

Quindi il repository GitHub può restare pubblico senza pubblicare i PIN o l'indirizzo privato direttamente nei sorgenti.
