import 'legal_response.dart';

class SessionContextModel {
  final String? agama;
  final String? domicile;
  final String? budget;
  final String? caseType;
  final bool confirmed;
  final String flowState;

  const SessionContextModel({
    this.agama,
    this.domicile,
    this.budget,
    this.caseType,
    this.confirmed = false,
    this.flowState = 'extracting',
  });

  factory SessionContextModel.fromJson(Map<String, dynamic> j) => SessionContextModel(
        agama: j['agama'] as String?,
        domicile: j['domicile'] as String?,
        budget: j['budget'] as String?,
        caseType: j['case_type'] as String?,
        confirmed: j['confirmed'] as bool? ?? false,
        flowState: j['flow_state'] as String? ?? 'extracting',
      );

  Map<String, dynamic> toJson() => {
        'agama': agama,
        'domicile': domicile,
        'budget': budget,
        'case_type': caseType,
        'confirmed': confirmed,
        'flow_state': flowState,
      };

  SessionContextModel copyWith({
    String? agama,
    String? domicile,
    String? budget,
    String? caseType,
    bool? confirmed,
    String? flowState,
  }) =>
      SessionContextModel(
        agama: agama ?? this.agama,
        domicile: domicile ?? this.domicile,
        budget: budget ?? this.budget,
        caseType: caseType ?? this.caseType,
        confirmed: confirmed ?? this.confirmed,
        flowState: flowState ?? this.flowState,
      );

  bool get hasAny => agama != null || domicile != null || budget != null;
  bool get hasAll => agama != null && domicile != null && budget != null;
}

class ConsultResponse {
  final String message;
  final String flowState;
  final SessionContextModel contextUpdate;
  final ConsultStructured? structured;
  final String disclaimer;

  const ConsultResponse({
    required this.message,
    required this.flowState,
    required this.contextUpdate,
    this.structured,
    required this.disclaimer,
  });

  factory ConsultResponse.fromJson(Map<String, dynamic> j) => ConsultResponse(
        message: j['message'] as String,
        flowState: j['flow_state'] as String,
        contextUpdate: SessionContextModel.fromJson(
            j['context_update'] as Map<String, dynamic>),
        structured: j['structured'] != null
            ? ConsultStructured.fromJson(j['structured'] as Map<String, dynamic>)
            : null,
        disclaimer: j['disclaimer'] as String? ??
            'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi.',
      );
}

class ConsultSession {
  final String sessionId;
  final SessionContextModel context;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConsultSession({
    required this.sessionId,
    required this.context,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultSession.fresh() => ConsultSession(
        sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
        context: const SessionContextModel(),
        messages: [
          ChatMessage(
            id: 'init',
            isUser: false,
            text:
                'Halo, saya asisten LawDoc. Ceritakan masalah Anda dengan bahasa sehari-hari — '
                'saya akan bantu pahami hak hukum Anda. Anda juga bisa lampirkan dokumen hukum untuk saya analisa.',
            timestamp: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  ConsultSession copyWith({
    SessionContextModel? context,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) =>
      ConsultSession(
        sessionId: sessionId,
        context: context ?? this.context,
        messages: messages ?? this.messages,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );

  factory ConsultSession.fromJson(Map<String, dynamic> j) => ConsultSession(
        sessionId: j['session_id'] as String,
        context: SessionContextModel.fromJson(
            j['context'] as Map<String, dynamic>),
        messages: (j['messages'] as List)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'context': context.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
