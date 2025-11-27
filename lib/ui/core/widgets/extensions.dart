import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/globals/globals.dart';
import 'package:music_hub/utils/globals/music_track.dart';
import 'package:music_hub/utils/globals/utils.dart';

extension WidgetWithContext on BuildContext {
  void showToast(String msg) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: .floating,
          margin: const .only(bottom: 10, left: 15, right: 15),
          shape: RoundedRectangleBorder(borderRadius: .circular(15)),
          showCloseIcon: true,
          persist: false,
        ),
      );
  }

  Future<void> showLogPopup({required String title}) async {
    final logLines = File(Globals.logPath).readAsLinesSync();
    final contentLines = <String>[];

    for (final line in logLines) {
      if (line.isEmpty || !line.contains(']')) continue;

      final isError = line.contains('[E]'), isWarn = line.contains('[W]');
      final time = line.substring(0, line.indexOf(']') + 1).trim();
      final content = line.substring(line.indexOf(']') + 5).trim();
      // final content = line;
      contentLines.add('t$time\n');
      contentLines.add(
        '${isError
            ? 'e'
            : isWarn
            ? 'w'
            : 'i'} - $content\n',
      );
      contentLines.add(' \n');
    }
    contentLines.removeLast();
    contentLines.last = contentLines.last.substring(0, contentLines.last.length - 1);

    final textSpans = <TextSpan>[];
    for (var line in contentLines) {
      final lineColor = switch (line[0]) {
        'e' => theme.colorScheme.error,
        'w' => Colors.amber[700],
        't' => theme.colorScheme.secondary,
        _ => theme.textTheme.bodyMedium?.color,
      };
      textSpans.add(
        TextSpan(
          text: line.substring(1),
          style: TextStyle(color: lineColor),
        ),
      );
    }

    await showActionDialog<void>(
      title: title,
      titleFontSize: 28,
      widgetContent: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
          children: textSpans,
        ),
      ),
      contentFontSize: 16,
      centerContent: false,
      time: 300.ms,
      actions: [TextButton(onPressed: Navigator.of(this).pop, child: const Text('OK'))],
    );
  }

  InputDecoration textFieldDecoration({
    Color? fillColor,
    String? hintText,
    String? labelText,
    String? errorText,
    InputBorder? border,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    BoxConstraints? constraints,
  }) => InputDecoration(
    filled: true,
    fillColor: fillColor,
    hintText: hintText,
    hintStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.5)),
    labelText: labelText,
    labelStyle: TextStyle(fontWeight: .w600, color: theme.colorScheme.primary),
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minHeight: 2, minWidth: 2),
    contentPadding: contentPadding ?? const .symmetric(horizontal: 20),
    border: border,
    constraints: constraints,
  );

  Color? iconColor([double opacity = 1]) {
    return theme.iconTheme.color?.withOpacity(opacity);
  }

  Text leadingText(String text, [bool bold = true, double size = 18]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: bold ? .bold : .normal,
      ),
    );
  }

  Future<void> showSongOptionsMenu({
    required int songID,
    required List<Widget> options,
  }) async {
    MusicTrack song = Globals.allSongs.firstWhere((e) => e.id == songID);
    await getBottomSheet(
      Text(song.name, style: bottomSheetTitle, textAlign: .center, softWrap: true),
      options,
    );
  }

  Future<void> getBottomSheet(Widget title, List<Widget> content) async {
    await showCupertinoModalPopup(
      context: this,
      builder: (context) => Material(
        color: theme.colorScheme.surface,
        borderRadius: .circular(30),
        child: Container(
          constraints: .loose(.fromWidth(MediaQuery.of(context).size.width * 0.9)),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: theme.colorScheme.onSurface),
            borderRadius: .circular(30),
          ),
          child: Padding(
            padding: const .only(left: 10, right: 10, top: 30),
            child: Column(
              mainAxisSize: .min,
              children: [
                Padding(padding: const .symmetric(horizontal: 20), child: title),
                Padding(
                  padding: const .symmetric(vertical: 15),
                  child: Column(mainAxisSize: .min, children: content),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showErrorPopup(String error) async {
    await showActionDialog<void>(
      barrierDismissible: true,
      time: 300.ms,
      icon: Icon(Icons.error_rounded, color: theme.colorScheme.error, size: 30),
      title: 'Error',
      titleFontSize: 24,
      textContent: dedent('''
            An error occurred while performing the operation.
            Error: $error'''),
      contentFontSize: 16,
      actions: [
        TextButton(child: const Text('OK'), onPressed: () => Navigator.of(this).pop()),
      ],
    );
  }

  Future<void> showPopupMessage({
    Icon? icon,
    required String title,
    required String content,
    Duration time = const Duration(milliseconds: 200),
    bool centerContent = true,
    bool enableButton = true,
    bool barrierDismissible = true,
  }) async {
    await showActionDialog<void>(
      icon: icon,
      title: title,
      titleFontSize: 24,
      textContent: content,
      contentFontSize: 16,
      centerContent: centerContent,
      time: time,
      actions: [
        TextButton(
          onPressed: enableButton ? () => Navigator.of(this).pop() : null,
          child: const Text('OK'),
        ),
      ],
      barrierDismissible: barrierDismissible,
    );
  }

  Future<T?> showActionDialog<T>({
    Icon? icon,
    required String title,
    required double titleFontSize,
    String? textContent,
    Widget? widgetContent,
    required double contentFontSize,
    bool centerContent = true,
    List<Widget> actions = const [],
    required Duration time,
    Alignment scaleAlignment = .center,
    bool barrierDismissible = true,
  }) async {
    assert(
      textContent != null || widgetContent != null,
      'textContent or widgetContent parameter must be non-null',
    );

    final content = textContent != null
        ? Text(dedent(textContent), textAlign: centerContent ? .center : null)
        : widgetContent!;

    return await showGeneralDialog<T>(
      context: this,
      transitionDuration: time,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      transitionBuilder: (_, anim1, _, child) {
        return ScaleTransition(
          scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
          alignment: scaleAlignment,
          child: child,
        );
      },
      pageBuilder: (_, _, _) {
        return SafeArea(
          child: AlertDialog(
            icon: icon,
            scrollable: true,
            title: Text(title, textAlign: .center),
            titleTextStyle: Theme.of(
              this,
            ).textTheme.titleLarge?.copyWith(fontSize: titleFontSize, fontWeight: .w700),
            content: content,
            contentTextStyle: Theme.of(
              this,
            ).textTheme.bodyMedium?.copyWith(fontSize: contentFontSize),
            contentPadding: const .symmetric(horizontal: 20, vertical: 15),
            actionsAlignment: .spaceEvenly,
            actions: actions,
            actionsPadding: const .symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: const .all(.circular(10)),
              side: BorderSide(color: theme.colorScheme.onSurface),
            ),
            insetPadding: const .all(24),
          ),
        );
      },
    );
  }
}
