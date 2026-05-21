# FlowSpot — Toilets & Water

FlowSpot is a Flutter mobile app for finding nearby public toilets and drinking fountains, with reviews, trust signals, and gamified community contributions.

## MVP included

- Flutter app shell
- Centralized FlowSpot design system
- Real OpenStreetMap map preview via `flutter_map`
- Bottom-sheet map marker previews
- Device location lookup with Paris fallback
- Nearby public toilets and fountains from OpenStreetMap/Overpass
- Recently verified sorting
- Trust score algorithm foundation
- Offline cache for the last successful nearby results
- Supabase backend scaffolding
- Photo upload scaffolding
- Contributor leaderboard scaffold
- AdMob monetization scaffolding

## Design system

Theme files live in `lib/src/theme`:

- `app_colors.dart`
- `app_spacing.dart`
- `app_radius.dart`
- `app_typography.dart`
- `app_theme.dart`

Design direction:
- deep teal primary
- soft civic background
- rounded cards
- calm utility typography
- trust-oriented color semantics

## Monetization philosophy

FlowSpot should monetize without harming utility.

Recommended ad strategy:
- lightweight banner ads
- contextual native ads
- no aggressive interstitials
- never interrupt emergency navigation
- prioritize retention over short-term CPM
