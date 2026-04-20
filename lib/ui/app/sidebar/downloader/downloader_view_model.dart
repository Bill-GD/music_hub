import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:music_hub/data/models/online_song.dart';
import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/ui/core/widgets/extensions.dart';
import 'package:music_hub/utils/constants.dart';
import 'package:music_hub/utils/extensions.dart';
import 'package:music_hub/utils/utils.dart';

class DownloaderViewModel extends ChangeNotifier {
  final shortSoundcloudRegEx = RegExp(r'^(?:https://)?on\.soundcloud\.com(?:\S+)?');
  final fullSoundcloudRegEx = RegExp(
    r'^(?:https://)?(m\.)?soundcloud\.com/([a-zA-Z0-9-]+)/([a-zA-Z0-9-]+)(?:\S+)?$',
  );
  final youtubeRegEx = RegExp(
    r'^(?:https://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/)([a-zA-Z0-9-_]{11})(?:\S+)?$',
  );

  final _logService = get<LogService>(), _dio = get<Dio>();
  final _baseSoundcloudApiUrl = 'https://api-v2.soundcloud.com';
  final urlController = TextEditingController();

  CancelToken _cancelToken = CancelToken();

  CancelToken get cancelToken {
    if (_cancelToken.isCancelled) {
      _cancelToken = CancelToken();
    }
    return _cancelToken;
  }

  bool _isGettingData = false, _isDownloading = false, _hasDownloaded = false;
  String? errorText;
  OnlineSong? _fetchedSong;
  int _received = 0, _total = 1;

  bool get fetchingData => _isGettingData;

  bool get canFetchData =>
      urlController.text.isNotEmpty &&
      errorText == null &&
      !_isGettingData &&
      !_isDownloading;

  OnlineSong? get song => _fetchedSong;

  bool get downloading => _isDownloading;

  bool get downloaded => _hasDownloaded;

  String get receivedSize => getSizeString(_received.toDouble());

  String get totalSize => getSizeString(_total.toDouble());

  double get percentage => clampDouble(_received / _total, 0, 1);

  String get percentageString => '${(_received / _total * 100).toStringAsPrecision(3)}%';

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  void progressCallback(int received, int total) {
    _received = received;
    _total = total;
    notifyListeners();
  }

  void validateInput(String text) {
    if (text.trim().isEmpty) {
      errorText = null;
    } else if (shortSoundcloudRegEx.hasMatch(text)) {
      errorText = 'Please use full URL, SoundCloud API is weird';
    } else if (!youtubeRegEx.hasMatch(text) && !fullSoundcloudRegEx.hasMatch(text)) {
      errorText = 'Invalid URL';
    } else {
      errorText = null;
    }
    notifyListeners();
  }

  Future<void> getData() async {
    _isGettingData = true;
    _fetchedSong = null;
    notifyListeners();

    final url = urlController.text;
    final isFromSoundCloud = url.contains('soundcloud.com');

    if (isFromSoundCloud) {
      errorText = 'SoundCloud downloader is disabled';
      // await _getSoundCloudSongData(url);
    } else {
      await _getYouTubeVideoData(url);
    }

    _isGettingData = false;
    notifyListeners();
  }

  Future<void> downloadSong() async {
    _isDownloading = true;
    notifyListeners();

    final url = urlController.text;
    final isFromSoundCloud = url.contains('soundcloud.com');

    if (isFromSoundCloud) {
      await _getSoundCloudSongData(url);
      // await Future.delayed(3.seconds);
    } else {
      await _downloadYoutube(url);
    }

    _isDownloading = false;
    _hasDownloaded = true;
    notifyListeners();
  }

  void cancelDownload() {
    _isDownloading = false;
    _hasDownloaded = false;
    cancelToken.cancel('User cancelled');
    notifyListeners();
  }

  void _failsDownload([Exception? error]) {
    _isDownloading = false;
    _hasDownloaded = false;
    notifyListeners();
    final err = error ?? Exception("Audio stream can't be downloaded.");
    cancelToken.cancel(err);
    throw err;
  }

  Future<void> _getYouTubeVideoData(String urlText) async {
    final yt = YoutubeExplode();

    final video = await yt.videos.get(urlText);
    final manifest = await yt.videos.streams.getManifest(urlText);
    final streamInfo = manifest.audioOnly.withHighestBitrate();

    _total = streamInfo.size.totalBytes;
    _fetchedSong = OnlineSong(
      url: urlText,
      title: video.title,
      author: video.author,
      duration: video.duration ?? 0.ms,
      thumbnailUrl: video.thumbnails.lowResUrl,
    );
    yt.close();
  }

  Future<void> _downloadYoutube(String url) async {
    if (_fetchedSong == null) throw Exception('No song fetched, aborting download.');

    final navKey = get<GlobalKey<NavigatorState>>();
    final yt = YoutubeExplode();
    final file = File(
      '${Paths.downloadPath}${sanitizeFilePath(_fetchedSong!.title)}.mp3',
    );

    if (file.existsSync() && file.lengthSync() > 0) {
      navKey.currentContext?.showToast('File with the same name already exists');
      return;
    }

    final manifest = await yt.videos.streams.getManifest(url);
    final streamInfo = manifest.audioOnly.withHighestBitrate();

    _logService.log('Saving to: ${file.absolute.path}');

    final timeoutTimer = Timer(10.seconds, () {
      if (_received <= 0) {
        if (file.existsSync()) file.deleteSync();
        _failsDownload(Exception('Timed out without having downloaded anything'));
      }
    });

    try {
      await _dio.download(
        streamInfo.url.toString(),
        file.absolute.path,
        onReceiveProgress: (received, total) {
          timeoutTimer.cancel();
          progressCallback(received, total);
        },
        cancelToken: cancelToken,
      );
    } on Exception catch (e) {
      timeoutTimer.cancel();
      if (file.existsSync()) file.deleteSync();
      _failsDownload(e);
    }

    if (_received <= 0) {
      timeoutTimer.cancel();
      if (file.existsSync()) file.deleteSync();
      _failsDownload(Exception("Dio couldn't download"));
    }

    timeoutTimer.cancel();
    yt.close();
    navKey.currentContext?.showToast('Finished downloading');
  }

  Future<void> _getSoundCloudSongData(String urlText) async {
    if (!urlText.contains('https://')) {
      urlText = 'https://$urlText';
    }
    // const String clientId = 'client_id=8BBZpqUP1KSN4W6YB64xog2PX4Dw98b1';
    const String clientId = 'client_id=57GDonO1e5SInnyt8DyMGWwbrg0AOq1H';
    final navKey = get<GlobalKey<NavigatorState>>();

    final url = urlText.split('?').first;
    final author = url.split('/').elementAt(3);

    _logService.log('Searching for author: $author');
    final responseAuthor = await _dio.get(
      '$_baseSoundcloudApiUrl/search/users?q=$author&$clientId',
    );

    if (responseAuthor.statusCode! >= 400) {
      _logService.log(
        '${responseAuthor.statusCode} - '
        '${switch (responseAuthor.statusCode) {
          401 => 'Unauthorized: Invalid client id',
          404 => 'Not Found',
          _ => 'Error',
        }}',
      );
      navKey.currentContext?.showToast('Failed to get author data');
      return;
    }

    final Map<String, dynamic> jsonDataAuthor = responseAuthor.data;
    var resultAuthor = (jsonDataAuthor['collection'] as List).where(
      (element) => element['permalink'] == author,
    );

    // can't find author
    if (resultAuthor.isEmpty) {
      _logService.log("Couldn't find author: $author");
      navKey.currentContext?.showToast("Couldn't find author: $author");
      return;
    }

    final authorId = '${resultAuthor.first['id']}';
    final authorUsername = '${resultAuthor.first['username']}';
    final trackCount = '${resultAuthor.first['track_count'] * 2}';

    _logService.log('Author: $authorUsername (id:$authorId) has $trackCount songs');
    _logService.log('Searching for track: ${url.split('/').elementAt(4)}');

    final responseTracks = await _dio.get(
      '$_baseSoundcloudApiUrl/users/$authorId/tracks?$clientId&limit=$trackCount',
    );

    if (responseAuthor.statusCode! >= 400) {
      _logService.log(
        '${responseAuthor.statusCode} - '
        '${switch (responseAuthor.statusCode) {
          401 => 'Unauthorized: Invalid client id',
          404 => 'Not Found',
          _ => 'Error',
        }}',
      );
      navKey.currentContext?.showToast('Failed to get track data');
      return;
    }

    final Map<String, dynamic> jsonDataTracks = responseTracks.data;
    var resultTracks = (jsonDataTracks['collection'] as List).where(
      (element) => element['permalink'] == url.split('/').elementAt(4),
    );

    final Map? trackData = resultTracks.isNotEmpty ? resultTracks.first : null;
    // can't find song
    if (trackData == null) {
      _logService.log("Couldn't find song: ${url.split('/').elementAt(4)}");
      navKey.currentContext?.showToast(
        "Couldn't find song: ${url.split('/').elementAt(4)}",
      );
      return;
    }

    final String songTitle = trackData['title'];
    final String trackStreamUrl = trackData['media']['transcodings'][1]['url'];
    final Duration duration = Duration(
      milliseconds: trackData['media']['transcodings'][1]['duration'],
    );
    final String? artworkUrl = trackData['artwork_url'];

    _logService.log('Found track stream url: $trackStreamUrl');
    _logService.log('Getting song media url');
    final responseTrack = await _dio.get('$trackStreamUrl?$clientId');

    if (responseAuthor.statusCode! >= 400) {
      _logService.log(
        '${responseAuthor.statusCode} - '
        '${switch (responseAuthor.statusCode) {
          401 => 'Unauthorized: Invalid client id',
          404 => 'Not Found',
          _ => 'Error',
        }}',
      );
      navKey.currentContext?.showToast('Failed to get track media url');
      return;
    }

    _total = 9999;
    _fetchedSong = OnlineSong(
      url: responseTrack.data['url'],
      title: songTitle,
      author: authorUsername,
      duration: duration,
      thumbnailUrl: artworkUrl,
    );
  }
}
