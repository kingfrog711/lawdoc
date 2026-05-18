import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';
import '../../widgets/lang_toggle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t('Selamat siang,', 'Good afternoon,'),
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                      Text('Pak Budi',
                          style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                  const Spacer(),
                  const LangToggle(),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.navyDeep),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tanya Dulu hero card
              GestureDetector(
                onTap: () => context.go('/chat'),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E2D50), Color(0xFF0E1829)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gold.withAlpha(120)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, size: 10, color: AppColors.gold),
                                const SizedBox(width: 4),
                                Text(t('TANYA DULU · AI', 'ASK FIRST · AI'),
                                    style: GoogleFonts.inter(
                                        fontSize: 9, fontWeight: FontWeight.w700,
                                        color: AppColors.gold, letterSpacing: 0.8)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                          t('Punya masalah hukum?\nCerita dulu, gratis.',
                              'Got a legal issue?\nTalk first, free.'),
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 20, fontWeight: FontWeight.w700,
                              color: AppColors.white, height: 1.3)),
                      const SizedBox(height: 8),
                      Text(
                          t('AI akan bantu pahami situasi Anda dalam bahasa sederhana.',
                              'AI will help you understand your situation in plain language.'),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.textOnDarkMuted)),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.white.withAlpha(20),
                          border: Border.all(color: AppColors.white.withAlpha(60)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(t('Mulai bicara', 'Start talking'),
                                style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w600,
                                    color: AppColors.white)),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 14, color: AppColors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // LBH banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.amberCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t('Bantuan hukum gratis (LBH)', 'Free legal aid (LBH)'),
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(
                              t('Tersedia untuk Anda yang memenuhi syarat penghasilan.',
                                  'Available if you meet the income requirements.'),
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/pro-bono'),
                      child: const Icon(Icons.chevron_right, color: AppColors.gold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Case categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t('Kategori kasus', 'Case categories'),
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () {},
                    child: Text(t('Lihat semua', 'See all'),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.gold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _CategoryCard(icon: Icons.favorite_border, label: t('Perceraian', 'Divorce'), sub: t('Keluarga', 'Family')),
                  _CategoryCard(icon: Icons.account_balance_wallet_outlined, label: t('Utang Piutang', 'Debts'), sub: t('Keuangan', 'Finance')),
                  _CategoryCard(icon: Icons.location_on_outlined, label: t('Sengketa Tanah', 'Land Disputes'), sub: t('Properti', 'Property')),
                  _CategoryCard(icon: Icons.description_outlined, label: t('Waris', 'Inheritance'), sub: t('Keluarga', 'Family')),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  const _CategoryCard({required this.icon, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/chat'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: AppColors.gold),
              const Spacer(),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              Text(sub,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
