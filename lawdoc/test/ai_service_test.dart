import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lawdoc/models/consult_session.dart';
import 'package:lawdoc/services/ai_service.dart';

void main() {
  tearDown(() {
    AiService.setHttpClient(http.Client());
  });

  group('AiService.checkBackend', () {
    test('returns true on 200', () async {
      AiService.setHttpClient(MockClient((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/health');
        return http.Response('{"status":"ok","version":"2.1.0"}', 200);
      }));

      expect(await AiService.checkBackend(), isTrue);
    });

    test('returns false on non-200', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response('down', 503)));
      expect(await AiService.checkBackend(), isFalse);
    });

    test('returns false on network exception', () async {
      AiService.setHttpClient(MockClient((_) async {
        throw http.ClientException('connection refused');
      }));
      expect(await AiService.checkBackend(), isFalse);
    });
  });

  group('AiService.consult', () {
    test('sends well-formed POST and parses full consulting response', () async {
      AiService.setHttpClient(MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/consult');
        expect(req.headers['Content-Type'], contains('application/json'));

        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['message'], 'Saya mau cerai karena KDRT');
        expect(body['session_id'], isNotEmpty);
        expect(body['context'], isA<Map<String, dynamic>>());
        expect(body['history'], isA<List<dynamic>>());
        expect(body.containsKey('document_text'), isFalse);

        return http.Response(
          jsonEncode({
            'message': 'Saya turut prihatin. Mari kita bahas langkah hukumnya.',
            'flow_state': 'consulting',
            'context_update': {
              'agama': 'Islam',
              'domicile': 'Jakarta',
              'budget': 'pro_bono',
              'case_type': 'perceraian',
              'confirmed': true,
              'flow_state': 'consulting',
            },
            'structured': {
              'legal_basis': {
                'pasal': 'UU 23/2004 PKDRT',
                'text': 'Setiap orang dilarang melakukan kekerasan dalam rumah tangga.',
                'application': 'Anda dapat mengajukan gugatan cerai dengan bukti KDRT.',
              },
              'docs_needed': ['KTP', 'Buku nikah', 'Visum / bukti KDRT'],
              'steps': ['Cari tempat aman', 'Buat laporan polisi'],
              'outcome': 'Cerai sah dalam 3-6 bulan via Pengadilan Agama',
              'refer_to_lawyer': false,
            },
            'disclaimer': 'Jawaban ini bersifat informasi umum.',
          }),
          200,
          headers: {'Content-Type': 'application/json'},
        );
      }));

      final result = await AiService.consult(
        'Saya mau cerai karena KDRT',
        ConsultSession.fresh(),
      );

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.response, isNotNull);

      final r = result.response!;
      expect(r.message, contains('Saya turut prihatin'));
      expect(r.flowState, 'consulting');
      expect(r.contextUpdate.agama, 'Islam');
      expect(r.contextUpdate.domicile, 'Jakarta');
      expect(r.contextUpdate.caseType, 'perceraian');
      expect(r.contextUpdate.confirmed, isTrue);

      expect(r.structured, isNotNull);
      expect(r.structured!.legalBasis!.pasal, contains('PKDRT'));
      expect(r.structured!.legalBasis!.application, isNotNull);
      expect(r.structured!.docsNeeded, hasLength(3));
      expect(r.structured!.steps, hasLength(2));
      expect(r.structured!.referToLawyer, isFalse);
      expect(r.structured!.hasContent, isTrue);
    });

    test('parses extracting-state response without structured block', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response(
            jsonEncode({
              'message': 'Boleh saya tahu agama dan domisili Anda?',
              'flow_state': 'extracting',
              'context_update': {
                'agama': null,
                'domicile': null,
                'budget': null,
                'case_type': null,
                'confirmed': false,
                'flow_state': 'extracting',
              },
              'disclaimer': 'Jawaban ini bersifat informasi umum.',
            }),
            200,
          )));

      final result = await AiService.consult('Halo', ConsultSession.fresh());

      expect(result.success, isTrue);
      expect(result.response!.flowState, 'extracting');
      expect(result.response!.structured, isNull);
      expect(result.response!.contextUpdate.hasAny, isFalse);
    });

    test('includes document_text in body when provided', () async {
      String? capturedDocText;
      AiService.setHttpClient(MockClient((req) async {
        capturedDocText = (jsonDecode(req.body) as Map)['document_text'] as String?;
        return http.Response(
          jsonEncode({
            'message': 'ok',
            'flow_state': 'consulting',
            'context_update': {
              'confirmed': true,
              'flow_state': 'consulting',
            },
            'disclaimer': 'x',
          }),
          200,
        );
      }));

      await AiService.consult(
        'Analyze this',
        ConsultSession.fresh(),
        documentText: 'Surat Perjanjian Sewa Menyewa nomor 42/...',
      );

      expect(capturedDocText, 'Surat Perjanjian Sewa Menyewa nomor 42/...');
    });

    test('returns failure with detail message on 500', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response(
            jsonEncode({'detail': 'HF_API_KEY not configured in .env'}),
            500,
          )));

      final result = await AiService.consult('Halo', ConsultSession.fresh());

      expect(result.success, isFalse);
      expect(result.response, isNull);
      expect(result.error, 'HF_API_KEY not configured in .env');
    });

    test('returns failure on network exception', () async {
      AiService.setHttpClient(MockClient((_) async {
        throw http.ClientException('Connection refused');
      }));

      final result = await AiService.consult('Halo', ConsultSession.fresh());

      expect(result.success, isFalse);
      expect(result.error, contains('Connection refused'));
    });
  });

  group('AiService.query (legacy /tanya)', () {
    test('parses LegalResponse on 200', () async {
      AiService.setHttpClient(MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/tanya');

        final body = jsonDecode(req.body) as Map<String, dynamic>;
        expect(body['message'], 'Saya mau cerai karena KDRT');
        expect(body.containsKey('document_text'), isFalse);

        return http.Response(
          jsonEncode({
            'summary': 'Anda mengalami KDRT dan ingin mengajukan perceraian.',
            'legal_basis': {
              'pasal': 'UU 23/2004 PKDRT jo. UU 1/1974 Perkawinan',
              'text': 'Setiap orang dilarang melakukan kekerasan...',
              'application': 'KDRT merupakan alasan kuat untuk mengajukan perceraian.',
            },
            'steps': [
              'Cari tempat aman',
              'Buat laporan polisi atas KDRT',
              'Konsultasi ke LBH terdekat',
            ],
            'disclaimer': 'Jawaban ini bersifat informasi umum, bukan nasihat hukum resmi.',
          }),
          200,
        );
      }));

      final result = await AiService.query('Saya mau cerai karena KDRT');

      expect(result.source, ResponseSource.backend);
      expect(result.error, isNull);
      expect(result.response.summary, contains('KDRT'));
      expect(result.response.legalBasis.pasal, contains('PKDRT'));
      expect(result.response.legalBasis.application, isNotNull);
      expect(result.response.steps, hasLength(3));
      expect(result.response.disclaimer, contains('bukan nasihat hukum resmi'));
    });

    test('sends document_text in /tanya body when provided', () async {
      String? capturedDocText;
      AiService.setHttpClient(MockClient((req) async {
        capturedDocText = (jsonDecode(req.body) as Map)['document_text'] as String?;
        return http.Response(
          jsonEncode({
            'summary': 'ok',
            'legal_basis': {'pasal': 'x', 'text': 'x'},
            'steps': ['x'],
            'disclaimer': 'x',
          }),
          200,
        );
      }));

      await AiService.query('Analisis dokumen ini', documentText: 'Akta jual beli...');
      expect(capturedDocText, 'Akta jual beli...');
    });

    test('falls back to offline mock on backend 500', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response('boom', 500)));

      final result = await AiService.query('test query');

      expect(result.source, ResponseSource.offline);
      expect(result.error, isNotNull);
      expect(result.response, isNotNull);
      expect(result.response.summary, isNotEmpty);
      expect(result.response.legalBasis.pasal, isNotEmpty);
    });

    test('falls back to offline mock on network exception', () async {
      AiService.setHttpClient(MockClient((_) async {
        throw http.ClientException('Connection refused');
      }));

      final result = await AiService.query('test query');

      expect(result.source, ResponseSource.offline);
      expect(result.error, contains('Connection refused'));
      expect(result.response, isNotNull);
    });
  });

  group('AiService.parseDocument', () {
    final samplePdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46]); // %PDF

    test('uploads multipart file and parses 200 response', () async {
      String? capturedContentType;

      AiService.setHttpClient(MockClient((req) async {
        expect(req.method, 'POST');
        expect(req.url.path, '/parse-document');
        capturedContentType = req.headers['content-type'];
        // Multipart body should carry the filename + form field name
        expect(req.body, contains('contract.pdf'));
        expect(req.body, contains('name="file"'));

        return http.Response(
          jsonEncode({
            'text': '# Document Title\n\nParsed markdown content...',
            'filename': 'contract.pdf',
            'char_count': 42,
          }),
          200,
        );
      }));

      final result = await AiService.parseDocument(samplePdfBytes, 'contract.pdf');

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.text, contains('Parsed markdown'));
      expect(result.filename, 'contract.pdf');
      expect(result.charCount, 42);
      expect(capturedContentType, contains('multipart/form-data'));
    });

    test('returns failure with detail on 500 (missing API key)', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response(
            jsonEncode({'detail': 'LLAMA_CLOUD_API_KEY not configured in .env'}),
            500,
          )));

      final result = await AiService.parseDocument(samplePdfBytes, 'foo.pdf');

      expect(result.success, isFalse);
      expect(result.error, contains('LLAMA_CLOUD_API_KEY'));
      expect(result.text, isNull);
    });

    test('returns failure on 415 unsupported file type', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response(
            jsonEncode({'detail': 'Unsupported file type: .exe'}),
            415,
          )));

      final result = await AiService.parseDocument(
        Uint8List.fromList([0]),
        'bad.exe',
      );

      expect(result.success, isFalse);
      expect(result.error, contains('Unsupported'));
    });

    test('returns failure on network exception', () async {
      AiService.setHttpClient(MockClient((_) async {
        throw http.ClientException('Connection refused');
      }));

      final result = await AiService.parseDocument(samplePdfBytes, 'foo.pdf');

      expect(result.success, isFalse);
      expect(result.error, contains('Connection refused'));
    });

    test('falls back to raw body when error response is not JSON', () async {
      AiService.setHttpClient(MockClient((_) async => http.Response(
            'internal server error (non-JSON body)',
            500,
          )));

      final result = await AiService.parseDocument(samplePdfBytes, 'foo.pdf');

      expect(result.success, isFalse);
      expect(result.error, 'internal server error (non-JSON body)');
    });
  });
}
