import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/legal_response.dart';
import '../../models/consult_session.dart';
import '../../services/ai_service.dart';
import '../../services/session_service.dart';
import '../../theme/colors.dart';

class TanyaDuluScreen extends StatefulWidget {
  const TanyaDuluScreen({super.key});

  @override
  State<TanyaDuluScreen> createState() => _TanyaDuluScreenState();
}

class _AttachedFile {
  final String name;
  final String content;
  const _AttachedFile({required this.name, required this.content});
}

enum _BackendStatus { checking, live, offline }

class _TanyaDuluScreenState extends State<TanyaDuluScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  ConsultSession? _session;
  bool _sessionLoading = true;
  bool _loading = false;
  _AttachedFile? _attached;
  _BackendStatus _backendStatus = _BackendStatus.checking;

  @override
  void initState() {
    super.initState();
    _initSession();
    _checkBackend();
  }

  Future<void> _initSession() async {
    final existing = await SessionService.load();
    if (!mounted) return;
    setState(() {
      _session = existing ?? ConsultSession.fresh();
      _sessionLoading = false;
    });
  }

  Future<void> _checkBackend() async {
    final live = await AiService.checkBackend();
    if (!mounted) return;
    setState(() {
      _backendStatus = live ? _BackendStatus.live : _BackendStatus.offline;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final Uint8List? bytes = file.bytes;
    if (bytes == null) return;
    setState(() {
      _attached = _AttachedFile(name: file.name, content: String.fromCharCodes(bytes));
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attached == null) || _loading || _session == null) return;

    final displayText = text.isNotEmpty ? text : 'Tolong analisa dokumen yang saya lampirkan.';
    final attachedFile = _attached;
    _controller.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      text: displayText,
      attachedFileName: attachedFile?.name,
      timestamp: DateTime.now(),
    );

    setState(() {
      _session = _session!.copyWith(
        messages: [..._session!.messages, userMsg],
      );
      _loading = true;
      _attached = null;
    });
    _scrollToBottom();

    final result = await AiService.consult(
      displayText,
      _session!,
      documentText: attachedFile?.content,
    );

    if (!mounted) return;

    if (!result.success) {
      final errorMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        isUser: false,
        text: 'Model sedang tidak tersedia, coba lagi nanti.',
        timestamp: DateTime.now(),
        isSystemMessage: true,
      );
      setState(() {
        _session = _session!.copyWith(messages: [..._session!.messages, errorMsg]);
        _loading = false;
        _backendStatus = _BackendStatus.offline;
      });
      await SessionService.save(_session!);
      _scrollToBottom();
      return;
    }

    final resp = result.response!;
    final aiMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_ai',
      isUser: false,
      text: resp.message,
      consultStructured: resp.structured?.hasContent == true ? resp.structured : null,
      timestamp: DateTime.now(),
      fromBackend: true,
    );

    final updatedSession = _session!.copyWith(
      context: resp.contextUpdate,
      messages: [..._session!.messages, aiMsg],
    );

    setState(() {
      _session = updatedSession;
      _loading = false;
      _backendStatus = _BackendStatus.live;
    });

    await SessionService.save(_session!);
    _scrollToBottom();
  }

  Future<void> _resetSession() async {
    await SessionService.clear();
    setState(() {
      _session = ConsultSession.fresh();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showEditContextSheet() {
    if (_session == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditContextSheet(
        current: _session!.context,
        onSave: (updated) {
          final systemNote = ChatMessage(
            id: '${DateTime.now().millisecondsSinceEpoch}_ctx',
            isUser: false,
            text: '📝 Informasi diperbarui.',
            timestamp: DateTime.now(),
            isSystemMessage: true,
          );
          setState(() {
            _session = _session!.copyWith(
              context: updated,
              messages: [..._session!.messages, systemNote],
            );
          });
          SessionService.save(_session!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionLoading || _session == null) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.navyDeep)),
      );
    }

    final ctx = _session!.context;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.navyDeep),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusDot(status: _backendStatus),
                const SizedBox(width: 6),
                Text(
                  'Tanya Dulu',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                if (ctx.caseType != null)
                  _CaseTypeBadge(caseType: ctx.caseType!)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.navyDeep.withAlpha(60)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BETA',
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep,
                          letterSpacing: 0.8),
                    ),
                  ),
              ],
            ),
            Text(
              _statusSubtitle,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, size: 20, color: AppColors.textSecondary),
            tooltip: 'Mulai sesi baru',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Mulai sesi baru?',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  content: Text('Riwayat percakapan ini akan dihapus.',
                      style: GoogleFonts.inter(fontSize: 14)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus & Mulai Baru',
                            style: TextStyle(color: Color(0xFFEF4444)))),
                  ],
                ),
              );
              if (confirmed == true) _resetSession();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.chatDisclaimerBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bukan pengganti pengacara. Gunakan jawaban AI untuk memahami situasi, lalu hubungi pengacara untuk tindakan resmi.',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.probonoText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          // Context bar (shows once any value is extracted)
          if (ctx.hasAny)
            _ContextBar(context: ctx, onEdit: _showEditContextSheet),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _session!.messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_loading && i == _session!.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _session!.messages[i]);
              },
            ),
          ),

          // Input area
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_attached != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FileChip(
                      name: _attached!.name,
                      onRemove: () => setState(() => _attached = null),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _attached != null
                              ? AppColors.navyDeep.withAlpha(20)
                              : AppColors.cream,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _attached != null
                                ? AppColors.navyDeep
                                : AppColors.navyDeep.withAlpha(50),
                          ),
                        ),
                        child: Icon(
                          Icons.attach_file,
                          size: 18,
                          color: _attached != null
                              ? AppColors.navyDeep
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _attached != null
                              ? 'Tanya tentang dokumen ini...'
                              : 'Ceritakan masalah Anda...',
                          suffixIcon:
                              const Icon(Icons.mic_none, color: AppColors.textMuted),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: AppColors.navyDeep, shape: BoxShape.circle),
                        child: const Icon(Icons.send, color: AppColors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _statusSubtitle {
    switch (_backendStatus) {
      case _BackendStatus.checking:
        return 'Menghubungkan ke AI...';
      case _BackendStatus.live:
        return 'Perdata AI · Aktif';
      case _BackendStatus.offline:
        return 'Model tidak tersedia';
    }
  }
}

// ── Context bar ────────────────────────────────────────────────────────────────

class _ContextBar extends StatelessWidget {
  final SessionContextModel context;
  final VoidCallback onEdit;
  const _ContextBar({required this.context, required this.onEdit});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.confirmed
            ? AppColors.navyDeep.withAlpha(10)
            : AppColors.amberCard.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.confirmed
              ? AppColors.navyDeep.withAlpha(35)
              : AppColors.gold.withAlpha(100),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (context.agama != null)
                  _ContextPill(
                      label: context.agama!, icon: Icons.account_circle_outlined),
                if (context.domicile != null)
                  _ContextPill(
                      label: context.domicile!, icon: Icons.location_on_outlined),
                if (context.budget != null)
                  _ContextPill(
                      label: _budgetLabel(context.budget!),
                      icon: Icons.payments_outlined),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.edit_outlined,
                  size: 15, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  static String _budgetLabel(String b) => const {
        'pro_bono': 'Pro bono',
        '<500rb': '< Rp500rb',
        '500rb-2jt': 'Rp500rb–2jt',
        '>2jt': '> Rp2jt',
      }[b] ??
      b;
}

class _ContextPill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _ContextPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.navyDeep),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navyDeep)),
        ],
      ),
    );
  }
}

// ── Edit context bottom sheet ──────────────────────────────────────────────────

class _EditContextSheet extends StatefulWidget {
  final SessionContextModel current;
  final ValueChanged<SessionContextModel> onSave;
  const _EditContextSheet({required this.current, required this.onSave});

  @override
  State<_EditContextSheet> createState() => _EditContextSheetState();
}

class _EditContextSheetState extends State<_EditContextSheet> {
  late String? _agama;
  late String? _budget;
  late TextEditingController _domicileCtrl;

  static const _agamaOptions = ['Islam', 'Kristen', 'Hindu', 'Buddha', 'Konghucu'];
  static const _budgetOptions = [
    ('pro_bono', 'Pro bono / LBH'),
    ('<500rb', '< Rp500.000'),
    ('500rb-2jt', 'Rp500rb – Rp2jt'),
    ('>2jt', '> Rp2.000.000'),
  ];

  @override
  void initState() {
    super.initState();
    _agama = widget.current.agama;
    _budget = widget.current.budget;
    _domicileCtrl = TextEditingController(text: widget.current.domicile ?? '');
  }

  @override
  void dispose() {
    _domicileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perbarui Informasi',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
          const SizedBox(height: 4),
          Text('Perubahan akan berlaku pada pesan berikutnya.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Agama
          Text('Agama',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _agamaOptions.map((a) {
              final selected = _agama == a;
              return ChoiceChip(
                label: Text(a,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: selected ? AppColors.white : AppColors.textPrimary)),
                selected: selected,
                selectedColor: AppColors.navyDeep,
                onSelected: (_) => setState(() => _agama = a),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Domisili
          Text('Domisili',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _domicileCtrl,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Contoh: Jakarta, Surabaya, Makassar...',
              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Budget
          Text('Kemampuan Biaya',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          ...(_budgetOptions.map((opt) {
            final (value, label) = opt;
            final selected = _budget == value;
            return InkWell(
              onTap: () => setState(() => _budget = value),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppColors.navyDeep : AppColors.textMuted,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.navyDeep,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(label, style: GoogleFonts.inter(fontSize: 13)),
                  ],
                ),
              ),
            );
          })),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyDeep,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final updated = widget.current.copyWith(
                  agama: _agama,
                  domicile: _domicileCtrl.text.trim().isEmpty
                      ? null
                      : _domicileCtrl.text.trim(),
                  budget: _budget,
                );
                Navigator.pop(context);
                widget.onSave(updated);
              },
              child: Text('Simpan', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Case type badge ────────────────────────────────────────────────────────────

class _CaseTypeBadge extends StatelessWidget {
  final String caseType;
  const _CaseTypeBadge({required this.caseType});

  static const _colors = {
    'perceraian': Color(0xFF8B1A1A),
    'warisan': Color(0xFF1A4A8B),
    'tanah': Color(0xFF1A6B3C),
    'utang': Color(0xFF7B4A1A),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[caseType] ?? AppColors.navyDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(
        caseType.toUpperCase(),
        style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: 0.8),
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // System / error messages (centered, muted)
    if (message.isSystemMessage) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.navyDeep.withAlpha(12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.attachedFileName != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.navyDeep.withAlpha(180),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.description_outlined, size: 13, color: AppColors.white),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          message.attachedFileName!,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.chatUserBubble,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.white, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // AI message
    final cs = message.consultStructured;
    final lr = message.legalResponse;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.chatAiBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source badge
                  if (cs != null || lr != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SourceBadge(fromBackend: message.fromBackend),
                    ),
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                  ),
                  // New consult structured cards
                  if (cs != null && cs.hasContent) ...[
                    const SizedBox(height: 12),
                    _ConsultCards(structured: cs),
                  ],
                  // Legacy legal response
                  if (lr != null && cs == null) ...[
                    const SizedBox(height: 12),
                    _LegalBasisBlock(basis: lr.legalBasis),
                    const SizedBox(height: 12),
                    Text(
                      'Langkah yang bisa Anda ambil:',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    ...lr.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                    color: AppColors.navyDeep, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text('${e.key + 1}',
                                    style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(e.value,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                        height: 1.5)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Consult structured cards ───────────────────────────────────────────────────

class _ConsultCards extends StatefulWidget {
  final ConsultStructured structured;
  const _ConsultCards({required this.structured});

  @override
  State<_ConsultCards> createState() => _ConsultCardsState();
}

class _ConsultCardsState extends State<_ConsultCards> {
  bool _docsExpanded = false;
  final Set<int> _checkedDocs = {};

  @override
  Widget build(BuildContext context) {
    final s = widget.structured;
    return Column(
      children: [
        if (s.legalBasis != null) _LegalBasisBlock(basis: s.legalBasis!),
        if (s.docsNeeded?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          _DocsCard(
            docs: s.docsNeeded!,
            checked: _checkedDocs,
            expanded: _docsExpanded,
            onToggleExpand: () => setState(() => _docsExpanded = !_docsExpanded),
            onToggleCheck: (i) => setState(() {
              if (_checkedDocs.contains(i)) {
                _checkedDocs.remove(i);
              } else {
                _checkedDocs.add(i);
              }
            }),
          ),
        ],
        if (s.steps?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          _StepsCard(steps: s.steps!),
        ],
        if (s.outcome != null) ...[
          const SizedBox(height: 10),
          _OutcomeCard(outcome: s.outcome!),
        ],
        if (s.referToLawyer) ...[
          const SizedBox(height: 10),
          _ReferCard(),
        ],
      ],
    );
  }
}

class _DocsCard extends StatelessWidget {
  final List<String> docs;
  final Set<int> checked;
  final bool expanded;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onToggleCheck;
  const _DocsCard({
    required this.docs,
    required this.checked,
    required this.expanded,
    required this.onToggleExpand,
    required this.onToggleCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withAlpha(8),
        border: Border(left: BorderSide(color: AppColors.gold, width: 3)),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.only(
                topRight: const Radius.circular(8),
                bottomRight: expanded ? Radius.zero : const Radius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.checklist_outlined, size: 14, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'DOKUMEN YANG DIBUTUHKAN',
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                        letterSpacing: 1),
                  ),
                  const Spacer(),
                  Text(
                    '${checked.length}/${docs.length}',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            ...docs.asMap().entries.map((e) => InkWell(
                  onTap: () => onToggleCheck(e.key),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          checked.contains(e.key)
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank,
                          size: 16,
                          color: checked.contains(e.key)
                              ? AppColors.verified
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.value,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: checked.contains(e.key)
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              decoration: checked.contains(e.key)
                                  ? TextDecoration.lineThrough
                                  : null,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          if (expanded) const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final List<String> steps;
  const _StepsCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withAlpha(8),
        border: Border(left: BorderSide(color: AppColors.navyDeep, width: 3)),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_list_numbered, size: 14, color: AppColors.navyDeep),
              const SizedBox(width: 6),
              Text(
                'LANGKAH SELANJUTNYA',
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDeep,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: AppColors.navyDeep, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${e.key + 1}',
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.value,
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _OutcomeCard extends StatelessWidget {
  final String outcome;
  const _OutcomeCard({required this.outcome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amberCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_outlined, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                'PERKIRAAN HASIL',
                style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyDeep,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(outcome,
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}

class _ReferCard extends StatelessWidget {
  const _ReferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withAlpha(120)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outlined, size: 16, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konsultasi Pengacara Disarankan',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep)),
                const SizedBox(height: 4),
                Text(
                  'Kasus ini memerlukan pendampingan profesional. Gunakan fitur Cari Pengacara untuk menemukan advokat di domisili Anda.',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _StatusDot extends StatelessWidget {
  final _BackendStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      _BackendStatus.checking => AppColors.gold,
      _BackendStatus.live => AppColors.verified,
      _BackendStatus.offline => const Color(0xFFEF4444),
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final bool fromBackend;
  const _SourceBadge({required this.fromBackend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: fromBackend ? AppColors.verified : const Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          fromBackend ? 'Perdata AI' : 'Offline',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: fromBackend ? AppColors.verified : const Color(0xFFEF4444),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _LegalBasisBlock extends StatelessWidget {
  final LegalBasis basis;
  const _LegalBasisBlock({required this.basis});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withAlpha(8),
        border: Border(left: BorderSide(color: AppColors.navyDeep, width: 3)),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DASAR HUKUM',
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(basis.pasal,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep)),
                const SizedBox(height: 6),
                Text(basis.text,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
              ],
            ),
          ),
          if (basis.application != null && basis.application!.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.navyDeep.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right_alt, size: 16, color: AppColors.navyDeep),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      basis.application!,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.navyDeep,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;
  const _FileChip({required this.name, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navyDeep.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.navyDeep.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.description_outlined, size: 14, color: AppColors.navyDeep),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.navyDeep)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.chatAiBubble,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 150),
            const SizedBox(width: 4),
            _Dot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration:
            const BoxDecoration(color: AppColors.navyDeep, shape: BoxShape.circle),
      ),
    );
  }
}
