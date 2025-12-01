import 'dart:async';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/song_lyric.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/lyric_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/lyric/lyric_editor.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Paths;

import 'package:music_hub/utils/extensions.dart'
    show DurationFromNumber, LyricTimestamp;

class LyricStrip extends StatefulWidget {
  const LyricStrip({super.key});

  @override
  State<LyricStrip> createState() => _LyricStripState();
}

class _LyricStripState extends State<LyricStrip> {
  final lyricService = GetIt.I<LyricService>(),
      logService = GetIt.I<LogService>(),
      songService = GetIt.I<SongService>(),
      playerService = GetIt.I<PlayerService>();

  final scrollController = PageController(viewportFraction: 0.3);
  final List<StreamSubscription> subs = [];
  var lines = <String>[], timestampList = <Duration>[];
  int currentLine = 0, viewLine = 0, lineCount = 0, currentSongID = 0;
  bool canAutoScroll = true;

  late SongLyric lyric;

  void scroll(Duration time) {
    if (!scrollController.hasClients) return;
    scrollController.animateToPage(currentLine, duration: time, curve: Curves.decelerate);
  }

  int findCurrentLine() {
    for (int i = lineCount - 1; i >= 0; i--) {
      if (playerService.player.position.inMilliseconds >=
          timestampList[i].inMilliseconds) {
        return i;
      }
    }
    return 0;
  }

  void updateLyric() {
    final song = songService.allSongs.firstWhere(
      (e) => e.id == songService.currentSongID,
    );
    currentSongID = song.id;
    lyric =
        lyricService.getLyric(currentSongID, Paths.lyricPath + song.lyricPath) ??
        SongLyric(
          songId: currentSongID,
          name: song.name,
          artist: song.artist,
          path: song.path,
          list: [],
        );

    if (lyric.list.isNotEmpty) {
      lines = lyric.list.map((e) => e.line).toList();
      timestampList = lyric.list.map((e) => e.timestamp).toList();
      if (timestampList.first.inMicroseconds != 0) {
        lines.insert(0, '[Music]');
        timestampList.insert(0, 0.ms);
      }
    }
    lineCount = lines.length;
    logService.log('Updated lyric for $currentSongID: ${song.lyricPath}');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateLyric();

    viewLine = currentLine = findCurrentLine();
    WidgetsBinding.instance.addPostFrameCallback((_) => scroll(100.ms));

    subs.add(
      playerService.player.positionStream.listen((event) {
        final newLine = findCurrentLine();
        if (newLine == currentLine) return;
        viewLine = currentLine = newLine;
        if (canAutoScroll) scroll(600.ms);
      }),
    );

    subs.add(
      songService.lyricChangedController.stream.listen((_) {
        updateLyric();
        viewLine = currentLine = findCurrentLine();
        scroll(600.ms);
      }),
    );

    subs.add(
      playerService.onSongChange.listen((_) {
        songService.lyricChangedController.add(null);
      }),
    );
  }

  @override
  void dispose() {
    for (final e in subs) {
      e.cancel();
    }
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: scrollController,
          scrollDirection: .vertical,
          pageSnapping: false,
          padEnds: true,
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final isCurrent = index == currentLine, isViewed = index == viewLine;
            final highlight = isCurrent || isViewed;

            return Center(
              child: ListTile(
                leading: Text(
                  timestampList[index].toMMSS(),
                  style: TextStyle(
                    shadows: [
                      if (highlight)
                        Shadow(
                          color: context.colorScheme.inverseSurface.withValues(
                            alpha: isViewed ? 1 : 0.4,
                          ),
                          blurRadius: 25,
                        ),
                    ],
                    color: isViewed
                        ? null
                        : isCurrent
                        ? Theme.of(
                            context,
                          ).colorScheme.inverseSurface.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.07),
                  ),
                ),
                title: Text(
                  lines[index],
                  textAlign: .center,
                  style: TextStyle(
                    shadows: [
                      if (highlight)
                        Shadow(
                          color: context.colorScheme.inverseSurface,
                          blurRadius: isViewed ? 30 : 20,
                        ),
                    ],
                    fontSize: highlight ? 16 : null,
                    fontWeight: highlight ? .bold : .normal,
                    color: isViewed
                        ? null
                        : isCurrent
                        ? Theme.of(
                            context,
                          ).colorScheme.inverseSurface.withValues(alpha: 0.4)
                        : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                trailing: isCurrent
                    ? const Padding(
                        padding: .only(right: 5),
                        child: FaIcon(FontAwesomeIcons.volumeHigh, size: 10),
                      )
                    : isViewed
                    ? const Icon(Icons.arrow_left_rounded)
                    : const Text(''),
                visualDensity: .compact,
                dense: true,
              ),
            );
          },
          onPageChanged: (index) {
            viewLine = index;
            canAutoScroll = false;
            Future.delayed(250.ms, () => canAutoScroll = true);
            setState(() {});
          },
        ),
        Positioned(
          right: 15,
          child: IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LyricEditor(songID: currentSongID),
                ),
              );
            },
          ),
        ),
        Positioned(
          right: 50,
          child: IconButton(
            icon: const Icon(Icons.delete_forever_rounded),
            onPressed: () {
              context
                  .showActionDialog<bool>(
                    title: 'Delete lyric',
                    titleFontSize: 18,
                    textContent: 'Are you sure you want to remove the lyrics?',
                    contentFontSize: 14,
                    time: 300.ms,
                    actions: [
                      TextButton(
                        child: const Text('No'),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () {
                          final song = songService.getSong(lyric.songId);
                          if (song != null) {
                            logService.log('Removing lyric for ${song.id}');
                            song.lyricPath = '';
                            song.update();
                          }
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  )
                  .then((value) {
                    if (value != true) return;
                    songService.lyricChangedController.add(null);
                  });
            },
          ),
        ),
      ],
    );
  }
}
