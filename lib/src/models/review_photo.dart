class ReviewPhoto {
  const ReviewPhoto({
    required this.localPath,
    this.remoteUrl,
    this.isUploaded = false,
  });

  final String localPath;
  final String? remoteUrl;
  final bool isUploaded;

  Map<String, dynamic> toJson() => {
        'localPath': localPath,
        'remoteUrl': remoteUrl,
        'isUploaded': isUploaded,
      };

  factory ReviewPhoto.fromJson(Map<String, dynamic> json) {
    return ReviewPhoto(
      localPath: json['localPath'] as String? ?? '',
      remoteUrl: json['remoteUrl'] as String?,
      isUploaded: json['isUploaded'] as bool? ?? false,
    );
  }
}
