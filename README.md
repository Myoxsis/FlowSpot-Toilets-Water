# FlowSpot — Toilets & Water

FlowSpot is a Flutter mobile app for finding nearby public toilets and drinking fountains, with reviews, trust signals, and gamified community contributions.

## MVP included

- Flutter app shell
- Home screen with map-style placeholder and nearby places
- Public toilet and fountain sample data
- Place detail screen
- Review summaries and quick-review attributes
- Gamification profile with points, levels, badges, and contribution actions
- Ad placement placeholders for an ads-first monetization model

## Run locally

```bash
flutter pub get
flutter run
```

## Product direction

FlowSpot should prioritize speed and trust:

1. Find the nearest useful spot quickly
2. Show whether it was verified recently
3. Let users review in a few taps
4. Reward useful community contributions
5. Keep ads lightweight and non-blocking

## Next milestones

- Add real map integration with `flutter_map` or Google Maps
- Connect OpenStreetMap / Overpass data
- Add geolocation
- Persist reviews with Supabase or Firebase
- Add moderation and anti-spam rules
- Integrate AdMob banners/native placements
