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

  Map<String, dynamic> toJson() => {
        'authorName': authorName,
        'comment': comment,
        'rating': rating,
        'minutesAgo': minutesAgo,
        'tags': tags,
      };

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['authorName'] as String? ?? 'Anonymous',
      comment: json['comment'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      minutesAgo: json['minutesAgo'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((tag) => tag.toString()).toList(),
    );
  }
}
