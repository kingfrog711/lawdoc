import 'package:flutter/material.dart';
import '../../l10n/strings.dart';
import '../../theme/colors.dart';

class ProBonoScreen extends StatefulWidget {
  const ProBonoScreen({super.key});

  @override
  State<ProBonoScreen> createState() => _ProBonoScreenState();
}

class _ProBonoScreenState extends State<ProBonoScreen> {
  final _caseController = TextEditingController();
  final _incomeController = TextEditingController();
  bool _submitted = false;

  List<_Check> _buildChecks() => [
        _Check(
            text: t('Penghasilan keluarga di bawah UMR daerah',
                'Family income below local minimum wage'),
            checked: true),
        _Check(
            text: t('Memiliki KTP / dokumen identitas',
                'Has KTP / identity document'),
            checked: true),
        _Check(
            text: t('Kasus berkategori perdata (bukan pidana)',
                'Case is civil (not criminal)'),
            checked: true),
        _Check(
            text: t('Belum didampingi pengacara lain',
                'No other lawyer assigned yet'),
            checked: false),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.navyDeep),
        title: Text(t('Bantuan hukum gratis', 'Free legal aid'),
            style: const TextStyle(
                fontFamily: 'SFUIDisplay',
                fontSize: 16, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ),
      body: _submitted ? _SuccessView() : _FormView(
        checks: _buildChecks(),
        caseController: _caseController,
        incomeController: _incomeController,
        onSubmit: () => setState(() => _submitted = true),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final List<_Check> checks;
  final TextEditingController caseController, incomeController;
  final VoidCallback onSubmit;

  const _FormView({
    required this.checks,
    required this.caseController,
    required this.incomeController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.amberCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 28, color: AppColors.gold),
                const SizedBox(height: 12),
                Text(
                    t('Hukum tidak boleh\njadi privilese.',
                        'Law should not be\na privilege.'),
                    style: const TextStyle(
                        fontFamily: 'AppleGaramond',
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: AppColors.gold, height: 1.2)),
                const SizedBox(height: 8),
                Text(
                  t(
                    'LawDoc bermitra dengan LBH dan pengacara pro bono untuk mendampingi Anda — tanpa biaya.',
                    'LawDoc partners with LBH and pro bono lawyers to support you, free of charge.',
                  ),
                  style: const TextStyle(
                      fontFamily: 'SFUIDisplay',
                      fontSize: 13, color: AppColors.probonoText, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(t('Syarat kelayakan', 'Eligibility'),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: checks.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        c.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: c.checked ? AppColors.verified : AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(c.text,
                            style: const TextStyle(
                                fontFamily: 'SFUIDisplay',
                                fontSize: 14, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(t('Lengkapi data', 'Fill in your details'),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          Text(t('Jenis kasus', 'Case type'),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: caseController,
            decoration: InputDecoration(
                hintText: t('Sengketa tanah waris', 'Inheritance land dispute')),
          ),
          const SizedBox(height: 14),

          Text(t('Penghasilan / bulan', 'Income / month'),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Rp 2.500.000'),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              child: Text(t('Kirim permohonan →', 'Submit application →')),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: const BoxDecoration(color: AppColors.verifiedBg, shape: BoxShape.circle),
              child: const Icon(Icons.check, size: 36, color: AppColors.verified),
            ),
            const SizedBox(height: 20),
            Text(t('Permohonan terkirim', 'Application submitted'),
                style: const TextStyle(
                    fontFamily: 'AppleGaramond',
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              t(
                'Tim LBH akan menghubungi Anda dalam 1–3 hari kerja untuk verifikasi kelayakan dan penunjukan pengacara.',
                'The LBH team will contact you within 1–3 business days to verify eligibility and assign a lawyer.',
              ),
              style: const TextStyle(
                  fontFamily: 'SFUIDisplay',
                  fontSize: 14, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Check {
  final String text;
  final bool checked;
  const _Check({required this.text, required this.checked});
}
