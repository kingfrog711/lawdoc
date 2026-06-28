import 'package:flutter/material.dart';
import '../models/article.dart';
import '../theme/colors.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;

  const ArticleCard({super.key, required this.article, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.blush,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(_categoryIcon(article.category),
                  size: 32, color: AppColors.mauve),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title,
                      style: const TextStyle(
                          fontFamily: 'SFUIDisplay',
                          fontSize: 16, fontWeight: FontWeight.w400,
                          color: AppColors.articleTitle),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.inactiveChipBorder),
                      const SizedBox(width: 3),
                      Text('${article.readMinutes} min',
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 11, color: AppColors.inactiveChipBorder)),
                      const SizedBox(width: 8),
                      Container(
                        width: 4, height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.inactiveChipBorder,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(article.category.label,
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 11, color: AppColors.inactiveChipBorder)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.inactiveChipBorder, size: 16),
          ],
        ),
      ),
    );
  }

  static IconData _categoryIcon(ArticleCategory cat) {
    switch (cat) {
      case ArticleCategory.perceraian: return Icons.favorite_border;
      case ArticleCategory.waris: return Icons.description_outlined;
      case ArticleCategory.utang: return Icons.account_balance_wallet_outlined;
      case ArticleCategory.tanah: return Icons.location_on_outlined;
      default: return Icons.menu_book_outlined;
    }
  }
}
