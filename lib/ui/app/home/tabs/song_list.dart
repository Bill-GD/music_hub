import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/song_options.dart';

class SongList extends StatefulWidget {
  final int param;
  final void Function(void Function()) updateParent;

  const SongList({super.key, required this.param, required this.updateParent});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> with TickerProviderStateMixin {
  final playerService = GetIt.I<PlayerService>(),
      songService = GetIt.I<SongService>(),
      configService = GetIt.I<ConfigService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const .symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              // shuffle playback
              TextButton.icon(
                icon: FaIcon(
                  FontAwesomeIcons.shuffle,
                  size: 20,
                  color: context.iconColor(),
                ),
                label: Text(
                  'Shuffle playback',
                  style: TextStyle(fontWeight: .w700, color: context.iconColor()),
                ),
                onPressed: () async {
                  final randomSong = songService
                      .allSongs[Random().nextInt(songService.allSongs.length)]
                      .id;
                  if (!playerService.isShuffled) playerService.changeShuffleMode();

                  playerService.registerPlaylist(
                    'All songs',
                    songService.allSongs.map((e) => e.id).toList(),
                    randomSong,
                  );
                  await Navigator.of(context).push(await getMusicPlayerRoute(randomSong));
                  setState(() {});
                },
              ),
              // sort songs
              Directionality(
                textDirection: .rtl,
                child: TextButton.icon(
                  icon: Icon(
                    CupertinoIcons.sort_down,
                    size: 30,
                    color: context.iconColor(),
                  ),
                  label: Text(
                    configService.getSortOptionString(),
                    style: TextStyle(fontWeight: .w700, color: context.iconColor()),
                  ),
                  onPressed: () async {
                    await context.getBottomSheet(
                      const Text(
                        'Sort Songs',
                        style: TextStyle(
                          fontSize: FontSize.mediumSmall,
                          fontWeight: .w700,
                        ),
                        textAlign: .center,
                        softWrap: true,
                      ),
                      [
                        ListTile(
                          visualDensity: .compact,
                          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                          leading: FaIcon(
                            FontAwesomeIcons.arrowDown19,
                            color: context.iconColor(),
                          ),
                          title: const Text(
                            'By ID',
                            style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                          ),
                          onTap: () {
                            setState(() => songService.sortAllSongs(.id));
                            Navigator.pop(context);
                            configService.saveConfig();
                          },
                        ),
                        ListTile(
                          visualDensity: .compact,
                          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                          leading: FaIcon(
                            FontAwesomeIcons.arrowDownAZ,
                            color: context.iconColor(),
                          ),
                          title: const Text(
                            'By name',
                            style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                          ),
                          onTap: () {
                            setState(() => songService.sortAllSongs(.name));
                            Navigator.pop(context);
                            configService.saveConfig();
                          },
                        ),
                        ListTile(
                          visualDensity: .compact,
                          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                          leading: FaIcon(
                            FontAwesomeIcons.arrowDown91,
                            color: context.iconColor(),
                          ),
                          title: const Text(
                            'By the number of times played',
                            style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                          ),
                          onTap: () {
                            setState(() => songService.sortAllSongs(.mostPlayed));
                            Navigator.pop(context);
                            configService.saveConfig();
                          },
                        ),
                        ListTile(
                          visualDensity: .compact,
                          shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                          leading: FaIcon(
                            FontAwesomeIcons.clock,
                            color: context.iconColor(),
                          ),
                          title: const Text(
                            'By adding time',
                            style: TextStyle(fontSize: FontSize.small, fontWeight: .w600),
                          ),
                          onTap: () {
                            setState(() => songService.sortAllSongs(.recentlyAdded));
                            Navigator.pop(context);
                            configService.saveConfig();
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // song list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await songService.updateMusicData();
              songService.sortAllSongs();
              if (context.mounted) setState(() {});
            },
            child: Scrollbar(
              interactive: true,
              thumbVisibility: true,
              radius: const .circular(16),
              thickness: min(songService.allSongs.length ~/ 3, 8).toDouble(),
              child: ListView.builder(
                itemCount: songService.allSongs.length,
                itemBuilder: (context, songIndex) => ListTile(
                  contentPadding: const .symmetric(horizontal: 4),
                  leading: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Padding(
                        padding: const .only(left: 12),
                        child: Icon(
                          Icons.music_note_rounded,
                          color: context.theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    songService.allSongs[songIndex].name,
                    overflow: .ellipsis,
                    style: const TextStyle(fontWeight: .w600),
                  ),
                  subtitle: Text(
                    songService.allSongs[songIndex].artist,
                    overflow: .ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontWeight: .w400),
                  ),
                  onTap: () async {
                    playerService.registerPlaylist(
                      'All songs',
                      songService.allSongs.map((e) => e.id).toList(),
                      songService.allSongs[songIndex].id,
                    );
                    await Navigator.of(
                      context,
                    ).push(await getMusicPlayerRoute(songService.allSongs[songIndex].id));
                    setState(() {});
                    widget.updateParent(() {});
                  },
                  trailing: Row(
                    mainAxisSize: .min,
                    children: [
                      Visibility(
                        visible: configService.currentSortOption == .mostPlayed,
                        child: Text('${songService.allSongs[songIndex].timeListened}'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded),
                        onPressed: () async {
                          await context.showSongOptionsMenu(
                            songID: songService.allSongs[songIndex].id,
                            options: [
                              SongInfoOption(
                                songID: songService.allSongs[songIndex].id,
                                updateCallback: () {
                                  setState(() {});
                                },
                              ),
                              DeleteSongOption(
                                songID: songService.allSongs[songIndex].id,
                              ),
                            ],
                          );
                          widget.updateParent(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
