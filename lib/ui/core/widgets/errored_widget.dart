import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';

class ErroredWidget extends StatelessWidget {
  final FlutterErrorDetails e;

  const ErroredWidget({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.surfaceContainer,
      padding: const .all(32),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Internal UI Error'),
            Padding(
              padding: const .only(bottom: 8),
              child: Text('${e.exception}', style: const TextStyle(fontSize: 24)),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const .all(16),
                child: Text(e.stack.toString(), style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
