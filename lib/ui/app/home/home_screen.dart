import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/playlist_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/home/home_view_model.dart';
import 'package:music_hub/ui/app/home/permission/storage_permission.dart';
import 'package:music_hub/ui/app/home/search/search.dart';
import 'package:music_hub/ui/app/home/search/search_view_model.dart';
import 'package:music_hub/ui/app/home/tabs/album_list.dart';
import 'package:music_hub/ui/app/home/tabs/artist_list.dart';
import 'package:music_hub/ui/app/home/tabs/song_list.dart';
import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/app/sidebar/drawer.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/input.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals.dart';
import 'package:music_hub/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final playerService = get<PlayerService>(),
      playlistService = get<PlaylistService>(),
      songService = get<SongService>();

  late final animController = AnimationController(
    duration: 300.ms,
    reverseDuration: 300.ms,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    playerService.playing
        ? animController.forward(from: 0)
        : animController.reverse(from: 1);

    Future.microtask(() async {
      if (!mounted) return;
      final vm = context.read<HomeViewModel>();

      var status = await vm.checkStoragePermission();

      if (!status.isGranted && mounted) {
        await showDialog(
          context: context,
          builder: (_) => StoragePermissionDialog(),
          barrierDismissible: false,
        );
        status = await Permission.manageExternalStorage.status;
      }

      context.showCustomSnackBar(
        SnackBar(
          content: ValueListenableBuilder(
            valueListenable: vm.loadingSnackMessage,
            builder: (_, value, _) => Text(value),
          ),
          behavior: .floating,
          margin: const .only(bottom: 10, left: 15, right: 15),
          shape: RoundedRectangleBorder(borderRadius: .circular(15)),
          persist: true,
        ),
      );
      await vm.load(updateToast: (msg) => vm.loadingSnackMessage.value = msg);
      context.hideSnackBar();
    });

    Future.microtask(() async {
      if (!mounted) return;
      final vm = context.read<HomeViewModel>();

      final result = await vm.checkNewVersion();
      if (result.$1 && mounted) {
        context.showPopupMessage(
          title: 'New version available',
          content:
              'Current version: v${Constants.appVersion}\n'
              'New version: ${result.$2}',
        );
      }
    });

    playerService.onPlayingChange.listen((playing) {
      if (playing) {
        animController.forward(from: 0);
      } else {
        animController.reverse(from: 1);
      }
    });
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    return ListenableBuilder(
      listenable: vm,
      child: StretchingOverscrollIndicator(
        axisDirection: .right,
        child: TabBarView(
          children: const [
            SongList(), //
            ArtistList(),
            AlbumList(),
          ],
        ),
      ),
      builder: (context, child) {
        return SafeArea(
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: context.colorScheme.surface,
                title: Input(
                  readOnly: true,
                  hintText: 'Search songs and artists',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.colorScheme.primary,
                  ),
                  constraints: BoxConstraints.loose(
                    Size.fromHeight(AppBar().preferredSize.height * 0.65),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, _, _) {
                          return SearchScreen(viewModel: SearchViewModel());
                        },
                        transitionDuration: 400.ms,
                        transitionsBuilder: (_, anim, _, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -1),
                              end: const Offset(0, 0),
                            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(anim),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                bottom: TabBar(
                  enableFeedback: false,
                  splashFactory: NoSplash.splashFactory,
                  indicatorSize: .label,
                  indicator: UnderlineTabIndicator(
                    borderRadius: .circular(10),
                    insets: const .symmetric(vertical: 6),
                    borderSide: BorderSide(width: 3, color: context.colorScheme.primary),
                  ),
                  labelStyle: const TextStyle(
                    fontWeight: .bold,
                    fontSize: FontSize.mediumSmall,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: FontSize.small),
                  tabs: const [
                    Tab(text: 'Songs'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Albums'),
                  ],
                ),
              ),
              drawer: const HomeDrawer(),
              body: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : child!,
              // mini player
              bottomNavigationBar: ValueListenableBuilder(
                valueListenable: Globals.showMinimizedPlayer,
                builder: (context, showMinimizedPlayer, child) {
                  return Visibility(visible: showMinimizedPlayer, child: child!);
                },
                child: Container(
                  margin: const .only(left: 10, right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
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
                                color: context.colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              songService.currentSongID >= 0 && !vm.loading
                                  ? '${songService.getSong(songService.currentSongID)?.name}'
                                  : 'None',
                              overflow: .ellipsis,
                              style: const TextStyle(
                                fontWeight: .w700,
                                fontSize: FontSize.small,
                              ),
                            ),
                            subtitle: Text(
                              songService.currentSongID >= 0 && !vm.loading
                                  ? '${songService.getSong(songService.currentSongID)?.artist}'
                                  : 'None',
                            ),
                            onTap: vm.loading
                                ? null
                                : () async {
                                    await Navigator.of(context).push(
                                      await getMusicPlayerRoute(
                                        songService.currentSongID,
                                      ),
                                    );
                                    setState(() {});
                                  },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => playerService.skipToPrevious(),
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: context.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      Stack(
                        alignment: .center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                playerService.currentDuration /
                                playerService.totalDuration,
                          ),
                          IconButton(
                            onPressed: () {
                              if (Globals.setDuplicate) {
                                playerService.setPlayerSong(songService.currentSongID);
                              } else {
                                playerService.playing
                                    ? playerService.pause()
                                    : playerService.play();
                              }
                              setState(() {});
                            },
                            icon: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(animController),
                              color: context.colorScheme.primary,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => playerService.skipToNext(),
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: context.colorScheme.primary,
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
