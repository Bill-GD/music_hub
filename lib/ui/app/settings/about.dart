import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/settings/version_list.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart' show Constants;
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber;
import 'package:music_hub/utils/globals.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final logService = GetIt.I<LogService>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('About', style: TextStyle(fontWeight: .w700)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Visibility(
              visible: !Globals.isInternetConnected.value,
              child: Container(
                width: double.infinity,
                color: Colors.red,
                padding: const .symmetric(vertical: 3),
                child: const Text('No Internet Connection', textAlign: .center),
              ),
            ),
            Flexible(
              child: ListView(
                children: [
                  ListTile(
                    title: context.leadingText('Current version', false, 16),
                    subtitle: Text(Constants.appVersion),
                  ),
                  ListTile(
                    title: context.leadingText('Version list', false, 16),
                    subtitle: const Text('View the list of versions of this app'),
                    onTap: () {
                      if (!Globals.isInternetConnected.value) return;

                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: 300.ms,
                          barrierDismissible: true,
                          barrierLabel: '',
                          transitionsBuilder: (_, anim1, _, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1, 0),
                                end: const Offset(0, 0),
                              ).animate(anim1),
                              child: child,
                            );
                          },
                          pageBuilder: (context, _, _) {
                            return const VersionList();
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: context.leadingText('Licenses', false, 16),
                    subtitle: const Text('View open-source licenses'),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: Constants.appName,
                        applicationVersion:
                            'v${Constants.appVersion}${Constants.isDev ? '' : ' - stable'}',
                      );
                    },
                  ),
                  ListTile(
                    title: context.leadingText('Get releases', false, 16),
                    subtitle: const Text('Get the releases of this app'),
                    onTap: () async {
                      final uri = Uri.parse(
                        'https://github.com/Bill-GD/music_hub/releases',
                      );
                      final canLaunch = await canLaunchUrl(uri);
                      launchUrl(uri);
                      if (canLaunch) {
                        logService.log('The system has found a handler, can launch URL');
                      } else if (context.mounted) {
                        logService.log(
                          'URL launcher support query is not specified or can\'t launch URL, but opening regardless',
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: context.leadingText('GitHub Repo', false, 16),
                    subtitle: const Text('Open GitHub repository of this app'),
                    onTap: () async {
                      final uri = Uri.parse('https://github.com/Bill-GD/music_hub');
                      final canLaunch = await canLaunchUrl(uri);
                      launchUrl(uri);
                      if (canLaunch) {
                        logService.log('The system has found a handler, can launch URL');
                      } else if (context.mounted) {
                        logService.log(
                          'URL launcher support query is not specified or can\'t launch URL, but opening regardless',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
