import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  static int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/lawyers')) return 1;
    if (location.startsWith('/chat')) return 2;
    if (location.startsWith('/knowledge')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBg,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, label: 'Beranda', index: 0, current: currentIndex,
                    onTap: () => context.go('/home')),
                _NavItem(icon: Icons.search, label: 'Cari', index: 1, current: currentIndex,
                    onTap: () => context.go('/lawyers')),
                _TanyaAiButton(active: currentIndex == 2, onTap: () => context.go('/chat')),
                _NavItem(icon: Icons.menu_book_outlined, label: 'Belajar', index: 3, current: currentIndex,
                    onTap: () => context.go('/knowledge')),
                _NavItem(icon: Icons.person_outline, label: 'Saya', index: 4, current: currentIndex,
                    onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label,
    required this.index, required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22,
                color: active ? AppColors.bottomNavActive : AppColors.bottomNavInactive),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: active ? AppColors.bottomNavActive : AppColors.bottomNavInactive,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _TanyaAiButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _TanyaAiButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: active ? AppColors.gold : AppColors.navyDeep,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyDeep.withAlpha(60),
                    blurRadius: 8, offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.white),
            ),
            const SizedBox(height: 2),
            Text('Tanya AI',
                style: GoogleFonts.inter(
                    fontSize: 10,
                    color: active ? AppColors.gold : AppColors.bottomNavActive,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
