import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/home/home_view_model.dart';
import 'package:music_hub/ui/app/main_screen/album_list.dart';
import 'package:music_hub/ui/app/main_screen/drawer.dart';
import 'package:music_hub/ui/app/main_screen/song_list.dart';
import 'package:music_hub/ui/app/permission/storage_permission.dart';
import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/app/search/search.dart';
import 'package:music_hub/ui/app/songs/artist_songs.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Constants;
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber, WhereOrNull;
import 'package:music_hub/utils/globals.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final logService = GetIt.I<LogService>();
  late final animController = AnimationController(
    duration: 300.ms,
    reverseDuration: 300.ms,
    vsync: this,
  );
  bool isDarkTheme = false;
  int _childParam = 0;

  @override
  void initState() {
    super.initState();
    widget.viewModel.playerService.playing
        ? animController.forward(from: 0)
        : animController.reverse(from: 1);

    widget.viewModel.checkStoragePermission().then((storagePermissionStatus) async {
      if (!storagePermissionStatus.isGranted && mounted) {
        await showDialog(
          context: context,
          builder: (_) => const StoragePermissionDialog(),
          barrierDismissible: false,
        );

        storagePermissionStatus = await Permission.manageExternalStorage.status;
      } else {
        await widget.viewModel.loadSongs();
      }
    });

    widget.viewModel.playerService.onPlayingChange.listen((playing) {
      if (playing) {
        animController.forward(from: 0);
      } else {
        animController.reverse(from: 1);
      }
    });

    widget.viewModel.checkNewVersion().then((result) {
      if (result.$1 && mounted) {
        context.showPopupMessage(
          title: 'New version available',
          content:
              'Current version: v${Constants.appVersion}\n'
              'New version: ${result.$2}',
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.viewModel.playerService.player.dispose();
  }

  void updateChildren() {
    _childParam = _childParam == 0 ? 1 : 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return SafeArea(
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: context.theme.colorScheme.surface,
                title: Container(
                  height: AppBar().preferredSize.height * 0.65,
                  margin: const .only(right: 15),
                  child: TextField(
                    readOnly: true,
                    decoration: context.textFieldDecoration(
                      hintText: 'Search songs and artists',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: context.theme.colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: context.theme.colorScheme.onSurface,
                        ),
                        borderRadius: .circular(25),
                      ),
                      fillColor: context.theme.colorScheme.secondaryContainer.withValues(
                        alpha: 0.4,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder: (context, _, _) => const SearchScreen(),
                          transitionDuration: 400.ms,
                          transitionsBuilder: (_, anim, _, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                        begin: const Offset(0, -1),
                                        end: const Offset(0, 0),
                                      )
                                      .chain(CurveTween(curve: Curves.easeOutCubic))
                                      .animate(anim),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                bottom: TabBar(
                  enableFeedback: false,
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: .label,
                  indicator: UnderlineTabIndicator(
                    borderRadius: .circular(10),
                    insets: const .symmetric(horizontal: 20, vertical: 6),
                    borderSide: BorderSide(
                      width: 3,
                      color: context.theme.colorScheme.primary,
                    ),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: .bold,
                    fontSize: FontSize.mediumSmall,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: FontSize.small),
                  tabs: const [
                    Tab(child: Text('Songs')),
                    Tab(child: Text('Artists')),
                    Tab(child: Text('Albums')),
                  ],
                ),
              ),
              drawer: const MainDrawer(),
              body: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : StretchingOverscrollIndicator(
                      axisDirection: .right,
                      child: TabBarView(
                        children: [
                          // song list
                          SongList(param: _childParam, updateParent: setState),
                          // artist list
                          ListView.builder(
                            itemCount: vm.songService.artists.length,
                            itemBuilder: (context, artistIndex) {
                              String artistName = vm.songService.artists.keys.elementAt(
                                artistIndex,
                              );
                              return OpenContainer(
                                closedElevation: 0,
                                closedColor: context.theme.colorScheme.surface,
                                openColor: Colors.transparent,
                                transitionDuration: 400.ms,
                                onClosed: (_) => setState(() {}),
                                openBuilder: (context, action) {
                                  return ArtistSongs(artistName: artistName);
                                },
                                closedBuilder: (context, action) {
                                  final songCount = vm.songService.artists[artistName];
                                  if (songCount == null) return const SizedBox.shrink();

                                  return ListTile(
                                    contentPadding: const .symmetric(horizontal: 20),
                                    title: Text(
                                      artistName,
                                      style: const TextStyle(fontWeight: .w600),
                                    ),
                                    subtitle: Text(
                                      '$songCount song${songCount > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: .w400,
                                      ),
                                    ),
                                    onTap: action,
                                  );
                                },
                              );
                            },
                          ),
                          const AlbumList(),
                        ],
                      ),
                    ),
              // mini player
              bottomNavigationBar: Visibility(
                visible: Globals.showMinimizedPlayer,
                child: Container(
                  margin: const .only(left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: context.theme.colorScheme.primaryContainer,
                    borderRadius: .circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 5,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceEvenly,
                    crossAxisAlignment: .center,
                    children: [
                      Expanded(
                        child: Theme(
                          data: context.theme.copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: ListTile(
                            contentPadding: .zero,
                            dense: true,
                            visualDensity: .compact,
                            leading: Padding(
                              padding: const .only(left: 14),
                              child: Icon(
                                Icons.music_note_rounded,
                                color: context.theme.colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              vm.songService.currentSongID >= 0 && !vm.loading
                                  ? '${vm.songService.allSongs.firstWhereOrNull((e) => e.id == vm.songService.currentSongID)?.name}'
                                  : 'None',
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontWeight: .w700,
                                fontSize: FontSize.small,
                              ),
                            ),
                            subtitle: Text(
                              vm.songService.currentSongID >= 0 && !vm.loading
                                  ? '${vm.songService.allSongs.firstWhereOrNull((e) => e.id == vm.songService.currentSongID)?.artist}'
                                  : 'None',
                            ),
                            onTap: vm.loading
                                ? null
                                : () async {
                                    await Navigator.of(context).push(
                                      await getMusicPlayerRoute(
                                        context,
                                        vm.songService.currentSongID,
                                      ),
                                    );
                                    setState(() {});
                                  },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => vm.playerService.skipToPrevious(),
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: context.theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      Stack(
                        alignment: .center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            value: vm.playerService.currentDuration / vm.playerService.totalDuration,
                          ),
                          IconButton(
                            onPressed: () {
                              if (Globals.setDuplicate) {
                                vm.playerService.setPlayerSong(vm.songService.currentSongID);
                              } else {
                                vm.playerService.playing
                                    ? vm.playerService.pause()
                                    : vm.playerService.play();
                              }
                              setState(() {});
                            },
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(animController),
                              color: context.theme.colorScheme.primary,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => vm.playerService.skipToNext(),
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: context.theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
