import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_lawyers.dart';
import '../../l10n/strings.dart';
import '../../models/lawyer.dart';
import '../../theme/colors.dart';
import '../../widgets/lang_toggle.dart';
import '../../widgets/lawyer_card.dart';

class BrowseLawyersScreen extends StatefulWidget {
  const BrowseLawyersScreen({super.key});

  @override
  State<BrowseLawyersScreen> createState() => _BrowseLawyersScreenState();
}

class _BrowseLawyersScreenState extends State<BrowseLawyersScreen> {
  // Filter is stored by key (Indonesian-stable). Display labels go through t().
  String _filter = 'Semua';
  final _filterKeys = const ['Semua', 'Pro bono', 'Perceraian', 'Waris', 'Tanah', 'Utang'];

  String _filterLabel(String key) {
    switch (key) {
      case 'Semua': return t('Semua', 'All');
      case 'Pro bono': return t('Pro bono', 'Pro bono');
      case 'Perceraian': return t('Perceraian', 'Divorce');
      case 'Waris': return t('Waris', 'Inheritance');
      case 'Tanah': return t('Tanah', 'Land');
      case 'Utang': return t('Utang', 'Debt');
      default: return key;
    }
  }

  List<Lawyer> get _filtered {
    if (_filter == 'Semua') return mockLawyers;
    if (_filter == 'Pro bono') return mockLawyers.where((l) => l.isProBono).toList();
    return mockLawyers.where((l) => l.areas.any((a) => a.contains(_filter))).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(t('Cari pengacara', 'Find a lawyer'),
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        actions: const [LangToggle(), SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: t('Cari nama atau spesialisasi...',
                    'Search by name or specialization...'),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: const Icon(Icons.mic_none, color: AppColors.textMuted),
              ),
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filterKeys.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filterKeys[i];
                final active = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.navyDeep : AppColors.white,
                      border: Border.all(
                        color: active ? AppColors.navyDeep : AppColors.inputBorder,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_filterLabel(f),
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w500,
                            color: active ? AppColors.white : AppColors.textPrimary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    t('${_filtered.length} pengacara cocok',
                        '${_filtered.length} lawyers match'),
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                Row(
                  children: [
                    const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(t('Urutkan', 'Sort'),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: _filtered.length,
              itemBuilder: (context, i) => LawyerCard(
                lawyer: _filtered[i],
                onTap: () => context.go('/lawyers/${_filtered[i].id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
