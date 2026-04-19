import 'package:flutter/material.dart';

import 'package:music_hub/data/services/github_service.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/app/sidebar/settings/version_dialog.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class VersionList extends StatefulWidget {
  const VersionList({super.key});

  @override
  State<VersionList> createState() => _VersionListState();
}

class _VersionListState extends State<VersionList> {
  final logService = get<LogService>(), githubService = get<GithubService>();
  List<String> tags = [], shas = [];
  int versionCount = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    githubService.getAllTags().then((value) {
      value = value.reversed.toList();
      tags = value.map((e) => e.$1).toList();
      shas = value.map((e) => e.$2).toList();
      versionCount = tags.length;
      if (context.mounted) {
        logService.log('Got $versionCount tags');
        setState(() => loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.popRoute(),
        ),
        title: const Text(
          'Version list',
          style: TextStyle(fontWeight: .w700),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final res = (await githubService.getAllTags()).reversed.toList();
          tags = res.map((e) => e.$1).toList();
          shas = res.map((e) => e.$2).toList();
          versionCount = tags.length;
          if (context.mounted) {
            logService.log('Got $versionCount tags');
            setState(() {});
          }
          if (context.mounted) setState(() {});
        },
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: versionCount,
                itemBuilder: (context, index) {
                  bool isDevBuild = tags[index].contains('_dev_');
                  return ListTile(
                    leading: tags[index] == 'v${Constants.appVersion}' //
                        ? const Icon(Icons.arrow_right_rounded)
                        : const Text(''),
                    title: Text(
                      tags[index],
                      style: const TextStyle(
                        fontWeight: .w600,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text('${shas[index]} - ${isDevBuild ? 'dev' : 'stable'}'),
                    visualDensity: const VisualDensity(vertical: 3, horizontal: 4),
                    trailing: Row(
                      mainAxisSize: .min,
                      children: [
                        if (!isDevBuild)
                          IconButton(
                            icon: const Icon(Icons.file_present_rounded),
                            onPressed: () {
                              context.pushRoute(RawDialogRoute(
                                transitionDuration: 300.ms,
                                barrierDismissible: true,
                                barrierLabel: '',
                                transitionBuilder: (_, anim1, _, child) {
                                  return ScaleTransition(
                                    scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
                                    alignment: Alignment.center,
                                    child: child,
                                  );
                                },
                                pageBuilder: (context, _, _) {
                                  return VersionDialog(
                                    tag: tags[index],
                                    sha: shas[index],
                                  );
                                },
                              ));
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.logo_dev_rounded),
                          onPressed: () {
                            context.pushRoute(RawDialogRoute(
                              transitionDuration: 300.ms,
                              barrierDismissible: true,
                              barrierLabel: '',
                              transitionBuilder: (_, anim1, _, child) {
                                return ScaleTransition(
                                  scale: anim1.drive(CurveTween(curve: Curves.easeOutQuart)),
                                  alignment: .center,
                                  child: child,
                                );
                              },
                              pageBuilder: (context, _, _) {
                                return VersionDialog(
                                  tag: tags[index],
                                  sha: shas[index],
                                  dev: true,
                                );
                              },
                            ));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
