import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/ui/core/widgets/input.dart';

class AddAlbum extends StatefulWidget {
  const AddAlbum({super.key});

  @override
  State<AddAlbum> createState() => _AddAlbumState();
}

class _AddAlbumState extends State<AddAlbum> {
  final albumService = GetIt.I<AlbumService>();

  final albumNameController = TextEditingController();
  String errorText = '';
  bool canAdd = false;
  late final names = albumService.albums.map((e) => e.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Add new album',
          style: TextStyle(fontWeight: .w700),
          textAlign: .center,
        ),
        actions: [
          IconButton(
            onPressed: canAdd
                ? () async {
                    await Album(
                      name: albumNameController.text,
                      timeAdded: DateTime.now(),
                    ).insert();
                    await albumService.updateAlbumList();
                    if (context.mounted) Navigator.of(context).pop();
                  }
                : null,
            icon: const Icon(Icons.check_rounded, size: 30),
          ),
        ],
      ),
      body: Padding(
        padding: const .symmetric(horizontal: 32, vertical: 16),
        child: Input(
          controller: albumNameController,
          onChanged: (val) {
            if (val.trim().isEmpty) {
              errorText = "Name can't be empty";
              canAdd = false;
            } else if (names.contains(val.trim())) {
              errorText = 'This name is already taken';
              canAdd = false;
            } else {
              errorText = '';
              canAdd = true;
            }
            setState(() {});
          },
          labelText: 'Name',
          errorText: errorText.isEmpty ? null : errorText,
          suffixIcon: const Padding(
            padding: .only(right: 12),
            child: Icon(Icons.edit_rounded),
          ),
        ),
      ),
    );
  }
}
