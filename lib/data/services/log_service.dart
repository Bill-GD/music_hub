import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals/globals.dart';

enum LogLevel { info, warn, error }

class LogService {
  static final _logFile = File(Globals.logPath);

  static void init() {
    if (!_logFile.existsSync()) _logFile.createSync(recursive: true);
    _logFile.writeAsStringSync('');
    log('Log init');
  }

  static void log(String content, [LogLevel level = LogLevel.info]) {
    final prefix = level.name[0].toUpperCase();
    final time = DateTime.now();
    _logFile.writeAsStringSync(
      '[$time] [$prefix] $content\n',
      mode: FileMode.append,
    );
    debugPrint('[$time] [$prefix] $content');
  }
}
