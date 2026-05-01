import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/mock_lawyers.dart';
import '../../models/lawyer.dart';
import '../../theme/colors.dart';

class LawyerProfileScreen extends StatelessWidget {
  final String lawyerId;
  const LawyerProfileScreen({super.key, required this.lawyerId});

  Lawyer get _lawyer =>
      mockLawyers.firstWhere((l) => l.id == lawyerId, orElse: () => mockLawyers.first);

  @override
  Widget build(BuildContext context) {
    final l = _lawyer;
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.navyDeep),
        title: Text('Profil pengacara',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.navyDeep),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(lawyer: l),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.navyDeep,
                      child: Text(l.initials,
                          style: GoogleFonts.inter(
                              fontSize: 20, fontWeight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                    const SizedBox(height: 12),
                    Text(l.name,
                        style: GoogleFonts.inter(
                            fontSize: 17, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(l.specialization,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                    if (l.isVerifiedPeradi)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.verifiedBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 14, color: AppColors.verified),
                            const SizedBox(width: 4),
                            Text('Terverifikasi PERADI',
                                style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: AppColors.verifiedText)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _Stat(value: '${l.yearsExp}', unit: 'thn', label: 'Pengalaman'),
                        _Stat(value: '${l.rating}', unit: '${l.reviewCount} ulasan', label: 'Rating'),
                        _Stat(value: '${l.casesCompleted}', unit: '', label: 'Kasus selesai'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tentang',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(l.bio,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: l.languages.map((lang) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.inputBorder),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(lang,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bidang praktek',
                        style: GoogleFonts.inter(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ...l.practiceAreas.map((area) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(area,
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: AppColors.textPrimary)),
                              Text(_caseCount(area),
                                  style: GoogleFonts.inter(
                                      fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _caseCount(String area) {
    final map = {
      'Perceraian & hak asuh': '142 kasus',
      'Hukum waris': '89 kasus',
      'Perjanjian pra-nikah': '53 kasus',
      'Utang piutang & kredit': '95 kasus',
      'Perlindungan konsumen': '64 kasus',
      'Sengketa perbankan': '42 kasus',
      'Sengketa kepemilikan tanah': '210 kasus',
      'Sertifikasi & BPN': '134 kasus',
      'Gugatan tanah warisan': '54 kasus',
      'Gugatan perceraian': '61 kasus',
      'Perlindungan korban KDRT': '32 kasus',
      'Hak asuh & nafkah': '19 kasus',
    };
    return map[area] ?? '';
  }
}

class _Stat extends StatelessWidget {
  final String value, unit, label;
  const _Stat({required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Lawyer lawyer;
  const _BottomBar({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (!lawyer.isProBono)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pilihan konsultasi',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                  Text(lawyer.priceLabel ?? '',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Booking konsultasi →'),
            ),
          ),
        ],
      ),
    );
  }
}
