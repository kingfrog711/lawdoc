import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/consult_session.dart';

class SessionService {
  static const String _filename = 'lawdoc_session.json';
  static const String _prefsKey = 'lawdoc_session';

  static Future<ConsultSession?> load() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_prefsKey);
        if (raw == null) return null;
        return ConsultSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final f = File('${dir.path}/$_filename');
        if (!await f.exists()) return null;
        final raw = await f.readAsString();
        return ConsultSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(ConsultSession session) async {
    try {
      final jsonString = jsonEncode(session.toJson());
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, jsonString);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final f = File('${dir.path}/$_filename');
        await f.writeAsString(jsonString);
      }
    } catch (_) {}
  }

  static Future<void> clear() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_prefsKey);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final f = File('${dir.path}/$_filename');
        if (await f.exists()) await f.delete();
      }
    } catch (_) {}
  }
}
