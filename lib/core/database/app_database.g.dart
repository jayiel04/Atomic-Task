// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TimerProgressTable extends TimerProgress
    with TableInfo<$TimerProgressTable, TimerProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _gemsMeta = const VerificationMeta('gems');
  @override
  late final GeneratedColumn<int> gems = GeneratedColumn<int>(
    'gems',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalFocusSecondsMeta = const VerificationMeta(
    'totalFocusSeconds',
  );
  @override
  late final GeneratedColumn<int> totalFocusSeconds = GeneratedColumn<int>(
    'total_focus_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _profileNameMeta = const VerificationMeta(
    'profileName',
  );
  @override
  late final GeneratedColumn<String> profileName = GeneratedColumn<String>(
    'profile_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('NOMBRE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gems,
    totalFocusSeconds,
    profileName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gems')) {
      context.handle(
        _gemsMeta,
        gems.isAcceptableOrUnknown(data['gems']!, _gemsMeta),
      );
    }
    if (data.containsKey('total_focus_seconds')) {
      context.handle(
        _totalFocusSecondsMeta,
        totalFocusSeconds.isAcceptableOrUnknown(
          data['total_focus_seconds']!,
          _totalFocusSecondsMeta,
        ),
      );
    }
    if (data.containsKey('profile_name')) {
      context.handle(
        _profileNameMeta,
        profileName.isAcceptableOrUnknown(
          data['profile_name']!,
          _profileNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimerProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerProgressData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gems: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gems'],
      )!,
      totalFocusSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_focus_seconds'],
      )!,
      profileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_name'],
      )!,
    );
  }

  @override
  $TimerProgressTable createAlias(String alias) {
    return $TimerProgressTable(attachedDatabase, alias);
  }
}

class TimerProgressData extends DataClass
    implements Insertable<TimerProgressData> {
  final int id;
  final int gems;
  final int totalFocusSeconds;
  final String profileName;
  const TimerProgressData({
    required this.id,
    required this.gems,
    required this.totalFocusSeconds,
    required this.profileName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['gems'] = Variable<int>(gems);
    map['total_focus_seconds'] = Variable<int>(totalFocusSeconds);
    map['profile_name'] = Variable<String>(profileName);
    return map;
  }

  TimerProgressCompanion toCompanion(bool nullToAbsent) {
    return TimerProgressCompanion(
      id: Value(id),
      gems: Value(gems),
      totalFocusSeconds: Value(totalFocusSeconds),
      profileName: Value(profileName),
    );
  }

  factory TimerProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerProgressData(
      id: serializer.fromJson<int>(json['id']),
      gems: serializer.fromJson<int>(json['gems']),
      totalFocusSeconds: serializer.fromJson<int>(json['totalFocusSeconds']),
      profileName: serializer.fromJson<String>(json['profileName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gems': serializer.toJson<int>(gems),
      'totalFocusSeconds': serializer.toJson<int>(totalFocusSeconds),
      'profileName': serializer.toJson<String>(profileName),
    };
  }

  TimerProgressData copyWith({
    int? id,
    int? gems,
    int? totalFocusSeconds,
    String? profileName,
  }) => TimerProgressData(
    id: id ?? this.id,
    gems: gems ?? this.gems,
    totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
    profileName: profileName ?? this.profileName,
  );
  TimerProgressData copyWithCompanion(TimerProgressCompanion data) {
    return TimerProgressData(
      id: data.id.present ? data.id.value : this.id,
      gems: data.gems.present ? data.gems.value : this.gems,
      totalFocusSeconds: data.totalFocusSeconds.present
          ? data.totalFocusSeconds.value
          : this.totalFocusSeconds,
      profileName: data.profileName.present
          ? data.profileName.value
          : this.profileName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerProgressData(')
          ..write('id: $id, ')
          ..write('gems: $gems, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('profileName: $profileName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gems, totalFocusSeconds, profileName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerProgressData &&
          other.id == this.id &&
          other.gems == this.gems &&
          other.totalFocusSeconds == this.totalFocusSeconds &&
          other.profileName == this.profileName);
}

class TimerProgressCompanion extends UpdateCompanion<TimerProgressData> {
  final Value<int> id;
  final Value<int> gems;
  final Value<int> totalFocusSeconds;
  final Value<String> profileName;
  const TimerProgressCompanion({
    this.id = const Value.absent(),
    this.gems = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    this.profileName = const Value.absent(),
  });
  TimerProgressCompanion.insert({
    this.id = const Value.absent(),
    this.gems = const Value.absent(),
    this.totalFocusSeconds = const Value.absent(),
    this.profileName = const Value.absent(),
  });
  static Insertable<TimerProgressData> custom({
    Expression<int>? id,
    Expression<int>? gems,
    Expression<int>? totalFocusSeconds,
    Expression<String>? profileName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gems != null) 'gems': gems,
      if (totalFocusSeconds != null) 'total_focus_seconds': totalFocusSeconds,
      if (profileName != null) 'profile_name': profileName,
    });
  }

  TimerProgressCompanion copyWith({
    Value<int>? id,
    Value<int>? gems,
    Value<int>? totalFocusSeconds,
    Value<String>? profileName,
  }) {
    return TimerProgressCompanion(
      id: id ?? this.id,
      gems: gems ?? this.gems,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      profileName: profileName ?? this.profileName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gems.present) {
      map['gems'] = Variable<int>(gems.value);
    }
    if (totalFocusSeconds.present) {
      map['total_focus_seconds'] = Variable<int>(totalFocusSeconds.value);
    }
    if (profileName.present) {
      map['profile_name'] = Variable<String>(profileName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerProgressCompanion(')
          ..write('id: $id, ')
          ..write('gems: $gems, ')
          ..write('totalFocusSeconds: $totalFocusSeconds, ')
          ..write('profileName: $profileName')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _focusMinutesMeta = const VerificationMeta(
    'focusMinutes',
  );
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
    'focus_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    title,
    isCompleted,
    dueDate,
    focusMinutes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
        _focusMinutesMeta,
        focusMinutes.isAcceptableOrUnknown(
          data['focus_minutes']!,
          _focusMinutesMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      focusMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_minutes'],
      ),
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
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final int? focusMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskRow({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    this.focusMinutes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || focusMinutes != null) {
      map['focus_minutes'] = Variable<int>(focusMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      isCompleted: Value(isCompleted),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      focusMinutes: focusMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(focusMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      focusMinutes: serializer.fromJson<int?>(json['focusMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'focusMinutes': serializer.toJson<int?>(focusMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TaskRow copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<int?> focusMinutes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    focusMinutes: focusMinutes.present ? focusMinutes.value : this.focusMinutes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    isCompleted,
    dueDate,
    focusMinutes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted &&
          other.dueDate == this.dueDate &&
          other.focusMinutes == this.focusMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> dueDate;
  final Value<int?> focusMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<bool>? isCompleted,
    Expression<DateTime>? dueDate,
    Expression<int>? focusMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<bool>? isCompleted,
    Value<DateTime?>? dueDate,
    Value<int?>? focusMinutes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('dueDate: $dueDate, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimerProgressTable timerProgress = $TimerProgressTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [timerProgress, tasks];
}

typedef $$TimerProgressTableCreateCompanionBuilder =
    TimerProgressCompanion Function({
      Value<int> id,
      Value<int> gems,
      Value<int> totalFocusSeconds,
      Value<String> profileName,
    });
typedef $$TimerProgressTableUpdateCompanionBuilder =
    TimerProgressCompanion Function({
      Value<int> id,
      Value<int> gems,
      Value<int> totalFocusSeconds,
      Value<String> profileName,
    });

class $$TimerProgressTableFilterComposer
    extends Composer<_$AppDatabase, $TimerProgressTable> {
  $$TimerProgressTableFilterComposer({
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

  ColumnFilters<int> get gems => $composableBuilder(
    column: $table.gems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerProgressTable> {
  $$TimerProgressTableOrderingComposer({
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

  ColumnOrderings<int> get gems => $composableBuilder(
    column: $table.gems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerProgressTable> {
  $$TimerProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get gems =>
      $composableBuilder(column: $table.gems, builder: (column) => column);

  GeneratedColumn<int> get totalFocusSeconds => $composableBuilder(
    column: $table.totalFocusSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileName => $composableBuilder(
    column: $table.profileName,
    builder: (column) => column,
  );
}

class $$TimerProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerProgressTable,
          TimerProgressData,
          $$TimerProgressTableFilterComposer,
          $$TimerProgressTableOrderingComposer,
          $$TimerProgressTableAnnotationComposer,
          $$TimerProgressTableCreateCompanionBuilder,
          $$TimerProgressTableUpdateCompanionBuilder,
          (
            TimerProgressData,
            BaseReferences<
              _$AppDatabase,
              $TimerProgressTable,
              TimerProgressData
            >,
          ),
          TimerProgressData,
          PrefetchHooks Function()
        > {
  $$TimerProgressTableTableManager(_$AppDatabase db, $TimerProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gems = const Value.absent(),
                Value<int> totalFocusSeconds = const Value.absent(),
                Value<String> profileName = const Value.absent(),
              }) => TimerProgressCompanion(
                id: id,
                gems: gems,
                totalFocusSeconds: totalFocusSeconds,
                profileName: profileName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gems = const Value.absent(),
                Value<int> totalFocusSeconds = const Value.absent(),
                Value<String> profileName = const Value.absent(),
              }) => TimerProgressCompanion.insert(
                id: id,
                gems: gems,
                totalFocusSeconds: totalFocusSeconds,
                profileName: profileName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerProgressTable,
      TimerProgressData,
      $$TimerProgressTableFilterComposer,
      $$TimerProgressTableOrderingComposer,
      $$TimerProgressTableAnnotationComposer,
      $$TimerProgressTableCreateCompanionBuilder,
      $$TimerProgressTableUpdateCompanionBuilder,
      (
        TimerProgressData,
        BaseReferences<_$AppDatabase, $TimerProgressTable, TimerProgressData>,
      ),
      TimerProgressData,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isCompleted,
      Value<DateTime?> dueDate,
      Value<int?> focusMinutes,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<bool> isCompleted,
      Value<DateTime?> dueDate,
      Value<int?> focusMinutes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
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
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
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

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
    column: $table.focusMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> focusMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                isCompleted: isCompleted,
                dueDate: dueDate,
                focusMinutes: focusMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int?> focusMinutes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                isCompleted: isCompleted,
                dueDate: dueDate,
                focusMinutes: focusMinutes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$AppDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimerProgressTableTableManager get timerProgress =>
      $$TimerProgressTableTableManager(_db, _db.timerProgress);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
