import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/models/album.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/file_picker.dart';
import 'package:music_hub/ui/core/widgets/input.dart';
import 'package:music_hub/utils/extensions.dart' show DateString;

class AlbumInfo extends StatefulWidget {
  final int albumID;

  const AlbumInfo({super.key, required this.albumID});

  @override
  State<AlbumInfo> createState() => _AlbumInfoState();
}

class _AlbumInfoState extends State<AlbumInfo> {
  final songService = GetIt.I<SongService>(), playerService = GetIt.I<PlayerService>();
  late final TextEditingController albumController;
  late final Album album;
  String errorText = '', imagePath = '';
  bool hasChanges = false, hasCover = false;

  @override
  void initState() {
    super.initState();
    album = songService.albums.firstWhere((e) => e.id == widget.albumID);
    albumController = TextEditingController(text: album.name);
    imagePath = album.imagePath;
    hasCover = File(imagePath).existsSync();
  }

  @override
  void dispose() {
    super.dispose();
    albumController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 40),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Edit album info', style: TextStyle(fontWeight: .w700)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded, size: 30),
              onPressed: hasChanges
                  ? () async {
                      FocusManager.instance.primaryFocus?.unfocus();

                      album.name = albumController.text.trim();
                      playerService.playlistName = album.name;
                      album.imagePath = imagePath;
                      await album.update();

                      if (context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    }
                  : null,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const .symmetric(horizontal: 30),
                child: Container(
                  margin: const .symmetric(vertical: 10),
                  child: Input(
                    controller: albumController,
                    readOnly: album.name == 'Unknown',
                    onChanged: (val) {
                      if (![album.name, 'Unknown'].contains(val.trim()) && //
                          val.trim().isNotEmpty) {
                        hasChanges = true;
                        errorText = '';
                      } else {
                        hasChanges = false;
                        errorText = 'Name is invalid';
                      }
                      setState(() {});
                    },
                    labelText: 'Name',
                    errorText: errorText.isNotEmpty ? errorText : null,
                    suffixIcon: widget.albumID == 1
                        ? null
                        : const Padding(
                            padding: .only(right: 12),
                            child: Icon(Icons.edit_rounded),
                          ),
                  ),
                ),
              ),
              Container(
                margin: const .only(top: 30, bottom: 20),
                child: const Text(
                  'Other Information',
                  style: TextStyle(fontSize: 22, fontWeight: .w700),
                ),
              ),
              Padding(
                padding: const .only(left: 30, right: 15),
                child: Row(
                  children: [
                    context.leadingText('ID'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: album.id.toString(),
                        border: .none,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const .only(left: 30, right: 15),
                child: Row(
                  children: [
                    context.leadingText('Song count'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: album.songs.length.toString(),
                        border: .none,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const .only(left: 30, right: 15),
                child: Row(
                  children: [
                    context.leadingText('Time Added'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: album.timeAdded.toDateString(),
                        border: .none,
                      ),
                    ),
                  ],
                ),
              ),
              // cover image
              Container(
                margin: const .only(top: 30, bottom: 20),
                child: const Text(
                  'Cover image',
                  style: TextStyle(fontSize: 22, fontWeight: .w700),
                ),
              ),
              Padding(
                padding: const .only(bottom: 32),
                child: GestureDetector(
                  onTap: () async {
                    final path = await FilePicker.image(
                      context: context,
                      rootDirectory: Directory('/storage/emulated/0'),
                    );
                    if (path == null) return;
                    imagePath = path;
                    hasChanges = imagePath != album.imagePath;
                    setState(() => hasCover = true);
                  },
                  child: Stack(
                    children: [
                      Container(
                        constraints: .tight(const Size(320, 320)),
                        decoration: !hasCover
                            ? BoxDecoration(
                                borderRadius: .circular(10),
                                border: .all(
                                  width: 1,
                                  color: context.theme.colorScheme.onSurface,
                                ),
                              )
                            : null,
                        child: hasCover
                            ? ClipRRect(
                                borderRadius: .circular(20),
                                child: Image.file(File(imagePath), fit: .cover),
                              )
                            : Column(
                                mainAxisAlignment: .center,
                                mainAxisSize: .min,
                                children: [
                                  const Icon(Icons.image_not_supported_rounded, size: 80),
                                  Text(
                                    imagePath.isNotEmpty
                                        ? 'Image not found\nTap to relocate or change'
                                        : 'No cover image\nTap to change',
                                    textAlign: .center,
                                  ),
                                ],
                              ),
                      ),
                      if (hasCover)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded),
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.2),
                              ),
                            ),
                            onPressed: () {
                              imagePath = '';
                              hasChanges = imagePath != album.imagePath;
                              setState(() => hasCover = false);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
