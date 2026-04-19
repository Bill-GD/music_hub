import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/player_service.dart';
import 'package:music_hub/ui/app/sidebar/settings/about.dart';
import 'package:music_hub/ui/app/sidebar/settings/backup.dart';
import 'package:music_hub/ui/app/sidebar/settings/theme_setting.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final configService = get<ConfigService>(),
      playerService = get<PlayerService>();
  bool hasChanges = false;

  late bool autoBackup = configService.backupOnLaunch;
  late bool ignoreShortFile = configService.enableSongFiltering;
  late int ignoreTimeLimit = configService.lengthLimitMilliseconds ~/ 1e3;
  late bool autoPlay = configService.autoPlayNewSong;
  late int delayBetween = configService.delayMilliseconds;
  late bool appendLyric = configService.appendLyric;
  late double volume = configService.volume;
  late int backupCount = configService.backupCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Settings', style: TextStyle(fontWeight: .w700)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: hasChanges
                  ? () async {
                      FocusManager.instance.primaryFocus?.unfocus();

                      String changes = 'Confirm the following changes?\n\n';

                      changes += ignoreShortFile != configService.enableSongFiltering
                          ? ignoreShortFile
                                ? 'Enable song filtering\n'
                                : 'Disable song filtering\n'
                          : '';

                      changes +=
                          ignoreShortFile &&
                              ignoreTimeLimit !=
                                  configService.lengthLimitMilliseconds ~/ 1e3
                          ? 'Filter file shorter than: $ignoreTimeLimit s\n'
                          : '';

                      changes += autoPlay != configService.autoPlayNewSong
                          ? autoPlay
                                ? 'Enable auto play\n'
                                : 'Disable auto play\n'
                          : '';

                      changes += appendLyric != configService.appendLyric
                          ? appendLyric
                                ? 'Enable append lyric\n'
                                : 'Disable append lyric\n'
                          : '';

                      changes += autoBackup != configService.backupOnLaunch
                          ? autoBackup
                                ? 'Enable auto backup\n'
                                : 'Disable auto backup\n'
                          : '';
                      changes += delayBetween != configService.delayMilliseconds
                          ? 'Delay between songs: $delayBetween ms\n'
                          : '';
                      changes += volume != configService.volume
                          ? 'Volume: x$volume\n'
                          : '';
                      changes += backupCount != configService.backupCount
                          ? 'Backup count: $backupCount\n'
                          : '';

                      if (changes.endsWith('\n')) {
                        changes = changes.substring(0, changes.length - 1);
                      }

                      if (hasChanges) {
                        final needsUpdate = await context.showActionDialog<bool>(
                          title: 'Confirm changes',
                          titleFontSize: 24,
                          textContent: changes,
                          contentFontSize: 16,
                          time: 300.ms,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () async {
                                configService.backupOnLaunch = autoBackup;
                                configService.enableSongFiltering = ignoreShortFile;
                                configService.lengthLimitMilliseconds =
                                    ignoreTimeLimit * 1000;
                                configService.autoPlayNewSong = autoPlay;
                                configService.delayMilliseconds = delayBetween;
                                configService.appendLyric = appendLyric;
                                configService.volume = volume;
                                playerService.setVolume(configService.volume);
                                configService.backupCount = backupCount;
                                await configService.saveConfig();
                                if (context.mounted) Navigator.of(context).pop(true);
                              },
                              child: const Text('Yes'),
                            ),
                          ],
                        );

                        if (needsUpdate == true) setState(() => hasChanges = false);
                      }
                    }
                  : null,
            ),
          ],
        ),
        body: ListView(
          padding: const .only(bottom: 24),
          children: [
            Container(
              margin: const .symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'APP SETTINGS',
                style: TextStyle(fontSize: 18, fontWeight: .w700),
              ),
            ),
            SwitchListTile(
              title: context.leadingText('Backup data on launch', false, 16),
              subtitle: const Text(
                'Backup data on app launch. May be undesirable in certain situations.',
              ),
              value: autoBackup,
              onChanged: (value) {
                hasChanges = value != configService.backupOnLaunch;
                setState(() => autoBackup = value);
              },
            ),
            ListTile(
              title: context.leadingText('Theme', false, 16),
              subtitle: const Text('Customize the app\'s theme'),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
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
                );
              },
            ),
            ListTile(
              title: context.leadingText('Backup', false, 16),
              subtitle: const Text('Save and restore app data'),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const BackupScreen(),
                    transitionsBuilder: (context, anim1, _, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: const Offset(0, 0),
                        ).animate(anim1.drive(CurveTween(curve: Curves.decelerate))),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            Column(
              children: [
                ListTile(
                  title: context.leadingText('Backup count', false, 16),
                  subtitle: Text('Number of backups to keep: $backupCount'),
                ),
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('5'),
                      Expanded(
                        child: Slider(
                          value: backupCount.toDouble(),
                          min: 5,
                          max: 15,
                          onChanged: (value) {
                            hasChanges = value.toInt() != configService.backupCount;
                            setState(() => backupCount = value.toInt());
                          },
                        ),
                      ),
                      const Text('15'),
                    ],
                  ),
                ),
              ],
            ),
            ListTile(
              title: context.leadingText('Version', false, 16),
              subtitle: Text(Constants.appVersion),
              trailing: const Icon(CupertinoIcons.right_chevron),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const AboutScreen(),
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
                );
              },
            ),
            Container(
              margin: const .symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'FILE SETTINGS',
                style: TextStyle(fontSize: 18, fontWeight: .w700),
              ),
            ),
            SwitchListTile(
              title: context.leadingText('Song Filter', false, 16),
              subtitle: const Text('Ignore short files'),
              value: ignoreShortFile,
              onChanged: (value) {
                hasChanges = value != configService.enableSongFiltering;
                setState(() => ignoreShortFile = value);
              },
            ),
            Visibility(
              visible: ignoreShortFile,
              child: Column(
                children: [
                  ListTile(
                    title: context.leadingText('Time', false, 16),
                    subtitle: Text('Hide files shorter than $ignoreTimeLimit seconds'),
                  ),
                  Padding(
                    padding: const .symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text('0 sec'),
                        Expanded(
                          child: Slider(
                            value: ignoreTimeLimit.toDouble(),
                            min: 0,
                            max: 300,
                            onChanged: (value) {
                              if (!ignoreShortFile) return;
                              hasChanges =
                                  value.toInt() !=
                                  configService.lengthLimitMilliseconds ~/ 1e3;
                              setState(() => ignoreTimeLimit = value.toInt());
                            },
                            divisions: 30,
                          ),
                        ),
                        const Text('5 mins'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const .symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                'PLAYER SETTINGS',
                style: TextStyle(fontSize: 18, fontWeight: .w700),
              ),
            ),
            SwitchListTile(
              title: context.leadingText('Auto play new song', false, 16),
              subtitle: const Text('Starts playing when choosing a new song'),
              value: autoPlay,
              onChanged: (value) {
                hasChanges = value != configService.autoPlayNewSong;
                setState(() => autoPlay = value);
              },
            ),
            Column(
              children: [
                ListTile(
                  title: context.leadingText('Delay between songs', false, 16),
                  subtitle: Text('Short delay of $delayBetween ms when skipping song'),
                ),
                Padding(
                  padding: const .symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('0'),
                      Expanded(
                        child: Slider(
                          value: delayBetween.toDouble(),
                          min: 0.0,
                          max: 500.0,
                          onChanged: (value) {
                            hasChanges = value.toInt() != configService.delayMilliseconds;
                            setState(() => delayBetween = value.toInt());
                          },
                        ),
                      ),
                      const Text('500'),
                    ],
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: context.leadingText('Append lyric', false, 16),
              subtitle: const Text('Only add lines instead of free lyric editing'),
              value: appendLyric,
              onChanged: (value) {
                hasChanges = value != configService.appendLyric;
                setState(() => appendLyric = value);
              },
            ),
            ListTile(
              title: context.leadingText('Volume', false, 16),
              subtitle: Text(
                'Change the player\'s base volume (${(volume * 100).toInt()}%)',
              ),
            ),
            Padding(
              padding: const .symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('0%'),
                  Expanded(
                    child: Slider(
                      value: volume,
                      min: 0,
                      max: 1,
                      onChanged: (value) {
                        hasChanges = value != configService.volume;
                        setState(() => volume = value);
                      },
                      divisions: 100,
                    ),
                  ),
                  const Text('100%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
