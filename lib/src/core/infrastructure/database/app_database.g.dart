// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MealEntriesTable extends MealEntries
    with TableInfo<$MealEntriesTable, MealEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _occurredOffsetMinutesMeta =
      const VerificationMeta('occurredOffsetMinutes');
  @override
  late final GeneratedColumn<int> occurredOffsetMinutes = GeneratedColumn<int>(
    'occurred_offset_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerIdMeta = const VerificationMeta(
    'providerId',
  );
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
    'provider_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analyzedAtUtcMeta = const VerificationMeta(
    'analyzedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> analyzedAtUtc =
      GeneratedColumn<DateTime>(
        'analyzed_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _detectedLocaleMeta = const VerificationMeta(
    'detectedLocale',
  );
  @override
  late final GeneratedColumn<String> detectedLocale = GeneratedColumn<String>(
    'detected_locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assumptionsJsonMeta = const VerificationMeta(
    'assumptionsJson',
  );
  @override
  late final GeneratedColumn<String> assumptionsJson = GeneratedColumn<String>(
    'assumptions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userEditedMeta = const VerificationMeta(
    'userEdited',
  );
  @override
  late final GeneratedColumn<bool> userEdited = GeneratedColumn<bool>(
    'user_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("user_edited" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAtUtc = GeneratedColumn<DateTime>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    occurredAtUtc,
    occurredOffsetMinutes,
    description,
    providerId,
    modelId,
    analyzedAtUtc,
    detectedLocale,
    confidence,
    assumptionsJson,
    userEdited,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    if (data.containsKey('occurred_offset_minutes')) {
      context.handle(
        _occurredOffsetMinutesMeta,
        occurredOffsetMinutes.isAcceptableOrUnknown(
          data['occurred_offset_minutes']!,
          _occurredOffsetMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredOffsetMinutesMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('provider_id')) {
      context.handle(
        _providerIdMeta,
        providerId.isAcceptableOrUnknown(data['provider_id']!, _providerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('analyzed_at_utc')) {
      context.handle(
        _analyzedAtUtcMeta,
        analyzedAtUtc.isAcceptableOrUnknown(
          data['analyzed_at_utc']!,
          _analyzedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_analyzedAtUtcMeta);
    }
    if (data.containsKey('detected_locale')) {
      context.handle(
        _detectedLocaleMeta,
        detectedLocale.isAcceptableOrUnknown(
          data['detected_locale']!,
          _detectedLocaleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedLocaleMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('assumptions_json')) {
      context.handle(
        _assumptionsJsonMeta,
        assumptionsJson.isAcceptableOrUnknown(
          data['assumptions_json']!,
          _assumptionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsJsonMeta);
    }
    if (data.containsKey('user_edited')) {
      context.handle(
        _userEditedMeta,
        userEdited.isAcceptableOrUnknown(data['user_edited']!, _userEditedMeta),
      );
    } else if (isInserting) {
      context.missing(_userEditedMeta);
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
      occurredOffsetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_offset_minutes'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      providerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      analyzedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}analyzed_at_utc'],
      )!,
      detectedLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_locale'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      assumptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions_json'],
      )!,
      userEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_edited'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at_utc'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $MealEntriesTable createAlias(String alias) {
    return $MealEntriesTable(attachedDatabase, alias);
  }
}

class MealEntryRow extends DataClass implements Insertable<MealEntryRow> {
  final String id;
  final DateTime occurredAtUtc;
  final int occurredOffsetMinutes;
  final String? description;
  final String providerId;
  final String modelId;
  final DateTime analyzedAtUtc;
  final String detectedLocale;
  final String confidence;
  final String assumptionsJson;
  final bool userEdited;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;
  final int revision;
  const MealEntryRow({
    required this.id,
    required this.occurredAtUtc,
    required this.occurredOffsetMinutes,
    this.description,
    required this.providerId,
    required this.modelId,
    required this.analyzedAtUtc,
    required this.detectedLocale,
    required this.confidence,
    required this.assumptionsJson,
    required this.userEdited,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    map['occurred_offset_minutes'] = Variable<int>(occurredOffsetMinutes);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['provider_id'] = Variable<String>(providerId);
    map['model_id'] = Variable<String>(modelId);
    map['analyzed_at_utc'] = Variable<DateTime>(analyzedAtUtc);
    map['detected_locale'] = Variable<String>(detectedLocale);
    map['confidence'] = Variable<String>(confidence);
    map['assumptions_json'] = Variable<String>(assumptionsJson);
    map['user_edited'] = Variable<bool>(userEdited);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc);
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  MealEntriesCompanion toCompanion(bool nullToAbsent) {
    return MealEntriesCompanion(
      id: Value(id),
      occurredAtUtc: Value(occurredAtUtc),
      occurredOffsetMinutes: Value(occurredOffsetMinutes),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      providerId: Value(providerId),
      modelId: Value(modelId),
      analyzedAtUtc: Value(analyzedAtUtc),
      detectedLocale: Value(detectedLocale),
      confidence: Value(confidence),
      assumptionsJson: Value(assumptionsJson),
      userEdited: Value(userEdited),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
      revision: Value(revision),
    );
  }

  factory MealEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntryRow(
      id: serializer.fromJson<String>(json['id']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
      occurredOffsetMinutes: serializer.fromJson<int>(
        json['occurredOffsetMinutes'],
      ),
      description: serializer.fromJson<String?>(json['description']),
      providerId: serializer.fromJson<String>(json['providerId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      analyzedAtUtc: serializer.fromJson<DateTime>(json['analyzedAtUtc']),
      detectedLocale: serializer.fromJson<String>(json['detectedLocale']),
      confidence: serializer.fromJson<String>(json['confidence']),
      assumptionsJson: serializer.fromJson<String>(json['assumptionsJson']),
      userEdited: serializer.fromJson<bool>(json['userEdited']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      deletedAtUtc: serializer.fromJson<DateTime?>(json['deletedAtUtc']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
      'occurredOffsetMinutes': serializer.toJson<int>(occurredOffsetMinutes),
      'description': serializer.toJson<String?>(description),
      'providerId': serializer.toJson<String>(providerId),
      'modelId': serializer.toJson<String>(modelId),
      'analyzedAtUtc': serializer.toJson<DateTime>(analyzedAtUtc),
      'detectedLocale': serializer.toJson<String>(detectedLocale),
      'confidence': serializer.toJson<String>(confidence),
      'assumptionsJson': serializer.toJson<String>(assumptionsJson),
      'userEdited': serializer.toJson<bool>(userEdited),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'deletedAtUtc': serializer.toJson<DateTime?>(deletedAtUtc),
      'revision': serializer.toJson<int>(revision),
    };
  }

  MealEntryRow copyWith({
    String? id,
    DateTime? occurredAtUtc,
    int? occurredOffsetMinutes,
    Value<String?> description = const Value.absent(),
    String? providerId,
    String? modelId,
    DateTime? analyzedAtUtc,
    String? detectedLocale,
    String? confidence,
    String? assumptionsJson,
    bool? userEdited,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> deletedAtUtc = const Value.absent(),
    int? revision,
  }) => MealEntryRow(
    id: id ?? this.id,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
    occurredOffsetMinutes: occurredOffsetMinutes ?? this.occurredOffsetMinutes,
    description: description.present ? description.value : this.description,
    providerId: providerId ?? this.providerId,
    modelId: modelId ?? this.modelId,
    analyzedAtUtc: analyzedAtUtc ?? this.analyzedAtUtc,
    detectedLocale: detectedLocale ?? this.detectedLocale,
    confidence: confidence ?? this.confidence,
    assumptionsJson: assumptionsJson ?? this.assumptionsJson,
    userEdited: userEdited ?? this.userEdited,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
    revision: revision ?? this.revision,
  );
  MealEntryRow copyWithCompanion(MealEntriesCompanion data) {
    return MealEntryRow(
      id: data.id.present ? data.id.value : this.id,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
      occurredOffsetMinutes: data.occurredOffsetMinutes.present
          ? data.occurredOffsetMinutes.value
          : this.occurredOffsetMinutes,
      description: data.description.present
          ? data.description.value
          : this.description,
      providerId: data.providerId.present
          ? data.providerId.value
          : this.providerId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      analyzedAtUtc: data.analyzedAtUtc.present
          ? data.analyzedAtUtc.value
          : this.analyzedAtUtc,
      detectedLocale: data.detectedLocale.present
          ? data.detectedLocale.value
          : this.detectedLocale,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      assumptionsJson: data.assumptionsJson.present
          ? data.assumptionsJson.value
          : this.assumptionsJson,
      userEdited: data.userEdited.present
          ? data.userEdited.value
          : this.userEdited,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryRow(')
          ..write('id: $id, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('occurredOffsetMinutes: $occurredOffsetMinutes, ')
          ..write('description: $description, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('analyzedAtUtc: $analyzedAtUtc, ')
          ..write('detectedLocale: $detectedLocale, ')
          ..write('confidence: $confidence, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('userEdited: $userEdited, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    occurredAtUtc,
    occurredOffsetMinutes,
    description,
    providerId,
    modelId,
    analyzedAtUtc,
    detectedLocale,
    confidence,
    assumptionsJson,
    userEdited,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntryRow &&
          other.id == this.id &&
          other.occurredAtUtc == this.occurredAtUtc &&
          other.occurredOffsetMinutes == this.occurredOffsetMinutes &&
          other.description == this.description &&
          other.providerId == this.providerId &&
          other.modelId == this.modelId &&
          other.analyzedAtUtc == this.analyzedAtUtc &&
          other.detectedLocale == this.detectedLocale &&
          other.confidence == this.confidence &&
          other.assumptionsJson == this.assumptionsJson &&
          other.userEdited == this.userEdited &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc &&
          other.revision == this.revision);
}

class MealEntriesCompanion extends UpdateCompanion<MealEntryRow> {
  final Value<String> id;
  final Value<DateTime> occurredAtUtc;
  final Value<int> occurredOffsetMinutes;
  final Value<String?> description;
  final Value<String> providerId;
  final Value<String> modelId;
  final Value<DateTime> analyzedAtUtc;
  final Value<String> detectedLocale;
  final Value<String> confidence;
  final Value<String> assumptionsJson;
  final Value<bool> userEdited;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> deletedAtUtc;
  final Value<int> revision;
  final Value<int> rowid;
  const MealEntriesCompanion({
    this.id = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.occurredOffsetMinutes = const Value.absent(),
    this.description = const Value.absent(),
    this.providerId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.analyzedAtUtc = const Value.absent(),
    this.detectedLocale = const Value.absent(),
    this.confidence = const Value.absent(),
    this.assumptionsJson = const Value.absent(),
    this.userEdited = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEntriesCompanion.insert({
    required String id,
    required DateTime occurredAtUtc,
    required int occurredOffsetMinutes,
    this.description = const Value.absent(),
    required String providerId,
    required String modelId,
    required DateTime analyzedAtUtc,
    required String detectedLocale,
    required String confidence,
    required String assumptionsJson,
    required bool userEdited,
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.deletedAtUtc = const Value.absent(),
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurredAtUtc = Value(occurredAtUtc),
       occurredOffsetMinutes = Value(occurredOffsetMinutes),
       providerId = Value(providerId),
       modelId = Value(modelId),
       analyzedAtUtc = Value(analyzedAtUtc),
       detectedLocale = Value(detectedLocale),
       confidence = Value(confidence),
       assumptionsJson = Value(assumptionsJson),
       userEdited = Value(userEdited),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc),
       revision = Value(revision);
  static Insertable<MealEntryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? occurredOffsetMinutes,
    Expression<String>? description,
    Expression<String>? providerId,
    Expression<String>? modelId,
    Expression<DateTime>? analyzedAtUtc,
    Expression<String>? detectedLocale,
    Expression<String>? confidence,
    Expression<String>? assumptionsJson,
    Expression<bool>? userEdited,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? deletedAtUtc,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (occurredOffsetMinutes != null)
        'occurred_offset_minutes': occurredOffsetMinutes,
      if (description != null) 'description': description,
      if (providerId != null) 'provider_id': providerId,
      if (modelId != null) 'model_id': modelId,
      if (analyzedAtUtc != null) 'analyzed_at_utc': analyzedAtUtc,
      if (detectedLocale != null) 'detected_locale': detectedLocale,
      if (confidence != null) 'confidence': confidence,
      if (assumptionsJson != null) 'assumptions_json': assumptionsJson,
      if (userEdited != null) 'user_edited': userEdited,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? occurredAtUtc,
    Value<int>? occurredOffsetMinutes,
    Value<String?>? description,
    Value<String>? providerId,
    Value<String>? modelId,
    Value<DateTime>? analyzedAtUtc,
    Value<String>? detectedLocale,
    Value<String>? confidence,
    Value<String>? assumptionsJson,
    Value<bool>? userEdited,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? deletedAtUtc,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return MealEntriesCompanion(
      id: id ?? this.id,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      occurredOffsetMinutes:
          occurredOffsetMinutes ?? this.occurredOffsetMinutes,
      description: description ?? this.description,
      providerId: providerId ?? this.providerId,
      modelId: modelId ?? this.modelId,
      analyzedAtUtc: analyzedAtUtc ?? this.analyzedAtUtc,
      detectedLocale: detectedLocale ?? this.detectedLocale,
      confidence: confidence ?? this.confidence,
      assumptionsJson: assumptionsJson ?? this.assumptionsJson,
      userEdited: userEdited ?? this.userEdited,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (occurredOffsetMinutes.present) {
      map['occurred_offset_minutes'] = Variable<int>(
        occurredOffsetMinutes.value,
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (analyzedAtUtc.present) {
      map['analyzed_at_utc'] = Variable<DateTime>(analyzedAtUtc.value);
    }
    if (detectedLocale.present) {
      map['detected_locale'] = Variable<String>(detectedLocale.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (assumptionsJson.present) {
      map['assumptions_json'] = Variable<String>(assumptionsJson.value);
    }
    if (userEdited.present) {
      map['user_edited'] = Variable<bool>(userEdited.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealEntriesCompanion(')
          ..write('id: $id, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('occurredOffsetMinutes: $occurredOffsetMinutes, ')
          ..write('description: $description, ')
          ..write('providerId: $providerId, ')
          ..write('modelId: $modelId, ')
          ..write('analyzedAtUtc: $analyzedAtUtc, ')
          ..write('detectedLocale: $detectedLocale, ')
          ..write('confidence: $confidence, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('userEdited: $userEdited, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealItemsTable extends MealItems
    with TableInfo<$MealItemsTable, MealItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealEntryIdMeta = const VerificationMeta(
    'mealEntryId',
  );
  @override
  late final GeneratedColumn<String> mealEntryId = GeneratedColumn<String>(
    'meal_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meal_entries (id)',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _amountDescriptionMeta = const VerificationMeta(
    'amountDescription',
  );
  @override
  late final GeneratedColumn<String> amountDescription =
      GeneratedColumn<String>(
        'amount_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _normalizedGramsMilliMeta =
      const VerificationMeta('normalizedGramsMilli');
  @override
  late final GeneratedColumn<int> normalizedGramsMilli = GeneratedColumn<int>(
    'normalized_grams_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<String> confidence = GeneratedColumn<String>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assumptionsJsonMeta = const VerificationMeta(
    'assumptionsJson',
  );
  @override
  late final GeneratedColumn<String> assumptionsJson = GeneratedColumn<String>(
    'assumptions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mealEntryId,
    sortOrder,
    name,
    amountDescription,
    normalizedGramsMilli,
    confidence,
    assumptionsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('meal_entry_id')) {
      context.handle(
        _mealEntryIdMeta,
        mealEntryId.isAcceptableOrUnknown(
          data['meal_entry_id']!,
          _mealEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealEntryIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount_description')) {
      context.handle(
        _amountDescriptionMeta,
        amountDescription.isAcceptableOrUnknown(
          data['amount_description']!,
          _amountDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('normalized_grams_milli')) {
      context.handle(
        _normalizedGramsMilliMeta,
        normalizedGramsMilli.isAcceptableOrUnknown(
          data['normalized_grams_milli']!,
          _normalizedGramsMilliMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('assumptions_json')) {
      context.handle(
        _assumptionsJsonMeta,
        assumptionsJson.isAcceptableOrUnknown(
          data['assumptions_json']!,
          _assumptionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assumptionsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mealEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_entry_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_description'],
      ),
      normalizedGramsMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}normalized_grams_milli'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence'],
      )!,
      assumptionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assumptions_json'],
      )!,
    );
  }

  @override
  $MealItemsTable createAlias(String alias) {
    return $MealItemsTable(attachedDatabase, alias);
  }
}

class MealItemRow extends DataClass implements Insertable<MealItemRow> {
  final String id;
  final String mealEntryId;
  final int sortOrder;
  final String name;
  final String? amountDescription;
  final int? normalizedGramsMilli;
  final String confidence;
  final String assumptionsJson;
  const MealItemRow({
    required this.id,
    required this.mealEntryId,
    required this.sortOrder,
    required this.name,
    this.amountDescription,
    this.normalizedGramsMilli,
    required this.confidence,
    required this.assumptionsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['meal_entry_id'] = Variable<String>(mealEntryId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || amountDescription != null) {
      map['amount_description'] = Variable<String>(amountDescription);
    }
    if (!nullToAbsent || normalizedGramsMilli != null) {
      map['normalized_grams_milli'] = Variable<int>(normalizedGramsMilli);
    }
    map['confidence'] = Variable<String>(confidence);
    map['assumptions_json'] = Variable<String>(assumptionsJson);
    return map;
  }

  MealItemsCompanion toCompanion(bool nullToAbsent) {
    return MealItemsCompanion(
      id: Value(id),
      mealEntryId: Value(mealEntryId),
      sortOrder: Value(sortOrder),
      name: Value(name),
      amountDescription: amountDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(amountDescription),
      normalizedGramsMilli: normalizedGramsMilli == null && nullToAbsent
          ? const Value.absent()
          : Value(normalizedGramsMilli),
      confidence: Value(confidence),
      assumptionsJson: Value(assumptionsJson),
    );
  }

  factory MealItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealItemRow(
      id: serializer.fromJson<String>(json['id']),
      mealEntryId: serializer.fromJson<String>(json['mealEntryId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      name: serializer.fromJson<String>(json['name']),
      amountDescription: serializer.fromJson<String?>(
        json['amountDescription'],
      ),
      normalizedGramsMilli: serializer.fromJson<int?>(
        json['normalizedGramsMilli'],
      ),
      confidence: serializer.fromJson<String>(json['confidence']),
      assumptionsJson: serializer.fromJson<String>(json['assumptionsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mealEntryId': serializer.toJson<String>(mealEntryId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'name': serializer.toJson<String>(name),
      'amountDescription': serializer.toJson<String?>(amountDescription),
      'normalizedGramsMilli': serializer.toJson<int?>(normalizedGramsMilli),
      'confidence': serializer.toJson<String>(confidence),
      'assumptionsJson': serializer.toJson<String>(assumptionsJson),
    };
  }

  MealItemRow copyWith({
    String? id,
    String? mealEntryId,
    int? sortOrder,
    String? name,
    Value<String?> amountDescription = const Value.absent(),
    Value<int?> normalizedGramsMilli = const Value.absent(),
    String? confidence,
    String? assumptionsJson,
  }) => MealItemRow(
    id: id ?? this.id,
    mealEntryId: mealEntryId ?? this.mealEntryId,
    sortOrder: sortOrder ?? this.sortOrder,
    name: name ?? this.name,
    amountDescription: amountDescription.present
        ? amountDescription.value
        : this.amountDescription,
    normalizedGramsMilli: normalizedGramsMilli.present
        ? normalizedGramsMilli.value
        : this.normalizedGramsMilli,
    confidence: confidence ?? this.confidence,
    assumptionsJson: assumptionsJson ?? this.assumptionsJson,
  );
  MealItemRow copyWithCompanion(MealItemsCompanion data) {
    return MealItemRow(
      id: data.id.present ? data.id.value : this.id,
      mealEntryId: data.mealEntryId.present
          ? data.mealEntryId.value
          : this.mealEntryId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      name: data.name.present ? data.name.value : this.name,
      amountDescription: data.amountDescription.present
          ? data.amountDescription.value
          : this.amountDescription,
      normalizedGramsMilli: data.normalizedGramsMilli.present
          ? data.normalizedGramsMilli.value
          : this.normalizedGramsMilli,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      assumptionsJson: data.assumptionsJson.present
          ? data.assumptionsJson.value
          : this.assumptionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealItemRow(')
          ..write('id: $id, ')
          ..write('mealEntryId: $mealEntryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('amountDescription: $amountDescription, ')
          ..write('normalizedGramsMilli: $normalizedGramsMilli, ')
          ..write('confidence: $confidence, ')
          ..write('assumptionsJson: $assumptionsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mealEntryId,
    sortOrder,
    name,
    amountDescription,
    normalizedGramsMilli,
    confidence,
    assumptionsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealItemRow &&
          other.id == this.id &&
          other.mealEntryId == this.mealEntryId &&
          other.sortOrder == this.sortOrder &&
          other.name == this.name &&
          other.amountDescription == this.amountDescription &&
          other.normalizedGramsMilli == this.normalizedGramsMilli &&
          other.confidence == this.confidence &&
          other.assumptionsJson == this.assumptionsJson);
}

class MealItemsCompanion extends UpdateCompanion<MealItemRow> {
  final Value<String> id;
  final Value<String> mealEntryId;
  final Value<int> sortOrder;
  final Value<String> name;
  final Value<String?> amountDescription;
  final Value<int?> normalizedGramsMilli;
  final Value<String> confidence;
  final Value<String> assumptionsJson;
  final Value<int> rowid;
  const MealItemsCompanion({
    this.id = const Value.absent(),
    this.mealEntryId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.name = const Value.absent(),
    this.amountDescription = const Value.absent(),
    this.normalizedGramsMilli = const Value.absent(),
    this.confidence = const Value.absent(),
    this.assumptionsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealItemsCompanion.insert({
    required String id,
    required String mealEntryId,
    required int sortOrder,
    required String name,
    this.amountDescription = const Value.absent(),
    this.normalizedGramsMilli = const Value.absent(),
    required String confidence,
    required String assumptionsJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mealEntryId = Value(mealEntryId),
       sortOrder = Value(sortOrder),
       name = Value(name),
       confidence = Value(confidence),
       assumptionsJson = Value(assumptionsJson);
  static Insertable<MealItemRow> custom({
    Expression<String>? id,
    Expression<String>? mealEntryId,
    Expression<int>? sortOrder,
    Expression<String>? name,
    Expression<String>? amountDescription,
    Expression<int>? normalizedGramsMilli,
    Expression<String>? confidence,
    Expression<String>? assumptionsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mealEntryId != null) 'meal_entry_id': mealEntryId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (name != null) 'name': name,
      if (amountDescription != null) 'amount_description': amountDescription,
      if (normalizedGramsMilli != null)
        'normalized_grams_milli': normalizedGramsMilli,
      if (confidence != null) 'confidence': confidence,
      if (assumptionsJson != null) 'assumptions_json': assumptionsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? mealEntryId,
    Value<int>? sortOrder,
    Value<String>? name,
    Value<String?>? amountDescription,
    Value<int?>? normalizedGramsMilli,
    Value<String>? confidence,
    Value<String>? assumptionsJson,
    Value<int>? rowid,
  }) {
    return MealItemsCompanion(
      id: id ?? this.id,
      mealEntryId: mealEntryId ?? this.mealEntryId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      amountDescription: amountDescription ?? this.amountDescription,
      normalizedGramsMilli: normalizedGramsMilli ?? this.normalizedGramsMilli,
      confidence: confidence ?? this.confidence,
      assumptionsJson: assumptionsJson ?? this.assumptionsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mealEntryId.present) {
      map['meal_entry_id'] = Variable<String>(mealEntryId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountDescription.present) {
      map['amount_description'] = Variable<String>(amountDescription.value);
    }
    if (normalizedGramsMilli.present) {
      map['normalized_grams_milli'] = Variable<int>(normalizedGramsMilli.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(confidence.value);
    }
    if (assumptionsJson.present) {
      map['assumptions_json'] = Variable<String>(assumptionsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealItemsCompanion(')
          ..write('id: $id, ')
          ..write('mealEntryId: $mealEntryId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('amountDescription: $amountDescription, ')
          ..write('normalizedGramsMilli: $normalizedGramsMilli, ')
          ..write('confidence: $confidence, ')
          ..write('assumptionsJson: $assumptionsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealNutrientValuesTable extends MealNutrientValues
    with TableInfo<$MealNutrientValuesTable, MealNutrientValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealNutrientValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mealItemIdMeta = const VerificationMeta(
    'mealItemId',
  );
  @override
  late final GeneratedColumn<String> mealItemId = GeneratedColumn<String>(
    'meal_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meal_items (id)',
    ),
  );
  static const VerificationMeta _nutrientIdMeta = const VerificationMeta(
    'nutrientId',
  );
  @override
  late final GeneratedColumn<String> nutrientId = GeneratedColumn<String>(
    'nutrient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _milliUnitsMeta = const VerificationMeta(
    'milliUnits',
  );
  @override
  late final GeneratedColumn<int> milliUnits = GeneratedColumn<int>(
    'milli_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mealItemId,
    nutrientId,
    unit,
    milliUnits,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_nutrient_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealNutrientValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meal_item_id')) {
      context.handle(
        _mealItemIdMeta,
        mealItemId.isAcceptableOrUnknown(
          data['meal_item_id']!,
          _mealItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealItemIdMeta);
    }
    if (data.containsKey('nutrient_id')) {
      context.handle(
        _nutrientIdMeta,
        nutrientId.isAcceptableOrUnknown(data['nutrient_id']!, _nutrientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nutrientIdMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('milli_units')) {
      context.handle(
        _milliUnitsMeta,
        milliUnits.isAcceptableOrUnknown(data['milli_units']!, _milliUnitsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mealItemId, nutrientId};
  @override
  MealNutrientValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealNutrientValueRow(
      mealItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_item_id'],
      )!,
      nutrientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutrient_id'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      milliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}milli_units'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $MealNutrientValuesTable createAlias(String alias) {
    return $MealNutrientValuesTable(attachedDatabase, alias);
  }
}

class MealNutrientValueRow extends DataClass
    implements Insertable<MealNutrientValueRow> {
  final String mealItemId;
  final String nutrientId;
  final String unit;
  final int? milliUnits;
  final String source;
  const MealNutrientValueRow({
    required this.mealItemId,
    required this.nutrientId,
    required this.unit,
    this.milliUnits,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meal_item_id'] = Variable<String>(mealItemId);
    map['nutrient_id'] = Variable<String>(nutrientId);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || milliUnits != null) {
      map['milli_units'] = Variable<int>(milliUnits);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  MealNutrientValuesCompanion toCompanion(bool nullToAbsent) {
    return MealNutrientValuesCompanion(
      mealItemId: Value(mealItemId),
      nutrientId: Value(nutrientId),
      unit: Value(unit),
      milliUnits: milliUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(milliUnits),
      source: Value(source),
    );
  }

  factory MealNutrientValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealNutrientValueRow(
      mealItemId: serializer.fromJson<String>(json['mealItemId']),
      nutrientId: serializer.fromJson<String>(json['nutrientId']),
      unit: serializer.fromJson<String>(json['unit']),
      milliUnits: serializer.fromJson<int?>(json['milliUnits']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mealItemId': serializer.toJson<String>(mealItemId),
      'nutrientId': serializer.toJson<String>(nutrientId),
      'unit': serializer.toJson<String>(unit),
      'milliUnits': serializer.toJson<int?>(milliUnits),
      'source': serializer.toJson<String>(source),
    };
  }

  MealNutrientValueRow copyWith({
    String? mealItemId,
    String? nutrientId,
    String? unit,
    Value<int?> milliUnits = const Value.absent(),
    String? source,
  }) => MealNutrientValueRow(
    mealItemId: mealItemId ?? this.mealItemId,
    nutrientId: nutrientId ?? this.nutrientId,
    unit: unit ?? this.unit,
    milliUnits: milliUnits.present ? milliUnits.value : this.milliUnits,
    source: source ?? this.source,
  );
  MealNutrientValueRow copyWithCompanion(MealNutrientValuesCompanion data) {
    return MealNutrientValueRow(
      mealItemId: data.mealItemId.present
          ? data.mealItemId.value
          : this.mealItemId,
      nutrientId: data.nutrientId.present
          ? data.nutrientId.value
          : this.nutrientId,
      unit: data.unit.present ? data.unit.value : this.unit,
      milliUnits: data.milliUnits.present
          ? data.milliUnits.value
          : this.milliUnits,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealNutrientValueRow(')
          ..write('mealItemId: $mealItemId, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('unit: $unit, ')
          ..write('milliUnits: $milliUnits, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(mealItemId, nutrientId, unit, milliUnits, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealNutrientValueRow &&
          other.mealItemId == this.mealItemId &&
          other.nutrientId == this.nutrientId &&
          other.unit == this.unit &&
          other.milliUnits == this.milliUnits &&
          other.source == this.source);
}

class MealNutrientValuesCompanion
    extends UpdateCompanion<MealNutrientValueRow> {
  final Value<String> mealItemId;
  final Value<String> nutrientId;
  final Value<String> unit;
  final Value<int?> milliUnits;
  final Value<String> source;
  final Value<int> rowid;
  const MealNutrientValuesCompanion({
    this.mealItemId = const Value.absent(),
    this.nutrientId = const Value.absent(),
    this.unit = const Value.absent(),
    this.milliUnits = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealNutrientValuesCompanion.insert({
    required String mealItemId,
    required String nutrientId,
    required String unit,
    this.milliUnits = const Value.absent(),
    required String source,
    this.rowid = const Value.absent(),
  }) : mealItemId = Value(mealItemId),
       nutrientId = Value(nutrientId),
       unit = Value(unit),
       source = Value(source);
  static Insertable<MealNutrientValueRow> custom({
    Expression<String>? mealItemId,
    Expression<String>? nutrientId,
    Expression<String>? unit,
    Expression<int>? milliUnits,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mealItemId != null) 'meal_item_id': mealItemId,
      if (nutrientId != null) 'nutrient_id': nutrientId,
      if (unit != null) 'unit': unit,
      if (milliUnits != null) 'milli_units': milliUnits,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealNutrientValuesCompanion copyWith({
    Value<String>? mealItemId,
    Value<String>? nutrientId,
    Value<String>? unit,
    Value<int?>? milliUnits,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return MealNutrientValuesCompanion(
      mealItemId: mealItemId ?? this.mealItemId,
      nutrientId: nutrientId ?? this.nutrientId,
      unit: unit ?? this.unit,
      milliUnits: milliUnits ?? this.milliUnits,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mealItemId.present) {
      map['meal_item_id'] = Variable<String>(mealItemId.value);
    }
    if (nutrientId.present) {
      map['nutrient_id'] = Variable<String>(nutrientId.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (milliUnits.present) {
      map['milli_units'] = Variable<int>(milliUnits.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealNutrientValuesCompanion(')
          ..write('mealItemId: $mealItemId, ')
          ..write('nutrientId: $nutrientId, ')
          ..write('unit: $unit, ')
          ..write('milliUnits: $milliUnits, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalTargetsTable extends GoalTargets
    with TableInfo<$GoalTargetsTable, GoalTargetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nutrientIdMeta = const VerificationMeta(
    'nutrientId',
  );
  @override
  late final GeneratedColumn<String> nutrientId = GeneratedColumn<String>(
    'nutrient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumMilliUnitsMeta = const VerificationMeta(
    'minimumMilliUnits',
  );
  @override
  late final GeneratedColumn<int> minimumMilliUnits = GeneratedColumn<int>(
    'minimum_milli_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maximumMilliUnitsMeta = const VerificationMeta(
    'maximumMilliUnits',
  );
  @override
  late final GeneratedColumn<int> maximumMilliUnits = GeneratedColumn<int>(
    'maximum_milli_units',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    nutrientId,
    targetType,
    minimumMilliUnits,
    maximumMilliUnits,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalTargetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('nutrient_id')) {
      context.handle(
        _nutrientIdMeta,
        nutrientId.isAcceptableOrUnknown(data['nutrient_id']!, _nutrientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nutrientIdMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('minimum_milli_units')) {
      context.handle(
        _minimumMilliUnitsMeta,
        minimumMilliUnits.isAcceptableOrUnknown(
          data['minimum_milli_units']!,
          _minimumMilliUnitsMeta,
        ),
      );
    }
    if (data.containsKey('maximum_milli_units')) {
      context.handle(
        _maximumMilliUnitsMeta,
        maximumMilliUnits.isAcceptableOrUnknown(
          data['maximum_milli_units']!,
          _maximumMilliUnitsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nutrientId};
  @override
  GoalTargetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalTargetRow(
      nutrientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nutrient_id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      minimumMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_milli_units'],
      ),
      maximumMilliUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maximum_milli_units'],
      ),
    );
  }

  @override
  $GoalTargetsTable createAlias(String alias) {
    return $GoalTargetsTable(attachedDatabase, alias);
  }
}

class GoalTargetRow extends DataClass implements Insertable<GoalTargetRow> {
  final String nutrientId;
  final String targetType;
  final int? minimumMilliUnits;
  final int? maximumMilliUnits;
  const GoalTargetRow({
    required this.nutrientId,
    required this.targetType,
    this.minimumMilliUnits,
    this.maximumMilliUnits,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['nutrient_id'] = Variable<String>(nutrientId);
    map['target_type'] = Variable<String>(targetType);
    if (!nullToAbsent || minimumMilliUnits != null) {
      map['minimum_milli_units'] = Variable<int>(minimumMilliUnits);
    }
    if (!nullToAbsent || maximumMilliUnits != null) {
      map['maximum_milli_units'] = Variable<int>(maximumMilliUnits);
    }
    return map;
  }

  GoalTargetsCompanion toCompanion(bool nullToAbsent) {
    return GoalTargetsCompanion(
      nutrientId: Value(nutrientId),
      targetType: Value(targetType),
      minimumMilliUnits: minimumMilliUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(minimumMilliUnits),
      maximumMilliUnits: maximumMilliUnits == null && nullToAbsent
          ? const Value.absent()
          : Value(maximumMilliUnits),
    );
  }

  factory GoalTargetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalTargetRow(
      nutrientId: serializer.fromJson<String>(json['nutrientId']),
      targetType: serializer.fromJson<String>(json['targetType']),
      minimumMilliUnits: serializer.fromJson<int?>(json['minimumMilliUnits']),
      maximumMilliUnits: serializer.fromJson<int?>(json['maximumMilliUnits']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nutrientId': serializer.toJson<String>(nutrientId),
      'targetType': serializer.toJson<String>(targetType),
      'minimumMilliUnits': serializer.toJson<int?>(minimumMilliUnits),
      'maximumMilliUnits': serializer.toJson<int?>(maximumMilliUnits),
    };
  }

  GoalTargetRow copyWith({
    String? nutrientId,
    String? targetType,
    Value<int?> minimumMilliUnits = const Value.absent(),
    Value<int?> maximumMilliUnits = const Value.absent(),
  }) => GoalTargetRow(
    nutrientId: nutrientId ?? this.nutrientId,
    targetType: targetType ?? this.targetType,
    minimumMilliUnits: minimumMilliUnits.present
        ? minimumMilliUnits.value
        : this.minimumMilliUnits,
    maximumMilliUnits: maximumMilliUnits.present
        ? maximumMilliUnits.value
        : this.maximumMilliUnits,
  );
  GoalTargetRow copyWithCompanion(GoalTargetsCompanion data) {
    return GoalTargetRow(
      nutrientId: data.nutrientId.present
          ? data.nutrientId.value
          : this.nutrientId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      minimumMilliUnits: data.minimumMilliUnits.present
          ? data.minimumMilliUnits.value
          : this.minimumMilliUnits,
      maximumMilliUnits: data.maximumMilliUnits.present
          ? data.maximumMilliUnits.value
          : this.maximumMilliUnits,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalTargetRow(')
          ..write('nutrientId: $nutrientId, ')
          ..write('targetType: $targetType, ')
          ..write('minimumMilliUnits: $minimumMilliUnits, ')
          ..write('maximumMilliUnits: $maximumMilliUnits')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(nutrientId, targetType, minimumMilliUnits, maximumMilliUnits);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalTargetRow &&
          other.nutrientId == this.nutrientId &&
          other.targetType == this.targetType &&
          other.minimumMilliUnits == this.minimumMilliUnits &&
          other.maximumMilliUnits == this.maximumMilliUnits);
}

class GoalTargetsCompanion extends UpdateCompanion<GoalTargetRow> {
  final Value<String> nutrientId;
  final Value<String> targetType;
  final Value<int?> minimumMilliUnits;
  final Value<int?> maximumMilliUnits;
  final Value<int> rowid;
  const GoalTargetsCompanion({
    this.nutrientId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.minimumMilliUnits = const Value.absent(),
    this.maximumMilliUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalTargetsCompanion.insert({
    required String nutrientId,
    required String targetType,
    this.minimumMilliUnits = const Value.absent(),
    this.maximumMilliUnits = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nutrientId = Value(nutrientId),
       targetType = Value(targetType);
  static Insertable<GoalTargetRow> custom({
    Expression<String>? nutrientId,
    Expression<String>? targetType,
    Expression<int>? minimumMilliUnits,
    Expression<int>? maximumMilliUnits,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nutrientId != null) 'nutrient_id': nutrientId,
      if (targetType != null) 'target_type': targetType,
      if (minimumMilliUnits != null) 'minimum_milli_units': minimumMilliUnits,
      if (maximumMilliUnits != null) 'maximum_milli_units': maximumMilliUnits,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalTargetsCompanion copyWith({
    Value<String>? nutrientId,
    Value<String>? targetType,
    Value<int?>? minimumMilliUnits,
    Value<int?>? maximumMilliUnits,
    Value<int>? rowid,
  }) {
    return GoalTargetsCompanion(
      nutrientId: nutrientId ?? this.nutrientId,
      targetType: targetType ?? this.targetType,
      minimumMilliUnits: minimumMilliUnits ?? this.minimumMilliUnits,
      maximumMilliUnits: maximumMilliUnits ?? this.maximumMilliUnits,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nutrientId.present) {
      map['nutrient_id'] = Variable<String>(nutrientId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (minimumMilliUnits.present) {
      map['minimum_milli_units'] = Variable<int>(minimumMilliUnits.value);
    }
    if (maximumMilliUnits.present) {
      map['maximum_milli_units'] = Variable<int>(maximumMilliUnits.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalTargetsCompanion(')
          ..write('nutrientId: $nutrientId, ')
          ..write('targetType: $targetType, ')
          ..write('minimumMilliUnits: $minimumMilliUnits, ')
          ..write('maximumMilliUnits: $maximumMilliUnits, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MealEntriesTable mealEntries = $MealEntriesTable(this);
  late final $MealItemsTable mealItems = $MealItemsTable(this);
  late final $MealNutrientValuesTable mealNutrientValues =
      $MealNutrientValuesTable(this);
  late final $GoalTargetsTable goalTargets = $GoalTargetsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mealEntries,
    mealItems,
    mealNutrientValues,
    goalTargets,
  ];
}

typedef $$MealEntriesTableCreateCompanionBuilder =
    MealEntriesCompanion Function({
      required String id,
      required DateTime occurredAtUtc,
      required int occurredOffsetMinutes,
      Value<String?> description,
      required String providerId,
      required String modelId,
      required DateTime analyzedAtUtc,
      required String detectedLocale,
      required String confidence,
      required String assumptionsJson,
      required bool userEdited,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
      required int revision,
      Value<int> rowid,
    });
typedef $$MealEntriesTableUpdateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> occurredAtUtc,
      Value<int> occurredOffsetMinutes,
      Value<String?> description,
      Value<String> providerId,
      Value<String> modelId,
      Value<DateTime> analyzedAtUtc,
      Value<String> detectedLocale,
      Value<String> confidence,
      Value<String> assumptionsJson,
      Value<bool> userEdited,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
      Value<int> revision,
      Value<int> rowid,
    });

final class $$MealEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntryRow> {
  $$MealEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MealItemsTable, List<MealItemRow>>
  _mealItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealItems,
    aliasName: 'meal_entries__id__meal_items__meal_entry_id',
  );

  $$MealItemsTableProcessedTableManager get mealItemsRefs {
    final manager = $$MealItemsTableTableManager(
      $_db,
      $_db.mealItems,
    ).filter((f) => f.mealEntryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mealItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MealEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableFilterComposer({
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

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredOffsetMinutes => $composableBuilder(
    column: $table.occurredOffsetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedLocale => $composableBuilder(
    column: $table.detectedLocale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> mealItemsRefs(
    Expression<bool> Function($$MealItemsTableFilterComposer f) f,
  ) {
    final $$MealItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealItems,
      getReferencedColumn: (t) => t.mealEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealItemsTableFilterComposer(
            $db: $db,
            $table: $db.mealItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredOffsetMinutes => $composableBuilder(
    column: $table.occurredOffsetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedLocale => $composableBuilder(
    column: $table.detectedLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredOffsetMinutes => $composableBuilder(
    column: $table.occurredOffsetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerId => $composableBuilder(
    column: $table.providerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<DateTime> get analyzedAtUtc => $composableBuilder(
    column: $table.analyzedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedLocale => $composableBuilder(
    column: $table.detectedLocale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get userEdited => $composableBuilder(
    column: $table.userEdited,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  Expression<T> mealItemsRefs<T extends Object>(
    Expression<T> Function($$MealItemsTableAnnotationComposer a) f,
  ) {
    final $$MealItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealItems,
      getReferencedColumn: (t) => t.mealEntryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mealItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntriesTable,
          MealEntryRow,
          $$MealEntriesTableFilterComposer,
          $$MealEntriesTableOrderingComposer,
          $$MealEntriesTableAnnotationComposer,
          $$MealEntriesTableCreateCompanionBuilder,
          $$MealEntriesTableUpdateCompanionBuilder,
          (MealEntryRow, $$MealEntriesTableReferences),
          MealEntryRow,
          PrefetchHooks Function({bool mealItemsRefs})
        > {
  $$MealEntriesTableTableManager(_$AppDatabase db, $MealEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> occurredOffsetMinutes = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> providerId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<DateTime> analyzedAtUtc = const Value.absent(),
                Value<String> detectedLocale = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<String> assumptionsJson = const Value.absent(),
                Value<bool> userEdited = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> deletedAtUtc = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion(
                id: id,
                occurredAtUtc: occurredAtUtc,
                occurredOffsetMinutes: occurredOffsetMinutes,
                description: description,
                providerId: providerId,
                modelId: modelId,
                analyzedAtUtc: analyzedAtUtc,
                detectedLocale: detectedLocale,
                confidence: confidence,
                assumptionsJson: assumptionsJson,
                userEdited: userEdited,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime occurredAtUtc,
                required int occurredOffsetMinutes,
                Value<String?> description = const Value.absent(),
                required String providerId,
                required String modelId,
                required DateTime analyzedAtUtc,
                required String detectedLocale,
                required String confidence,
                required String assumptionsJson,
                required bool userEdited,
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> deletedAtUtc = const Value.absent(),
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion.insert(
                id: id,
                occurredAtUtc: occurredAtUtc,
                occurredOffsetMinutes: occurredOffsetMinutes,
                description: description,
                providerId: providerId,
                modelId: modelId,
                analyzedAtUtc: analyzedAtUtc,
                detectedLocale: detectedLocale,
                confidence: confidence,
                assumptionsJson: assumptionsJson,
                userEdited: userEdited,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MealEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mealItemsRefs) db.mealItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mealItemsRefs)
                    await $_getPrefetchedData<
                      MealEntryRow,
                      $MealEntriesTable,
                      MealItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$MealEntriesTableReferences
                          ._mealItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MealEntriesTableReferences(
                            db,
                            table,
                            p0,
                          ).mealItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.mealEntryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MealEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntriesTable,
      MealEntryRow,
      $$MealEntriesTableFilterComposer,
      $$MealEntriesTableOrderingComposer,
      $$MealEntriesTableAnnotationComposer,
      $$MealEntriesTableCreateCompanionBuilder,
      $$MealEntriesTableUpdateCompanionBuilder,
      (MealEntryRow, $$MealEntriesTableReferences),
      MealEntryRow,
      PrefetchHooks Function({bool mealItemsRefs})
    >;
typedef $$MealItemsTableCreateCompanionBuilder =
    MealItemsCompanion Function({
      required String id,
      required String mealEntryId,
      required int sortOrder,
      required String name,
      Value<String?> amountDescription,
      Value<int?> normalizedGramsMilli,
      required String confidence,
      required String assumptionsJson,
      Value<int> rowid,
    });
typedef $$MealItemsTableUpdateCompanionBuilder =
    MealItemsCompanion Function({
      Value<String> id,
      Value<String> mealEntryId,
      Value<int> sortOrder,
      Value<String> name,
      Value<String?> amountDescription,
      Value<int?> normalizedGramsMilli,
      Value<String> confidence,
      Value<String> assumptionsJson,
      Value<int> rowid,
    });

final class $$MealItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MealItemsTable, MealItemRow> {
  $$MealItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MealEntriesTable _mealEntryIdTable(_$AppDatabase db) =>
      db.mealEntries.createAlias('meal_items__meal_entry_id__meal_entries__id');

  $$MealEntriesTableProcessedTableManager get mealEntryId {
    final $_column = $_itemColumn<String>('meal_entry_id')!;

    final manager = $$MealEntriesTableTableManager(
      $_db,
      $_db.mealEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $MealNutrientValuesTable,
    List<MealNutrientValueRow>
  >
  _mealNutrientValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mealNutrientValues,
        aliasName: 'meal_items__id__meal_nutrient_values__meal_item_id',
      );

  $$MealNutrientValuesTableProcessedTableManager get mealNutrientValuesRefs {
    final manager = $$MealNutrientValuesTableTableManager(
      $_db,
      $_db.mealNutrientValues,
    ).filter((f) => f.mealItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mealNutrientValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MealItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableFilterComposer({
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountDescription => $composableBuilder(
    column: $table.amountDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get normalizedGramsMilli => $composableBuilder(
    column: $table.normalizedGramsMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$MealEntriesTableFilterComposer get mealEntryId {
    final $$MealEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealEntryId,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableFilterComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> mealNutrientValuesRefs(
    Expression<bool> Function($$MealNutrientValuesTableFilterComposer f) f,
  ) {
    final $$MealNutrientValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealNutrientValues,
      getReferencedColumn: (t) => t.mealItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealNutrientValuesTableFilterComposer(
            $db: $db,
            $table: $db.mealNutrientValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableOrderingComposer({
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountDescription => $composableBuilder(
    column: $table.amountDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get normalizedGramsMilli => $composableBuilder(
    column: $table.normalizedGramsMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$MealEntriesTableOrderingComposer get mealEntryId {
    final $$MealEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealEntryId,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealItemsTable> {
  $$MealItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get amountDescription => $composableBuilder(
    column: $table.amountDescription,
    builder: (column) => column,
  );

  GeneratedColumn<int> get normalizedGramsMilli => $composableBuilder(
    column: $table.normalizedGramsMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assumptionsJson => $composableBuilder(
    column: $table.assumptionsJson,
    builder: (column) => column,
  );

  $$MealEntriesTableAnnotationComposer get mealEntryId {
    final $$MealEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealEntryId,
      referencedTable: $db.mealEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.mealEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> mealNutrientValuesRefs<T extends Object>(
    Expression<T> Function($$MealNutrientValuesTableAnnotationComposer a) f,
  ) {
    final $$MealNutrientValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mealNutrientValues,
          getReferencedColumn: (t) => t.mealItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MealNutrientValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.mealNutrientValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MealItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealItemsTable,
          MealItemRow,
          $$MealItemsTableFilterComposer,
          $$MealItemsTableOrderingComposer,
          $$MealItemsTableAnnotationComposer,
          $$MealItemsTableCreateCompanionBuilder,
          $$MealItemsTableUpdateCompanionBuilder,
          (MealItemRow, $$MealItemsTableReferences),
          MealItemRow,
          PrefetchHooks Function({
            bool mealEntryId,
            bool mealNutrientValuesRefs,
          })
        > {
  $$MealItemsTableTableManager(_$AppDatabase db, $MealItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mealEntryId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> amountDescription = const Value.absent(),
                Value<int?> normalizedGramsMilli = const Value.absent(),
                Value<String> confidence = const Value.absent(),
                Value<String> assumptionsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealItemsCompanion(
                id: id,
                mealEntryId: mealEntryId,
                sortOrder: sortOrder,
                name: name,
                amountDescription: amountDescription,
                normalizedGramsMilli: normalizedGramsMilli,
                confidence: confidence,
                assumptionsJson: assumptionsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mealEntryId,
                required int sortOrder,
                required String name,
                Value<String?> amountDescription = const Value.absent(),
                Value<int?> normalizedGramsMilli = const Value.absent(),
                required String confidence,
                required String assumptionsJson,
                Value<int> rowid = const Value.absent(),
              }) => MealItemsCompanion.insert(
                id: id,
                mealEntryId: mealEntryId,
                sortOrder: sortOrder,
                name: name,
                amountDescription: amountDescription,
                normalizedGramsMilli: normalizedGramsMilli,
                confidence: confidence,
                assumptionsJson: assumptionsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MealItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mealEntryId = false, mealNutrientValuesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mealNutrientValuesRefs) db.mealNutrientValues,
                  ],
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
                        if (mealEntryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mealEntryId,
                                    referencedTable: $$MealItemsTableReferences
                                        ._mealEntryIdTable(db),
                                    referencedColumn: $$MealItemsTableReferences
                                        ._mealEntryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mealNutrientValuesRefs)
                        await $_getPrefetchedData<
                          MealItemRow,
                          $MealItemsTable,
                          MealNutrientValueRow
                        >(
                          currentTable: table,
                          referencedTable: $$MealItemsTableReferences
                              ._mealNutrientValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MealItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).mealNutrientValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mealItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MealItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealItemsTable,
      MealItemRow,
      $$MealItemsTableFilterComposer,
      $$MealItemsTableOrderingComposer,
      $$MealItemsTableAnnotationComposer,
      $$MealItemsTableCreateCompanionBuilder,
      $$MealItemsTableUpdateCompanionBuilder,
      (MealItemRow, $$MealItemsTableReferences),
      MealItemRow,
      PrefetchHooks Function({bool mealEntryId, bool mealNutrientValuesRefs})
    >;
typedef $$MealNutrientValuesTableCreateCompanionBuilder =
    MealNutrientValuesCompanion Function({
      required String mealItemId,
      required String nutrientId,
      required String unit,
      Value<int?> milliUnits,
      required String source,
      Value<int> rowid,
    });
typedef $$MealNutrientValuesTableUpdateCompanionBuilder =
    MealNutrientValuesCompanion Function({
      Value<String> mealItemId,
      Value<String> nutrientId,
      Value<String> unit,
      Value<int?> milliUnits,
      Value<String> source,
      Value<int> rowid,
    });

final class $$MealNutrientValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MealNutrientValuesTable,
          MealNutrientValueRow
        > {
  $$MealNutrientValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MealItemsTable _mealItemIdTable(_$AppDatabase db) => db.mealItems
      .createAlias('meal_nutrient_values__meal_item_id__meal_items__id');

  $$MealItemsTableProcessedTableManager get mealItemId {
    final $_column = $_itemColumn<String>('meal_item_id')!;

    final manager = $$MealItemsTableTableManager(
      $_db,
      $_db.mealItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MealNutrientValuesTableFilterComposer
    extends Composer<_$AppDatabase, $MealNutrientValuesTable> {
  $$MealNutrientValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get milliUnits => $composableBuilder(
    column: $table.milliUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$MealItemsTableFilterComposer get mealItemId {
    final $$MealItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealItemId,
      referencedTable: $db.mealItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealItemsTableFilterComposer(
            $db: $db,
            $table: $db.mealItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealNutrientValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealNutrientValuesTable> {
  $$MealNutrientValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get milliUnits => $composableBuilder(
    column: $table.milliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$MealItemsTableOrderingComposer get mealItemId {
    final $$MealItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealItemId,
      referencedTable: $db.mealItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mealItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealNutrientValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealNutrientValuesTable> {
  $$MealNutrientValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get milliUnits => $composableBuilder(
    column: $table.milliUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$MealItemsTableAnnotationComposer get mealItemId {
    final $$MealItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealItemId,
      referencedTable: $db.mealItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mealItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealNutrientValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealNutrientValuesTable,
          MealNutrientValueRow,
          $$MealNutrientValuesTableFilterComposer,
          $$MealNutrientValuesTableOrderingComposer,
          $$MealNutrientValuesTableAnnotationComposer,
          $$MealNutrientValuesTableCreateCompanionBuilder,
          $$MealNutrientValuesTableUpdateCompanionBuilder,
          (MealNutrientValueRow, $$MealNutrientValuesTableReferences),
          MealNutrientValueRow,
          PrefetchHooks Function({bool mealItemId})
        > {
  $$MealNutrientValuesTableTableManager(
    _$AppDatabase db,
    $MealNutrientValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealNutrientValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealNutrientValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealNutrientValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> mealItemId = const Value.absent(),
                Value<String> nutrientId = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<int?> milliUnits = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealNutrientValuesCompanion(
                mealItemId: mealItemId,
                nutrientId: nutrientId,
                unit: unit,
                milliUnits: milliUnits,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String mealItemId,
                required String nutrientId,
                required String unit,
                Value<int?> milliUnits = const Value.absent(),
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => MealNutrientValuesCompanion.insert(
                mealItemId: mealItemId,
                nutrientId: nutrientId,
                unit: unit,
                milliUnits: milliUnits,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MealNutrientValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealItemId = false}) {
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
                    if (mealItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mealItemId,
                                referencedTable:
                                    $$MealNutrientValuesTableReferences
                                        ._mealItemIdTable(db),
                                referencedColumn:
                                    $$MealNutrientValuesTableReferences
                                        ._mealItemIdTable(db)
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

typedef $$MealNutrientValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealNutrientValuesTable,
      MealNutrientValueRow,
      $$MealNutrientValuesTableFilterComposer,
      $$MealNutrientValuesTableOrderingComposer,
      $$MealNutrientValuesTableAnnotationComposer,
      $$MealNutrientValuesTableCreateCompanionBuilder,
      $$MealNutrientValuesTableUpdateCompanionBuilder,
      (MealNutrientValueRow, $$MealNutrientValuesTableReferences),
      MealNutrientValueRow,
      PrefetchHooks Function({bool mealItemId})
    >;
typedef $$GoalTargetsTableCreateCompanionBuilder =
    GoalTargetsCompanion Function({
      required String nutrientId,
      required String targetType,
      Value<int?> minimumMilliUnits,
      Value<int?> maximumMilliUnits,
      Value<int> rowid,
    });
typedef $$GoalTargetsTableUpdateCompanionBuilder =
    GoalTargetsCompanion Function({
      Value<String> nutrientId,
      Value<String> targetType,
      Value<int?> minimumMilliUnits,
      Value<int?> maximumMilliUnits,
      Value<int> rowid,
    });

class $$GoalTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalTargetsTable> {
  $$GoalTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumMilliUnits => $composableBuilder(
    column: $table.minimumMilliUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maximumMilliUnits => $composableBuilder(
    column: $table.maximumMilliUnits,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalTargetsTable> {
  $$GoalTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumMilliUnits => $composableBuilder(
    column: $table.minimumMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maximumMilliUnits => $composableBuilder(
    column: $table.maximumMilliUnits,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalTargetsTable> {
  $$GoalTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get nutrientId => $composableBuilder(
    column: $table.nutrientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumMilliUnits => $composableBuilder(
    column: $table.minimumMilliUnits,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maximumMilliUnits => $composableBuilder(
    column: $table.maximumMilliUnits,
    builder: (column) => column,
  );
}

class $$GoalTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalTargetsTable,
          GoalTargetRow,
          $$GoalTargetsTableFilterComposer,
          $$GoalTargetsTableOrderingComposer,
          $$GoalTargetsTableAnnotationComposer,
          $$GoalTargetsTableCreateCompanionBuilder,
          $$GoalTargetsTableUpdateCompanionBuilder,
          (
            GoalTargetRow,
            BaseReferences<_$AppDatabase, $GoalTargetsTable, GoalTargetRow>,
          ),
          GoalTargetRow,
          PrefetchHooks Function()
        > {
  $$GoalTargetsTableTableManager(_$AppDatabase db, $GoalTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> nutrientId = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int?> minimumMilliUnits = const Value.absent(),
                Value<int?> maximumMilliUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalTargetsCompanion(
                nutrientId: nutrientId,
                targetType: targetType,
                minimumMilliUnits: minimumMilliUnits,
                maximumMilliUnits: maximumMilliUnits,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String nutrientId,
                required String targetType,
                Value<int?> minimumMilliUnits = const Value.absent(),
                Value<int?> maximumMilliUnits = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalTargetsCompanion.insert(
                nutrientId: nutrientId,
                targetType: targetType,
                minimumMilliUnits: minimumMilliUnits,
                maximumMilliUnits: maximumMilliUnits,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalTargetsTable,
      GoalTargetRow,
      $$GoalTargetsTableFilterComposer,
      $$GoalTargetsTableOrderingComposer,
      $$GoalTargetsTableAnnotationComposer,
      $$GoalTargetsTableCreateCompanionBuilder,
      $$GoalTargetsTableUpdateCompanionBuilder,
      (
        GoalTargetRow,
        BaseReferences<_$AppDatabase, $GoalTargetsTable, GoalTargetRow>,
      ),
      GoalTargetRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db, _db.mealEntries);
  $$MealItemsTableTableManager get mealItems =>
      $$MealItemsTableTableManager(_db, _db.mealItems);
  $$MealNutrientValuesTableTableManager get mealNutrientValues =>
      $$MealNutrientValuesTableTableManager(_db, _db.mealNutrientValues);
  $$GoalTargetsTableTableManager get goalTargets =>
      $$GoalTargetsTableTableManager(_db, _db.goalTargets);
}
