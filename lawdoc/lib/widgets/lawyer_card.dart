import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lawyer.dart';
import '../theme/colors.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;

  const LawyerCard({super.key, required this.lawyer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(initials: lawyer.initials),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(lawyer.name,
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ),
                      if (lawyer.isVerifiedPeradi)
                        const Icon(Icons.verified, size: 16, color: AppColors.verified),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${lawyer.specialization} · ${lawyer.yearsExp} thn pengalaman',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: AppColors.gold),
                      const SizedBox(width: 2),
                      Text('${lawyer.rating} (${lawyer.reviewCount})',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      if (lawyer.isProBono) ...[
                        const SizedBox(width: 8),
                        _ProBonoBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      lawyer.isProBono
                          ? Text('Gratis (LBH)',
                              style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gold))
                          : Text(lawyer.priceLabel ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: AppColors.textSecondary)),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: Size.zero,
                          ),
                          child: Text('Lihat',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
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
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.navyDeep,
      child: Text(initials,
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.white)),
    );
  }
}

class _ProBonoBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.probonoBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('Pro bono',
          style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.probonoText)),
    );
  }
}
