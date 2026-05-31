class NewsArticle {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String source;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      description: json['description'] ?? json['summary'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image'] ?? json['urlToImage'],
      source: json['source']?['name'] ?? json['source'] ?? 'Unknown',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? json['published_date'] ?? '') ?? DateTime.now(),
    );
  }
}
