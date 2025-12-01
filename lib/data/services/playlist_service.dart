import 'package:get_it/get_it.dart';

import 'package:music_hub/data/services/config_service.dart';
import 'package:music_hub/data/services/database_service.dart';
import 'package:music_hub/data/services/log_service.dart';

class PlaylistService {
  final _logService = GetIt.I<LogService>();
  final _configService = GetIt.I<ConfigService>();
  final _databaseService = GetIt.I<DatabaseService>();
}
