import 'package:flutter/foundation.dart';

/// Global app language. true = Indonesian (default), false = English.
/// Wrap MaterialApp.router in a ValueListenableBuilder so the whole tree
/// rebuilds when this flips.
final ValueNotifier<bool> langIsId = ValueNotifier<bool>(true);

/// Pick the right string for the current language.
/// Usage: `t('Halo', 'Hello')` — keeps both strings co-located at the call site.
String t(String id, String en) => langIsId.value ? id : en;
