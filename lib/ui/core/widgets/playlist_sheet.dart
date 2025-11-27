import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';

import 'package:music_hub/utils/extensions.dart'
    show DurationFromNumber, PadInt, WhereOrNull;

class PlaylistSheet extends StatefulWidget {
  const PlaylistSheet({super.key});

  @override
  State<PlaylistSheet> createState() => _PlaylistSheetState();
}

class _PlaylistSheetState extends State<PlaylistSheet> {
  late final ScrollController scrollController = ScrollController();
  List<ListTile> content = [];
  late final StreamSubscription<bool> sub;

  void updateList() {
    final playerService = GetIt.I<PlayerService>(), songService = GetIt.I<SongService>();

    content = playerService.playlist
        .mapIndexed(
          (i, sId) => ListTile(
            key: ValueKey(i),
            visualDensity: VisualDensity.compact,
            titleAlignment: ListTileTitleAlignment.threeLine,
            leading: SizedBox(
              width: 32,
              child: Align(
                alignment: Alignment.center,
                child: sId == songService.currentSongID
                    ? const FaIcon(FontAwesomeIcons.headphones, size: 20)
                    : Text((i + 1).padIntLeft(2, '0')),
              ),
            ),
            title: Text(
              songService.allSongs.firstWhere((e) => e.id == sId).name,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(songService.allSongs.firstWhere((e) => e.id == sId).artist),
            trailing: songService.currentSongID != sId
                ? IconButton(
                    icon: const Icon(Icons.playlist_add_rounded),
                    onPressed: () {
                      final playlist = playerService.playlist;

                      final currentIdx = playlist.indexOf(songService.currentSongID);
                      final selectedIdx = playlist.indexOf(sId);

                      if (selectedIdx == currentIdx + 1) return;

                      GetIt.I<LogService>().log('Adding song #$selectedIdx to play next');

                      playlist.insert(currentIdx + 1, sId);
                      playlist.removeAt(
                        selectedIdx > currentIdx ? selectedIdx + 1 : selectedIdx,
                      );

                      playerService.savePlaylist(songService.currentSongID);

                      setState(updateList);
                    },
                  )
                : null,
          ),
        )
        .toList();
  }

  void scroll(Duration time) {
    final playerService = GetIt.I<PlayerService>(), songService = GetIt.I<SongService>();

    if (!scrollController.hasClients) return;
    final count = playerService.playlist.length;
    final current = playerService.playlist.indexOf(songService.currentSongID);
    final maxScrollExtent = scrollController.position.maxScrollExtent;

    scrollController.animateTo(
      maxScrollExtent * (current / count),
      duration: time,
      curve: Curves.easeIn,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => scroll(100.ms));

    updateList();

    sub = GetIt.I<PlayerService>().onSongChange.listen((event) {
      scroll(300.ms);
      setState(updateList);
    });
  }

  @override
  void dispose() {
    sub.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerService = GetIt.I<PlayerService>();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Text(
                playerService.playlistDisplayName,
                style: TextStyle(fontSize: FontSize.mediumSmall, fontWeight: .w700),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            Flexible(
              child: Scrollbar(
                controller: scrollController,
                interactive: true,
                thumbVisibility: true,
                radius: const Radius.circular(16),
                thickness: min(content.length ~/ 3, 8).toDouble(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ReorderableListView(
                    scrollController: scrollController,
                    onReorder: (oIdx, nIdx) {
                      if (nIdx > oIdx) nIdx--;
                      GetIt.I<LogService>().log(
                        'Reorder: old: $oIdx (id=${playerService.playlist[oIdx]}) - new: $nIdx (id=${playerService.playlist[nIdx]})',
                      );
                      playerService.moveSong(oIdx, nIdx);
                      // final idx = content.
                      content.insert(nIdx, content.removeAt(oIdx));
                      updateList();
                      setState(() {});
                    },
                    proxyDecorator: (child, _, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Material(
                          color: Theme.of(context).colorScheme.tertiaryContainer,
                          child: child,
                        ),
                      );
                    },
                    // shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    children: content,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
