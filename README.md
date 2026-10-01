# Barcelona Trip 2026 — Flutter conversion

Conversione Flutter/Dart della web app Barcelona 2026.

## Stack

- Flutter / Dart — frontend responsive Web, Android e iOS
- Material 3 — UI light mediterranea
- Supabase Edge Functions — login PIN e API privata
- Supabase PostgreSQL — itinerario, profili, checklist, rating, note e preferiti
- `shared_preferences` — sessione/cache locale
- `geolocator` — sezione **Vicino a me**
- `url_launcher` — apertura Google Maps
- GitHub Actions + GitHub Pages — deploy Web gratuito

Il progetto **non contiene i PIN** dei partecipanti e non contiene service-role key. La publishable key Supabase nel client è intenzionalmente pubblica; le operazioni sensibili passano dalle Edge Functions già configurate.

## Funzioni convertite

- login PIN personale
- sessione persistente
- Home con alloggio, statistiche e programma del giorno
- itinerario condiviso
- modifica itinerario solo per Nicola/admin
- Quartieri
- dettaglio luoghi
- `Vicino a me` con GPS e filtro 500 m / 1 km / 2 km
- Cibo e ristoranti
- rating + note
- `Elimina visita`
- preferiti ristoranti
- ricerca completa luoghi
- recensioni del gruppo nei dettagli
- apertura Google Maps
- cache dell'ultimo bootstrap per lettura offline

## Avvio sul Mac

Dalla cartella del progetto:

```bash
flutter pub get
flutter run -d chrome
```

Con il tuo ambiente Flutter 3.47.5 / Dart 3.13.4 non serve modificare lo SDK constraint.

## Build Web locale

```bash
flutter build web --release --base-href "/barcelona-trip-2026/"
```

Output:

```text
build/web/
```

## GitHub Pages

È già incluso:

```text
.github/workflows/deploy.yml
```

Dopo aver caricato il progetto nel repository `barcelona-trip-2026`:

1. GitHub → **Settings → Pages**
2. Source → **GitHub Actions**
3. push su `main`
4. il workflow esegue automaticamente:
   - `flutter pub get`
   - `flutter analyze`
   - `flutter test`
   - `flutter build web --release`
   - deploy GitHub Pages

URL previsto:

```text
https://<username>.github.io/barcelona-trip-2026/
```

## Struttura

```text
lib/
├── main.dart
├── app.dart
├── models/
│   └── models.dart
├── services/
│   ├── backend_service.dart
│   ├── location_service.dart
│   └── maps_service.dart
├── state/
│   ├── trip_controller.dart
│   └── trip_scope.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   └── common_widgets.dart
└── screens/
    ├── login_screen.dart
    ├── shell_screen.dart
    ├── home_screen.dart
    ├── itinerary_screen.dart
    ├── neighborhoods_screen.dart
    ├── nearby_screen.dart
    ├── food_screen.dart
    ├── all_places_screen.dart
    ├── place_detail_screen.dart
    ├── profile_screen.dart
    └── admin_itinerary_screen.dart
```

## Backend già collegato

Il client usa le Edge Functions esistenti:

```text
/functions/v1/pin-login
/functions/v1/trip-api
```

Il login restituisce un token applicativo. `trip-api` valida il token server-side prima di restituire itinerario, alloggio e dati condivisi.
