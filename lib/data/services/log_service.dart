import 'dart:io';

import 'package:flutter/cupertino.dart';

enum LogLevel { info, warn, error }

class LogService {
  final File _logFile;

  LogService({required String logPath}) : _logFile = File(logPath) {
    if (!_logFile.existsSync()) _logFile.createSync(recursive: true);
    _logFile.writeAsStringSync('');
    log('Log init');
  }

  void log(String content, [LogLevel level = LogLevel.info]) {
    final prefix = level.name[0].toUpperCase();
    final time = DateTime.now();
    _logFile.writeAsStringSync('[$time] [$prefix] $content\n', mode: FileMode.append);
    debugPrint('[$time] [$prefix] $content');
  }
}
