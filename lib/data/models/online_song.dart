class OnlineSong {
  final String url;
  final String title;
  final String author;
  final String? thumbnailUrl;
  final Duration duration;

  OnlineSong({
    required this.url,
    required this.title,
    required this.author,
    this.thumbnailUrl,
    required this.duration,
  });
}
