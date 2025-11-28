import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/backup_service.dart';
import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/extensions.dart' show DateString, DurationFromNumber;

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final backupService = GetIt.I<BackupService>(),
      configService = GetIt.I<ConfigService>();
  List<FileSystemEntity> backupFiles = [];

  void updateBackupList() {
    backupFiles = backupService.getBackups();
  }

  @override
  void initState() {
    super.initState();
    updateBackupList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Backup'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_left_rounded, size: 40),
            onPressed: Navigator.of(context).pop,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const .only(bottom: 16),
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final res = await context.showActionDialog<bool>(
                        title: 'Backup data',
                        titleFontSize: 24,
                        textContent:
                            'Do you want to back up the current data? '
                            'This will overwrite the backed up data.\n'
                            'Is disabled if app is just re-installed.',
                        contentFontSize: 16,
                        time: 300.ms,
                        barrierDismissible: false,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                      if (res != true) return;
                      await backupService.backupData();
                      if (context.mounted) {
                        context.showToast('Data backed up successfully');
                      }
                      updateBackupList();
                      setState(() {});
                    },
                    child: const Text('Backup data'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (backupService.getBackups().isEmpty) {
                        GetIt.I<LogService>().log('No backup data found');
                        context.showToast('No backup data found');
                        return;
                      }

                      final res = await context.showActionDialog<bool>(
                        title: 'Overwrite data',
                        titleFontSize: 24,
                        textContent:
                            'Do you want to recover data from backup? '
                            'This will overwrite current data '
                            'and you\'d want to refresh the songs.',
                        contentFontSize: 16,
                        time: 300.ms,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                      if (res != true) return;
                      await backupService.recoverBackup(backupFiles.first as File);
                      if (context.mounted) {
                        context.showToast('Data recovered successfully');
                      }
                      updateBackupList();
                      setState(() {});
                    },
                    child: const Text('Recover backup'),
                  ),
                ],
              ),
            ),
            if (backupFiles.isEmpty)
              const Expanded(
                child: Column(
                  mainAxisAlignment: .center,
                  mainAxisSize: .min,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 40),
                    Text('No backup found', style: TextStyle(fontSize: 18)),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  itemCount: backupFiles.length,
                  itemBuilder: (context, index) {
                    FileStat stat = backupFiles[index].statSync();
                    return ListTile(
                      leading: Text(
                        '${index + 1}/${configService.backupCount}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      title: Text(
                        'Backup ${stat.modified.toDateString()}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        '${stat.size} B',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      contentPadding: const .only(left: 18, right: 4),
                      trailing: Row(
                        mainAxisAlignment: .end,
                        mainAxisSize: .min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restore_rounded),
                            onPressed: () async {
                              final res = await context.showActionDialog<bool>(
                                title: 'Overwrite data',
                                titleFontSize: 18,
                                textContent:
                                    'Do you want to recover data from backup ${index + 1}? '
                                    'This will overwrite current data '
                                    'and you\'d want to refresh the songs.',
                                contentFontSize: 14,
                                time: 300.ms,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                              if (res != true) return;
                              await backupService.recoverBackup(
                                backupFiles[index] as File,
                              );
                              if (context.mounted) {
                                context.showToast('Data recovered successfully');
                              }
                              updateBackupList();
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_forever_rounded),
                            onPressed: () async {
                              final res = await context.showActionDialog<bool>(
                                title: 'Delete backup',
                                titleFontSize: 18,
                                textContent:
                                    'Are you sure you want to remove this backup?',
                                contentFontSize: 14,
                                time: 300.ms,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                              if (res != true) return;
                              backupFiles[index].deleteSync();
                              updateBackupList();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
