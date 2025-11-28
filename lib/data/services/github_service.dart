import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/log_service.dart';
import 'package:music_hub/utils/constants.dart' show Constants;

class GithubService {
  final LogService _logService = GetIt.I();
  final Dio _dio = GetIt.I();

  Future<Response> apiQuery(String query) {
    const baseApiUrl = 'https://api.github.com/repos/Bill-GD/music_hub';
    _logService.log('Querying $query');
    return _dio.get(
      '$baseApiUrl$query',
      options: Options(headers: {'Authorization': 'Bearer ${Constants.githubToken}'}),
    );
  }

  Future<List<(String, String)>> getAllTags() async {
    final value = await apiQuery('/git/refs/tags');
    final json = jsonDecode(value.data);
    if (json == null) {
      throw Exception('Rate limited. Please come back later.');
    }
    if (json is! List) {
      _logService.log('JSON received is not a list', .error);
      throw Exception('Something is wrong when trying to get version list.');
    }

    return json.map((e) {
      final tag = e['ref'].toString().trim().split('/').last;
      final sha = e['object']['sha'].toString().trim().substring(0, 7);
      return (tag, sha);
    }).toList();
  }
}
