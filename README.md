# FlowSpot — Toilets & Water

FlowSpot is a Flutter mobile app for finding nearby public toilets and drinking fountains, with reviews, trust signals, and gamified community contributions.

## MVP included

- Flutter app shell
- Real OpenStreetMap map preview via `flutter_map`
- Device location lookup with Paris fallback
- Nearby public toilets and fountains from OpenStreetMap/Overpass
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

## Current data flow

1. The app requests location permission.
2. If permission is denied, it uses Paris as a fallback.
3. The app queries Overpass for:
   - `amenity=toilets`
   - `amenity=drinking_water`
4. If Overpass fails, sample data is shown.

## Next milestones

- Add Android/iOS permission configuration files
- Add real review submission flow
- Persist reviews with Supabase or Firebase
- Add moderation and anti-spam rules
- Integrate AdMob banners/native placements
- Add offline city packs
