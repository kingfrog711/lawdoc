import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class LawDocLogo extends StatelessWidget {
  final bool dark;
  const LawDocLogo({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.white : AppColors.navyDeep;
    final fg = dark ? AppColors.navyDeep : AppColors.white;
    final textColor = dark ? AppColors.white : AppColors.navyDeep;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.center,
          child: Text('L', style: GoogleFonts.playfairDisplay(
            color: fg, fontSize: 16, fontWeight: FontWeight.w700,
          )),
        ),
        const SizedBox(width: 8),
        Text('LawDoc', style: GoogleFonts.inter(
          color: textColor, fontSize: 16, fontWeight: FontWeight.w600,
        )),
      ],
    );
  }
}
