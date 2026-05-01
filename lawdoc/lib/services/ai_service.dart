import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/legal_response.dart';
import '../data/mock_ai_responses.dart';

enum AiMode { mock, gemini }

enum ResponseSource { gemini, mock }

class AiResult {
  final LegalResponse response;
  final ResponseSource source;
  final String? error;
  const AiResult({required this.response, required this.source, this.error});
}

class AiService {
  static AiMode mode = AiMode.gemini;

  static const String _base = 'http://localhost:8000';
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

  static Future<AiResult> query(String userMessage, {String? documentText}) async {
    if (mode == AiMode.mock) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final r = getMockResponse(userMessage) ?? defaultMockResponse;
      return AiResult(response: r, source: ResponseSource.mock);
    }
    return _queryBackend(userMessage, documentText: documentText);
  }

  static Future<AiResult> _queryBackend(String message, {String? documentText}) async {
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
        return AiResult(
          response: LegalResponse.fromJson(data),
          source: ResponseSource.gemini,
        );
      }

      // Backend returned an error status
      final errorDetail = 'Backend error ${res.statusCode}: ${res.body}';
      // ignore: avoid_print
      print('[AiService] $errorDetail');
      final fallback = getMockResponse(message) ?? defaultMockResponse;
      return AiResult(response: fallback, source: ResponseSource.mock, error: errorDetail);
    } catch (e) {
      final errorDetail = 'Network error: $e';
      // ignore: avoid_print
      print('[AiService] $errorDetail');
      final fallback = getMockResponse(message) ?? defaultMockResponse;
      return AiResult(response: fallback, source: ResponseSource.mock, error: errorDetail);
    }
  }
}
