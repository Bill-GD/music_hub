import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/artist_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/song/song_info.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Paths;
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber;
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class SongInfoOption extends StatelessWidget {
  final int songID;
  final void Function() updateCallback;

  const SongInfoOption({super.key, required this.songID, required this.updateCallback});

  @override
  Widget build(BuildContext context) {
    final songService = GetIt.I<SongService>();
    final artistService = GetIt.I<ArtistService>();

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: .circular(30)),
      leading: Icon(Icons.info_outline_rounded, color: context.iconColor()),
      title: Text(
        'Song info',
        style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
      ),
      onTap: () async {
        final needsUpdate = await Navigator.of(context).push(
          PageRouteBuilder<bool>(
            transitionDuration: 400.ms,
            transitionsBuilder: (_, anim, _, child) {
              return ScaleTransition(
                alignment: .bottomCenter,
                scale: Tween<double>(
                  begin: 0,
                  end: 1,
                ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim),
                child: child,
              );
            },
            pageBuilder: (_, _, _) => SongInfo(songID: songID),
          ),
        );
        if (needsUpdate == true) {
          artistService.updateArtistList();
          songService.sortAllSongs();
          updateCallback();
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }
}

class DeleteSongOption extends StatelessWidget {
  final int songID;

  const DeleteSongOption({super.key, required this.songID});

  @override
  Widget build(BuildContext context) {
    final playerService = GetIt.I<PlayerService>(), songService = GetIt.I<SongService>();
    Song song = songService.songs.firstWhere((e) => e.id == songID);

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: .circular(30)),
      leading: Icon(Icons.delete_rounded, color: context.iconColor()),
      title: const Text(
        'Delete',
        style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
      ),
      onTap: () async {
        bool songDeleted = false;
        await context.showActionDialog<void>(
          icon: Icon(
            Icons.warning_rounded,
            color: context.colorScheme.error,
            size: 30,
          ),
          title: 'Delete song',
          titleFontSize: FontSize.medium,
          textContent: dedent('''
                      This CANNOT be undone.
                      Are you sure you want to delete
        
                      ${song.name}'''),
          contentFontSize: FontSize.small,
          time: 300.ms,
          scaleAlignment: .bottomCenter,
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () async {
                if (songService.currentSongID == songID) {
                  songService.currentSongID = -1;
                  Globals.showMinimizedPlayer.value = false;
                }
                playerService.pause();
                await song.delete();
                File(Paths.downloadPath + song.path).deleteSync();
                songDeleted = true;
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        );
        if (songDeleted) {
          await loadData();
          songService.sortAllSongs();
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }
}
