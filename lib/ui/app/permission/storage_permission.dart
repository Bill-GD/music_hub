import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:music_hub/data/services/log_service.dart';

class StoragePermissionDialog extends StatelessWidget {
  const StoragePermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(10))),
      title: const Center(
        child: Text(
          'Storage Permission',
          style: TextStyle(fontSize: 24, fontWeight: .w700),
        ),
      ),
      content: const Text(
        'Allow Music Hub to access storage?\nMusic Hub will only access the Download folder.',
        textAlign: .center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: .spaceAround,
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            GetIt.I<LogService>().log('Storage permission denied, exiting app');
            SystemNavigator.pop();
          },
        ),
        TextButton(
          child: const Text('Yes'),
          onPressed: () {
            Permission.manageExternalStorage.request().then((status) async {
              if (status.isPermanentlyDenied) {
                GetIt.I<LogService>().log('Opening app settings to request permission');
                await openAppSettings();
              }
              if (status.isGranted && context.mounted) {
                Navigator.pop(context);
              }
            });
          },
        ),
      ],
    );
  }
}
