class Guide {
  final int id;
  final String title;
  final String category;
  final String categoryLabel;
  final String preservationMethod;
  final String content;
  final String smellIndicator;
  final String textureIndicator;
  final String visualIndicator;
  final String author;
  final int totalUpvotes;
  final String? createdAt;
  final String? updatedAt;

  const Guide({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryLabel,
    required this.preservationMethod,
    required this.content,
    required this.smellIndicator,
    required this.textureIndicator,
    required this.visualIndicator,
    required this.author,
    required this.totalUpvotes,
    this.createdAt,
    this.updatedAt,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      categoryLabel: (json['category_label'] ?? '').toString(),
      preservationMethod: (json['preservation_method'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      smellIndicator: (json['smell_indicator'] ?? '').toString(),
      textureIndicator: (json['texture_indicator'] ?? '').toString(),
      visualIndicator: (json['visual_indicator'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      totalUpvotes: (json['total_upvotes'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}