import 'package:flutter/material.dart';

import 'package:animations/animations.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/artist_service.dart';
import 'package:music_hub/ui/app/artist/artist_songs.dart';
import 'package:music_hub/ui/core/theme/extensions.dart';
import 'package:music_hub/utils/extensions.dart' show DurationFromNumber;

class ArtistList extends StatefulWidget {
  const ArtistList({super.key});

  @override
  State<ArtistList> createState() => _ArtistListState();
}

class _ArtistListState extends State<ArtistList> {
  final artistService = GetIt.I<ArtistService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          artistService.updateArtistList();
          if (context.mounted) setState(() {});
        },
        child: ListView.builder(
          itemCount: artistService.artists.length,
          itemBuilder: (context, artistIndex) {
            String artistName = artistService.artists.keys.elementAt(artistIndex);
            return OpenContainer(
              closedElevation: 0,
              closedColor: context.colorScheme.surface,
              openColor: Colors.transparent,
              transitionDuration: 400.ms,
              onClosed: (_) => setState(() {}),
              openBuilder: (context, action) {
                return ArtistSongs(artistName: artistName);
              },
              closedBuilder: (context, action) {
                final songCount = artistService.artists[artistName];
                if (songCount == null) return const SizedBox.shrink();

                return ListTile(
                  contentPadding: const .symmetric(horizontal: 20),
                  title: Text(artistName, style: const TextStyle(fontWeight: .w600)),
                  subtitle: Text(
                    '$songCount song${songCount > 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600], fontWeight: .w400),
                  ),
                  onTap: action,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
