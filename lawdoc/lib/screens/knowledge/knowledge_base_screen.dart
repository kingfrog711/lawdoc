import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_articles.dart';
import '../../models/article.dart';
import '../../theme/colors.dart';
import '../../widgets/article_card.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  String _tab = 'Populer';
  final _tabs = ['Populer', 'Perceraian', 'Waris', 'Utang', 'Tanah'];

  List<Article> get _articles {
    if (_tab == 'Populer') return mockArticles;
    final map = {
      'Perceraian': ArticleCategory.perceraian,
      'Waris': ArticleCategory.waris,
      'Utang': ArticleCategory.utang,
      'Tanah': ArticleCategory.tanah,
    };
    final cat = map[_tab];
    return cat == null ? mockArticles : mockArticles.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Belajar',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('Bahasa sederhana, tanpa jargon hukum.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.navyDeep),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured series
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E2D50), Color(0xFF162A4A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold.withAlpha(120)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('SERI · DASAR HUKUM',
                          style: GoogleFonts.inter(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: AppColors.gold, letterSpacing: 0.8)),
                    ),
                    const SizedBox(height: 10),
                    Text(featuredSeries.title,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColors.white, height: 1.3)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('${featuredSeries.totalChapters} bab',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textOnDarkMuted)),
                        const SizedBox(width: 8),
                        Text('${featuredSeries.totalMinutes} menit',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textOnDarkMuted)),
                        const SizedBox(width: 8),
                        Text('${featuredSeries.completedChapters} dari ${featuredSeries.totalChapters} selesai',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.gold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: featuredSeries.completedChapters / featuredSeries.totalChapters,
                        backgroundColor: AppColors.white.withAlpha(30),
                        valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tab filter
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final t = _tabs[i];
                  final active = t == _tab;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.navyDeep : AppColors.white,
                        border: Border.all(
                          color: active ? AppColors.navyDeep : AppColors.inputBorder,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t,
                          style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: active ? AppColors.white : AppColors.textPrimary)),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Artikel terbaru',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _articles.map((a) => ArticleCard(
                  article: a,
                  onTap: () => _showArticle(context, a),
                )).toList(),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showArticle(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ArticleSheet(article: article),
    );
  }
}

class _ArticleSheet extends StatelessWidget {
  final Article article;
  const _ArticleSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.category.label,
                        style: GoogleFonts.inter(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: AppColors.gold, letterSpacing: 0.8)),
                    const SizedBox(height: 6),
                    Text(article.title,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary, height: 1.3)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text('${article.readMinutes} menit · ${article.difficulty}',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                    const Divider(height: 28),
                    Text(article.content,
                        style: GoogleFonts.inter(
                            fontSize: 15, color: AppColors.textPrimary, height: 1.7)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
