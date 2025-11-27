import 'dart:io';

import 'package:music_hub/data/models/lyric_item.dart';
import 'package:music_hub/data/models/song_lyric.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Paths, Constants;

import 'package:music_hub/utils/extensions.dart'
    show DurationFromNumber, LyricTimestamp, WhereOrNull;

class LyricService {
  final LogService _logService;

  LyricService(this._logService);

  String? _getMetadata(List<String> lines, String begin) => lines
      .firstWhereOrNull((e) => e.startsWith(begin))
      ?.substring(4)
      .replaceAll(']', '')
      .trim();

  void addLyric(SongLyric lyric) {
    final lrcFile = File(Paths.lyricPath + lyric.path);
    if (!lrcFile.existsSync()) lrcFile.createSync(recursive: true);

    _logService.log(
      'Writing lyric: p=${lrcFile.path}, id=${lyric.songId}, ve=${Constants.appVersion}',
    );

    lrcFile.writeAsStringSync('');

    lrcFile.writeAsStringSync('[ti: ${lyric.name}]\n', mode: .append);
    lrcFile.writeAsStringSync('[ar: ${lyric.artist}]\n', mode: .append);
    lrcFile.writeAsStringSync('[al:]\n', mode: .append);

    lrcFile.writeAsStringSync('[re: ${Constants.appName}]\n', mode: .append);
    lrcFile.writeAsStringSync('[ve: ${Constants.appVersion}]\n', mode: .append);
    lrcFile.writeAsStringSync('[length:]\n\n', mode: .append);

    for (final l in lyric.list) {
      lrcFile.writeAsStringSync(
        '[${l.timestamp.toLyricTimestamp()}] ${l.line}\n',
        mode: .append,
      );
    }
  }

  SongLyric? getLyric(int songID, String path) {
    final lrcFile = File(path);
    if (!lrcFile.existsSync()) return null;

    var lines = lrcFile.readAsLinesSync();

    final name = _getMetadata(lines, '[ti:') ?? '';
    final artist = _getMetadata(lines, '[ar:') ?? '';
    // final album = _getMetadata(lines, '[al:') ?? '';

    lines = lines
        .where((e) => e.trim().isNotEmpty && e.startsWith(RegExp(r'^\[\d')))
        .toList();

    final lItems = <LyricItem>[];

    for (final l in lines) {
      final closingBracketIdx = l.indexOf(']');
      final timeStr = l.substring(1, closingBracketIdx);

      var timeParts = timeStr.split(RegExp(r'[:.]'));

      for (final t in timeParts) {
        final matches = RegExp(r'[0-9]{2}').allMatches(t);
        if (matches.length != 1) {
          _logService.log('$t match count ${matches.length} -> invalid, skipping...');
          continue;
        }
      }

      final time = timeParts.map(int.parse);
      lItems.add(
        LyricItem(
          timestamp:
              time.elementAt(0).minutes +
              time.elementAt(1).seconds +
              (time.elementAt(2) * 10).ms,
          line: l.substring(closingBracketIdx + 1).trim(),
        ),
      );
    }

    lItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SongLyric(
      songId: songID,
      name: name,
      artist: artist,
      path: path.split(Paths.lyricPath).last,
      list: lItems,
    );
  }
}
