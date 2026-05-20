class Review {
  const Review({
    required this.authorName,
    required this.comment,
    required this.rating,
    required this.minutesAgo,
    required this.tags,
  });

  final String authorName;
  final String comment;
  final double rating;
  final int minutesAgo;
  final List<String> tags;
}
