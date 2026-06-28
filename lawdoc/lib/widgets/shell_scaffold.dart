import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/strings.dart';
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
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: t('Beranda', 'Home'),
                  index: 0,
                  current: currentIndex,
                  onTap: () => context.go('/home'),
                ),
                _NavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: t('Cari', 'Find'),
                  index: 1,
                  current: currentIndex,
                  onTap: () => context.go('/lawyers'),
                ),
                _ChatFab(active: currentIndex == 2, onTap: () => context.go('/chat')),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: t('Belajar', 'Learn'),
                  index: 3,
                  current: currentIndex,
                  onTap: () => context.go('/knowledge'),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: t('Saya', 'Me'),
                  index: 4,
                  current: currentIndex,
                  onTap: () {},
                ),
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
  final IconData activeIcon;
  final String label;
  final int index, current;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
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
            Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active ? AppColors.bottomNavActive : AppColors.bottomNavInactive,
            ),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontFamily: 'SFUIDisplay',
                    fontSize: 10,
                    color: active ? AppColors.bottomNavActive : AppColors.bottomNavInactive,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _ChatFab extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _ChatFab({required this.active, required this.onTap});

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
                color: AppColors.fabBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
