import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/data/services/song_service.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/file_picker.dart';
import 'package:music_hub/ui/core/widgets/input.dart';
import 'package:music_hub/utils/constants.dart' show Paths;
import 'package:music_hub/utils/extensions.dart' show DateString;

class SongInfo extends StatefulWidget {
  final int songID;

  const SongInfo({super.key, required this.songID});

  @override
  State<SongInfo> createState() => _SongInfoState();
}

class _SongInfoState extends State<SongInfo> {
  final songService = GetIt.I<SongService>(), playerService = GetIt.I<PlayerService>();

  final _songController = TextEditingController(),
      _artistController = TextEditingController();
  bool hasCover = false, hasChanges = false;

  late final song = songService.getSong(widget.songID)!;
  late String imagePath = song.imagePath;

  @override
  void initState() {
    super.initState();
    _songController.text = song.name;
    _artistController.text = song.artist;
    hasCover = File(imagePath).existsSync();
  }

  @override
  void dispose() {
    super.dispose();
    _songController.dispose();
    _artistController.dispose();
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
          title: const Text('Edit song info', style: TextStyle(fontWeight: .w700)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.check_rounded, size: 30),
              onPressed: hasChanges
                  ? () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      _songController.text = _songController.text.trim();
                      _artistController.text = _artistController.text.trim();

                      song.name = _songController.text.isEmpty
                          ? song.path.split('/').last.split('.mp3').first
                          : _songController.text;

                      song.artist = _artistController.text.isEmpty
                          ? 'Unknown' //
                          : _artistController.text;

                      song.imagePath = imagePath;

                      await song.update();
                      if (widget.songID == songService.currentSongID) {
                        playerService.updateNotificationInfo(songID: widget.songID);
                      }

                      // setState(() => hasChanges = false);
                      if (context.mounted) {
                        Navigator.of(context).pop(hasChanges);
                      }
                    }
                  : null,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // song name
              Padding(
                padding: const .symmetric(horizontal: 30),
                child: Container(
                  margin: const .symmetric(vertical: 10),
                  child: Input(
                    controller: _songController,
                    onChanged: (value) => setState(() => hasChanges = value != song.name),
                    labelText: 'Name',
                    suffixIcon: const Padding(
                      padding: .symmetric(horizontal: 12),
                      child: Icon(Icons.edit_rounded),
                    ),
                  ),
                ),
              ),
              // song artist
              Padding(
                padding: const .symmetric(horizontal: 30),
                child: Container(
                  margin: const .symmetric(vertical: 10),
                  child: Input(
                    controller: _artistController,
                    onChanged: (value) =>
                        setState(() => hasChanges = value != song.artist),
                    labelText: 'Artist',
                    suffixIcon: const Padding(
                      padding: .symmetric(horizontal: 12),
                      child: Icon(Icons.edit_rounded),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const .only(top: 30, bottom: 20),
                child: const Text(
                  'Other information',
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
                        initialValue: song.id.toString(),
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
                    context.leadingText('Time played'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: song.timeListened.toString(),
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
                    context.leadingText('Time added'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: song.timeAdded.toDateString(),
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
                    context.leadingText('Path'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: song.fullPath,
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
                    context.leadingText('Lyric'),
                    Expanded(
                      child: Input(
                        readOnly: true,
                        scrollPadding: const .only(right: 0),
                        initialValue: song.lyricPath.isNotEmpty
                            ? Paths.lyricPath + song.lyricPath
                            : 'No lyric',
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
                    hasChanges = imagePath != song.imagePath;
                    setState(() => hasCover = true);
                  },
                  child: Stack(
                    children: [
                      Container(
                        constraints: .tight(const Size(320, 320)),
                        decoration: !hasCover
                            ? BoxDecoration(
                                borderRadius: .circular(10),
                                border: Border.all(
                                  width: 1,
                                  color: context.colorScheme.onSurface,
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
                                        ? 'Image is missing\nTap to relocate or change'
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
                                context.colorScheme.surface.withValues(alpha: 0.2),
                              ),
                            ),
                            onPressed: () {
                              imagePath = '';
                              hasChanges = imagePath != song.imagePath;
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
