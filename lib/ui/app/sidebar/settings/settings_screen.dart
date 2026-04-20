import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:music_hub/ui/app/sidebar/settings/about.dart';
import 'package:music_hub/ui/app/sidebar/settings/backup.dart';
import 'package:music_hub/ui/app/sidebar/settings/settings_view_model.dart';
import 'package:music_hub/ui/app/sidebar/settings/theme_setting.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsScreen({super.key, required this.viewModel});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsViewModel get vm => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: context.popRoute,
              ),
              title: const Text('Settings', style: TextStyle(fontWeight: .w700)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.save_rounded),
                  onPressed: vm.hasChanges
                      ? () async {
                          FocusManager.instance.primaryFocus?.unfocus();

                          await context.showActionDialog<bool>(
                            title: 'Confirm changes',
                            titleFontSize: 24,
                            textContent:
                                'Confirm the following changes?\n\n'
                                '${vm.getChanges().join('\n')}',
                            contentFontSize: 16,
                            time: 300.ms,
                            actions: [
                              TextButton(
                                onPressed: () => context.popRoute(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await vm.updateConfig();
                                  if (context.mounted) context.popRoute(true);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        }
                      : null,
                ),
              ],
            ),
            body: ListView(
              padding: const .only(bottom: 24, left: 16, right: 16),
              children: [
                _Section(
                  title: 'APP SETTINGS',
                  tiles: [
                    _Switch(
                      title: 'Backup data on launch',
                      subtitle:
                          'Backup data on app launch. May be undesirable in certain situations.',
                      value: vm.backupOnLaunch,
                      onChanged: (value) => vm.backupOnLaunch = value,
                    ),
                    _Route(
                      title: 'Theme',
                      subtitle: 'Customize the app\'s theme',
                      routeBuilder: () => PageRouteBuilder(
                        pageBuilder: (_, _, _) => const ThemeSetting(),
                        transitionsBuilder: (context, anim, _, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: const Offset(0, 0),
                            ).animate(anim.drive(CurveTween(curve: Curves.decelerate))),
                            child: child,
                          );
                        },
                      ),
                    ),
                    _Route(
                      title: 'Backup',
                      subtitle: 'Save and restore app data',
                      routeBuilder: () => PageRouteBuilder(
                        pageBuilder: (_, _, _) => const BackupScreen(),
                        transitionsBuilder: (_, anim1, _, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: const Offset(0, 0),
                            ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
                            child: child,
                          );
                        },
                      ),
                    ),
                    _Slider(
                      title: 'Backup count',
                      subtitle: 'Number of backups to keep: ${vm.backupCount}',
                      sliderLeft: '5',
                      slider: Slider(
                        value: vm.backupCount.toDouble(),
                        min: 5,
                        max: 15,
                        onChanged: (value) => vm.backupCount = value.toInt(),
                      ),
                      sliderRight: '15',
                    ),
                    _Route(
                      title: 'Version',
                      subtitle: Constants.appVersion,
                      routeBuilder: () => PageRouteBuilder(
                        pageBuilder: (_, _, _) => const AboutScreen(),
                        transitionsBuilder: (_, anim, _, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-1, 0),
                              end: const Offset(0, 0),
                            ).animate(anim.drive(CurveTween(curve: Curves.decelerate))),
                            child: child,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: 'FILE SETTINGS',
                  tiles: [
                    _Switch(
                      title: 'Song Filter',
                      subtitle: 'Ignore short files',
                      value: vm.enableSongFiltering,
                      onChanged: (value) => vm.enableSongFiltering = value,
                    ),
                    Visibility(
                      visible: vm.enableSongFiltering,
                      child: _Slider(
                        title: 'Time',
                        subtitle:
                            'Hide files shorter than ${vm.lengthLimitSeconds} seconds',
                        sliderLeft: '0 sec',
                        slider: Slider(
                          value: vm.lengthLimitSeconds.toDouble(),
                          min: 0,
                          max: 300,
                          onChanged: (value) => vm.lengthLimitSeconds = value.toInt(),
                          divisions: 30,
                        ),
                        sliderRight: '5 mins',
                      ),
                    ),
                  ],
                ),
                _Section(
                  title: 'PLAYER SETTINGS',
                  tiles: [
                    _Switch(
                      title: 'Auto play new song',
                      subtitle: 'Starts playing when choosing a new song',
                      value: vm.autoPlayNewSong,
                      onChanged: (value) => vm.autoPlayNewSong = value,
                    ),
                    _Slider(
                      title: 'Delay between songs',
                      subtitle:
                          'Short delay of ${vm.delayMilliseconds} ms when skipping song',
                      sliderLeft: '0',
                      slider: Slider(
                        value: vm.delayMilliseconds.toDouble(),
                        min: 0.0,
                        max: 500.0,
                        onChanged: (value) => vm.delayMilliseconds = value.toInt(),
                      ),
                      sliderRight: '500',
                    ),
                    _Switch(
                      title: 'Append lyric',
                      subtitle: 'Only add lines instead of free lyric editing',
                      value: vm.appendLyric,
                      onChanged: (value) => vm.appendLyric = value,
                    ),
                    _Slider(
                      title: 'Volume',
                      subtitle: 'Change the base volume (${(vm.volume * 100).toInt()}%)',
                      sliderLeft: '0%',
                      slider: Slider(
                        value: vm.volume,
                        min: 0,
                        max: 1,
                        onChanged: (value) => vm.volume = value,
                        divisions: 100,
                      ),
                      sliderRight: '100%',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _Section({required this.title, required this.tiles});

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: .min,
      mainAxisAlignment: .start,
      children: [
        Container(
          margin: const .symmetric(vertical: 12),
          alignment: .centerLeft,
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: .w700)),
        ),
        ...tiles,
      ],
    );
  }
}

class _Switch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _Switch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: context.leadingText(title, false, 16),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _Slider extends StatelessWidget {
  final String title;
  final String subtitle;
  final String sliderLeft;
  final Slider slider;
  final String sliderRight;

  const _Slider({
    required this.title,
    required this.subtitle,
    required this.sliderLeft,
    required this.slider,
    required this.sliderRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(title: context.leadingText(title, false, 16), subtitle: Text(subtitle)),
        Padding(
          padding: const .symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(sliderLeft),
              Expanded(child: slider),
              Text(sliderRight),
            ],
          ),
        ),
      ],
    );
  }
}

class _Route extends StatelessWidget {
  final String title;
  final String subtitle;
  final Route Function() routeBuilder;

  const _Route({required this.title, required this.subtitle, required this.routeBuilder});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: context.leadingText(title, false, 16),
      subtitle: Text(subtitle),
      trailing: const Icon(CupertinoIcons.right_chevron),
      onTap: () => context.pushRoute(routeBuilder()),
    );
  }
}
