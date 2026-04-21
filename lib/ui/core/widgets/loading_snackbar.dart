import 'package:flutter/material.dart';

class LoadingSnackbar extends SnackBar {
  final ValueNotifier<String> messageListenable;

  LoadingSnackbar(this.messageListenable, {super.key})
    : super(
        content: ValueListenableBuilder(
          valueListenable: messageListenable,
          builder: (_, value, _) => Text(value),
        ),
        behavior: .floating,
        margin: const .only(bottom: 10, left: 15, right: 15),
        shape: RoundedRectangleBorder(borderRadius: .circular(15)),
        persist: true,
      );
}
