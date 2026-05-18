enum ArticleCategory { perceraian, waris, utang, tanah, umum }

extension ArticleCategoryLabel on ArticleCategory {
  String get label {
    switch (this) {
      case ArticleCategory.perceraian: return 'PERCERAIAN';
      case ArticleCategory.waris:      return 'WARIS';
      case ArticleCategory.utang:      return 'UTANG PIUTANG';
      case ArticleCategory.tanah:      return 'SENGKETA TANAH';
      case ArticleCategory.umum:       return 'UMUM';
    }
  }
}

class Article {
  final String id;
  final String title;
  final ArticleCategory category;
  final int readMinutes;
  final String difficulty;
  final String preview;
  final String content;
  final List<String> sources;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.readMinutes,
    required this.difficulty,
    required this.preview,
    required this.content,
    this.sources = const [],
  });
}

class ArticleSeries {
  final String id;
  final String title;
  final String subtitle;
  final int totalChapters;
  final int completedChapters;
  final int totalMinutes;

  const ArticleSeries({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.totalChapters,
    required this.completedChapters,
    required this.totalMinutes,
  });
}
