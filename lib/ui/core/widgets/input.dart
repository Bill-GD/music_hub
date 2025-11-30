import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';

class Input extends StatelessWidget {
  final TextEditingController? controller;
  final bool autofocus;
  final bool? readOnly;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextStyle? style;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final TextStyle? labelStyle;
  final InputBorder border;
  final BoxConstraints? constraints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? scrollPadding;
  final String? initialValue;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function()? onTap;

  const Input({
    super.key,
    this.controller,
    this.autofocus = false,
    this.readOnly,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.textAlign,
    this.textAlignVertical,
    this.style,
    this.labelText,
    this.hintText,
    this.errorText,
    this.labelStyle,
    this.border = const OutlineInputBorder(borderRadius: .all(.circular(8))),
    this.constraints,
    this.prefixIcon,
    this.suffixIcon,
    this.scrollPadding,
    this.initialValue,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly ?? false,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization ?? .none,
      textAlign: textAlign ?? .start,
      textAlignVertical: textAlignVertical,
      style: style ?? const TextStyle(fontSize: FontSize.small),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
        errorText: errorText,
        labelStyle:
            labelStyle ??
            TextStyle(fontWeight: .w600, color: context.theme.colorScheme.primary),
        border: border,
        constraints: constraints,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixIconConstraints: const BoxConstraints(minHeight: 2, minWidth: 2),
        contentPadding: const .symmetric(horizontal: 10),
      ),
      scrollPadding: scrollPadding ?? const .all(20),
      initialValue: initialValue,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onTap: onTap,
    );
  }
}
