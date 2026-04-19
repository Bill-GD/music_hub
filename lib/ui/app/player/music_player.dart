import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/models/song_lyric.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/data/services/lyric_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/player/lyric/lyric_editor.dart';
import 'package:music_hub/ui/app/player/lyric/lyric_strip.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/button.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/file_picker.dart';
import 'package:music_hub/ui/core/widgets/page_indicator.dart';
import 'package:music_hub/ui/core/widgets/playlist_sheet.dart';
import 'package:music_hub/ui/core/widgets/song_options.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

Future<Route> getMusicPlayerRoute(int songID) async {
  await get<PlayerService>().setPlayerSong(songID, shouldPlay: !Globals.setDuplicate);
  return PageRouteBuilder(
    pageBuilder: (context, _, _) => MusicPlayer(songID: songID),
    transitionDuration: 400.ms,
    transitionsBuilder: (_, anim, _, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim),
        child: child,
      );
    },
  );
}

class MusicPlayer extends StatefulWidget {
  final int songID;

  const MusicPlayer({super.key, required this.songID});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> with TickerProviderStateMixin {
  final lyricService = get<LyricService>(),
      playerService = get<PlayerService>(),
      playlistService = get<PlaylistService>(),
      songService = get<SongService>(),
      albumService = get<AlbumService>(),
      logService = get<LogService>();

  int currentDuration = 0, maxDuration = 0;
  final List<StreamSubscription> subs = [];
  late final AnimationController animController;
  late final TabController tabController;
  late Song song;
  late SongLyric lyric;
  Image? coverImage;

  void updateSongInfo([int? songID]) async {
    logService.log("Updating player's UI");

    song = songService.getSong(songID ?? songService.currentSongID)!;
    currentDuration = playerService.currentDuration;
    maxDuration = playerService.totalDuration;
    updateLyric();
    updateCoverImage();
    setState(() {});
  }

  void updateLyric() {
    logService.log('Updating lyric');
    lyric =
        lyricService.getLyric(song.id, Paths.lyricPath + song.lyricPath) ??
        SongLyric(
          songId: song.id,
          name: song.name,
          artist: song.artist,
          path: '${song.name}.lrc',
          list: [],
        );
    setState(() {});
  }

  void updateCoverImage() {
    logService.log('Updating cover image');
    coverImage = null;
    if (File(song.imagePath).existsSync()) {
      logService.log('Cover image for song found');
      coverImage = Image.file(File(song.imagePath), fit: .cover);
    } else {
      final album = albumService.albums.firstWhereOrNull(
        (e) => e.name == playlistService.playlistName,
      );
      if (album != null && File(album.imagePath).existsSync()) {
        logService.log('Cover image for album found');
        coverImage = Image.file(File(album.imagePath), fit: .cover);
      }
    }
    if (coverImage == null) {
      if (song.imagePath.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.showToast('Image for this song is missing.');
        });
      }
      logService.log('No cover image found');
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateSongInfo(widget.songID);

    animController = AnimationController(
      duration: 300.ms,
      reverseDuration: 300.ms,
      vsync: this,
    );
    playerService.playing
        ? animController.forward(from: 0)
        : animController.reverse(from: 1);

    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() => setState(() {}));

    subs.add(
      playerService.onSongChange.listen((changed) {
        if (changed) updateSongInfo();
      }),
    );
    subs.add(
      playerService.player.positionStream.listen((current) {
        currentDuration = current.inMilliseconds;
        setState(() {});
      }),
    );
    subs.add(
      playerService.onPlayingChange.listen((playing) {
        if (playing) {
          animController.forward(from: 0);
        } else {
          animController.reverse(from: 1);
        }
      }),
    );
    subs.add(
      songService.lyricChangedController.stream.listen((_) {
        updateLyric();
      }),
    );
  }

  @override
  void dispose() {
    for (final e in subs) {
      e.cancel();
    }
    tabController.dispose();
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          image: coverImage == null
              ? null
              : DecorationImage(
                  image: coverImage!.image,
                  fit: .cover,
                  filterQuality: .none,
                ),
          gradient: coverImage == null
              ? LinearGradient(
                  colors: [
                    context.colorScheme.surface,
                    context.colorScheme.primaryContainer,
                  ],
                  stops: const [0.0, 0.8],
                  begin: .topCenter,
                  end: .bottomCenter,
                )
              : null,
        ),
        child: _applyBackFilter(
          hasImage: coverImage != null,
          child: Scaffold(
            backgroundColor: coverImage == null
                ? Colors.transparent
                : context.colorScheme.surfaceContainerLowest.withValues(alpha: 0.5),
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
                onPressed: () async {
                  if (context.mounted) context.popRoute();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () async {
                    await context.showSongOptionsMenu(
                      songID: songService.currentSongID,
                      options: [
                        SongInfoOption(
                          songID: songService.currentSongID,
                          updateCallback: updateSongInfo,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const .only(top: 20),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  // "Image" & Lyric
                  ConstrainedBox(
                    constraints: const .tightFor(height: 320),
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        Stack(
                          alignment: .center,
                          children: [
                            Container(
                              constraints: .tight(const Size(320, 320)),
                              decoration: coverImage == null
                                  ? BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          context.colorScheme.primaryContainer,
                                          Colors.white70,
                                          context.colorScheme.primaryContainer,
                                        ],
                                        begin: .topCenter,
                                        end: .bottomCenter,
                                      ),
                                      border: .all(
                                        width: 1,
                                        color: context.colorScheme.onSurface,
                                      ),
                                      borderRadius: .circular(20),
                                    )
                                  : null,
                              child: coverImage == null
                                  ? Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.grey[850],
                                      size: 180,
                                    )
                                  : ClipRRect(
                                      borderRadius: .circular(20),
                                      child: coverImage,
                                    ),
                            ),
                          ],
                        ),
                        if (song.lyricPath.isEmpty || lyric.list.isEmpty)
                          Column(
                            mainAxisAlignment: .center,
                            children: [
                              Button(
                                text: 'Add lyric',
                                outline: true,
                                onPressed: () {
                                  context.pushRoute(
                                    MaterialPageRoute(
                                      builder: (context) => LyricEditor(songID: song.id),
                                    ),
                                  );
                                },
                              ),
                              Button(
                                text: 'Select file',
                                onPressed: () async {
                                  var path = await FilePicker.open(
                                    context: context,
                                    rootDirectory: Directory(Paths.lyricPath),
                                    allowedExtensions: const ['lrc'],
                                  );
                                  if (path == null) return;
                                  path = path.split(Paths.lyricPath).last;
                                  if (song.lyricPath == path) return;

                                  logService.log('Chosen new lrc: $path');
                                  song.lyricPath = path;
                                  await song.update();
                                  updateLyric();
                                },
                              ),
                            ],
                          )
                        else
                          const LyricStrip(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const .symmetric(vertical: 20, horizontal: 30),
                    child: PageIndicator(pageCount: 2, currentIndex: tabController.index),
                  ),
                  InkWell(
                    borderRadius: .circular(5),
                    onTap: () {
                      context.pushRoute(
                        CupertinoModalPopupRoute(
                          builder: (context) => const PlaylistSheet(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const .all(6.0),
                      child: Row(
                        mainAxisAlignment: .center,
                        mainAxisSize: .min,
                        children: [
                          const Icon(Icons.list_rounded),
                          const SizedBox(width: 5),
                          Text(
                            playlistService.playlistDisplayName,
                            style: const TextStyle(
                              fontWeight: .w600,
                              fontSize: FontSize.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Song info
                  Padding(
                    padding: const .only(bottom: 30, top: 12, left: 30, right: 30),
                    child: Column(
                      children: [
                        Text(
                          song.name,
                          textAlign: .center,
                          overflow: .ellipsis,
                          style: const TextStyle(
                            fontWeight: .w700,
                            fontSize: FontSize.mediumSmall,
                          ),
                        ),
                        Text(
                          song.artist,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontWeight: .w600,
                            fontSize: FontSize.small,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const .symmetric(horizontal: 30),
                    child: Stack(
                      children: [
                        ProgressBar(
                          progress: min(maxDuration, currentDuration).ms,
                          total: maxDuration.ms,
                          thumbCanPaintOutsideBar: false,
                          thumbRadius: 6,
                          timeLabelPadding: 5,
                          timeLabelLocation: .below,
                          timeLabelType: .totalTime,
                          timeLabelTextStyle: TextStyle(
                            color: context.colorScheme.onSurface,
                            fontWeight: .bold,
                          ),
                          onSeek: (seekDuration) async {
                            currentDuration = min(
                              maxDuration,
                              seekDuration.inMilliseconds,
                            );
                            await playerService.seek(seekDuration);
                            setState(() {});
                          },
                        ),
                        Container(
                          height: 4.5,
                          width: 2,
                          margin: .only(
                            top: 4,
                            left:
                                playerService.minTimePercent *
                                MediaQuery.of(context).size.width,
                          ),
                          color: context.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  // Controls
                  Padding(
                    padding: const .only(top: 20, bottom: 70, left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            playlistService.changeShuffleMode();
                            setState(() {});
                          },
                          icon: Icon(
                            CupertinoIcons.shuffle,
                            color: playlistService.isShuffled
                                ? context.colorScheme.primary
                                : context.colorScheme.primary.withValues(alpha: 0.3),
                            size: 30,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await playerService.skipToPrevious();
                          },
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: context.colorScheme.primary,
                            size: 45,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: .circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                          child: IconButton(
                            onPressed: () {
                              playerService.playing
                                  ? playerService.pause()
                                  : playerService.play();
                              setState(() {});
                            },
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(animController),
                              color: context.colorScheme.primary,
                              size: 70,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await playerService.skipToNext();
                          },
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: context.colorScheme.primary,
                            size: 45,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await playlistService.changeRepeatMode();
                            setState(() {});
                          },
                          icon: Icon(
                            playlistService.repeatMode == .one
                                ? CupertinoIcons.repeat_1
                                : CupertinoIcons.repeat,
                            color: playlistService.repeatMode == .none
                                ? context.colorScheme.primary.withValues(alpha: 0.3)
                                : context.colorScheme.primary,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _applyBackFilter({required bool hasImage, required Widget child}) {
  return hasImage
      ? BackdropFilter(filter: .blur(sigmaX: 30, sigmaY: 30), child: child)
      : child;
}
