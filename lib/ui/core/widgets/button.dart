import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';

class Button extends StatelessWidget {
  final bool outline;
  final String? tooltip;
  final void Function()? onPressed;
  final bool disabled;
  final String text;

  const Button({
    super.key,
    this.outline = false,
    this.tooltip,
    this.onPressed,
    this.disabled = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    Color bgColor = outline ? Colors.transparent : colorScheme.primaryContainer;
    Color? outlineColor = outline ? colorScheme.primaryContainer : null;

    final colors = {'bg': bgColor, 'outline': ?outlineColor};

    final textWidget = Text(
      text,
      style: TextStyle(
        color: colors['text'],
        fontSize: FontSize.small,
        fontWeight: .w600,
      ),
    );
    final shape = WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: .circular(8),
        side: outline && colors['outline'] != null
            ? BorderSide(color: colors['outline']!)
            : .none,
      ),
    );
    final callback = disabled
        ? null
        : () {
            onPressed?.call();
          };

    final button = outline
        ? TextButton(
            onPressed: callback,
            style: ButtonStyle(elevation: const WidgetStatePropertyAll(0), shape: shape),
            child: Padding(padding: const .symmetric(horizontal: 16), child: textWidget),
          )
        : ElevatedButton(
            onPressed: callback,
            style: ButtonStyle(
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                return colors['bg']!.withValues(
                  alpha: states.contains(WidgetState.disabled) ? 0.5 : 1,
                );
              }),
              shape: shape,
            ),
            child: textWidget,
          );

    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
