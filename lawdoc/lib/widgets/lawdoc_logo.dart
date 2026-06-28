import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LawDocLogo extends StatelessWidget {
  final bool dark;
  const LawDocLogo({super.key, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final textColor = dark ? AppColors.white : AppColors.navy;
    final iconColor = dark ? AppColors.white.withAlpha(180) : AppColors.mauve;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.balance, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text('LawDoc', style: TextStyle(
          fontFamily: 'AppleGaramond',
          color: textColor, fontSize: 20, fontWeight: FontWeight.w700,
        )),
      ],
    );
  }
}
