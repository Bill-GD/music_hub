import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/hold_gesture.dart';
import 'package:music_hub/utils/extensions.dart' show LyricTimestamp, PadInt;

class TimestampEditor extends StatefulWidget {
  final (int, int, int) timestamp;

  const TimestampEditor({super.key, required this.timestamp});

  @override
  State<TimestampEditor> createState() => _TimestampEditorState();
}

class _TimestampEditorState extends State<TimestampEditor> {
  late List<int> edit = [widget.timestamp.$1, widget.timestamp.$2, widget.timestamp.$3];

  void upTime(int index) {
    switch (index) {
      case 0:
        edit[0] = (edit[0] + 1) % 60;
        break;
      case 1:
        if (edit[1] >= 59) upTime(0);
        edit[1] = (edit[1] + 1) % 60;
        break;
      case 2:
        if (edit[2] >= 900) upTime(1);
        edit[2] = (edit[2] + 100) % 1000;
        break;
    }
  }

  void downTime(int index) {
    switch (index) {
      case 0:
        edit[0] = (edit[0] - 1) % 60;
        break;
      case 1:
        if (edit[1] <= 0) downTime(0);
        edit[1] = (edit[1] - 1) % 60;
        break;
      case 2:
        if (edit[2] <= 99) downTime(1);
        edit[2] = (edit[2] - 100) % 1000;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit timestamp', textAlign: .center, overflow: .ellipsis),
      titleTextStyle: context.theme.textTheme.titleLarge?.copyWith(
        fontSize: 24,
        fontWeight: .w700,
      ),
      content: Column(
        mainAxisSize: .min,
        children: [
          const Text('Current: '),
          Text(
            Duration(
              minutes: widget.timestamp.$1,
              seconds: widget.timestamp.$2,
              milliseconds: widget.timestamp.$3,
            ).toLyricTimestamp(),
            style: const TextStyle(fontWeight: .bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: .center,
            mainAxisSize: .min,
            children: [
              Column(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  HoldingGesture(
                    callback: () {
                      upTime(0);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_up_rounded, size: 40),
                  ),
                  Padding(
                    padding: const .symmetric(vertical: 24, horizontal: 32),
                    child: Text(edit[0].padIntLeft(2, '0')),
                  ),
                  HoldingGesture(
                    callback: () {
                      downTime(0);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_down_rounded, size: 40),
                  ),
                ],
              ),
              const Text(':'),
              Column(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  HoldingGesture(
                    callback: () {
                      upTime(1);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_up_rounded, size: 40),
                  ),
                  Padding(
                    padding: const .symmetric(vertical: 24, horizontal: 32),
                    child: Text(edit[1].padIntLeft(2, '0')),
                  ),
                  HoldingGesture(
                    callback: () {
                      downTime(1);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_down_rounded, size: 40),
                  ),
                ],
              ),
              const Text('.'),
              Column(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  HoldingGesture(
                    callback: () {
                      upTime(2);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_up_rounded, size: 40),
                  ),
                  Padding(
                    padding: const .symmetric(vertical: 24, horizontal: 32),
                    child: Text((edit[2] ~/ 10).padIntLeft(2, '0')),
                  ),
                  HoldingGesture(
                    callback: () {
                      downTime(2);
                      setState(() {});
                    },
                    child: const Icon(Icons.arrow_drop_down_rounded, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      contentTextStyle: context.theme.textTheme.bodyMedium?.copyWith(fontSize: 18),
      contentPadding: const .only(left: 20, right: 20, top: 15),
      actionsAlignment: .spaceEvenly,
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            GetIt.I<LogService>().log('Edited timestamp: ${widget.timestamp} -> $edit');
            Navigator.of(context).pop(edit);
          },
        ),
      ],
      actionsPadding: const .symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: const .all(.circular(10)),
        side: BorderSide(color: context.colorScheme.onSurface),
      ),
      insetPadding: const .only(top: 40, bottom: 16),
    );
  }
}
