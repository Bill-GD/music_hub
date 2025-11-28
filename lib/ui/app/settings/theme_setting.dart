import 'package:flutter/material.dart';

import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({super.key});

  @override
  State<ThemeSetting> createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Theme', style: TextStyle(fontWeight: .w700)),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            SwitchListTile(
              title: context.leadingText('Dark mode', false, 16),
              // subtitle: const Text('Backup data on app launch. May be undesirable in certain situations.'),
              value: context.isDarkMode,
              onChanged: (_) => context.nextTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
