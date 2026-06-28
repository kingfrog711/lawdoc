import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';
import '../../widgets/lang_toggle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;
  final _pageController = PageController();

  static const _pages = [
    (
      id: 'Bantuan yang pantas!',
      en: 'Justice made accessible!',
      subId: 'Konsultasi cepat dengan AI, terhubung dengan banyak LBH dan firma hukum terpercaya.',
      subEn: 'Quick AI consultation, connected to trusted LBH networks and law firms.',
    ),
    (
      id: 'Pengacara terverifikasi.',
      en: 'Verified lawyers.',
      subId: 'PERADI-verified, harga transparan. Temukan pengacara atau dapatkan bantuan gratis.',
      subEn: 'PERADI-verified, transparent pricing. Find a lawyer or get free LBH assistance.',
    ),
    (
      id: 'Hak Anda terlindungi.',
      en: 'Your rights protected.',
      subId: 'Akses informasi hukum kapan saja, di mana saja. Gratis untuk semua.',
      subEn: 'Access legal information anytime, anywhere. Free for everyone.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A2438), Color(0xFF3A1E29), Color(0xFF251219)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [const LangToggle(dark: true)],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      'LawDoc',
                      style: const TextStyle(
                        fontFamily: 'AppleGaramond',
                        fontSize: 120,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mauve,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 96,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, i) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t(_pages[i].id, _pages[i].en),
                                style: const TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.mauve,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                t(_pages[i].subId, _pages[i].subEn),
                                style: const TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mauve,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: List.generate(_pages.length, (i) => _Dot(active: i == _page)),
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.splashCta,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t('Mulai konsultasi gratis →', 'Start free consultation →'),
                            style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/home'),
                          child: Text(
                            t('Saya sudah punya akun', 'I already have an account'),
                            style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.splashTextSecondary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 40 : 14,
      height: 14,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.splashActiveDot : AppColors.mauve,
        borderRadius: BorderRadius.circular(11.25),
      ),
    );
  }
}
