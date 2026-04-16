import 'package:flutter/material.dart';

import 'package:music_hub/ui/app/downloader/downloader_view_model.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/button.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/ui/core/widgets/input.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals.dart';

class MusicDownloaderScreen extends StatefulWidget {
  final DownloaderViewModel viewModel;

  const MusicDownloaderScreen({super.key, required this.viewModel});

  @override
  State<MusicDownloaderScreen> createState() => MusicDownloaderScreenState();
}

class MusicDownloaderScreenState extends State<MusicDownloaderScreen> {
  late final vm = widget.viewModel;

  void popCallback() {
    if (vm.downloading) {
      return context.showToast('App is downloading music, please wait');
    }
  }

  @override
  void dispose() {
    vm.urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return SafeArea(
          child: PopScope(
            canPop: !vm.downloading,
            onPopInvokedWithResult: (_, _) {
              popCallback();
            },
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () {
                    popCallback();
                    if (!vm.downloading) Navigator.pop(context);
                  },
                ),
                centerTitle: true,
                title: const Text(
                  'Music Downloader',
                  style: TextStyle(fontWeight: .w700),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.help_rounded),
                    onPressed: () {
                      context.showPopupMessage(
                        title: 'Instruction',
                        content: '''
                          Enter YouTube or SoundCloud link into the text field.
                          Press the get data button.
                          Wait for the app to fetch the data.
                          Press the download button.
                          Wait for the app to download the music.''',
                      );
                    },
                  ),
                ],
              ),
              body: ValueListenableBuilder(
                valueListenable: Globals.isInternetConnected,
                builder: (context, connected, _) {
                  return Column(
                    children: [
                      AnimatedOpacity(
                        opacity: connected ? 0 : 1,
                        duration: 150.ms,
                        child: Container(
                          width: .infinity,
                          color: Colors.red,
                          padding: const .symmetric(vertical: 3),
                          child: const Text('No Internet connection', textAlign: .center),
                        ),
                      ),
                      Padding(
                        padding: const .all(12),
                        child: Column(
                          mainAxisAlignment: .start,
                          spacing: 8,
                          children: [
                            Input(
                              controller: vm.urlController,
                              readOnly: !connected,
                              labelText: 'Music Link',
                              hintText: 'Enter YouTube or SoundCloud link',
                              errorText: vm.errorText,
                              maxLines: 1,
                              textInputAction: .done,
                              suffixIcon: vm.fetchingData
                                  ? Container(
                                      width: 20,
                                      height: 20,
                                      margin: const .only(right: 20),
                                      alignment: .center,
                                      child: const CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : null,
                              onChanged: vm.validateInput,
                            ),
                            Button(
                              text: 'Get song data',
                              disabled: !vm.canFetchData || !connected,
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                vm.getData();
                              },
                            ),
                            if (vm.song != null) ...[
                              // song info
                              Container(
                                decoration: BoxDecoration(
                                  border: .all(color: context.colorScheme.outline),
                                  borderRadius: .circular(8),
                                ),
                                padding: const .all(12),
                                child: Row(
                                  mainAxisAlignment: .spaceEvenly,
                                  spacing: 12,
                                  children: [
                                    Container(
                                      decoration: vm.song!.thumbnailUrl == null
                                          ? BoxDecoration(
                                              border: .all(
                                                color: context.colorScheme.onSurface,
                                              ),
                                              borderRadius: .circular(10),
                                            )
                                          : null,
                                      child: vm.song!.thumbnailUrl == null
                                          ? Icon(
                                              Icons.music_note_rounded,
                                              color: context.colorScheme.primary,
                                            )
                                          : Image.network(
                                              vm.song!.thumbnailUrl!,
                                              fit: .fitHeight,
                                            ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        mainAxisAlignment: .spaceAround,
                                        children: [
                                          Text(
                                            vm.song!.title,
                                            style: const TextStyle(
                                              fontWeight: .w600,
                                              fontSize: FontSize.small,
                                            ),
                                          ),
                                          Text(vm.song!.author),
                                          Text(
                                            vm.song!.duration.toStringNoMilliseconds(),
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Button(
                                text: 'Download Music',
                                disabled: vm.downloading,
                                onPressed: vm.downloadSong,
                              ),
                            ],
                            if (vm.downloading)
                              Column(
                                children: [
                                  Row(
                                    spacing: 16,
                                    children: [
                                      Text(
                                        '${vm.percentageString}\n'
                                        '(${vm.receivedSize} / ${vm.totalSize})',
                                        style: TextStyle(fontWeight: .w600),
                                        textAlign: .end,
                                      ),
                                      Expanded(
                                        child: TweenAnimationBuilder<double>(
                                          duration: 300.ms,
                                          curve: Curves.easeOut,
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: vm.percentage,
                                          ),
                                          builder: (context, value, child) => ClipRRect(
                                            borderRadius: .circular(30),
                                            child: LinearProgressIndicator(
                                              value: value,
                                              minHeight: 6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Button(
                                    text: 'Cancel download',
                                    disabled: vm.downloading,
                                    onPressed: vm.cancelDownload,
                                  ),
                                ],
                              )
                            else if (vm.downloaded)
                              Text('Finished downloading', textAlign: .center),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
