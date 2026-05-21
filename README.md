# FlowSpot — Toilets & Water

FlowSpot is a Flutter mobile app for finding nearby public toilets and drinking fountains, with reviews, trust signals, and gamified community contributions.

## MVP included

- Flutter app shell
- Real OpenStreetMap map preview via `flutter_map`
- Bottom-sheet map marker previews
- Device location lookup with Paris fallback
- Nearby public toilets and fountains from OpenStreetMap/Overpass
- Recently verified sorting
- Trust score algorithm foundation
- Offline cache for the last successful nearby results
- Supabase backend scaffolding
- Place detail screen
- Quick-review bottom sheet with structured tags
- Local persistence for quick reviews, favorites, and contribution points
- Review summaries and quick-review attributes
- Gamification profile with points, levels, badges, and contribution actions
- Ad placement placeholders for an ads-first monetization model

## Run locally

```bash
flutter pub get
flutter run
```

## Supabase setup

Replace the placeholder values in:

- `lib/src/services/supabase_service.dart`

with your:
- Supabase URL
- Supabase anon key

Future backend targets:
- shared reviews
- shared trust score signals
- contributor leaderboard
- image uploads
- moderation queue

## Product direction

FlowSpot should prioritize speed and trust:

1. Find the nearest useful spot quickly
2. Show whether it was verified recently
3. Let users review in a few taps
4. Reward useful community contributions
5. Keep ads lightweight and non-blocking
