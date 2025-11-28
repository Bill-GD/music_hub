import 'dart:math';

import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/app/album/add_album.dart';
import 'package:music_hub/ui/app/album/album_songs.dart';
import 'package:music_hub/utils/extensions.dart';

class AlbumList extends StatefulWidget {
  const AlbumList({super.key});

  @override
  State<AlbumList> createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList> {
  final songService = GetIt.I<SongService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await songService.updateAlbumList();
          if (context.mounted) setState(() {});
        },
        child: ListView.builder(
          itemCount: songService.albums.length + 1,
          itemBuilder: (context, albumIndex) {
            final isNewTile = albumIndex == 0;
            final album =
                songService.albums[min(
                  isNewTile ? 0 : albumIndex - 1,
                  songService.albums.length - 1,
                )];

            return OpenContainer(
              closedElevation: 0,
              closedColor: Theme.of(context).colorScheme.surface,
              openColor: Colors.transparent,
              transitionDuration: 400.ms,
              onClosed: (_) => setState(() {}),
              openBuilder: (_, _) {
                return isNewTile ? const AddAlbum() : AlbumSongs(albumID: album.id);
              },
              closedBuilder: (_, action) {
                final songCount = album.songs.length;
                if (songCount < 0) return const SizedBox.shrink();

                return ListTile(
                  contentPadding: const .symmetric(horizontal: 20),
                  title: isNewTile
                      ? const Icon(Icons.add_rounded)
                      : Text(album.name, style: const TextStyle(fontWeight: .w600)),
                  subtitle: isNewTile
                      ? null
                      : Text(
                          '$songCount song${songCount > 1 ? 's' : ''}',
                          style: TextStyle(color: Colors.grey[600], fontWeight: .w400),
                        ),
                  onTap: action,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
