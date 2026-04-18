// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SongTable extends Song with TableInfo<$SongTable, SongData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timeAddedMeta = const VerificationMeta(
    'timeAdded',
  );
  @override
  late final GeneratedColumn<DateTime> timeAdded = GeneratedColumn<DateTime>(
    'time_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeListenedMeta = const VerificationMeta(
    'timeListened',
  );
  @override
  late final GeneratedColumn<int> timeListened = GeneratedColumn<int>(
    'time_listened',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lyricPathMeta = const VerificationMeta(
    'lyricPath',
  );
  @override
  late final GeneratedColumn<String> lyricPath = GeneratedColumn<String>(
    'lyric_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    check: () => deleted.isIn([true, false]),
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timeAdded,
    path,
    name,
    artist,
    timeListened,
    lyricPath,
    imagePath,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'song';
  @override
  VerificationContext validateIntegrity(
    Insertable<SongData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time_added')) {
      context.handle(
        _timeAddedMeta,
        timeAdded.isAcceptableOrUnknown(data['time_added']!, _timeAddedMeta),
      );
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('time_listened')) {
      context.handle(
        _timeListenedMeta,
        timeListened.isAcceptableOrUnknown(
          data['time_listened']!,
          _timeListenedMeta,
        ),
      );
    }
    if (data.containsKey('lyric_path')) {
      context.handle(
        _lyricPathMeta,
        lyricPath.isAcceptableOrUnknown(data['lyric_path']!, _lyricPathMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SongData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SongData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timeAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time_added'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      )!,
      timeListened: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_listened'],
      )!,
      lyricPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lyric_path'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $SongTable createAlias(String alias) {
    return $SongTable(attachedDatabase, alias);
  }
}

class SongData extends DataClass implements Insertable<SongData> {
  final int id;
  final DateTime timeAdded;
  final String path;
  final String name;
  final String artist;
  final int timeListened;
  final String lyricPath;
  final String imagePath;
  final bool deleted;
  const SongData({
    required this.id,
    required this.timeAdded,
    required this.path,
    required this.name,
    required this.artist,
    required this.timeListened,
    required this.lyricPath,
    required this.imagePath,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time_added'] = Variable<DateTime>(timeAdded);
    map['path'] = Variable<String>(path);
    map['name'] = Variable<String>(name);
    map['artist'] = Variable<String>(artist);
    map['time_listened'] = Variable<int>(timeListened);
    map['lyric_path'] = Variable<String>(lyricPath);
    map['image_path'] = Variable<String>(imagePath);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  SongCompanion toCompanion(bool nullToAbsent) {
    return SongCompanion(
      id: Value(id),
      timeAdded: Value(timeAdded),
      path: Value(path),
      name: Value(name),
      artist: Value(artist),
      timeListened: Value(timeListened),
      lyricPath: Value(lyricPath),
      imagePath: Value(imagePath),
      deleted: Value(deleted),
    );
  }

  factory SongData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SongData(
      id: serializer.fromJson<int>(json['id']),
      timeAdded: serializer.fromJson<DateTime>(json['timeAdded']),
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String>(json['name']),
      artist: serializer.fromJson<String>(json['artist']),
      timeListened: serializer.fromJson<int>(json['timeListened']),
      lyricPath: serializer.fromJson<String>(json['lyricPath']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timeAdded': serializer.toJson<DateTime>(timeAdded),
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String>(name),
      'artist': serializer.toJson<String>(artist),
      'timeListened': serializer.toJson<int>(timeListened),
      'lyricPath': serializer.toJson<String>(lyricPath),
      'imagePath': serializer.toJson<String>(imagePath),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  SongData copyWith({
    int? id,
    DateTime? timeAdded,
    String? path,
    String? name,
    String? artist,
    int? timeListened,
    String? lyricPath,
    String? imagePath,
    bool? deleted,
  }) => SongData(
    id: id ?? this.id,
    timeAdded: timeAdded ?? this.timeAdded,
    path: path ?? this.path,
    name: name ?? this.name,
    artist: artist ?? this.artist,
    timeListened: timeListened ?? this.timeListened,
    lyricPath: lyricPath ?? this.lyricPath,
    imagePath: imagePath ?? this.imagePath,
    deleted: deleted ?? this.deleted,
  );
  SongData copyWithCompanion(SongCompanion data) {
    return SongData(
      id: data.id.present ? data.id.value : this.id,
      timeAdded: data.timeAdded.present ? data.timeAdded.value : this.timeAdded,
      path: data.path.present ? data.path.value : this.path,
      name: data.name.present ? data.name.value : this.name,
      artist: data.artist.present ? data.artist.value : this.artist,
      timeListened: data.timeListened.present
          ? data.timeListened.value
          : this.timeListened,
      lyricPath: data.lyricPath.present ? data.lyricPath.value : this.lyricPath,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SongData(')
          ..write('id: $id, ')
          ..write('timeAdded: $timeAdded, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('timeListened: $timeListened, ')
          ..write('lyricPath: $lyricPath, ')
          ..write('imagePath: $imagePath, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timeAdded,
    path,
    name,
    artist,
    timeListened,
    lyricPath,
    imagePath,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SongData &&
          other.id == this.id &&
          other.timeAdded == this.timeAdded &&
          other.path == this.path &&
          other.name == this.name &&
          other.artist == this.artist &&
          other.timeListened == this.timeListened &&
          other.lyricPath == this.lyricPath &&
          other.imagePath == this.imagePath &&
          other.deleted == this.deleted);
}

class SongCompanion extends UpdateCompanion<SongData> {
  final Value<int> id;
  final Value<DateTime> timeAdded;
  final Value<String> path;
  final Value<String> name;
  final Value<String> artist;
  final Value<int> timeListened;
  final Value<String> lyricPath;
  final Value<String> imagePath;
  final Value<bool> deleted;
  const SongCompanion({
    this.id = const Value.absent(),
    this.timeAdded = const Value.absent(),
    this.path = const Value.absent(),
    this.name = const Value.absent(),
    this.artist = const Value.absent(),
    this.timeListened = const Value.absent(),
    this.lyricPath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  SongCompanion.insert({
    this.id = const Value.absent(),
    this.timeAdded = const Value.absent(),
    required String path,
    required String name,
    required String artist,
    this.timeListened = const Value.absent(),
    this.lyricPath = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.deleted = const Value.absent(),
  }) : path = Value(path),
       name = Value(name),
       artist = Value(artist);
  static Insertable<SongData> custom({
    Expression<int>? id,
    Expression<DateTime>? timeAdded,
    Expression<String>? path,
    Expression<String>? name,
    Expression<String>? artist,
    Expression<int>? timeListened,
    Expression<String>? lyricPath,
    Expression<String>? imagePath,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timeAdded != null) 'time_added': timeAdded,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (artist != null) 'artist': artist,
      if (timeListened != null) 'time_listened': timeListened,
      if (lyricPath != null) 'lyric_path': lyricPath,
      if (imagePath != null) 'image_path': imagePath,
      if (deleted != null) 'deleted': deleted,
    });
  }

  SongCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timeAdded,
    Value<String>? path,
    Value<String>? name,
    Value<String>? artist,
    Value<int>? timeListened,
    Value<String>? lyricPath,
    Value<String>? imagePath,
    Value<bool>? deleted,
  }) {
    return SongCompanion(
      id: id ?? this.id,
      timeAdded: timeAdded ?? this.timeAdded,
      path: path ?? this.path,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      timeListened: timeListened ?? this.timeListened,
      lyricPath: lyricPath ?? this.lyricPath,
      imagePath: imagePath ?? this.imagePath,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timeAdded.present) {
      map['time_added'] = Variable<DateTime>(timeAdded.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (timeListened.present) {
      map['time_listened'] = Variable<int>(timeListened.value);
    }
    if (lyricPath.present) {
      map['lyric_path'] = Variable<String>(lyricPath.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongCompanion(')
          ..write('id: $id, ')
          ..write('timeAdded: $timeAdded, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('artist: $artist, ')
          ..write('timeListened: $timeListened, ')
          ..write('lyricPath: $lyricPath, ')
          ..write('imagePath: $imagePath, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $AlbumTable extends Album with TableInfo<$AlbumTable, AlbumData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timeAddedMeta = const VerificationMeta(
    'timeAdded',
  );
  @override
  late final GeneratedColumn<DateTime> timeAdded = GeneratedColumn<DateTime>(
    'time_added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, timeAdded, name, imagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time_added')) {
      context.handle(
        _timeAddedMeta,
        timeAdded.isAcceptableOrUnknown(data['time_added']!, _timeAddedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timeAdded: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time_added'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
    );
  }

  @override
  $AlbumTable createAlias(String alias) {
    return $AlbumTable(attachedDatabase, alias);
  }
}

class AlbumData extends DataClass implements Insertable<AlbumData> {
  final int id;
  final DateTime timeAdded;
  final String name;
  final String imagePath;
  const AlbumData({
    required this.id,
    required this.timeAdded,
    required this.name,
    required this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time_added'] = Variable<DateTime>(timeAdded);
    map['name'] = Variable<String>(name);
    map['image_path'] = Variable<String>(imagePath);
    return map;
  }

  AlbumCompanion toCompanion(bool nullToAbsent) {
    return AlbumCompanion(
      id: Value(id),
      timeAdded: Value(timeAdded),
      name: Value(name),
      imagePath: Value(imagePath),
    );
  }

  factory AlbumData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumData(
      id: serializer.fromJson<int>(json['id']),
      timeAdded: serializer.fromJson<DateTime>(json['timeAdded']),
      name: serializer.fromJson<String>(json['name']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timeAdded': serializer.toJson<DateTime>(timeAdded),
      'name': serializer.toJson<String>(name),
      'imagePath': serializer.toJson<String>(imagePath),
    };
  }

  AlbumData copyWith({
    int? id,
    DateTime? timeAdded,
    String? name,
    String? imagePath,
  }) => AlbumData(
    id: id ?? this.id,
    timeAdded: timeAdded ?? this.timeAdded,
    name: name ?? this.name,
    imagePath: imagePath ?? this.imagePath,
  );
  AlbumData copyWithCompanion(AlbumCompanion data) {
    return AlbumData(
      id: data.id.present ? data.id.value : this.id,
      timeAdded: data.timeAdded.present ? data.timeAdded.value : this.timeAdded,
      name: data.name.present ? data.name.value : this.name,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumData(')
          ..write('id: $id, ')
          ..write('timeAdded: $timeAdded, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timeAdded, name, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumData &&
          other.id == this.id &&
          other.timeAdded == this.timeAdded &&
          other.name == this.name &&
          other.imagePath == this.imagePath);
}

class AlbumCompanion extends UpdateCompanion<AlbumData> {
  final Value<int> id;
  final Value<DateTime> timeAdded;
  final Value<String> name;
  final Value<String> imagePath;
  const AlbumCompanion({
    this.id = const Value.absent(),
    this.timeAdded = const Value.absent(),
    this.name = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  AlbumCompanion.insert({
    this.id = const Value.absent(),
    this.timeAdded = const Value.absent(),
    required String name,
    this.imagePath = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AlbumData> custom({
    Expression<int>? id,
    Expression<DateTime>? timeAdded,
    Expression<String>? name,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timeAdded != null) 'time_added': timeAdded,
      if (name != null) 'name': name,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  AlbumCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timeAdded,
    Value<String>? name,
    Value<String>? imagePath,
  }) {
    return AlbumCompanion(
      id: id ?? this.id,
      timeAdded: timeAdded ?? this.timeAdded,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timeAdded.present) {
      map['time_added'] = Variable<DateTime>(timeAdded.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumCompanion(')
          ..write('id: $id, ')
          ..write('timeAdded: $timeAdded, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTable extends Playlist
    with TableInfo<$PlaylistTable, PlaylistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listNameMeta = const VerificationMeta(
    'listName',
  );
  @override
  late final GeneratedColumn<String> listName = GeneratedColumn<String>(
    'list_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<int> songId = GeneratedColumn<int>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, listName, songId, isCurrent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_name')) {
      context.handle(
        _listNameMeta,
        listName.isAcceptableOrUnknown(data['list_name']!, _listNameMeta),
      );
    } else if (isInserting) {
      context.missing(_listNameMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
        _songIdMeta,
        songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta),
      );
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_name'],
      )!,
      songId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}song_id'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
    );
  }

  @override
  $PlaylistTable createAlias(String alias) {
    return $PlaylistTable(attachedDatabase, alias);
  }
}

class PlaylistData extends DataClass implements Insertable<PlaylistData> {
  final int id;
  final String listName;
  final int songId;
  final bool isCurrent;
  const PlaylistData({
    required this.id,
    required this.listName,
    required this.songId,
    required this.isCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_name'] = Variable<String>(listName);
    map['song_id'] = Variable<int>(songId);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  PlaylistCompanion toCompanion(bool nullToAbsent) {
    return PlaylistCompanion(
      id: Value(id),
      listName: Value(listName),
      songId: Value(songId),
      isCurrent: Value(isCurrent),
    );
  }

  factory PlaylistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistData(
      id: serializer.fromJson<int>(json['id']),
      listName: serializer.fromJson<String>(json['listName']),
      songId: serializer.fromJson<int>(json['songId']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listName': serializer.toJson<String>(listName),
      'songId': serializer.toJson<int>(songId),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  PlaylistData copyWith({
    int? id,
    String? listName,
    int? songId,
    bool? isCurrent,
  }) => PlaylistData(
    id: id ?? this.id,
    listName: listName ?? this.listName,
    songId: songId ?? this.songId,
    isCurrent: isCurrent ?? this.isCurrent,
  );
  PlaylistData copyWithCompanion(PlaylistCompanion data) {
    return PlaylistData(
      id: data.id.present ? data.id.value : this.id,
      listName: data.listName.present ? data.listName.value : this.listName,
      songId: data.songId.present ? data.songId.value : this.songId,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistData(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('songId: $songId, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listName, songId, isCurrent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistData &&
          other.id == this.id &&
          other.listName == this.listName &&
          other.songId == this.songId &&
          other.isCurrent == this.isCurrent);
}

class PlaylistCompanion extends UpdateCompanion<PlaylistData> {
  final Value<int> id;
  final Value<String> listName;
  final Value<int> songId;
  final Value<bool> isCurrent;
  const PlaylistCompanion({
    this.id = const Value.absent(),
    this.listName = const Value.absent(),
    this.songId = const Value.absent(),
    this.isCurrent = const Value.absent(),
  });
  PlaylistCompanion.insert({
    this.id = const Value.absent(),
    required String listName,
    required int songId,
    this.isCurrent = const Value.absent(),
  }) : listName = Value(listName),
       songId = Value(songId);
  static Insertable<PlaylistData> custom({
    Expression<int>? id,
    Expression<String>? listName,
    Expression<int>? songId,
    Expression<bool>? isCurrent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listName != null) 'list_name': listName,
      if (songId != null) 'song_id': songId,
      if (isCurrent != null) 'is_current': isCurrent,
    });
  }

  PlaylistCompanion copyWith({
    Value<int>? id,
    Value<String>? listName,
    Value<int>? songId,
    Value<bool>? isCurrent,
  }) {
    return PlaylistCompanion(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      songId: songId ?? this.songId,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listName.present) {
      map['list_name'] = Variable<String>(listName.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistCompanion(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('songId: $songId, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }
}

class $AlbumSongTable extends AlbumSong
    with TableInfo<$AlbumSongTable, AlbumSongData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumSongTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackOrderMeta = const VerificationMeta(
    'trackOrder',
  );
  @override
  late final GeneratedColumn<int> trackOrder = GeneratedColumn<int>(
    'track_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES song (id)',
    ),
  );
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<int> albumId = GeneratedColumn<int>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES album (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [trackOrder, trackId, albumId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_song';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumSongData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_order')) {
      context.handle(
        _trackOrderMeta,
        trackOrder.isAcceptableOrUnknown(data['track_order']!, _trackOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_trackOrderMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackOrder, trackId, albumId};
  @override
  AlbumSongData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumSongData(
      trackOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_order'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}album_id'],
      )!,
    );
  }

  @override
  $AlbumSongTable createAlias(String alias) {
    return $AlbumSongTable(attachedDatabase, alias);
  }
}

class AlbumSongData extends DataClass implements Insertable<AlbumSongData> {
  final int trackOrder;
  final int trackId;
  final int albumId;
  const AlbumSongData({
    required this.trackOrder,
    required this.trackId,
    required this.albumId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_order'] = Variable<int>(trackOrder);
    map['track_id'] = Variable<int>(trackId);
    map['album_id'] = Variable<int>(albumId);
    return map;
  }

  AlbumSongCompanion toCompanion(bool nullToAbsent) {
    return AlbumSongCompanion(
      trackOrder: Value(trackOrder),
      trackId: Value(trackId),
      albumId: Value(albumId),
    );
  }

  factory AlbumSongData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumSongData(
      trackOrder: serializer.fromJson<int>(json['trackOrder']),
      trackId: serializer.fromJson<int>(json['trackId']),
      albumId: serializer.fromJson<int>(json['albumId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackOrder': serializer.toJson<int>(trackOrder),
      'trackId': serializer.toJson<int>(trackId),
      'albumId': serializer.toJson<int>(albumId),
    };
  }

  AlbumSongData copyWith({int? trackOrder, int? trackId, int? albumId}) =>
      AlbumSongData(
        trackOrder: trackOrder ?? this.trackOrder,
        trackId: trackId ?? this.trackId,
        albumId: albumId ?? this.albumId,
      );
  AlbumSongData copyWithCompanion(AlbumSongCompanion data) {
    return AlbumSongData(
      trackOrder: data.trackOrder.present
          ? data.trackOrder.value
          : this.trackOrder,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumSongData(')
          ..write('trackOrder: $trackOrder, ')
          ..write('trackId: $trackId, ')
          ..write('albumId: $albumId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackOrder, trackId, albumId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumSongData &&
          other.trackOrder == this.trackOrder &&
          other.trackId == this.trackId &&
          other.albumId == this.albumId);
}

class AlbumSongCompanion extends UpdateCompanion<AlbumSongData> {
  final Value<int> trackOrder;
  final Value<int> trackId;
  final Value<int> albumId;
  final Value<int> rowid;
  const AlbumSongCompanion({
    this.trackOrder = const Value.absent(),
    this.trackId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumSongCompanion.insert({
    required int trackOrder,
    required int trackId,
    required int albumId,
    this.rowid = const Value.absent(),
  }) : trackOrder = Value(trackOrder),
       trackId = Value(trackId),
       albumId = Value(albumId);
  static Insertable<AlbumSongData> custom({
    Expression<int>? trackOrder,
    Expression<int>? trackId,
    Expression<int>? albumId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackOrder != null) 'track_order': trackOrder,
      if (trackId != null) 'track_id': trackId,
      if (albumId != null) 'album_id': albumId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumSongCompanion copyWith({
    Value<int>? trackOrder,
    Value<int>? trackId,
    Value<int>? albumId,
    Value<int>? rowid,
  }) {
    return AlbumSongCompanion(
      trackOrder: trackOrder ?? this.trackOrder,
      trackId: trackId ?? this.trackId,
      albumId: albumId ?? this.albumId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackOrder.present) {
      map['track_order'] = Variable<int>(trackOrder.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumSongCompanion(')
          ..write('trackOrder: $trackOrder, ')
          ..write('trackId: $trackId, ')
          ..write('albumId: $albumId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MusicDatabase extends GeneratedDatabase {
  _$MusicDatabase(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $SongTable song = $SongTable(this);
  late final $AlbumTable album = $AlbumTable(this);
  late final $PlaylistTable playlist = $PlaylistTable(this);
  late final $AlbumSongTable albumSong = $AlbumSongTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    song,
    album,
    playlist,
    albumSong,
  ];
}

typedef $$SongTableCreateCompanionBuilder =
    SongCompanion Function({
      Value<int> id,
      Value<DateTime> timeAdded,
      required String path,
      required String name,
      required String artist,
      Value<int> timeListened,
      Value<String> lyricPath,
      Value<String> imagePath,
      Value<bool> deleted,
    });
typedef $$SongTableUpdateCompanionBuilder =
    SongCompanion Function({
      Value<int> id,
      Value<DateTime> timeAdded,
      Value<String> path,
      Value<String> name,
      Value<String> artist,
      Value<int> timeListened,
      Value<String> lyricPath,
      Value<String> imagePath,
      Value<bool> deleted,
    });

final class $$SongTableReferences
    extends BaseReferences<_$MusicDatabase, $SongTable, SongData> {
  $$SongTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlbumSongTable, List<AlbumSongData>>
  _albumSongRefsTable(_$MusicDatabase db) => MultiTypedResultKey.fromTable(
    db.albumSong,
    aliasName: $_aliasNameGenerator(db.song.id, db.albumSong.trackId),
  );

  $$AlbumSongTableProcessedTableManager get albumSongRefs {
    final manager = $$AlbumSongTableTableManager(
      $_db,
      $_db.albumSong,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_albumSongRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SongTableFilterComposer extends Composer<_$MusicDatabase, $SongTable> {
  $$SongTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timeAdded => $composableBuilder(
    column: $table.timeAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeListened => $composableBuilder(
    column: $table.timeListened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lyricPath => $composableBuilder(
    column: $table.lyricPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> albumSongRefs(
    Expression<bool> Function($$AlbumSongTableFilterComposer f) f,
  ) {
    final $$AlbumSongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumSong,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumSongTableFilterComposer(
            $db: $db,
            $table: $db.albumSong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongTableOrderingComposer extends Composer<_$MusicDatabase, $SongTable> {
  $$SongTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timeAdded => $composableBuilder(
    column: $table.timeAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeListened => $composableBuilder(
    column: $table.timeListened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lyricPath => $composableBuilder(
    column: $table.lyricPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SongTableAnnotationComposer extends Composer<_$MusicDatabase, $SongTable> {
  $$SongTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timeAdded =>
      $composableBuilder(column: $table.timeAdded, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get timeListened => $composableBuilder(
    column: $table.timeListened,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lyricPath =>
      $composableBuilder(column: $table.lyricPath, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  Expression<T> albumSongRefs<T extends Object>(
    Expression<T> Function($$AlbumSongTableAnnotationComposer a) f,
  ) {
    final $$AlbumSongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumSong,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumSongTableAnnotationComposer(
            $db: $db,
            $table: $db.albumSong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SongTableTableManager
    extends
        RootTableManager<
          _$MusicDatabase,
          $SongTable,
          SongData,
          $$SongTableFilterComposer,
          $$SongTableOrderingComposer,
          $$SongTableAnnotationComposer,
          $$SongTableCreateCompanionBuilder,
          $$SongTableUpdateCompanionBuilder,
          (SongData, $$SongTableReferences),
          SongData,
          PrefetchHooks Function({bool albumSongRefs})
        > {
  $$SongTableTableManager(_$MusicDatabase db, $SongTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SongTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SongTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SongTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timeAdded = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> artist = const Value.absent(),
                Value<int> timeListened = const Value.absent(),
                Value<String> lyricPath = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => SongCompanion(
                id: id,
                timeAdded: timeAdded,
                path: path,
                name: name,
                artist: artist,
                timeListened: timeListened,
                lyricPath: lyricPath,
                imagePath: imagePath,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timeAdded = const Value.absent(),
                required String path,
                required String name,
                required String artist,
                Value<int> timeListened = const Value.absent(),
                Value<String> lyricPath = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => SongCompanion.insert(
                id: id,
                timeAdded: timeAdded,
                path: path,
                name: name,
                artist: artist,
                timeListened: timeListened,
                lyricPath: lyricPath,
                imagePath: imagePath,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SongTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({albumSongRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (albumSongRefs) db.albumSong],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (albumSongRefs)
                    await $_getPrefetchedData<
                      SongData,
                      $SongTable,
                      AlbumSongData
                    >(
                      currentTable: table,
                      referencedTable: $$SongTableReferences
                          ._albumSongRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SongTableReferences(db, table, p0).albumSongRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.trackId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SongTableProcessedTableManager =
    ProcessedTableManager<
      _$MusicDatabase,
      $SongTable,
      SongData,
      $$SongTableFilterComposer,
      $$SongTableOrderingComposer,
      $$SongTableAnnotationComposer,
      $$SongTableCreateCompanionBuilder,
      $$SongTableUpdateCompanionBuilder,
      (SongData, $$SongTableReferences),
      SongData,
      PrefetchHooks Function({bool albumSongRefs})
    >;
typedef $$AlbumTableCreateCompanionBuilder =
    AlbumCompanion Function({
      Value<int> id,
      Value<DateTime> timeAdded,
      required String name,
      Value<String> imagePath,
    });
typedef $$AlbumTableUpdateCompanionBuilder =
    AlbumCompanion Function({
      Value<int> id,
      Value<DateTime> timeAdded,
      Value<String> name,
      Value<String> imagePath,
    });

final class $$AlbumTableReferences
    extends BaseReferences<_$MusicDatabase, $AlbumTable, AlbumData> {
  $$AlbumTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlbumSongTable, List<AlbumSongData>>
  _albumSongRefsTable(_$MusicDatabase db) => MultiTypedResultKey.fromTable(
    db.albumSong,
    aliasName: $_aliasNameGenerator(db.album.id, db.albumSong.albumId),
  );

  $$AlbumSongTableProcessedTableManager get albumSongRefs {
    final manager = $$AlbumSongTableTableManager(
      $_db,
      $_db.albumSong,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_albumSongRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumTableFilterComposer extends Composer<_$MusicDatabase, $AlbumTable> {
  $$AlbumTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timeAdded => $composableBuilder(
    column: $table.timeAdded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> albumSongRefs(
    Expression<bool> Function($$AlbumSongTableFilterComposer f) f,
  ) {
    final $$AlbumSongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumSong,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumSongTableFilterComposer(
            $db: $db,
            $table: $db.albumSong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumTableOrderingComposer extends Composer<_$MusicDatabase, $AlbumTable> {
  $$AlbumTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timeAdded => $composableBuilder(
    column: $table.timeAdded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumTableAnnotationComposer extends Composer<_$MusicDatabase, $AlbumTable> {
  $$AlbumTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timeAdded =>
      $composableBuilder(column: $table.timeAdded, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  Expression<T> albumSongRefs<T extends Object>(
    Expression<T> Function($$AlbumSongTableAnnotationComposer a) f,
  ) {
    final $$AlbumSongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumSong,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumSongTableAnnotationComposer(
            $db: $db,
            $table: $db.albumSong,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumTableTableManager
    extends
        RootTableManager<
          _$MusicDatabase,
          $AlbumTable,
          AlbumData,
          $$AlbumTableFilterComposer,
          $$AlbumTableOrderingComposer,
          $$AlbumTableAnnotationComposer,
          $$AlbumTableCreateCompanionBuilder,
          $$AlbumTableUpdateCompanionBuilder,
          (AlbumData, $$AlbumTableReferences),
          AlbumData,
          PrefetchHooks Function({bool albumSongRefs})
        > {
  $$AlbumTableTableManager(_$MusicDatabase db, $AlbumTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timeAdded = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
              }) => AlbumCompanion(
                id: id,
                timeAdded: timeAdded,
                name: name,
                imagePath: imagePath,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timeAdded = const Value.absent(),
                required String name,
                Value<String> imagePath = const Value.absent(),
              }) => AlbumCompanion.insert(
                id: id,
                timeAdded: timeAdded,
                name: name,
                imagePath: imagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AlbumTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({albumSongRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (albumSongRefs) db.albumSong],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (albumSongRefs)
                    await $_getPrefetchedData<
                      AlbumData,
                      $AlbumTable,
                      AlbumSongData
                    >(
                      currentTable: table,
                      referencedTable: $$AlbumTableReferences
                          ._albumSongRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlbumTableReferences(db, table, p0).albumSongRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.albumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumTableProcessedTableManager =
    ProcessedTableManager<
      _$MusicDatabase,
      $AlbumTable,
      AlbumData,
      $$AlbumTableFilterComposer,
      $$AlbumTableOrderingComposer,
      $$AlbumTableAnnotationComposer,
      $$AlbumTableCreateCompanionBuilder,
      $$AlbumTableUpdateCompanionBuilder,
      (AlbumData, $$AlbumTableReferences),
      AlbumData,
      PrefetchHooks Function({bool albumSongRefs})
    >;
typedef $$PlaylistTableCreateCompanionBuilder =
    PlaylistCompanion Function({
      Value<int> id,
      required String listName,
      required int songId,
      Value<bool> isCurrent,
    });
typedef $$PlaylistTableUpdateCompanionBuilder =
    PlaylistCompanion Function({
      Value<int> id,
      Value<String> listName,
      Value<int> songId,
      Value<bool> isCurrent,
    });

class $$PlaylistTableFilterComposer
    extends Composer<_$MusicDatabase, $PlaylistTable> {
  $$PlaylistTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listName => $composableBuilder(
    column: $table.listName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaylistTableOrderingComposer
    extends Composer<_$MusicDatabase, $PlaylistTable> {
  $$PlaylistTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listName => $composableBuilder(
    column: $table.listName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get songId => $composableBuilder(
    column: $table.songId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistTableAnnotationComposer
    extends Composer<_$MusicDatabase, $PlaylistTable> {
  $$PlaylistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listName =>
      $composableBuilder(column: $table.listName, builder: (column) => column);

  GeneratedColumn<int> get songId =>
      $composableBuilder(column: $table.songId, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);
}

class $$PlaylistTableTableManager
    extends
        RootTableManager<
          _$MusicDatabase,
          $PlaylistTable,
          PlaylistData,
          $$PlaylistTableFilterComposer,
          $$PlaylistTableOrderingComposer,
          $$PlaylistTableAnnotationComposer,
          $$PlaylistTableCreateCompanionBuilder,
          $$PlaylistTableUpdateCompanionBuilder,
          (
            PlaylistData,
            BaseReferences<_$MusicDatabase, $PlaylistTable, PlaylistData>,
          ),
          PlaylistData,
          PrefetchHooks Function()
        > {
  $$PlaylistTableTableManager(_$MusicDatabase db, $PlaylistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> listName = const Value.absent(),
                Value<int> songId = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
              }) => PlaylistCompanion(
                id: id,
                listName: listName,
                songId: songId,
                isCurrent: isCurrent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String listName,
                required int songId,
                Value<bool> isCurrent = const Value.absent(),
              }) => PlaylistCompanion.insert(
                id: id,
                listName: listName,
                songId: songId,
                isCurrent: isCurrent,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaylistTableProcessedTableManager =
    ProcessedTableManager<
      _$MusicDatabase,
      $PlaylistTable,
      PlaylistData,
      $$PlaylistTableFilterComposer,
      $$PlaylistTableOrderingComposer,
      $$PlaylistTableAnnotationComposer,
      $$PlaylistTableCreateCompanionBuilder,
      $$PlaylistTableUpdateCompanionBuilder,
      (PlaylistData, BaseReferences<_$MusicDatabase, $PlaylistTable, PlaylistData>),
      PlaylistData,
      PrefetchHooks Function()
    >;
typedef $$AlbumSongTableCreateCompanionBuilder =
    AlbumSongCompanion Function({
      required int trackOrder,
      required int trackId,
      required int albumId,
      Value<int> rowid,
    });
typedef $$AlbumSongTableUpdateCompanionBuilder =
    AlbumSongCompanion Function({
      Value<int> trackOrder,
      Value<int> trackId,
      Value<int> albumId,
      Value<int> rowid,
    });

final class $$AlbumSongTableReferences
    extends BaseReferences<_$MusicDatabase, $AlbumSongTable, AlbumSongData> {
  $$AlbumSongTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SongTable _trackIdTable(_$MusicDatabase db) => db.song.createAlias(
    $_aliasNameGenerator(db.albumSong.trackId, db.song.id),
  );

  $$SongTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<int>('track_id')!;

    final manager = $$SongTableTableManager(
      $_db,
      $_db.song,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AlbumTable _albumIdTable(_$MusicDatabase db) => db.album.createAlias(
    $_aliasNameGenerator(db.albumSong.albumId, db.album.id),
  );

  $$AlbumTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<int>('album_id')!;

    final manager = $$AlbumTableTableManager(
      $_db,
      $_db.album,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlbumSongTableFilterComposer
    extends Composer<_$MusicDatabase, $AlbumSongTable> {
  $$AlbumSongTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get trackOrder => $composableBuilder(
    column: $table.trackOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$SongTableFilterComposer get trackId {
    final $$SongTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.song,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTableFilterComposer(
            $db: $db,
            $table: $db.song,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumTableFilterComposer get albumId {
    final $$AlbumTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.album,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableFilterComposer(
            $db: $db,
            $table: $db.album,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumSongTableOrderingComposer
    extends Composer<_$MusicDatabase, $AlbumSongTable> {
  $$AlbumSongTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get trackOrder => $composableBuilder(
    column: $table.trackOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$SongTableOrderingComposer get trackId {
    final $$SongTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.song,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTableOrderingComposer(
            $db: $db,
            $table: $db.song,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumTableOrderingComposer get albumId {
    final $$AlbumTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.album,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableOrderingComposer(
            $db: $db,
            $table: $db.album,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumSongTableAnnotationComposer
    extends Composer<_$MusicDatabase, $AlbumSongTable> {
  $$AlbumSongTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get trackOrder => $composableBuilder(
    column: $table.trackOrder,
    builder: (column) => column,
  );

  $$SongTableAnnotationComposer get trackId {
    final $$SongTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.song,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SongTableAnnotationComposer(
            $db: $db,
            $table: $db.song,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AlbumTableAnnotationComposer get albumId {
    final $$AlbumTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.album,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumTableAnnotationComposer(
            $db: $db,
            $table: $db.album,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumSongTableTableManager
    extends
        RootTableManager<
          _$MusicDatabase,
          $AlbumSongTable,
          AlbumSongData,
          $$AlbumSongTableFilterComposer,
          $$AlbumSongTableOrderingComposer,
          $$AlbumSongTableAnnotationComposer,
          $$AlbumSongTableCreateCompanionBuilder,
          $$AlbumSongTableUpdateCompanionBuilder,
          (AlbumSongData, $$AlbumSongTableReferences),
          AlbumSongData,
          PrefetchHooks Function({bool trackId, bool albumId})
        > {
  $$AlbumSongTableTableManager(_$MusicDatabase db, $AlbumSongTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumSongTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumSongTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumSongTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> trackOrder = const Value.absent(),
                Value<int> trackId = const Value.absent(),
                Value<int> albumId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumSongCompanion(
                trackOrder: trackOrder,
                trackId: trackId,
                albumId: albumId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int trackOrder,
                required int trackId,
                required int albumId,
                Value<int> rowid = const Value.absent(),
              }) => AlbumSongCompanion.insert(
                trackOrder: trackOrder,
                trackId: trackId,
                albumId: albumId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumSongTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trackId = false, albumId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$AlbumSongTableReferences
                                    ._trackIdTable(db),
                                referencedColumn: $$AlbumSongTableReferences
                                    ._trackIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable: $$AlbumSongTableReferences
                                    ._albumIdTable(db),
                                referencedColumn: $$AlbumSongTableReferences
                                    ._albumIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlbumSongTableProcessedTableManager =
    ProcessedTableManager<
      _$MusicDatabase,
      $AlbumSongTable,
      AlbumSongData,
      $$AlbumSongTableFilterComposer,
      $$AlbumSongTableOrderingComposer,
      $$AlbumSongTableAnnotationComposer,
      $$AlbumSongTableCreateCompanionBuilder,
      $$AlbumSongTableUpdateCompanionBuilder,
      (AlbumSongData, $$AlbumSongTableReferences),
      AlbumSongData,
      PrefetchHooks Function({bool trackId, bool albumId})
    >;

class $DatabaseManager {
  final _$MusicDatabase _db;
  $DatabaseManager(this._db);
  $$SongTableTableManager get song => $$SongTableTableManager(_db, _db.song);
  $$AlbumTableTableManager get album =>
      $$AlbumTableTableManager(_db, _db.album);
  $$PlaylistTableTableManager get playlist =>
      $$PlaylistTableTableManager(_db, _db.playlist);
  $$AlbumSongTableTableManager get albumSong =>
      $$AlbumSongTableTableManager(_db, _db.albumSong);
}
