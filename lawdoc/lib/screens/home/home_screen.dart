import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeScreenBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blush rectangle — top-right background element
            Positioned(
              top: -40,
              right: -60,
              child: Container(
                width: 320,
                height: 380,
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo row
                  Row(
                    children: [
                      const Icon(Icons.balance, size: 18, color: Color(0xFF041632)),
                      const SizedBox(width: 4),
                      const Text(
                        'LawDoc',
                        style: TextStyle(
                          fontFamily: 'AppleGaramond',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mauve,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Profile card
                  const _ProfileCard(),

                  const SizedBox(height: 16),

                  // "Explore"
                  const Text(
                    'Explore',
                    style: TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chat / Cerita banner
                  _BannerCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C2045), Color(0xFF63103F), Color(0xFF7A003A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    title: t(
                      'Punya masalah hukum?\nCeritakan disini',
                      'Got a legal issue?\nTell us here',
                    ),
                    subtitle: t(
                      'AI akan bantu Anda dalam memahami situasi terkait dalam bahasa sederhana',
                      'AI will help you understand your situation in plain language',
                    ),
                    ctaLabel: t('Mulai bicara →', 'Start talking →'),
                    ctaColor: const Color(0xFF530044),
                    onTap: () => context.go('/chat'),
                  ),

                  const SizedBox(height: 16),

                  // LBH banner
                  _BannerCard(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF192342), Color(0xFF262C41), Color(0xFF686868)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    title: t('Butuh bantuan lbh?', 'Need LBH assistance?'),
                    subtitle: t(
                      'Survey akan mencari LBH terdekat di sekitar mu dan sesuai budget',
                      'Survey will find the nearest LBH based on your location and budget',
                    ),
                    ctaLabel: t('Mulai cari →', 'Start searching →'),
                    ctaColor: AppColors.navy,
                    onTap: () => context.go('/lawyers'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  static const _greenChips = [
    'Katolik',
    'Duda',
    'Punya bisnis',
    'Bapak dari 2 anak',
  ];
  static const _redChips = [
    'Domisili belum terverifikasi',
    'Umur belum terverifikasi',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.profileCardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blush,
                  border: Border.all(color: const Color(0xFF960064), width: 1),
                ),
                child: const Icon(Icons.person, color: AppColors.mauve, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('Selamat siang,', 'Good afternoon,'),
                      style: TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 13,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const Text(
                      'Pak Pengguna',
                      style: TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.verifiedBadgeBorder
                            .withValues(alpha: 0.33),
                        border: Border.all(
                            color: AppColors.verifiedBadgeBorder),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              size: 12,
                              color: AppColors.verifiedBadgeBorder),
                          const SizedBox(width: 4),
                          Text(
                            t('Terverifikasi', 'Verified'),
                            style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.verifiedBadgeBorder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _greenChips
                .map((chip) => _ProfileChip(
                      label: chip,
                      fillAlpha: 0.33,
                      fillColor: const Color(0xFF96C8B2),
                      borderColor: AppColors.profileChipGreen,
                      textColor: AppColors.profileChipGreen,
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _redChips
                .map((chip) => _ProfileChip(
                      label: chip,
                      fillAlpha: 0.33,
                      fillColor: const Color(0xFFFF474A),
                      borderColor: AppColors.profileChipRed,
                      textColor: AppColors.profileChipRed,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String label;
  final double fillAlpha;
  final Color fillColor, borderColor, textColor;

  const _ProfileChip({
    required this.label,
    required this.fillAlpha,
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: fillColor.withValues(alpha: fillAlpha),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SFUIDisplay',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Banner card ───────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final Gradient gradient;
  final String title, subtitle, ctaLabel;
  final Color ctaColor;
  final VoidCallback onTap;

  const _BannerCard({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.ctaColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 188,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 13,
                      color: AppColors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ctaColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ctaLabel,
                style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
