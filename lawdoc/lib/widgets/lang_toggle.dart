import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class LangToggle extends StatefulWidget {
  final bool dark;
  const LangToggle({super.key, this.dark = false});

  @override
  State<LangToggle> createState() => _LangToggleState();
}

class _LangToggleState extends State<LangToggle> {
  bool _isId = true;

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.dark ? AppColors.white.withAlpha(80) : AppColors.navyDeep.withAlpha(60);
    final activeText = widget.dark ? AppColors.navyDeep : AppColors.white;
    final inactiveText = widget.dark ? AppColors.white.withAlpha(180) : AppColors.navyDeep.withAlpha(120);
    final activeBg = widget.dark ? AppColors.white : AppColors.navyDeep;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(label: 'ID', active: _isId, activeBg: activeBg, activeText: activeText, inactiveText: inactiveText,
              onTap: () => setState(() => _isId = true)),
          _Pill(label: 'EN', active: !_isId, activeBg: activeBg, activeText: activeText, inactiveText: inactiveText,
              onTap: () => setState(() => _isId = false)),
        ],
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
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: active ? activeText : inactiveText,
        )),
      ),
    );
  }
}
