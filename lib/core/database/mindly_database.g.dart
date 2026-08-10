// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mindly_database.dart';

// ignore_for_file: type=lint
class $CapturesTable extends Captures with TableInfo<$CapturesTable, Capture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta(
    'rawText',
  );
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIncompleteMeta = const VerificationMeta(
    'isIncomplete',
  );
  @override
  late final GeneratedColumn<bool> isIncomplete = GeneratedColumn<bool>(
    'is_incomplete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_incomplete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mode,
    context,
    rawText,
    transcript,
    summary,
    audioPath,
    isIncomplete,
    isPinned,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'captures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Capture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(
        _rawTextMeta,
        rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('is_incomplete')) {
      context.handle(
        _isIncompleteMeta,
        isIncomplete.isAcceptableOrUnknown(
          data['is_incomplete']!,
          _isIncompleteMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Capture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Capture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      rawText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_text'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      isIncomplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_incomplete'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CapturesTable createAlias(String alias) {
    return $CapturesTable(attachedDatabase, alias);
  }
}

class Capture extends DataClass implements Insertable<Capture> {
  final String id;
  final String mode;
  final String context;
  final String? rawText;
  final String? transcript;
  final String? summary;
  final String? audioPath;
  final bool isIncomplete;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Capture({
    required this.id,
    required this.mode,
    required this.context,
    this.rawText,
    this.transcript,
    this.summary,
    this.audioPath,
    required this.isIncomplete,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mode'] = Variable<String>(mode);
    map['context'] = Variable<String>(context);
    if (!nullToAbsent || rawText != null) {
      map['raw_text'] = Variable<String>(rawText);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['is_incomplete'] = Variable<bool>(isIncomplete);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CapturesCompanion toCompanion(bool nullToAbsent) {
    return CapturesCompanion(
      id: Value(id),
      mode: Value(mode),
      context: Value(context),
      rawText: rawText == null && nullToAbsent
          ? const Value.absent()
          : Value(rawText),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      isIncomplete: Value(isIncomplete),
      isPinned: Value(isPinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Capture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Capture(
      id: serializer.fromJson<String>(json['id']),
      mode: serializer.fromJson<String>(json['mode']),
      context: serializer.fromJson<String>(json['context']),
      rawText: serializer.fromJson<String?>(json['rawText']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      summary: serializer.fromJson<String?>(json['summary']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      isIncomplete: serializer.fromJson<bool>(json['isIncomplete']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mode': serializer.toJson<String>(mode),
      'context': serializer.toJson<String>(context),
      'rawText': serializer.toJson<String?>(rawText),
      'transcript': serializer.toJson<String?>(transcript),
      'summary': serializer.toJson<String?>(summary),
      'audioPath': serializer.toJson<String?>(audioPath),
      'isIncomplete': serializer.toJson<bool>(isIncomplete),
      'isPinned': serializer.toJson<bool>(isPinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Capture copyWith({
    String? id,
    String? mode,
    String? context,
    Value<String?> rawText = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    bool? isIncomplete,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Capture(
    id: id ?? this.id,
    mode: mode ?? this.mode,
    context: context ?? this.context,
    rawText: rawText.present ? rawText.value : this.rawText,
    transcript: transcript.present ? transcript.value : this.transcript,
    summary: summary.present ? summary.value : this.summary,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    isIncomplete: isIncomplete ?? this.isIncomplete,
    isPinned: isPinned ?? this.isPinned,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Capture copyWithCompanion(CapturesCompanion data) {
    return Capture(
      id: data.id.present ? data.id.value : this.id,
      mode: data.mode.present ? data.mode.value : this.mode,
      context: data.context.present ? data.context.value : this.context,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      summary: data.summary.present ? data.summary.value : this.summary,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      isIncomplete: data.isIncomplete.present
          ? data.isIncomplete.value
          : this.isIncomplete,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Capture(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('context: $context, ')
          ..write('rawText: $rawText, ')
          ..write('transcript: $transcript, ')
          ..write('summary: $summary, ')
          ..write('audioPath: $audioPath, ')
          ..write('isIncomplete: $isIncomplete, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mode,
    context,
    rawText,
    transcript,
    summary,
    audioPath,
    isIncomplete,
    isPinned,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Capture &&
          other.id == this.id &&
          other.mode == this.mode &&
          other.context == this.context &&
          other.rawText == this.rawText &&
          other.transcript == this.transcript &&
          other.summary == this.summary &&
          other.audioPath == this.audioPath &&
          other.isIncomplete == this.isIncomplete &&
          other.isPinned == this.isPinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CapturesCompanion extends UpdateCompanion<Capture> {
  final Value<String> id;
  final Value<String> mode;
  final Value<String> context;
  final Value<String?> rawText;
  final Value<String?> transcript;
  final Value<String?> summary;
  final Value<String?> audioPath;
  final Value<bool> isIncomplete;
  final Value<bool> isPinned;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CapturesCompanion({
    this.id = const Value.absent(),
    this.mode = const Value.absent(),
    this.context = const Value.absent(),
    this.rawText = const Value.absent(),
    this.transcript = const Value.absent(),
    this.summary = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.isIncomplete = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapturesCompanion.insert({
    required String id,
    required String mode,
    required String context,
    this.rawText = const Value.absent(),
    this.transcript = const Value.absent(),
    this.summary = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.isIncomplete = const Value.absent(),
    this.isPinned = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mode = Value(mode),
       context = Value(context),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Capture> custom({
    Expression<String>? id,
    Expression<String>? mode,
    Expression<String>? context,
    Expression<String>? rawText,
    Expression<String>? transcript,
    Expression<String>? summary,
    Expression<String>? audioPath,
    Expression<bool>? isIncomplete,
    Expression<bool>? isPinned,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mode != null) 'mode': mode,
      if (context != null) 'context': context,
      if (rawText != null) 'raw_text': rawText,
      if (transcript != null) 'transcript': transcript,
      if (summary != null) 'summary': summary,
      if (audioPath != null) 'audio_path': audioPath,
      if (isIncomplete != null) 'is_incomplete': isIncomplete,
      if (isPinned != null) 'is_pinned': isPinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapturesCompanion copyWith({
    Value<String>? id,
    Value<String>? mode,
    Value<String>? context,
    Value<String?>? rawText,
    Value<String?>? transcript,
    Value<String?>? summary,
    Value<String?>? audioPath,
    Value<bool>? isIncomplete,
    Value<bool>? isPinned,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CapturesCompanion(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      context: context ?? this.context,
      rawText: rawText ?? this.rawText,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      audioPath: audioPath ?? this.audioPath,
      isIncomplete: isIncomplete ?? this.isIncomplete,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (isIncomplete.present) {
      map['is_incomplete'] = Variable<bool>(isIncomplete.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapturesCompanion(')
          ..write('id: $id, ')
          ..write('mode: $mode, ')
          ..write('context: $context, ')
          ..write('rawText: $rawText, ')
          ..write('transcript: $transcript, ')
          ..write('summary: $summary, ')
          ..write('audioPath: $audioPath, ')
          ..write('isIncomplete: $isIncomplete, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeopleTable extends People with TableInfo<$PeopleTable, PeopleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    normalizedName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeopleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeopleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeopleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class PeopleData extends DataClass implements Insertable<PeopleData> {
  final String id;
  final String displayName;
  final String normalizedName;
  final DateTime createdAt;
  const PeopleData({
    required this.id,
    required this.displayName,
    required this.normalizedName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      displayName: Value(displayName),
      normalizedName: Value(normalizedName),
      createdAt: Value(createdAt),
    );
  }

  factory PeopleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeopleData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PeopleData copyWith({
    String? id,
    String? displayName,
    String? normalizedName,
    DateTime? createdAt,
  }) => PeopleData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    normalizedName: normalizedName ?? this.normalizedName,
    createdAt: createdAt ?? this.createdAt,
  );
  PeopleData copyWithCompanion(PeopleCompanion data) {
    return PeopleData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeopleData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, normalizedName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeopleData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.normalizedName == this.normalizedName &&
          other.createdAt == this.createdAt);
}

class PeopleCompanion extends UpdateCompanion<PeopleData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> normalizedName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required String displayName,
    required String normalizedName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt);
  static Insertable<PeopleData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? normalizedName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? normalizedName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      normalizedName: normalizedName ?? this.normalizedName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicsTable extends Topics with TableInfo<$TopicsTable, Topic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedLabelMeta = const VerificationMeta(
    'normalizedLabel',
  );
  @override
  late final GeneratedColumn<String> normalizedLabel = GeneratedColumn<String>(
    'normalized_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, label, normalizedLabel, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Topic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('normalized_label')) {
      context.handle(
        _normalizedLabelMeta,
        normalizedLabel.isAcceptableOrUnknown(
          data['normalized_label']!,
          _normalizedLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedLabelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Topic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Topic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      normalizedLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TopicsTable createAlias(String alias) {
    return $TopicsTable(attachedDatabase, alias);
  }
}

class Topic extends DataClass implements Insertable<Topic> {
  final String id;
  final String label;
  final String normalizedLabel;
  final DateTime createdAt;
  const Topic({
    required this.id,
    required this.label,
    required this.normalizedLabel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['normalized_label'] = Variable<String>(normalizedLabel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      id: Value(id),
      label: Value(label),
      normalizedLabel: Value(normalizedLabel),
      createdAt: Value(createdAt),
    );
  }

  factory Topic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Topic(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      normalizedLabel: serializer.fromJson<String>(json['normalizedLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'normalizedLabel': serializer.toJson<String>(normalizedLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Topic copyWith({
    String? id,
    String? label,
    String? normalizedLabel,
    DateTime? createdAt,
  }) => Topic(
    id: id ?? this.id,
    label: label ?? this.label,
    normalizedLabel: normalizedLabel ?? this.normalizedLabel,
    createdAt: createdAt ?? this.createdAt,
  );
  Topic copyWithCompanion(TopicsCompanion data) {
    return Topic(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      normalizedLabel: data.normalizedLabel.present
          ? data.normalizedLabel.value
          : this.normalizedLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Topic(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('normalizedLabel: $normalizedLabel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, normalizedLabel, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Topic &&
          other.id == this.id &&
          other.label == this.label &&
          other.normalizedLabel == this.normalizedLabel &&
          other.createdAt == this.createdAt);
}

class TopicsCompanion extends UpdateCompanion<Topic> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> normalizedLabel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TopicsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.normalizedLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicsCompanion.insert({
    required String id,
    required String label,
    required String normalizedLabel,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       normalizedLabel = Value(normalizedLabel),
       createdAt = Value(createdAt);
  static Insertable<Topic> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? normalizedLabel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (normalizedLabel != null) 'normalized_label': normalizedLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicsCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? normalizedLabel,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TopicsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      normalizedLabel: normalizedLabel ?? this.normalizedLabel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (normalizedLabel.present) {
      map['normalized_label'] = Variable<String>(normalizedLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('normalizedLabel: $normalizedLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommitmentsTable extends Commitments
    with TableInfo<$CommitmentsTable, Commitment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _captureIdMeta = const VerificationMeta(
    'captureId',
  );
  @override
  late final GeneratedColumn<String> captureId = GeneratedColumn<String>(
    'capture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES captures (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _commitmentTextMeta = const VerificationMeta(
    'commitmentText',
  );
  @override
  late final GeneratedColumn<String> commitmentText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    captureId,
    commitmentText,
    dueDate,
    owner,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'commitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Commitment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capture_id')) {
      context.handle(
        _captureIdMeta,
        captureId.isAcceptableOrUnknown(data['capture_id']!, _captureIdMeta),
      );
    }
    if (data.containsKey('text')) {
      context.handle(
        _commitmentTextMeta,
        commitmentText.isAcceptableOrUnknown(
          data['text']!,
          _commitmentTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commitmentTextMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Commitment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Commitment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      captureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_id'],
      ),
      commitmentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      owner: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CommitmentsTable createAlias(String alias) {
    return $CommitmentsTable(attachedDatabase, alias);
  }
}

class Commitment extends DataClass implements Insertable<Commitment> {
  final String id;
  final String? captureId;
  final String commitmentText;
  final DateTime? dueDate;
  final String? owner;
  final String status;
  final DateTime createdAt;
  const Commitment({
    required this.id,
    this.captureId,
    required this.commitmentText,
    this.dueDate,
    this.owner,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || captureId != null) {
      map['capture_id'] = Variable<String>(captureId);
    }
    map['text'] = Variable<String>(commitmentText);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || owner != null) {
      map['owner'] = Variable<String>(owner);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CommitmentsCompanion toCompanion(bool nullToAbsent) {
    return CommitmentsCompanion(
      id: Value(id),
      captureId: captureId == null && nullToAbsent
          ? const Value.absent()
          : Value(captureId),
      commitmentText: Value(commitmentText),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      owner: owner == null && nullToAbsent
          ? const Value.absent()
          : Value(owner),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Commitment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Commitment(
      id: serializer.fromJson<String>(json['id']),
      captureId: serializer.fromJson<String?>(json['captureId']),
      commitmentText: serializer.fromJson<String>(json['commitmentText']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      owner: serializer.fromJson<String?>(json['owner']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'captureId': serializer.toJson<String?>(captureId),
      'commitmentText': serializer.toJson<String>(commitmentText),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'owner': serializer.toJson<String?>(owner),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Commitment copyWith({
    String? id,
    Value<String?> captureId = const Value.absent(),
    String? commitmentText,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<String?> owner = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => Commitment(
    id: id ?? this.id,
    captureId: captureId.present ? captureId.value : this.captureId,
    commitmentText: commitmentText ?? this.commitmentText,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    owner: owner.present ? owner.value : this.owner,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Commitment copyWithCompanion(CommitmentsCompanion data) {
    return Commitment(
      id: data.id.present ? data.id.value : this.id,
      captureId: data.captureId.present ? data.captureId.value : this.captureId,
      commitmentText: data.commitmentText.present
          ? data.commitmentText.value
          : this.commitmentText,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      owner: data.owner.present ? data.owner.value : this.owner,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Commitment(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('commitmentText: $commitmentText, ')
          ..write('dueDate: $dueDate, ')
          ..write('owner: $owner, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    captureId,
    commitmentText,
    dueDate,
    owner,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Commitment &&
          other.id == this.id &&
          other.captureId == this.captureId &&
          other.commitmentText == this.commitmentText &&
          other.dueDate == this.dueDate &&
          other.owner == this.owner &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class CommitmentsCompanion extends UpdateCompanion<Commitment> {
  final Value<String> id;
  final Value<String?> captureId;
  final Value<String> commitmentText;
  final Value<DateTime?> dueDate;
  final Value<String?> owner;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CommitmentsCompanion({
    this.id = const Value.absent(),
    this.captureId = const Value.absent(),
    this.commitmentText = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.owner = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommitmentsCompanion.insert({
    required String id,
    this.captureId = const Value.absent(),
    required String commitmentText,
    this.dueDate = const Value.absent(),
    this.owner = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       commitmentText = Value(commitmentText),
       createdAt = Value(createdAt);
  static Insertable<Commitment> custom({
    Expression<String>? id,
    Expression<String>? captureId,
    Expression<String>? commitmentText,
    Expression<DateTime>? dueDate,
    Expression<String>? owner,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (captureId != null) 'capture_id': captureId,
      if (commitmentText != null) 'text': commitmentText,
      if (dueDate != null) 'due_date': dueDate,
      if (owner != null) 'owner': owner,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommitmentsCompanion copyWith({
    Value<String>? id,
    Value<String?>? captureId,
    Value<String>? commitmentText,
    Value<DateTime?>? dueDate,
    Value<String?>? owner,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CommitmentsCompanion(
      id: id ?? this.id,
      captureId: captureId ?? this.captureId,
      commitmentText: commitmentText ?? this.commitmentText,
      dueDate: dueDate ?? this.dueDate,
      owner: owner ?? this.owner,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (captureId.present) {
      map['capture_id'] = Variable<String>(captureId.value);
    }
    if (commitmentText.present) {
      map['text'] = Variable<String>(commitmentText.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommitmentsCompanion(')
          ..write('id: $id, ')
          ..write('captureId: $captureId, ')
          ..write('commitmentText: $commitmentText, ')
          ..write('dueDate: $dueDate, ')
          ..write('owner: $owner, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryRelationshipsTable extends MemoryRelationships
    with TableInfo<$MemoryRelationshipsTable, MemoryRelationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromTypeMeta = const VerificationMeta(
    'fromType',
  );
  @override
  late final GeneratedColumn<String> fromType = GeneratedColumn<String>(
    'from_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationTypeMeta = const VerificationMeta(
    'relationType',
  );
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
    'relation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toTypeMeta = const VerificationMeta('toType');
  @override
  late final GeneratedColumn<String> toType = GeneratedColumn<String>(
    'to_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<String> toId = GeneratedColumn<String>(
    'to_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromType,
    fromId,
    relationType,
    toType,
    toId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryRelationship> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_type')) {
      context.handle(
        _fromTypeMeta,
        fromType.isAcceptableOrUnknown(data['from_type']!, _fromTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fromTypeMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('relation_type')) {
      context.handle(
        _relationTypeMeta,
        relationType.isAcceptableOrUnknown(
          data['relation_type']!,
          _relationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relationTypeMeta);
    }
    if (data.containsKey('to_type')) {
      context.handle(
        _toTypeMeta,
        toType.isAcceptableOrUnknown(data['to_type']!, _toTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_toTypeMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryRelationship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryRelationship(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_type'],
      )!,
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      relationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation_type'],
      )!,
      toType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_type'],
      )!,
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryRelationshipsTable createAlias(String alias) {
    return $MemoryRelationshipsTable(attachedDatabase, alias);
  }
}

class MemoryRelationship extends DataClass
    implements Insertable<MemoryRelationship> {
  final String id;
  final String fromType;
  final String fromId;
  final String relationType;
  final String toType;
  final String toId;
  final DateTime createdAt;
  const MemoryRelationship({
    required this.id,
    required this.fromType,
    required this.fromId,
    required this.relationType,
    required this.toType,
    required this.toId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_type'] = Variable<String>(fromType);
    map['from_id'] = Variable<String>(fromId);
    map['relation_type'] = Variable<String>(relationType);
    map['to_type'] = Variable<String>(toType);
    map['to_id'] = Variable<String>(toId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return MemoryRelationshipsCompanion(
      id: Value(id),
      fromType: Value(fromType),
      fromId: Value(fromId),
      relationType: Value(relationType),
      toType: Value(toType),
      toId: Value(toId),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryRelationship.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryRelationship(
      id: serializer.fromJson<String>(json['id']),
      fromType: serializer.fromJson<String>(json['fromType']),
      fromId: serializer.fromJson<String>(json['fromId']),
      relationType: serializer.fromJson<String>(json['relationType']),
      toType: serializer.fromJson<String>(json['toType']),
      toId: serializer.fromJson<String>(json['toId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromType': serializer.toJson<String>(fromType),
      'fromId': serializer.toJson<String>(fromId),
      'relationType': serializer.toJson<String>(relationType),
      'toType': serializer.toJson<String>(toType),
      'toId': serializer.toJson<String>(toId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryRelationship copyWith({
    String? id,
    String? fromType,
    String? fromId,
    String? relationType,
    String? toType,
    String? toId,
    DateTime? createdAt,
  }) => MemoryRelationship(
    id: id ?? this.id,
    fromType: fromType ?? this.fromType,
    fromId: fromId ?? this.fromId,
    relationType: relationType ?? this.relationType,
    toType: toType ?? this.toType,
    toId: toId ?? this.toId,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryRelationship copyWithCompanion(MemoryRelationshipsCompanion data) {
    return MemoryRelationship(
      id: data.id.present ? data.id.value : this.id,
      fromType: data.fromType.present ? data.fromType.value : this.fromType,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      toType: data.toType.present ? data.toType.value : this.toType,
      toId: data.toId.present ? data.toId.value : this.toId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRelationship(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('relationType: $relationType, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromType, fromId, relationType, toType, toId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryRelationship &&
          other.id == this.id &&
          other.fromType == this.fromType &&
          other.fromId == this.fromId &&
          other.relationType == this.relationType &&
          other.toType == this.toType &&
          other.toId == this.toId &&
          other.createdAt == this.createdAt);
}

class MemoryRelationshipsCompanion extends UpdateCompanion<MemoryRelationship> {
  final Value<String> id;
  final Value<String> fromType;
  final Value<String> fromId;
  final Value<String> relationType;
  final Value<String> toType;
  final Value<String> toId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryRelationshipsCompanion({
    this.id = const Value.absent(),
    this.fromType = const Value.absent(),
    this.fromId = const Value.absent(),
    this.relationType = const Value.absent(),
    this.toType = const Value.absent(),
    this.toId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryRelationshipsCompanion.insert({
    required String id,
    required String fromType,
    required String fromId,
    required String relationType,
    required String toType,
    required String toId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromType = Value(fromType),
       fromId = Value(fromId),
       relationType = Value(relationType),
       toType = Value(toType),
       toId = Value(toId),
       createdAt = Value(createdAt);
  static Insertable<MemoryRelationship> custom({
    Expression<String>? id,
    Expression<String>? fromType,
    Expression<String>? fromId,
    Expression<String>? relationType,
    Expression<String>? toType,
    Expression<String>? toId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromType != null) 'from_type': fromType,
      if (fromId != null) 'from_id': fromId,
      if (relationType != null) 'relation_type': relationType,
      if (toType != null) 'to_type': toType,
      if (toId != null) 'to_id': toId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryRelationshipsCompanion copyWith({
    Value<String>? id,
    Value<String>? fromType,
    Value<String>? fromId,
    Value<String>? relationType,
    Value<String>? toType,
    Value<String>? toId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryRelationshipsCompanion(
      id: id ?? this.id,
      fromType: fromType ?? this.fromType,
      fromId: fromId ?? this.fromId,
      relationType: relationType ?? this.relationType,
      toType: toType ?? this.toType,
      toId: toId ?? this.toId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromType.present) {
      map['from_type'] = Variable<String>(fromType.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (toType.present) {
      map['to_type'] = Variable<String>(toType.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<String>(toId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('relationType: $relationType, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryEmbeddingsTable extends MemoryEmbeddings
    with TableInfo<$MemoryEmbeddingsTable, MemoryEmbedding> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryEmbeddingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<int> dimensions = GeneratedColumn<int>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerType,
    ownerId,
    model,
    dimensions,
    vector,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoryEmbedding> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionsMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ownerType, ownerId, model},
  ];
  @override
  MemoryEmbedding map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryEmbedding(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimensions'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemoryEmbeddingsTable createAlias(String alias) {
    return $MemoryEmbeddingsTable(attachedDatabase, alias);
  }
}

class MemoryEmbedding extends DataClass implements Insertable<MemoryEmbedding> {
  final String id;
  final String ownerType;
  final String ownerId;
  final String model;
  final int dimensions;
  final Uint8List vector;
  final DateTime createdAt;
  const MemoryEmbedding({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.model,
    required this.dimensions,
    required this.vector,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['model'] = Variable<String>(model);
    map['dimensions'] = Variable<int>(dimensions);
    map['vector'] = Variable<Uint8List>(vector);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemoryEmbeddingsCompanion toCompanion(bool nullToAbsent) {
    return MemoryEmbeddingsCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      model: Value(model),
      dimensions: Value(dimensions),
      vector: Value(vector),
      createdAt: Value(createdAt),
    );
  }

  factory MemoryEmbedding.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryEmbedding(
      id: serializer.fromJson<String>(json['id']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      model: serializer.fromJson<String>(json['model']),
      dimensions: serializer.fromJson<int>(json['dimensions']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'model': serializer.toJson<String>(model),
      'dimensions': serializer.toJson<int>(dimensions),
      'vector': serializer.toJson<Uint8List>(vector),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemoryEmbedding copyWith({
    String? id,
    String? ownerType,
    String? ownerId,
    String? model,
    int? dimensions,
    Uint8List? vector,
    DateTime? createdAt,
  }) => MemoryEmbedding(
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    model: model ?? this.model,
    dimensions: dimensions ?? this.dimensions,
    vector: vector ?? this.vector,
    createdAt: createdAt ?? this.createdAt,
  );
  MemoryEmbedding copyWithCompanion(MemoryEmbeddingsCompanion data) {
    return MemoryEmbedding(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      model: data.model.present ? data.model.value : this.model,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      vector: data.vector.present ? data.vector.value : this.vector,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEmbedding(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('model: $model, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerType,
    ownerId,
    model,
    dimensions,
    $driftBlobEquality.hash(vector),
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryEmbedding &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.model == this.model &&
          other.dimensions == this.dimensions &&
          $driftBlobEquality.equals(other.vector, this.vector) &&
          other.createdAt == this.createdAt);
}

class MemoryEmbeddingsCompanion extends UpdateCompanion<MemoryEmbedding> {
  final Value<String> id;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String> model;
  final Value<int> dimensions;
  final Value<Uint8List> vector;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemoryEmbeddingsCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.model = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.vector = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryEmbeddingsCompanion.insert({
    required String id,
    required String ownerType,
    required String ownerId,
    required String model,
    required int dimensions,
    required Uint8List vector,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       model = Value(model),
       dimensions = Value(dimensions),
       vector = Value(vector),
       createdAt = Value(createdAt);
  static Insertable<MemoryEmbedding> custom({
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? model,
    Expression<int>? dimensions,
    Expression<Uint8List>? vector,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (model != null) 'model': model,
      if (dimensions != null) 'dimensions': dimensions,
      if (vector != null) 'vector': vector,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryEmbeddingsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<String>? model,
    Value<int>? dimensions,
    Value<Uint8List>? vector,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemoryEmbeddingsCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      model: model ?? this.model,
      dimensions: dimensions ?? this.dimensions,
      vector: vector ?? this.vector,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<int>(dimensions.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryEmbeddingsCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('model: $model, ')
          ..write('dimensions: $dimensions, ')
          ..write('vector: $vector, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MindlyDatabase extends GeneratedDatabase {
  _$MindlyDatabase(QueryExecutor e) : super(e);
  $MindlyDatabaseManager get managers => $MindlyDatabaseManager(this);
  late final $CapturesTable captures = $CapturesTable(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $TopicsTable topics = $TopicsTable(this);
  late final $CommitmentsTable commitments = $CommitmentsTable(this);
  late final $MemoryRelationshipsTable memoryRelationships =
      $MemoryRelationshipsTable(this);
  late final $MemoryEmbeddingsTable memoryEmbeddings = $MemoryEmbeddingsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    captures,
    people,
    topics,
    commitments,
    memoryRelationships,
    memoryEmbeddings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'captures',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('commitments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CapturesTableCreateCompanionBuilder =
    CapturesCompanion Function({
      required String id,
      required String mode,
      required String context,
      Value<String?> rawText,
      Value<String?> transcript,
      Value<String?> summary,
      Value<String?> audioPath,
      Value<bool> isIncomplete,
      Value<bool> isPinned,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CapturesTableUpdateCompanionBuilder =
    CapturesCompanion Function({
      Value<String> id,
      Value<String> mode,
      Value<String> context,
      Value<String?> rawText,
      Value<String?> transcript,
      Value<String?> summary,
      Value<String?> audioPath,
      Value<bool> isIncomplete,
      Value<bool> isPinned,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CapturesTableReferences
    extends BaseReferences<_$MindlyDatabase, $CapturesTable, Capture> {
  $$CapturesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CommitmentsTable, List<Commitment>>
  _commitmentsRefsTable(_$MindlyDatabase db) => MultiTypedResultKey.fromTable(
    db.commitments,
    aliasName: 'captures__id__commitments__capture_id',
  );

  $$CommitmentsTableProcessedTableManager get commitmentsRefs {
    final manager = $$CommitmentsTableTableManager(
      $_db,
      $_db.commitments,
    ).filter((f) => f.captureId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_commitmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CapturesTableFilterComposer
    extends Composer<_$MindlyDatabase, $CapturesTable> {
  $$CapturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncomplete => $composableBuilder(
    column: $table.isIncomplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> commitmentsRefs(
    Expression<bool> Function($$CommitmentsTableFilterComposer f) f,
  ) {
    final $$CommitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.captureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableFilterComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CapturesTableOrderingComposer
    extends Composer<_$MindlyDatabase, $CapturesTable> {
  $$CapturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawText => $composableBuilder(
    column: $table.rawText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncomplete => $composableBuilder(
    column: $table.isIncomplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapturesTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $CapturesTable> {
  $$CapturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<bool> get isIncomplete => $composableBuilder(
    column: $table.isIncomplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> commitmentsRefs<T extends Object>(
    Expression<T> Function($$CommitmentsTableAnnotationComposer a) f,
  ) {
    final $$CommitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.commitments,
      getReferencedColumn: (t) => t.captureId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CommitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.commitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CapturesTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $CapturesTable,
          Capture,
          $$CapturesTableFilterComposer,
          $$CapturesTableOrderingComposer,
          $$CapturesTableAnnotationComposer,
          $$CapturesTableCreateCompanionBuilder,
          $$CapturesTableUpdateCompanionBuilder,
          (Capture, $$CapturesTableReferences),
          Capture,
          PrefetchHooks Function({bool commitmentsRefs})
        > {
  $$CapturesTableTableManager(_$MindlyDatabase db, $CapturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<String?> rawText = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> isIncomplete = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapturesCompanion(
                id: id,
                mode: mode,
                context: context,
                rawText: rawText,
                transcript: transcript,
                summary: summary,
                audioPath: audioPath,
                isIncomplete: isIncomplete,
                isPinned: isPinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mode,
                required String context,
                Value<String?> rawText = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<bool> isIncomplete = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CapturesCompanion.insert(
                id: id,
                mode: mode,
                context: context,
                rawText: rawText,
                transcript: transcript,
                summary: summary,
                audioPath: audioPath,
                isIncomplete: isIncomplete,
                isPinned: isPinned,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CapturesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({commitmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (commitmentsRefs) db.commitments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (commitmentsRefs)
                    await $_getPrefetchedData<
                      Capture,
                      $CapturesTable,
                      Commitment
                    >(
                      currentTable: table,
                      referencedTable: $$CapturesTableReferences
                          ._commitmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$CapturesTableReferences(
                        db,
                        table,
                        p0,
                      ).commitmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.captureId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CapturesTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $CapturesTable,
      Capture,
      $$CapturesTableFilterComposer,
      $$CapturesTableOrderingComposer,
      $$CapturesTableAnnotationComposer,
      $$CapturesTableCreateCompanionBuilder,
      $$CapturesTableUpdateCompanionBuilder,
      (Capture, $$CapturesTableReferences),
      Capture,
      PrefetchHooks Function({bool commitmentsRefs})
    >;
typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      required String id,
      required String displayName,
      required String normalizedName,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String> normalizedName,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PeopleTableFilterComposer
    extends Composer<_$MindlyDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeopleTableOrderingComposer
    extends Composer<_$MindlyDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $PeopleTable,
          PeopleData,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (
            PeopleData,
            BaseReferences<_$MindlyDatabase, $PeopleTable, PeopleData>,
          ),
          PeopleData,
          PrefetchHooks Function()
        > {
  $$PeopleTableTableManager(_$MindlyDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                displayName: displayName,
                normalizedName: normalizedName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String normalizedName,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                displayName: displayName,
                normalizedName: normalizedName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $PeopleTable,
      PeopleData,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (PeopleData, BaseReferences<_$MindlyDatabase, $PeopleTable, PeopleData>),
      PeopleData,
      PrefetchHooks Function()
    >;
typedef $$TopicsTableCreateCompanionBuilder =
    TopicsCompanion Function({
      required String id,
      required String label,
      required String normalizedLabel,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TopicsTableUpdateCompanionBuilder =
    TopicsCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> normalizedLabel,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TopicsTableFilterComposer
    extends Composer<_$MindlyDatabase, $TopicsTable> {
  $$TopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedLabel => $composableBuilder(
    column: $table.normalizedLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TopicsTableOrderingComposer
    extends Composer<_$MindlyDatabase, $TopicsTable> {
  $$TopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedLabel => $composableBuilder(
    column: $table.normalizedLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TopicsTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $TopicsTable> {
  $$TopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get normalizedLabel => $composableBuilder(
    column: $table.normalizedLabel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TopicsTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $TopicsTable,
          Topic,
          $$TopicsTableFilterComposer,
          $$TopicsTableOrderingComposer,
          $$TopicsTableAnnotationComposer,
          $$TopicsTableCreateCompanionBuilder,
          $$TopicsTableUpdateCompanionBuilder,
          (Topic, BaseReferences<_$MindlyDatabase, $TopicsTable, Topic>),
          Topic,
          PrefetchHooks Function()
        > {
  $$TopicsTableTableManager(_$MindlyDatabase db, $TopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> normalizedLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion(
                id: id,
                label: label,
                normalizedLabel: normalizedLabel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                required String normalizedLabel,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion.insert(
                id: id,
                label: label,
                normalizedLabel: normalizedLabel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $TopicsTable,
      Topic,
      $$TopicsTableFilterComposer,
      $$TopicsTableOrderingComposer,
      $$TopicsTableAnnotationComposer,
      $$TopicsTableCreateCompanionBuilder,
      $$TopicsTableUpdateCompanionBuilder,
      (Topic, BaseReferences<_$MindlyDatabase, $TopicsTable, Topic>),
      Topic,
      PrefetchHooks Function()
    >;
typedef $$CommitmentsTableCreateCompanionBuilder =
    CommitmentsCompanion Function({
      required String id,
      Value<String?> captureId,
      required String commitmentText,
      Value<DateTime?> dueDate,
      Value<String?> owner,
      Value<String> status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CommitmentsTableUpdateCompanionBuilder =
    CommitmentsCompanion Function({
      Value<String> id,
      Value<String?> captureId,
      Value<String> commitmentText,
      Value<DateTime?> dueDate,
      Value<String?> owner,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CommitmentsTableReferences
    extends BaseReferences<_$MindlyDatabase, $CommitmentsTable, Commitment> {
  $$CommitmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CapturesTable _captureIdTable(_$MindlyDatabase db) =>
      db.captures.createAlias('commitments__capture_id__captures__id');

  $$CapturesTableProcessedTableManager? get captureId {
    final $_column = $_itemColumn<String>('capture_id');
    if ($_column == null) return null;
    final manager = $$CapturesTableTableManager(
      $_db,
      $_db.captures,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_captureIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CommitmentsTableFilterComposer
    extends Composer<_$MindlyDatabase, $CommitmentsTable> {
  $$CommitmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commitmentText => $composableBuilder(
    column: $table.commitmentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CapturesTableFilterComposer get captureId {
    final $$CapturesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.captureId,
      referencedTable: $db.captures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturesTableFilterComposer(
            $db: $db,
            $table: $db.captures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentsTableOrderingComposer
    extends Composer<_$MindlyDatabase, $CommitmentsTable> {
  $$CommitmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commitmentText => $composableBuilder(
    column: $table.commitmentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CapturesTableOrderingComposer get captureId {
    final $$CapturesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.captureId,
      referencedTable: $db.captures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturesTableOrderingComposer(
            $db: $db,
            $table: $db.captures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentsTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $CommitmentsTable> {
  $$CommitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commitmentText => $composableBuilder(
    column: $table.commitmentText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CapturesTableAnnotationComposer get captureId {
    final $$CapturesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.captureId,
      referencedTable: $db.captures,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapturesTableAnnotationComposer(
            $db: $db,
            $table: $db.captures,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CommitmentsTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $CommitmentsTable,
          Commitment,
          $$CommitmentsTableFilterComposer,
          $$CommitmentsTableOrderingComposer,
          $$CommitmentsTableAnnotationComposer,
          $$CommitmentsTableCreateCompanionBuilder,
          $$CommitmentsTableUpdateCompanionBuilder,
          (Commitment, $$CommitmentsTableReferences),
          Commitment,
          PrefetchHooks Function({bool captureId})
        > {
  $$CommitmentsTableTableManager(_$MindlyDatabase db, $CommitmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommitmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> captureId = const Value.absent(),
                Value<String> commitmentText = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> owner = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion(
                id: id,
                captureId: captureId,
                commitmentText: commitmentText,
                dueDate: dueDate,
                owner: owner,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> captureId = const Value.absent(),
                required String commitmentText,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String?> owner = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CommitmentsCompanion.insert(
                id: id,
                captureId: captureId,
                commitmentText: commitmentText,
                dueDate: dueDate,
                owner: owner,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CommitmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({captureId = false}) {
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
                    if (captureId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.captureId,
                                referencedTable: $$CommitmentsTableReferences
                                    ._captureIdTable(db),
                                referencedColumn: $$CommitmentsTableReferences
                                    ._captureIdTable(db)
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

typedef $$CommitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $CommitmentsTable,
      Commitment,
      $$CommitmentsTableFilterComposer,
      $$CommitmentsTableOrderingComposer,
      $$CommitmentsTableAnnotationComposer,
      $$CommitmentsTableCreateCompanionBuilder,
      $$CommitmentsTableUpdateCompanionBuilder,
      (Commitment, $$CommitmentsTableReferences),
      Commitment,
      PrefetchHooks Function({bool captureId})
    >;
typedef $$MemoryRelationshipsTableCreateCompanionBuilder =
    MemoryRelationshipsCompanion Function({
      required String id,
      required String fromType,
      required String fromId,
      required String relationType,
      required String toType,
      required String toId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryRelationshipsTableUpdateCompanionBuilder =
    MemoryRelationshipsCompanion Function({
      Value<String> id,
      Value<String> fromType,
      Value<String> fromId,
      Value<String> relationType,
      Value<String> toType,
      Value<String> toId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MemoryRelationshipsTableFilterComposer
    extends Composer<_$MindlyDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryRelationshipsTableOrderingComposer
    extends Composer<_$MindlyDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryRelationshipsTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $MemoryRelationshipsTable> {
  $$MemoryRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromType =>
      $composableBuilder(column: $table.fromType, builder: (column) => column);

  GeneratedColumn<String> get fromId =>
      $composableBuilder(column: $table.fromId, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
    column: $table.relationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toType =>
      $composableBuilder(column: $table.toType, builder: (column) => column);

  GeneratedColumn<String> get toId =>
      $composableBuilder(column: $table.toId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MemoryRelationshipsTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $MemoryRelationshipsTable,
          MemoryRelationship,
          $$MemoryRelationshipsTableFilterComposer,
          $$MemoryRelationshipsTableOrderingComposer,
          $$MemoryRelationshipsTableAnnotationComposer,
          $$MemoryRelationshipsTableCreateCompanionBuilder,
          $$MemoryRelationshipsTableUpdateCompanionBuilder,
          (
            MemoryRelationship,
            BaseReferences<
              _$MindlyDatabase,
              $MemoryRelationshipsTable,
              MemoryRelationship
            >,
          ),
          MemoryRelationship,
          PrefetchHooks Function()
        > {
  $$MemoryRelationshipsTableTableManager(
    _$MindlyDatabase db,
    $MemoryRelationshipsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryRelationshipsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MemoryRelationshipsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromType = const Value.absent(),
                Value<String> fromId = const Value.absent(),
                Value<String> relationType = const Value.absent(),
                Value<String> toType = const Value.absent(),
                Value<String> toId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryRelationshipsCompanion(
                id: id,
                fromType: fromType,
                fromId: fromId,
                relationType: relationType,
                toType: toType,
                toId: toId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromType,
                required String fromId,
                required String relationType,
                required String toType,
                required String toId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryRelationshipsCompanion.insert(
                id: id,
                fromType: fromType,
                fromId: fromId,
                relationType: relationType,
                toType: toType,
                toId: toId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryRelationshipsTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $MemoryRelationshipsTable,
      MemoryRelationship,
      $$MemoryRelationshipsTableFilterComposer,
      $$MemoryRelationshipsTableOrderingComposer,
      $$MemoryRelationshipsTableAnnotationComposer,
      $$MemoryRelationshipsTableCreateCompanionBuilder,
      $$MemoryRelationshipsTableUpdateCompanionBuilder,
      (
        MemoryRelationship,
        BaseReferences<
          _$MindlyDatabase,
          $MemoryRelationshipsTable,
          MemoryRelationship
        >,
      ),
      MemoryRelationship,
      PrefetchHooks Function()
    >;
typedef $$MemoryEmbeddingsTableCreateCompanionBuilder =
    MemoryEmbeddingsCompanion Function({
      required String id,
      required String ownerType,
      required String ownerId,
      required String model,
      required int dimensions,
      required Uint8List vector,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MemoryEmbeddingsTableUpdateCompanionBuilder =
    MemoryEmbeddingsCompanion Function({
      Value<String> id,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<String> model,
      Value<int> dimensions,
      Value<Uint8List> vector,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MemoryEmbeddingsTableFilterComposer
    extends Composer<_$MindlyDatabase, $MemoryEmbeddingsTable> {
  $$MemoryEmbeddingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoryEmbeddingsTableOrderingComposer
    extends Composer<_$MindlyDatabase, $MemoryEmbeddingsTable> {
  $$MemoryEmbeddingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoryEmbeddingsTableAnnotationComposer
    extends Composer<_$MindlyDatabase, $MemoryEmbeddingsTable> {
  $$MemoryEmbeddingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MemoryEmbeddingsTableTableManager
    extends
        RootTableManager<
          _$MindlyDatabase,
          $MemoryEmbeddingsTable,
          MemoryEmbedding,
          $$MemoryEmbeddingsTableFilterComposer,
          $$MemoryEmbeddingsTableOrderingComposer,
          $$MemoryEmbeddingsTableAnnotationComposer,
          $$MemoryEmbeddingsTableCreateCompanionBuilder,
          $$MemoryEmbeddingsTableUpdateCompanionBuilder,
          (
            MemoryEmbedding,
            BaseReferences<
              _$MindlyDatabase,
              $MemoryEmbeddingsTable,
              MemoryEmbedding
            >,
          ),
          MemoryEmbedding,
          PrefetchHooks Function()
        > {
  $$MemoryEmbeddingsTableTableManager(
    _$MindlyDatabase db,
    $MemoryEmbeddingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryEmbeddingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryEmbeddingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryEmbeddingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> dimensions = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoryEmbeddingsCompanion(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                model: model,
                dimensions: dimensions,
                vector: vector,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerType,
                required String ownerId,
                required String model,
                required int dimensions,
                required Uint8List vector,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoryEmbeddingsCompanion.insert(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                model: model,
                dimensions: dimensions,
                vector: vector,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoryEmbeddingsTableProcessedTableManager =
    ProcessedTableManager<
      _$MindlyDatabase,
      $MemoryEmbeddingsTable,
      MemoryEmbedding,
      $$MemoryEmbeddingsTableFilterComposer,
      $$MemoryEmbeddingsTableOrderingComposer,
      $$MemoryEmbeddingsTableAnnotationComposer,
      $$MemoryEmbeddingsTableCreateCompanionBuilder,
      $$MemoryEmbeddingsTableUpdateCompanionBuilder,
      (
        MemoryEmbedding,
        BaseReferences<
          _$MindlyDatabase,
          $MemoryEmbeddingsTable,
          MemoryEmbedding
        >,
      ),
      MemoryEmbedding,
      PrefetchHooks Function()
    >;

class $MindlyDatabaseManager {
  final _$MindlyDatabase _db;
  $MindlyDatabaseManager(this._db);
  $$CapturesTableTableManager get captures =>
      $$CapturesTableTableManager(_db, _db.captures);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$TopicsTableTableManager get topics =>
      $$TopicsTableTableManager(_db, _db.topics);
  $$CommitmentsTableTableManager get commitments =>
      $$CommitmentsTableTableManager(_db, _db.commitments);
  $$MemoryRelationshipsTableTableManager get memoryRelationships =>
      $$MemoryRelationshipsTableTableManager(_db, _db.memoryRelationships);
  $$MemoryEmbeddingsTableTableManager get memoryEmbeddings =>
      $$MemoryEmbeddingsTableTableManager(_db, _db.memoryEmbeddings);
}
