import 'package:flutter/material.dart';

import 'package:music_hub/ui/app/player/music_player.dart';
import 'package:music_hub/ui/app/search/search_view_model.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/input.dart';

class SearchScreen extends StatefulWidget {
  final SearchViewModel viewModel;

  const SearchScreen({super.key, required this.viewModel});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 40),
            onPressed: Navigator.of(context).pop,
          ),
          title: Input(
            autofocus: true,
            onChanged: vm.searchSongs,
            hintText: 'Search songs and artists',
            constraints: BoxConstraints.loose(
              Size.fromHeight(AppBar().preferredSize.height * 0.65),
            ),
            prefixIcon: Icon(Icons.search_rounded, color: context.colorScheme.primary),
          ),
        ),
        body: ListenableBuilder(
          listenable: vm,
          builder: (context, child) {
            return ListView.builder(
              padding: const .symmetric(horizontal: 15, vertical: 15),
              itemCount: vm.filteredSongs.length,
              itemBuilder: (context, index) {
                final song = vm.songService.songs.firstWhere(
                  (e) => e.path == vm.filteredSongs[index],
                );
                return ListTile(
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
                    FocusManager.instance.primaryFocus?.unfocus();
                    vm.playerService.registerPlaylist(
                      'All songs',
                      vm.songService.idList,
                      song.id,
                    );
                    await Navigator.of(context).pushReplacement(await getMusicPlayerRoute(song.id));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
