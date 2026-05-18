class LegalBasis {
  final String pasal;
  final String text;
  final String? application;
  final String? sourceUrl;

  const LegalBasis({required this.pasal, required this.text, this.application, this.sourceUrl});

  factory LegalBasis.fromJson(Map<String, dynamic> j) => LegalBasis(
        pasal: j['pasal'] as String,
        text: j['text'] as String,
        application: j['application'] as String?,
        sourceUrl: j['source_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'pasal': pasal,
        'text': text,
        if (application != null) 'application': application,
        if (sourceUrl != null) 'source_url': sourceUrl,
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

class DocGuide {
  final String doc;
  final List<String> steps;
  final String? tutorialUrl;

  const DocGuide({required this.doc, required this.steps, this.tutorialUrl});

  factory DocGuide.fromJson(Map<String, dynamic> j) => DocGuide(
        doc: j['doc'] as String,
        steps: List<String>.from(j['steps'] as List),
        tutorialUrl: j['tutorial_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'doc': doc,
        'steps': steps,
        if (tutorialUrl != null) 'tutorial_url': tutorialUrl,
      };
}

class ConsultStructured {
  final LegalBasis? legalBasis;
  final List<String>? docsNeeded;
  final List<DocGuide>? docsGuides;
  final List<String>? steps;
  final String? outcome;
  final bool referToLawyer;

  const ConsultStructured({
    this.legalBasis,
    this.docsNeeded,
    this.docsGuides,
    this.steps,
    this.outcome,
    this.referToLawyer = false,
  });

  factory ConsultStructured.fromJson(Map<String, dynamic> j) => ConsultStructured(
        legalBasis: j['legal_basis'] != null
            ? LegalBasis.fromJson(j['legal_basis'] as Map<String, dynamic>)
            : null,
        docsNeeded: j['docs_needed'] != null
            ? List<String>.from(j['docs_needed'] as List)
            : null,
        docsGuides: j['docs_guides'] != null
            ? (j['docs_guides'] as List)
                .map((g) => DocGuide.fromJson(g as Map<String, dynamic>))
                .toList()
            : null,
        steps: j['steps'] != null ? List<String>.from(j['steps'] as List) : null,
        outcome: j['outcome'] as String?,
        referToLawyer: j['refer_to_lawyer'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'legal_basis': legalBasis?.toJson(),
        'docs_needed': docsNeeded,
        'docs_guides': docsGuides?.map((g) => g.toJson()).toList(),
        'steps': steps,
        'outcome': outcome,
        'refer_to_lawyer': referToLawyer,
      };

  bool get hasContent =>
      legalBasis != null ||
      (docsNeeded?.isNotEmpty ?? false) ||
      (steps?.isNotEmpty ?? false) ||
      outcome != null;
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final LegalResponse? legalResponse;
  final ConsultStructured? consultStructured;
  final DateTime timestamp;
  final String? attachedFileName;
  final bool fromBackend;
  final String? backendError;
  final bool isSystemMessage;

  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    this.legalResponse,
    this.consultStructured,
    required this.timestamp,
    this.attachedFileName,
    this.fromBackend = false,
    this.backendError,
    this.isSystemMessage = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isUser': isUser,
        'text': text,
        'legalResponse': legalResponse?.toJson(),
        'consultStructured': consultStructured?.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'attachedFileName': attachedFileName,
        'fromBackend': fromBackend,
        'backendError': backendError,
        'isSystemMessage': isSystemMessage,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        isUser: j['isUser'] as bool,
        text: j['text'] as String,
        legalResponse: j['legalResponse'] != null
            ? LegalResponse.fromJson(j['legalResponse'] as Map<String, dynamic>)
            : null,
        consultStructured: j['consultStructured'] != null
            ? ConsultStructured.fromJson(
                j['consultStructured'] as Map<String, dynamic>)
            : null,
        timestamp: DateTime.parse(j['timestamp'] as String),
        attachedFileName: j['attachedFileName'] as String?,
        fromBackend: j['fromBackend'] as bool? ?? false,
        backendError: j['backendError'] as String?,
        isSystemMessage: j['isSystemMessage'] as bool? ?? false,
      );
}
