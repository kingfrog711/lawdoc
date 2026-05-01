class LegalBasis {
  final String pasal;
  final String text;
  final String? application;

  const LegalBasis({required this.pasal, required this.text, this.application});

  factory LegalBasis.fromJson(Map<String, dynamic> j) => LegalBasis(
        pasal: j['pasal'] as String,
        text: j['text'] as String,
        application: j['application'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'pasal': pasal,
        'text': text,
        if (application != null) 'application': application,
      };
}

class LegalResponse {
  final String summary;
  final LegalBasis legalBasis;
  final List<String> steps;
  final String disclaimer;

  const LegalResponse({
    required this.summary,
    required this.legalBasis,
    required this.steps,
    required this.disclaimer,
  });

  factory LegalResponse.fromJson(Map<String, dynamic> j) => LegalResponse(
        summary: j['summary'] as String,
        legalBasis: LegalBasis.fromJson(j['legal_basis'] as Map<String, dynamic>),
        steps: List<String>.from(j['steps'] as List),
        disclaimer: j['disclaimer'] as String,
      );

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'legal_basis': legalBasis.toJson(),
        'steps': steps,
        'disclaimer': disclaimer,
      };
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final LegalResponse? legalResponse;
  final DateTime timestamp;
  final String? attachedFileName;
  final bool fromBackend;
  final String? backendError;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.legalResponse,
    required this.timestamp,
    this.attachedFileName,
    this.fromBackend = false,
    this.backendError,
  });
}
