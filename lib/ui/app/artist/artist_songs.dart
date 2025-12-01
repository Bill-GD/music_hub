import 'dart:math';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/song_options.dart';

class ArtistSongs extends StatefulWidget {
  final String artistName;

  const ArtistSongs({super.key, required this.artistName});

  @override
  State<ArtistSongs> createState() => _ArtistSongsState();
}

class _ArtistSongsState extends State<ArtistSongs> {
  final songService = GetIt.I<SongService>(), playerService = GetIt.I<PlayerService>();
  late List<Song> songs;

  void getSongs() {
    songs = songService.songs.where((s) => s.artist == widget.artistName).toList()
      ..sort(
        (track1, track2) =>
            track1.name.toLowerCase().compareTo(track2.name.toLowerCase()),
      );
  }

  @override
  void initState() {
    super.initState();
    getSongs();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
          ),
          centerTitle: true,
          title: Text(
            widget.artistName,
            style: const TextStyle(fontWeight: .w700),
            textAlign: .center,
          ),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                TextButton.icon(
                  style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  icon: FaIcon(
                    FontAwesomeIcons.shuffle,
                    size: 25,
                    color: context.iconColor(songs.isEmpty ? 0.5 : 1),
                  ),
                  label: Text(
                    'Shuffle playback',
                    style: TextStyle(
                      fontWeight: .w700,
                      color: context.iconColor(songs.isEmpty ? 0.5 : 1),
                    ),
                  ),
                  onPressed: songs.isEmpty
                      ? null
                      : () async {
                          final randomSong = songs[Random().nextInt(songs.length)].id;
                          if (!playerService.isShuffled) {
                            playerService.changeShuffleMode();
                          }
                          // get artistName or album.name depend on category
                          playerService.registerPlaylist(
                            widget.artistName,
                            songs.map((e) => e.id).toList(),
                            randomSong,
                          );
                          await Navigator.of(
                            context,
                          ).push(await getMusicPlayerRoute(randomSong));
                        },
                ),
                TextButton.icon(
                  style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  icon: FaIcon(
                    Icons.play_circle_filled_rounded,
                    size: 30,
                    color: context.iconColor(songs.isEmpty ? 0.5 : 1),
                  ),
                  label: Text(
                    'Play sequentially',
                    style: TextStyle(
                      fontWeight: .w700,
                      color: context.iconColor(songs.isEmpty ? 0.5 : 1),
                    ),
                  ),
                  onPressed: songs.isEmpty
                      ? null
                      : () async {
                          final first = songs[0].id;
                          if (playerService.isShuffled) {
                            playerService.changeShuffleMode();
                          }
                          // get artistName or album.name depend on category
                          playerService.registerPlaylist(
                            widget.artistName,
                            songs.map((e) => e.id).toList(),
                            first,
                          );
                          await Navigator.of(
                            context,
                          ).push(await getMusicPlayerRoute(first));
                        },
                ),
              ],
            ),
            Expanded(
              child: StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, songIndex) => ListTile(
                    contentPadding: const .symmetric(horizontal: 4),
                    leading: Padding(
                      padding: const .only(left: 16),
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        children: [Text((songIndex + 1).toString().padLeft(2, '0'))],
                      ),
                    ),
                    title: Text(
                      songs[songIndex].name,
                      overflow: .ellipsis,
                      style: const TextStyle(fontWeight: .w600),
                    ),
                    subtitle: Text(
                      songs[songIndex].artist,
                      overflow: .ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: .w400,
                      ),
                    ),
                    onTap: () async {
                      playerService.registerPlaylist(
                        widget.artistName,
                        songs.map((e) => e.id).toList(),
                        songs[songIndex].id,
                      );
                      await Navigator.of(
                        context,
                      ).push(await getMusicPlayerRoute(songs[songIndex].id));
                      setState(() {});
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () async {
                        await context.showSongOptionsMenu(
                          songID: songs[songIndex].id,
                          options: [
                            SongInfoOption(
                              songID: songs[songIndex].id,
                              updateCallback: () {
                                setState(() {});
                              },
                            ),
                            DeleteSongOption(songID: songs[songIndex].id),
                          ],
                        );
                        getSongs();
                        if (songs.isEmpty && context.mounted) {
                          Navigator.of(context).pop();
                        } else {
                          setState(() {});
                        }
                      },
                    ),
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
