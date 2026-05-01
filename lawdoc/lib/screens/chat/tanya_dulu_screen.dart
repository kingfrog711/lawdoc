import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/legal_response.dart';
import '../../services/ai_service.dart';
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
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  _AttachedFile? _attached;
  _BackendStatus _backendStatus = _BackendStatus.checking;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: 'init',
      isUser: false,
      text: 'Halo, saya asisten LawDoc. Ceritakan masalah Anda dengan bahasa sehari-hari — saya akan bantu pahami. Anda juga bisa lampirkan dokumen hukum untuk saya analisa.',
      timestamp: DateTime.now(),
    ));
    _checkBackend();
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

    final content = String.fromCharCodes(bytes);
    setState(() {
      _attached = _AttachedFile(name: file.name, content: content);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attached == null) || _loading) return;

    final displayText = text.isNotEmpty ? text : 'Tolong analisa dokumen yang saya lampirkan.';
    final attachedFile = _attached;

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: true,
        text: displayText,
        attachedFileName: attachedFile?.name,
        timestamp: DateTime.now(),
      ));
      _loading = true;
      _attached = null;
    });
    _controller.clear();
    _scrollToBottom();

    final result = await AiService.query(displayText, documentText: attachedFile?.content);

    // Update backend status based on what actually happened
    if (!mounted) return;
    setState(() {
      _backendStatus = result.source == ResponseSource.gemini
          ? _BackendStatus.live
          : _BackendStatus.offline;

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isUser: false,
        text: result.response.summary,
        legalResponse: result.response,
        timestamp: DateTime.now(),
        fromBackend: result.source == ResponseSource.gemini,
        backendError: result.error,
      ));
      _loading = false;
    });
    _scrollToBottom();

    // Show snackbar if fell back to mock unexpectedly
    if (result.source == ResponseSource.mock && result.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backend offline — jawaban dari template lokal. Pastikan server berjalan.',
            style: GoogleFonts.inter(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF92400E),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Coba lagi',
            textColor: AppColors.gold,
            onPressed: _checkBackend,
          ),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
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
                Text('Tanya Dulu',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.navyDeep.withAlpha(60)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('BETA',
                      style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: AppColors.navyDeep, letterSpacing: 0.8)),
                ),
              ],
            ),
            Text(_statusSubtitle,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.probonoText, height: 1.5),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (_loading && i == _messages.length) return const _TypingIndicator();
                return _MessageBubble(message: _messages[i]);
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
                        width: 40, height: 40,
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
                              : 'Tulis atau ucapkan pertanyaan...',
                          suffixIcon: const Icon(Icons.mic_none, color: AppColors.textMuted),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 44, height: 44,
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
        return 'Gemini AI · Aktif';
      case _BackendStatus.offline:
        return 'Offline — jawaban dari template lokal';
    }
  }
}

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
      width: 8, height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.navyDeep),
            ),
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

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
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
                child: Text(message.text,
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.white, height: 1.5)),
              ),
            ],
          ),
        ),
      );
    }

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
                  BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source badge — only on AI messages that have a legalResponse
                  if (lr != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SourceBadge(fromBackend: message.fromBackend),
                    ),
                  Text(message.text,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                  if (lr != null) ...[
                    const SizedBox(height: 12),
                    _LegalBasisBlock(basis: lr.legalBasis),
                    const SizedBox(height: 12),
                    Text('Langkah yang bisa Anda ambil:',
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    ...lr.steps.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: const BoxDecoration(
                                    color: AppColors.navyDeep, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text('${e.key + 1}',
                                    style: GoogleFonts.inter(
                                        fontSize: 10, fontWeight: FontWeight.w700,
                                        color: AppColors.white)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(e.value,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
            // Show error hint below bubble if it fell back to mock due to an error
            if (!message.fromBackend && message.backendError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, size: 11, color: Color(0xFFEF4444)),
                    const SizedBox(width: 4),
                    Text('Backend tidak terjangkau — jawaban dari template lokal',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
          ],
        ),
      ),
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
          width: 6, height: 6,
          decoration: BoxDecoration(
            color: fromBackend ? AppColors.verified : const Color(0xFFEF4444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          fromBackend ? 'Gemini AI' : 'Offline · Template lokal',
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
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
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
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: AppColors.navyDeep, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(basis.pasal,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.navyDeep)),
                const SizedBox(height: 6),
                Text(basis.text,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(color: AppColors.navyDeep, shape: BoxShape.circle),
      ),
    );
  }
}
