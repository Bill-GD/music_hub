import 'package:flutter/material.dart';

import 'package:theme_provider/theme_provider.dart';

extension ThemeWithContext on BuildContext {
  bool get isDarkMode => ThemeProvider.themeOf(this).id.contains('dark');

  void nextTheme() => ThemeProvider.controllerOf(this).nextTheme();

  ThemeData get theme => Theme.of(this);
}
