class YouTubeVideo {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String publishedAt;

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.publishedAt,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['id']['videoId'] ?? '',
      title: json['snippet']['title'] ?? '',
      description: json['snippet']['description'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['medium']['url'] ?? '',
      channelTitle: json['snippet']['channelTitle'] ?? '',
      publishedAt: json['snippet']['publishedAt'] ?? '',
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
}