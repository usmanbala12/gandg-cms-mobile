// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedMeta =
      const VerificationMeta('lastSynced');
  @override
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
      'last_synced', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, location, metadata, lastSynced, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    }
    if (data.containsKey('last_synced')) {
      context.handle(
          _lastSyncedMeta,
          lastSynced.isAcceptableOrUnknown(
              data['last_synced']!, _lastSyncedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
      lastSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_synced']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? location;
  final String? metadata;
  final int? lastSynced;
  final int createdAt;
  final int updatedAt;
  const Project(
      {required this.id,
      required this.name,
      this.location,
      this.metadata,
      this.lastSynced,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    if (!nullToAbsent || lastSynced != null) {
      map['last_synced'] = Variable<int>(lastSynced);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      lastSynced: lastSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSynced),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      lastSynced: serializer.fromJson<int?>(json['lastSynced']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'metadata': serializer.toJson<String?>(metadata),
      'lastSynced': serializer.toJson<int?>(lastSynced),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Project copyWith(
          {String? id,
          String? name,
          Value<String?> location = const Value.absent(),
          Value<String?> metadata = const Value.absent(),
          Value<int?> lastSynced = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location.present ? location.value : this.location,
        metadata: metadata.present ? metadata.value : this.metadata,
        lastSynced: lastSynced.present ? lastSynced.value : this.lastSynced,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      lastSynced:
          data.lastSynced.present ? data.lastSynced.value : this.lastSynced,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('metadata: $metadata, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, location, metadata, lastSynced, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.metadata == this.metadata &&
          other.lastSynced == this.lastSynced &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<String?> metadata;
  final Value<int?> lastSynced;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.location = const Value.absent(),
    this.metadata = const Value.absent(),
    this.lastSynced = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? metadata,
    Expression<int>? lastSynced,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (metadata != null) 'metadata': metadata,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? location,
      Value<String?>? metadata,
      Value<int?>? lastSynced,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      lastSynced: lastSynced ?? this.lastSynced,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<int>(lastSynced.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('metadata: $metadata, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<int> lastAttemptAt = GeneratedColumn<int>(
      'last_attempt_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        entityType,
        entityId,
        action,
        payload,
        priority,
        status,
        attempts,
        lastAttemptAt,
        errorMessage,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastAttemptAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_attempt_at']),
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final String projectId;
  final String entityType;
  final String entityId;
  final String action;
  final String? payload;
  final int priority;
  final String status;
  final int attempts;
  final int? lastAttemptAt;
  final String? errorMessage;
  final int createdAt;
  const SyncQueueData(
      {required this.id,
      required this.projectId,
      required this.entityType,
      required this.entityId,
      required this.action,
      this.payload,
      required this.priority,
      required this.status,
      required this.attempts,
      this.lastAttemptAt,
      this.errorMessage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      projectId: Value(projectId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      priority: Value(priority),
      status: Value(status),
      attempts: Value(attempts),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String?>(json['payload']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastAttemptAt: serializer.fromJson<int?>(json['lastAttemptAt']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String?>(payload),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'lastAttemptAt': serializer.toJson<int?>(lastAttemptAt),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? projectId,
          String? entityType,
          String? entityId,
          String? action,
          Value<String?> payload = const Value.absent(),
          int? priority,
          String? status,
          int? attempts,
          Value<int?> lastAttemptAt = const Value.absent(),
          Value<String?> errorMessage = const Value.absent(),
          int? createdAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payload: payload.present ? payload.value : this.payload,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      entityType,
      entityId,
      action,
      payload,
      priority,
      status,
      attempts,
      lastAttemptAt,
      errorMessage,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> payload;
  final Value<int> priority;
  final Value<String> status;
  final Value<int> attempts;
  final Value<int?> lastAttemptAt;
  final Value<String?> errorMessage;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required String projectId,
    required String entityType,
    required String entityId,
    required String action,
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<int>? lastAttemptAt,
    Expression<String>? errorMessage,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String?>? payload,
      Value<int>? priority,
      Value<String>? status,
      Value<int>? attempts,
      Value<int?>? lastAttemptAt,
      Value<String?>? errorMessage,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<int>(lastAttemptAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaData extends DataClass implements Insertable<MetaData> {
  final String key;
  final String value;
  const MetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory MetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaData copyWith({String? key, String? value}) => MetaData(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  MetaData copyWithCompanion(MetaCompanion data) {
    return MetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaData && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<MetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestsTable extends Requests with TableInfo<$RequestsTable, Request> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _requestTypeMeta =
      const VerificationMeta('requestType');
  @override
  late final GeneratedColumn<String> requestType = GeneratedColumn<String>(
      'request_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortSummaryMeta =
      const VerificationMeta('shortSummary');
  @override
  late final GeneratedColumn<String> shortSummary = GeneratedColumn<String>(
      'short_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('PENDING'));
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assigneeIdMeta =
      const VerificationMeta('assigneeId');
  @override
  late final GeneratedColumn<String> assigneeId = GeneratedColumn<String>(
      'assignee_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
      'due_date', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _serverUpdatedAtMeta =
      const VerificationMeta('serverUpdatedAt');
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
      'server_updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
      'meta', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        requestType,
        title,
        shortSummary,
        description,
        status,
        createdBy,
        assigneeId,
        priority,
        location,
        dueDate,
        createdAt,
        updatedAt,
        serverId,
        serverUpdatedAt,
        meta
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests';
  @override
  VerificationContext validateIntegrity(Insertable<Request> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('request_type')) {
      context.handle(
          _requestTypeMeta,
          requestType.isAcceptableOrUnknown(
              data['request_type']!, _requestTypeMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('short_summary')) {
      context.handle(
          _shortSummaryMeta,
          shortSummary.isAcceptableOrUnknown(
              data['short_summary']!, _shortSummaryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('assignee_id')) {
      context.handle(
          _assigneeIdMeta,
          assigneeId.isAcceptableOrUnknown(
              data['assignee_id']!, _assigneeIdMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
          _serverUpdatedAtMeta,
          serverUpdatedAt.isAcceptableOrUnknown(
              data['server_updated_at']!, _serverUpdatedAtMeta));
    }
    if (data.containsKey('meta')) {
      context.handle(
          _metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Request map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Request(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      requestType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}request_type']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      shortSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_summary']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      assigneeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assignee_id']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      serverUpdatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_updated_at']),
      meta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta']),
    );
  }

  @override
  $RequestsTable createAlias(String alias) {
    return $RequestsTable(attachedDatabase, alias);
  }
}

class Request extends DataClass implements Insertable<Request> {
  final String id;
  final String projectId;
  final String? requestType;
  final String title;
  final String? shortSummary;
  final String? description;
  final String status;
  final String createdBy;
  final String? assigneeId;
  final String? priority;
  final String? location;
  final int? dueDate;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final String? meta;
  const Request(
      {required this.id,
      required this.projectId,
      this.requestType,
      required this.title,
      this.shortSummary,
      this.description,
      required this.status,
      required this.createdBy,
      this.assigneeId,
      this.priority,
      this.location,
      this.dueDate,
      required this.createdAt,
      required this.updatedAt,
      this.serverId,
      this.serverUpdatedAt,
      this.meta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || requestType != null) {
      map['request_type'] = Variable<String>(requestType);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || shortSummary != null) {
      map['short_summary'] = Variable<String>(shortSummary);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || assigneeId != null) {
      map['assignee_id'] = Variable<String>(assigneeId);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<int>(dueDate);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<String>(meta);
    }
    return map;
  }

  RequestsCompanion toCompanion(bool nullToAbsent) {
    return RequestsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      requestType: requestType == null && nullToAbsent
          ? const Value.absent()
          : Value(requestType),
      title: Value(title),
      shortSummary: shortSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(shortSummary),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      createdBy: Value(createdBy),
      assigneeId: assigneeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeId),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
    );
  }

  factory Request.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Request(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      requestType: serializer.fromJson<String?>(json['requestType']),
      title: serializer.fromJson<String>(json['title']),
      shortSummary: serializer.fromJson<String?>(json['shortSummary']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      assigneeId: serializer.fromJson<String?>(json['assigneeId']),
      priority: serializer.fromJson<String?>(json['priority']),
      location: serializer.fromJson<String?>(json['location']),
      dueDate: serializer.fromJson<int?>(json['dueDate']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      meta: serializer.fromJson<String?>(json['meta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'requestType': serializer.toJson<String?>(requestType),
      'title': serializer.toJson<String>(title),
      'shortSummary': serializer.toJson<String?>(shortSummary),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'assigneeId': serializer.toJson<String?>(assigneeId),
      'priority': serializer.toJson<String?>(priority),
      'location': serializer.toJson<String?>(location),
      'dueDate': serializer.toJson<int?>(dueDate),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverId': serializer.toJson<String?>(serverId),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'meta': serializer.toJson<String?>(meta),
    };
  }

  Request copyWith(
          {String? id,
          String? projectId,
          Value<String?> requestType = const Value.absent(),
          String? title,
          Value<String?> shortSummary = const Value.absent(),
          Value<String?> description = const Value.absent(),
          String? status,
          String? createdBy,
          Value<String?> assigneeId = const Value.absent(),
          Value<String?> priority = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<int?> dueDate = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<String?> serverId = const Value.absent(),
          Value<int?> serverUpdatedAt = const Value.absent(),
          Value<String?> meta = const Value.absent()}) =>
      Request(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        requestType: requestType.present ? requestType.value : this.requestType,
        title: title ?? this.title,
        shortSummary:
            shortSummary.present ? shortSummary.value : this.shortSummary,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        createdBy: createdBy ?? this.createdBy,
        assigneeId: assigneeId.present ? assigneeId.value : this.assigneeId,
        priority: priority.present ? priority.value : this.priority,
        location: location.present ? location.value : this.location,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        serverId: serverId.present ? serverId.value : this.serverId,
        serverUpdatedAt: serverUpdatedAt.present
            ? serverUpdatedAt.value
            : this.serverUpdatedAt,
        meta: meta.present ? meta.value : this.meta,
      );
  Request copyWithCompanion(RequestsCompanion data) {
    return Request(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      requestType:
          data.requestType.present ? data.requestType.value : this.requestType,
      title: data.title.present ? data.title.value : this.title,
      shortSummary: data.shortSummary.present
          ? data.shortSummary.value
          : this.shortSummary,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      assigneeId:
          data.assigneeId.present ? data.assigneeId.value : this.assigneeId,
      priority: data.priority.present ? data.priority.value : this.priority,
      location: data.location.present ? data.location.value : this.location,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      meta: data.meta.present ? data.meta.value : this.meta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Request(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('requestType: $requestType, ')
          ..write('title: $title, ')
          ..write('shortSummary: $shortSummary, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('priority: $priority, ')
          ..write('location: $location, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      projectId,
      requestType,
      title,
      shortSummary,
      description,
      status,
      createdBy,
      assigneeId,
      priority,
      location,
      dueDate,
      createdAt,
      updatedAt,
      serverId,
      serverUpdatedAt,
      meta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Request &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.requestType == this.requestType &&
          other.title == this.title &&
          other.shortSummary == this.shortSummary &&
          other.description == this.description &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.assigneeId == this.assigneeId &&
          other.priority == this.priority &&
          other.location == this.location &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.meta == this.meta);
}

class RequestsCompanion extends UpdateCompanion<Request> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> requestType;
  final Value<String> title;
  final Value<String?> shortSummary;
  final Value<String?> description;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<String?> assigneeId;
  final Value<String?> priority;
  final Value<String?> location;
  final Value<int?> dueDate;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> serverId;
  final Value<int?> serverUpdatedAt;
  final Value<String?> meta;
  final Value<int> rowid;
  const RequestsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.requestType = const Value.absent(),
    this.title = const Value.absent(),
    this.shortSummary = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.priority = const Value.absent(),
    this.location = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.meta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestsCompanion.insert({
    required String id,
    required String projectId,
    this.requestType = const Value.absent(),
    required String title,
    this.shortSummary = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    required String createdBy,
    this.assigneeId = const Value.absent(),
    this.priority = const Value.absent(),
    this.location = const Value.absent(),
    this.dueDate = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.meta = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        title = Value(title),
        createdBy = Value(createdBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Request> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? requestType,
    Expression<String>? title,
    Expression<String>? shortSummary,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<String>? assigneeId,
    Expression<String>? priority,
    Expression<String>? location,
    Expression<int>? dueDate,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? serverId,
    Expression<int>? serverUpdatedAt,
    Expression<String>? meta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (requestType != null) 'request_type': requestType,
      if (title != null) 'title': title,
      if (shortSummary != null) 'short_summary': shortSummary,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (priority != null) 'priority': priority,
      if (location != null) 'location': location,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (meta != null) 'meta': meta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String?>? requestType,
      Value<String>? title,
      Value<String?>? shortSummary,
      Value<String?>? description,
      Value<String>? status,
      Value<String>? createdBy,
      Value<String?>? assigneeId,
      Value<String?>? priority,
      Value<String?>? location,
      Value<int?>? dueDate,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String?>? serverId,
      Value<int?>? serverUpdatedAt,
      Value<String?>? meta,
      Value<int>? rowid}) {
    return RequestsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      requestType: requestType ?? this.requestType,
      title: title ?? this.title,
      shortSummary: shortSummary ?? this.shortSummary,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      assigneeId: assigneeId ?? this.assigneeId,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      meta: meta ?? this.meta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (requestType.present) {
      map['request_type'] = Variable<String>(requestType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (shortSummary.present) {
      map['short_summary'] = Variable<String>(shortSummary.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (assigneeId.present) {
      map['assignee_id'] = Variable<String>(assigneeId.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('requestType: $requestType, ')
          ..write('title: $title, ')
          ..write('shortSummary: $shortSummary, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('priority: $priority, ')
          ..write('location: $location, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('meta: $meta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, UserTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
      'role_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleDisplayNameMeta =
      const VerificationMeta('roleDisplayName');
  @override
  late final GeneratedColumn<String> roleDisplayName = GeneratedColumn<String>(
      'role_display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _adminMeta = const VerificationMeta('admin');
  @override
  late final GeneratedColumn<bool> admin = GeneratedColumn<bool>(
      'admin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("admin" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mfaEnabledMeta =
      const VerificationMeta('mfaEnabled');
  @override
  late final GeneratedColumn<bool> mfaEnabled = GeneratedColumn<bool>(
      'mfa_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("mfa_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastLoginAtMeta =
      const VerificationMeta('lastLoginAt');
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
      'last_login_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        email,
        role,
        roleId,
        roleDisplayName,
        admin,
        status,
        mfaEnabled,
        lastLoginAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<UserTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(_roleIdMeta,
          roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta));
    }
    if (data.containsKey('role_display_name')) {
      context.handle(
          _roleDisplayNameMeta,
          roleDisplayName.isAcceptableOrUnknown(
              data['role_display_name']!, _roleDisplayNameMeta));
    }
    if (data.containsKey('admin')) {
      context.handle(
          _adminMeta, admin.isAcceptableOrUnknown(data['admin']!, _adminMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('mfa_enabled')) {
      context.handle(
          _mfaEnabledMeta,
          mfaEnabled.isAcceptableOrUnknown(
              data['mfa_enabled']!, _mfaEnabledMeta));
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
          _lastLoginAtMeta,
          lastLoginAt.isAcceptableOrUnknown(
              data['last_login_at']!, _lastLoginAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      roleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role_id']),
      roleDisplayName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}role_display_name']),
      admin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}admin'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      mfaEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}mfa_enabled'])!,
      lastLoginAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_login_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserTableData extends DataClass implements Insertable<UserTableData> {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? roleId;
  final String? roleDisplayName;
  final bool admin;
  final String status;
  final bool mfaEnabled;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const UserTableData(
      {required this.id,
      required this.fullName,
      required this.email,
      required this.role,
      this.roleId,
      this.roleDisplayName,
      required this.admin,
      required this.status,
      required this.mfaEnabled,
      this.lastLoginAt,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['email'] = Variable<String>(email);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || roleId != null) {
      map['role_id'] = Variable<String>(roleId);
    }
    if (!nullToAbsent || roleDisplayName != null) {
      map['role_display_name'] = Variable<String>(roleDisplayName);
    }
    map['admin'] = Variable<bool>(admin);
    map['status'] = Variable<String>(status);
    map['mfa_enabled'] = Variable<bool>(mfaEnabled);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      fullName: Value(fullName),
      email: Value(email),
      role: Value(role),
      roleId:
          roleId == null && nullToAbsent ? const Value.absent() : Value(roleId),
      roleDisplayName: roleDisplayName == null && nullToAbsent
          ? const Value.absent()
          : Value(roleDisplayName),
      admin: Value(admin),
      status: Value(status),
      mfaEnabled: Value(mfaEnabled),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTableData(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String>(json['email']),
      role: serializer.fromJson<String>(json['role']),
      roleId: serializer.fromJson<String?>(json['roleId']),
      roleDisplayName: serializer.fromJson<String?>(json['roleDisplayName']),
      admin: serializer.fromJson<bool>(json['admin']),
      status: serializer.fromJson<String>(json['status']),
      mfaEnabled: serializer.fromJson<bool>(json['mfaEnabled']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String>(email),
      'role': serializer.toJson<String>(role),
      'roleId': serializer.toJson<String?>(roleId),
      'roleDisplayName': serializer.toJson<String?>(roleDisplayName),
      'admin': serializer.toJson<bool>(admin),
      'status': serializer.toJson<String>(status),
      'mfaEnabled': serializer.toJson<bool>(mfaEnabled),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserTableData copyWith(
          {String? id,
          String? fullName,
          String? email,
          String? role,
          Value<String?> roleId = const Value.absent(),
          Value<String?> roleDisplayName = const Value.absent(),
          bool? admin,
          String? status,
          bool? mfaEnabled,
          Value<DateTime?> lastLoginAt = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      UserTableData(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        role: role ?? this.role,
        roleId: roleId.present ? roleId.value : this.roleId,
        roleDisplayName: roleDisplayName.present
            ? roleDisplayName.value
            : this.roleDisplayName,
        admin: admin ?? this.admin,
        status: status ?? this.status,
        mfaEnabled: mfaEnabled ?? this.mfaEnabled,
        lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  UserTableData copyWithCompanion(UsersCompanion data) {
    return UserTableData(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      role: data.role.present ? data.role.value : this.role,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      roleDisplayName: data.roleDisplayName.present
          ? data.roleDisplayName.value
          : this.roleDisplayName,
      admin: data.admin.present ? data.admin.value : this.admin,
      status: data.status.present ? data.status.value : this.status,
      mfaEnabled:
          data.mfaEnabled.present ? data.mfaEnabled.value : this.mfaEnabled,
      lastLoginAt:
          data.lastLoginAt.present ? data.lastLoginAt.value : this.lastLoginAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTableData(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('roleId: $roleId, ')
          ..write('roleDisplayName: $roleDisplayName, ')
          ..write('admin: $admin, ')
          ..write('status: $status, ')
          ..write('mfaEnabled: $mfaEnabled, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fullName,
      email,
      role,
      roleId,
      roleDisplayName,
      admin,
      status,
      mfaEnabled,
      lastLoginAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTableData &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.role == this.role &&
          other.roleId == this.roleId &&
          other.roleDisplayName == this.roleDisplayName &&
          other.admin == this.admin &&
          other.status == this.status &&
          other.mfaEnabled == this.mfaEnabled &&
          other.lastLoginAt == this.lastLoginAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<UserTableData> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String> email;
  final Value<String> role;
  final Value<String?> roleId;
  final Value<String?> roleDisplayName;
  final Value<bool> admin;
  final Value<String> status;
  final Value<bool> mfaEnabled;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.role = const Value.absent(),
    this.roleId = const Value.absent(),
    this.roleDisplayName = const Value.absent(),
    this.admin = const Value.absent(),
    this.status = const Value.absent(),
    this.mfaEnabled = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String fullName,
    required String email,
    required String role,
    this.roleId = const Value.absent(),
    this.roleDisplayName = const Value.absent(),
    this.admin = const Value.absent(),
    required String status,
    this.mfaEnabled = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        email = Value(email),
        role = Value(role),
        status = Value(status);
  static Insertable<UserTableData> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? role,
    Expression<String>? roleId,
    Expression<String>? roleDisplayName,
    Expression<bool>? admin,
    Expression<String>? status,
    Expression<bool>? mfaEnabled,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (role != null) 'role': role,
      if (roleId != null) 'role_id': roleId,
      if (roleDisplayName != null) 'role_display_name': roleDisplayName,
      if (admin != null) 'admin': admin,
      if (status != null) 'status': status,
      if (mfaEnabled != null) 'mfa_enabled': mfaEnabled,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String>? email,
      Value<String>? role,
      Value<String?>? roleId,
      Value<String?>? roleDisplayName,
      Value<bool>? admin,
      Value<String>? status,
      Value<bool>? mfaEnabled,
      Value<DateTime?>? lastLoginAt,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      roleId: roleId ?? this.roleId,
      roleDisplayName: roleDisplayName ?? this.roleDisplayName,
      admin: admin ?? this.admin,
      status: status ?? this.status,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
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
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (roleDisplayName.present) {
      map['role_display_name'] = Variable<String>(roleDisplayName.value);
    }
    if (admin.present) {
      map['admin'] = Variable<bool>(admin.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (mfaEnabled.present) {
      map['mfa_enabled'] = Variable<bool>(mfaEnabled.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('role: $role, ')
          ..write('roleId: $roleId, ')
          ..write('roleDisplayName: $roleDisplayName, ')
          ..write('admin: $admin, ')
          ..write('status: $status, ')
          ..write('mfaEnabled: $mfaEnabled, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final $RequestsTable requests = $RequestsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final MetaDao metaDao = MetaDao(this as AppDatabase);
  late final RequestDao requestDao = RequestDao(this as AppDatabase);
  late final UserDao userDao = UserDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [projects, syncQueue, meta, requests, users];
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String name,
  Value<String?> location,
  Value<String?> metadata,
  Value<int?> lastSynced,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> location,
  Value<String?> metadata,
  Value<int?> lastSynced,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<int> get lastSynced => $composableBuilder(
      column: $table.lastSynced, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int?> lastSynced = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            location: location,
            metadata: metadata,
            lastSynced: lastSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> location = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int?> lastSynced = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            location: location,
            metadata: metadata,
            lastSynced: lastSynced,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required String projectId,
  required String entityType,
  required String entityId,
  required String action,
  Value<String?> payload,
  Value<int> priority,
  Value<String> status,
  Value<int> attempts,
  Value<int?> lastAttemptAt,
  Value<String?> errorMessage,
  required int createdAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String?> payload,
  Value<int> priority,
  Value<String> status,
  Value<int> attempts,
  Value<int?> lastAttemptAt,
  Value<String?> errorMessage,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> lastAttemptAt = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            projectId: projectId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            priority: priority,
            status: status,
            attempts: attempts,
            lastAttemptAt: lastAttemptAt,
            errorMessage: errorMessage,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String entityType,
            required String entityId,
            required String action,
            Value<String?> payload = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int?> lastAttemptAt = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            projectId: projectId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            priority: priority,
            status: status,
            attempts: attempts,
            lastAttemptAt: lastAttemptAt,
            errorMessage: errorMessage,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$MetaTableOrderingComposer extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$MetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MetaTable,
    MetaData,
    $$MetaTableFilterComposer,
    $$MetaTableOrderingComposer,
    $$MetaTableAnnotationComposer,
    $$MetaTableCreateCompanionBuilder,
    $$MetaTableUpdateCompanionBuilder,
    (MetaData, BaseReferences<_$AppDatabase, $MetaTable, MetaData>),
    MetaData,
    PrefetchHooks Function()> {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              MetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MetaTable,
    MetaData,
    $$MetaTableFilterComposer,
    $$MetaTableOrderingComposer,
    $$MetaTableAnnotationComposer,
    $$MetaTableCreateCompanionBuilder,
    $$MetaTableUpdateCompanionBuilder,
    (MetaData, BaseReferences<_$AppDatabase, $MetaTable, MetaData>),
    MetaData,
    PrefetchHooks Function()>;
typedef $$RequestsTableCreateCompanionBuilder = RequestsCompanion Function({
  required String id,
  required String projectId,
  Value<String?> requestType,
  required String title,
  Value<String?> shortSummary,
  Value<String?> description,
  Value<String> status,
  required String createdBy,
  Value<String?> assigneeId,
  Value<String?> priority,
  Value<String?> location,
  Value<int?> dueDate,
  required int createdAt,
  required int updatedAt,
  Value<String?> serverId,
  Value<int?> serverUpdatedAt,
  Value<String?> meta,
  Value<int> rowid,
});
typedef $$RequestsTableUpdateCompanionBuilder = RequestsCompanion Function({
  Value<String> id,
  Value<String> projectId,
  Value<String?> requestType,
  Value<String> title,
  Value<String?> shortSummary,
  Value<String?> description,
  Value<String> status,
  Value<String> createdBy,
  Value<String?> assigneeId,
  Value<String?> priority,
  Value<String?> location,
  Value<int?> dueDate,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String?> serverId,
  Value<int?> serverUpdatedAt,
  Value<String?> meta,
  Value<int> rowid,
});

class $$RequestsTableFilterComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortSummary => $composableBuilder(
      column: $table.shortSummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assigneeId => $composableBuilder(
      column: $table.assigneeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get meta => $composableBuilder(
      column: $table.meta, builder: (column) => ColumnFilters(column));
}

class $$RequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortSummary => $composableBuilder(
      column: $table.shortSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assigneeId => $composableBuilder(
      column: $table.assigneeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get meta => $composableBuilder(
      column: $table.meta, builder: (column) => ColumnOrderings(column));
}

class $$RequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get requestType => $composableBuilder(
      column: $table.requestType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get shortSummary => $composableBuilder(
      column: $table.shortSummary, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get assigneeId => $composableBuilder(
      column: $table.assigneeId, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
      column: $table.serverUpdatedAt, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);
}

class $$RequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RequestsTable,
    Request,
    $$RequestsTableFilterComposer,
    $$RequestsTableOrderingComposer,
    $$RequestsTableAnnotationComposer,
    $$RequestsTableCreateCompanionBuilder,
    $$RequestsTableUpdateCompanionBuilder,
    (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
    Request,
    PrefetchHooks Function()> {
  $$RequestsTableTableManager(_$AppDatabase db, $RequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String?> requestType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> shortSummary = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String?> assigneeId = const Value.absent(),
            Value<String?> priority = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int?> dueDate = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<String?> meta = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RequestsCompanion(
            id: id,
            projectId: projectId,
            requestType: requestType,
            title: title,
            shortSummary: shortSummary,
            description: description,
            status: status,
            createdBy: createdBy,
            assigneeId: assigneeId,
            priority: priority,
            location: location,
            dueDate: dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverId: serverId,
            serverUpdatedAt: serverUpdatedAt,
            meta: meta,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            Value<String?> requestType = const Value.absent(),
            required String title,
            Value<String?> shortSummary = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            required String createdBy,
            Value<String?> assigneeId = const Value.absent(),
            Value<String?> priority = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int?> dueDate = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<String?> serverId = const Value.absent(),
            Value<int?> serverUpdatedAt = const Value.absent(),
            Value<String?> meta = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RequestsCompanion.insert(
            id: id,
            projectId: projectId,
            requestType: requestType,
            title: title,
            shortSummary: shortSummary,
            description: description,
            status: status,
            createdBy: createdBy,
            assigneeId: assigneeId,
            priority: priority,
            location: location,
            dueDate: dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            serverId: serverId,
            serverUpdatedAt: serverUpdatedAt,
            meta: meta,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RequestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RequestsTable,
    Request,
    $$RequestsTableFilterComposer,
    $$RequestsTableOrderingComposer,
    $$RequestsTableAnnotationComposer,
    $$RequestsTableCreateCompanionBuilder,
    $$RequestsTableUpdateCompanionBuilder,
    (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
    Request,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String fullName,
  required String email,
  required String role,
  Value<String?> roleId,
  Value<String?> roleDisplayName,
  Value<bool> admin,
  required String status,
  Value<bool> mfaEnabled,
  Value<DateTime?> lastLoginAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> fullName,
  Value<String> email,
  Value<String> role,
  Value<String?> roleId,
  Value<String?> roleDisplayName,
  Value<bool> admin,
  Value<String> status,
  Value<bool> mfaEnabled,
  Value<DateTime?> lastLoginAt,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roleDisplayName => $composableBuilder(
      column: $table.roleDisplayName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get admin => $composableBuilder(
      column: $table.admin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get mfaEnabled => $composableBuilder(
      column: $table.mfaEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roleId => $composableBuilder(
      column: $table.roleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roleDisplayName => $composableBuilder(
      column: $table.roleDisplayName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get admin => $composableBuilder(
      column: $table.admin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get mfaEnabled => $composableBuilder(
      column: $table.mfaEnabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get roleId =>
      $composableBuilder(column: $table.roleId, builder: (column) => column);

  GeneratedColumn<String> get roleDisplayName => $composableBuilder(
      column: $table.roleDisplayName, builder: (column) => column);

  GeneratedColumn<bool> get admin =>
      $composableBuilder(column: $table.admin, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get mfaEnabled => $composableBuilder(
      column: $table.mfaEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
      column: $table.lastLoginAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    UserTableData,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserTableData, BaseReferences<_$AppDatabase, $UsersTable, UserTableData>),
    UserTableData,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> roleId = const Value.absent(),
            Value<String?> roleDisplayName = const Value.absent(),
            Value<bool> admin = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<bool> mfaEnabled = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            fullName: fullName,
            email: email,
            role: role,
            roleId: roleId,
            roleDisplayName: roleDisplayName,
            admin: admin,
            status: status,
            mfaEnabled: mfaEnabled,
            lastLoginAt: lastLoginAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            required String email,
            required String role,
            Value<String?> roleId = const Value.absent(),
            Value<String?> roleDisplayName = const Value.absent(),
            Value<bool> admin = const Value.absent(),
            required String status,
            Value<bool> mfaEnabled = const Value.absent(),
            Value<DateTime?> lastLoginAt = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            fullName: fullName,
            email: email,
            role: role,
            roleId: roleId,
            roleDisplayName: roleDisplayName,
            admin: admin,
            status: status,
            mfaEnabled: mfaEnabled,
            lastLoginAt: lastLoginAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    UserTableData,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (UserTableData, BaseReferences<_$AppDatabase, $UsersTable, UserTableData>),
    UserTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
  $$RequestsTableTableManager get requests =>
      $$RequestsTableTableManager(_db, _db.requests);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
