import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/models/song.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/extensions.dart' show PadInt, WhereOrNull;
import 'package:music_hub/utils/utils.dart';

class AddAlbumSong extends StatefulWidget {
  final int albumID;

  const AddAlbumSong({super.key, required this.albumID});

  @override
  State<AddAlbumSong> createState() => _AddAlbumSongState();
}

class _AddAlbumSongState extends State<AddAlbumSong> {
  final songService = GetIt.I<SongService>();
  late final Album album;
  late final List<Song> availableSongs;
  late final List<int> order;
  final searchController = TextEditingController();
  bool canAdd = false;
  int songAddedCount = 0;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    album = songService.albums.firstWhere((e) => e.id == widget.albumID);
    availableSongs =
        songService.allSongs
            .where((e) => !album.songs.contains(e.id)) //
            .toList()
          ..sort((a, b) => a.id - b.id);
    order = List.generate(availableSongs.length, (_) => -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
        ),
        centerTitle: true,
        title: const Text(
          'Add new song',
          style: TextStyle(fontWeight: .w700),
          textAlign: .center,
        ),
        actions: [
          IconButton(
            onPressed: canAdd
                ? () async {
                    // LogHandler.log('$order');
                    // LogHandler.log('${availableSongs.map((e) => e.id)}');
                    final unknown = songService.albums.firstWhere((e) => e.id == 1);
                    for (final i in range(1, songAddedCount)) {
                      final si = availableSongs[order.indexOf(i)].id;
                      songService.allSongs.firstWhereOrNull((e) => e.id == si)?.hasAlbum =
                          true;
                      album.songs.add(si);
                      unknown.songs.remove(si);
                    }
                    await album.update();
                    await unknown.update();
                    await songService.updateAlbumList();
                    if (context.mounted) Navigator.of(context).pop();
                  }
                : null,
            icon: const Icon(Icons.check_rounded, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const .symmetric(horizontal: 30),
            margin: const .symmetric(vertical: 10),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                searchText = val;
                setState(() {});
              },
              decoration: context.textFieldDecoration(
                labelText: 'Search',
                hintText: 'Search names and artists',
                fillColor: context.theme.colorScheme.surface,
                border: const OutlineInputBorder(borderRadius: .all(.circular(10))),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const .symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: availableSongs.length,
                itemBuilder: (context, songIndex) {
                  final song = availableSongs[songIndex];
                  final tile = CheckboxListTile(
                    contentPadding: const .symmetric(horizontal: 4),
                    value: order[songIndex] != -1,
                    secondary: Text(
                      order[songIndex] < 0 ? '' : order[songIndex].padIntLeft(2, '0'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    title: Text(
                      song.name,
                      // '${song.id}. ${song.name}',
                      overflow: .ellipsis,
                      style: const TextStyle(fontWeight: .w600),
                    ),
                    subtitle: Text(
                      song.artist,
                      overflow: .ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontWeight: .w400),
                    ),
                    onChanged: (val) {
                      if (val == true) {
                        order[songIndex] = ++songAddedCount;
                      } else {
                        // order.map((e) => e > songAddedCount ? e - 1 : e);
                        for (int i = 0; i < order.length; i++) {
                          if (order[i] > order[songIndex]) order[i]--;
                        }
                        order[songIndex] = -1;
                        songAddedCount--;
                      }
                      canAdd = order.any((e) => e != -1);
                      setState(() {});
                    },
                  );
                  if (searchText.isEmpty) return tile;
                  return song.name.toLowerCase().contains(searchText.toLowerCase()) ||
                          song.artist.toLowerCase().contains(searchText.toLowerCase())
                      ? tile
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
