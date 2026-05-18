import 'dart:convert';
import 'dart:typed_data';
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

// ── Document-parsing result (LlamaParse) ──────────────────────────────────────

class ParseResult {
  final String? text;
  final String? filename;
  final int? charCount;
  final bool success;
  final String? error;
  const ParseResult({
    this.text,
    this.filename,
    this.charCount,
    required this.success,
    this.error,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class AiService {
  // Override at build time: --dart-define=API_BASE_URL=https://your-backend.fly.dev
  static const String _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String _consultUrl = '$_base/consult';
  static const String _tanyaUrl = '$_base/tanya';
  static const String _healthUrl = '$_base/health';
  static const String _parseUrl = '$_base/parse-document';

  static http.Client _client = http.Client();

  /// Inject a custom HTTP client (tests swap in MockClient).
  static void setHttpClient(http.Client client) {
    _client = client;
  }

  static Future<bool> checkBackend() async {
    try {
      final res = await _client
          .get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
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
          .map((m) => {'role': m.isUser ? 'user' : 'model', 'content': m.text})
          .toList();

      final body = <String, dynamic>{
        'session_id': session.sessionId,
        'message': message,
        'context': session.context.toJson(),
        'history': history,
        if (documentText != null) 'document_text': documentText,
      };

      final res = await _client
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

  /// Parse an uploaded document (PDF, DOCX, image, etc.) via LlamaParse.
  /// Returns extracted markdown/text that callers feed back to /consult as
  /// `documentText`.
  static Future<ParseResult> parseDocument(Uint8List bytes, String filename) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_parseUrl))
        ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final streamed = await _client.send(request).timeout(const Duration(seconds: 120));
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return ParseResult(
          text: data['text'] as String?,
          filename: data['filename'] as String?,
          charCount: data['char_count'] as int?,
          success: true,
        );
      }

      String detail;
      try {
        detail = (jsonDecode(res.body) as Map)['detail'] as String? ?? res.body;
      } catch (_) {
        detail = res.body;
      }
      return ParseResult(success: false, error: detail);
    } catch (e) {
      return ParseResult(success: false, error: e.toString());
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

      final res = await _client
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
