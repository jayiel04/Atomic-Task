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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TimerProgressTable timerProgress = $TimerProgressTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [timerProgress];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TimerProgressTableTableManager get timerProgress =>
      $$TimerProgressTableTableManager(_db, _db.timerProgress);
}
