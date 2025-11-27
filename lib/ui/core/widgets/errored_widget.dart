import 'package:flutter/material.dart';

import 'package:music_hub/data/services/log_service.dart';

class ErroredWidget extends StatelessWidget {
  final FlutterErrorDetails e;

  const ErroredWidget({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    LogService.log(e.exception.toString(), LogLevel.error);

    return Container(
      // color: context.colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Internal UI Error'),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('${e.exception}', style: const TextStyle(fontSize: 24)),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(e.stack.toString(), style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
