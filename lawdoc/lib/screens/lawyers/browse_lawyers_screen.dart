import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_lawyers.dart';
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
  String _filter = 'Semua';
  final _filters = ['Semua', 'Pro bono', 'Perceraian', 'Waris', 'Tanah', 'Utang'];

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
        title: Text('Cari pengacara',
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
              decoration: const InputDecoration(
                hintText: 'Cari nama atau spesialisasi...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: Icon(Icons.mic_none, color: AppColors.textMuted),
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
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final f = _filters[i];
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
                    child: Text(f,
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
                Text('${_filtered.length} pengacara cocok',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                Row(
                  children: [
                    const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('Urutkan',
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
