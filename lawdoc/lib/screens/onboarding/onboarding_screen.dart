import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../widgets/lawdoc_logo.dart';
import '../../widgets/lang_toggle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      tag: 'PERDATA · CIVIL LAW',
      headline: 'Hak Anda,\ndidampingi.',
      body: 'Bantuan hukum perdata, mudah diakses.',
      sub: 'Konsultasi cepat dengan AI, terhubung ke LBH atau pengacara berpengalaman — tanpa biaya kejutan.',
    ),
    _OnboardPage(
      tag: 'PRIVASI · PRIVACY',
      headline: 'Rahasia Anda\naman.',
      body: 'AI berjalan di perangkat Anda.',
      sub: 'Percakapan hukum Anda tidak pernah meninggalkan ponsel — diproses lokal dengan Gemma 4.',
    ),
    _OnboardPage(
      tag: 'AKSES · ACCESS',
      headline: 'Pengacara\nterverifikasi.',
      body: 'PERADI-verified, harga transparan.',
      sub: 'Temukan pengacara berpengalaman atau dapatkan bantuan gratis melalui jaringan LBH.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LawDocLogo(),
                  const LangToggle(),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _PageContent(page: _pages[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(_pages.length, (i) => _Dot(active: i == _page)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Mulai konsultasi gratis →'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: Text('Saya sudah punya akun',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
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

class _PageContent extends StatelessWidget {
  final _OnboardPage page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withAlpha(120)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(page.tag,
                      style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: AppColors.gold, letterSpacing: 1)),
                ),
                const Spacer(),
                Text(page.headline,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 26, fontWeight: FontWeight.w700,
                        color: AppColors.white, height: 1.2)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(page.body,
              style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Text(page.sub,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
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
      width: active ? 20 : 6,
      height: 6,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.navyDeep : AppColors.navyDeep.withAlpha(60),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _OnboardPage {
  final String tag, headline, body, sub;
  const _OnboardPage({required this.tag, required this.headline, required this.body, required this.sub});
}
