import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_lawyers.dart';
import '../../l10n/strings.dart';
import '../../models/lawyer.dart';
import '../../services/session_service.dart';
import '../../theme/colors.dart';
import '../../widgets/lawyer_card.dart';

class BrowseLawyersScreen extends StatefulWidget {
  const BrowseLawyersScreen({super.key});

  @override
  State<BrowseLawyersScreen> createState() => _BrowseLawyersScreenState();
}

class _BrowseLawyersScreenState extends State<BrowseLawyersScreen> {
  String _filter = 'Semua';
  List<String> _contextChips = [];
  final _filterKeys = const ['Semua', 'Pro bono', 'Perceraian', 'Waris', 'Tanah', 'Utang'];

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    final session = await SessionService.load();
    if (!mounted || session == null) return;
    final ctx = session.context;
    final chips = <String>[];
    if (ctx.agama != null) chips.add(ctx.agama!);
    if (ctx.caseType != null) chips.add(ctx.caseType!);
    if (ctx.domicile != null) chips.add(ctx.domicile!);
    setState(() => _contextChips = chips);
  }

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: const Icon(Icons.arrow_back, color: AppColors.navy),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('Scope Anda', 'Your Scope'),
                            style: const TextStyle(
                                fontFamily: 'SFUIDisplay',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.scopeTitle)),
                        Text(
                          t(
                            'LawDoc akan mencari konsultan terbaik untuk Anda.',
                            'LawDoc will find the best consultant for you.',
                          ),
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_contextChips.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _contextChips
                      .map((chip) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.contextChipBorder,
                                  width: 0.84),
                              borderRadius: BorderRadius.circular(25.2),
                              color: AppColors.contextChipBg,
                            ),
                            child: Text(chip,
                                style: const TextStyle(
                                    fontFamily: 'SFUIDisplay',
                                    fontSize: 10,
                                    color: AppColors.contextChipBorder,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: t('Cari nama atau spesialisasi...',
                      'Search by name or specialization...'),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon:
                      const Icon(Icons.mic_none, color: AppColors.textMuted),
                ),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filterKeys.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final f = _filterKeys[i];
                  final active = f == _filter;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? AppColors.mauve : AppColors.white,
                        border: Border.all(
                          color:
                              active ? AppColors.mauve : AppColors.inputBorder,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(_filterLabel(f),
                          style: TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? AppColors.white
                                  : AppColors.textPrimary)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('${_filtered.length} konsultan cocok',
                        '${_filtered.length} lawyers match'),
                    style: const TextStyle(
                        fontFamily: 'SFUIDisplay',
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.sort,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(t('Urutkan', 'Sort'),
                          style: const TextStyle(
                              fontFamily: 'SFUIDisplay',
                              fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: _filtered.length,
                itemBuilder: (context, i) => LawyerCard(
                  lawyer: _filtered[i],
                  onTap: () => context.go('/lawyers/${_filtered[i].id}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
