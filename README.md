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
- Photo upload scaffolding
- Place detail screen
- Quick-review bottom sheet with structured tags
- Local persistence for quick reviews, favorites, and contribution points
- Review summaries and quick-review attributes
- Gamification profile with points, levels, badges, and contribution actions
- Ad placement placeholders for an ads-first monetization model

## Future photo flow

1. User attaches a toilet/fountain photo
2. Image uploads to Supabase Storage
3. Moderation pipeline validates content
4. Verified photos improve trust score
5. Recent photos increase visibility ranking
