import 'dart:math';

import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/album/add_album_song.dart';
import 'package:music_hub/ui/app/album/album_info.dart';
import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/song_options.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class AlbumSongs extends StatefulWidget {
  final int albumID;

  const AlbumSongs({super.key, required this.albumID});

  @override
  State<AlbumSongs> createState() => _AlbumSongsState();
}

class _AlbumSongsState extends State<AlbumSongs> {
  final songService = get<SongService>(),
      albumService = get<AlbumService>(),
      logService = get<LogService>(),
      playlistService = get<PlaylistService>();

  late Album album;
  List<Song> songs = [];
  late int totalSongCount;

  void getSongs() {
    album = albumService.albums.firstWhere((e) => e.id == widget.albumID);
    songs = [];
    for (final sId in album.songs) {
      final s = songService.getSong(sId);
      if (s != null) songs.add(s);
    }
    totalSongCount = songs.length;
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
            onPressed: context.popRoute,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
          ),
          centerTitle: true,
          title: Text(
            album.name,
            style: const TextStyle(fontWeight: .w700),
            textAlign: .center,
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await context.getBottomSheet(
                  Text(
                    album.name,
                    style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                    textAlign: .center,
                    softWrap: true,
                  ),
                  [
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: context.iconColor(),
                      ),
                      title: const Text(
                        'Album info',
                        style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                      ),
                      onTap: () async {
                        bool? needsUpdate = await context.pushRoute(
                          PageRouteBuilder<bool>(
                            transitionDuration: 400.ms,
                            transitionsBuilder: (_, anim, _, child) {
                              return ScaleTransition(
                                alignment: Alignment.bottomCenter,
                                scale: Tween<double>(begin: 0, end: 1)
                                    .chain(CurveTween(curve: Curves.easeOutCubic))
                                    .animate(anim),
                                child: child,
                              );
                            },
                            pageBuilder: (_, _, _) => AlbumInfo(albumID: widget.albumID),
                          ),
                        );
                        if (needsUpdate == true) {
                          setState(() {
                            albumService.updateAlbumList();
                          });
                          if (context.mounted) context.popRoute();
                        }
                      },
                    ),
                    if (album.id != 1)
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                        leading: Icon(Icons.delete_rounded, color: context.iconColor()),
                        title: const Text(
                          'Delete album',
                          style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                        ),
                        onTap: () async {
                          bool deleteAlbum = false;

                          await context.showActionDialog<bool>(
                            icon: Icon(
                              Icons.warning_rounded,
                              color: context.colorScheme.error,
                              size: 30,
                            ),
                            title: 'Delete Album',
                            titleFontSize: 24,
                            textContent: dedent('''
                                  This CANNOT be undone.
                                  Are you sure you want to delete
                    
                                  ${album.name}'''),
                            contentFontSize: 16,
                            time: 300.ms,
                            actions: [
                              TextButton(
                                onPressed: context.popRoute,
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  deleteAlbum = true;
                                  await albumService.albums
                                      .firstWhereOrNull((a) => a.id == widget.albumID)
                                      ?.delete();
                                  await albumService.updateAlbumList();
                                  if (context.mounted) context.popRoute(true);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                          if (deleteAlbum && context.mounted) {
                            context.popRoute();
                            context.popRoute();
                          }
                        },
                      ),
                  ],
                );
              },
              icon: const Icon(Icons.more_vert_rounded),
            ),
          ],
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
                          if (!playlistService.isShuffled) {
                            playlistService.changeShuffleMode();
                          }
                          // get artistName or album.name depend on category
                          playlistService.registerPlaylist(
                            album.name,
                            songs.map((e) => e.id).toList(),
                            randomSong,
                          );
                          await context.pushRoute(await getMusicPlayerRoute(randomSong));
                        },
                ),
                TextButton.icon(
                  style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
                  icon: FaIcon(
                    FaIconData(Icons.play_circle_filled_rounded),
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
                          if (playlistService.isShuffled) {
                            playlistService.changeShuffleMode();
                          }
                          // get artistName or album.name depend on category
                          playlistService.registerPlaylist(
                            album.name,
                            songs.map((e) => e.id).toList(),
                            first,
                          );
                          await context.pushRoute(await getMusicPlayerRoute(first));
                        },
                ),
              ],
            ),
            Expanded(
              child: album.id == 1
                  ? ListView.builder(
                      itemCount: totalSongCount,
                      itemBuilder: (context, songIndex) {
                        final song = songs[songIndex];
                        return songTile(song, songIndex);
                      },
                    )
                  : ReorderableListView.builder(
                      itemCount: totalSongCount + (album.id == 1 ? 0 : 1),
                      onReorder: (oIdx, nIdx) {
                        if (nIdx > oIdx) nIdx--;
                        oIdx--;
                        nIdx--;
                        if (nIdx > totalSongCount ||
                            album.id == 1 ||
                            nIdx == oIdx ||
                            nIdx < 0) {
                          return;
                        }
                        final oldSongId = songs[oIdx].id, newSongId = songs[nIdx].id;
                        logService.log(
                          'Reorder album: $oIdx (id=$oldSongId) -> $nIdx (id=$newSongId)',
                        );
                        album.songs.insert(nIdx, album.songs.removeAt(oIdx));
                        album.update();
                        setState(getSongs);
                      },
                      proxyDecorator: (child, _, _) {
                        return ClipRRect(
                          borderRadius: .circular(10),
                          child: Material(
                            color: context.colorScheme.surfaceContainerHighest,
                            child: child,
                          ),
                        );
                      },
                      itemBuilder: (context, songIndex) {
                        final isNewTile = album.id == 1 ? false : songIndex == 0;
                        final song = isNewTile
                            ? null
                            : songs[songIndex - (album.id == 1 ? 0 : 1)];

                        if (isNewTile) {
                          if (album.id == 1) {
                            return const SizedBox.shrink(key: ValueKey(-1));
                          }

                          // add to album
                          return OpenContainer(
                            key: const ValueKey(-1),
                            closedElevation: 0,
                            closedColor: context.colorScheme.surface,
                            openColor: Colors.transparent,
                            transitionDuration: 400.ms,
                            onClosed: (_) => setState(getSongs),
                            openBuilder: (_, _) => AddAlbumSong(albumID: widget.albumID),
                            closedBuilder: (_, action) {
                              return ListTile(
                                title: const Icon(Icons.add_rounded),
                                onTap: action,
                              );
                            },
                          );
                        }
                        // song tile
                        return songTile(song!, songIndex);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile songTile(Song song, int songIndex) {
    return ListTile(
      key: ValueKey(song.id),
      contentPadding: const .symmetric(horizontal: 4),
      leading: Padding(
        padding: const .only(left: 16),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Text((songIndex + (album.id == 1 ? 1 : 0)).toString().padLeft(2, '0')),
          ],
        ),
      ),
      title: Text(
        song.name,
        overflow: .ellipsis,
        style: const TextStyle(fontWeight: .w600),
      ),
      subtitle: Text(
        song.artist,
        overflow: .ellipsis,
        style: TextStyle(color: Colors.grey[600], fontWeight: .w400),
      ),
      onTap: () async {
        playlistService.registerPlaylist(
          album.name,
          songs.map((e) => e.id).toList(),
          song.id,
        );
        await context.pushRoute(await getMusicPlayerRoute(song.id));
        setState(() {});
      },
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: () async {
          await context.showSongOptionsMenu(
            songID: song.id,
            options: [
              SongInfoOption(
                songID: song.id,
                updateCallback: () {
                  setState(() {});
                },
              ),
              if (album.id != 1)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                  leading: Icon(Icons.delete_rounded, color: context.iconColor()),
                  title: const Text(
                    'Remove from playlist',
                    style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                  ),
                  onTap: () async {
                    bool songRemoved = false;
                    await context.showActionDialog<bool>(
                      title: 'Remove from album',
                      titleFontSize: 24,
                      textContent: dedent("""
                                      Are you sure you want to remove
  
                                      ${song.name}
  
                                      from album '${album.name}'"""),
                      contentFontSize: 16,
                      time: 300.ms,
                      actions: [
                        TextButton(
                          onPressed: context.popRoute,
                          child: const Text('No'),
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            songRemoved = true;
                            await song.removeFromPlaylist(widget.albumID);
                            if (mounted) context.popRoute();
                          },
                        ),
                      ],
                    );
                    if (songRemoved) {
                      await albumService.updateAlbumList();
                      if (mounted) context.popRoute();
                    }
                  },
                ),
            ],
          );
          getSongs();
          setState(() {});
        },
      ),
    );
  }
}
