import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:music_hub/ui/app/music_downloader/music_downloader.dart';
import 'package:music_hub/ui/app/settings/setting.dart';
import 'package:music_hub/ui/core/theme/font_size.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Constants;

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: .horizontal(right: const .circular(30)),
      ),
      child: Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        mainAxisSize: .min,
        children: [
          Expanded(
            child: Padding(
              padding: const .symmetric(horizontal: 10),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const .only(left: 15, bottom: 10, top: 5),
                    title: Text(
                      Constants.appName,
                      style: TextStyle(fontSize: FontSize.medium),
                    ),
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                    leading: FaIcon(FontAwesomeIcons.gear, color: context.iconColor()),
                    title: const Text(
                      'Settings',
                      style: TextStyle(fontSize: FontSize.mediumSmall),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) {
                            return const SettingsScreen();
                          },
                          transitionsBuilder: (context, anim1, _, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(-1, 0),
                                    end: const Offset(0, 0),
                                  ).animate(
                                    anim1.drive(CurveTween(curve: Curves.decelerate)),
                                  ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _listItemDivider(),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                    leading: Icon(Icons.download_rounded, color: context.iconColor()),
                    title: const Text(
                      'Download Music',
                      style: TextStyle(fontSize: FontSize.mediumSmall),
                    ),
                    onTap: () {
                      Navigator.of(context).push<bool>(
                        PageRouteBuilder(
                          pageBuilder: (_, _, _) {
                            return const MusicDownloader();
                          },
                          transitionsBuilder: (context, anim1, _, child) {
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(-1, 0),
                                    end: const Offset(0, 0),
                                  ).animate(
                                    anim1.drive(CurveTween(curve: Curves.decelerate)),
                                  ),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _listItemDivider(),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: .circular(30)),
                    leading: FaIcon(Icons.logo_dev, color: context.iconColor()),
                    title: const Text(
                      'Log',
                      style: TextStyle(fontSize: FontSize.mediumSmall),
                    ),
                    onTap: () {
                      context.showLogPopup('Application log');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Divider _listItemDivider() => const Divider(indent: 20, endIndent: 20);
