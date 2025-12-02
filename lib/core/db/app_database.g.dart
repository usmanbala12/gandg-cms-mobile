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
    'id',
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
    'last_synced',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    metadata,
    lastSynced,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
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
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
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
  const Project({
    required this.id,
    required this.name,
    this.location,
    this.metadata,
    this.lastSynced,
    required this.createdAt,
    required this.updatedAt,
  });
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

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  Project copyWith({
    String? id,
    String? name,
    Value<String?> location = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    Value<int?> lastSynced = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => Project(
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
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
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
    id,
    name,
    location,
    metadata,
    lastSynced,
    createdAt,
    updatedAt,
  );
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
  }) : id = Value(id),
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

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<String?>? metadata,
    Value<int?>? lastSynced,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
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
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<int> lastAttemptAt = GeneratedColumn<int>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
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
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_attempt_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
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
  const SyncQueueData({
    required this.id,
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
    required this.createdAt,
  });
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

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  SyncQueueData copyWith({
    String? id,
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
    int? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    payload: payload.present ? payload.value : this.payload,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
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
    createdAt,
  );
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
  }) : id = Value(id),
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

  SyncQueueCompanion copyWith({
    Value<String>? id,
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
    Value<int>? rowid,
  }) {
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

class $ProjectAnalyticsTable extends ProjectAnalytics
    with TableInfo<$ProjectAnalyticsTable, ProjectAnalytic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectAnalyticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
    'last_synced',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportsCountMeta = const VerificationMeta(
    'reportsCount',
  );
  @override
  late final GeneratedColumn<int> reportsCount = GeneratedColumn<int>(
    'reports_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _requestsPendingMeta = const VerificationMeta(
    'requestsPending',
  );
  @override
  late final GeneratedColumn<int> requestsPending = GeneratedColumn<int>(
    'requests_pending',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openIssuesMeta = const VerificationMeta(
    'openIssues',
  );
  @override
  late final GeneratedColumn<int> openIssues = GeneratedColumn<int>(
    'open_issues',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reportsTimeseriesMeta = const VerificationMeta(
    'reportsTimeseries',
  );
  @override
  late final GeneratedColumn<String> reportsTimeseries =
      GeneratedColumn<String>(
        'reports_timeseries',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _requestsByStatusMeta = const VerificationMeta(
    'requestsByStatus',
  );
  @override
  late final GeneratedColumn<String> requestsByStatus = GeneratedColumn<String>(
    'requests_by_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recentActivityMeta = const VerificationMeta(
    'recentActivity',
  );
  @override
  late final GeneratedColumn<String> recentActivity = GeneratedColumn<String>(
    'recent_activity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    projectId,
    lastSynced,
    reportsCount,
    requestsPending,
    openIssues,
    reportsTimeseries,
    requestsByStatus,
    recentActivity,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_analytics';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectAnalytic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    }
    if (data.containsKey('reports_count')) {
      context.handle(
        _reportsCountMeta,
        reportsCount.isAcceptableOrUnknown(
          data['reports_count']!,
          _reportsCountMeta,
        ),
      );
    }
    if (data.containsKey('requests_pending')) {
      context.handle(
        _requestsPendingMeta,
        requestsPending.isAcceptableOrUnknown(
          data['requests_pending']!,
          _requestsPendingMeta,
        ),
      );
    }
    if (data.containsKey('open_issues')) {
      context.handle(
        _openIssuesMeta,
        openIssues.isAcceptableOrUnknown(data['open_issues']!, _openIssuesMeta),
      );
    }
    if (data.containsKey('reports_timeseries')) {
      context.handle(
        _reportsTimeseriesMeta,
        reportsTimeseries.isAcceptableOrUnknown(
          data['reports_timeseries']!,
          _reportsTimeseriesMeta,
        ),
      );
    }
    if (data.containsKey('requests_by_status')) {
      context.handle(
        _requestsByStatusMeta,
        requestsByStatus.isAcceptableOrUnknown(
          data['requests_by_status']!,
          _requestsByStatusMeta,
        ),
      );
    }
    if (data.containsKey('recent_activity')) {
      context.handle(
        _recentActivityMeta,
        recentActivity.isAcceptableOrUnknown(
          data['recent_activity']!,
          _recentActivityMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {projectId};
  @override
  ProjectAnalytic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectAnalytic(
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced'],
      ),
      reportsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reports_count'],
      )!,
      requestsPending: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requests_pending'],
      )!,
      openIssues: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}open_issues'],
      )!,
      reportsTimeseries: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reports_timeseries'],
      ),
      requestsByStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requests_by_status'],
      ),
      recentActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recent_activity'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProjectAnalyticsTable createAlias(String alias) {
    return $ProjectAnalyticsTable(attachedDatabase, alias);
  }
}

class ProjectAnalytic extends DataClass implements Insertable<ProjectAnalytic> {
  final String projectId;
  final int? lastSynced;
  final int reportsCount;
  final int requestsPending;
  final int openIssues;
  final String? reportsTimeseries;
  final String? requestsByStatus;
  final String? recentActivity;
  final int createdAt;
  final int updatedAt;
  const ProjectAnalytic({
    required this.projectId,
    this.lastSynced,
    required this.reportsCount,
    required this.requestsPending,
    required this.openIssues,
    this.reportsTimeseries,
    this.requestsByStatus,
    this.recentActivity,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || lastSynced != null) {
      map['last_synced'] = Variable<int>(lastSynced);
    }
    map['reports_count'] = Variable<int>(reportsCount);
    map['requests_pending'] = Variable<int>(requestsPending);
    map['open_issues'] = Variable<int>(openIssues);
    if (!nullToAbsent || reportsTimeseries != null) {
      map['reports_timeseries'] = Variable<String>(reportsTimeseries);
    }
    if (!nullToAbsent || requestsByStatus != null) {
      map['requests_by_status'] = Variable<String>(requestsByStatus);
    }
    if (!nullToAbsent || recentActivity != null) {
      map['recent_activity'] = Variable<String>(recentActivity);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProjectAnalyticsCompanion toCompanion(bool nullToAbsent) {
    return ProjectAnalyticsCompanion(
      projectId: Value(projectId),
      lastSynced: lastSynced == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSynced),
      reportsCount: Value(reportsCount),
      requestsPending: Value(requestsPending),
      openIssues: Value(openIssues),
      reportsTimeseries: reportsTimeseries == null && nullToAbsent
          ? const Value.absent()
          : Value(reportsTimeseries),
      requestsByStatus: requestsByStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(requestsByStatus),
      recentActivity: recentActivity == null && nullToAbsent
          ? const Value.absent()
          : Value(recentActivity),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProjectAnalytic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectAnalytic(
      projectId: serializer.fromJson<String>(json['projectId']),
      lastSynced: serializer.fromJson<int?>(json['lastSynced']),
      reportsCount: serializer.fromJson<int>(json['reportsCount']),
      requestsPending: serializer.fromJson<int>(json['requestsPending']),
      openIssues: serializer.fromJson<int>(json['openIssues']),
      reportsTimeseries: serializer.fromJson<String?>(
        json['reportsTimeseries'],
      ),
      requestsByStatus: serializer.fromJson<String?>(json['requestsByStatus']),
      recentActivity: serializer.fromJson<String?>(json['recentActivity']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'lastSynced': serializer.toJson<int?>(lastSynced),
      'reportsCount': serializer.toJson<int>(reportsCount),
      'requestsPending': serializer.toJson<int>(requestsPending),
      'openIssues': serializer.toJson<int>(openIssues),
      'reportsTimeseries': serializer.toJson<String?>(reportsTimeseries),
      'requestsByStatus': serializer.toJson<String?>(requestsByStatus),
      'recentActivity': serializer.toJson<String?>(recentActivity),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ProjectAnalytic copyWith({
    String? projectId,
    Value<int?> lastSynced = const Value.absent(),
    int? reportsCount,
    int? requestsPending,
    int? openIssues,
    Value<String?> reportsTimeseries = const Value.absent(),
    Value<String?> requestsByStatus = const Value.absent(),
    Value<String?> recentActivity = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => ProjectAnalytic(
    projectId: projectId ?? this.projectId,
    lastSynced: lastSynced.present ? lastSynced.value : this.lastSynced,
    reportsCount: reportsCount ?? this.reportsCount,
    requestsPending: requestsPending ?? this.requestsPending,
    openIssues: openIssues ?? this.openIssues,
    reportsTimeseries: reportsTimeseries.present
        ? reportsTimeseries.value
        : this.reportsTimeseries,
    requestsByStatus: requestsByStatus.present
        ? requestsByStatus.value
        : this.requestsByStatus,
    recentActivity: recentActivity.present
        ? recentActivity.value
        : this.recentActivity,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProjectAnalytic copyWithCompanion(ProjectAnalyticsCompanion data) {
    return ProjectAnalytic(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
      reportsCount: data.reportsCount.present
          ? data.reportsCount.value
          : this.reportsCount,
      requestsPending: data.requestsPending.present
          ? data.requestsPending.value
          : this.requestsPending,
      openIssues: data.openIssues.present
          ? data.openIssues.value
          : this.openIssues,
      reportsTimeseries: data.reportsTimeseries.present
          ? data.reportsTimeseries.value
          : this.reportsTimeseries,
      requestsByStatus: data.requestsByStatus.present
          ? data.requestsByStatus.value
          : this.requestsByStatus,
      recentActivity: data.recentActivity.present
          ? data.recentActivity.value
          : this.recentActivity,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectAnalytic(')
          ..write('projectId: $projectId, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('reportsCount: $reportsCount, ')
          ..write('requestsPending: $requestsPending, ')
          ..write('openIssues: $openIssues, ')
          ..write('reportsTimeseries: $reportsTimeseries, ')
          ..write('requestsByStatus: $requestsByStatus, ')
          ..write('recentActivity: $recentActivity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    projectId,
    lastSynced,
    reportsCount,
    requestsPending,
    openIssues,
    reportsTimeseries,
    requestsByStatus,
    recentActivity,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectAnalytic &&
          other.projectId == this.projectId &&
          other.lastSynced == this.lastSynced &&
          other.reportsCount == this.reportsCount &&
          other.requestsPending == this.requestsPending &&
          other.openIssues == this.openIssues &&
          other.reportsTimeseries == this.reportsTimeseries &&
          other.requestsByStatus == this.requestsByStatus &&
          other.recentActivity == this.recentActivity &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectAnalyticsCompanion extends UpdateCompanion<ProjectAnalytic> {
  final Value<String> projectId;
  final Value<int?> lastSynced;
  final Value<int> reportsCount;
  final Value<int> requestsPending;
  final Value<int> openIssues;
  final Value<String?> reportsTimeseries;
  final Value<String?> requestsByStatus;
  final Value<String?> recentActivity;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProjectAnalyticsCompanion({
    this.projectId = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.reportsCount = const Value.absent(),
    this.requestsPending = const Value.absent(),
    this.openIssues = const Value.absent(),
    this.reportsTimeseries = const Value.absent(),
    this.requestsByStatus = const Value.absent(),
    this.recentActivity = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectAnalyticsCompanion.insert({
    required String projectId,
    this.lastSynced = const Value.absent(),
    this.reportsCount = const Value.absent(),
    this.requestsPending = const Value.absent(),
    this.openIssues = const Value.absent(),
    this.reportsTimeseries = const Value.absent(),
    this.requestsByStatus = const Value.absent(),
    this.recentActivity = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : projectId = Value(projectId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectAnalytic> custom({
    Expression<String>? projectId,
    Expression<int>? lastSynced,
    Expression<int>? reportsCount,
    Expression<int>? requestsPending,
    Expression<int>? openIssues,
    Expression<String>? reportsTimeseries,
    Expression<String>? requestsByStatus,
    Expression<String>? recentActivity,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (reportsCount != null) 'reports_count': reportsCount,
      if (requestsPending != null) 'requests_pending': requestsPending,
      if (openIssues != null) 'open_issues': openIssues,
      if (reportsTimeseries != null) 'reports_timeseries': reportsTimeseries,
      if (requestsByStatus != null) 'requests_by_status': requestsByStatus,
      if (recentActivity != null) 'recent_activity': recentActivity,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectAnalyticsCompanion copyWith({
    Value<String>? projectId,
    Value<int?>? lastSynced,
    Value<int>? reportsCount,
    Value<int>? requestsPending,
    Value<int>? openIssues,
    Value<String?>? reportsTimeseries,
    Value<String?>? requestsByStatus,
    Value<String?>? recentActivity,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectAnalyticsCompanion(
      projectId: projectId ?? this.projectId,
      lastSynced: lastSynced ?? this.lastSynced,
      reportsCount: reportsCount ?? this.reportsCount,
      requestsPending: requestsPending ?? this.requestsPending,
      openIssues: openIssues ?? this.openIssues,
      reportsTimeseries: reportsTimeseries ?? this.reportsTimeseries,
      requestsByStatus: requestsByStatus ?? this.requestsByStatus,
      recentActivity: recentActivity ?? this.recentActivity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<int>(lastSynced.value);
    }
    if (reportsCount.present) {
      map['reports_count'] = Variable<int>(reportsCount.value);
    }
    if (requestsPending.present) {
      map['requests_pending'] = Variable<int>(requestsPending.value);
    }
    if (openIssues.present) {
      map['open_issues'] = Variable<int>(openIssues.value);
    }
    if (reportsTimeseries.present) {
      map['reports_timeseries'] = Variable<String>(reportsTimeseries.value);
    }
    if (requestsByStatus.present) {
      map['requests_by_status'] = Variable<String>(requestsByStatus.value);
    }
    if (recentActivity.present) {
      map['recent_activity'] = Variable<String>(recentActivity.value);
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
    return (StringBuffer('ProjectAnalyticsCompanion(')
          ..write('projectId: $projectId, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('reportsCount: $reportsCount, ')
          ..write('requestsPending: $requestsPending, ')
          ..write('openIssues: $openIssues, ')
          ..write('reportsTimeseries: $reportsTimeseries, ')
          ..write('requestsByStatus: $requestsByStatus, ')
          ..write('recentActivity: $recentActivity, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formTemplateIdMeta = const VerificationMeta(
    'formTemplateId',
  );
  @override
  late final GeneratedColumn<String> formTemplateId = GeneratedColumn<String>(
    'form_template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportDateMeta = const VerificationMeta(
    'reportDate',
  );
  @override
  late final GeneratedColumn<int> reportDate = GeneratedColumn<int>(
    'report_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _submissionDataMeta = const VerificationMeta(
    'submissionData',
  );
  @override
  late final GeneratedColumn<String> submissionData = GeneratedColumn<String>(
    'submission_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaIdsMeta = const VerificationMeta(
    'mediaIds',
  );
  @override
  late final GeneratedColumn<String> mediaIds = GeneratedColumn<String>(
    'media_ids',
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
    defaultValue: const Constant('DRAFT'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    formTemplateId,
    reportDate,
    submissionData,
    location,
    mediaIds,
    status,
    createdAt,
    updatedAt,
    serverId,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('form_template_id')) {
      context.handle(
        _formTemplateIdMeta,
        formTemplateId.isAcceptableOrUnknown(
          data['form_template_id']!,
          _formTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('report_date')) {
      context.handle(
        _reportDateMeta,
        reportDate.isAcceptableOrUnknown(data['report_date']!, _reportDateMeta),
      );
    } else if (isInserting) {
      context.missing(_reportDateMeta);
    }
    if (data.containsKey('submission_data')) {
      context.handle(
        _submissionDataMeta,
        submissionData.isAcceptableOrUnknown(
          data['submission_data']!,
          _submissionDataMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('media_ids')) {
      context.handle(
        _mediaIdsMeta,
        mediaIds.isAcceptableOrUnknown(data['media_ids']!, _mediaIdsMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      formTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form_template_id'],
      ),
      reportDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}report_date'],
      )!,
      submissionData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}submission_data'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      mediaIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_ids'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }
}

class Report extends DataClass implements Insertable<Report> {
  final String id;
  final String projectId;
  final String? formTemplateId;
  final int reportDate;
  final String? submissionData;
  final String? location;
  final String? mediaIds;
  final String status;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  const Report({
    required this.id,
    required this.projectId,
    this.formTemplateId,
    required this.reportDate,
    this.submissionData,
    this.location,
    this.mediaIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || formTemplateId != null) {
      map['form_template_id'] = Variable<String>(formTemplateId);
    }
    map['report_date'] = Variable<int>(reportDate);
    if (!nullToAbsent || submissionData != null) {
      map['submission_data'] = Variable<String>(submissionData);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || mediaIds != null) {
      map['media_ids'] = Variable<String>(mediaIds);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      formTemplateId: formTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(formTemplateId),
      reportDate: Value(reportDate),
      submissionData: submissionData == null && nullToAbsent
          ? const Value.absent()
          : Value(submissionData),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      mediaIds: mediaIds == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaIds),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      formTemplateId: serializer.fromJson<String?>(json['formTemplateId']),
      reportDate: serializer.fromJson<int>(json['reportDate']),
      submissionData: serializer.fromJson<String?>(json['submissionData']),
      location: serializer.fromJson<String?>(json['location']),
      mediaIds: serializer.fromJson<String?>(json['mediaIds']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'formTemplateId': serializer.toJson<String?>(formTemplateId),
      'reportDate': serializer.toJson<int>(reportDate),
      'submissionData': serializer.toJson<String?>(submissionData),
      'location': serializer.toJson<String?>(location),
      'mediaIds': serializer.toJson<String?>(mediaIds),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverId': serializer.toJson<String?>(serverId),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
    };
  }

  Report copyWith({
    String? id,
    String? projectId,
    Value<String?> formTemplateId = const Value.absent(),
    int? reportDate,
    Value<String?> submissionData = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<String?> mediaIds = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
    Value<String?> serverId = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
  }) => Report(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    formTemplateId: formTemplateId.present
        ? formTemplateId.value
        : this.formTemplateId,
    reportDate: reportDate ?? this.reportDate,
    submissionData: submissionData.present
        ? submissionData.value
        : this.submissionData,
    location: location.present ? location.value : this.location,
    mediaIds: mediaIds.present ? mediaIds.value : this.mediaIds,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId.present ? serverId.value : this.serverId,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      formTemplateId: data.formTemplateId.present
          ? data.formTemplateId.value
          : this.formTemplateId,
      reportDate: data.reportDate.present
          ? data.reportDate.value
          : this.reportDate,
      submissionData: data.submissionData.present
          ? data.submissionData.value
          : this.submissionData,
      location: data.location.present ? data.location.value : this.location,
      mediaIds: data.mediaIds.present ? data.mediaIds.value : this.mediaIds,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('formTemplateId: $formTemplateId, ')
          ..write('reportDate: $reportDate, ')
          ..write('submissionData: $submissionData, ')
          ..write('location: $location, ')
          ..write('mediaIds: $mediaIds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    formTemplateId,
    reportDate,
    submissionData,
    location,
    mediaIds,
    status,
    createdAt,
    updatedAt,
    serverId,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.formTemplateId == this.formTemplateId &&
          other.reportDate == this.reportDate &&
          other.submissionData == this.submissionData &&
          other.location == this.location &&
          other.mediaIds == this.mediaIds &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> formTemplateId;
  final Value<int> reportDate;
  final Value<String?> submissionData;
  final Value<String?> location;
  final Value<String?> mediaIds;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> serverId;
  final Value<int?> serverUpdatedAt;
  final Value<int> rowid;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.formTemplateId = const Value.absent(),
    this.reportDate = const Value.absent(),
    this.submissionData = const Value.absent(),
    this.location = const Value.absent(),
    this.mediaIds = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReportsCompanion.insert({
    required String id,
    required String projectId,
    this.formTemplateId = const Value.absent(),
    required int reportDate,
    this.submissionData = const Value.absent(),
    this.location = const Value.absent(),
    this.mediaIds = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       reportDate = Value(reportDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Report> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? formTemplateId,
    Expression<int>? reportDate,
    Expression<String>? submissionData,
    Expression<String>? location,
    Expression<String>? mediaIds,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? serverId,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (formTemplateId != null) 'form_template_id': formTemplateId,
      if (reportDate != null) 'report_date': reportDate,
      if (submissionData != null) 'submission_data': submissionData,
      if (location != null) 'location': location,
      if (mediaIds != null) 'media_ids': mediaIds,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String?>? formTemplateId,
    Value<int>? reportDate,
    Value<String?>? submissionData,
    Value<String?>? location,
    Value<String?>? mediaIds,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? serverId,
    Value<int?>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      formTemplateId: formTemplateId ?? this.formTemplateId,
      reportDate: reportDate ?? this.reportDate,
      submissionData: submissionData ?? this.submissionData,
      location: location ?? this.location,
      mediaIds: mediaIds ?? this.mediaIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (formTemplateId.present) {
      map['form_template_id'] = Variable<String>(formTemplateId.value);
    }
    if (reportDate.present) {
      map['report_date'] = Variable<int>(reportDate.value);
    }
    if (submissionData.present) {
      map['submission_data'] = Variable<String>(submissionData.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (mediaIds.present) {
      map['media_ids'] = Variable<String>(mediaIds.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('formTemplateId: $formTemplateId, ')
          ..write('reportDate: $reportDate, ')
          ..write('submissionData: $submissionData, ')
          ..write('location: $location, ')
          ..write('mediaIds: $mediaIds, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssuesTable extends Issues with TableInfo<$IssuesTable, Issue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
    'priority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assigneeIdMeta = const VerificationMeta(
    'assigneeId',
  );
  @override
  late final GeneratedColumn<String> assigneeId = GeneratedColumn<String>(
    'assignee_id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('SYNCED'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    title,
    description,
    priority,
    assigneeId,
    status,
    category,
    location,
    dueDate,
    meta,
    createdAt,
    updatedAt,
    serverId,
    serverUpdatedAt,
    deletedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<Issue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('assignee_id')) {
      context.handle(
        _assigneeIdMeta,
        assigneeId.isAcceptableOrUnknown(data['assignee_id']!, _assigneeIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('meta')) {
      context.handle(
        _metaMeta,
        meta.isAcceptableOrUnknown(data['meta']!, _metaMeta),
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
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Issue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Issue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priority'],
      ),
      assigneeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date'],
      ),
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $IssuesTable createAlias(String alias) {
    return $IssuesTable(attachedDatabase, alias);
  }
}

class Issue extends DataClass implements Insertable<Issue> {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final String? priority;
  final String? assigneeId;
  final String? status;
  final String? category;
  final String? location;
  final int? dueDate;
  final String? meta;
  final int createdAt;
  final int updatedAt;
  final String? serverId;
  final int? serverUpdatedAt;
  final int? deletedAt;
  final String syncStatus;
  const Issue({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.priority,
    this.assigneeId,
    this.status,
    this.category,
    this.location,
    this.dueDate,
    this.meta,
    required this.createdAt,
    required this.updatedAt,
    this.serverId,
    this.serverUpdatedAt,
    this.deletedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || priority != null) {
      map['priority'] = Variable<String>(priority);
    }
    if (!nullToAbsent || assigneeId != null) {
      map['assignee_id'] = Variable<String>(assigneeId);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<int>(dueDate);
    }
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<String>(meta);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  IssuesCompanion toCompanion(bool nullToAbsent) {
    return IssuesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      priority: priority == null && nullToAbsent
          ? const Value.absent()
          : Value(priority),
      assigneeId: assigneeId == null && nullToAbsent
          ? const Value.absent()
          : Value(assigneeId),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Issue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Issue(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      priority: serializer.fromJson<String?>(json['priority']),
      assigneeId: serializer.fromJson<String?>(json['assigneeId']),
      status: serializer.fromJson<String?>(json['status']),
      category: serializer.fromJson<String?>(json['category']),
      location: serializer.fromJson<String?>(json['location']),
      dueDate: serializer.fromJson<int?>(json['dueDate']),
      meta: serializer.fromJson<String?>(json['meta']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<String?>(priority),
      'assigneeId': serializer.toJson<String?>(assigneeId),
      'status': serializer.toJson<String?>(status),
      'category': serializer.toJson<String?>(category),
      'location': serializer.toJson<String?>(location),
      'dueDate': serializer.toJson<int?>(dueDate),
      'meta': serializer.toJson<String?>(meta),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'serverId': serializer.toJson<String?>(serverId),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Issue copyWith({
    String? id,
    String? projectId,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<String?> priority = const Value.absent(),
    Value<String?> assigneeId = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<int?> dueDate = const Value.absent(),
    Value<String?> meta = const Value.absent(),
    int? createdAt,
    int? updatedAt,
    Value<String?> serverId = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    Value<int?> deletedAt = const Value.absent(),
    String? syncStatus,
  }) => Issue(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    priority: priority.present ? priority.value : this.priority,
    assigneeId: assigneeId.present ? assigneeId.value : this.assigneeId,
    status: status.present ? status.value : this.status,
    category: category.present ? category.value : this.category,
    location: location.present ? location.value : this.location,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    meta: meta.present ? meta.value : this.meta,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    serverId: serverId.present ? serverId.value : this.serverId,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Issue copyWithCompanion(IssuesCompanion data) {
    return Issue(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      assigneeId: data.assigneeId.present
          ? data.assigneeId.value
          : this.assigneeId,
      status: data.status.present ? data.status.value : this.status,
      category: data.category.present ? data.category.value : this.category,
      location: data.location.present ? data.location.value : this.location,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      meta: data.meta.present ? data.meta.value : this.meta,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Issue(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('dueDate: $dueDate, ')
          ..write('meta: $meta, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    title,
    description,
    priority,
    assigneeId,
    status,
    category,
    location,
    dueDate,
    meta,
    createdAt,
    updatedAt,
    serverId,
    serverUpdatedAt,
    deletedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Issue &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.assigneeId == this.assigneeId &&
          other.status == this.status &&
          other.category == this.category &&
          other.location == this.location &&
          other.dueDate == this.dueDate &&
          other.meta == this.meta &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.serverId == this.serverId &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class IssuesCompanion extends UpdateCompanion<Issue> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> priority;
  final Value<String?> assigneeId;
  final Value<String?> status;
  final Value<String?> category;
  final Value<String?> location;
  final Value<int?> dueDate;
  final Value<String?> meta;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> serverId;
  final Value<int?> serverUpdatedAt;
  final Value<int?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const IssuesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.meta = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssuesCompanion.insert({
    required String id,
    required String projectId,
    required String title,
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.assigneeId = const Value.absent(),
    this.status = const Value.absent(),
    this.category = const Value.absent(),
    this.location = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.meta = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.serverId = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Issue> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? priority,
    Expression<String>? assigneeId,
    Expression<String>? status,
    Expression<String>? category,
    Expression<String>? location,
    Expression<int>? dueDate,
    Expression<String>? meta,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? serverId,
    Expression<int>? serverUpdatedAt,
    Expression<int>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (status != null) 'status': status,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (dueDate != null) 'due_date': dueDate,
      if (meta != null) 'meta': meta,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (serverId != null) 'server_id': serverId,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssuesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? title,
    Value<String?>? description,
    Value<String?>? priority,
    Value<String?>? assigneeId,
    Value<String?>? status,
    Value<String?>? category,
    Value<String?>? location,
    Value<int?>? dueDate,
    Value<String?>? meta,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? serverId,
    Value<int?>? serverUpdatedAt,
    Value<int?>? deletedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return IssuesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      status: status ?? this.status,
      category: category ?? this.category,
      location: location ?? this.location,
      dueDate: dueDate ?? this.dueDate,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serverId: serverId ?? this.serverId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (assigneeId.present) {
      map['assignee_id'] = Variable<String>(assigneeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssuesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('assigneeId: $assigneeId, ')
          ..write('status: $status, ')
          ..write('category: $category, ')
          ..write('location: $location, ')
          ..write('dueDate: $dueDate, ')
          ..write('meta: $meta, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueCommentsTable extends IssueComments
    with TableInfo<$IssueCommentsTable, IssueComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueLocalIdMeta = const VerificationMeta(
    'issueLocalId',
  );
  @override
  late final GeneratedColumn<String> issueLocalId = GeneratedColumn<String>(
    'issue_local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverCreatedAtMeta = const VerificationMeta(
    'serverCreatedAt',
  );
  @override
  late final GeneratedColumn<int> serverCreatedAt = GeneratedColumn<int>(
    'server_created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  @override
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    defaultValue: const Constant('PENDING'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    issueLocalId,
    authorId,
    body,
    createdAt,
    updatedAt,
    deletedAt,
    serverId,
    serverCreatedAt,
    serverUpdatedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueComment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('issue_local_id')) {
      context.handle(
        _issueLocalIdMeta,
        issueLocalId.isAcceptableOrUnknown(
          data['issue_local_id']!,
          _issueLocalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_issueLocalIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('server_created_at')) {
      context.handle(
        _serverCreatedAtMeta,
        serverCreatedAt.isAcceptableOrUnknown(
          data['server_created_at']!,
          _serverCreatedAtMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IssueComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueComment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      issueLocalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_local_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      serverCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_created_at'],
      ),
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $IssueCommentsTable createAlias(String alias) {
    return $IssueCommentsTable(attachedDatabase, alias);
  }
}

class IssueComment extends DataClass implements Insertable<IssueComment> {
  final String id;
  final String issueLocalId;
  final String authorId;
  final String body;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
  final String? serverId;
  final int? serverCreatedAt;
  final int? serverUpdatedAt;
  final String status;
  const IssueComment({
    required this.id,
    required this.issueLocalId,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.serverId,
    this.serverCreatedAt,
    this.serverUpdatedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['issue_local_id'] = Variable<String>(issueLocalId);
    map['author_id'] = Variable<String>(authorId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || serverCreatedAt != null) {
      map['server_created_at'] = Variable<int>(serverCreatedAt);
    }
    if (!nullToAbsent || serverUpdatedAt != null) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  IssueCommentsCompanion toCompanion(bool nullToAbsent) {
    return IssueCommentsCompanion(
      id: Value(id),
      issueLocalId: Value(issueLocalId),
      authorId: Value(authorId),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      serverCreatedAt: serverCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverCreatedAt),
      serverUpdatedAt: serverUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUpdatedAt),
      status: Value(status),
    );
  }

  factory IssueComment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueComment(
      id: serializer.fromJson<String>(json['id']),
      issueLocalId: serializer.fromJson<String>(json['issueLocalId']),
      authorId: serializer.fromJson<String>(json['authorId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      serverCreatedAt: serializer.fromJson<int?>(json['serverCreatedAt']),
      serverUpdatedAt: serializer.fromJson<int?>(json['serverUpdatedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'issueLocalId': serializer.toJson<String>(issueLocalId),
      'authorId': serializer.toJson<String>(authorId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
      'serverId': serializer.toJson<String?>(serverId),
      'serverCreatedAt': serializer.toJson<int?>(serverCreatedAt),
      'serverUpdatedAt': serializer.toJson<int?>(serverUpdatedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  IssueComment copyWith({
    String? id,
    String? issueLocalId,
    String? authorId,
    String? body,
    int? createdAt,
    int? updatedAt,
    Value<int?> deletedAt = const Value.absent(),
    Value<String?> serverId = const Value.absent(),
    Value<int?> serverCreatedAt = const Value.absent(),
    Value<int?> serverUpdatedAt = const Value.absent(),
    String? status,
  }) => IssueComment(
    id: id ?? this.id,
    issueLocalId: issueLocalId ?? this.issueLocalId,
    authorId: authorId ?? this.authorId,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    serverId: serverId.present ? serverId.value : this.serverId,
    serverCreatedAt: serverCreatedAt.present
        ? serverCreatedAt.value
        : this.serverCreatedAt,
    serverUpdatedAt: serverUpdatedAt.present
        ? serverUpdatedAt.value
        : this.serverUpdatedAt,
    status: status ?? this.status,
  );
  IssueComment copyWithCompanion(IssueCommentsCompanion data) {
    return IssueComment(
      id: data.id.present ? data.id.value : this.id,
      issueLocalId: data.issueLocalId.present
          ? data.issueLocalId.value
          : this.issueLocalId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverCreatedAt: data.serverCreatedAt.present
          ? data.serverCreatedAt.value
          : this.serverCreatedAt,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueComment(')
          ..write('id: $id, ')
          ..write('issueLocalId: $issueLocalId, ')
          ..write('authorId: $authorId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    issueLocalId,
    authorId,
    body,
    createdAt,
    updatedAt,
    deletedAt,
    serverId,
    serverCreatedAt,
    serverUpdatedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueComment &&
          other.id == this.id &&
          other.issueLocalId == this.issueLocalId &&
          other.authorId == this.authorId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.serverId == this.serverId &&
          other.serverCreatedAt == this.serverCreatedAt &&
          other.serverUpdatedAt == this.serverUpdatedAt &&
          other.status == this.status);
}

class IssueCommentsCompanion extends UpdateCompanion<IssueComment> {
  final Value<String> id;
  final Value<String> issueLocalId;
  final Value<String> authorId;
  final Value<String> body;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> deletedAt;
  final Value<String?> serverId;
  final Value<int?> serverCreatedAt;
  final Value<int?> serverUpdatedAt;
  final Value<String> status;
  final Value<int> rowid;
  const IssueCommentsCompanion({
    this.id = const Value.absent(),
    this.issueLocalId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverCreatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueCommentsCompanion.insert({
    required String id,
    required String issueLocalId,
    required String authorId,
    required String body,
    required int createdAt,
    required int updatedAt,
    this.deletedAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverCreatedAt = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       issueLocalId = Value(issueLocalId),
       authorId = Value(authorId),
       body = Value(body),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<IssueComment> custom({
    Expression<String>? id,
    Expression<String>? issueLocalId,
    Expression<String>? authorId,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? serverId,
    Expression<int>? serverCreatedAt,
    Expression<int>? serverUpdatedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (issueLocalId != null) 'issue_local_id': issueLocalId,
      if (authorId != null) 'author_id': authorId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (serverId != null) 'server_id': serverId,
      if (serverCreatedAt != null) 'server_created_at': serverCreatedAt,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueCommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? issueLocalId,
    Value<String>? authorId,
    Value<String>? body,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int?>? deletedAt,
    Value<String?>? serverId,
    Value<int?>? serverCreatedAt,
    Value<int?>? serverUpdatedAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return IssueCommentsCompanion(
      id: id ?? this.id,
      issueLocalId: issueLocalId ?? this.issueLocalId,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      serverId: serverId ?? this.serverId,
      serverCreatedAt: serverCreatedAt ?? this.serverCreatedAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (issueLocalId.present) {
      map['issue_local_id'] = Variable<String>(issueLocalId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (serverCreatedAt.present) {
      map['server_created_at'] = Variable<int>(serverCreatedAt.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueCommentsCompanion(')
          ..write('id: $id, ')
          ..write('issueLocalId: $issueLocalId, ')
          ..write('authorId: $authorId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('serverId: $serverId, ')
          ..write('serverCreatedAt: $serverCreatedAt, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueHistoryTable extends IssueHistory
    with TableInfo<$IssueHistoryTable, IssueHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<String> issueId = GeneratedColumn<String>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<String> authorId = GeneratedColumn<String>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    issueId,
    action,
    field,
    oldValue,
    newValue,
    authorId,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IssueHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      ),
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $IssueHistoryTable createAlias(String alias) {
    return $IssueHistoryTable(attachedDatabase, alias);
  }
}

class IssueHistoryData extends DataClass
    implements Insertable<IssueHistoryData> {
  final String id;
  final String issueId;
  final String action;
  final String? field;
  final String? oldValue;
  final String? newValue;
  final String authorId;
  final int timestamp;
  const IssueHistoryData({
    required this.id,
    required this.issueId,
    required this.action,
    this.field,
    this.oldValue,
    this.newValue,
    required this.authorId,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['issue_id'] = Variable<String>(issueId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || field != null) {
      map['field'] = Variable<String>(field);
    }
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['author_id'] = Variable<String>(authorId);
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  IssueHistoryCompanion toCompanion(bool nullToAbsent) {
    return IssueHistoryCompanion(
      id: Value(id),
      issueId: Value(issueId),
      action: Value(action),
      field: field == null && nullToAbsent
          ? const Value.absent()
          : Value(field),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      authorId: Value(authorId),
      timestamp: Value(timestamp),
    );
  }

  factory IssueHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueHistoryData(
      id: serializer.fromJson<String>(json['id']),
      issueId: serializer.fromJson<String>(json['issueId']),
      action: serializer.fromJson<String>(json['action']),
      field: serializer.fromJson<String?>(json['field']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      authorId: serializer.fromJson<String>(json['authorId']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'issueId': serializer.toJson<String>(issueId),
      'action': serializer.toJson<String>(action),
      'field': serializer.toJson<String?>(field),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'authorId': serializer.toJson<String>(authorId),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  IssueHistoryData copyWith({
    String? id,
    String? issueId,
    String? action,
    Value<String?> field = const Value.absent(),
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    String? authorId,
    int? timestamp,
  }) => IssueHistoryData(
    id: id ?? this.id,
    issueId: issueId ?? this.issueId,
    action: action ?? this.action,
    field: field.present ? field.value : this.field,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    authorId: authorId ?? this.authorId,
    timestamp: timestamp ?? this.timestamp,
  );
  IssueHistoryData copyWithCompanion(IssueHistoryCompanion data) {
    return IssueHistoryData(
      id: data.id.present ? data.id.value : this.id,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      action: data.action.present ? data.action.value : this.action,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueHistoryData(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('action: $action, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('authorId: $authorId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    issueId,
    action,
    field,
    oldValue,
    newValue,
    authorId,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueHistoryData &&
          other.id == this.id &&
          other.issueId == this.issueId &&
          other.action == this.action &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.authorId == this.authorId &&
          other.timestamp == this.timestamp);
}

class IssueHistoryCompanion extends UpdateCompanion<IssueHistoryData> {
  final Value<String> id;
  final Value<String> issueId;
  final Value<String> action;
  final Value<String?> field;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String> authorId;
  final Value<int> timestamp;
  final Value<int> rowid;
  const IssueHistoryCompanion({
    this.id = const Value.absent(),
    this.issueId = const Value.absent(),
    this.action = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.authorId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueHistoryCompanion.insert({
    required String id,
    required String issueId,
    required String action,
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required String authorId,
    required int timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       issueId = Value(issueId),
       action = Value(action),
       authorId = Value(authorId),
       timestamp = Value(timestamp);
  static Insertable<IssueHistoryData> custom({
    Expression<String>? id,
    Expression<String>? issueId,
    Expression<String>? action,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? authorId,
    Expression<int>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (issueId != null) 'issue_id': issueId,
      if (action != null) 'action': action,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (authorId != null) 'author_id': authorId,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? issueId,
    Value<String>? action,
    Value<String?>? field,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String>? authorId,
    Value<int>? timestamp,
    Value<int>? rowid,
  }) {
    return IssueHistoryCompanion(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      action: action ?? this.action,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      authorId: authorId ?? this.authorId,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<String>(issueId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<String>(authorId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueHistoryCompanion(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('action: $action, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('authorId: $authorId, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueMediaTable extends IssueMedia
    with TableInfo<$IssueMediaTable, IssueMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<String> issueId = GeneratedColumn<String>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadStatusMeta = const VerificationMeta(
    'uploadStatus',
  );
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    issueId,
    localPath,
    thumbnailPath,
    mimeType,
    sizeBytes,
    serverId,
    serverUrl,
    uploadStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueMediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    }
    if (data.containsKey('upload_status')) {
      context.handle(
        _uploadStatusMeta,
        uploadStatus.isAcceptableOrUnknown(
          data['upload_status']!,
          _uploadStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IssueMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueMediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      ),
      uploadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_status'],
      )!,
    );
  }

  @override
  $IssueMediaTable createAlias(String alias) {
    return $IssueMediaTable(attachedDatabase, alias);
  }
}

class IssueMediaData extends DataClass implements Insertable<IssueMediaData> {
  final String id;
  final String issueId;
  final String localPath;
  final String? thumbnailPath;
  final String mimeType;
  final int sizeBytes;
  final String? serverId;
  final String? serverUrl;
  final String uploadStatus;
  const IssueMediaData({
    required this.id,
    required this.issueId,
    required this.localPath,
    this.thumbnailPath,
    required this.mimeType,
    required this.sizeBytes,
    this.serverId,
    this.serverUrl,
    required this.uploadStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['issue_id'] = Variable<String>(issueId);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    map['upload_status'] = Variable<String>(uploadStatus);
    return map;
  }

  IssueMediaCompanion toCompanion(bool nullToAbsent) {
    return IssueMediaCompanion(
      id: Value(id),
      issueId: Value(issueId),
      localPath: Value(localPath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      uploadStatus: Value(uploadStatus),
    );
  }

  factory IssueMediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueMediaData(
      id: serializer.fromJson<String>(json['id']),
      issueId: serializer.fromJson<String>(json['issueId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'issueId': serializer.toJson<String>(issueId),
      'localPath': serializer.toJson<String>(localPath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'serverId': serializer.toJson<String?>(serverId),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
    };
  }

  IssueMediaData copyWith({
    String? id,
    String? issueId,
    String? localPath,
    Value<String?> thumbnailPath = const Value.absent(),
    String? mimeType,
    int? sizeBytes,
    Value<String?> serverId = const Value.absent(),
    Value<String?> serverUrl = const Value.absent(),
    String? uploadStatus,
  }) => IssueMediaData(
    id: id ?? this.id,
    issueId: issueId ?? this.issueId,
    localPath: localPath ?? this.localPath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    serverId: serverId.present ? serverId.value : this.serverId,
    serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
    uploadStatus: uploadStatus ?? this.uploadStatus,
  );
  IssueMediaData copyWithCompanion(IssueMediaCompanion data) {
    return IssueMediaData(
      id: data.id.present ? data.id.value : this.id,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueMediaData(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('serverId: $serverId, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('uploadStatus: $uploadStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    issueId,
    localPath,
    thumbnailPath,
    mimeType,
    sizeBytes,
    serverId,
    serverUrl,
    uploadStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueMediaData &&
          other.id == this.id &&
          other.issueId == this.issueId &&
          other.localPath == this.localPath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.serverId == this.serverId &&
          other.serverUrl == this.serverUrl &&
          other.uploadStatus == this.uploadStatus);
}

class IssueMediaCompanion extends UpdateCompanion<IssueMediaData> {
  final Value<String> id;
  final Value<String> issueId;
  final Value<String> localPath;
  final Value<String?> thumbnailPath;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> serverId;
  final Value<String?> serverUrl;
  final Value<String> uploadStatus;
  final Value<int> rowid;
  const IssueMediaCompanion({
    this.id = const Value.absent(),
    this.issueId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.serverId = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueMediaCompanion.insert({
    required String id,
    required String issueId,
    required String localPath,
    this.thumbnailPath = const Value.absent(),
    required String mimeType,
    required int sizeBytes,
    this.serverId = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       issueId = Value(issueId),
       localPath = Value(localPath),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<IssueMediaData> custom({
    Expression<String>? id,
    Expression<String>? issueId,
    Expression<String>? localPath,
    Expression<String>? thumbnailPath,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? serverId,
    Expression<String>? serverUrl,
    Expression<String>? uploadStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (issueId != null) 'issue_id': issueId,
      if (localPath != null) 'local_path': localPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (serverId != null) 'server_id': serverId,
      if (serverUrl != null) 'server_url': serverUrl,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueMediaCompanion copyWith({
    Value<String>? id,
    Value<String>? issueId,
    Value<String>? localPath,
    Value<String?>? thumbnailPath,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? serverId,
    Value<String?>? serverUrl,
    Value<String>? uploadStatus,
    Value<int>? rowid,
  }) {
    return IssueMediaCompanion(
      id: id ?? this.id,
      issueId: issueId ?? this.issueId,
      localPath: localPath ?? this.localPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      serverId: serverId ?? this.serverId,
      serverUrl: serverUrl ?? this.serverUrl,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<String>(issueId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueMediaCompanion(')
          ..write('id: $id, ')
          ..write('issueId: $issueId, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('serverId: $serverId, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentTypeMeta = const VerificationMeta(
    'parentType',
  );
  @override
  late final GeneratedColumn<String> parentType = GeneratedColumn<String>(
    'parent_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadStatusMeta = const VerificationMeta(
    'uploadStatus',
  );
  @override
  late final GeneratedColumn<String> uploadStatus = GeneratedColumn<String>(
    'upload_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localPath,
    projectId,
    parentType,
    parentId,
    uploadStatus,
    mime,
    size,
    createdAt,
    serverId,
    thumbnailPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('parent_type')) {
      context.handle(
        _parentTypeMeta,
        parentType.isAcceptableOrUnknown(data['parent_type']!, _parentTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_parentTypeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('upload_status')) {
      context.handle(
        _uploadStatusMeta,
        uploadStatus.isAcceptableOrUnknown(
          data['upload_status']!,
          _uploadStatusMeta,
        ),
      );
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      parentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_type'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      )!,
      uploadStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upload_status'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  final String id;
  final String localPath;
  final String projectId;
  final String parentType;
  final String parentId;
  final String uploadStatus;
  final String? mime;
  final int size;
  final int createdAt;
  final String? serverId;
  final String? thumbnailPath;
  const MediaFile({
    required this.id,
    required this.localPath,
    required this.projectId,
    required this.parentType,
    required this.parentId,
    required this.uploadStatus,
    this.mime,
    required this.size,
    required this.createdAt,
    this.serverId,
    this.thumbnailPath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_path'] = Variable<String>(localPath);
    map['project_id'] = Variable<String>(projectId);
    map['parent_type'] = Variable<String>(parentType);
    map['parent_id'] = Variable<String>(parentId);
    map['upload_status'] = Variable<String>(uploadStatus);
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    map['size'] = Variable<int>(size);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      localPath: Value(localPath),
      projectId: Value(projectId),
      parentType: Value(parentType),
      parentId: Value(parentId),
      uploadStatus: Value(uploadStatus),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      size: Value(size),
      createdAt: Value(createdAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
    );
  }

  factory MediaFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      id: serializer.fromJson<String>(json['id']),
      localPath: serializer.fromJson<String>(json['localPath']),
      projectId: serializer.fromJson<String>(json['projectId']),
      parentType: serializer.fromJson<String>(json['parentType']),
      parentId: serializer.fromJson<String>(json['parentId']),
      uploadStatus: serializer.fromJson<String>(json['uploadStatus']),
      mime: serializer.fromJson<String?>(json['mime']),
      size: serializer.fromJson<int>(json['size']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localPath': serializer.toJson<String>(localPath),
      'projectId': serializer.toJson<String>(projectId),
      'parentType': serializer.toJson<String>(parentType),
      'parentId': serializer.toJson<String>(parentId),
      'uploadStatus': serializer.toJson<String>(uploadStatus),
      'mime': serializer.toJson<String?>(mime),
      'size': serializer.toJson<int>(size),
      'createdAt': serializer.toJson<int>(createdAt),
      'serverId': serializer.toJson<String?>(serverId),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
    };
  }

  MediaFile copyWith({
    String? id,
    String? localPath,
    String? projectId,
    String? parentType,
    String? parentId,
    String? uploadStatus,
    Value<String?> mime = const Value.absent(),
    int? size,
    int? createdAt,
    Value<String?> serverId = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
  }) => MediaFile(
    id: id ?? this.id,
    localPath: localPath ?? this.localPath,
    projectId: projectId ?? this.projectId,
    parentType: parentType ?? this.parentType,
    parentId: parentId ?? this.parentId,
    uploadStatus: uploadStatus ?? this.uploadStatus,
    mime: mime.present ? mime.value : this.mime,
    size: size ?? this.size,
    createdAt: createdAt ?? this.createdAt,
    serverId: serverId.present ? serverId.value : this.serverId,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
  );
  MediaFile copyWithCompanion(MediaFilesCompanion data) {
    return MediaFile(
      id: data.id.present ? data.id.value : this.id,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      parentType: data.parentType.present
          ? data.parentType.value
          : this.parentType,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      uploadStatus: data.uploadStatus.present
          ? data.uploadStatus.value
          : this.uploadStatus,
      mime: data.mime.present ? data.mime.value : this.mime,
      size: data.size.present ? data.size.value : this.size,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('projectId: $projectId, ')
          ..write('parentType: $parentType, ')
          ..write('parentId: $parentId, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverId: $serverId, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localPath,
    projectId,
    parentType,
    parentId,
    uploadStatus,
    mime,
    size,
    createdAt,
    serverId,
    thumbnailPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.id == this.id &&
          other.localPath == this.localPath &&
          other.projectId == this.projectId &&
          other.parentType == this.parentType &&
          other.parentId == this.parentId &&
          other.uploadStatus == this.uploadStatus &&
          other.mime == this.mime &&
          other.size == this.size &&
          other.createdAt == this.createdAt &&
          other.serverId == this.serverId &&
          other.thumbnailPath == this.thumbnailPath);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFile> {
  final Value<String> id;
  final Value<String> localPath;
  final Value<String> projectId;
  final Value<String> parentType;
  final Value<String> parentId;
  final Value<String> uploadStatus;
  final Value<String?> mime;
  final Value<int> size;
  final Value<int> createdAt;
  final Value<String?> serverId;
  final Value<String?> thumbnailPath;
  final Value<int> rowid;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.localPath = const Value.absent(),
    this.projectId = const Value.absent(),
    this.parentType = const Value.absent(),
    this.parentId = const Value.absent(),
    this.uploadStatus = const Value.absent(),
    this.mime = const Value.absent(),
    this.size = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    required String id,
    required String localPath,
    required String projectId,
    required String parentType,
    required String parentId,
    this.uploadStatus = const Value.absent(),
    this.mime = const Value.absent(),
    required int size,
    required int createdAt,
    this.serverId = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localPath = Value(localPath),
       projectId = Value(projectId),
       parentType = Value(parentType),
       parentId = Value(parentId),
       size = Value(size),
       createdAt = Value(createdAt);
  static Insertable<MediaFile> custom({
    Expression<String>? id,
    Expression<String>? localPath,
    Expression<String>? projectId,
    Expression<String>? parentType,
    Expression<String>? parentId,
    Expression<String>? uploadStatus,
    Expression<String>? mime,
    Expression<int>? size,
    Expression<int>? createdAt,
    Expression<String>? serverId,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localPath != null) 'local_path': localPath,
      if (projectId != null) 'project_id': projectId,
      if (parentType != null) 'parent_type': parentType,
      if (parentId != null) 'parent_id': parentId,
      if (uploadStatus != null) 'upload_status': uploadStatus,
      if (mime != null) 'mime': mime,
      if (size != null) 'size': size,
      if (createdAt != null) 'created_at': createdAt,
      if (serverId != null) 'server_id': serverId,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? localPath,
    Value<String>? projectId,
    Value<String>? parentType,
    Value<String>? parentId,
    Value<String>? uploadStatus,
    Value<String?>? mime,
    Value<int>? size,
    Value<int>? createdAt,
    Value<String?>? serverId,
    Value<String?>? thumbnailPath,
    Value<int>? rowid,
  }) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      projectId: projectId ?? this.projectId,
      parentType: parentType ?? this.parentType,
      parentId: parentId ?? this.parentId,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      mime: mime ?? this.mime,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (parentType.present) {
      map['parent_type'] = Variable<String>(parentType.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (uploadStatus.present) {
      map['upload_status'] = Variable<String>(uploadStatus.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('localPath: $localPath, ')
          ..write('projectId: $projectId, ')
          ..write('parentType: $parentType, ')
          ..write('parentId: $parentId, ')
          ..write('uploadStatus: $uploadStatus, ')
          ..write('mime: $mime, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverId: $serverId, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverPayloadMeta = const VerificationMeta(
    'serverPayload',
  );
  @override
  late final GeneratedColumn<String> serverPayload = GeneratedColumn<String>(
    'server_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<int> detectedAt = GeneratedColumn<int>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<int> resolved = GeneratedColumn<int>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    localPayload,
    serverPayload,
    detectedAt,
    resolved,
    resolution,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('server_payload')) {
      context.handle(
        _serverPayloadMeta,
        serverPayload.isAcceptableOrUnknown(
          data['server_payload']!,
          _serverPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverPayloadMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
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
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      serverPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_payload'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_at'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String id;
  final String entityType;
  final String entityId;
  final String localPayload;
  final String serverPayload;
  final int detectedAt;
  final int resolved;
  final String? resolution;
  final int createdAt;
  const SyncConflict({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localPayload,
    required this.serverPayload,
    required this.detectedAt,
    required this.resolved,
    this.resolution,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_payload'] = Variable<String>(localPayload);
    map['server_payload'] = Variable<String>(serverPayload);
    map['detected_at'] = Variable<int>(detectedAt);
    map['resolved'] = Variable<int>(resolved);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localPayload: Value(localPayload),
      serverPayload: Value(serverPayload),
      detectedAt: Value(detectedAt),
      resolved: Value(resolved),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      createdAt: Value(createdAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      serverPayload: serializer.fromJson<String>(json['serverPayload']),
      detectedAt: serializer.fromJson<int>(json['detectedAt']),
      resolved: serializer.fromJson<int>(json['resolved']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localPayload': serializer.toJson<String>(localPayload),
      'serverPayload': serializer.toJson<String>(serverPayload),
      'detectedAt': serializer.toJson<int>(detectedAt),
      'resolved': serializer.toJson<int>(resolved),
      'resolution': serializer.toJson<String?>(resolution),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? localPayload,
    String? serverPayload,
    int? detectedAt,
    int? resolved,
    Value<String?> resolution = const Value.absent(),
    int? createdAt,
  }) => SyncConflict(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localPayload: localPayload ?? this.localPayload,
    serverPayload: serverPayload ?? this.serverPayload,
    detectedAt: detectedAt ?? this.detectedAt,
    resolved: resolved ?? this.resolved,
    resolution: resolution.present ? resolution.value : this.resolution,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      serverPayload: data.serverPayload.present
          ? data.serverPayload.value
          : this.serverPayload,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolved: $resolved, ')
          ..write('resolution: $resolution, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    localPayload,
    serverPayload,
    detectedAt,
    resolved,
    resolution,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localPayload == this.localPayload &&
          other.serverPayload == this.serverPayload &&
          other.detectedAt == this.detectedAt &&
          other.resolved == this.resolved &&
          other.resolution == this.resolution &&
          other.createdAt == this.createdAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localPayload;
  final Value<String> serverPayload;
  final Value<int> detectedAt;
  final Value<int> resolved;
  final Value<String?> resolution;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.serverPayload = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolved = const Value.absent(),
    this.resolution = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String localPayload,
    required String serverPayload,
    required int detectedAt,
    this.resolved = const Value.absent(),
    this.resolution = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localPayload = Value(localPayload),
       serverPayload = Value(serverPayload),
       detectedAt = Value(detectedAt),
       createdAt = Value(createdAt);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localPayload,
    Expression<String>? serverPayload,
    Expression<int>? detectedAt,
    Expression<int>? resolved,
    Expression<String>? resolution,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localPayload != null) 'local_payload': localPayload,
      if (serverPayload != null) 'server_payload': serverPayload,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolved != null) 'resolved': resolved,
      if (resolution != null) 'resolution': resolution,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localPayload,
    Value<String>? serverPayload,
    Value<int>? detectedAt,
    Value<int>? resolved,
    Value<String?>? resolution,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localPayload: localPayload ?? this.localPayload,
      serverPayload: serverPayload ?? this.serverPayload,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolution: resolution ?? this.resolution,
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
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (serverPayload.present) {
      map['server_payload'] = Variable<String>(serverPayload.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<int>(detectedAt.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<int>(resolved.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
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
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayload: $localPayload, ')
          ..write('serverPayload: $serverPayload, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolved: $resolved, ')
          ..write('resolution: $resolution, ')
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
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
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
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
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
    return MetaCompanion(key: Value(key), value: Value(value));
  }

  factory MetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
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

  MetaData copyWith({String? key, String? value}) =>
      MetaData(key: key ?? this.key, value: value ?? this.value);
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
  }) : key = Value(key),
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

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
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

class $FormTemplatesTable extends FormTemplates
    with TableInfo<$FormTemplatesTable, FormTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _schemaMeta = const VerificationMeta('schema');
  @override
  late final GeneratedColumn<String> schema = GeneratedColumn<String>(
    'schema',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  @override
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, schema, version, lastSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'form_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('schema')) {
      context.handle(
        _schemaMeta,
        schema.isAcceptableOrUnknown(data['schema']!, _schemaMeta),
      );
    } else if (isInserting) {
      context.missing(_schemaMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      schema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schema'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced'],
      )!,
    );
  }

  @override
  $FormTemplatesTable createAlias(String alias) {
    return $FormTemplatesTable(attachedDatabase, alias);
  }
}

class FormTemplate extends DataClass implements Insertable<FormTemplate> {
  final String id;
  final String name;
  final String schema;
  final int version;
  final int lastSynced;
  const FormTemplate({
    required this.id,
    required this.name,
    required this.schema,
    required this.version,
    required this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['schema'] = Variable<String>(schema);
    map['version'] = Variable<int>(version);
    map['last_synced'] = Variable<int>(lastSynced);
    return map;
  }

  FormTemplatesCompanion toCompanion(bool nullToAbsent) {
    return FormTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      schema: Value(schema),
      version: Value(version),
      lastSynced: Value(lastSynced),
    );
  }

  factory FormTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      schema: serializer.fromJson<String>(json['schema']),
      version: serializer.fromJson<int>(json['version']),
      lastSynced: serializer.fromJson<int>(json['lastSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'schema': serializer.toJson<String>(schema),
      'version': serializer.toJson<int>(version),
      'lastSynced': serializer.toJson<int>(lastSynced),
    };
  }

  FormTemplate copyWith({
    String? id,
    String? name,
    String? schema,
    int? version,
    int? lastSynced,
  }) => FormTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    schema: schema ?? this.schema,
    version: version ?? this.version,
    lastSynced: lastSynced ?? this.lastSynced,
  );
  FormTemplate copyWithCompanion(FormTemplatesCompanion data) {
    return FormTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      schema: data.schema.present ? data.schema.value : this.schema,
      version: data.version.present ? data.version.value : this.version,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('schema: $schema, ')
          ..write('version: $version, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, schema, version, lastSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.schema == this.schema &&
          other.version == this.version &&
          other.lastSynced == this.lastSynced);
}

class FormTemplatesCompanion extends UpdateCompanion<FormTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> schema;
  final Value<int> version;
  final Value<int> lastSynced;
  final Value<int> rowid;
  const FormTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.schema = const Value.absent(),
    this.version = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormTemplatesCompanion.insert({
    required String id,
    required String name,
    required String schema,
    this.version = const Value.absent(),
    required int lastSynced,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       schema = Value(schema),
       lastSynced = Value(lastSynced);
  static Insertable<FormTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? schema,
    Expression<int>? version,
    Expression<int>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (schema != null) 'schema': schema,
      if (version != null) 'version': version,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? schema,
    Value<int>? version,
    Value<int>? lastSynced,
    Value<int>? rowid,
  }) {
    return FormTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      schema: schema ?? this.schema,
      version: version ?? this.version,
      lastSynced: lastSynced ?? this.lastSynced,
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
    if (schema.present) {
      map['schema'] = Variable<String>(schema.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<int>(lastSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('schema: $schema, ')
          ..write('version: $version, ')
          ..write('lastSynced: $lastSynced, ')
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
  late final $ProjectAnalyticsTable projectAnalytics = $ProjectAnalyticsTable(
    this,
  );
  late final $ReportsTable reports = $ReportsTable(this);
  late final $IssuesTable issues = $IssuesTable(this);
  late final $IssueCommentsTable issueComments = $IssueCommentsTable(this);
  late final $IssueHistoryTable issueHistory = $IssueHistoryTable(this);
  late final $IssueMediaTable issueMedia = $IssueMediaTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final $FormTemplatesTable formTemplates = $FormTemplatesTable(this);
  late final ProjectDao projectDao = ProjectDao(this as AppDatabase);
  late final SyncQueueDao syncQueueDao = SyncQueueDao(this as AppDatabase);
  late final AnalyticsDao analyticsDao = AnalyticsDao(this as AppDatabase);
  late final ReportDao reportDao = ReportDao(this as AppDatabase);
  late final IssueDao issueDao = IssueDao(this as AppDatabase);
  late final IssueCommentDao issueCommentDao = IssueCommentDao(
    this as AppDatabase,
  );
  late final IssueHistoryDao issueHistoryDao = IssueHistoryDao(
    this as AppDatabase,
  );
  late final IssueMediaDao issueMediaDao = IssueMediaDao(this as AppDatabase);
  late final MediaDao mediaDao = MediaDao(this as AppDatabase);
  late final ConflictDao conflictDao = ConflictDao(this as AppDatabase);
  late final MetaDao metaDao = MetaDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    syncQueue,
    projectAnalytics,
    reports,
    issues,
    issueComments,
    issueHistory,
    issueMedia,
    mediaFiles,
    syncConflicts,
    meta,
    formTemplates,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> location,
      Value<String?> metadata,
      Value<int?> lastSynced,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.lastSynced,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int?> lastSynced = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                location: location,
                metadata: metadata,
                lastSynced: lastSynced,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> location = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<int?> lastSynced = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
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
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
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
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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
    column: $table.entityType,
    builder: (column) => column,
  );

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
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
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
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
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
              }) => SyncQueueCompanion(
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
          createCompanionCallback:
              ({
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
              }) => SyncQueueCompanion.insert(
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
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
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
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $$ProjectAnalyticsTableCreateCompanionBuilder =
    ProjectAnalyticsCompanion Function({
      required String projectId,
      Value<int?> lastSynced,
      Value<int> reportsCount,
      Value<int> requestsPending,
      Value<int> openIssues,
      Value<String?> reportsTimeseries,
      Value<String?> requestsByStatus,
      Value<String?> recentActivity,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ProjectAnalyticsTableUpdateCompanionBuilder =
    ProjectAnalyticsCompanion Function({
      Value<String> projectId,
      Value<int?> lastSynced,
      Value<int> reportsCount,
      Value<int> requestsPending,
      Value<int> openIssues,
      Value<String?> reportsTimeseries,
      Value<String?> requestsByStatus,
      Value<String?> recentActivity,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ProjectAnalyticsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectAnalyticsTable> {
  $$ProjectAnalyticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reportsCount => $composableBuilder(
    column: $table.reportsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestsPending => $composableBuilder(
    column: $table.requestsPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openIssues => $composableBuilder(
    column: $table.openIssues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportsTimeseries => $composableBuilder(
    column: $table.reportsTimeseries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestsByStatus => $composableBuilder(
    column: $table.requestsByStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recentActivity => $composableBuilder(
    column: $table.recentActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProjectAnalyticsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectAnalyticsTable> {
  $$ProjectAnalyticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reportsCount => $composableBuilder(
    column: $table.reportsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestsPending => $composableBuilder(
    column: $table.requestsPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openIssues => $composableBuilder(
    column: $table.openIssues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportsTimeseries => $composableBuilder(
    column: $table.reportsTimeseries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestsByStatus => $composableBuilder(
    column: $table.requestsByStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recentActivity => $composableBuilder(
    column: $table.recentActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectAnalyticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectAnalyticsTable> {
  $$ProjectAnalyticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reportsCount => $composableBuilder(
    column: $table.reportsCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestsPending => $composableBuilder(
    column: $table.requestsPending,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openIssues => $composableBuilder(
    column: $table.openIssues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportsTimeseries => $composableBuilder(
    column: $table.reportsTimeseries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestsByStatus => $composableBuilder(
    column: $table.requestsByStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recentActivity => $composableBuilder(
    column: $table.recentActivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProjectAnalyticsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectAnalyticsTable,
          ProjectAnalytic,
          $$ProjectAnalyticsTableFilterComposer,
          $$ProjectAnalyticsTableOrderingComposer,
          $$ProjectAnalyticsTableAnnotationComposer,
          $$ProjectAnalyticsTableCreateCompanionBuilder,
          $$ProjectAnalyticsTableUpdateCompanionBuilder,
          (
            ProjectAnalytic,
            BaseReferences<
              _$AppDatabase,
              $ProjectAnalyticsTable,
              ProjectAnalytic
            >,
          ),
          ProjectAnalytic,
          PrefetchHooks Function()
        > {
  $$ProjectAnalyticsTableTableManager(
    _$AppDatabase db,
    $ProjectAnalyticsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectAnalyticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectAnalyticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectAnalyticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> projectId = const Value.absent(),
                Value<int?> lastSynced = const Value.absent(),
                Value<int> reportsCount = const Value.absent(),
                Value<int> requestsPending = const Value.absent(),
                Value<int> openIssues = const Value.absent(),
                Value<String?> reportsTimeseries = const Value.absent(),
                Value<String?> requestsByStatus = const Value.absent(),
                Value<String?> recentActivity = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectAnalyticsCompanion(
                projectId: projectId,
                lastSynced: lastSynced,
                reportsCount: reportsCount,
                requestsPending: requestsPending,
                openIssues: openIssues,
                reportsTimeseries: reportsTimeseries,
                requestsByStatus: requestsByStatus,
                recentActivity: recentActivity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String projectId,
                Value<int?> lastSynced = const Value.absent(),
                Value<int> reportsCount = const Value.absent(),
                Value<int> requestsPending = const Value.absent(),
                Value<int> openIssues = const Value.absent(),
                Value<String?> reportsTimeseries = const Value.absent(),
                Value<String?> requestsByStatus = const Value.absent(),
                Value<String?> recentActivity = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectAnalyticsCompanion.insert(
                projectId: projectId,
                lastSynced: lastSynced,
                reportsCount: reportsCount,
                requestsPending: requestsPending,
                openIssues: openIssues,
                reportsTimeseries: reportsTimeseries,
                requestsByStatus: requestsByStatus,
                recentActivity: recentActivity,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProjectAnalyticsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectAnalyticsTable,
      ProjectAnalytic,
      $$ProjectAnalyticsTableFilterComposer,
      $$ProjectAnalyticsTableOrderingComposer,
      $$ProjectAnalyticsTableAnnotationComposer,
      $$ProjectAnalyticsTableCreateCompanionBuilder,
      $$ProjectAnalyticsTableUpdateCompanionBuilder,
      (
        ProjectAnalytic,
        BaseReferences<_$AppDatabase, $ProjectAnalyticsTable, ProjectAnalytic>,
      ),
      ProjectAnalytic,
      PrefetchHooks Function()
    >;
typedef $$ReportsTableCreateCompanionBuilder =
    ReportsCompanion Function({
      required String id,
      required String projectId,
      Value<String?> formTemplateId,
      required int reportDate,
      Value<String?> submissionData,
      Value<String?> location,
      Value<String?> mediaIds,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      Value<String?> serverId,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });
typedef $$ReportsTableUpdateCompanionBuilder =
    ReportsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String?> formTemplateId,
      Value<int> reportDate,
      Value<String?> submissionData,
      Value<String?> location,
      Value<String?> mediaIds,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> serverId,
      Value<int?> serverUpdatedAt,
      Value<int> rowid,
    });

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formTemplateId => $composableBuilder(
    column: $table.formTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get submissionData => $composableBuilder(
    column: $table.submissionData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaIds => $composableBuilder(
    column: $table.mediaIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formTemplateId => $composableBuilder(
    column: $table.formTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get submissionData => $composableBuilder(
    column: $table.submissionData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaIds => $composableBuilder(
    column: $table.mediaIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
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

  GeneratedColumn<String> get formTemplateId => $composableBuilder(
    column: $table.formTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reportDate => $composableBuilder(
    column: $table.reportDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get submissionData => $composableBuilder(
    column: $table.submissionData,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get mediaIds =>
      $composableBuilder(column: $table.mediaIds, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
          Report,
          PrefetchHooks Function()
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> formTemplateId = const Value.absent(),
                Value<int> reportDate = const Value.absent(),
                Value<String?> submissionData = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> mediaIds = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                projectId: projectId,
                formTemplateId: formTemplateId,
                reportDate: reportDate,
                submissionData: submissionData,
                location: location,
                mediaIds: mediaIds,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                Value<String?> formTemplateId = const Value.absent(),
                required int reportDate,
                Value<String?> submissionData = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> mediaIds = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                projectId: projectId,
                formTemplateId: formTemplateId,
                reportDate: reportDate,
                submissionData: submissionData,
                location: location,
                mediaIds: mediaIds,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, BaseReferences<_$AppDatabase, $ReportsTable, Report>),
      Report,
      PrefetchHooks Function()
    >;
typedef $$IssuesTableCreateCompanionBuilder =
    IssuesCompanion Function({
      required String id,
      required String projectId,
      required String title,
      Value<String?> description,
      Value<String?> priority,
      Value<String?> assigneeId,
      Value<String?> status,
      Value<String?> category,
      Value<String?> location,
      Value<int?> dueDate,
      Value<String?> meta,
      required int createdAt,
      required int updatedAt,
      Value<String?> serverId,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$IssuesTableUpdateCompanionBuilder =
    IssuesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> title,
      Value<String?> description,
      Value<String?> priority,
      Value<String?> assigneeId,
      Value<String?> status,
      Value<String?> category,
      Value<String?> location,
      Value<int?> dueDate,
      Value<String?> meta,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> serverId,
      Value<int?> serverUpdatedAt,
      Value<int?> deletedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$IssuesTableFilterComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableFilterComposer({
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

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableOrderingComposer({
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

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssuesTable> {
  $$IssuesTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get assigneeId => $composableBuilder(
    column: $table.assigneeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$IssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssuesTable,
          Issue,
          $$IssuesTableFilterComposer,
          $$IssuesTableOrderingComposer,
          $$IssuesTableAnnotationComposer,
          $$IssuesTableCreateCompanionBuilder,
          $$IssuesTableUpdateCompanionBuilder,
          (Issue, BaseReferences<_$AppDatabase, $IssuesTable, Issue>),
          Issue,
          PrefetchHooks Function()
        > {
  $$IssuesTableTableManager(_$AppDatabase db, $IssuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String?> assigneeId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> dueDate = const Value.absent(),
                Value<String?> meta = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssuesCompanion(
                id: id,
                projectId: projectId,
                title: title,
                description: description,
                priority: priority,
                assigneeId: assigneeId,
                status: status,
                category: category,
                location: location,
                dueDate: dueDate,
                meta: meta,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<String?> priority = const Value.absent(),
                Value<String?> assigneeId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int?> dueDate = const Value.absent(),
                Value<String?> meta = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssuesCompanion.insert(
                id: id,
                projectId: projectId,
                title: title,
                description: description,
                priority: priority,
                assigneeId: assigneeId,
                status: status,
                category: category,
                location: location,
                dueDate: dueDate,
                meta: meta,
                createdAt: createdAt,
                updatedAt: updatedAt,
                serverId: serverId,
                serverUpdatedAt: serverUpdatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssuesTable,
      Issue,
      $$IssuesTableFilterComposer,
      $$IssuesTableOrderingComposer,
      $$IssuesTableAnnotationComposer,
      $$IssuesTableCreateCompanionBuilder,
      $$IssuesTableUpdateCompanionBuilder,
      (Issue, BaseReferences<_$AppDatabase, $IssuesTable, Issue>),
      Issue,
      PrefetchHooks Function()
    >;
typedef $$IssueCommentsTableCreateCompanionBuilder =
    IssueCommentsCompanion Function({
      required String id,
      required String issueLocalId,
      required String authorId,
      required String body,
      required int createdAt,
      required int updatedAt,
      Value<int?> deletedAt,
      Value<String?> serverId,
      Value<int?> serverCreatedAt,
      Value<int?> serverUpdatedAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$IssueCommentsTableUpdateCompanionBuilder =
    IssueCommentsCompanion Function({
      Value<String> id,
      Value<String> issueLocalId,
      Value<String> authorId,
      Value<String> body,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int?> deletedAt,
      Value<String?> serverId,
      Value<int?> serverCreatedAt,
      Value<int?> serverUpdatedAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$IssueCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueCommentsTable> {
  $$IssueCommentsTableFilterComposer({
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

  ColumnFilters<String> get issueLocalId => $composableBuilder(
    column: $table.issueLocalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueCommentsTable> {
  $$IssueCommentsTableOrderingComposer({
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

  ColumnOrderings<String> get issueLocalId => $composableBuilder(
    column: $table.issueLocalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueCommentsTable> {
  $$IssueCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get issueLocalId => $composableBuilder(
    column: $table.issueLocalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get serverCreatedAt => $composableBuilder(
    column: $table.serverCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$IssueCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueCommentsTable,
          IssueComment,
          $$IssueCommentsTableFilterComposer,
          $$IssueCommentsTableOrderingComposer,
          $$IssueCommentsTableAnnotationComposer,
          $$IssueCommentsTableCreateCompanionBuilder,
          $$IssueCommentsTableUpdateCompanionBuilder,
          (
            IssueComment,
            BaseReferences<_$AppDatabase, $IssueCommentsTable, IssueComment>,
          ),
          IssueComment,
          PrefetchHooks Function()
        > {
  $$IssueCommentsTableTableManager(_$AppDatabase db, $IssueCommentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> issueLocalId = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverCreatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCommentsCompanion(
                id: id,
                issueLocalId: issueLocalId,
                authorId: authorId,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverId: serverId,
                serverCreatedAt: serverCreatedAt,
                serverUpdatedAt: serverUpdatedAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String issueLocalId,
                required String authorId,
                required String body,
                required int createdAt,
                required int updatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<int?> serverCreatedAt = const Value.absent(),
                Value<int?> serverUpdatedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCommentsCompanion.insert(
                id: id,
                issueLocalId: issueLocalId,
                authorId: authorId,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                serverId: serverId,
                serverCreatedAt: serverCreatedAt,
                serverUpdatedAt: serverUpdatedAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueCommentsTable,
      IssueComment,
      $$IssueCommentsTableFilterComposer,
      $$IssueCommentsTableOrderingComposer,
      $$IssueCommentsTableAnnotationComposer,
      $$IssueCommentsTableCreateCompanionBuilder,
      $$IssueCommentsTableUpdateCompanionBuilder,
      (
        IssueComment,
        BaseReferences<_$AppDatabase, $IssueCommentsTable, IssueComment>,
      ),
      IssueComment,
      PrefetchHooks Function()
    >;
typedef $$IssueHistoryTableCreateCompanionBuilder =
    IssueHistoryCompanion Function({
      required String id,
      required String issueId,
      required String action,
      Value<String?> field,
      Value<String?> oldValue,
      Value<String?> newValue,
      required String authorId,
      required int timestamp,
      Value<int> rowid,
    });
typedef $$IssueHistoryTableUpdateCompanionBuilder =
    IssueHistoryCompanion Function({
      Value<String> id,
      Value<String> issueId,
      Value<String> action,
      Value<String?> field,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String> authorId,
      Value<int> timestamp,
      Value<int> rowid,
    });

class $$IssueHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $IssueHistoryTable> {
  $$IssueHistoryTableFilterComposer({
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

  ColumnFilters<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueHistoryTable> {
  $$IssueHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorId => $composableBuilder(
    column: $table.authorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueHistoryTable> {
  $$IssueHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get authorId =>
      $composableBuilder(column: $table.authorId, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$IssueHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueHistoryTable,
          IssueHistoryData,
          $$IssueHistoryTableFilterComposer,
          $$IssueHistoryTableOrderingComposer,
          $$IssueHistoryTableAnnotationComposer,
          $$IssueHistoryTableCreateCompanionBuilder,
          $$IssueHistoryTableUpdateCompanionBuilder,
          (
            IssueHistoryData,
            BaseReferences<_$AppDatabase, $IssueHistoryTable, IssueHistoryData>,
          ),
          IssueHistoryData,
          PrefetchHooks Function()
        > {
  $$IssueHistoryTableTableManager(_$AppDatabase db, $IssueHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> issueId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String> authorId = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueHistoryCompanion(
                id: id,
                issueId: issueId,
                action: action,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                authorId: authorId,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String issueId,
                required String action,
                Value<String?> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required String authorId,
                required int timestamp,
                Value<int> rowid = const Value.absent(),
              }) => IssueHistoryCompanion.insert(
                id: id,
                issueId: issueId,
                action: action,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                authorId: authorId,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueHistoryTable,
      IssueHistoryData,
      $$IssueHistoryTableFilterComposer,
      $$IssueHistoryTableOrderingComposer,
      $$IssueHistoryTableAnnotationComposer,
      $$IssueHistoryTableCreateCompanionBuilder,
      $$IssueHistoryTableUpdateCompanionBuilder,
      (
        IssueHistoryData,
        BaseReferences<_$AppDatabase, $IssueHistoryTable, IssueHistoryData>,
      ),
      IssueHistoryData,
      PrefetchHooks Function()
    >;
typedef $$IssueMediaTableCreateCompanionBuilder =
    IssueMediaCompanion Function({
      required String id,
      required String issueId,
      required String localPath,
      Value<String?> thumbnailPath,
      required String mimeType,
      required int sizeBytes,
      Value<String?> serverId,
      Value<String?> serverUrl,
      Value<String> uploadStatus,
      Value<int> rowid,
    });
typedef $$IssueMediaTableUpdateCompanionBuilder =
    IssueMediaCompanion Function({
      Value<String> id,
      Value<String> issueId,
      Value<String> localPath,
      Value<String?> thumbnailPath,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> serverId,
      Value<String?> serverUrl,
      Value<String> uploadStatus,
      Value<int> rowid,
    });

class $$IssueMediaTableFilterComposer
    extends Composer<_$AppDatabase, $IssueMediaTable> {
  $$IssueMediaTableFilterComposer({
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

  ColumnFilters<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueMediaTable> {
  $$IssueMediaTableOrderingComposer({
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

  ColumnOrderings<String> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueMediaTable> {
  $$IssueMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => column,
  );
}

class $$IssueMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueMediaTable,
          IssueMediaData,
          $$IssueMediaTableFilterComposer,
          $$IssueMediaTableOrderingComposer,
          $$IssueMediaTableAnnotationComposer,
          $$IssueMediaTableCreateCompanionBuilder,
          $$IssueMediaTableUpdateCompanionBuilder,
          (
            IssueMediaData,
            BaseReferences<_$AppDatabase, $IssueMediaTable, IssueMediaData>,
          ),
          IssueMediaData,
          PrefetchHooks Function()
        > {
  $$IssueMediaTableTableManager(_$AppDatabase db, $IssueMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> issueId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueMediaCompanion(
                id: id,
                issueId: issueId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                serverId: serverId,
                serverUrl: serverUrl,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String issueId,
                required String localPath,
                Value<String?> thumbnailPath = const Value.absent(),
                required String mimeType,
                required int sizeBytes,
                Value<String?> serverId = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<String> uploadStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueMediaCompanion.insert(
                id: id,
                issueId: issueId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                serverId: serverId,
                serverUrl: serverUrl,
                uploadStatus: uploadStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueMediaTable,
      IssueMediaData,
      $$IssueMediaTableFilterComposer,
      $$IssueMediaTableOrderingComposer,
      $$IssueMediaTableAnnotationComposer,
      $$IssueMediaTableCreateCompanionBuilder,
      $$IssueMediaTableUpdateCompanionBuilder,
      (
        IssueMediaData,
        BaseReferences<_$AppDatabase, $IssueMediaTable, IssueMediaData>,
      ),
      IssueMediaData,
      PrefetchHooks Function()
    >;
typedef $$MediaFilesTableCreateCompanionBuilder =
    MediaFilesCompanion Function({
      required String id,
      required String localPath,
      required String projectId,
      required String parentType,
      required String parentId,
      Value<String> uploadStatus,
      Value<String?> mime,
      required int size,
      required int createdAt,
      Value<String?> serverId,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });
typedef $$MediaFilesTableUpdateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<String> id,
      Value<String> localPath,
      Value<String> projectId,
      Value<String> parentType,
      Value<String> parentId,
      Value<String> uploadStatus,
      Value<String?> mime,
      Value<int> size,
      Value<int> createdAt,
      Value<String?> serverId,
      Value<String?> thumbnailPath,
      Value<int> rowid,
    });

class $$MediaFilesTableFilterComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
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

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentType => $composableBuilder(
    column: $table.parentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
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

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentType => $composableBuilder(
    column: $table.parentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get parentType => $composableBuilder(
    column: $table.parentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get uploadStatus => $composableBuilder(
    column: $table.uploadStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaFilesTable,
          MediaFile,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (
            MediaFile,
            BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFile>,
          ),
          MediaFile,
          PrefetchHooks Function()
        > {
  $$MediaFilesTableTableManager(_$AppDatabase db, $MediaFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> parentType = const Value.absent(),
                Value<String> parentId = const Value.absent(),
                Value<String> uploadStatus = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion(
                id: id,
                localPath: localPath,
                projectId: projectId,
                parentType: parentType,
                parentId: parentId,
                uploadStatus: uploadStatus,
                mime: mime,
                size: size,
                createdAt: createdAt,
                serverId: serverId,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String localPath,
                required String projectId,
                required String parentType,
                required String parentId,
                Value<String> uploadStatus = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                required int size,
                required int createdAt,
                Value<String?> serverId = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                id: id,
                localPath: localPath,
                projectId: projectId,
                parentType: parentType,
                parentId: parentId,
                uploadStatus: uploadStatus,
                mime: mime,
                size: size,
                createdAt: createdAt,
                serverId: serverId,
                thumbnailPath: thumbnailPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaFilesTable,
      MediaFile,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (MediaFile, BaseReferences<_$AppDatabase, $MediaFilesTable, MediaFile>),
      MediaFile,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String localPayload,
      required String serverPayload,
      required int detectedAt,
      Value<int> resolved,
      Value<String?> resolution,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localPayload,
      Value<String> serverPayload,
      Value<int> detectedAt,
      Value<int> resolved,
      Value<String?> resolution,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverPayload => $composableBuilder(
    column: $table.serverPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String> serverPayload = const Value.absent(),
                Value<int> detectedAt = const Value.absent(),
                Value<int> resolved = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                detectedAt: detectedAt,
                resolved: resolved,
                resolution: resolution,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String localPayload,
                required String serverPayload,
                required int detectedAt,
                Value<int> resolved = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localPayload: localPayload,
                serverPayload: serverPayload,
                detectedAt: detectedAt,
                resolved: resolved,
                resolution: resolution,
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

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder =
    MetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaTableUpdateCompanionBuilder =
    MetaCompanion Function({
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
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
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
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
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

class $$MetaTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function()
    >;
typedef $$FormTemplatesTableCreateCompanionBuilder =
    FormTemplatesCompanion Function({
      required String id,
      required String name,
      required String schema,
      Value<int> version,
      required int lastSynced,
      Value<int> rowid,
    });
typedef $$FormTemplatesTableUpdateCompanionBuilder =
    FormTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> schema,
      Value<int> version,
      Value<int> lastSynced,
      Value<int> rowid,
    });

class $$FormTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $FormTemplatesTable> {
  $$FormTemplatesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schema => $composableBuilder(
    column: $table.schema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FormTemplatesTable> {
  $$FormTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schema => $composableBuilder(
    column: $table.schema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormTemplatesTable> {
  $$FormTemplatesTableAnnotationComposer({
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

  GeneratedColumn<String> get schema =>
      $composableBuilder(column: $table.schema, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
}

class $$FormTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormTemplatesTable,
          FormTemplate,
          $$FormTemplatesTableFilterComposer,
          $$FormTemplatesTableOrderingComposer,
          $$FormTemplatesTableAnnotationComposer,
          $$FormTemplatesTableCreateCompanionBuilder,
          $$FormTemplatesTableUpdateCompanionBuilder,
          (
            FormTemplate,
            BaseReferences<_$AppDatabase, $FormTemplatesTable, FormTemplate>,
          ),
          FormTemplate,
          PrefetchHooks Function()
        > {
  $$FormTemplatesTableTableManager(_$AppDatabase db, $FormTemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> schema = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormTemplatesCompanion(
                id: id,
                name: name,
                schema: schema,
                version: version,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String schema,
                Value<int> version = const Value.absent(),
                required int lastSynced,
                Value<int> rowid = const Value.absent(),
              }) => FormTemplatesCompanion.insert(
                id: id,
                name: name,
                schema: schema,
                version: version,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormTemplatesTable,
      FormTemplate,
      $$FormTemplatesTableFilterComposer,
      $$FormTemplatesTableOrderingComposer,
      $$FormTemplatesTableAnnotationComposer,
      $$FormTemplatesTableCreateCompanionBuilder,
      $$FormTemplatesTableUpdateCompanionBuilder,
      (
        FormTemplate,
        BaseReferences<_$AppDatabase, $FormTemplatesTable, FormTemplate>,
      ),
      FormTemplate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$ProjectAnalyticsTableTableManager get projectAnalytics =>
      $$ProjectAnalyticsTableTableManager(_db, _db.projectAnalytics);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$IssuesTableTableManager get issues =>
      $$IssuesTableTableManager(_db, _db.issues);
  $$IssueCommentsTableTableManager get issueComments =>
      $$IssueCommentsTableTableManager(_db, _db.issueComments);
  $$IssueHistoryTableTableManager get issueHistory =>
      $$IssueHistoryTableTableManager(_db, _db.issueHistory);
  $$IssueMediaTableTableManager get issueMedia =>
      $$IssueMediaTableTableManager(_db, _db.issueMedia);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
  $$FormTemplatesTableTableManager get formTemplates =>
      $$FormTemplatesTableTableManager(_db, _db.formTemplates);
}
