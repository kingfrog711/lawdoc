import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/consult_session.dart';

class SessionService {
  static const String _filename = 'lawdoc_session.json';

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  static Future<ConsultSession?> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final raw = await f.readAsString();
      return ConsultSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(ConsultSession session) async {
    final f = await _file();
    await f.writeAsString(jsonEncode(session.toJson()));
  }

  static Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }
}
