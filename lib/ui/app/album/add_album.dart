import 'package:flutter/material.dart';

import 'package:music_hub/data/database/database.dart';
import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/services/album_service.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/input.dart';
import 'package:music_hub/utils/utils.dart';

class AddAlbum extends StatefulWidget {
  const AddAlbum({super.key});

  @override
  State<AddAlbum> createState() => _AddAlbumState();
}

class _AddAlbumState extends State<AddAlbum> {
  final albumService = get<AlbumService>();

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
          onPressed: context.popRoute,
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
                    await Album.insert(
                      AlbumCompanion.insert(name: albumNameController.text),
                    );
                    await albumService.updateAlbumList();
                    if (context.mounted) context.popRoute();
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
