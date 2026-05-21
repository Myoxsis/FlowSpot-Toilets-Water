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
- Contributor leaderboard scaffold
- AdMob monetization scaffolding
- Place detail screen
- Quick-review bottom sheet with structured tags
- Local persistence for quick reviews, favorites, and contribution points
- Review summaries and quick-review attributes
- Gamification profile with points, levels, badges, and contribution actions

## Monetization philosophy

FlowSpot should monetize without harming utility.

Recommended ad strategy:
- lightweight banner ads
- contextual native ads
- no aggressive interstitials
- never interrupt emergency navigation
- prioritize retention over short-term CPM

Best placements:
- after nearby results
- after review sections
- inside leaderboard/community screens

Avoid:
- launch ads
- fullscreen navigation interruptions
- forced video ads
