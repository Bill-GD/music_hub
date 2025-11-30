import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';

class ErroredWidget extends StatelessWidget {
  final FlutterErrorDetails e;

  const ErroredWidget({super.key, required this.e});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return SafeArea(
          child: Container(
            color: context.colorScheme.surfaceContainer,
            child: Stack(
              children: [
                Padding(
                  padding: const .only(left: 32, right: 32, top: 64),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const .only(bottom: 8),
                          child: Text(
                            '${e.exception}',
                            style: const TextStyle(
                              fontSize: FontSize.medium,
                              decoration: .none,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: Padding(
                            padding: const .all(16),
                            child: Text(
                              e.stack.toString(),
                              style: const TextStyle(
                                fontSize: FontSize.small,
                                decoration: .none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(left: 8, top: 8, child: BackButton()),
              ],
            ),
          ),
        );
      },
    );
  }
}
