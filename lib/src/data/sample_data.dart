import '../models/gamification.dart';
import '../models/place.dart';
import '../models/review.dart';

const samplePlaces = <Place>[
  Place(
    id: 'toilet-1',
    name: 'Jardin Public Restroom',
    type: PlaceType.toilet,
    distanceMeters: 120,
    address: 'Near the north gate',
    isFree: true,
    isOpen: true,
    isWheelchairAccessible: true,
    cleanlinessScore: 4.2,
    trustScore: 92,
    verifiedMinutesAgo: 35,
    reviewCount: 48,
    latitude: 48.8571,
    longitude: 2.3513,
    hasBabyChanging: true,
  ),
  Place(
    id: 'water-1',
    name: 'Stone Drinking Fountain',
    type: PlaceType.fountain,
    distanceMeters: 210,
    address: 'Main square, beside the kiosk',
    isFree: true,
    isOpen: true,
    isWheelchairAccessible: true,
    cleanlinessScore: 4.6,
    trustScore: 88,
    verifiedMinutesAgo: 12,
    reviewCount: 31,
    latitude: 48.8559,
    longitude: 2.3534,
    isBottleFriendly: true,
  ),
  Place(
    id: 'toilet-2',
    name: 'Metro Station Public WC',
    type: PlaceType.toilet,
    distanceMeters: 460,
    address: 'Lower concourse',
    isFree: false,
    isOpen: true,
    isWheelchairAccessible: false,
    cleanlinessScore: 3.5,
    trustScore: 74,
    verifiedMinutesAgo: 80,
    reviewCount: 65,
    latitude: 48.8548,
    longitude: 2.3497,
  ),
];

const sampleReviews = <Review>[
  Review(
    authorName: 'City Scout',
    comment: 'Open and clean. The baby changing table was usable.',
    rating: 4.5,
    minutesAgo: 35,
    tags: ['Open', 'Clean', 'Baby changing'],
  ),
  Review(
    authorName: 'Fountain Guardian',
    comment: 'Water pressure is good and bottle refill is easy.',
    rating: 5,
    minutesAgo: 12,
    tags: ['Working', 'Bottle-friendly'],
  ),
];

const contributionActions = <ContributionAction>[
  ContributionAction(label: 'Confirm open', points: 2, icon: '✅'),
  ContributionAction(label: 'Add quick review', points: 5, icon: '⭐'),
  ContributionAction(label: 'Upload photo', points: 8, icon: '📷'),
  ContributionAction(label: 'Report issue', points: 5, icon: '🚩'),
  ContributionAction(label: 'Add new spot', points: 15, icon: '📍'),
];

const userProgress = UserProgress(
  points: 145,
  levelName: 'City Scout',
  nextLevelPoints: 250,
  badges: [
    Badge(name: 'First Flush', description: 'Reviewed your first public toilet.', icon: '🚽'),
    Badge(name: 'Water Finder', description: 'Reviewed your first fountain.', icon: '💧'),
    Badge(name: 'Cleanliness Critic', description: 'Submitted 10 cleanliness ratings.', icon: '🧼'),
  ],
);
