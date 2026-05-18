import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/legal_response.dart';
import '../models/consult_session.dart';
import '../data/mock_ai_responses.dart';

enum ResponseSource { backend, offline }

// ── Legacy result type (kept for /tanya compatibility) ────────────────────────

class AiResult {
  final LegalResponse response;
  final ResponseSource source;
  final String? error;
  const AiResult({required this.response, required this.source, this.error});
}

// ── New consult result type ───────────────────────────────────────────────────

class ConsultResult {
  final ConsultResponse? response;
  final bool success;
  final String? error;
  const ConsultResult({this.response, required this.success, this.error});
}

// ── Service ───────────────────────────────────────────────────────────────────

class AiService {
  static const String _base = 'http://localhost:8000';
  static const String _consultUrl = '$_base/consult';
  static const String _tanyaUrl = '$_base/tanya';
  static const String _healthUrl = '$_base/health';

  static Future<bool> checkBackend() async {
    try {
      final res = await http
          .get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Builds the text content for a history entry, including structured output for AI messages.
  // This ensures follow-up calls have full context of what was previously returned.
  static String _historyContent(ChatMessage m) {
    if (m.isUser) return m.text;
    final cs = m.consultStructured;
    if (cs == null) return m.text;

    final sb = StringBuffer(m.text);
    if (cs.legalBasis != null) {
      sb.write('\n\n[DASAR HUKUM YANG DIBERIKAN: ${cs.legalBasis!.pasal} — ${cs.legalBasis!.text}]');
      if (cs.legalBasis!.application != null) {
        sb.write('\n[PENERAPAN: ${cs.legalBasis!.application}]');
      }
    }
    if (cs.docsNeeded?.isNotEmpty == true) {
      sb.write('\n\n[DOKUMEN YANG DIBUTUHKAN: ${cs.docsNeeded!.join(', ')}]');
    }
    if (cs.steps?.isNotEmpty == true) {
      final numbered = cs.steps!.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('; ');
      sb.write('\n\n[LANGKAH YANG DIBERIKAN: $numbered]');
    }
    if (cs.outcome != null) {
      sb.write('\n\n[PERKIRAAN HASIL: ${cs.outcome}]');
    }
    return sb.toString();
  }

  // Primary method — calls /consult with full session context
  static Future<ConsultResult> consult(
    String message,
    ConsultSession session, {
    String? documentText,
  }) async {
    try {
      final history = session.messages
          .where((m) => !m.isSystemMessage)
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'content': _historyContent(m)})
          .toList();

      final body = <String, dynamic>{
        'session_id': session.sessionId,
        'message': message,
        'context': session.context.toJson(),
        'history': history,
        if (documentText != null) 'document_text': documentText,
      };

      final res = await http
          .post(
            Uri.parse(_consultUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ConsultResult(
          response: ConsultResponse.fromJson(data),
          success: true,
        );
      }

      final detail = jsonDecode(res.body)['detail'] as String? ?? res.body;
      return ConsultResult(success: false, error: detail);
    } catch (e) {
      return ConsultResult(success: false, error: e.toString());
    }
  }

  // Legacy method — calls /tanya (preserved)
  static Future<AiResult> query(String userMessage, {String? documentText}) async {
    return _queryLegacy(userMessage, documentText: documentText);
  }

  static Future<AiResult> _queryLegacy(String message, {String? documentText}) async {
    try {
      final body = <String, dynamic>{'message': message};
      if (documentText != null) body['document_text'] = documentText;

      final res = await http
          .post(
            Uri.parse(_tanyaUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return AiResult(response: LegalResponse.fromJson(data), source: ResponseSource.backend);
      }

      // ignore: avoid_print
      print('[AiService] Legacy backend error ${res.statusCode}');
      final fallback = getMockResponse(message) ?? defaultMockResponse;
      return AiResult(response: fallback, source: ResponseSource.offline, error: res.body);
    } catch (e) {
      final fallback = getMockResponse(message) ?? defaultMockResponse;
      return AiResult(response: fallback, source: ResponseSource.offline, error: e.toString());
    }
  }
}
