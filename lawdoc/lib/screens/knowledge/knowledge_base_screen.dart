import 'package:flutter/material.dart';
import '../../data/mock_articles.dart';
import '../../l10n/strings.dart';
import '../../models/article.dart';
import '../../theme/colors.dart';
import '../../widgets/article_card.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  String _tab = 'Semua';
  final _tabKeys = const ['Semua', 'Perceraian', 'Waris', 'Hukum'];

  String _tabLabel(String key) {
    switch (key) {
      case 'Semua': return t('Semua', 'All');
      case 'Perceraian': return t('Perceraian', 'Divorce');
      case 'Waris': return t('Waris', 'Inheritance');
      case 'Hukum': return t('Hukum', 'Law');
      default: return key;
    }
  }

  List<Article> get _articles {
    if (_tab == 'Semua' || _tab == 'Hukum') return mockArticles;
    final map = {
      'Perceraian': ArticleCategory.perceraian,
      'Waris': ArticleCategory.waris,
    };
    final cat = map[_tab];
    return cat == null ? mockArticles : mockArticles.where((a) => a.category == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.knowledgeBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterChips()),
            SliverToBoxAdapter(child: _buildFeaturedCard()),
            SliverToBoxAdapter(child: _buildArticlesSection()),
            SliverToBoxAdapter(child: _buildJalurBelajar()),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Icon(Icons.balance, size: 18, color: AppColors.articleTitle),
          const SizedBox(width: 4),
          const Text('LawDoc',
              style: TextStyle(
                  fontFamily: 'AppleGaramond',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mauve,
                  height: 1.1)),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.navy, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: TextField(
        decoration: InputDecoration(
          hintText: t('Cari topik hukum...', 'Search legal topics...'),
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        itemCount: _tabKeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final key = _tabKeys[i];
          final active = key == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.activeChip : AppColors.inactiveChipBg,
                border: active
                    ? null
                    : Border.all(color: AppColors.inactiveChipBorder),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(_tabLabel(key),
                  style: TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: active ? AppColors.white : AppColors.inactiveChipText)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.knowledgeFeaturedBg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.featuredBadgeBg,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(t('Panduan Lengkap', 'Complete Guide'),
                    style: const TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.featuredBadgeText)),
              ),
              const SizedBox(height: 12),
              Text(featuredSeries.title,
                  style: const TextStyle(
                      fontFamily: 'AppleGaramond',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.25)),
              const SizedBox(height: 8),
              Text(
                t(
                  'Pelajari hak dan kewajiban dalam rumah tangga menurut UU Perkawinan.',
                  'Learn your rights and obligations under Indonesian Marriage Law.',
                ),
                style: const TextStyle(
                    fontFamily: 'SFUIDisplay',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t('Artikel Terbaru', 'Latest Articles'),
                  style: const TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.articleTitle)),
              GestureDetector(
                onTap: () {},
                child: Text(t('Lihat Semua', 'See All'),
                    style: const TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 12,
                        color: AppColors.activeChip,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._articles
              .take(4)
              .map((a) => ArticleCard(
                    article: a,
                    onTap: () => _showArticle(context, a),
                  )),
        ],
      ),
    );
  }

  Widget _buildJalurBelajar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('Jalur Belajar', 'Learning Paths'),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.articleTitle)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModuleCard(
                  module: 'Modul 01',
                  title: t('Waris & Hibah', 'Inheritance & Grants'),
                  icon: Icons.balance,
                  bgColor: AppColors.jalurBelajar1Bg,
                  moduleColor: const Color(0xFF732C5B),
                  titleColor: const Color(0xFF3B002C),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ModuleCard(
                  module: 'Modul 02',
                  title: t('Hukum Bisnis', 'Business Law'),
                  icon: Icons.business_center_outlined,
                  bgColor: AppColors.jalurBelajar2Bg,
                  moduleColor: const Color(0xFF374765),
                  titleColor: const Color(0xFF091B37),
                ),
              ),
            ],
          ),
        ],
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

class _ModuleCard extends StatelessWidget {
  final String module, title;
  final IconData icon;
  final Color bgColor, moduleColor, titleColor;
  const _ModuleCard({
    required this.module,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.moduleColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: titleColor),
          const SizedBox(height: 44),
          Text(module,
              style: TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: moduleColor,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: titleColor)),
        ],
      ),
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(article.category.label,
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.mauve)),
                    ),
                    const SizedBox(height: 10),
                    Text(article.title,
                        style: const TextStyle(
                            fontFamily: 'AppleGaramond',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readMinutes} min · ${article.difficulty}',
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    Text(article.content,
                        style: const TextStyle(
                            fontFamily: 'SFUIDisplay',
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.7)),
                    if (article.sources.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.blush,
                          border: Border(
                            left: BorderSide(color: AppColors.mauve, width: 3),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gavel_outlined,
                                    size: 14, color: AppColors.mauve),
                                const SizedBox(width: 6),
                                const Text(
                                  'SUMBER HUKUM',
                                  style: TextStyle(
                                      fontFamily: 'SFUIDisplay',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.navy,
                                      letterSpacing: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...article.sources.map((s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(
                                              color: AppColors.mauve,
                                              fontWeight: FontWeight.w700)),
                                      Expanded(
                                        child: Text(s,
                                            style: const TextStyle(
                                                fontFamily: 'SFUIDisplay',
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                                height: 1.5)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
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
