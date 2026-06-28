import 'package:flutter/material.dart';
import '../models/lawyer.dart';
import '../theme/colors.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;

  const LawyerCard({super.key, required this.lawyer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 3.2),
            blurRadius: 3.2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(initials: lawyer.initials),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(lawyer.name,
                            style: const TextStyle(
                                fontFamily: 'SFUIDisplay',
                                fontSize: 15, fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                      ),
                      if (lawyer.isVerifiedPeradi)
                        const Icon(Icons.verified, size: 16, color: AppColors.verified),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(lawyer.specialization,
                      style: const TextStyle(
                          fontFamily: 'SFUIDisplay',
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Badge(label: '${lawyer.yearsExp} thn', color: const Color(0xFFFFF3E0)),
                      const SizedBox(width: 6),
                      _Badge(
                        label: '${(lawyer.rating * 10).round()}%',
                        color: AppColors.blush,
                      ),
                      if (lawyer.isProBono) ...[
                        const SizedBox(width: 6),
                        _ProBonoBadge(),
                      ],
                    ],
                  ),
                  if (lawyer.organization != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.business_outlined,
                            size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(lawyer.organization!,
                              style: const TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 11, color: AppColors.textMuted),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      lawyer.isProBono
                          ? const Text('Gratis (LBH)',
                              style: TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.burgundy))
                          : Text(lawyer.priceLabel ?? '',
                              style: const TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.pilihBtn,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Pilih',
                              style: TextStyle(
                                  fontFamily: 'SFUIDisplay',
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                  color: AppColors.white)),
                        ),
                      ),
                    ],
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

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108, height: 120,
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: const TextStyle(
              fontFamily: 'SFUIDisplay',
              fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.burgundy)),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'SFUIDisplay',
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    );
  }
}

class _ProBonoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.probonoBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text('Pro bono',
          style: TextStyle(
              fontFamily: 'SFUIDisplay',
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.probonoText)),
    );
  }
}
