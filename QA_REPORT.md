# QA conversione Flutter

## Controlli effettuati nella generazione

- struttura progetto Flutter completa
- `pubspec.yaml` con dipendenze necessarie
- nessun PIN inserito nei sorgenti Flutter
- nessuna service-role key inserita nel frontend
- endpoint Supabase coerenti con V6.5
- parsing dei payload `pin-login` / `trip-api`
- mappatura dati pubblici: 8 quartieri, 42 luoghi, 8 cibi, 22 ristoranti
- GitHub Actions configurata per analyze + test + build + Pages
- itinerario e alloggio restano caricati dal backend dopo login

## Limite del controllo locale

Il container usato per generare il progetto non dispone del Flutter SDK, quindi non è stato possibile eseguire qui `flutter analyze`, `flutter test` o il build Web. Il workflow GitHub incluso eseguirà automaticamente questi tre controlli prima del deploy, e in locale puoi farli con il tuo Flutter 3.47.5.
