// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
//
// import 'package:dio/dio.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:music_hub/data/services/log_service.dart';
// import 'package:music_hub/utils/globals/widgets.dart';
// import 'package:music_hub/utils/utils.dart';
//
// const _url = 'https://api-v2.soundcloud.com';
//
// Future<Map<String, dynamic>?> getSoundCloudSongData(BuildContext context, String urlText) async {
//   if (!urlText.contains('https://')) {
//     urlText = 'https://$urlText';
//   }
//   // const String clientId = 'client_id=8BBZpqUP1KSN4W6YB64xog2PX4Dw98b1';
//   const String clientId = 'client_id=57GDonO1e5SInnyt8DyMGWwbrg0AOq1H';
//
//   String url = urlText.split('?').first;
//   String author = url.split('/').elementAt(3);
//
//   LogService.log('Searching for author: $author');
//   http.Response responseAuthor = await http.get(
//     Uri.parse('$_url/search/users?q=$author&$clientId'),
//   );
//
//   switch (responseAuthor.statusCode) {
//     case 401:
//       LogService.log('${responseAuthor.statusCode} Unauthorized: Invalid client id');
//       break;
//     case 404:
//       LogService.log('${responseAuthor.statusCode} Forbidden');
//       break;
//   }
//
//   if (responseAuthor.statusCode != 200) {
//     if (context.mounted) showToast(context, 'Failed to get author data');
//     return null;
//   }
//
//   Map<String, dynamic> jsonDataAuthor = jsonDecode(responseAuthor.body);
//   var resultAuthor = (jsonDataAuthor['collection'] as List).where(
//     (element) => element['permalink'] == author,
//   );
//
//   // can't find author
//   if (resultAuthor.isEmpty) {
//     LogService.log("Couldn't find author: $author");
//     if (context.mounted) {
//       showToast(context, "Couldn't find author: $author");
//     }
//     return null;
//   }
//
//   String authorId = '${resultAuthor.first['id']}';
//   String authorUsername = '${resultAuthor.first['username']}';
//   String trackCount = '${resultAuthor.first['track_count'] * 2}';
//
//   LogService.log('Author: $authorUsername (id:$authorId) has $trackCount songs');
//
//   LogService.log('Searching for track: ${url.split('/').elementAt(4)}');
//   http.Response responseTracks = await http.get(
//     Uri.parse('$_url/users/$authorId/tracks?$clientId&limit=$trackCount'),
//   );
//
//   switch (responseTracks.statusCode) {
//     case 401:
//       LogService.log('${responseTracks.statusCode} Unauthorized: Invalid client id');
//       break;
//     case 404:
//       LogService.log('${responseTracks.statusCode} Forbidden');
//       break;
//   }
//
//   if (responseTracks.statusCode != 200) {
//     if (context.mounted) showToast(context, 'Failed to get track data');
//     return null;
//   }
//
//   Map<String, dynamic> jsonDataTracks = jsonDecode(responseTracks.body);
//   var resultTracks = (jsonDataTracks['collection'] as List).where(
//     (element) => element['permalink'] == url.split('/').elementAt(4),
//   );
//
//   final Map? trackData = resultTracks.isNotEmpty ? resultTracks.first : null;
//   // can't find song
//   if (trackData == null) {
//     LogService.log("Couldn't find song: ${url.split('/').elementAt(4)}");
//     if (context.mounted) {
//       showToast(context, "Couldn't find song: ${url.split('/').elementAt(4)}");
//     }
//     return null;
//   }
//
//   String songTitle = trackData['title'];
//   String trackStreamUrl = trackData['media']['transcodings'][1]['url'];
//   Duration duration = Duration(milliseconds: trackData['media']['transcodings'][1]['duration']);
//   String? artworkUrl = trackData['artwork_url'];
//
//   LogService.log('Found track stream url: $trackStreamUrl');
//   LogService.log('Getting song media url');
//   http.Response responseTrack = await http.get(Uri.parse('$trackStreamUrl?$clientId'));
//
//   switch (responseTrack.statusCode) {
//     case 401:
//       LogService.log('${responseTrack.statusCode} Unauthorized: Invalid client id');
//       break;
//     case 404:
//       LogService.log('${responseTrack.statusCode} Forbidden');
//       break;
//   }
//   if (responseTrack.statusCode != 200) {
//     if (context.mounted) showToast(context, 'Failed to get track media url');
//     return null;
//   }
//
//   String trackUrl = jsonDecode(responseTrack.body)['url'];
//
//   // LogHandler.log(trackUrl);
//   // LogHandler.log(songTitle);
//
//   return {
//     'trackUrl': trackUrl,
//     'thumbnailUrl': artworkUrl,
//     'title': songTitle,
//     'author': authorUsername,
//     'duration': duration,
//   };
// }
//
// Future<void> downloadSoundCloudMP3(
//   BuildContext context,
//   String url,
//   String videoTitle,
//   void Function(int, int) onReceiveProgress,
// ) async {
//   final dio = Dio();
//   final file = File('/storage/emulated/0/Download/${sanitizeFilePath(videoTitle)}.mp3');
//
//   if (file.existsSync() && file.lengthSync() > 0) {
//     LogService.log('Duplicate file name, canceled download');
//     if (context.mounted) {
//       showToast(context, 'Duplicate file name, canceled download');
//     }
//     return;
//   }
//   try {
//     LogService.log('Saving to: ${file.absolute.path}');
//     await dio.download(
//       url,
//       file.absolute.path,
//       onReceiveProgress: onReceiveProgress,
//     );
//
//     if (context.mounted) {
//       showToast(context, 'Finished downloading');
//     }
//   } on Exception catch (e) {
//     LogService.log(e.toString(), .error);
//     if (context.mounted) {
//       showErrorPopup(context, e.toString());
//     }
//   }
// }
