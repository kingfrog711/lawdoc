import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/colors.dart';

class LangToggle extends StatelessWidget {
  final bool dark;
  const LangToggle({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final borderColor = dark ? AppColors.white.withAlpha(80) : AppColors.mauve.withAlpha(100);
    final activeText = dark ? AppColors.burgundy : AppColors.white;
    final inactiveText = dark ? AppColors.white.withAlpha(180) : AppColors.textSecondary;
    final activeBg = dark ? AppColors.white : AppColors.burgundy;

    return ValueListenableBuilder<bool>(
      valueListenable: langIsId,
      builder: (context, isId, _) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Pill(
              label: 'ID',
              active: isId,
              activeBg: activeBg,
              activeText: activeText,
              inactiveText: inactiveText,
              onTap: () => langIsId.value = true,
            ),
            _Pill(
              label: 'EN',
              active: !isId,
              activeBg: activeBg,
              activeText: activeText,
              inactiveText: inactiveText,
              onTap: () => langIsId.value = false,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeBg, activeText, inactiveText;
  final VoidCallback onTap;
  const _Pill({required this.label, required this.active, required this.activeBg,
    required this.activeText, required this.inactiveText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          fontFamily: 'SFUIDisplay',
          fontSize: 11, fontWeight: FontWeight.w700,
          color: active ? activeText : inactiveText,
        )),
      ),
    );
  }
}
