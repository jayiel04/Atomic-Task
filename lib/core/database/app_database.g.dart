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

class $TaskRecurrenceRulesTable extends TaskRecurrenceRules
    with TableInfo<$TaskRecurrenceRulesTable, TaskRecurrenceRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskRecurrenceRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    frequency,
    interval,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_recurrence_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRecurrenceRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    } else if (isInserting) {
      context.missing(_intervalMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  TaskRecurrenceRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRecurrenceRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  $TaskRecurrenceRulesTable createAlias(String alias) {
    return $TaskRecurrenceRulesTable(attachedDatabase, alias);
  }
}

class TaskRecurrenceRuleRow extends DataClass
    implements Insertable<TaskRecurrenceRuleRow> {
  final int id;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskRecurrenceRuleRow({
    required this.id,
    required this.frequency,
    required this.interval,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TaskRecurrenceRulesCompanion toCompanion(bool nullToAbsent) {
    return TaskRecurrenceRulesCompanion(
      id: Value(id),
      frequency: Value(frequency),
      interval: Value(interval),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskRecurrenceRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRecurrenceRuleRow(
      id: serializer.fromJson<int>(json['id']),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TaskRecurrenceRuleRow copyWith({
    int? id,
    String? frequency,
    int? interval,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskRecurrenceRuleRow(
    id: id ?? this.id,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskRecurrenceRuleRow copyWithCompanion(TaskRecurrenceRulesCompanion data) {
    return TaskRecurrenceRuleRow(
      id: data.id.present ? data.id.value : this.id,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRecurrenceRuleRow(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    frequency,
    interval,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRecurrenceRuleRow &&
          other.id == this.id &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TaskRecurrenceRulesCompanion
    extends UpdateCompanion<TaskRecurrenceRuleRow> {
  final Value<int> id;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TaskRecurrenceRulesCompanion({
    this.id = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TaskRecurrenceRulesCompanion.insert({
    this.id = const Value.absent(),
    required String frequency,
    required int interval,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : frequency = Value(frequency),
       interval = Value(interval),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRecurrenceRuleRow> custom({
    Expression<int>? id,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TaskRecurrenceRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? frequency,
    Value<int>? interval,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TaskRecurrenceRulesCompanion(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
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
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('TaskRecurrenceRulesCompanion(')
          ..write('id: $id, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceRuleIdMeta = const VerificationMeta(
    'recurrenceRuleId',
  );
  @override
  late final GeneratedColumn<int> recurrenceRuleId = GeneratedColumn<int>(
    'recurrence_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES task_recurrence_rules (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta(
    'occurrenceDate',
  );
  @override
  late final GeneratedColumn<DateTime> occurrenceDate =
      GeneratedColumn<DateTime>(
        'occurrence_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
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
    completedAt,
    recurrenceRuleId,
    occurrenceDate,
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('recurrence_rule_id')) {
      context.handle(
        _recurrenceRuleIdMeta,
        recurrenceRuleId.isAcceptableOrUnknown(
          data['recurrence_rule_id']!,
          _recurrenceRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(
          data['occurrence_date']!,
          _occurrenceDateMeta,
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recurrenceRuleId, occurrenceDate},
  ];
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
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      recurrenceRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurrence_rule_id'],
      ),
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurrence_date'],
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
  final DateTime? completedAt;
  final int? recurrenceRuleId;
  final DateTime? occurrenceDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TaskRow({
    required this.id,
    required this.title,
    required this.isCompleted,
    this.dueDate,
    this.focusMinutes,
    this.completedAt,
    this.recurrenceRuleId,
    this.occurrenceDate,
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
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || recurrenceRuleId != null) {
      map['recurrence_rule_id'] = Variable<int>(recurrenceRuleId);
    }
    if (!nullToAbsent || occurrenceDate != null) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate);
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
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      recurrenceRuleId: recurrenceRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceRuleId),
      occurrenceDate: occurrenceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceDate),
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
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      recurrenceRuleId: serializer.fromJson<int?>(json['recurrenceRuleId']),
      occurrenceDate: serializer.fromJson<DateTime?>(json['occurrenceDate']),
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
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'recurrenceRuleId': serializer.toJson<int?>(recurrenceRuleId),
      'occurrenceDate': serializer.toJson<DateTime?>(occurrenceDate),
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
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> recurrenceRuleId = const Value.absent(),
    Value<DateTime?> occurrenceDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    focusMinutes: focusMinutes.present ? focusMinutes.value : this.focusMinutes,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    recurrenceRuleId: recurrenceRuleId.present
        ? recurrenceRuleId.value
        : this.recurrenceRuleId,
    occurrenceDate: occurrenceDate.present
        ? occurrenceDate.value
        : this.occurrenceDate,
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
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      recurrenceRuleId: data.recurrenceRuleId.present
          ? data.recurrenceRuleId.value
          : this.recurrenceRuleId,
      occurrenceDate: data.occurrenceDate.present
          ? data.occurrenceDate.value
          : this.occurrenceDate,
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
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
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
    completedAt,
    recurrenceRuleId,
    occurrenceDate,
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
          other.completedAt == this.completedAt &&
          other.recurrenceRuleId == this.recurrenceRuleId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<bool> isCompleted;
  final Value<DateTime?> dueDate;
  final Value<int?> focusMinutes;
  final Value<DateTime?> completedAt;
  final Value<int?> recurrenceRuleId;
  final Value<DateTime?> occurrenceDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.isCompleted = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.recurrenceRuleId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
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
    Expression<DateTime>? completedAt,
    Expression<int>? recurrenceRuleId,
    Expression<DateTime>? occurrenceDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (dueDate != null) 'due_date': dueDate,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (completedAt != null) 'completed_at': completedAt,
      if (recurrenceRuleId != null) 'recurrence_rule_id': recurrenceRuleId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
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
    Value<DateTime?>? completedAt,
    Value<int?>? recurrenceRuleId,
    Value<DateTime?>? occurrenceDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      completedAt: completedAt ?? this.completedAt,
      recurrenceRuleId: recurrenceRuleId ?? this.recurrenceRuleId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
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
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (recurrenceRuleId.present) {
      map['recurrence_rule_id'] = Variable<int>(recurrenceRuleId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<DateTime>(occurrenceDate.value);
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
          ..write('completedAt: $completedAt, ')
          ..write('recurrenceRuleId: $recurrenceRuleId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ActiveTimerSessionsTable extends ActiveTimerSessions
    with TableInfo<$ActiveTimerSessionsTable, ActiveTimerSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActiveTimerSessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
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
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedSecondsMeta = const VerificationMeta(
    'selectedSeconds',
  );
  @override
  late final GeneratedColumn<int> selectedSeconds = GeneratedColumn<int>(
    'selected_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingSecondsMeta = const VerificationMeta(
    'remainingSeconds',
  );
  @override
  late final GeneratedColumn<int> remainingSeconds = GeneratedColumn<int>(
    'remaining_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta(
    'elapsedSeconds',
  );
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardedBlocksMeta = const VerificationMeta(
    'rewardedBlocks',
  );
  @override
  late final GeneratedColumn<int> rewardedBlocks = GeneratedColumn<int>(
    'rewarded_blocks',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargedMinutesMeta = const VerificationMeta(
    'chargedMinutes',
  );
  @override
  late final GeneratedColumn<int> chargedMinutes = GeneratedColumn<int>(
    'charged_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCheckpointAtMeta = const VerificationMeta(
    'lastCheckpointAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCheckpointAt =
      GeneratedColumn<DateTime>(
        'last_checkpoint_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedTaskIdMeta = const VerificationMeta(
    'linkedTaskId',
  );
  @override
  late final GeneratedColumn<int> linkedTaskId = GeneratedColumn<int>(
    'linked_task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedTaskTitleMeta = const VerificationMeta(
    'linkedTaskTitle',
  );
  @override
  late final GeneratedColumn<String> linkedTaskTitle = GeneratedColumn<String>(
    'linked_task_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    mode,
    state,
    selectedSeconds,
    remainingSeconds,
    elapsedSeconds,
    rewardedBlocks,
    chargedMinutes,
    lastCheckpointAt,
    endsAt,
    linkedTaskId,
    linkedTaskTitle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'active_timer_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActiveTimerSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('selected_seconds')) {
      context.handle(
        _selectedSecondsMeta,
        selectedSeconds.isAcceptableOrUnknown(
          data['selected_seconds']!,
          _selectedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_selectedSecondsMeta);
    }
    if (data.containsKey('remaining_seconds')) {
      context.handle(
        _remainingSecondsMeta,
        remainingSeconds.isAcceptableOrUnknown(
          data['remaining_seconds']!,
          _remainingSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remainingSecondsMeta);
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(
          data['elapsed_seconds']!,
          _elapsedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elapsedSecondsMeta);
    }
    if (data.containsKey('rewarded_blocks')) {
      context.handle(
        _rewardedBlocksMeta,
        rewardedBlocks.isAcceptableOrUnknown(
          data['rewarded_blocks']!,
          _rewardedBlocksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rewardedBlocksMeta);
    }
    if (data.containsKey('charged_minutes')) {
      context.handle(
        _chargedMinutesMeta,
        chargedMinutes.isAcceptableOrUnknown(
          data['charged_minutes']!,
          _chargedMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargedMinutesMeta);
    }
    if (data.containsKey('last_checkpoint_at')) {
      context.handle(
        _lastCheckpointAtMeta,
        lastCheckpointAt.isAcceptableOrUnknown(
          data['last_checkpoint_at']!,
          _lastCheckpointAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastCheckpointAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('linked_task_id')) {
      context.handle(
        _linkedTaskIdMeta,
        linkedTaskId.isAcceptableOrUnknown(
          data['linked_task_id']!,
          _linkedTaskIdMeta,
        ),
      );
    }
    if (data.containsKey('linked_task_title')) {
      context.handle(
        _linkedTaskTitleMeta,
        linkedTaskTitle.isAcceptableOrUnknown(
          data['linked_task_title']!,
          _linkedTaskTitleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActiveTimerSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActiveTimerSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      selectedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_seconds'],
      )!,
      remainingSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_seconds'],
      )!,
      elapsedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_seconds'],
      )!,
      rewardedBlocks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rewarded_blocks'],
      )!,
      chargedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged_minutes'],
      )!,
      lastCheckpointAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checkpoint_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      linkedTaskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}linked_task_id'],
      ),
      linkedTaskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_task_title'],
      ),
    );
  }

  @override
  $ActiveTimerSessionsTable createAlias(String alias) {
    return $ActiveTimerSessionsTable(attachedDatabase, alias);
  }
}

class ActiveTimerSessionRow extends DataClass
    implements Insertable<ActiveTimerSessionRow> {
  final int id;
  final String sessionId;
  final String mode;
  final String state;
  final int selectedSeconds;
  final int remainingSeconds;
  final int elapsedSeconds;
  final int rewardedBlocks;
  final int chargedMinutes;
  final DateTime lastCheckpointAt;
  final DateTime? endsAt;
  final int? linkedTaskId;
  final String? linkedTaskTitle;
  const ActiveTimerSessionRow({
    required this.id,
    required this.sessionId,
    required this.mode,
    required this.state,
    required this.selectedSeconds,
    required this.remainingSeconds,
    required this.elapsedSeconds,
    required this.rewardedBlocks,
    required this.chargedMinutes,
    required this.lastCheckpointAt,
    this.endsAt,
    this.linkedTaskId,
    this.linkedTaskTitle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['mode'] = Variable<String>(mode);
    map['state'] = Variable<String>(state);
    map['selected_seconds'] = Variable<int>(selectedSeconds);
    map['remaining_seconds'] = Variable<int>(remainingSeconds);
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    map['rewarded_blocks'] = Variable<int>(rewardedBlocks);
    map['charged_minutes'] = Variable<int>(chargedMinutes);
    map['last_checkpoint_at'] = Variable<DateTime>(lastCheckpointAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    if (!nullToAbsent || linkedTaskId != null) {
      map['linked_task_id'] = Variable<int>(linkedTaskId);
    }
    if (!nullToAbsent || linkedTaskTitle != null) {
      map['linked_task_title'] = Variable<String>(linkedTaskTitle);
    }
    return map;
  }

  ActiveTimerSessionsCompanion toCompanion(bool nullToAbsent) {
    return ActiveTimerSessionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      mode: Value(mode),
      state: Value(state),
      selectedSeconds: Value(selectedSeconds),
      remainingSeconds: Value(remainingSeconds),
      elapsedSeconds: Value(elapsedSeconds),
      rewardedBlocks: Value(rewardedBlocks),
      chargedMinutes: Value(chargedMinutes),
      lastCheckpointAt: Value(lastCheckpointAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      linkedTaskId: linkedTaskId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTaskId),
      linkedTaskTitle: linkedTaskTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedTaskTitle),
    );
  }

  factory ActiveTimerSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActiveTimerSessionRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      mode: serializer.fromJson<String>(json['mode']),
      state: serializer.fromJson<String>(json['state']),
      selectedSeconds: serializer.fromJson<int>(json['selectedSeconds']),
      remainingSeconds: serializer.fromJson<int>(json['remainingSeconds']),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      rewardedBlocks: serializer.fromJson<int>(json['rewardedBlocks']),
      chargedMinutes: serializer.fromJson<int>(json['chargedMinutes']),
      lastCheckpointAt: serializer.fromJson<DateTime>(json['lastCheckpointAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      linkedTaskId: serializer.fromJson<int?>(json['linkedTaskId']),
      linkedTaskTitle: serializer.fromJson<String?>(json['linkedTaskTitle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'mode': serializer.toJson<String>(mode),
      'state': serializer.toJson<String>(state),
      'selectedSeconds': serializer.toJson<int>(selectedSeconds),
      'remainingSeconds': serializer.toJson<int>(remainingSeconds),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'rewardedBlocks': serializer.toJson<int>(rewardedBlocks),
      'chargedMinutes': serializer.toJson<int>(chargedMinutes),
      'lastCheckpointAt': serializer.toJson<DateTime>(lastCheckpointAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'linkedTaskId': serializer.toJson<int?>(linkedTaskId),
      'linkedTaskTitle': serializer.toJson<String?>(linkedTaskTitle),
    };
  }

  ActiveTimerSessionRow copyWith({
    int? id,
    String? sessionId,
    String? mode,
    String? state,
    int? selectedSeconds,
    int? remainingSeconds,
    int? elapsedSeconds,
    int? rewardedBlocks,
    int? chargedMinutes,
    DateTime? lastCheckpointAt,
    Value<DateTime?> endsAt = const Value.absent(),
    Value<int?> linkedTaskId = const Value.absent(),
    Value<String?> linkedTaskTitle = const Value.absent(),
  }) => ActiveTimerSessionRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    mode: mode ?? this.mode,
    state: state ?? this.state,
    selectedSeconds: selectedSeconds ?? this.selectedSeconds,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    rewardedBlocks: rewardedBlocks ?? this.rewardedBlocks,
    chargedMinutes: chargedMinutes ?? this.chargedMinutes,
    lastCheckpointAt: lastCheckpointAt ?? this.lastCheckpointAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    linkedTaskId: linkedTaskId.present ? linkedTaskId.value : this.linkedTaskId,
    linkedTaskTitle: linkedTaskTitle.present
        ? linkedTaskTitle.value
        : this.linkedTaskTitle,
  );
  ActiveTimerSessionRow copyWithCompanion(ActiveTimerSessionsCompanion data) {
    return ActiveTimerSessionRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      mode: data.mode.present ? data.mode.value : this.mode,
      state: data.state.present ? data.state.value : this.state,
      selectedSeconds: data.selectedSeconds.present
          ? data.selectedSeconds.value
          : this.selectedSeconds,
      remainingSeconds: data.remainingSeconds.present
          ? data.remainingSeconds.value
          : this.remainingSeconds,
      elapsedSeconds: data.elapsedSeconds.present
          ? data.elapsedSeconds.value
          : this.elapsedSeconds,
      rewardedBlocks: data.rewardedBlocks.present
          ? data.rewardedBlocks.value
          : this.rewardedBlocks,
      chargedMinutes: data.chargedMinutes.present
          ? data.chargedMinutes.value
          : this.chargedMinutes,
      lastCheckpointAt: data.lastCheckpointAt.present
          ? data.lastCheckpointAt.value
          : this.lastCheckpointAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      linkedTaskId: data.linkedTaskId.present
          ? data.linkedTaskId.value
          : this.linkedTaskId,
      linkedTaskTitle: data.linkedTaskTitle.present
          ? data.linkedTaskTitle.value
          : this.linkedTaskTitle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerSessionRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('mode: $mode, ')
          ..write('state: $state, ')
          ..write('selectedSeconds: $selectedSeconds, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('rewardedBlocks: $rewardedBlocks, ')
          ..write('chargedMinutes: $chargedMinutes, ')
          ..write('lastCheckpointAt: $lastCheckpointAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('linkedTaskId: $linkedTaskId, ')
          ..write('linkedTaskTitle: $linkedTaskTitle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    mode,
    state,
    selectedSeconds,
    remainingSeconds,
    elapsedSeconds,
    rewardedBlocks,
    chargedMinutes,
    lastCheckpointAt,
    endsAt,
    linkedTaskId,
    linkedTaskTitle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActiveTimerSessionRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.mode == this.mode &&
          other.state == this.state &&
          other.selectedSeconds == this.selectedSeconds &&
          other.remainingSeconds == this.remainingSeconds &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.rewardedBlocks == this.rewardedBlocks &&
          other.chargedMinutes == this.chargedMinutes &&
          other.lastCheckpointAt == this.lastCheckpointAt &&
          other.endsAt == this.endsAt &&
          other.linkedTaskId == this.linkedTaskId &&
          other.linkedTaskTitle == this.linkedTaskTitle);
}

class ActiveTimerSessionsCompanion
    extends UpdateCompanion<ActiveTimerSessionRow> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> mode;
  final Value<String> state;
  final Value<int> selectedSeconds;
  final Value<int> remainingSeconds;
  final Value<int> elapsedSeconds;
  final Value<int> rewardedBlocks;
  final Value<int> chargedMinutes;
  final Value<DateTime> lastCheckpointAt;
  final Value<DateTime?> endsAt;
  final Value<int?> linkedTaskId;
  final Value<String?> linkedTaskTitle;
  const ActiveTimerSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.mode = const Value.absent(),
    this.state = const Value.absent(),
    this.selectedSeconds = const Value.absent(),
    this.remainingSeconds = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.rewardedBlocks = const Value.absent(),
    this.chargedMinutes = const Value.absent(),
    this.lastCheckpointAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.linkedTaskId = const Value.absent(),
    this.linkedTaskTitle = const Value.absent(),
  });
  ActiveTimerSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String mode,
    required String state,
    required int selectedSeconds,
    required int remainingSeconds,
    required int elapsedSeconds,
    required int rewardedBlocks,
    required int chargedMinutes,
    required DateTime lastCheckpointAt,
    this.endsAt = const Value.absent(),
    this.linkedTaskId = const Value.absent(),
    this.linkedTaskTitle = const Value.absent(),
  }) : sessionId = Value(sessionId),
       mode = Value(mode),
       state = Value(state),
       selectedSeconds = Value(selectedSeconds),
       remainingSeconds = Value(remainingSeconds),
       elapsedSeconds = Value(elapsedSeconds),
       rewardedBlocks = Value(rewardedBlocks),
       chargedMinutes = Value(chargedMinutes),
       lastCheckpointAt = Value(lastCheckpointAt);
  static Insertable<ActiveTimerSessionRow> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? mode,
    Expression<String>? state,
    Expression<int>? selectedSeconds,
    Expression<int>? remainingSeconds,
    Expression<int>? elapsedSeconds,
    Expression<int>? rewardedBlocks,
    Expression<int>? chargedMinutes,
    Expression<DateTime>? lastCheckpointAt,
    Expression<DateTime>? endsAt,
    Expression<int>? linkedTaskId,
    Expression<String>? linkedTaskTitle,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (mode != null) 'mode': mode,
      if (state != null) 'state': state,
      if (selectedSeconds != null) 'selected_seconds': selectedSeconds,
      if (remainingSeconds != null) 'remaining_seconds': remainingSeconds,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (rewardedBlocks != null) 'rewarded_blocks': rewardedBlocks,
      if (chargedMinutes != null) 'charged_minutes': chargedMinutes,
      if (lastCheckpointAt != null) 'last_checkpoint_at': lastCheckpointAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (linkedTaskId != null) 'linked_task_id': linkedTaskId,
      if (linkedTaskTitle != null) 'linked_task_title': linkedTaskTitle,
    });
  }

  ActiveTimerSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<String>? mode,
    Value<String>? state,
    Value<int>? selectedSeconds,
    Value<int>? remainingSeconds,
    Value<int>? elapsedSeconds,
    Value<int>? rewardedBlocks,
    Value<int>? chargedMinutes,
    Value<DateTime>? lastCheckpointAt,
    Value<DateTime?>? endsAt,
    Value<int?>? linkedTaskId,
    Value<String?>? linkedTaskTitle,
  }) {
    return ActiveTimerSessionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      selectedSeconds: selectedSeconds ?? this.selectedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      rewardedBlocks: rewardedBlocks ?? this.rewardedBlocks,
      chargedMinutes: chargedMinutes ?? this.chargedMinutes,
      lastCheckpointAt: lastCheckpointAt ?? this.lastCheckpointAt,
      endsAt: endsAt ?? this.endsAt,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedTaskTitle: linkedTaskTitle ?? this.linkedTaskTitle,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (selectedSeconds.present) {
      map['selected_seconds'] = Variable<int>(selectedSeconds.value);
    }
    if (remainingSeconds.present) {
      map['remaining_seconds'] = Variable<int>(remainingSeconds.value);
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (rewardedBlocks.present) {
      map['rewarded_blocks'] = Variable<int>(rewardedBlocks.value);
    }
    if (chargedMinutes.present) {
      map['charged_minutes'] = Variable<int>(chargedMinutes.value);
    }
    if (lastCheckpointAt.present) {
      map['last_checkpoint_at'] = Variable<DateTime>(lastCheckpointAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (linkedTaskId.present) {
      map['linked_task_id'] = Variable<int>(linkedTaskId.value);
    }
    if (linkedTaskTitle.present) {
      map['linked_task_title'] = Variable<String>(linkedTaskTitle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActiveTimerSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('mode: $mode, ')
          ..write('state: $state, ')
          ..write('selectedSeconds: $selectedSeconds, ')
          ..write('remainingSeconds: $remainingSeconds, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('rewardedBlocks: $rewardedBlocks, ')
          ..write('chargedMinutes: $chargedMinutes, ')
          ..write('lastCheckpointAt: $lastCheckpointAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('linkedTaskId: $linkedTaskId, ')
          ..write('linkedTaskTitle: $linkedTaskTitle')
          ..write(')'))
        .toString();
  }
}

class $PendingTimerSummariesTable extends PendingTimerSummaries
    with TableInfo<$PendingTimerSummariesTable, PendingTimerSummaryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingTimerSummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
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
  static const VerificationMeta _completedSecondsMeta = const VerificationMeta(
    'completedSeconds',
  );
  @override
  late final GeneratedColumn<int> completedSeconds = GeneratedColumn<int>(
    'completed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gemDeltaMeta = const VerificationMeta(
    'gemDelta',
  );
  @override
  late final GeneratedColumn<int> gemDelta = GeneratedColumn<int>(
    'gem_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inAppPendingMeta = const VerificationMeta(
    'inAppPending',
  );
  @override
  late final GeneratedColumn<bool> inAppPending = GeneratedColumn<bool>(
    'in_app_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("in_app_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificationPendingMeta =
      const VerificationMeta('notificationPending');
  @override
  late final GeneratedColumn<bool> notificationPending = GeneratedColumn<bool>(
    'notification_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notification_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _adPendingMeta = const VerificationMeta(
    'adPending',
  );
  @override
  late final GeneratedColumn<bool> adPending = GeneratedColumn<bool>(
    'ad_pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ad_pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _taskCompletionPendingMeta =
      const VerificationMeta('taskCompletionPending');
  @override
  late final GeneratedColumn<bool> taskCompletionPending =
      GeneratedColumn<bool>(
        'task_completion_pending',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("task_completion_pending" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _completedWhileAppWasAwayMeta =
      const VerificationMeta('completedWhileAppWasAway');
  @override
  late final GeneratedColumn<bool> completedWhileAppWasAway =
      GeneratedColumn<bool>(
        'completed_while_app_was_away',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("completed_while_app_was_away" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _awaySecondsAfterCompletionMeta =
      const VerificationMeta('awaySecondsAfterCompletion');
  @override
  late final GeneratedColumn<int> awaySecondsAfterCompletion =
      GeneratedColumn<int>(
        'away_seconds_after_completion',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    sessionId,
    mode,
    completedSeconds,
    gemDelta,
    completedAt,
    taskId,
    taskTitle,
    inAppPending,
    notificationPending,
    adPending,
    taskCompletionPending,
    completedWhileAppWasAway,
    awaySecondsAfterCompletion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_timer_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingTimerSummaryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('completed_seconds')) {
      context.handle(
        _completedSecondsMeta,
        completedSeconds.isAcceptableOrUnknown(
          data['completed_seconds']!,
          _completedSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedSecondsMeta);
    }
    if (data.containsKey('gem_delta')) {
      context.handle(
        _gemDeltaMeta,
        gemDelta.isAcceptableOrUnknown(data['gem_delta']!, _gemDeltaMeta),
      );
    } else if (isInserting) {
      context.missing(_gemDeltaMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    }
    if (data.containsKey('in_app_pending')) {
      context.handle(
        _inAppPendingMeta,
        inAppPending.isAcceptableOrUnknown(
          data['in_app_pending']!,
          _inAppPendingMeta,
        ),
      );
    }
    if (data.containsKey('notification_pending')) {
      context.handle(
        _notificationPendingMeta,
        notificationPending.isAcceptableOrUnknown(
          data['notification_pending']!,
          _notificationPendingMeta,
        ),
      );
    }
    if (data.containsKey('ad_pending')) {
      context.handle(
        _adPendingMeta,
        adPending.isAcceptableOrUnknown(data['ad_pending']!, _adPendingMeta),
      );
    }
    if (data.containsKey('task_completion_pending')) {
      context.handle(
        _taskCompletionPendingMeta,
        taskCompletionPending.isAcceptableOrUnknown(
          data['task_completion_pending']!,
          _taskCompletionPendingMeta,
        ),
      );
    }
    if (data.containsKey('completed_while_app_was_away')) {
      context.handle(
        _completedWhileAppWasAwayMeta,
        completedWhileAppWasAway.isAcceptableOrUnknown(
          data['completed_while_app_was_away']!,
          _completedWhileAppWasAwayMeta,
        ),
      );
    }
    if (data.containsKey('away_seconds_after_completion')) {
      context.handle(
        _awaySecondsAfterCompletionMeta,
        awaySecondsAfterCompletion.isAcceptableOrUnknown(
          data['away_seconds_after_completion']!,
          _awaySecondsAfterCompletionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sessionId};
  @override
  PendingTimerSummaryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingTimerSummaryRow(
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      completedSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_seconds'],
      )!,
      gemDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gem_delta'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      ),
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      ),
      inAppPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}in_app_pending'],
      )!,
      notificationPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notification_pending'],
      )!,
      adPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ad_pending'],
      )!,
      taskCompletionPending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}task_completion_pending'],
      )!,
      completedWhileAppWasAway: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed_while_app_was_away'],
      )!,
      awaySecondsAfterCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}away_seconds_after_completion'],
      ),
    );
  }

  @override
  $PendingTimerSummariesTable createAlias(String alias) {
    return $PendingTimerSummariesTable(attachedDatabase, alias);
  }
}

class PendingTimerSummaryRow extends DataClass
    implements Insertable<PendingTimerSummaryRow> {
  final String sessionId;
  final String mode;
  final int completedSeconds;
  final int gemDelta;
  final DateTime completedAt;
  final int? taskId;
  final String? taskTitle;
  final bool inAppPending;
  final bool notificationPending;
  final bool adPending;
  final bool taskCompletionPending;
  final bool completedWhileAppWasAway;
  final int? awaySecondsAfterCompletion;
  const PendingTimerSummaryRow({
    required this.sessionId,
    required this.mode,
    required this.completedSeconds,
    required this.gemDelta,
    required this.completedAt,
    this.taskId,
    this.taskTitle,
    required this.inAppPending,
    required this.notificationPending,
    required this.adPending,
    required this.taskCompletionPending,
    required this.completedWhileAppWasAway,
    this.awaySecondsAfterCompletion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['session_id'] = Variable<String>(sessionId);
    map['mode'] = Variable<String>(mode);
    map['completed_seconds'] = Variable<int>(completedSeconds);
    map['gem_delta'] = Variable<int>(gemDelta);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || taskTitle != null) {
      map['task_title'] = Variable<String>(taskTitle);
    }
    map['in_app_pending'] = Variable<bool>(inAppPending);
    map['notification_pending'] = Variable<bool>(notificationPending);
    map['ad_pending'] = Variable<bool>(adPending);
    map['task_completion_pending'] = Variable<bool>(taskCompletionPending);
    map['completed_while_app_was_away'] = Variable<bool>(
      completedWhileAppWasAway,
    );
    if (!nullToAbsent || awaySecondsAfterCompletion != null) {
      map['away_seconds_after_completion'] = Variable<int>(
        awaySecondsAfterCompletion,
      );
    }
    return map;
  }

  PendingTimerSummariesCompanion toCompanion(bool nullToAbsent) {
    return PendingTimerSummariesCompanion(
      sessionId: Value(sessionId),
      mode: Value(mode),
      completedSeconds: Value(completedSeconds),
      gemDelta: Value(gemDelta),
      completedAt: Value(completedAt),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      taskTitle: taskTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(taskTitle),
      inAppPending: Value(inAppPending),
      notificationPending: Value(notificationPending),
      adPending: Value(adPending),
      taskCompletionPending: Value(taskCompletionPending),
      completedWhileAppWasAway: Value(completedWhileAppWasAway),
      awaySecondsAfterCompletion:
          awaySecondsAfterCompletion == null && nullToAbsent
          ? const Value.absent()
          : Value(awaySecondsAfterCompletion),
    );
  }

  factory PendingTimerSummaryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingTimerSummaryRow(
      sessionId: serializer.fromJson<String>(json['sessionId']),
      mode: serializer.fromJson<String>(json['mode']),
      completedSeconds: serializer.fromJson<int>(json['completedSeconds']),
      gemDelta: serializer.fromJson<int>(json['gemDelta']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      taskTitle: serializer.fromJson<String?>(json['taskTitle']),
      inAppPending: serializer.fromJson<bool>(json['inAppPending']),
      notificationPending: serializer.fromJson<bool>(
        json['notificationPending'],
      ),
      adPending: serializer.fromJson<bool>(json['adPending']),
      taskCompletionPending: serializer.fromJson<bool>(
        json['taskCompletionPending'],
      ),
      completedWhileAppWasAway: serializer.fromJson<bool>(
        json['completedWhileAppWasAway'],
      ),
      awaySecondsAfterCompletion: serializer.fromJson<int?>(
        json['awaySecondsAfterCompletion'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sessionId': serializer.toJson<String>(sessionId),
      'mode': serializer.toJson<String>(mode),
      'completedSeconds': serializer.toJson<int>(completedSeconds),
      'gemDelta': serializer.toJson<int>(gemDelta),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'taskId': serializer.toJson<int?>(taskId),
      'taskTitle': serializer.toJson<String?>(taskTitle),
      'inAppPending': serializer.toJson<bool>(inAppPending),
      'notificationPending': serializer.toJson<bool>(notificationPending),
      'adPending': serializer.toJson<bool>(adPending),
      'taskCompletionPending': serializer.toJson<bool>(taskCompletionPending),
      'completedWhileAppWasAway': serializer.toJson<bool>(
        completedWhileAppWasAway,
      ),
      'awaySecondsAfterCompletion': serializer.toJson<int?>(
        awaySecondsAfterCompletion,
      ),
    };
  }

  PendingTimerSummaryRow copyWith({
    String? sessionId,
    String? mode,
    int? completedSeconds,
    int? gemDelta,
    DateTime? completedAt,
    Value<int?> taskId = const Value.absent(),
    Value<String?> taskTitle = const Value.absent(),
    bool? inAppPending,
    bool? notificationPending,
    bool? adPending,
    bool? taskCompletionPending,
    bool? completedWhileAppWasAway,
    Value<int?> awaySecondsAfterCompletion = const Value.absent(),
  }) => PendingTimerSummaryRow(
    sessionId: sessionId ?? this.sessionId,
    mode: mode ?? this.mode,
    completedSeconds: completedSeconds ?? this.completedSeconds,
    gemDelta: gemDelta ?? this.gemDelta,
    completedAt: completedAt ?? this.completedAt,
    taskId: taskId.present ? taskId.value : this.taskId,
    taskTitle: taskTitle.present ? taskTitle.value : this.taskTitle,
    inAppPending: inAppPending ?? this.inAppPending,
    notificationPending: notificationPending ?? this.notificationPending,
    adPending: adPending ?? this.adPending,
    taskCompletionPending: taskCompletionPending ?? this.taskCompletionPending,
    completedWhileAppWasAway:
        completedWhileAppWasAway ?? this.completedWhileAppWasAway,
    awaySecondsAfterCompletion: awaySecondsAfterCompletion.present
        ? awaySecondsAfterCompletion.value
        : this.awaySecondsAfterCompletion,
  );
  PendingTimerSummaryRow copyWithCompanion(
    PendingTimerSummariesCompanion data,
  ) {
    return PendingTimerSummaryRow(
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      mode: data.mode.present ? data.mode.value : this.mode,
      completedSeconds: data.completedSeconds.present
          ? data.completedSeconds.value
          : this.completedSeconds,
      gemDelta: data.gemDelta.present ? data.gemDelta.value : this.gemDelta,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      inAppPending: data.inAppPending.present
          ? data.inAppPending.value
          : this.inAppPending,
      notificationPending: data.notificationPending.present
          ? data.notificationPending.value
          : this.notificationPending,
      adPending: data.adPending.present ? data.adPending.value : this.adPending,
      taskCompletionPending: data.taskCompletionPending.present
          ? data.taskCompletionPending.value
          : this.taskCompletionPending,
      completedWhileAppWasAway: data.completedWhileAppWasAway.present
          ? data.completedWhileAppWasAway.value
          : this.completedWhileAppWasAway,
      awaySecondsAfterCompletion: data.awaySecondsAfterCompletion.present
          ? data.awaySecondsAfterCompletion.value
          : this.awaySecondsAfterCompletion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingTimerSummaryRow(')
          ..write('sessionId: $sessionId, ')
          ..write('mode: $mode, ')
          ..write('completedSeconds: $completedSeconds, ')
          ..write('gemDelta: $gemDelta, ')
          ..write('completedAt: $completedAt, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('inAppPending: $inAppPending, ')
          ..write('notificationPending: $notificationPending, ')
          ..write('adPending: $adPending, ')
          ..write('taskCompletionPending: $taskCompletionPending, ')
          ..write('completedWhileAppWasAway: $completedWhileAppWasAway, ')
          ..write('awaySecondsAfterCompletion: $awaySecondsAfterCompletion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sessionId,
    mode,
    completedSeconds,
    gemDelta,
    completedAt,
    taskId,
    taskTitle,
    inAppPending,
    notificationPending,
    adPending,
    taskCompletionPending,
    completedWhileAppWasAway,
    awaySecondsAfterCompletion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingTimerSummaryRow &&
          other.sessionId == this.sessionId &&
          other.mode == this.mode &&
          other.completedSeconds == this.completedSeconds &&
          other.gemDelta == this.gemDelta &&
          other.completedAt == this.completedAt &&
          other.taskId == this.taskId &&
          other.taskTitle == this.taskTitle &&
          other.inAppPending == this.inAppPending &&
          other.notificationPending == this.notificationPending &&
          other.adPending == this.adPending &&
          other.taskCompletionPending == this.taskCompletionPending &&
          other.completedWhileAppWasAway == this.completedWhileAppWasAway &&
          other.awaySecondsAfterCompletion == this.awaySecondsAfterCompletion);
}

class PendingTimerSummariesCompanion
    extends UpdateCompanion<PendingTimerSummaryRow> {
  final Value<String> sessionId;
  final Value<String> mode;
  final Value<int> completedSeconds;
  final Value<int> gemDelta;
  final Value<DateTime> completedAt;
  final Value<int?> taskId;
  final Value<String?> taskTitle;
  final Value<bool> inAppPending;
  final Value<bool> notificationPending;
  final Value<bool> adPending;
  final Value<bool> taskCompletionPending;
  final Value<bool> completedWhileAppWasAway;
  final Value<int?> awaySecondsAfterCompletion;
  final Value<int> rowid;
  const PendingTimerSummariesCompanion({
    this.sessionId = const Value.absent(),
    this.mode = const Value.absent(),
    this.completedSeconds = const Value.absent(),
    this.gemDelta = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.inAppPending = const Value.absent(),
    this.notificationPending = const Value.absent(),
    this.adPending = const Value.absent(),
    this.taskCompletionPending = const Value.absent(),
    this.completedWhileAppWasAway = const Value.absent(),
    this.awaySecondsAfterCompletion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingTimerSummariesCompanion.insert({
    required String sessionId,
    required String mode,
    required int completedSeconds,
    required int gemDelta,
    required DateTime completedAt,
    this.taskId = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.inAppPending = const Value.absent(),
    this.notificationPending = const Value.absent(),
    this.adPending = const Value.absent(),
    this.taskCompletionPending = const Value.absent(),
    this.completedWhileAppWasAway = const Value.absent(),
    this.awaySecondsAfterCompletion = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sessionId = Value(sessionId),
       mode = Value(mode),
       completedSeconds = Value(completedSeconds),
       gemDelta = Value(gemDelta),
       completedAt = Value(completedAt);
  static Insertable<PendingTimerSummaryRow> custom({
    Expression<String>? sessionId,
    Expression<String>? mode,
    Expression<int>? completedSeconds,
    Expression<int>? gemDelta,
    Expression<DateTime>? completedAt,
    Expression<int>? taskId,
    Expression<String>? taskTitle,
    Expression<bool>? inAppPending,
    Expression<bool>? notificationPending,
    Expression<bool>? adPending,
    Expression<bool>? taskCompletionPending,
    Expression<bool>? completedWhileAppWasAway,
    Expression<int>? awaySecondsAfterCompletion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sessionId != null) 'session_id': sessionId,
      if (mode != null) 'mode': mode,
      if (completedSeconds != null) 'completed_seconds': completedSeconds,
      if (gemDelta != null) 'gem_delta': gemDelta,
      if (completedAt != null) 'completed_at': completedAt,
      if (taskId != null) 'task_id': taskId,
      if (taskTitle != null) 'task_title': taskTitle,
      if (inAppPending != null) 'in_app_pending': inAppPending,
      if (notificationPending != null)
        'notification_pending': notificationPending,
      if (adPending != null) 'ad_pending': adPending,
      if (taskCompletionPending != null)
        'task_completion_pending': taskCompletionPending,
      if (completedWhileAppWasAway != null)
        'completed_while_app_was_away': completedWhileAppWasAway,
      if (awaySecondsAfterCompletion != null)
        'away_seconds_after_completion': awaySecondsAfterCompletion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingTimerSummariesCompanion copyWith({
    Value<String>? sessionId,
    Value<String>? mode,
    Value<int>? completedSeconds,
    Value<int>? gemDelta,
    Value<DateTime>? completedAt,
    Value<int?>? taskId,
    Value<String?>? taskTitle,
    Value<bool>? inAppPending,
    Value<bool>? notificationPending,
    Value<bool>? adPending,
    Value<bool>? taskCompletionPending,
    Value<bool>? completedWhileAppWasAway,
    Value<int?>? awaySecondsAfterCompletion,
    Value<int>? rowid,
  }) {
    return PendingTimerSummariesCompanion(
      sessionId: sessionId ?? this.sessionId,
      mode: mode ?? this.mode,
      completedSeconds: completedSeconds ?? this.completedSeconds,
      gemDelta: gemDelta ?? this.gemDelta,
      completedAt: completedAt ?? this.completedAt,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      inAppPending: inAppPending ?? this.inAppPending,
      notificationPending: notificationPending ?? this.notificationPending,
      adPending: adPending ?? this.adPending,
      taskCompletionPending:
          taskCompletionPending ?? this.taskCompletionPending,
      completedWhileAppWasAway:
          completedWhileAppWasAway ?? this.completedWhileAppWasAway,
      awaySecondsAfterCompletion:
          awaySecondsAfterCompletion ?? this.awaySecondsAfterCompletion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (completedSeconds.present) {
      map['completed_seconds'] = Variable<int>(completedSeconds.value);
    }
    if (gemDelta.present) {
      map['gem_delta'] = Variable<int>(gemDelta.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (inAppPending.present) {
      map['in_app_pending'] = Variable<bool>(inAppPending.value);
    }
    if (notificationPending.present) {
      map['notification_pending'] = Variable<bool>(notificationPending.value);
    }
    if (adPending.present) {
      map['ad_pending'] = Variable<bool>(adPending.value);
    }
    if (taskCompletionPending.present) {
      map['task_completion_pending'] = Variable<bool>(
        taskCompletionPending.value,
      );
    }
    if (completedWhileAppWasAway.present) {
      map['completed_while_app_was_away'] = Variable<bool>(
        completedWhileAppWasAway.value,
      );
    }
    if (awaySecondsAfterCompletion.present) {
      map['away_seconds_after_completion'] = Variable<int>(
        awaySecondsAfterCompletion.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingTimerSummariesCompanion(')
          ..write('sessionId: $sessionId, ')
          ..write('mode: $mode, ')
          ..write('completedSeconds: $completedSeconds, ')
          ..write('gemDelta: $gemDelta, ')
          ..write('completedAt: $completedAt, ')
          ..write('taskId: $taskId, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('inAppPending: $inAppPending, ')
          ..write('notificationPending: $notificationPending, ')
          ..write('adPending: $adPending, ')
          ..write('taskCompletionPending: $taskCompletionPending, ')
          ..write('completedWhileAppWasAway: $completedWhileAppWasAway, ')
          ..write('awaySecondsAfterCompletion: $awaySecondsAfterCompletion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimerProgressTable timerProgress = $TimerProgressTable(this);
  late final $TaskRecurrenceRulesTable taskRecurrenceRules =
      $TaskRecurrenceRulesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ActiveTimerSessionsTable activeTimerSessions =
      $ActiveTimerSessionsTable(this);
  late final $PendingTimerSummariesTable pendingTimerSummaries =
      $PendingTimerSummariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    timerProgress,
    taskRecurrenceRules,
    tasks,
    activeTimerSessions,
    pendingTimerSummaries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'task_recurrence_rules',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
  ]);
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
typedef $$TaskRecurrenceRulesTableCreateCompanionBuilder =
    TaskRecurrenceRulesCompanion Function({
      Value<int> id,
      required String frequency,
      required int interval,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TaskRecurrenceRulesTableUpdateCompanionBuilder =
    TaskRecurrenceRulesCompanion Function({
      Value<int> id,
      Value<String> frequency,
      Value<int> interval,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TaskRecurrenceRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TaskRecurrenceRulesTable,
          TaskRecurrenceRuleRow
        > {
  $$TaskRecurrenceRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TasksTable, List<TaskRow>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'task_recurrence_rules__id__tasks__recurrence_rule_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.recurrenceRuleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TaskRecurrenceRulesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskRecurrenceRulesTable> {
  $$TaskRecurrenceRulesTableFilterComposer({
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

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.recurrenceRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskRecurrenceRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskRecurrenceRulesTable> {
  $$TaskRecurrenceRulesTableOrderingComposer({
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

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

class $$TaskRecurrenceRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskRecurrenceRulesTable> {
  $$TaskRecurrenceRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.recurrenceRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskRecurrenceRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskRecurrenceRulesTable,
          TaskRecurrenceRuleRow,
          $$TaskRecurrenceRulesTableFilterComposer,
          $$TaskRecurrenceRulesTableOrderingComposer,
          $$TaskRecurrenceRulesTableAnnotationComposer,
          $$TaskRecurrenceRulesTableCreateCompanionBuilder,
          $$TaskRecurrenceRulesTableUpdateCompanionBuilder,
          (TaskRecurrenceRuleRow, $$TaskRecurrenceRulesTableReferences),
          TaskRecurrenceRuleRow,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$TaskRecurrenceRulesTableTableManager(
    _$AppDatabase db,
    $TaskRecurrenceRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskRecurrenceRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskRecurrenceRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TaskRecurrenceRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TaskRecurrenceRulesCompanion(
                id: id,
                frequency: frequency,
                interval: interval,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String frequency,
                required int interval,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TaskRecurrenceRulesCompanion.insert(
                id: id,
                frequency: frequency,
                interval: interval,
                startDate: startDate,
                endDate: endDate,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskRecurrenceRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<
                      TaskRecurrenceRuleRow,
                      $TaskRecurrenceRulesTable,
                      TaskRow
                    >(
                      currentTable: table,
                      referencedTable: $$TaskRecurrenceRulesTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TaskRecurrenceRulesTableReferences(
                            db,
                            table,
                            p0,
                          ).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.recurrenceRuleId == item.id,
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

typedef $$TaskRecurrenceRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskRecurrenceRulesTable,
      TaskRecurrenceRuleRow,
      $$TaskRecurrenceRulesTableFilterComposer,
      $$TaskRecurrenceRulesTableOrderingComposer,
      $$TaskRecurrenceRulesTableAnnotationComposer,
      $$TaskRecurrenceRulesTableCreateCompanionBuilder,
      $$TaskRecurrenceRulesTableUpdateCompanionBuilder,
      (TaskRecurrenceRuleRow, $$TaskRecurrenceRulesTableReferences),
      TaskRecurrenceRuleRow,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      Value<bool> isCompleted,
      Value<DateTime?> dueDate,
      Value<int?> focusMinutes,
      Value<DateTime?> completedAt,
      Value<int?> recurrenceRuleId,
      Value<DateTime?> occurrenceDate,
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
      Value<DateTime?> completedAt,
      Value<int?> recurrenceRuleId,
      Value<DateTime?> occurrenceDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, TaskRow> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskRecurrenceRulesTable _recurrenceRuleIdTable(_$AppDatabase db) =>
      db.taskRecurrenceRules.createAlias(
        'tasks__recurrence_rule_id__task_recurrence_rules__id',
      );

  $$TaskRecurrenceRulesTableProcessedTableManager? get recurrenceRuleId {
    final $_column = $_itemColumn<int>('recurrence_rule_id');
    if ($_column == null) return null;
    final manager = $$TaskRecurrenceRulesTableTableManager(
      $_db,
      $_db.taskRecurrenceRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurrenceRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

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

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
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

  $$TaskRecurrenceRulesTableFilterComposer get recurrenceRuleId {
    final $$TaskRecurrenceRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recurrenceRuleId,
      referencedTable: $db.taskRecurrenceRules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskRecurrenceRulesTableFilterComposer(
            $db: $db,
            $table: $db.taskRecurrenceRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
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

  $$TaskRecurrenceRulesTableOrderingComposer get recurrenceRuleId {
    final $$TaskRecurrenceRulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceRuleId,
          referencedTable: $db.taskRecurrenceRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskRecurrenceRulesTableOrderingComposer(
                $db: $db,
                $table: $db.taskRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
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

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurrenceDate => $composableBuilder(
    column: $table.occurrenceDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TaskRecurrenceRulesTableAnnotationComposer get recurrenceRuleId {
    final $$TaskRecurrenceRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurrenceRuleId,
          referencedTable: $db.taskRecurrenceRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TaskRecurrenceRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.taskRecurrenceRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
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
          (TaskRow, $$TasksTableReferences),
          TaskRow,
          PrefetchHooks Function({bool recurrenceRuleId})
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
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> recurrenceRuleId = const Value.absent(),
                Value<DateTime?> occurrenceDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                isCompleted: isCompleted,
                dueDate: dueDate,
                focusMinutes: focusMinutes,
                completedAt: completedAt,
                recurrenceRuleId: recurrenceRuleId,
                occurrenceDate: occurrenceDate,
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
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> recurrenceRuleId = const Value.absent(),
                Value<DateTime?> occurrenceDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                isCompleted: isCompleted,
                dueDate: dueDate,
                focusMinutes: focusMinutes,
                completedAt: completedAt,
                recurrenceRuleId: recurrenceRuleId,
                occurrenceDate: occurrenceDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({recurrenceRuleId = false}) {
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
                    if (recurrenceRuleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recurrenceRuleId,
                                referencedTable: $$TasksTableReferences
                                    ._recurrenceRuleIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._recurrenceRuleIdTable(db)
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
      (TaskRow, $$TasksTableReferences),
      TaskRow,
      PrefetchHooks Function({bool recurrenceRuleId})
    >;
typedef $$ActiveTimerSessionsTableCreateCompanionBuilder =
    ActiveTimerSessionsCompanion Function({
      Value<int> id,
      required String sessionId,
      required String mode,
      required String state,
      required int selectedSeconds,
      required int remainingSeconds,
      required int elapsedSeconds,
      required int rewardedBlocks,
      required int chargedMinutes,
      required DateTime lastCheckpointAt,
      Value<DateTime?> endsAt,
      Value<int?> linkedTaskId,
      Value<String?> linkedTaskTitle,
    });
typedef $$ActiveTimerSessionsTableUpdateCompanionBuilder =
    ActiveTimerSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<String> mode,
      Value<String> state,
      Value<int> selectedSeconds,
      Value<int> remainingSeconds,
      Value<int> elapsedSeconds,
      Value<int> rewardedBlocks,
      Value<int> chargedMinutes,
      Value<DateTime> lastCheckpointAt,
      Value<DateTime?> endsAt,
      Value<int?> linkedTaskId,
      Value<String?> linkedTaskTitle,
    });

class $$ActiveTimerSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ActiveTimerSessionsTable> {
  $$ActiveTimerSessionsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedSeconds => $composableBuilder(
    column: $table.selectedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardedBlocks => $composableBuilder(
    column: $table.rewardedBlocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargedMinutes => $composableBuilder(
    column: $table.chargedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCheckpointAt => $composableBuilder(
    column: $table.lastCheckpointAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get linkedTaskId => $composableBuilder(
    column: $table.linkedTaskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedTaskTitle => $composableBuilder(
    column: $table.linkedTaskTitle,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActiveTimerSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActiveTimerSessionsTable> {
  $$ActiveTimerSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedSeconds => $composableBuilder(
    column: $table.selectedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardedBlocks => $composableBuilder(
    column: $table.rewardedBlocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargedMinutes => $composableBuilder(
    column: $table.chargedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCheckpointAt => $composableBuilder(
    column: $table.lastCheckpointAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get linkedTaskId => $composableBuilder(
    column: $table.linkedTaskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedTaskTitle => $composableBuilder(
    column: $table.linkedTaskTitle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActiveTimerSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActiveTimerSessionsTable> {
  $$ActiveTimerSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get selectedSeconds => $composableBuilder(
    column: $table.selectedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingSeconds => $composableBuilder(
    column: $table.remainingSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedSeconds => $composableBuilder(
    column: $table.elapsedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardedBlocks => $composableBuilder(
    column: $table.rewardedBlocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargedMinutes => $composableBuilder(
    column: $table.chargedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCheckpointAt => $composableBuilder(
    column: $table.lastCheckpointAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<int> get linkedTaskId => $composableBuilder(
    column: $table.linkedTaskId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedTaskTitle => $composableBuilder(
    column: $table.linkedTaskTitle,
    builder: (column) => column,
  );
}

class $$ActiveTimerSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActiveTimerSessionsTable,
          ActiveTimerSessionRow,
          $$ActiveTimerSessionsTableFilterComposer,
          $$ActiveTimerSessionsTableOrderingComposer,
          $$ActiveTimerSessionsTableAnnotationComposer,
          $$ActiveTimerSessionsTableCreateCompanionBuilder,
          $$ActiveTimerSessionsTableUpdateCompanionBuilder,
          (
            ActiveTimerSessionRow,
            BaseReferences<
              _$AppDatabase,
              $ActiveTimerSessionsTable,
              ActiveTimerSessionRow
            >,
          ),
          ActiveTimerSessionRow,
          PrefetchHooks Function()
        > {
  $$ActiveTimerSessionsTableTableManager(
    _$AppDatabase db,
    $ActiveTimerSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActiveTimerSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActiveTimerSessionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ActiveTimerSessionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> selectedSeconds = const Value.absent(),
                Value<int> remainingSeconds = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int> rewardedBlocks = const Value.absent(),
                Value<int> chargedMinutes = const Value.absent(),
                Value<DateTime> lastCheckpointAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int?> linkedTaskId = const Value.absent(),
                Value<String?> linkedTaskTitle = const Value.absent(),
              }) => ActiveTimerSessionsCompanion(
                id: id,
                sessionId: sessionId,
                mode: mode,
                state: state,
                selectedSeconds: selectedSeconds,
                remainingSeconds: remainingSeconds,
                elapsedSeconds: elapsedSeconds,
                rewardedBlocks: rewardedBlocks,
                chargedMinutes: chargedMinutes,
                lastCheckpointAt: lastCheckpointAt,
                endsAt: endsAt,
                linkedTaskId: linkedTaskId,
                linkedTaskTitle: linkedTaskTitle,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required String mode,
                required String state,
                required int selectedSeconds,
                required int remainingSeconds,
                required int elapsedSeconds,
                required int rewardedBlocks,
                required int chargedMinutes,
                required DateTime lastCheckpointAt,
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int?> linkedTaskId = const Value.absent(),
                Value<String?> linkedTaskTitle = const Value.absent(),
              }) => ActiveTimerSessionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                mode: mode,
                state: state,
                selectedSeconds: selectedSeconds,
                remainingSeconds: remainingSeconds,
                elapsedSeconds: elapsedSeconds,
                rewardedBlocks: rewardedBlocks,
                chargedMinutes: chargedMinutes,
                lastCheckpointAt: lastCheckpointAt,
                endsAt: endsAt,
                linkedTaskId: linkedTaskId,
                linkedTaskTitle: linkedTaskTitle,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActiveTimerSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActiveTimerSessionsTable,
      ActiveTimerSessionRow,
      $$ActiveTimerSessionsTableFilterComposer,
      $$ActiveTimerSessionsTableOrderingComposer,
      $$ActiveTimerSessionsTableAnnotationComposer,
      $$ActiveTimerSessionsTableCreateCompanionBuilder,
      $$ActiveTimerSessionsTableUpdateCompanionBuilder,
      (
        ActiveTimerSessionRow,
        BaseReferences<
          _$AppDatabase,
          $ActiveTimerSessionsTable,
          ActiveTimerSessionRow
        >,
      ),
      ActiveTimerSessionRow,
      PrefetchHooks Function()
    >;
typedef $$PendingTimerSummariesTableCreateCompanionBuilder =
    PendingTimerSummariesCompanion Function({
      required String sessionId,
      required String mode,
      required int completedSeconds,
      required int gemDelta,
      required DateTime completedAt,
      Value<int?> taskId,
      Value<String?> taskTitle,
      Value<bool> inAppPending,
      Value<bool> notificationPending,
      Value<bool> adPending,
      Value<bool> taskCompletionPending,
      Value<bool> completedWhileAppWasAway,
      Value<int?> awaySecondsAfterCompletion,
      Value<int> rowid,
    });
typedef $$PendingTimerSummariesTableUpdateCompanionBuilder =
    PendingTimerSummariesCompanion Function({
      Value<String> sessionId,
      Value<String> mode,
      Value<int> completedSeconds,
      Value<int> gemDelta,
      Value<DateTime> completedAt,
      Value<int?> taskId,
      Value<String?> taskTitle,
      Value<bool> inAppPending,
      Value<bool> notificationPending,
      Value<bool> adPending,
      Value<bool> taskCompletionPending,
      Value<bool> completedWhileAppWasAway,
      Value<int?> awaySecondsAfterCompletion,
      Value<int> rowid,
    });

class $$PendingTimerSummariesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingTimerSummariesTable> {
  $$PendingTimerSummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedSeconds => $composableBuilder(
    column: $table.completedSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gemDelta => $composableBuilder(
    column: $table.gemDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inAppPending => $composableBuilder(
    column: $table.inAppPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationPending => $composableBuilder(
    column: $table.notificationPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get adPending => $composableBuilder(
    column: $table.adPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get taskCompletionPending => $composableBuilder(
    column: $table.taskCompletionPending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completedWhileAppWasAway => $composableBuilder(
    column: $table.completedWhileAppWasAway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awaySecondsAfterCompletion => $composableBuilder(
    column: $table.awaySecondsAfterCompletion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingTimerSummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingTimerSummariesTable> {
  $$PendingTimerSummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedSeconds => $composableBuilder(
    column: $table.completedSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gemDelta => $composableBuilder(
    column: $table.gemDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inAppPending => $composableBuilder(
    column: $table.inAppPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationPending => $composableBuilder(
    column: $table.notificationPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adPending => $composableBuilder(
    column: $table.adPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get taskCompletionPending => $composableBuilder(
    column: $table.taskCompletionPending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completedWhileAppWasAway => $composableBuilder(
    column: $table.completedWhileAppWasAway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awaySecondsAfterCompletion => $composableBuilder(
    column: $table.awaySecondsAfterCompletion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingTimerSummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingTimerSummariesTable> {
  $$PendingTimerSummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get completedSeconds => $composableBuilder(
    column: $table.completedSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gemDelta =>
      $composableBuilder(column: $table.gemDelta, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<bool> get inAppPending => $composableBuilder(
    column: $table.inAppPending,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationPending => $composableBuilder(
    column: $table.notificationPending,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get adPending =>
      $composableBuilder(column: $table.adPending, builder: (column) => column);

  GeneratedColumn<bool> get taskCompletionPending => $composableBuilder(
    column: $table.taskCompletionPending,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completedWhileAppWasAway => $composableBuilder(
    column: $table.completedWhileAppWasAway,
    builder: (column) => column,
  );

  GeneratedColumn<int> get awaySecondsAfterCompletion => $composableBuilder(
    column: $table.awaySecondsAfterCompletion,
    builder: (column) => column,
  );
}

class $$PendingTimerSummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingTimerSummariesTable,
          PendingTimerSummaryRow,
          $$PendingTimerSummariesTableFilterComposer,
          $$PendingTimerSummariesTableOrderingComposer,
          $$PendingTimerSummariesTableAnnotationComposer,
          $$PendingTimerSummariesTableCreateCompanionBuilder,
          $$PendingTimerSummariesTableUpdateCompanionBuilder,
          (
            PendingTimerSummaryRow,
            BaseReferences<
              _$AppDatabase,
              $PendingTimerSummariesTable,
              PendingTimerSummaryRow
            >,
          ),
          PendingTimerSummaryRow,
          PrefetchHooks Function()
        > {
  $$PendingTimerSummariesTableTableManager(
    _$AppDatabase db,
    $PendingTimerSummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingTimerSummariesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingTimerSummariesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingTimerSummariesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sessionId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> completedSeconds = const Value.absent(),
                Value<int> gemDelta = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<String?> taskTitle = const Value.absent(),
                Value<bool> inAppPending = const Value.absent(),
                Value<bool> notificationPending = const Value.absent(),
                Value<bool> adPending = const Value.absent(),
                Value<bool> taskCompletionPending = const Value.absent(),
                Value<bool> completedWhileAppWasAway = const Value.absent(),
                Value<int?> awaySecondsAfterCompletion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTimerSummariesCompanion(
                sessionId: sessionId,
                mode: mode,
                completedSeconds: completedSeconds,
                gemDelta: gemDelta,
                completedAt: completedAt,
                taskId: taskId,
                taskTitle: taskTitle,
                inAppPending: inAppPending,
                notificationPending: notificationPending,
                adPending: adPending,
                taskCompletionPending: taskCompletionPending,
                completedWhileAppWasAway: completedWhileAppWasAway,
                awaySecondsAfterCompletion: awaySecondsAfterCompletion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sessionId,
                required String mode,
                required int completedSeconds,
                required int gemDelta,
                required DateTime completedAt,
                Value<int?> taskId = const Value.absent(),
                Value<String?> taskTitle = const Value.absent(),
                Value<bool> inAppPending = const Value.absent(),
                Value<bool> notificationPending = const Value.absent(),
                Value<bool> adPending = const Value.absent(),
                Value<bool> taskCompletionPending = const Value.absent(),
                Value<bool> completedWhileAppWasAway = const Value.absent(),
                Value<int?> awaySecondsAfterCompletion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingTimerSummariesCompanion.insert(
                sessionId: sessionId,
                mode: mode,
                completedSeconds: completedSeconds,
                gemDelta: gemDelta,
                completedAt: completedAt,
                taskId: taskId,
                taskTitle: taskTitle,
                inAppPending: inAppPending,
                notificationPending: notificationPending,
                adPending: adPending,
                taskCompletionPending: taskCompletionPending,
                completedWhileAppWasAway: completedWhileAppWasAway,
                awaySecondsAfterCompletion: awaySecondsAfterCompletion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingTimerSummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingTimerSummariesTable,
      PendingTimerSummaryRow,
      $$PendingTimerSummariesTableFilterComposer,
      $$PendingTimerSummariesTableOrderingComposer,
      $$PendingTimerSummariesTableAnnotationComposer,
      $$PendingTimerSummariesTableCreateCompanionBuilder,
      $$PendingTimerSummariesTableUpdateCompanionBuilder,
      (
        PendingTimerSummaryRow,
        BaseReferences<
          _$AppDatabase,
          $PendingTimerSummariesTable,
          PendingTimerSummaryRow
        >,
      ),
      PendingTimerSummaryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimerProgressTableTableManager get timerProgress =>
      $$TimerProgressTableTableManager(_db, _db.timerProgress);
  $$TaskRecurrenceRulesTableTableManager get taskRecurrenceRules =>
      $$TaskRecurrenceRulesTableTableManager(_db, _db.taskRecurrenceRules);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ActiveTimerSessionsTableTableManager get activeTimerSessions =>
      $$ActiveTimerSessionsTableTableManager(_db, _db.activeTimerSessions);
  $$PendingTimerSummariesTableTableManager get pendingTimerSummaries =>
      $$PendingTimerSummariesTableTableManager(_db, _db.pendingTimerSummaries);
}
