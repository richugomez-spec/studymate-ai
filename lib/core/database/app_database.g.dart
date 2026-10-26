// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SemestersTable extends Semesters
    with TableInfo<$SemestersTable, Semester> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemestersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _overallProgressMeta =
      const VerificationMeta('overallProgress');
  @override
  late final GeneratedColumn<double> overallProgress = GeneratedColumn<double>(
      'overall_progress', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        description,
        number,
        startDate,
        endDate,
        isActive,
        isArchived,
        overallProgress,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semesters';
  @override
  VerificationContext validateIntegrity(Insertable<Semester> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('overall_progress')) {
      context.handle(
          _overallProgressMeta,
          overallProgress.isAcceptableOrUnknown(
              data['overall_progress']!, _overallProgressMeta));
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Semester map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Semester(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      overallProgress: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}overall_progress'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $SemestersTable createAlias(String alias) {
    return $SemestersTable(attachedDatabase, alias);
  }
}

class Semester extends DataClass implements Insertable<Semester> {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int number;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isArchived;
  final double overallProgress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Semester(
      {required this.id,
      required this.userId,
      required this.name,
      this.description,
      required this.number,
      required this.startDate,
      required this.endDate,
      required this.isActive,
      required this.isArchived,
      required this.overallProgress,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['number'] = Variable<int>(number);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['is_active'] = Variable<bool>(isActive);
    map['is_archived'] = Variable<bool>(isArchived);
    map['overall_progress'] = Variable<double>(overallProgress);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SemestersCompanion toCompanion(bool nullToAbsent) {
    return SemestersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      number: Value(number),
      startDate: Value(startDate),
      endDate: Value(endDate),
      isActive: Value(isActive),
      isArchived: Value(isArchived),
      overallProgress: Value(overallProgress),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Semester.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Semester(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      number: serializer.fromJson<int>(json['number']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      overallProgress: serializer.fromJson<double>(json['overallProgress']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'number': serializer.toJson<int>(number),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'isActive': serializer.toJson<bool>(isActive),
      'isArchived': serializer.toJson<bool>(isArchived),
      'overallProgress': serializer.toJson<double>(overallProgress),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Semester copyWith(
          {String? id,
          String? userId,
          String? name,
          Value<String?> description = const Value.absent(),
          int? number,
          DateTime? startDate,
          DateTime? endDate,
          bool? isActive,
          bool? isArchived,
          double? overallProgress,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Semester(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        number: number ?? this.number,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        isActive: isActive ?? this.isActive,
        isArchived: isArchived ?? this.isArchived,
        overallProgress: overallProgress ?? this.overallProgress,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Semester copyWithCompanion(SemestersCompanion data) {
    return Semester(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      number: data.number.present ? data.number.value : this.number,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      overallProgress: data.overallProgress.present
          ? data.overallProgress.value
          : this.overallProgress,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Semester(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('number: $number, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isArchived: $isArchived, ')
          ..write('overallProgress: $overallProgress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      name,
      description,
      number,
      startDate,
      endDate,
      isActive,
      isArchived,
      overallProgress,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Semester &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.number == this.number &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.isActive == this.isActive &&
          other.isArchived == this.isArchived &&
          other.overallProgress == this.overallProgress &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SemestersCompanion extends UpdateCompanion<Semester> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> number;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<bool> isActive;
  final Value<bool> isArchived;
  final Value<double> overallProgress;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SemestersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.number = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.overallProgress = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SemestersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    required int number,
    required DateTime startDate,
    required DateTime endDate,
    this.isActive = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.overallProgress = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        name = Value(name),
        number = Value(number),
        startDate = Value(startDate),
        endDate = Value(endDate),
        createdAt = Value(createdAt);
  static Insertable<Semester> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? number,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<bool>? isActive,
    Expression<bool>? isArchived,
    Expression<double>? overallProgress,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (number != null) 'number': number,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (isActive != null) 'is_active': isActive,
      if (isArchived != null) 'is_archived': isArchived,
      if (overallProgress != null) 'overall_progress': overallProgress,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SemestersCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? number,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<bool>? isActive,
      Value<bool>? isArchived,
      Value<double>? overallProgress,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return SemestersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      number: number ?? this.number,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      overallProgress: overallProgress ?? this.overallProgress,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
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
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (overallProgress.present) {
      map['overall_progress'] = Variable<double>(overallProgress.value);
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
    return (StringBuffer('SemestersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('number: $number, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('isActive: $isActive, ')
          ..write('isArchived: $isArchived, ')
          ..write('overallProgress: $overallProgress, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _semesterIdMeta =
      const VerificationMeta('semesterId');
  @override
  late final GeneratedColumn<String> semesterId = GeneratedColumn<String>(
      'semester_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorIndexMeta =
      const VerificationMeta('colorIndex');
  @override
  late final GeneratedColumn<int> colorIndex = GeneratedColumn<int>(
      'color_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _masteryScoreMeta =
      const VerificationMeta('masteryScore');
  @override
  late final GeneratedColumn<double> masteryScore = GeneratedColumn<double>(
      'mastery_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalStudyMinutesMeta =
      const VerificationMeta('totalStudyMinutes');
  @override
  late final GeneratedColumn<int> totalStudyMinutes = GeneratedColumn<int>(
      'total_study_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        semesterId,
        userId,
        name,
        description,
        code,
        colorIndex,
        iconName,
        masteryScore,
        totalStudyMinutes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('semester_id')) {
      context.handle(
          _semesterIdMeta,
          semesterId.isAcceptableOrUnknown(
              data['semester_id']!, _semesterIdMeta));
    } else if (isInserting) {
      context.missing(_semesterIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    }
    if (data.containsKey('color_index')) {
      context.handle(
          _colorIndexMeta,
          colorIndex.isAcceptableOrUnknown(
              data['color_index']!, _colorIndexMeta));
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    }
    if (data.containsKey('mastery_score')) {
      context.handle(
          _masteryScoreMeta,
          masteryScore.isAcceptableOrUnknown(
              data['mastery_score']!, _masteryScoreMeta));
    }
    if (data.containsKey('total_study_minutes')) {
      context.handle(
          _totalStudyMinutesMeta,
          totalStudyMinutes.isAcceptableOrUnknown(
              data['total_study_minutes']!, _totalStudyMinutesMeta));
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      semesterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}semester_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code']),
      colorIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_index'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name']),
      masteryScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mastery_score'])!,
      totalStudyMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_study_minutes'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final String semesterId;
  final String userId;
  final String name;
  final String? description;
  final String? code;
  final int colorIndex;
  final String? iconName;
  final double masteryScore;
  final int totalStudyMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Subject(
      {required this.id,
      required this.semesterId,
      required this.userId,
      required this.name,
      this.description,
      this.code,
      required this.colorIndex,
      this.iconName,
      required this.masteryScore,
      required this.totalStudyMinutes,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['semester_id'] = Variable<String>(semesterId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['color_index'] = Variable<int>(colorIndex);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    map['mastery_score'] = Variable<double>(masteryScore);
    map['total_study_minutes'] = Variable<int>(totalStudyMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      semesterId: Value(semesterId),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      colorIndex: Value(colorIndex),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      masteryScore: Value(masteryScore),
      totalStudyMinutes: Value(totalStudyMinutes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      semesterId: serializer.fromJson<String>(json['semesterId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      code: serializer.fromJson<String?>(json['code']),
      colorIndex: serializer.fromJson<int>(json['colorIndex']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      masteryScore: serializer.fromJson<double>(json['masteryScore']),
      totalStudyMinutes: serializer.fromJson<int>(json['totalStudyMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'semesterId': serializer.toJson<String>(semesterId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'code': serializer.toJson<String?>(code),
      'colorIndex': serializer.toJson<int>(colorIndex),
      'iconName': serializer.toJson<String?>(iconName),
      'masteryScore': serializer.toJson<double>(masteryScore),
      'totalStudyMinutes': serializer.toJson<int>(totalStudyMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Subject copyWith(
          {String? id,
          String? semesterId,
          String? userId,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> code = const Value.absent(),
          int? colorIndex,
          Value<String?> iconName = const Value.absent(),
          double? masteryScore,
          int? totalStudyMinutes,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Subject(
        id: id ?? this.id,
        semesterId: semesterId ?? this.semesterId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        code: code.present ? code.value : this.code,
        colorIndex: colorIndex ?? this.colorIndex,
        iconName: iconName.present ? iconName.value : this.iconName,
        masteryScore: masteryScore ?? this.masteryScore,
        totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      semesterId:
          data.semesterId.present ? data.semesterId.value : this.semesterId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      code: data.code.present ? data.code.value : this.code,
      colorIndex:
          data.colorIndex.present ? data.colorIndex.value : this.colorIndex,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      masteryScore: data.masteryScore.present
          ? data.masteryScore.value
          : this.masteryScore,
      totalStudyMinutes: data.totalStudyMinutes.present
          ? data.totalStudyMinutes.value
          : this.totalStudyMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('semesterId: $semesterId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('code: $code, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('iconName: $iconName, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('totalStudyMinutes: $totalStudyMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      semesterId,
      userId,
      name,
      description,
      code,
      colorIndex,
      iconName,
      masteryScore,
      totalStudyMinutes,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.semesterId == this.semesterId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.code == this.code &&
          other.colorIndex == this.colorIndex &&
          other.iconName == this.iconName &&
          other.masteryScore == this.masteryScore &&
          other.totalStudyMinutes == this.totalStudyMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<String> semesterId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> code;
  final Value<int> colorIndex;
  final Value<String?> iconName;
  final Value<double> masteryScore;
  final Value<int> totalStudyMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.semesterId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.code = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.totalStudyMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String semesterId,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    this.code = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.iconName = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.totalStudyMinutes = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        semesterId = Value(semesterId),
        userId = Value(userId),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<String>? semesterId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? code,
    Expression<int>? colorIndex,
    Expression<String>? iconName,
    Expression<double>? masteryScore,
    Expression<int>? totalStudyMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (semesterId != null) 'semester_id': semesterId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (code != null) 'code': code,
      if (colorIndex != null) 'color_index': colorIndex,
      if (iconName != null) 'icon_name': iconName,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (totalStudyMinutes != null) 'total_study_minutes': totalStudyMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? semesterId,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? code,
      Value<int>? colorIndex,
      Value<String?>? iconName,
      Value<double>? masteryScore,
      Value<int>? totalStudyMinutes,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      semesterId: semesterId ?? this.semesterId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      colorIndex: colorIndex ?? this.colorIndex,
      iconName: iconName ?? this.iconName,
      masteryScore: masteryScore ?? this.masteryScore,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
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
    if (semesterId.present) {
      map['semester_id'] = Variable<String>(semesterId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (colorIndex.present) {
      map['color_index'] = Variable<int>(colorIndex.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<double>(masteryScore.value);
    }
    if (totalStudyMinutes.present) {
      map['total_study_minutes'] = Variable<int>(totalStudyMinutes.value);
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
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('semesterId: $semesterId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('code: $code, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('iconName: $iconName, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('totalStudyMinutes: $totalStudyMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _masteryScoreMeta =
      const VerificationMeta('masteryScore');
  @override
  late final GeneratedColumn<double> masteryScore = GeneratedColumn<double>(
      'mastery_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        subjectId,
        userId,
        name,
        description,
        sortOrder,
        masteryScore,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<Unit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('mastery_score')) {
      context.handle(
          _masteryScoreMeta,
          masteryScore.isAcceptableOrUnknown(
              data['mastery_score']!, _masteryScoreMeta));
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      masteryScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mastery_score'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String id;
  final String subjectId;
  final String userId;
  final String name;
  final String? description;
  final int sortOrder;
  final double masteryScore;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Unit(
      {required this.id,
      required this.subjectId,
      required this.userId,
      required this.name,
      this.description,
      required this.sortOrder,
      required this.masteryScore,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['mastery_score'] = Variable<double>(masteryScore);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      userId: Value(userId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sortOrder: Value(sortOrder),
      masteryScore: Value(masteryScore),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<String>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      masteryScore: serializer.fromJson<double>(json['masteryScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'masteryScore': serializer.toJson<double>(masteryScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Unit copyWith(
          {String? id,
          String? subjectId,
          String? userId,
          String? name,
          Value<String?> description = const Value.absent(),
          int? sortOrder,
          double? masteryScore,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Unit(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        sortOrder: sortOrder ?? this.sortOrder,
        masteryScore: masteryScore ?? this.masteryScore,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      masteryScore: data.masteryScore.present
          ? data.masteryScore.value
          : this.masteryScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, subjectId, userId, name, description,
      sortOrder, masteryScore, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.description == this.description &&
          other.sortOrder == this.sortOrder &&
          other.masteryScore == this.masteryScore &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> id;
  final Value<String> subjectId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> sortOrder;
  final Value<double> masteryScore;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    required String id,
    required String subjectId,
    required String userId,
    required String name,
    this.description = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.masteryScore = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        subjectId = Value(subjectId),
        userId = Value(userId),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Unit> custom({
    Expression<String>? id,
    Expression<String>? subjectId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? sortOrder,
    Expression<double>? masteryScore,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? subjectId,
      Value<String>? userId,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? sortOrder,
      Value<double>? masteryScore,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return UnitsCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      masteryScore: masteryScore ?? this.masteryScore,
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
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<double>(masteryScore.value);
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
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
      defaultValue: const Constant('not_started'));
  static const VerificationMeta _masteryScoreMeta =
      const VerificationMeta('masteryScore');
  @override
  late final GeneratedColumn<double> masteryScore = GeneratedColumn<double>(
      'mastery_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _weaknessFlagMeta =
      const VerificationMeta('weaknessFlag');
  @override
  late final GeneratedColumn<int> weaknessFlag = GeneratedColumn<int>(
      'weakness_flag', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isAIProcessedMeta =
      const VerificationMeta('isAIProcessed');
  @override
  late final GeneratedColumn<bool> isAIProcessed = GeneratedColumn<bool>(
      'is_a_i_processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_a_i_processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _conceptTagsJsonMeta =
      const VerificationMeta('conceptTagsJson');
  @override
  late final GeneratedColumn<String> conceptTagsJson = GeneratedColumn<String>(
      'concept_tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _learningObjectivesJsonMeta =
      const VerificationMeta('learningObjectivesJson');
  @override
  late final GeneratedColumn<String> learningObjectivesJson =
      GeneratedColumn<String>('learning_objectives_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _totalStudyMinutesMeta =
      const VerificationMeta('totalStudyMinutes');
  @override
  late final GeneratedColumn<int> totalStudyMinutes = GeneratedColumn<int>(
      'total_study_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quizAttemptsMeta =
      const VerificationMeta('quizAttempts');
  @override
  late final GeneratedColumn<int> quizAttempts = GeneratedColumn<int>(
      'quiz_attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _averageQuizScoreMeta =
      const VerificationMeta('averageQuizScore');
  @override
  late final GeneratedColumn<double> averageQuizScore = GeneratedColumn<double>(
      'average_quiz_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _flashcardCountMeta =
      const VerificationMeta('flashcardCount');
  @override
  late final GeneratedColumn<int> flashcardCount = GeneratedColumn<int>(
      'flashcard_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _chatMessageCountMeta =
      const VerificationMeta('chatMessageCount');
  @override
  late final GeneratedColumn<int> chatMessageCount = GeneratedColumn<int>(
      'chat_message_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastStudiedAtMeta =
      const VerificationMeta('lastStudiedAt');
  @override
  late final GeneratedColumn<DateTime> lastStudiedAt =
      GeneratedColumn<DateTime>('last_studied_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextRevisionDueMeta =
      const VerificationMeta('nextRevisionDue');
  @override
  late final GeneratedColumn<DateTime> nextRevisionDue =
      GeneratedColumn<DateTime>('next_revision_due', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        unitId,
        subjectId,
        userId,
        title,
        description,
        status,
        masteryScore,
        weaknessFlag,
        isAIProcessed,
        conceptTagsJson,
        learningObjectivesJson,
        totalStudyMinutes,
        quizAttempts,
        averageQuizScore,
        flashcardCount,
        chatMessageCount,
        lastStudiedAt,
        nextRevisionDue,
        sortOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(Insertable<Topic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('mastery_score')) {
      context.handle(
          _masteryScoreMeta,
          masteryScore.isAcceptableOrUnknown(
              data['mastery_score']!, _masteryScoreMeta));
    }
    if (data.containsKey('weakness_flag')) {
      context.handle(
          _weaknessFlagMeta,
          weaknessFlag.isAcceptableOrUnknown(
              data['weakness_flag']!, _weaknessFlagMeta));
    }
    if (data.containsKey('is_a_i_processed')) {
      context.handle(
          _isAIProcessedMeta,
          isAIProcessed.isAcceptableOrUnknown(
              data['is_a_i_processed']!, _isAIProcessedMeta));
    }
    if (data.containsKey('concept_tags_json')) {
      context.handle(
          _conceptTagsJsonMeta,
          conceptTagsJson.isAcceptableOrUnknown(
              data['concept_tags_json']!, _conceptTagsJsonMeta));
    }
    if (data.containsKey('learning_objectives_json')) {
      context.handle(
          _learningObjectivesJsonMeta,
          learningObjectivesJson.isAcceptableOrUnknown(
              data['learning_objectives_json']!, _learningObjectivesJsonMeta));
    }
    if (data.containsKey('total_study_minutes')) {
      context.handle(
          _totalStudyMinutesMeta,
          totalStudyMinutes.isAcceptableOrUnknown(
              data['total_study_minutes']!, _totalStudyMinutesMeta));
    }
    if (data.containsKey('quiz_attempts')) {
      context.handle(
          _quizAttemptsMeta,
          quizAttempts.isAcceptableOrUnknown(
              data['quiz_attempts']!, _quizAttemptsMeta));
    }
    if (data.containsKey('average_quiz_score')) {
      context.handle(
          _averageQuizScoreMeta,
          averageQuizScore.isAcceptableOrUnknown(
              data['average_quiz_score']!, _averageQuizScoreMeta));
    }
    if (data.containsKey('flashcard_count')) {
      context.handle(
          _flashcardCountMeta,
          flashcardCount.isAcceptableOrUnknown(
              data['flashcard_count']!, _flashcardCountMeta));
    }
    if (data.containsKey('chat_message_count')) {
      context.handle(
          _chatMessageCountMeta,
          chatMessageCount.isAcceptableOrUnknown(
              data['chat_message_count']!, _chatMessageCountMeta));
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
          _lastStudiedAtMeta,
          lastStudiedAt.isAcceptableOrUnknown(
              data['last_studied_at']!, _lastStudiedAtMeta));
    }
    if (data.containsKey('next_revision_due')) {
      context.handle(
          _nextRevisionDueMeta,
          nextRevisionDue.isAcceptableOrUnknown(
              data['next_revision_due']!, _nextRevisionDueMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Topic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Topic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      masteryScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mastery_score'])!,
      weaknessFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weakness_flag'])!,
      isAIProcessed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_a_i_processed'])!,
      conceptTagsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}concept_tags_json'])!,
      learningObjectivesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}learning_objectives_json'])!,
      totalStudyMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}total_study_minutes'])!,
      quizAttempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quiz_attempts'])!,
      averageQuizScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_quiz_score'])!,
      flashcardCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flashcard_count'])!,
      chatMessageCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}chat_message_count'])!,
      lastStudiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_studied_at']),
      nextRevisionDue: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_revision_due']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $TopicsTable createAlias(String alias) {
    return $TopicsTable(attachedDatabase, alias);
  }
}

class Topic extends DataClass implements Insertable<Topic> {
  final String id;
  final String unitId;
  final String subjectId;
  final String userId;
  final String title;
  final String? description;
  final String status;
  final double masteryScore;
  final int weaknessFlag;
  final bool isAIProcessed;
  final String conceptTagsJson;
  final String learningObjectivesJson;
  final int totalStudyMinutes;
  final int quizAttempts;
  final double averageQuizScore;
  final int flashcardCount;
  final int chatMessageCount;
  final DateTime? lastStudiedAt;
  final DateTime? nextRevisionDue;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const Topic(
      {required this.id,
      required this.unitId,
      required this.subjectId,
      required this.userId,
      required this.title,
      this.description,
      required this.status,
      required this.masteryScore,
      required this.weaknessFlag,
      required this.isAIProcessed,
      required this.conceptTagsJson,
      required this.learningObjectivesJson,
      required this.totalStudyMinutes,
      required this.quizAttempts,
      required this.averageQuizScore,
      required this.flashcardCount,
      required this.chatMessageCount,
      this.lastStudiedAt,
      this.nextRevisionDue,
      required this.sortOrder,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['unit_id'] = Variable<String>(unitId);
    map['subject_id'] = Variable<String>(subjectId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    map['mastery_score'] = Variable<double>(masteryScore);
    map['weakness_flag'] = Variable<int>(weaknessFlag);
    map['is_a_i_processed'] = Variable<bool>(isAIProcessed);
    map['concept_tags_json'] = Variable<String>(conceptTagsJson);
    map['learning_objectives_json'] = Variable<String>(learningObjectivesJson);
    map['total_study_minutes'] = Variable<int>(totalStudyMinutes);
    map['quiz_attempts'] = Variable<int>(quizAttempts);
    map['average_quiz_score'] = Variable<double>(averageQuizScore);
    map['flashcard_count'] = Variable<int>(flashcardCount);
    map['chat_message_count'] = Variable<int>(chatMessageCount);
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt);
    }
    if (!nullToAbsent || nextRevisionDue != null) {
      map['next_revision_due'] = Variable<DateTime>(nextRevisionDue);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      id: Value(id),
      unitId: Value(unitId),
      subjectId: Value(subjectId),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      masteryScore: Value(masteryScore),
      weaknessFlag: Value(weaknessFlag),
      isAIProcessed: Value(isAIProcessed),
      conceptTagsJson: Value(conceptTagsJson),
      learningObjectivesJson: Value(learningObjectivesJson),
      totalStudyMinutes: Value(totalStudyMinutes),
      quizAttempts: Value(quizAttempts),
      averageQuizScore: Value(averageQuizScore),
      flashcardCount: Value(flashcardCount),
      chatMessageCount: Value(chatMessageCount),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      nextRevisionDue: nextRevisionDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRevisionDue),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Topic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Topic(
      id: serializer.fromJson<String>(json['id']),
      unitId: serializer.fromJson<String>(json['unitId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      masteryScore: serializer.fromJson<double>(json['masteryScore']),
      weaknessFlag: serializer.fromJson<int>(json['weaknessFlag']),
      isAIProcessed: serializer.fromJson<bool>(json['isAIProcessed']),
      conceptTagsJson: serializer.fromJson<String>(json['conceptTagsJson']),
      learningObjectivesJson:
          serializer.fromJson<String>(json['learningObjectivesJson']),
      totalStudyMinutes: serializer.fromJson<int>(json['totalStudyMinutes']),
      quizAttempts: serializer.fromJson<int>(json['quizAttempts']),
      averageQuizScore: serializer.fromJson<double>(json['averageQuizScore']),
      flashcardCount: serializer.fromJson<int>(json['flashcardCount']),
      chatMessageCount: serializer.fromJson<int>(json['chatMessageCount']),
      lastStudiedAt: serializer.fromJson<DateTime?>(json['lastStudiedAt']),
      nextRevisionDue: serializer.fromJson<DateTime?>(json['nextRevisionDue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'unitId': serializer.toJson<String>(unitId),
      'subjectId': serializer.toJson<String>(subjectId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'masteryScore': serializer.toJson<double>(masteryScore),
      'weaknessFlag': serializer.toJson<int>(weaknessFlag),
      'isAIProcessed': serializer.toJson<bool>(isAIProcessed),
      'conceptTagsJson': serializer.toJson<String>(conceptTagsJson),
      'learningObjectivesJson':
          serializer.toJson<String>(learningObjectivesJson),
      'totalStudyMinutes': serializer.toJson<int>(totalStudyMinutes),
      'quizAttempts': serializer.toJson<int>(quizAttempts),
      'averageQuizScore': serializer.toJson<double>(averageQuizScore),
      'flashcardCount': serializer.toJson<int>(flashcardCount),
      'chatMessageCount': serializer.toJson<int>(chatMessageCount),
      'lastStudiedAt': serializer.toJson<DateTime?>(lastStudiedAt),
      'nextRevisionDue': serializer.toJson<DateTime?>(nextRevisionDue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Topic copyWith(
          {String? id,
          String? unitId,
          String? subjectId,
          String? userId,
          String? title,
          Value<String?> description = const Value.absent(),
          String? status,
          double? masteryScore,
          int? weaknessFlag,
          bool? isAIProcessed,
          String? conceptTagsJson,
          String? learningObjectivesJson,
          int? totalStudyMinutes,
          int? quizAttempts,
          double? averageQuizScore,
          int? flashcardCount,
          int? chatMessageCount,
          Value<DateTime?> lastStudiedAt = const Value.absent(),
          Value<DateTime?> nextRevisionDue = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      Topic(
        id: id ?? this.id,
        unitId: unitId ?? this.unitId,
        subjectId: subjectId ?? this.subjectId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        masteryScore: masteryScore ?? this.masteryScore,
        weaknessFlag: weaknessFlag ?? this.weaknessFlag,
        isAIProcessed: isAIProcessed ?? this.isAIProcessed,
        conceptTagsJson: conceptTagsJson ?? this.conceptTagsJson,
        learningObjectivesJson:
            learningObjectivesJson ?? this.learningObjectivesJson,
        totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
        quizAttempts: quizAttempts ?? this.quizAttempts,
        averageQuizScore: averageQuizScore ?? this.averageQuizScore,
        flashcardCount: flashcardCount ?? this.flashcardCount,
        chatMessageCount: chatMessageCount ?? this.chatMessageCount,
        lastStudiedAt:
            lastStudiedAt.present ? lastStudiedAt.value : this.lastStudiedAt,
        nextRevisionDue: nextRevisionDue.present
            ? nextRevisionDue.value
            : this.nextRevisionDue,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  Topic copyWithCompanion(TopicsCompanion data) {
    return Topic(
      id: data.id.present ? data.id.value : this.id,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      masteryScore: data.masteryScore.present
          ? data.masteryScore.value
          : this.masteryScore,
      weaknessFlag: data.weaknessFlag.present
          ? data.weaknessFlag.value
          : this.weaknessFlag,
      isAIProcessed: data.isAIProcessed.present
          ? data.isAIProcessed.value
          : this.isAIProcessed,
      conceptTagsJson: data.conceptTagsJson.present
          ? data.conceptTagsJson.value
          : this.conceptTagsJson,
      learningObjectivesJson: data.learningObjectivesJson.present
          ? data.learningObjectivesJson.value
          : this.learningObjectivesJson,
      totalStudyMinutes: data.totalStudyMinutes.present
          ? data.totalStudyMinutes.value
          : this.totalStudyMinutes,
      quizAttempts: data.quizAttempts.present
          ? data.quizAttempts.value
          : this.quizAttempts,
      averageQuizScore: data.averageQuizScore.present
          ? data.averageQuizScore.value
          : this.averageQuizScore,
      flashcardCount: data.flashcardCount.present
          ? data.flashcardCount.value
          : this.flashcardCount,
      chatMessageCount: data.chatMessageCount.present
          ? data.chatMessageCount.value
          : this.chatMessageCount,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      nextRevisionDue: data.nextRevisionDue.present
          ? data.nextRevisionDue.value
          : this.nextRevisionDue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Topic(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('subjectId: $subjectId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('weaknessFlag: $weaknessFlag, ')
          ..write('isAIProcessed: $isAIProcessed, ')
          ..write('conceptTagsJson: $conceptTagsJson, ')
          ..write('learningObjectivesJson: $learningObjectivesJson, ')
          ..write('totalStudyMinutes: $totalStudyMinutes, ')
          ..write('quizAttempts: $quizAttempts, ')
          ..write('averageQuizScore: $averageQuizScore, ')
          ..write('flashcardCount: $flashcardCount, ')
          ..write('chatMessageCount: $chatMessageCount, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('nextRevisionDue: $nextRevisionDue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        unitId,
        subjectId,
        userId,
        title,
        description,
        status,
        masteryScore,
        weaknessFlag,
        isAIProcessed,
        conceptTagsJson,
        learningObjectivesJson,
        totalStudyMinutes,
        quizAttempts,
        averageQuizScore,
        flashcardCount,
        chatMessageCount,
        lastStudiedAt,
        nextRevisionDue,
        sortOrder,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Topic &&
          other.id == this.id &&
          other.unitId == this.unitId &&
          other.subjectId == this.subjectId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.masteryScore == this.masteryScore &&
          other.weaknessFlag == this.weaknessFlag &&
          other.isAIProcessed == this.isAIProcessed &&
          other.conceptTagsJson == this.conceptTagsJson &&
          other.learningObjectivesJson == this.learningObjectivesJson &&
          other.totalStudyMinutes == this.totalStudyMinutes &&
          other.quizAttempts == this.quizAttempts &&
          other.averageQuizScore == this.averageQuizScore &&
          other.flashcardCount == this.flashcardCount &&
          other.chatMessageCount == this.chatMessageCount &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.nextRevisionDue == this.nextRevisionDue &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TopicsCompanion extends UpdateCompanion<Topic> {
  final Value<String> id;
  final Value<String> unitId;
  final Value<String> subjectId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> status;
  final Value<double> masteryScore;
  final Value<int> weaknessFlag;
  final Value<bool> isAIProcessed;
  final Value<String> conceptTagsJson;
  final Value<String> learningObjectivesJson;
  final Value<int> totalStudyMinutes;
  final Value<int> quizAttempts;
  final Value<double> averageQuizScore;
  final Value<int> flashcardCount;
  final Value<int> chatMessageCount;
  final Value<DateTime?> lastStudiedAt;
  final Value<DateTime?> nextRevisionDue;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const TopicsCompanion({
    this.id = const Value.absent(),
    this.unitId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.weaknessFlag = const Value.absent(),
    this.isAIProcessed = const Value.absent(),
    this.conceptTagsJson = const Value.absent(),
    this.learningObjectivesJson = const Value.absent(),
    this.totalStudyMinutes = const Value.absent(),
    this.quizAttempts = const Value.absent(),
    this.averageQuizScore = const Value.absent(),
    this.flashcardCount = const Value.absent(),
    this.chatMessageCount = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.nextRevisionDue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicsCompanion.insert({
    required String id,
    required String unitId,
    required String subjectId,
    required String userId,
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.weaknessFlag = const Value.absent(),
    this.isAIProcessed = const Value.absent(),
    this.conceptTagsJson = const Value.absent(),
    this.learningObjectivesJson = const Value.absent(),
    this.totalStudyMinutes = const Value.absent(),
    this.quizAttempts = const Value.absent(),
    this.averageQuizScore = const Value.absent(),
    this.flashcardCount = const Value.absent(),
    this.chatMessageCount = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.nextRevisionDue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        unitId = Value(unitId),
        subjectId = Value(subjectId),
        userId = Value(userId),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Topic> custom({
    Expression<String>? id,
    Expression<String>? unitId,
    Expression<String>? subjectId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? status,
    Expression<double>? masteryScore,
    Expression<int>? weaknessFlag,
    Expression<bool>? isAIProcessed,
    Expression<String>? conceptTagsJson,
    Expression<String>? learningObjectivesJson,
    Expression<int>? totalStudyMinutes,
    Expression<int>? quizAttempts,
    Expression<double>? averageQuizScore,
    Expression<int>? flashcardCount,
    Expression<int>? chatMessageCount,
    Expression<DateTime>? lastStudiedAt,
    Expression<DateTime>? nextRevisionDue,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitId != null) 'unit_id': unitId,
      if (subjectId != null) 'subject_id': subjectId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (weaknessFlag != null) 'weakness_flag': weaknessFlag,
      if (isAIProcessed != null) 'is_a_i_processed': isAIProcessed,
      if (conceptTagsJson != null) 'concept_tags_json': conceptTagsJson,
      if (learningObjectivesJson != null)
        'learning_objectives_json': learningObjectivesJson,
      if (totalStudyMinutes != null) 'total_study_minutes': totalStudyMinutes,
      if (quizAttempts != null) 'quiz_attempts': quizAttempts,
      if (averageQuizScore != null) 'average_quiz_score': averageQuizScore,
      if (flashcardCount != null) 'flashcard_count': flashcardCount,
      if (chatMessageCount != null) 'chat_message_count': chatMessageCount,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (nextRevisionDue != null) 'next_revision_due': nextRevisionDue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicsCompanion copyWith(
      {Value<String>? id,
      Value<String>? unitId,
      Value<String>? subjectId,
      Value<String>? userId,
      Value<String>? title,
      Value<String?>? description,
      Value<String>? status,
      Value<double>? masteryScore,
      Value<int>? weaknessFlag,
      Value<bool>? isAIProcessed,
      Value<String>? conceptTagsJson,
      Value<String>? learningObjectivesJson,
      Value<int>? totalStudyMinutes,
      Value<int>? quizAttempts,
      Value<double>? averageQuizScore,
      Value<int>? flashcardCount,
      Value<int>? chatMessageCount,
      Value<DateTime?>? lastStudiedAt,
      Value<DateTime?>? nextRevisionDue,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return TopicsCompanion(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      subjectId: subjectId ?? this.subjectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      masteryScore: masteryScore ?? this.masteryScore,
      weaknessFlag: weaknessFlag ?? this.weaknessFlag,
      isAIProcessed: isAIProcessed ?? this.isAIProcessed,
      conceptTagsJson: conceptTagsJson ?? this.conceptTagsJson,
      learningObjectivesJson:
          learningObjectivesJson ?? this.learningObjectivesJson,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      chatMessageCount: chatMessageCount ?? this.chatMessageCount,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      nextRevisionDue: nextRevisionDue ?? this.nextRevisionDue,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<double>(masteryScore.value);
    }
    if (weaknessFlag.present) {
      map['weakness_flag'] = Variable<int>(weaknessFlag.value);
    }
    if (isAIProcessed.present) {
      map['is_a_i_processed'] = Variable<bool>(isAIProcessed.value);
    }
    if (conceptTagsJson.present) {
      map['concept_tags_json'] = Variable<String>(conceptTagsJson.value);
    }
    if (learningObjectivesJson.present) {
      map['learning_objectives_json'] =
          Variable<String>(learningObjectivesJson.value);
    }
    if (totalStudyMinutes.present) {
      map['total_study_minutes'] = Variable<int>(totalStudyMinutes.value);
    }
    if (quizAttempts.present) {
      map['quiz_attempts'] = Variable<int>(quizAttempts.value);
    }
    if (averageQuizScore.present) {
      map['average_quiz_score'] = Variable<double>(averageQuizScore.value);
    }
    if (flashcardCount.present) {
      map['flashcard_count'] = Variable<int>(flashcardCount.value);
    }
    if (chatMessageCount.present) {
      map['chat_message_count'] = Variable<int>(chatMessageCount.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt.value);
    }
    if (nextRevisionDue.present) {
      map['next_revision_due'] = Variable<DateTime>(nextRevisionDue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('TopicsCompanion(')
          ..write('id: $id, ')
          ..write('unitId: $unitId, ')
          ..write('subjectId: $subjectId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('weaknessFlag: $weaknessFlag, ')
          ..write('isAIProcessed: $isAIProcessed, ')
          ..write('conceptTagsJson: $conceptTagsJson, ')
          ..write('learningObjectivesJson: $learningObjectivesJson, ')
          ..write('totalStudyMinutes: $totalStudyMinutes, ')
          ..write('quizAttempts: $quizAttempts, ')
          ..write('averageQuizScore: $averageQuizScore, ')
          ..write('flashcardCount: $flashcardCount, ')
          ..write('chatMessageCount: $chatMessageCount, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('nextRevisionDue: $nextRevisionDue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MicroConceptsTable extends MicroConcepts
    with TableInfo<$MicroConceptsTable, MicroConceptEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MicroConceptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyFormulasJsonMeta =
      const VerificationMeta('keyFormulasJson');
  @override
  late final GeneratedColumn<String> keyFormulasJson = GeneratedColumn<String>(
      'key_formulas_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _masteryScoreMeta =
      const VerificationMeta('masteryScore');
  @override
  late final GeneratedColumn<double> masteryScore = GeneratedColumn<double>(
      'mastery_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _confidenceScoreMeta =
      const VerificationMeta('confidenceScore');
  @override
  late final GeneratedColumn<double> confidenceScore = GeneratedColumn<double>(
      'confidence_score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _stabilityFactorMeta =
      const VerificationMeta('stabilityFactor');
  @override
  late final GeneratedColumn<double> stabilityFactor = GeneratedColumn<double>(
      'stability_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _forgettingProbabilityMeta =
      const VerificationMeta('forgettingProbability');
  @override
  late final GeneratedColumn<double> forgettingProbability =
      GeneratedColumn<double>('forgetting_probability', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _revisionCountMeta =
      const VerificationMeta('revisionCount');
  @override
  late final GeneratedColumn<int> revisionCount = GeneratedColumn<int>(
      'revision_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quizAccuracyMeta =
      const VerificationMeta('quizAccuracy');
  @override
  late final GeneratedColumn<double> quizAccuracy = GeneratedColumn<double>(
      'quiz_accuracy', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _estimatedStudyMinutesMeta =
      const VerificationMeta('estimatedStudyMinutes');
  @override
  late final GeneratedColumn<int> estimatedStudyMinutes = GeneratedColumn<int>(
      'estimated_study_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  static const VerificationMeta _estimatedRevisionMinutesMeta =
      const VerificationMeta('estimatedRevisionMinutes');
  @override
  late final GeneratedColumn<int> estimatedRevisionMinutes =
      GeneratedColumn<int>('estimated_revision_minutes', aliasedName, false,
          type: DriftSqlType.int,
          requiredDuringInsert: false,
          defaultValue: const Constant(5));
  static const VerificationMeta _lastStudiedAtMeta =
      const VerificationMeta('lastStudiedAt');
  @override
  late final GeneratedColumn<DateTime> lastStudiedAt =
      GeneratedColumn<DateTime>('last_studied_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextRevisionDueMeta =
      const VerificationMeta('nextRevisionDue');
  @override
  late final GeneratedColumn<DateTime> nextRevisionDue =
      GeneratedColumn<DateTime>('next_revision_due', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        subjectId,
        name,
        description,
        keyFormulasJson,
        masteryScore,
        confidenceScore,
        stabilityFactor,
        forgettingProbability,
        revisionCount,
        quizAccuracy,
        estimatedStudyMinutes,
        estimatedRevisionMinutes,
        lastStudiedAt,
        nextRevisionDue,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'micro_concepts';
  @override
  VerificationContext validateIntegrity(Insertable<MicroConceptEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('key_formulas_json')) {
      context.handle(
          _keyFormulasJsonMeta,
          keyFormulasJson.isAcceptableOrUnknown(
              data['key_formulas_json']!, _keyFormulasJsonMeta));
    }
    if (data.containsKey('mastery_score')) {
      context.handle(
          _masteryScoreMeta,
          masteryScore.isAcceptableOrUnknown(
              data['mastery_score']!, _masteryScoreMeta));
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
          _confidenceScoreMeta,
          confidenceScore.isAcceptableOrUnknown(
              data['confidence_score']!, _confidenceScoreMeta));
    }
    if (data.containsKey('stability_factor')) {
      context.handle(
          _stabilityFactorMeta,
          stabilityFactor.isAcceptableOrUnknown(
              data['stability_factor']!, _stabilityFactorMeta));
    }
    if (data.containsKey('forgetting_probability')) {
      context.handle(
          _forgettingProbabilityMeta,
          forgettingProbability.isAcceptableOrUnknown(
              data['forgetting_probability']!, _forgettingProbabilityMeta));
    }
    if (data.containsKey('revision_count')) {
      context.handle(
          _revisionCountMeta,
          revisionCount.isAcceptableOrUnknown(
              data['revision_count']!, _revisionCountMeta));
    }
    if (data.containsKey('quiz_accuracy')) {
      context.handle(
          _quizAccuracyMeta,
          quizAccuracy.isAcceptableOrUnknown(
              data['quiz_accuracy']!, _quizAccuracyMeta));
    }
    if (data.containsKey('estimated_study_minutes')) {
      context.handle(
          _estimatedStudyMinutesMeta,
          estimatedStudyMinutes.isAcceptableOrUnknown(
              data['estimated_study_minutes']!, _estimatedStudyMinutesMeta));
    }
    if (data.containsKey('estimated_revision_minutes')) {
      context.handle(
          _estimatedRevisionMinutesMeta,
          estimatedRevisionMinutes.isAcceptableOrUnknown(
              data['estimated_revision_minutes']!,
              _estimatedRevisionMinutesMeta));
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
          _lastStudiedAtMeta,
          lastStudiedAt.isAcceptableOrUnknown(
              data['last_studied_at']!, _lastStudiedAtMeta));
    }
    if (data.containsKey('next_revision_due')) {
      context.handle(
          _nextRevisionDueMeta,
          nextRevisionDue.isAcceptableOrUnknown(
              data['next_revision_due']!, _nextRevisionDueMeta));
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MicroConceptEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MicroConceptEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      keyFormulasJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}key_formulas_json'])!,
      masteryScore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mastery_score'])!,
      confidenceScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}confidence_score'])!,
      stabilityFactor: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}stability_factor'])!,
      forgettingProbability: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}forgetting_probability'])!,
      revisionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}revision_count'])!,
      quizAccuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quiz_accuracy'])!,
      estimatedStudyMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}estimated_study_minutes'])!,
      estimatedRevisionMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estimated_revision_minutes'])!,
      lastStudiedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_studied_at']),
      nextRevisionDue: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_revision_due']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $MicroConceptsTable createAlias(String alias) {
    return $MicroConceptsTable(attachedDatabase, alias);
  }
}

class MicroConceptEntry extends DataClass
    implements Insertable<MicroConceptEntry> {
  final String id;
  final String topicId;
  final String subjectId;
  final String name;
  final String? description;
  final String keyFormulasJson;
  final double masteryScore;
  final double confidenceScore;
  final double stabilityFactor;
  final double forgettingProbability;
  final int revisionCount;
  final double quizAccuracy;
  final int estimatedStudyMinutes;
  final int estimatedRevisionMinutes;
  final DateTime? lastStudiedAt;
  final DateTime? nextRevisionDue;
  final DateTime createdAt;
  final DateTime? updatedAt;
  const MicroConceptEntry(
      {required this.id,
      required this.topicId,
      required this.subjectId,
      required this.name,
      this.description,
      required this.keyFormulasJson,
      required this.masteryScore,
      required this.confidenceScore,
      required this.stabilityFactor,
      required this.forgettingProbability,
      required this.revisionCount,
      required this.quizAccuracy,
      required this.estimatedStudyMinutes,
      required this.estimatedRevisionMinutes,
      this.lastStudiedAt,
      this.nextRevisionDue,
      required this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['subject_id'] = Variable<String>(subjectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['key_formulas_json'] = Variable<String>(keyFormulasJson);
    map['mastery_score'] = Variable<double>(masteryScore);
    map['confidence_score'] = Variable<double>(confidenceScore);
    map['stability_factor'] = Variable<double>(stabilityFactor);
    map['forgetting_probability'] = Variable<double>(forgettingProbability);
    map['revision_count'] = Variable<int>(revisionCount);
    map['quiz_accuracy'] = Variable<double>(quizAccuracy);
    map['estimated_study_minutes'] = Variable<int>(estimatedStudyMinutes);
    map['estimated_revision_minutes'] = Variable<int>(estimatedRevisionMinutes);
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt);
    }
    if (!nullToAbsent || nextRevisionDue != null) {
      map['next_revision_due'] = Variable<DateTime>(nextRevisionDue);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  MicroConceptsCompanion toCompanion(bool nullToAbsent) {
    return MicroConceptsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      subjectId: Value(subjectId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      keyFormulasJson: Value(keyFormulasJson),
      masteryScore: Value(masteryScore),
      confidenceScore: Value(confidenceScore),
      stabilityFactor: Value(stabilityFactor),
      forgettingProbability: Value(forgettingProbability),
      revisionCount: Value(revisionCount),
      quizAccuracy: Value(quizAccuracy),
      estimatedStudyMinutes: Value(estimatedStudyMinutes),
      estimatedRevisionMinutes: Value(estimatedRevisionMinutes),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      nextRevisionDue: nextRevisionDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRevisionDue),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory MicroConceptEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MicroConceptEntry(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      keyFormulasJson: serializer.fromJson<String>(json['keyFormulasJson']),
      masteryScore: serializer.fromJson<double>(json['masteryScore']),
      confidenceScore: serializer.fromJson<double>(json['confidenceScore']),
      stabilityFactor: serializer.fromJson<double>(json['stabilityFactor']),
      forgettingProbability:
          serializer.fromJson<double>(json['forgettingProbability']),
      revisionCount: serializer.fromJson<int>(json['revisionCount']),
      quizAccuracy: serializer.fromJson<double>(json['quizAccuracy']),
      estimatedStudyMinutes:
          serializer.fromJson<int>(json['estimatedStudyMinutes']),
      estimatedRevisionMinutes:
          serializer.fromJson<int>(json['estimatedRevisionMinutes']),
      lastStudiedAt: serializer.fromJson<DateTime?>(json['lastStudiedAt']),
      nextRevisionDue: serializer.fromJson<DateTime?>(json['nextRevisionDue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'subjectId': serializer.toJson<String>(subjectId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'keyFormulasJson': serializer.toJson<String>(keyFormulasJson),
      'masteryScore': serializer.toJson<double>(masteryScore),
      'confidenceScore': serializer.toJson<double>(confidenceScore),
      'stabilityFactor': serializer.toJson<double>(stabilityFactor),
      'forgettingProbability': serializer.toJson<double>(forgettingProbability),
      'revisionCount': serializer.toJson<int>(revisionCount),
      'quizAccuracy': serializer.toJson<double>(quizAccuracy),
      'estimatedStudyMinutes': serializer.toJson<int>(estimatedStudyMinutes),
      'estimatedRevisionMinutes':
          serializer.toJson<int>(estimatedRevisionMinutes),
      'lastStudiedAt': serializer.toJson<DateTime?>(lastStudiedAt),
      'nextRevisionDue': serializer.toJson<DateTime?>(nextRevisionDue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  MicroConceptEntry copyWith(
          {String? id,
          String? topicId,
          String? subjectId,
          String? name,
          Value<String?> description = const Value.absent(),
          String? keyFormulasJson,
          double? masteryScore,
          double? confidenceScore,
          double? stabilityFactor,
          double? forgettingProbability,
          int? revisionCount,
          double? quizAccuracy,
          int? estimatedStudyMinutes,
          int? estimatedRevisionMinutes,
          Value<DateTime?> lastStudiedAt = const Value.absent(),
          Value<DateTime?> nextRevisionDue = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      MicroConceptEntry(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        subjectId: subjectId ?? this.subjectId,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        keyFormulasJson: keyFormulasJson ?? this.keyFormulasJson,
        masteryScore: masteryScore ?? this.masteryScore,
        confidenceScore: confidenceScore ?? this.confidenceScore,
        stabilityFactor: stabilityFactor ?? this.stabilityFactor,
        forgettingProbability:
            forgettingProbability ?? this.forgettingProbability,
        revisionCount: revisionCount ?? this.revisionCount,
        quizAccuracy: quizAccuracy ?? this.quizAccuracy,
        estimatedStudyMinutes:
            estimatedStudyMinutes ?? this.estimatedStudyMinutes,
        estimatedRevisionMinutes:
            estimatedRevisionMinutes ?? this.estimatedRevisionMinutes,
        lastStudiedAt:
            lastStudiedAt.present ? lastStudiedAt.value : this.lastStudiedAt,
        nextRevisionDue: nextRevisionDue.present
            ? nextRevisionDue.value
            : this.nextRevisionDue,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  MicroConceptEntry copyWithCompanion(MicroConceptsCompanion data) {
    return MicroConceptEntry(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      keyFormulasJson: data.keyFormulasJson.present
          ? data.keyFormulasJson.value
          : this.keyFormulasJson,
      masteryScore: data.masteryScore.present
          ? data.masteryScore.value
          : this.masteryScore,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      stabilityFactor: data.stabilityFactor.present
          ? data.stabilityFactor.value
          : this.stabilityFactor,
      forgettingProbability: data.forgettingProbability.present
          ? data.forgettingProbability.value
          : this.forgettingProbability,
      revisionCount: data.revisionCount.present
          ? data.revisionCount.value
          : this.revisionCount,
      quizAccuracy: data.quizAccuracy.present
          ? data.quizAccuracy.value
          : this.quizAccuracy,
      estimatedStudyMinutes: data.estimatedStudyMinutes.present
          ? data.estimatedStudyMinutes.value
          : this.estimatedStudyMinutes,
      estimatedRevisionMinutes: data.estimatedRevisionMinutes.present
          ? data.estimatedRevisionMinutes.value
          : this.estimatedRevisionMinutes,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      nextRevisionDue: data.nextRevisionDue.present
          ? data.nextRevisionDue.value
          : this.nextRevisionDue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MicroConceptEntry(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('keyFormulasJson: $keyFormulasJson, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('stabilityFactor: $stabilityFactor, ')
          ..write('forgettingProbability: $forgettingProbability, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('quizAccuracy: $quizAccuracy, ')
          ..write('estimatedStudyMinutes: $estimatedStudyMinutes, ')
          ..write('estimatedRevisionMinutes: $estimatedRevisionMinutes, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('nextRevisionDue: $nextRevisionDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      topicId,
      subjectId,
      name,
      description,
      keyFormulasJson,
      masteryScore,
      confidenceScore,
      stabilityFactor,
      forgettingProbability,
      revisionCount,
      quizAccuracy,
      estimatedStudyMinutes,
      estimatedRevisionMinutes,
      lastStudiedAt,
      nextRevisionDue,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MicroConceptEntry &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.subjectId == this.subjectId &&
          other.name == this.name &&
          other.description == this.description &&
          other.keyFormulasJson == this.keyFormulasJson &&
          other.masteryScore == this.masteryScore &&
          other.confidenceScore == this.confidenceScore &&
          other.stabilityFactor == this.stabilityFactor &&
          other.forgettingProbability == this.forgettingProbability &&
          other.revisionCount == this.revisionCount &&
          other.quizAccuracy == this.quizAccuracy &&
          other.estimatedStudyMinutes == this.estimatedStudyMinutes &&
          other.estimatedRevisionMinutes == this.estimatedRevisionMinutes &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.nextRevisionDue == this.nextRevisionDue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MicroConceptsCompanion extends UpdateCompanion<MicroConceptEntry> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> subjectId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> keyFormulasJson;
  final Value<double> masteryScore;
  final Value<double> confidenceScore;
  final Value<double> stabilityFactor;
  final Value<double> forgettingProbability;
  final Value<int> revisionCount;
  final Value<double> quizAccuracy;
  final Value<int> estimatedStudyMinutes;
  final Value<int> estimatedRevisionMinutes;
  final Value<DateTime?> lastStudiedAt;
  final Value<DateTime?> nextRevisionDue;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const MicroConceptsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.keyFormulasJson = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.stabilityFactor = const Value.absent(),
    this.forgettingProbability = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.quizAccuracy = const Value.absent(),
    this.estimatedStudyMinutes = const Value.absent(),
    this.estimatedRevisionMinutes = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.nextRevisionDue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MicroConceptsCompanion.insert({
    required String id,
    required String topicId,
    required String subjectId,
    required String name,
    this.description = const Value.absent(),
    this.keyFormulasJson = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.stabilityFactor = const Value.absent(),
    this.forgettingProbability = const Value.absent(),
    this.revisionCount = const Value.absent(),
    this.quizAccuracy = const Value.absent(),
    this.estimatedStudyMinutes = const Value.absent(),
    this.estimatedRevisionMinutes = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.nextRevisionDue = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        topicId = Value(topicId),
        subjectId = Value(subjectId),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<MicroConceptEntry> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? subjectId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? keyFormulasJson,
    Expression<double>? masteryScore,
    Expression<double>? confidenceScore,
    Expression<double>? stabilityFactor,
    Expression<double>? forgettingProbability,
    Expression<int>? revisionCount,
    Expression<double>? quizAccuracy,
    Expression<int>? estimatedStudyMinutes,
    Expression<int>? estimatedRevisionMinutes,
    Expression<DateTime>? lastStudiedAt,
    Expression<DateTime>? nextRevisionDue,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (subjectId != null) 'subject_id': subjectId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (keyFormulasJson != null) 'key_formulas_json': keyFormulasJson,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (stabilityFactor != null) 'stability_factor': stabilityFactor,
      if (forgettingProbability != null)
        'forgetting_probability': forgettingProbability,
      if (revisionCount != null) 'revision_count': revisionCount,
      if (quizAccuracy != null) 'quiz_accuracy': quizAccuracy,
      if (estimatedStudyMinutes != null)
        'estimated_study_minutes': estimatedStudyMinutes,
      if (estimatedRevisionMinutes != null)
        'estimated_revision_minutes': estimatedRevisionMinutes,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (nextRevisionDue != null) 'next_revision_due': nextRevisionDue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MicroConceptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? topicId,
      Value<String>? subjectId,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? keyFormulasJson,
      Value<double>? masteryScore,
      Value<double>? confidenceScore,
      Value<double>? stabilityFactor,
      Value<double>? forgettingProbability,
      Value<int>? revisionCount,
      Value<double>? quizAccuracy,
      Value<int>? estimatedStudyMinutes,
      Value<int>? estimatedRevisionMinutes,
      Value<DateTime?>? lastStudiedAt,
      Value<DateTime?>? nextRevisionDue,
      Value<DateTime>? createdAt,
      Value<DateTime?>? updatedAt,
      Value<int>? rowid}) {
    return MicroConceptsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      description: description ?? this.description,
      keyFormulasJson: keyFormulasJson ?? this.keyFormulasJson,
      masteryScore: masteryScore ?? this.masteryScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      stabilityFactor: stabilityFactor ?? this.stabilityFactor,
      forgettingProbability:
          forgettingProbability ?? this.forgettingProbability,
      revisionCount: revisionCount ?? this.revisionCount,
      quizAccuracy: quizAccuracy ?? this.quizAccuracy,
      estimatedStudyMinutes:
          estimatedStudyMinutes ?? this.estimatedStudyMinutes,
      estimatedRevisionMinutes:
          estimatedRevisionMinutes ?? this.estimatedRevisionMinutes,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      nextRevisionDue: nextRevisionDue ?? this.nextRevisionDue,
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
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (keyFormulasJson.present) {
      map['key_formulas_json'] = Variable<String>(keyFormulasJson.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<double>(masteryScore.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<double>(confidenceScore.value);
    }
    if (stabilityFactor.present) {
      map['stability_factor'] = Variable<double>(stabilityFactor.value);
    }
    if (forgettingProbability.present) {
      map['forgetting_probability'] =
          Variable<double>(forgettingProbability.value);
    }
    if (revisionCount.present) {
      map['revision_count'] = Variable<int>(revisionCount.value);
    }
    if (quizAccuracy.present) {
      map['quiz_accuracy'] = Variable<double>(quizAccuracy.value);
    }
    if (estimatedStudyMinutes.present) {
      map['estimated_study_minutes'] =
          Variable<int>(estimatedStudyMinutes.value);
    }
    if (estimatedRevisionMinutes.present) {
      map['estimated_revision_minutes'] =
          Variable<int>(estimatedRevisionMinutes.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<DateTime>(lastStudiedAt.value);
    }
    if (nextRevisionDue.present) {
      map['next_revision_due'] = Variable<DateTime>(nextRevisionDue.value);
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
    return (StringBuffer('MicroConceptsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('keyFormulasJson: $keyFormulasJson, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('stabilityFactor: $stabilityFactor, ')
          ..write('forgettingProbability: $forgettingProbability, ')
          ..write('revisionCount: $revisionCount, ')
          ..write('quizAccuracy: $quizAccuracy, ')
          ..write('estimatedStudyMinutes: $estimatedStudyMinutes, ')
          ..write('estimatedRevisionMinutes: $estimatedRevisionMinutes, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('nextRevisionDue: $nextRevisionDue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConceptDependenciesTable extends ConceptDependencies
    with TableInfo<$ConceptDependenciesTable, ConceptDependencyEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConceptDependenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceConceptIdMeta =
      const VerificationMeta('sourceConceptId');
  @override
  late final GeneratedColumn<String> sourceConceptId = GeneratedColumn<String>(
      'source_concept_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetConceptIdMeta =
      const VerificationMeta('targetConceptId');
  @override
  late final GeneratedColumn<String> targetConceptId = GeneratedColumn<String>(
      'target_concept_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dependencyTypeMeta =
      const VerificationMeta('dependencyType');
  @override
  late final GeneratedColumn<String> dependencyType = GeneratedColumn<String>(
      'dependency_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('prerequisite'));
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<double> strength = GeneratedColumn<double>(
      'strength', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sourceConceptId,
        targetConceptId,
        dependencyType,
        strength,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'concept_dependencies';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConceptDependencyEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_concept_id')) {
      context.handle(
          _sourceConceptIdMeta,
          sourceConceptId.isAcceptableOrUnknown(
              data['source_concept_id']!, _sourceConceptIdMeta));
    } else if (isInserting) {
      context.missing(_sourceConceptIdMeta);
    }
    if (data.containsKey('target_concept_id')) {
      context.handle(
          _targetConceptIdMeta,
          targetConceptId.isAcceptableOrUnknown(
              data['target_concept_id']!, _targetConceptIdMeta));
    } else if (isInserting) {
      context.missing(_targetConceptIdMeta);
    }
    if (data.containsKey('dependency_type')) {
      context.handle(
          _dependencyTypeMeta,
          dependencyType.isAcceptableOrUnknown(
              data['dependency_type']!, _dependencyTypeMeta));
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
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
  ConceptDependencyEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConceptDependencyEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sourceConceptId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_concept_id'])!,
      targetConceptId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}target_concept_id'])!,
      dependencyType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}dependency_type'])!,
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}strength'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ConceptDependenciesTable createAlias(String alias) {
    return $ConceptDependenciesTable(attachedDatabase, alias);
  }
}

class ConceptDependencyEntry extends DataClass
    implements Insertable<ConceptDependencyEntry> {
  final String id;
  final String sourceConceptId;
  final String targetConceptId;
  final String dependencyType;
  final double strength;
  final DateTime createdAt;
  const ConceptDependencyEntry(
      {required this.id,
      required this.sourceConceptId,
      required this.targetConceptId,
      required this.dependencyType,
      required this.strength,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_concept_id'] = Variable<String>(sourceConceptId);
    map['target_concept_id'] = Variable<String>(targetConceptId);
    map['dependency_type'] = Variable<String>(dependencyType);
    map['strength'] = Variable<double>(strength);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConceptDependenciesCompanion toCompanion(bool nullToAbsent) {
    return ConceptDependenciesCompanion(
      id: Value(id),
      sourceConceptId: Value(sourceConceptId),
      targetConceptId: Value(targetConceptId),
      dependencyType: Value(dependencyType),
      strength: Value(strength),
      createdAt: Value(createdAt),
    );
  }

  factory ConceptDependencyEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConceptDependencyEntry(
      id: serializer.fromJson<String>(json['id']),
      sourceConceptId: serializer.fromJson<String>(json['sourceConceptId']),
      targetConceptId: serializer.fromJson<String>(json['targetConceptId']),
      dependencyType: serializer.fromJson<String>(json['dependencyType']),
      strength: serializer.fromJson<double>(json['strength']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceConceptId': serializer.toJson<String>(sourceConceptId),
      'targetConceptId': serializer.toJson<String>(targetConceptId),
      'dependencyType': serializer.toJson<String>(dependencyType),
      'strength': serializer.toJson<double>(strength),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConceptDependencyEntry copyWith(
          {String? id,
          String? sourceConceptId,
          String? targetConceptId,
          String? dependencyType,
          double? strength,
          DateTime? createdAt}) =>
      ConceptDependencyEntry(
        id: id ?? this.id,
        sourceConceptId: sourceConceptId ?? this.sourceConceptId,
        targetConceptId: targetConceptId ?? this.targetConceptId,
        dependencyType: dependencyType ?? this.dependencyType,
        strength: strength ?? this.strength,
        createdAt: createdAt ?? this.createdAt,
      );
  ConceptDependencyEntry copyWithCompanion(ConceptDependenciesCompanion data) {
    return ConceptDependencyEntry(
      id: data.id.present ? data.id.value : this.id,
      sourceConceptId: data.sourceConceptId.present
          ? data.sourceConceptId.value
          : this.sourceConceptId,
      targetConceptId: data.targetConceptId.present
          ? data.targetConceptId.value
          : this.targetConceptId,
      dependencyType: data.dependencyType.present
          ? data.dependencyType.value
          : this.dependencyType,
      strength: data.strength.present ? data.strength.value : this.strength,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConceptDependencyEntry(')
          ..write('id: $id, ')
          ..write('sourceConceptId: $sourceConceptId, ')
          ..write('targetConceptId: $targetConceptId, ')
          ..write('dependencyType: $dependencyType, ')
          ..write('strength: $strength, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sourceConceptId, targetConceptId,
      dependencyType, strength, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConceptDependencyEntry &&
          other.id == this.id &&
          other.sourceConceptId == this.sourceConceptId &&
          other.targetConceptId == this.targetConceptId &&
          other.dependencyType == this.dependencyType &&
          other.strength == this.strength &&
          other.createdAt == this.createdAt);
}

class ConceptDependenciesCompanion
    extends UpdateCompanion<ConceptDependencyEntry> {
  final Value<String> id;
  final Value<String> sourceConceptId;
  final Value<String> targetConceptId;
  final Value<String> dependencyType;
  final Value<double> strength;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConceptDependenciesCompanion({
    this.id = const Value.absent(),
    this.sourceConceptId = const Value.absent(),
    this.targetConceptId = const Value.absent(),
    this.dependencyType = const Value.absent(),
    this.strength = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConceptDependenciesCompanion.insert({
    required String id,
    required String sourceConceptId,
    required String targetConceptId,
    this.dependencyType = const Value.absent(),
    this.strength = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sourceConceptId = Value(sourceConceptId),
        targetConceptId = Value(targetConceptId),
        createdAt = Value(createdAt);
  static Insertable<ConceptDependencyEntry> custom({
    Expression<String>? id,
    Expression<String>? sourceConceptId,
    Expression<String>? targetConceptId,
    Expression<String>? dependencyType,
    Expression<double>? strength,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceConceptId != null) 'source_concept_id': sourceConceptId,
      if (targetConceptId != null) 'target_concept_id': targetConceptId,
      if (dependencyType != null) 'dependency_type': dependencyType,
      if (strength != null) 'strength': strength,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConceptDependenciesCompanion copyWith(
      {Value<String>? id,
      Value<String>? sourceConceptId,
      Value<String>? targetConceptId,
      Value<String>? dependencyType,
      Value<double>? strength,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ConceptDependenciesCompanion(
      id: id ?? this.id,
      sourceConceptId: sourceConceptId ?? this.sourceConceptId,
      targetConceptId: targetConceptId ?? this.targetConceptId,
      dependencyType: dependencyType ?? this.dependencyType,
      strength: strength ?? this.strength,
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
    if (sourceConceptId.present) {
      map['source_concept_id'] = Variable<String>(sourceConceptId.value);
    }
    if (targetConceptId.present) {
      map['target_concept_id'] = Variable<String>(targetConceptId.value);
    }
    if (dependencyType.present) {
      map['dependency_type'] = Variable<String>(dependencyType.value);
    }
    if (strength.present) {
      map['strength'] = Variable<double>(strength.value);
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
    return (StringBuffer('ConceptDependenciesCompanion(')
          ..write('id: $id, ')
          ..write('sourceConceptId: $sourceConceptId, ')
          ..write('targetConceptId: $targetConceptId, ')
          ..write('dependencyType: $dependencyType, ')
          ..write('strength: $strength, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyDnaEntriesTable extends StudyDnaEntries
    with TableInfo<$StudyDnaEntriesTable, StudyDnaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyDnaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sensoryProfileJsonMeta =
      const VerificationMeta('sensoryProfileJson');
  @override
  late final GeneratedColumn<String> sensoryProfileJson =
      GeneratedColumn<String>('sensory_profile_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pedagogicalProfileJsonMeta =
      const VerificationMeta('pedagogicalProfileJson');
  @override
  late final GeneratedColumn<String> pedagogicalProfileJson =
      GeneratedColumn<String>('pedagogical_profile_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _temporalProfileJsonMeta =
      const VerificationMeta('temporalProfileJson');
  @override
  late final GeneratedColumn<String> temporalProfileJson =
      GeneratedColumn<String>('temporal_profile_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _retentionProfileJsonMeta =
      const VerificationMeta('retentionProfileJson');
  @override
  late final GeneratedColumn<String> retentionProfileJson =
      GeneratedColumn<String>('retention_profile_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        sensoryProfileJson,
        pedagogicalProfileJson,
        temporalProfileJson,
        retentionProfileJson,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_dna_entries';
  @override
  VerificationContext validateIntegrity(Insertable<StudyDnaEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('sensory_profile_json')) {
      context.handle(
          _sensoryProfileJsonMeta,
          sensoryProfileJson.isAcceptableOrUnknown(
              data['sensory_profile_json']!, _sensoryProfileJsonMeta));
    } else if (isInserting) {
      context.missing(_sensoryProfileJsonMeta);
    }
    if (data.containsKey('pedagogical_profile_json')) {
      context.handle(
          _pedagogicalProfileJsonMeta,
          pedagogicalProfileJson.isAcceptableOrUnknown(
              data['pedagogical_profile_json']!, _pedagogicalProfileJsonMeta));
    } else if (isInserting) {
      context.missing(_pedagogicalProfileJsonMeta);
    }
    if (data.containsKey('temporal_profile_json')) {
      context.handle(
          _temporalProfileJsonMeta,
          temporalProfileJson.isAcceptableOrUnknown(
              data['temporal_profile_json']!, _temporalProfileJsonMeta));
    } else if (isInserting) {
      context.missing(_temporalProfileJsonMeta);
    }
    if (data.containsKey('retention_profile_json')) {
      context.handle(
          _retentionProfileJsonMeta,
          retentionProfileJson.isAcceptableOrUnknown(
              data['retention_profile_json']!, _retentionProfileJsonMeta));
    } else if (isInserting) {
      context.missing(_retentionProfileJsonMeta);
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  StudyDnaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyDnaEntry(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      sensoryProfileJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sensory_profile_json'])!,
      pedagogicalProfileJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pedagogical_profile_json'])!,
      temporalProfileJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}temporal_profile_json'])!,
      retentionProfileJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}retention_profile_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StudyDnaEntriesTable createAlias(String alias) {
    return $StudyDnaEntriesTable(attachedDatabase, alias);
  }
}

class StudyDnaEntry extends DataClass implements Insertable<StudyDnaEntry> {
  final String userId;
  final String sensoryProfileJson;
  final String pedagogicalProfileJson;
  final String temporalProfileJson;
  final String retentionProfileJson;
  final DateTime updatedAt;
  const StudyDnaEntry(
      {required this.userId,
      required this.sensoryProfileJson,
      required this.pedagogicalProfileJson,
      required this.temporalProfileJson,
      required this.retentionProfileJson,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['sensory_profile_json'] = Variable<String>(sensoryProfileJson);
    map['pedagogical_profile_json'] = Variable<String>(pedagogicalProfileJson);
    map['temporal_profile_json'] = Variable<String>(temporalProfileJson);
    map['retention_profile_json'] = Variable<String>(retentionProfileJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudyDnaEntriesCompanion toCompanion(bool nullToAbsent) {
    return StudyDnaEntriesCompanion(
      userId: Value(userId),
      sensoryProfileJson: Value(sensoryProfileJson),
      pedagogicalProfileJson: Value(pedagogicalProfileJson),
      temporalProfileJson: Value(temporalProfileJson),
      retentionProfileJson: Value(retentionProfileJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory StudyDnaEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyDnaEntry(
      userId: serializer.fromJson<String>(json['userId']),
      sensoryProfileJson:
          serializer.fromJson<String>(json['sensoryProfileJson']),
      pedagogicalProfileJson:
          serializer.fromJson<String>(json['pedagogicalProfileJson']),
      temporalProfileJson:
          serializer.fromJson<String>(json['temporalProfileJson']),
      retentionProfileJson:
          serializer.fromJson<String>(json['retentionProfileJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'sensoryProfileJson': serializer.toJson<String>(sensoryProfileJson),
      'pedagogicalProfileJson':
          serializer.toJson<String>(pedagogicalProfileJson),
      'temporalProfileJson': serializer.toJson<String>(temporalProfileJson),
      'retentionProfileJson': serializer.toJson<String>(retentionProfileJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StudyDnaEntry copyWith(
          {String? userId,
          String? sensoryProfileJson,
          String? pedagogicalProfileJson,
          String? temporalProfileJson,
          String? retentionProfileJson,
          DateTime? updatedAt}) =>
      StudyDnaEntry(
        userId: userId ?? this.userId,
        sensoryProfileJson: sensoryProfileJson ?? this.sensoryProfileJson,
        pedagogicalProfileJson:
            pedagogicalProfileJson ?? this.pedagogicalProfileJson,
        temporalProfileJson: temporalProfileJson ?? this.temporalProfileJson,
        retentionProfileJson: retentionProfileJson ?? this.retentionProfileJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  StudyDnaEntry copyWithCompanion(StudyDnaEntriesCompanion data) {
    return StudyDnaEntry(
      userId: data.userId.present ? data.userId.value : this.userId,
      sensoryProfileJson: data.sensoryProfileJson.present
          ? data.sensoryProfileJson.value
          : this.sensoryProfileJson,
      pedagogicalProfileJson: data.pedagogicalProfileJson.present
          ? data.pedagogicalProfileJson.value
          : this.pedagogicalProfileJson,
      temporalProfileJson: data.temporalProfileJson.present
          ? data.temporalProfileJson.value
          : this.temporalProfileJson,
      retentionProfileJson: data.retentionProfileJson.present
          ? data.retentionProfileJson.value
          : this.retentionProfileJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyDnaEntry(')
          ..write('userId: $userId, ')
          ..write('sensoryProfileJson: $sensoryProfileJson, ')
          ..write('pedagogicalProfileJson: $pedagogicalProfileJson, ')
          ..write('temporalProfileJson: $temporalProfileJson, ')
          ..write('retentionProfileJson: $retentionProfileJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId,
      sensoryProfileJson,
      pedagogicalProfileJson,
      temporalProfileJson,
      retentionProfileJson,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyDnaEntry &&
          other.userId == this.userId &&
          other.sensoryProfileJson == this.sensoryProfileJson &&
          other.pedagogicalProfileJson == this.pedagogicalProfileJson &&
          other.temporalProfileJson == this.temporalProfileJson &&
          other.retentionProfileJson == this.retentionProfileJson &&
          other.updatedAt == this.updatedAt);
}

class StudyDnaEntriesCompanion extends UpdateCompanion<StudyDnaEntry> {
  final Value<String> userId;
  final Value<String> sensoryProfileJson;
  final Value<String> pedagogicalProfileJson;
  final Value<String> temporalProfileJson;
  final Value<String> retentionProfileJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StudyDnaEntriesCompanion({
    this.userId = const Value.absent(),
    this.sensoryProfileJson = const Value.absent(),
    this.pedagogicalProfileJson = const Value.absent(),
    this.temporalProfileJson = const Value.absent(),
    this.retentionProfileJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyDnaEntriesCompanion.insert({
    required String userId,
    required String sensoryProfileJson,
    required String pedagogicalProfileJson,
    required String temporalProfileJson,
    required String retentionProfileJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        sensoryProfileJson = Value(sensoryProfileJson),
        pedagogicalProfileJson = Value(pedagogicalProfileJson),
        temporalProfileJson = Value(temporalProfileJson),
        retentionProfileJson = Value(retentionProfileJson),
        updatedAt = Value(updatedAt);
  static Insertable<StudyDnaEntry> custom({
    Expression<String>? userId,
    Expression<String>? sensoryProfileJson,
    Expression<String>? pedagogicalProfileJson,
    Expression<String>? temporalProfileJson,
    Expression<String>? retentionProfileJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (sensoryProfileJson != null)
        'sensory_profile_json': sensoryProfileJson,
      if (pedagogicalProfileJson != null)
        'pedagogical_profile_json': pedagogicalProfileJson,
      if (temporalProfileJson != null)
        'temporal_profile_json': temporalProfileJson,
      if (retentionProfileJson != null)
        'retention_profile_json': retentionProfileJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyDnaEntriesCompanion copyWith(
      {Value<String>? userId,
      Value<String>? sensoryProfileJson,
      Value<String>? pedagogicalProfileJson,
      Value<String>? temporalProfileJson,
      Value<String>? retentionProfileJson,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return StudyDnaEntriesCompanion(
      userId: userId ?? this.userId,
      sensoryProfileJson: sensoryProfileJson ?? this.sensoryProfileJson,
      pedagogicalProfileJson:
          pedagogicalProfileJson ?? this.pedagogicalProfileJson,
      temporalProfileJson: temporalProfileJson ?? this.temporalProfileJson,
      retentionProfileJson: retentionProfileJson ?? this.retentionProfileJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sensoryProfileJson.present) {
      map['sensory_profile_json'] = Variable<String>(sensoryProfileJson.value);
    }
    if (pedagogicalProfileJson.present) {
      map['pedagogical_profile_json'] =
          Variable<String>(pedagogicalProfileJson.value);
    }
    if (temporalProfileJson.present) {
      map['temporal_profile_json'] =
          Variable<String>(temporalProfileJson.value);
    }
    if (retentionProfileJson.present) {
      map['retention_profile_json'] =
          Variable<String>(retentionProfileJson.value);
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
    return (StringBuffer('StudyDnaEntriesCompanion(')
          ..write('userId: $userId, ')
          ..write('sensoryProfileJson: $sensoryProfileJson, ')
          ..write('pedagogicalProfileJson: $pedagogicalProfileJson, ')
          ..write('temporalProfileJson: $temporalProfileJson, ')
          ..write('retentionProfileJson: $retentionProfileJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningTimelineEntriesTable extends LearningTimelineEntries
    with TableInfo<$LearningTimelineEntriesTable, TimelineEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningTimelineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conceptIdMeta =
      const VerificationMeta('conceptId');
  @override
  late final GeneratedColumn<String> conceptId = GeneratedColumn<String>(
      'concept_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deltaMasteryMeta =
      const VerificationMeta('deltaMastery');
  @override
  late final GeneratedColumn<double> deltaMastery = GeneratedColumn<double>(
      'delta_mastery', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _currentMasteryMeta =
      const VerificationMeta('currentMastery');
  @override
  late final GeneratedColumn<double> currentMastery = GeneratedColumn<double>(
      'current_mastery', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        conceptId,
        topicId,
        eventType,
        deltaMastery,
        currentMastery,
        title,
        description,
        payloadJson,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_timeline_entries';
  @override
  VerificationContext validateIntegrity(Insertable<TimelineEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('concept_id')) {
      context.handle(_conceptIdMeta,
          conceptId.isAcceptableOrUnknown(data['concept_id']!, _conceptIdMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('delta_mastery')) {
      context.handle(
          _deltaMasteryMeta,
          deltaMastery.isAcceptableOrUnknown(
              data['delta_mastery']!, _deltaMasteryMeta));
    }
    if (data.containsKey('current_mastery')) {
      context.handle(
          _currentMasteryMeta,
          currentMastery.isAcceptableOrUnknown(
              data['current_mastery']!, _currentMasteryMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      conceptId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}concept_id']),
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      deltaMastery: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}delta_mastery'])!,
      currentMastery: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_mastery'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $LearningTimelineEntriesTable createAlias(String alias) {
    return $LearningTimelineEntriesTable(attachedDatabase, alias);
  }
}

class TimelineEntry extends DataClass implements Insertable<TimelineEntry> {
  final String id;
  final String userId;
  final String? conceptId;
  final String? topicId;
  final String eventType;
  final double deltaMastery;
  final double currentMastery;
  final String title;
  final String description;
  final String payloadJson;
  final DateTime timestamp;
  const TimelineEntry(
      {required this.id,
      required this.userId,
      this.conceptId,
      this.topicId,
      required this.eventType,
      required this.deltaMastery,
      required this.currentMastery,
      required this.title,
      required this.description,
      required this.payloadJson,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || conceptId != null) {
      map['concept_id'] = Variable<String>(conceptId);
    }
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    map['event_type'] = Variable<String>(eventType);
    map['delta_mastery'] = Variable<double>(deltaMastery);
    map['current_mastery'] = Variable<double>(currentMastery);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['payload_json'] = Variable<String>(payloadJson);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  LearningTimelineEntriesCompanion toCompanion(bool nullToAbsent) {
    return LearningTimelineEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      conceptId: conceptId == null && nullToAbsent
          ? const Value.absent()
          : Value(conceptId),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      eventType: Value(eventType),
      deltaMastery: Value(deltaMastery),
      currentMastery: Value(currentMastery),
      title: Value(title),
      description: Value(description),
      payloadJson: Value(payloadJson),
      timestamp: Value(timestamp),
    );
  }

  factory TimelineEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      conceptId: serializer.fromJson<String?>(json['conceptId']),
      topicId: serializer.fromJson<String?>(json['topicId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      deltaMastery: serializer.fromJson<double>(json['deltaMastery']),
      currentMastery: serializer.fromJson<double>(json['currentMastery']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'conceptId': serializer.toJson<String?>(conceptId),
      'topicId': serializer.toJson<String?>(topicId),
      'eventType': serializer.toJson<String>(eventType),
      'deltaMastery': serializer.toJson<double>(deltaMastery),
      'currentMastery': serializer.toJson<double>(currentMastery),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TimelineEntry copyWith(
          {String? id,
          String? userId,
          Value<String?> conceptId = const Value.absent(),
          Value<String?> topicId = const Value.absent(),
          String? eventType,
          double? deltaMastery,
          double? currentMastery,
          String? title,
          String? description,
          String? payloadJson,
          DateTime? timestamp}) =>
      TimelineEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        conceptId: conceptId.present ? conceptId.value : this.conceptId,
        topicId: topicId.present ? topicId.value : this.topicId,
        eventType: eventType ?? this.eventType,
        deltaMastery: deltaMastery ?? this.deltaMastery,
        currentMastery: currentMastery ?? this.currentMastery,
        title: title ?? this.title,
        description: description ?? this.description,
        payloadJson: payloadJson ?? this.payloadJson,
        timestamp: timestamp ?? this.timestamp,
      );
  TimelineEntry copyWithCompanion(LearningTimelineEntriesCompanion data) {
    return TimelineEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      conceptId: data.conceptId.present ? data.conceptId.value : this.conceptId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      deltaMastery: data.deltaMastery.present
          ? data.deltaMastery.value
          : this.deltaMastery,
      currentMastery: data.currentMastery.present
          ? data.currentMastery.value
          : this.currentMastery,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('conceptId: $conceptId, ')
          ..write('topicId: $topicId, ')
          ..write('eventType: $eventType, ')
          ..write('deltaMastery: $deltaMastery, ')
          ..write('currentMastery: $currentMastery, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, conceptId, topicId, eventType,
      deltaMastery, currentMastery, title, description, payloadJson, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.conceptId == this.conceptId &&
          other.topicId == this.topicId &&
          other.eventType == this.eventType &&
          other.deltaMastery == this.deltaMastery &&
          other.currentMastery == this.currentMastery &&
          other.title == this.title &&
          other.description == this.description &&
          other.payloadJson == this.payloadJson &&
          other.timestamp == this.timestamp);
}

class LearningTimelineEntriesCompanion extends UpdateCompanion<TimelineEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> conceptId;
  final Value<String?> topicId;
  final Value<String> eventType;
  final Value<double> deltaMastery;
  final Value<double> currentMastery;
  final Value<String> title;
  final Value<String> description;
  final Value<String> payloadJson;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const LearningTimelineEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.conceptId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.deltaMastery = const Value.absent(),
    this.currentMastery = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningTimelineEntriesCompanion.insert({
    required String id,
    required String userId,
    this.conceptId = const Value.absent(),
    this.topicId = const Value.absent(),
    required String eventType,
    this.deltaMastery = const Value.absent(),
    this.currentMastery = const Value.absent(),
    required String title,
    required String description,
    this.payloadJson = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        eventType = Value(eventType),
        title = Value(title),
        description = Value(description),
        timestamp = Value(timestamp);
  static Insertable<TimelineEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? conceptId,
    Expression<String>? topicId,
    Expression<String>? eventType,
    Expression<double>? deltaMastery,
    Expression<double>? currentMastery,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? payloadJson,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (conceptId != null) 'concept_id': conceptId,
      if (topicId != null) 'topic_id': topicId,
      if (eventType != null) 'event_type': eventType,
      if (deltaMastery != null) 'delta_mastery': deltaMastery,
      if (currentMastery != null) 'current_mastery': currentMastery,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningTimelineEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? conceptId,
      Value<String?>? topicId,
      Value<String>? eventType,
      Value<double>? deltaMastery,
      Value<double>? currentMastery,
      Value<String>? title,
      Value<String>? description,
      Value<String>? payloadJson,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return LearningTimelineEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      conceptId: conceptId ?? this.conceptId,
      topicId: topicId ?? this.topicId,
      eventType: eventType ?? this.eventType,
      deltaMastery: deltaMastery ?? this.deltaMastery,
      currentMastery: currentMastery ?? this.currentMastery,
      title: title ?? this.title,
      description: description ?? this.description,
      payloadJson: payloadJson ?? this.payloadJson,
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
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (conceptId.present) {
      map['concept_id'] = Variable<String>(conceptId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (deltaMastery.present) {
      map['delta_mastery'] = Variable<double>(deltaMastery.value);
    }
    if (currentMastery.present) {
      map['current_mastery'] = Variable<double>(currentMastery.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LearningTimelineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('conceptId: $conceptId, ')
          ..write('topicId: $topicId, ')
          ..write('eventType: $eventType, ')
          ..write('deltaMastery: $deltaMastery, ')
          ..write('currentMastery: $currentMastery, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LearningResourcesTable extends LearningResources
    with TableInfo<$LearningResourcesTable, LearningResource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LearningResourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cloudUrlMeta =
      const VerificationMeta('cloudUrl');
  @override
  late final GeneratedColumn<String> cloudUrl = GeneratedColumn<String>(
      'cloud_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _youtubeUrlMeta =
      const VerificationMeta('youtubeUrl');
  @override
  late final GeneratedColumn<String> youtubeUrl = GeneratedColumn<String>(
      'youtube_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _extractedTextMeta =
      const VerificationMeta('extractedText');
  @override
  late final GeneratedColumn<String> extractedText = GeneratedColumn<String>(
      'extracted_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _chunkCountMeta =
      const VerificationMeta('chunkCount');
  @override
  late final GeneratedColumn<int> chunkCount = GeneratedColumn<int>(
      'chunk_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isProcessedMeta =
      const VerificationMeta('isProcessed');
  @override
  late final GeneratedColumn<bool> isProcessed = GeneratedColumn<bool>(
      'is_processed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_processed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _processingStatusMeta =
      const VerificationMeta('processingStatus');
  @override
  late final GeneratedColumn<String> processingStatus = GeneratedColumn<String>(
      'processing_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        userId,
        name,
        type,
        localPath,
        cloudUrl,
        youtubeUrl,
        extractedText,
        pageCount,
        chunkCount,
        isProcessed,
        processingStatus,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'learning_resources';
  @override
  VerificationContext validateIntegrity(Insertable<LearningResource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('cloud_url')) {
      context.handle(_cloudUrlMeta,
          cloudUrl.isAcceptableOrUnknown(data['cloud_url']!, _cloudUrlMeta));
    }
    if (data.containsKey('youtube_url')) {
      context.handle(
          _youtubeUrlMeta,
          youtubeUrl.isAcceptableOrUnknown(
              data['youtube_url']!, _youtubeUrlMeta));
    }
    if (data.containsKey('extracted_text')) {
      context.handle(
          _extractedTextMeta,
          extractedText.isAcceptableOrUnknown(
              data['extracted_text']!, _extractedTextMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    if (data.containsKey('chunk_count')) {
      context.handle(
          _chunkCountMeta,
          chunkCount.isAcceptableOrUnknown(
              data['chunk_count']!, _chunkCountMeta));
    }
    if (data.containsKey('is_processed')) {
      context.handle(
          _isProcessedMeta,
          isProcessed.isAcceptableOrUnknown(
              data['is_processed']!, _isProcessedMeta));
    }
    if (data.containsKey('processing_status')) {
      context.handle(
          _processingStatusMeta,
          processingStatus.isAcceptableOrUnknown(
              data['processing_status']!, _processingStatusMeta));
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
  LearningResource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LearningResource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      cloudUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cloud_url']),
      youtubeUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}youtube_url']),
      extractedText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extracted_text']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count']),
      chunkCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chunk_count'])!,
      isProcessed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_processed'])!,
      processingStatus: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}processing_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LearningResourcesTable createAlias(String alias) {
    return $LearningResourcesTable(attachedDatabase, alias);
  }
}

class LearningResource extends DataClass
    implements Insertable<LearningResource> {
  final String id;
  final String topicId;
  final String userId;
  final String name;
  final String type;
  final String? localPath;
  final String? cloudUrl;
  final String? youtubeUrl;
  final String? extractedText;
  final int? pageCount;
  final int chunkCount;
  final bool isProcessed;
  final String processingStatus;
  final DateTime createdAt;
  const LearningResource(
      {required this.id,
      required this.topicId,
      required this.userId,
      required this.name,
      required this.type,
      this.localPath,
      this.cloudUrl,
      this.youtubeUrl,
      this.extractedText,
      this.pageCount,
      required this.chunkCount,
      required this.isProcessed,
      required this.processingStatus,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    if (!nullToAbsent || cloudUrl != null) {
      map['cloud_url'] = Variable<String>(cloudUrl);
    }
    if (!nullToAbsent || youtubeUrl != null) {
      map['youtube_url'] = Variable<String>(youtubeUrl);
    }
    if (!nullToAbsent || extractedText != null) {
      map['extracted_text'] = Variable<String>(extractedText);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['chunk_count'] = Variable<int>(chunkCount);
    map['is_processed'] = Variable<bool>(isProcessed);
    map['processing_status'] = Variable<String>(processingStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LearningResourcesCompanion toCompanion(bool nullToAbsent) {
    return LearningResourcesCompanion(
      id: Value(id),
      topicId: Value(topicId),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      cloudUrl: cloudUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudUrl),
      youtubeUrl: youtubeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeUrl),
      extractedText: extractedText == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedText),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      chunkCount: Value(chunkCount),
      isProcessed: Value(isProcessed),
      processingStatus: Value(processingStatus),
      createdAt: Value(createdAt),
    );
  }

  factory LearningResource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LearningResource(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      cloudUrl: serializer.fromJson<String?>(json['cloudUrl']),
      youtubeUrl: serializer.fromJson<String?>(json['youtubeUrl']),
      extractedText: serializer.fromJson<String?>(json['extractedText']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      chunkCount: serializer.fromJson<int>(json['chunkCount']),
      isProcessed: serializer.fromJson<bool>(json['isProcessed']),
      processingStatus: serializer.fromJson<String>(json['processingStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String?>(localPath),
      'cloudUrl': serializer.toJson<String?>(cloudUrl),
      'youtubeUrl': serializer.toJson<String?>(youtubeUrl),
      'extractedText': serializer.toJson<String?>(extractedText),
      'pageCount': serializer.toJson<int?>(pageCount),
      'chunkCount': serializer.toJson<int>(chunkCount),
      'isProcessed': serializer.toJson<bool>(isProcessed),
      'processingStatus': serializer.toJson<String>(processingStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LearningResource copyWith(
          {String? id,
          String? topicId,
          String? userId,
          String? name,
          String? type,
          Value<String?> localPath = const Value.absent(),
          Value<String?> cloudUrl = const Value.absent(),
          Value<String?> youtubeUrl = const Value.absent(),
          Value<String?> extractedText = const Value.absent(),
          Value<int?> pageCount = const Value.absent(),
          int? chunkCount,
          bool? isProcessed,
          String? processingStatus,
          DateTime? createdAt}) =>
      LearningResource(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        type: type ?? this.type,
        localPath: localPath.present ? localPath.value : this.localPath,
        cloudUrl: cloudUrl.present ? cloudUrl.value : this.cloudUrl,
        youtubeUrl: youtubeUrl.present ? youtubeUrl.value : this.youtubeUrl,
        extractedText:
            extractedText.present ? extractedText.value : this.extractedText,
        pageCount: pageCount.present ? pageCount.value : this.pageCount,
        chunkCount: chunkCount ?? this.chunkCount,
        isProcessed: isProcessed ?? this.isProcessed,
        processingStatus: processingStatus ?? this.processingStatus,
        createdAt: createdAt ?? this.createdAt,
      );
  LearningResource copyWithCompanion(LearningResourcesCompanion data) {
    return LearningResource(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      cloudUrl: data.cloudUrl.present ? data.cloudUrl.value : this.cloudUrl,
      youtubeUrl:
          data.youtubeUrl.present ? data.youtubeUrl.value : this.youtubeUrl,
      extractedText: data.extractedText.present
          ? data.extractedText.value
          : this.extractedText,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      chunkCount:
          data.chunkCount.present ? data.chunkCount.value : this.chunkCount,
      isProcessed:
          data.isProcessed.present ? data.isProcessed.value : this.isProcessed,
      processingStatus: data.processingStatus.present
          ? data.processingStatus.value
          : this.processingStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LearningResource(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('extractedText: $extractedText, ')
          ..write('pageCount: $pageCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('processingStatus: $processingStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      topicId,
      userId,
      name,
      type,
      localPath,
      cloudUrl,
      youtubeUrl,
      extractedText,
      pageCount,
      chunkCount,
      isProcessed,
      processingStatus,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LearningResource &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.cloudUrl == this.cloudUrl &&
          other.youtubeUrl == this.youtubeUrl &&
          other.extractedText == this.extractedText &&
          other.pageCount == this.pageCount &&
          other.chunkCount == this.chunkCount &&
          other.isProcessed == this.isProcessed &&
          other.processingStatus == this.processingStatus &&
          other.createdAt == this.createdAt);
}

class LearningResourcesCompanion extends UpdateCompanion<LearningResource> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> localPath;
  final Value<String?> cloudUrl;
  final Value<String?> youtubeUrl;
  final Value<String?> extractedText;
  final Value<int?> pageCount;
  final Value<int> chunkCount;
  final Value<bool> isProcessed;
  final Value<String> processingStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LearningResourcesCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.cloudUrl = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.processingStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LearningResourcesCompanion.insert({
    required String id,
    required String topicId,
    required String userId,
    required String name,
    required String type,
    this.localPath = const Value.absent(),
    this.cloudUrl = const Value.absent(),
    this.youtubeUrl = const Value.absent(),
    this.extractedText = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.chunkCount = const Value.absent(),
    this.isProcessed = const Value.absent(),
    this.processingStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        topicId = Value(topicId),
        userId = Value(userId),
        name = Value(name),
        type = Value(type),
        createdAt = Value(createdAt);
  static Insertable<LearningResource> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? cloudUrl,
    Expression<String>? youtubeUrl,
    Expression<String>? extractedText,
    Expression<int>? pageCount,
    Expression<int>? chunkCount,
    Expression<bool>? isProcessed,
    Expression<String>? processingStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (cloudUrl != null) 'cloud_url': cloudUrl,
      if (youtubeUrl != null) 'youtube_url': youtubeUrl,
      if (extractedText != null) 'extracted_text': extractedText,
      if (pageCount != null) 'page_count': pageCount,
      if (chunkCount != null) 'chunk_count': chunkCount,
      if (isProcessed != null) 'is_processed': isProcessed,
      if (processingStatus != null) 'processing_status': processingStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LearningResourcesCompanion copyWith(
      {Value<String>? id,
      Value<String>? topicId,
      Value<String>? userId,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? localPath,
      Value<String?>? cloudUrl,
      Value<String?>? youtubeUrl,
      Value<String?>? extractedText,
      Value<int?>? pageCount,
      Value<int>? chunkCount,
      Value<bool>? isProcessed,
      Value<String>? processingStatus,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LearningResourcesCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      extractedText: extractedText ?? this.extractedText,
      pageCount: pageCount ?? this.pageCount,
      chunkCount: chunkCount ?? this.chunkCount,
      isProcessed: isProcessed ?? this.isProcessed,
      processingStatus: processingStatus ?? this.processingStatus,
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
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (cloudUrl.present) {
      map['cloud_url'] = Variable<String>(cloudUrl.value);
    }
    if (youtubeUrl.present) {
      map['youtube_url'] = Variable<String>(youtubeUrl.value);
    }
    if (extractedText.present) {
      map['extracted_text'] = Variable<String>(extractedText.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (chunkCount.present) {
      map['chunk_count'] = Variable<int>(chunkCount.value);
    }
    if (isProcessed.present) {
      map['is_processed'] = Variable<bool>(isProcessed.value);
    }
    if (processingStatus.present) {
      map['processing_status'] = Variable<String>(processingStatus.value);
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
    return (StringBuffer('LearningResourcesCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('cloudUrl: $cloudUrl, ')
          ..write('youtubeUrl: $youtubeUrl, ')
          ..write('extractedText: $extractedText, ')
          ..write('pageCount: $pageCount, ')
          ..write('chunkCount: $chunkCount, ')
          ..write('isProcessed: $isProcessed, ')
          ..write('processingStatus: $processingStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResourceChunksTable extends ResourceChunks
    with TableInfo<$ResourceChunksTable, ResourceChunk> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResourceChunksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
      'resource_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chunkIndexMeta =
      const VerificationMeta('chunkIndex');
  @override
  late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>(
      'chunk_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tokenCountMeta =
      const VerificationMeta('tokenCount');
  @override
  late final GeneratedColumn<int> tokenCount = GeneratedColumn<int>(
      'token_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _embeddingJsonMeta =
      const VerificationMeta('embeddingJson');
  @override
  late final GeneratedColumn<String> embeddingJson = GeneratedColumn<String>(
      'embedding_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        resourceId,
        topicId,
        content,
        chunkIndex,
        tokenCount,
        embeddingJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resource_chunks';
  @override
  VerificationContext validateIntegrity(Insertable<ResourceChunk> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('chunk_index')) {
      context.handle(
          _chunkIndexMeta,
          chunkIndex.isAcceptableOrUnknown(
              data['chunk_index']!, _chunkIndexMeta));
    } else if (isInserting) {
      context.missing(_chunkIndexMeta);
    }
    if (data.containsKey('token_count')) {
      context.handle(
          _tokenCountMeta,
          tokenCount.isAcceptableOrUnknown(
              data['token_count']!, _tokenCountMeta));
    } else if (isInserting) {
      context.missing(_tokenCountMeta);
    }
    if (data.containsKey('embedding_json')) {
      context.handle(
          _embeddingJsonMeta,
          embeddingJson.isAcceptableOrUnknown(
              data['embedding_json']!, _embeddingJsonMeta));
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
  ResourceChunk map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResourceChunk(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      chunkIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chunk_index'])!,
      tokenCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}token_count'])!,
      embeddingJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}embedding_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ResourceChunksTable createAlias(String alias) {
    return $ResourceChunksTable(attachedDatabase, alias);
  }
}

class ResourceChunk extends DataClass implements Insertable<ResourceChunk> {
  final String id;
  final String resourceId;
  final String topicId;
  final String content;
  final int chunkIndex;
  final int tokenCount;
  final String? embeddingJson;
  final DateTime createdAt;
  const ResourceChunk(
      {required this.id,
      required this.resourceId,
      required this.topicId,
      required this.content,
      required this.chunkIndex,
      required this.tokenCount,
      this.embeddingJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['resource_id'] = Variable<String>(resourceId);
    map['topic_id'] = Variable<String>(topicId);
    map['content'] = Variable<String>(content);
    map['chunk_index'] = Variable<int>(chunkIndex);
    map['token_count'] = Variable<int>(tokenCount);
    if (!nullToAbsent || embeddingJson != null) {
      map['embedding_json'] = Variable<String>(embeddingJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ResourceChunksCompanion toCompanion(bool nullToAbsent) {
    return ResourceChunksCompanion(
      id: Value(id),
      resourceId: Value(resourceId),
      topicId: Value(topicId),
      content: Value(content),
      chunkIndex: Value(chunkIndex),
      tokenCount: Value(tokenCount),
      embeddingJson: embeddingJson == null && nullToAbsent
          ? const Value.absent()
          : Value(embeddingJson),
      createdAt: Value(createdAt),
    );
  }

  factory ResourceChunk.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResourceChunk(
      id: serializer.fromJson<String>(json['id']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      content: serializer.fromJson<String>(json['content']),
      chunkIndex: serializer.fromJson<int>(json['chunkIndex']),
      tokenCount: serializer.fromJson<int>(json['tokenCount']),
      embeddingJson: serializer.fromJson<String?>(json['embeddingJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'resourceId': serializer.toJson<String>(resourceId),
      'topicId': serializer.toJson<String>(topicId),
      'content': serializer.toJson<String>(content),
      'chunkIndex': serializer.toJson<int>(chunkIndex),
      'tokenCount': serializer.toJson<int>(tokenCount),
      'embeddingJson': serializer.toJson<String?>(embeddingJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ResourceChunk copyWith(
          {String? id,
          String? resourceId,
          String? topicId,
          String? content,
          int? chunkIndex,
          int? tokenCount,
          Value<String?> embeddingJson = const Value.absent(),
          DateTime? createdAt}) =>
      ResourceChunk(
        id: id ?? this.id,
        resourceId: resourceId ?? this.resourceId,
        topicId: topicId ?? this.topicId,
        content: content ?? this.content,
        chunkIndex: chunkIndex ?? this.chunkIndex,
        tokenCount: tokenCount ?? this.tokenCount,
        embeddingJson:
            embeddingJson.present ? embeddingJson.value : this.embeddingJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ResourceChunk copyWithCompanion(ResourceChunksCompanion data) {
    return ResourceChunk(
      id: data.id.present ? data.id.value : this.id,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      content: data.content.present ? data.content.value : this.content,
      chunkIndex:
          data.chunkIndex.present ? data.chunkIndex.value : this.chunkIndex,
      tokenCount:
          data.tokenCount.present ? data.tokenCount.value : this.tokenCount,
      embeddingJson: data.embeddingJson.present
          ? data.embeddingJson.value
          : this.embeddingJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResourceChunk(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('topicId: $topicId, ')
          ..write('content: $content, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('embeddingJson: $embeddingJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, resourceId, topicId, content, chunkIndex,
      tokenCount, embeddingJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResourceChunk &&
          other.id == this.id &&
          other.resourceId == this.resourceId &&
          other.topicId == this.topicId &&
          other.content == this.content &&
          other.chunkIndex == this.chunkIndex &&
          other.tokenCount == this.tokenCount &&
          other.embeddingJson == this.embeddingJson &&
          other.createdAt == this.createdAt);
}

class ResourceChunksCompanion extends UpdateCompanion<ResourceChunk> {
  final Value<String> id;
  final Value<String> resourceId;
  final Value<String> topicId;
  final Value<String> content;
  final Value<int> chunkIndex;
  final Value<int> tokenCount;
  final Value<String?> embeddingJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ResourceChunksCompanion({
    this.id = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.content = const Value.absent(),
    this.chunkIndex = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.embeddingJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResourceChunksCompanion.insert({
    required String id,
    required String resourceId,
    required String topicId,
    required String content,
    required int chunkIndex,
    required int tokenCount,
    this.embeddingJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        resourceId = Value(resourceId),
        topicId = Value(topicId),
        content = Value(content),
        chunkIndex = Value(chunkIndex),
        tokenCount = Value(tokenCount),
        createdAt = Value(createdAt);
  static Insertable<ResourceChunk> custom({
    Expression<String>? id,
    Expression<String>? resourceId,
    Expression<String>? topicId,
    Expression<String>? content,
    Expression<int>? chunkIndex,
    Expression<int>? tokenCount,
    Expression<String>? embeddingJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (resourceId != null) 'resource_id': resourceId,
      if (topicId != null) 'topic_id': topicId,
      if (content != null) 'content': content,
      if (chunkIndex != null) 'chunk_index': chunkIndex,
      if (tokenCount != null) 'token_count': tokenCount,
      if (embeddingJson != null) 'embedding_json': embeddingJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResourceChunksCompanion copyWith(
      {Value<String>? id,
      Value<String>? resourceId,
      Value<String>? topicId,
      Value<String>? content,
      Value<int>? chunkIndex,
      Value<int>? tokenCount,
      Value<String?>? embeddingJson,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ResourceChunksCompanion(
      id: id ?? this.id,
      resourceId: resourceId ?? this.resourceId,
      topicId: topicId ?? this.topicId,
      content: content ?? this.content,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      tokenCount: tokenCount ?? this.tokenCount,
      embeddingJson: embeddingJson ?? this.embeddingJson,
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
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (chunkIndex.present) {
      map['chunk_index'] = Variable<int>(chunkIndex.value);
    }
    if (tokenCount.present) {
      map['token_count'] = Variable<int>(tokenCount.value);
    }
    if (embeddingJson.present) {
      map['embedding_json'] = Variable<String>(embeddingJson.value);
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
    return (StringBuffer('ResourceChunksCompanion(')
          ..write('id: $id, ')
          ..write('resourceId: $resourceId, ')
          ..write('topicId: $topicId, ')
          ..write('content: $content, ')
          ..write('chunkIndex: $chunkIndex, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('embeddingJson: $embeddingJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isAIGeneratedMeta =
      const VerificationMeta('isAIGenerated');
  @override
  late final GeneratedColumn<bool> isAIGenerated = GeneratedColumn<bool>(
      'is_a_i_generated', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_a_i_generated" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _repetitionsMeta =
      const VerificationMeta('repetitions');
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
      'repetitions', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nextReviewDueMeta =
      const VerificationMeta('nextReviewDue');
  @override
  late final GeneratedColumn<DateTime> nextReviewDue =
      GeneratedColumn<DateTime>('next_review_due', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastReviewedAtMeta =
      const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt =
      GeneratedColumn<DateTime>('last_reviewed_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        userId,
        front,
        back,
        hint,
        isAIGenerated,
        repetitions,
        easeFactor,
        intervalDays,
        nextReviewDue,
        lastReviewedAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(Insertable<Flashcard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('is_a_i_generated')) {
      context.handle(
          _isAIGeneratedMeta,
          isAIGenerated.isAcceptableOrUnknown(
              data['is_a_i_generated']!, _isAIGeneratedMeta));
    }
    if (data.containsKey('repetitions')) {
      context.handle(
          _repetitionsMeta,
          repetitions.isAcceptableOrUnknown(
              data['repetitions']!, _repetitionsMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    }
    if (data.containsKey('next_review_due')) {
      context.handle(
          _nextReviewDueMeta,
          nextReviewDue.isAcceptableOrUnknown(
              data['next_review_due']!, _nextReviewDueMeta));
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
          _lastReviewedAtMeta,
          lastReviewedAt.isAcceptableOrUnknown(
              data['last_reviewed_at']!, _lastReviewedAtMeta));
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
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      isAIGenerated: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_a_i_generated'])!,
      repetitions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}repetitions'])!,
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days'])!,
      nextReviewDue: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_review_due']),
      lastReviewedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final String id;
  final String topicId;
  final String userId;
  final String front;
  final String back;
  final String? hint;
  final bool isAIGenerated;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final DateTime? nextReviewDue;
  final DateTime? lastReviewedAt;
  final DateTime createdAt;
  const Flashcard(
      {required this.id,
      required this.topicId,
      required this.userId,
      required this.front,
      required this.back,
      this.hint,
      required this.isAIGenerated,
      required this.repetitions,
      required this.easeFactor,
      required this.intervalDays,
      this.nextReviewDue,
      this.lastReviewedAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['user_id'] = Variable<String>(userId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['is_a_i_generated'] = Variable<bool>(isAIGenerated);
    map['repetitions'] = Variable<int>(repetitions);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || nextReviewDue != null) {
      map['next_review_due'] = Variable<DateTime>(nextReviewDue);
    }
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      userId: Value(userId),
      front: Value(front),
      back: Value(back),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      isAIGenerated: Value(isAIGenerated),
      repetitions: Value(repetitions),
      easeFactor: Value(easeFactor),
      intervalDays: Value(intervalDays),
      nextReviewDue: nextReviewDue == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReviewDue),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      createdAt: Value(createdAt),
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      userId: serializer.fromJson<String>(json['userId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      hint: serializer.fromJson<String?>(json['hint']),
      isAIGenerated: serializer.fromJson<bool>(json['isAIGenerated']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      nextReviewDue: serializer.fromJson<DateTime?>(json['nextReviewDue']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'userId': serializer.toJson<String>(userId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'hint': serializer.toJson<String?>(hint),
      'isAIGenerated': serializer.toJson<bool>(isAIGenerated),
      'repetitions': serializer.toJson<int>(repetitions),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'nextReviewDue': serializer.toJson<DateTime?>(nextReviewDue),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Flashcard copyWith(
          {String? id,
          String? topicId,
          String? userId,
          String? front,
          String? back,
          Value<String?> hint = const Value.absent(),
          bool? isAIGenerated,
          int? repetitions,
          double? easeFactor,
          int? intervalDays,
          Value<DateTime?> nextReviewDue = const Value.absent(),
          Value<DateTime?> lastReviewedAt = const Value.absent(),
          DateTime? createdAt}) =>
      Flashcard(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        userId: userId ?? this.userId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint.present ? hint.value : this.hint,
        isAIGenerated: isAIGenerated ?? this.isAIGenerated,
        repetitions: repetitions ?? this.repetitions,
        easeFactor: easeFactor ?? this.easeFactor,
        intervalDays: intervalDays ?? this.intervalDays,
        nextReviewDue:
            nextReviewDue.present ? nextReviewDue.value : this.nextReviewDue,
        lastReviewedAt:
            lastReviewedAt.present ? lastReviewedAt.value : this.lastReviewedAt,
        createdAt: createdAt ?? this.createdAt,
      );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      userId: data.userId.present ? data.userId.value : this.userId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      hint: data.hint.present ? data.hint.value : this.hint,
      isAIGenerated: data.isAIGenerated.present
          ? data.isAIGenerated.value
          : this.isAIGenerated,
      repetitions:
          data.repetitions.present ? data.repetitions.value : this.repetitions,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      nextReviewDue: data.nextReviewDue.present
          ? data.nextReviewDue.value
          : this.nextReviewDue,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('isAIGenerated: $isAIGenerated, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewDue: $nextReviewDue, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      topicId,
      userId,
      front,
      back,
      hint,
      isAIGenerated,
      repetitions,
      easeFactor,
      intervalDays,
      nextReviewDue,
      lastReviewedAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.userId == this.userId &&
          other.front == this.front &&
          other.back == this.back &&
          other.hint == this.hint &&
          other.isAIGenerated == this.isAIGenerated &&
          other.repetitions == this.repetitions &&
          other.easeFactor == this.easeFactor &&
          other.intervalDays == this.intervalDays &&
          other.nextReviewDue == this.nextReviewDue &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.createdAt == this.createdAt);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> userId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> hint;
  final Value<bool> isAIGenerated;
  final Value<int> repetitions;
  final Value<double> easeFactor;
  final Value<int> intervalDays;
  final Value<DateTime?> nextReviewDue;
  final Value<DateTime?> lastReviewedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.userId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.hint = const Value.absent(),
    this.isAIGenerated = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReviewDue = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    required String id,
    required String topicId,
    required String userId,
    required String front,
    required String back,
    this.hint = const Value.absent(),
    this.isAIGenerated = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReviewDue = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        topicId = Value(topicId),
        userId = Value(userId),
        front = Value(front),
        back = Value(back),
        createdAt = Value(createdAt);
  static Insertable<Flashcard> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? userId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? hint,
    Expression<bool>? isAIGenerated,
    Expression<int>? repetitions,
    Expression<double>? easeFactor,
    Expression<int>? intervalDays,
    Expression<DateTime>? nextReviewDue,
    Expression<DateTime>? lastReviewedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (userId != null) 'user_id': userId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (hint != null) 'hint': hint,
      if (isAIGenerated != null) 'is_a_i_generated': isAIGenerated,
      if (repetitions != null) 'repetitions': repetitions,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (nextReviewDue != null) 'next_review_due': nextReviewDue,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? topicId,
      Value<String>? userId,
      Value<String>? front,
      Value<String>? back,
      Value<String?>? hint,
      Value<bool>? isAIGenerated,
      Value<int>? repetitions,
      Value<double>? easeFactor,
      Value<int>? intervalDays,
      Value<DateTime?>? nextReviewDue,
      Value<DateTime?>? lastReviewedAt,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      userId: userId ?? this.userId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDue: nextReviewDue ?? this.nextReviewDue,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
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
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (isAIGenerated.present) {
      map['is_a_i_generated'] = Variable<bool>(isAIGenerated.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (nextReviewDue.present) {
      map['next_review_due'] = Variable<DateTime>(nextReviewDue.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
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
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('isAIGenerated: $isAIGenerated, ')
          ..write('repetitions: $repetitions, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReviewDue: $nextReviewDue, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizzesTable extends Quizzes with TableInfo<$QuizzesTable, Quizze> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizzesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('mixed'));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _questionCountMeta =
      const VerificationMeta('questionCount');
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
      'question_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, topicId, userId, title, type, difficulty, questionCount, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quizzes';
  @override
  VerificationContext validateIntegrity(Insertable<Quizze> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('question_count')) {
      context.handle(
          _questionCountMeta,
          questionCount.isAcceptableOrUnknown(
              data['question_count']!, _questionCountMeta));
    } else if (isInserting) {
      context.missing(_questionCountMeta);
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
  Quizze map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quizze(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      questionCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuizzesTable createAlias(String alias) {
    return $QuizzesTable(attachedDatabase, alias);
  }
}

class Quizze extends DataClass implements Insertable<Quizze> {
  final String id;
  final String topicId;
  final String userId;
  final String title;
  final String type;
  final String difficulty;
  final int questionCount;
  final DateTime createdAt;
  const Quizze(
      {required this.id,
      required this.topicId,
      required this.userId,
      required this.title,
      required this.type,
      required this.difficulty,
      required this.questionCount,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['difficulty'] = Variable<String>(difficulty);
    map['question_count'] = Variable<int>(questionCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuizzesCompanion toCompanion(bool nullToAbsent) {
    return QuizzesCompanion(
      id: Value(id),
      topicId: Value(topicId),
      userId: Value(userId),
      title: Value(title),
      type: Value(type),
      difficulty: Value(difficulty),
      questionCount: Value(questionCount),
      createdAt: Value(createdAt),
    );
  }

  factory Quizze.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quizze(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'type': serializer.toJson<String>(type),
      'difficulty': serializer.toJson<String>(difficulty),
      'questionCount': serializer.toJson<int>(questionCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Quizze copyWith(
          {String? id,
          String? topicId,
          String? userId,
          String? title,
          String? type,
          String? difficulty,
          int? questionCount,
          DateTime? createdAt}) =>
      Quizze(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        type: type ?? this.type,
        difficulty: difficulty ?? this.difficulty,
        questionCount: questionCount ?? this.questionCount,
        createdAt: createdAt ?? this.createdAt,
      );
  Quizze copyWithCompanion(QuizzesCompanion data) {
    return Quizze(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quizze(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('questionCount: $questionCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, topicId, userId, title, type, difficulty, questionCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quizze &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.type == this.type &&
          other.difficulty == this.difficulty &&
          other.questionCount == this.questionCount &&
          other.createdAt == this.createdAt);
}

class QuizzesCompanion extends UpdateCompanion<Quizze> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> type;
  final Value<String> difficulty;
  final Value<int> questionCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const QuizzesCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizzesCompanion.insert({
    required String id,
    required String topicId,
    required String userId,
    required String title,
    this.type = const Value.absent(),
    this.difficulty = const Value.absent(),
    required int questionCount,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        topicId = Value(topicId),
        userId = Value(userId),
        title = Value(title),
        questionCount = Value(questionCount),
        createdAt = Value(createdAt);
  static Insertable<Quizze> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? type,
    Expression<String>? difficulty,
    Expression<int>? questionCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (difficulty != null) 'difficulty': difficulty,
      if (questionCount != null) 'question_count': questionCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizzesCompanion copyWith(
      {Value<String>? id,
      Value<String>? topicId,
      Value<String>? userId,
      Value<String>? title,
      Value<String>? type,
      Value<String>? difficulty,
      Value<int>? questionCount,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return QuizzesCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
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
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
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
    return (StringBuffer('QuizzesCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('difficulty: $difficulty, ')
          ..write('questionCount: $questionCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizQuestionsTable extends QuizQuestions
    with TableInfo<$QuizQuestionsTable, QuizQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  @override
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
      'quiz_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _correctAnswerMeta =
      const VerificationMeta('correctAnswer');
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
      'correct_answer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        quizId,
        question,
        type,
        optionsJson,
        correctAnswer,
        explanation,
        difficulty,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_questions';
  @override
  VerificationContext validateIntegrity(Insertable<QuizQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(_quizIdMeta,
          quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta));
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
          _correctAnswerMeta,
          correctAnswer.isAcceptableOrUnknown(
              data['correct_answer']!, _correctAnswerMeta));
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      quizId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quiz_id'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      correctAnswer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}correct_answer'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $QuizQuestionsTable createAlias(String alias) {
    return $QuizQuestionsTable(attachedDatabase, alias);
  }
}

class QuizQuestion extends DataClass implements Insertable<QuizQuestion> {
  final String id;
  final String quizId;
  final String question;
  final String type;
  final String optionsJson;
  final String correctAnswer;
  final String? explanation;
  final String difficulty;
  final int sortOrder;
  const QuizQuestion(
      {required this.id,
      required this.quizId,
      required this.question,
      required this.type,
      required this.optionsJson,
      required this.correctAnswer,
      this.explanation,
      required this.difficulty,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['question'] = Variable<String>(question);
    map['type'] = Variable<String>(type);
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_answer'] = Variable<String>(correctAnswer);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['difficulty'] = Variable<String>(difficulty);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuizQuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuizQuestionsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      question: Value(question),
      type: Value(type),
      optionsJson: Value(optionsJson),
      correctAnswer: Value(correctAnswer),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      difficulty: Value(difficulty),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestion(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quizId']),
      question: serializer.fromJson<String>(json['question']),
      type: serializer.fromJson<String>(json['type']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quizId': serializer.toJson<String>(quizId),
      'question': serializer.toJson<String>(question),
      'type': serializer.toJson<String>(type),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'explanation': serializer.toJson<String?>(explanation),
      'difficulty': serializer.toJson<String>(difficulty),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  QuizQuestion copyWith(
          {String? id,
          String? quizId,
          String? question,
          String? type,
          String? optionsJson,
          String? correctAnswer,
          Value<String?> explanation = const Value.absent(),
          String? difficulty,
          int? sortOrder}) =>
      QuizQuestion(
        id: id ?? this.id,
        quizId: quizId ?? this.quizId,
        question: question ?? this.question,
        type: type ?? this.type,
        optionsJson: optionsJson ?? this.optionsJson,
        correctAnswer: correctAnswer ?? this.correctAnswer,
        explanation: explanation.present ? explanation.value : this.explanation,
        difficulty: difficulty ?? this.difficulty,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  QuizQuestion copyWithCompanion(QuizQuestionsCompanion data) {
    return QuizQuestion(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      question: data.question.present ? data.question.value : this.question,
      type: data.type.present ? data.type.value : this.type,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('question: $question, ')
          ..write('type: $type, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, quizId, question, type, optionsJson,
      correctAnswer, explanation, difficulty, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestion &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.question == this.question &&
          other.type == this.type &&
          other.optionsJson == this.optionsJson &&
          other.correctAnswer == this.correctAnswer &&
          other.explanation == this.explanation &&
          other.difficulty == this.difficulty &&
          other.sortOrder == this.sortOrder);
}

class QuizQuestionsCompanion extends UpdateCompanion<QuizQuestion> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<String> question;
  final Value<String> type;
  final Value<String> optionsJson;
  final Value<String> correctAnswer;
  final Value<String?> explanation;
  final Value<String> difficulty;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const QuizQuestionsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.question = const Value.absent(),
    this.type = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizQuestionsCompanion.insert({
    required String id,
    required String quizId,
    required String question,
    required String type,
    this.optionsJson = const Value.absent(),
    required String correctAnswer,
    this.explanation = const Value.absent(),
    this.difficulty = const Value.absent(),
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        quizId = Value(quizId),
        question = Value(question),
        type = Value(type),
        correctAnswer = Value(correctAnswer),
        sortOrder = Value(sortOrder);
  static Insertable<QuizQuestion> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<String>? question,
    Expression<String>? type,
    Expression<String>? optionsJson,
    Expression<String>? correctAnswer,
    Expression<String>? explanation,
    Expression<String>? difficulty,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (question != null) 'question': question,
      if (type != null) 'type': type,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      if (difficulty != null) 'difficulty': difficulty,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? quizId,
      Value<String>? question,
      Value<String>? type,
      Value<String>? optionsJson,
      Value<String>? correctAnswer,
      Value<String?>? explanation,
      Value<String>? difficulty,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return QuizQuestionsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      question: question ?? this.question,
      type: type ?? this.type,
      optionsJson: optionsJson ?? this.optionsJson,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('question: $question, ')
          ..write('type: $type, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptsTable extends QuizAttempts
    with TableInfo<$QuizAttemptsTable, QuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  @override
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
      'quiz_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _correctCountMeta =
      const VerificationMeta('correctCount');
  @override
  late final GeneratedColumn<int> correctCount = GeneratedColumn<int>(
      'correct_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalQuestionsMeta =
      const VerificationMeta('totalQuestions');
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
      'total_questions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _answersJsonMeta =
      const VerificationMeta('answersJson');
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
      'answers_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        quizId,
        userId,
        score,
        correctCount,
        totalQuestions,
        durationSeconds,
        answersJson,
        completedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempts';
  @override
  VerificationContext validateIntegrity(Insertable<QuizAttempt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(_quizIdMeta,
          quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta));
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_count')) {
      context.handle(
          _correctCountMeta,
          correctCount.isAcceptableOrUnknown(
              data['correct_count']!, _correctCountMeta));
    } else if (isInserting) {
      context.missing(_correctCountMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
          _totalQuestionsMeta,
          totalQuestions.isAcceptableOrUnknown(
              data['total_questions']!, _totalQuestionsMeta));
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
          _answersJsonMeta,
          answersJson.isAcceptableOrUnknown(
              data['answers_json']!, _answersJsonMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttempt(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      quizId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quiz_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      correctCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_count'])!,
      totalQuestions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_questions'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      answersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answers_json'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
    );
  }

  @override
  $QuizAttemptsTable createAlias(String alias) {
    return $QuizAttemptsTable(attachedDatabase, alias);
  }
}

class QuizAttempt extends DataClass implements Insertable<QuizAttempt> {
  final String id;
  final String quizId;
  final String userId;
  final double score;
  final int correctCount;
  final int totalQuestions;
  final int durationSeconds;
  final String answersJson;
  final DateTime completedAt;
  const QuizAttempt(
      {required this.id,
      required this.quizId,
      required this.userId,
      required this.score,
      required this.correctCount,
      required this.totalQuestions,
      required this.durationSeconds,
      required this.answersJson,
      required this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['user_id'] = Variable<String>(userId);
    map['score'] = Variable<double>(score);
    map['correct_count'] = Variable<int>(correctCount);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['answers_json'] = Variable<String>(answersJson);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  QuizAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      userId: Value(userId),
      score: Value(score),
      correctCount: Value(correctCount),
      totalQuestions: Value(totalQuestions),
      durationSeconds: Value(durationSeconds),
      answersJson: Value(answersJson),
      completedAt: Value(completedAt),
    );
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttempt(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quizId']),
      userId: serializer.fromJson<String>(json['userId']),
      score: serializer.fromJson<double>(json['score']),
      correctCount: serializer.fromJson<int>(json['correctCount']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quizId': serializer.toJson<String>(quizId),
      'userId': serializer.toJson<String>(userId),
      'score': serializer.toJson<double>(score),
      'correctCount': serializer.toJson<int>(correctCount),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'answersJson': serializer.toJson<String>(answersJson),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  QuizAttempt copyWith(
          {String? id,
          String? quizId,
          String? userId,
          double? score,
          int? correctCount,
          int? totalQuestions,
          int? durationSeconds,
          String? answersJson,
          DateTime? completedAt}) =>
      QuizAttempt(
        id: id ?? this.id,
        quizId: quizId ?? this.quizId,
        userId: userId ?? this.userId,
        score: score ?? this.score,
        correctCount: correctCount ?? this.correctCount,
        totalQuestions: totalQuestions ?? this.totalQuestions,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        answersJson: answersJson ?? this.answersJson,
        completedAt: completedAt ?? this.completedAt,
      );
  QuizAttempt copyWithCompanion(QuizAttemptsCompanion data) {
    return QuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      userId: data.userId.present ? data.userId.value : this.userId,
      score: data.score.present ? data.score.value : this.score,
      correctCount: data.correctCount.present
          ? data.correctCount.value
          : this.correctCount,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      answersJson:
          data.answersJson.present ? data.answersJson.value : this.answersJson,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttempt(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('userId: $userId, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, quizId, userId, score, correctCount,
      totalQuestions, durationSeconds, answersJson, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttempt &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.userId == this.userId &&
          other.score == this.score &&
          other.correctCount == this.correctCount &&
          other.totalQuestions == this.totalQuestions &&
          other.durationSeconds == this.durationSeconds &&
          other.answersJson == this.answersJson &&
          other.completedAt == this.completedAt);
}

class QuizAttemptsCompanion extends UpdateCompanion<QuizAttempt> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<String> userId;
  final Value<double> score;
  final Value<int> correctCount;
  final Value<int> totalQuestions;
  final Value<int> durationSeconds;
  final Value<String> answersJson;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const QuizAttemptsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.userId = const Value.absent(),
    this.score = const Value.absent(),
    this.correctCount = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizAttemptsCompanion.insert({
    required String id,
    required String quizId,
    required String userId,
    required double score,
    required int correctCount,
    required int totalQuestions,
    required int durationSeconds,
    this.answersJson = const Value.absent(),
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        quizId = Value(quizId),
        userId = Value(userId),
        score = Value(score),
        correctCount = Value(correctCount),
        totalQuestions = Value(totalQuestions),
        durationSeconds = Value(durationSeconds),
        completedAt = Value(completedAt);
  static Insertable<QuizAttempt> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<String>? userId,
    Expression<double>? score,
    Expression<int>? correctCount,
    Expression<int>? totalQuestions,
    Expression<int>? durationSeconds,
    Expression<String>? answersJson,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (userId != null) 'user_id': userId,
      if (score != null) 'score': score,
      if (correctCount != null) 'correct_count': correctCount,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (answersJson != null) 'answers_json': answersJson,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizAttemptsCompanion copyWith(
      {Value<String>? id,
      Value<String>? quizId,
      Value<String>? userId,
      Value<double>? score,
      Value<int>? correctCount,
      Value<int>? totalQuestions,
      Value<int>? durationSeconds,
      Value<String>? answersJson,
      Value<DateTime>? completedAt,
      Value<int>? rowid}) {
    return QuizAttemptsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      correctCount: correctCount ?? this.correctCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      answersJson: answersJson ?? this.answersJson,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (correctCount.present) {
      map['correct_count'] = Variable<int>(correctCount.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('userId: $userId, ')
          ..write('score: $score, ')
          ..write('correctCount: $correctCount, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contextTypeMeta =
      const VerificationMeta('contextType');
  @override
  late final GeneratedColumn<String> contextType = GeneratedColumn<String>(
      'context_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('global'));
  static const VerificationMeta _contextIdMeta =
      const VerificationMeta('contextId');
  @override
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
      'context_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _messageCountMeta =
      const VerificationMeta('messageCount');
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
      'message_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastMessageAtMeta =
      const VerificationMeta('lastMessageAt');
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>('last_message_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        contextType,
        contextId,
        messageCount,
        createdAt,
        lastMessageAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('context_type')) {
      context.handle(
          _contextTypeMeta,
          contextType.isAcceptableOrUnknown(
              data['context_type']!, _contextTypeMeta));
    }
    if (data.containsKey('context_id')) {
      context.handle(_contextIdMeta,
          contextId.isAcceptableOrUnknown(data['context_id']!, _contextIdMeta));
    }
    if (data.containsKey('message_count')) {
      context.handle(
          _messageCountMeta,
          messageCount.isAcceptableOrUnknown(
              data['message_count']!, _messageCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
          _lastMessageAtMeta,
          lastMessageAt.isAcceptableOrUnknown(
              data['last_message_at']!, _lastMessageAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      contextType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_type'])!,
      contextId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_id']),
      messageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastMessageAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_at']),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String userId;
  final String title;
  final String contextType;
  final String? contextId;
  final int messageCount;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  const Conversation(
      {required this.id,
      required this.userId,
      required this.title,
      required this.contextType,
      this.contextId,
      required this.messageCount,
      required this.createdAt,
      this.lastMessageAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['context_type'] = Variable<String>(contextType);
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    map['message_count'] = Variable<int>(messageCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      contextType: Value(contextType),
      contextId: contextId == null && nullToAbsent
          ? const Value.absent()
          : Value(contextId),
      messageCount: Value(messageCount),
      createdAt: Value(createdAt),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      contextType: serializer.fromJson<String>(json['contextType']),
      contextId: serializer.fromJson<String?>(json['contextId']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'contextType': serializer.toJson<String>(contextType),
      'contextId': serializer.toJson<String?>(contextId),
      'messageCount': serializer.toJson<int>(messageCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
    };
  }

  Conversation copyWith(
          {String? id,
          String? userId,
          String? title,
          String? contextType,
          Value<String?> contextId = const Value.absent(),
          int? messageCount,
          DateTime? createdAt,
          Value<DateTime?> lastMessageAt = const Value.absent()}) =>
      Conversation(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        contextType: contextType ?? this.contextType,
        contextId: contextId.present ? contextId.value : this.contextId,
        messageCount: messageCount ?? this.messageCount,
        createdAt: createdAt ?? this.createdAt,
        lastMessageAt:
            lastMessageAt.present ? lastMessageAt.value : this.lastMessageAt,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      contextType:
          data.contextType.present ? data.contextType.value : this.contextType,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('messageCount: $messageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMessageAt: $lastMessageAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, title, contextType, contextId,
      messageCount, createdAt, lastMessageAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.contextType == this.contextType &&
          other.contextId == this.contextId &&
          other.messageCount == this.messageCount &&
          other.createdAt == this.createdAt &&
          other.lastMessageAt == this.lastMessageAt);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> contextType;
  final Value<String?> contextId;
  final Value<int> messageCount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastMessageAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.contextType = const Value.absent(),
    this.contextId = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    this.contextType = const Value.absent(),
    this.contextId = const Value.absent(),
    this.messageCount = const Value.absent(),
    required DateTime createdAt,
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? contextType,
    Expression<String>? contextId,
    Expression<int>? messageCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (contextType != null) 'context_type': contextType,
      if (contextId != null) 'context_id': contextId,
      if (messageCount != null) 'message_count': messageCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String>? contextType,
      Value<String?>? contextId,
      Value<int>? messageCount,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastMessageAt,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      contextType: contextType ?? this.contextType,
      contextId: contextId ?? this.contextId,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contextType.present) {
      map['context_type'] = Variable<String>(contextType.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('contextType: $contextType, ')
          ..write('contextId: $contextId, ')
          ..write('messageCount: $messageCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceChunkIdsJsonMeta =
      const VerificationMeta('sourceChunkIdsJson');
  @override
  late final GeneratedColumn<String> sourceChunkIdsJson =
      GeneratedColumn<String>('source_chunk_ids_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _promptTokensMeta =
      const VerificationMeta('promptTokens');
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
      'prompt_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completionTokensMeta =
      const VerificationMeta('completionTokens');
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
      'completion_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _aiProviderMeta =
      const VerificationMeta('aiProvider');
  @override
  late final GeneratedColumn<String> aiProvider = GeneratedColumn<String>(
      'ai_provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiModelMeta =
      const VerificationMeta('aiModel');
  @override
  late final GeneratedColumn<String> aiModel = GeneratedColumn<String>(
      'ai_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        content,
        sourceChunkIdsJson,
        promptTokens,
        completionTokens,
        aiProvider,
        aiModel,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('source_chunk_ids_json')) {
      context.handle(
          _sourceChunkIdsJsonMeta,
          sourceChunkIdsJson.isAcceptableOrUnknown(
              data['source_chunk_ids_json']!, _sourceChunkIdsJsonMeta));
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
          _promptTokensMeta,
          promptTokens.isAcceptableOrUnknown(
              data['prompt_tokens']!, _promptTokensMeta));
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
          _completionTokensMeta,
          completionTokens.isAcceptableOrUnknown(
              data['completion_tokens']!, _completionTokensMeta));
    }
    if (data.containsKey('ai_provider')) {
      context.handle(
          _aiProviderMeta,
          aiProvider.isAcceptableOrUnknown(
              data['ai_provider']!, _aiProviderMeta));
    }
    if (data.containsKey('ai_model')) {
      context.handle(_aiModelMeta,
          aiModel.isAcceptableOrUnknown(data['ai_model']!, _aiModelMeta));
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
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      sourceChunkIdsJson: attachedDatabase.typeMapping.read(DriftSqlType.string,
          data['${effectivePrefix}source_chunk_ids_json'])!,
      promptTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prompt_tokens'])!,
      completionTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completion_tokens'])!,
      aiProvider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_provider']),
      aiModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_model']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final String sourceChunkIdsJson;
  final int promptTokens;
  final int completionTokens;
  final String? aiProvider;
  final String? aiModel;
  final DateTime createdAt;
  const Message(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      required this.sourceChunkIdsJson,
      required this.promptTokens,
      required this.completionTokens,
      this.aiProvider,
      this.aiModel,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['source_chunk_ids_json'] = Variable<String>(sourceChunkIdsJson);
    map['prompt_tokens'] = Variable<int>(promptTokens);
    map['completion_tokens'] = Variable<int>(completionTokens);
    if (!nullToAbsent || aiProvider != null) {
      map['ai_provider'] = Variable<String>(aiProvider);
    }
    if (!nullToAbsent || aiModel != null) {
      map['ai_model'] = Variable<String>(aiModel);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      sourceChunkIdsJson: Value(sourceChunkIdsJson),
      promptTokens: Value(promptTokens),
      completionTokens: Value(completionTokens),
      aiProvider: aiProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(aiProvider),
      aiModel: aiModel == null && nullToAbsent
          ? const Value.absent()
          : Value(aiModel),
      createdAt: Value(createdAt),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      sourceChunkIdsJson:
          serializer.fromJson<String>(json['sourceChunkIdsJson']),
      promptTokens: serializer.fromJson<int>(json['promptTokens']),
      completionTokens: serializer.fromJson<int>(json['completionTokens']),
      aiProvider: serializer.fromJson<String?>(json['aiProvider']),
      aiModel: serializer.fromJson<String?>(json['aiModel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'sourceChunkIdsJson': serializer.toJson<String>(sourceChunkIdsJson),
      'promptTokens': serializer.toJson<int>(promptTokens),
      'completionTokens': serializer.toJson<int>(completionTokens),
      'aiProvider': serializer.toJson<String?>(aiProvider),
      'aiModel': serializer.toJson<String?>(aiModel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Message copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? content,
          String? sourceChunkIdsJson,
          int? promptTokens,
          int? completionTokens,
          Value<String?> aiProvider = const Value.absent(),
          Value<String?> aiModel = const Value.absent(),
          DateTime? createdAt}) =>
      Message(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        sourceChunkIdsJson: sourceChunkIdsJson ?? this.sourceChunkIdsJson,
        promptTokens: promptTokens ?? this.promptTokens,
        completionTokens: completionTokens ?? this.completionTokens,
        aiProvider: aiProvider.present ? aiProvider.value : this.aiProvider,
        aiModel: aiModel.present ? aiModel.value : this.aiModel,
        createdAt: createdAt ?? this.createdAt,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      sourceChunkIdsJson: data.sourceChunkIdsJson.present
          ? data.sourceChunkIdsJson.value
          : this.sourceChunkIdsJson,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
      aiProvider:
          data.aiProvider.present ? data.aiProvider.value : this.aiProvider,
      aiModel: data.aiModel.present ? data.aiModel.value : this.aiModel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('sourceChunkIdsJson: $sourceChunkIdsJson, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('aiProvider: $aiProvider, ')
          ..write('aiModel: $aiModel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      conversationId,
      role,
      content,
      sourceChunkIdsJson,
      promptTokens,
      completionTokens,
      aiProvider,
      aiModel,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.sourceChunkIdsJson == this.sourceChunkIdsJson &&
          other.promptTokens == this.promptTokens &&
          other.completionTokens == this.completionTokens &&
          other.aiProvider == this.aiProvider &&
          other.aiModel == this.aiModel &&
          other.createdAt == this.createdAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> sourceChunkIdsJson;
  final Value<int> promptTokens;
  final Value<int> completionTokens;
  final Value<String?> aiProvider;
  final Value<String?> aiModel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.sourceChunkIdsJson = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.aiProvider = const Value.absent(),
    this.aiModel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.sourceChunkIdsJson = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
    this.aiProvider = const Value.absent(),
    this.aiModel = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? sourceChunkIdsJson,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
    Expression<String>? aiProvider,
    Expression<String>? aiModel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (sourceChunkIdsJson != null)
        'source_chunk_ids_json': sourceChunkIdsJson,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
      if (aiProvider != null) 'ai_provider': aiProvider,
      if (aiModel != null) 'ai_model': aiModel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? role,
      Value<String>? content,
      Value<String>? sourceChunkIdsJson,
      Value<int>? promptTokens,
      Value<int>? completionTokens,
      Value<String?>? aiProvider,
      Value<String?>? aiModel,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      sourceChunkIdsJson: sourceChunkIdsJson ?? this.sourceChunkIdsJson,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
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
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sourceChunkIdsJson.present) {
      map['source_chunk_ids_json'] = Variable<String>(sourceChunkIdsJson.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    if (aiProvider.present) {
      map['ai_provider'] = Variable<String>(aiProvider.value);
    }
    if (aiModel.present) {
      map['ai_model'] = Variable<String>(aiModel.value);
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
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('sourceChunkIdsJson: $sourceChunkIdsJson, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens, ')
          ..write('aiProvider: $aiProvider, ')
          ..write('aiModel: $aiModel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudySessionsTable extends StudySessions
    with TableInfo<$StudySessionsTable, StudySession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudySessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
      'topic_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
      'subject_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
      'session_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMinutesMeta =
      const VerificationMeta('durationMinutes');
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
      'duration_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        topicId,
        subjectId,
        sessionType,
        durationMinutes,
        startedAt,
        endedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<StudySession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    } else if (isInserting) {
      context.missing(_sessionTypeMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
          _durationMinutesMeta,
          durationMinutes.isAcceptableOrUnknown(
              data['duration_minutes']!, _durationMinutesMeta));
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudySession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudySession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_id']),
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_id']),
      sessionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_type'])!,
      durationMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
    );
  }

  @override
  $StudySessionsTable createAlias(String alias) {
    return $StudySessionsTable(attachedDatabase, alias);
  }
}

class StudySession extends DataClass implements Insertable<StudySession> {
  final String id;
  final String userId;
  final String? topicId;
  final String? subjectId;
  final String sessionType;
  final int durationMinutes;
  final DateTime startedAt;
  final DateTime? endedAt;
  const StudySession(
      {required this.id,
      required this.userId,
      this.topicId,
      this.subjectId,
      required this.sessionType,
      required this.durationMinutes,
      required this.startedAt,
      this.endedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    if (!nullToAbsent || subjectId != null) {
      map['subject_id'] = Variable<String>(subjectId);
    }
    map['session_type'] = Variable<String>(sessionType);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  StudySessionsCompanion toCompanion(bool nullToAbsent) {
    return StudySessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      subjectId: subjectId == null && nullToAbsent
          ? const Value.absent()
          : Value(subjectId),
      sessionType: Value(sessionType),
      durationMinutes: Value(durationMinutes),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory StudySession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudySession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      topicId: serializer.fromJson<String?>(json['topicId']),
      subjectId: serializer.fromJson<String?>(json['subjectId']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'topicId': serializer.toJson<String?>(topicId),
      'subjectId': serializer.toJson<String?>(subjectId),
      'sessionType': serializer.toJson<String>(sessionType),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  StudySession copyWith(
          {String? id,
          String? userId,
          Value<String?> topicId = const Value.absent(),
          Value<String?> subjectId = const Value.absent(),
          String? sessionType,
          int? durationMinutes,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent()}) =>
      StudySession(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        topicId: topicId.present ? topicId.value : this.topicId,
        subjectId: subjectId.present ? subjectId.value : this.subjectId,
        sessionType: sessionType ?? this.sessionType,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
      );
  StudySession copyWithCompanion(StudySessionsCompanion data) {
    return StudySession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      sessionType:
          data.sessionType.present ? data.sessionType.value : this.sessionType,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudySession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('sessionType: $sessionType, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, topicId, subjectId, sessionType,
      durationMinutes, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudySession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.topicId == this.topicId &&
          other.subjectId == this.subjectId &&
          other.sessionType == this.sessionType &&
          other.durationMinutes == this.durationMinutes &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class StudySessionsCompanion extends UpdateCompanion<StudySession> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> topicId;
  final Value<String?> subjectId;
  final Value<String> sessionType;
  final Value<int> durationMinutes;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const StudySessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudySessionsCompanion.insert({
    required String id,
    required String userId,
    this.topicId = const Value.absent(),
    this.subjectId = const Value.absent(),
    required String sessionType,
    required int durationMinutes,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        sessionType = Value(sessionType),
        durationMinutes = Value(durationMinutes),
        startedAt = Value(startedAt);
  static Insertable<StudySession> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? topicId,
    Expression<String>? subjectId,
    Expression<String>? sessionType,
    Expression<int>? durationMinutes,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (topicId != null) 'topic_id': topicId,
      if (subjectId != null) 'subject_id': subjectId,
      if (sessionType != null) 'session_type': sessionType,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudySessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String?>? topicId,
      Value<String?>? subjectId,
      Value<String>? sessionType,
      Value<int>? durationMinutes,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? rowid}) {
    return StudySessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      subjectId: subjectId ?? this.subjectId,
      sessionType: sessionType ?? this.sessionType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudySessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topicId: $topicId, ')
          ..write('subjectId: $subjectId, ')
          ..write('sessionType: $sessionType, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyAnalyticsTable extends DailyAnalytics
    with TableInfo<$DailyAnalyticsTable, DailyAnalytic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyAnalyticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _studyMinutesMeta =
      const VerificationMeta('studyMinutes');
  @override
  late final GeneratedColumn<int> studyMinutes = GeneratedColumn<int>(
      'study_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quizzesCompletedMeta =
      const VerificationMeta('quizzesCompleted');
  @override
  late final GeneratedColumn<int> quizzesCompleted = GeneratedColumn<int>(
      'quizzes_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _flashcardsReviewedMeta =
      const VerificationMeta('flashcardsReviewed');
  @override
  late final GeneratedColumn<int> flashcardsReviewed = GeneratedColumn<int>(
      'flashcards_reviewed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _aiChatMessagesMeta =
      const VerificationMeta('aiChatMessages');
  @override
  late final GeneratedColumn<int> aiChatMessages = GeneratedColumn<int>(
      'ai_chat_messages', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _topicsStudiedMeta =
      const VerificationMeta('topicsStudied');
  @override
  late final GeneratedColumn<int> topicsStudied = GeneratedColumn<int>(
      'topics_studied', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalMetMeta =
      const VerificationMeta('goalMet');
  @override
  late final GeneratedColumn<bool> goalMet = GeneratedColumn<bool>(
      'goal_met', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("goal_met" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _streakDayMeta =
      const VerificationMeta('streakDay');
  @override
  late final GeneratedColumn<int> streakDay = GeneratedColumn<int>(
      'streak_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        date,
        studyMinutes,
        quizzesCompleted,
        flashcardsReviewed,
        aiChatMessages,
        topicsStudied,
        goalMet,
        streakDay
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_analytics';
  @override
  VerificationContext validateIntegrity(Insertable<DailyAnalytic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('study_minutes')) {
      context.handle(
          _studyMinutesMeta,
          studyMinutes.isAcceptableOrUnknown(
              data['study_minutes']!, _studyMinutesMeta));
    }
    if (data.containsKey('quizzes_completed')) {
      context.handle(
          _quizzesCompletedMeta,
          quizzesCompleted.isAcceptableOrUnknown(
              data['quizzes_completed']!, _quizzesCompletedMeta));
    }
    if (data.containsKey('flashcards_reviewed')) {
      context.handle(
          _flashcardsReviewedMeta,
          flashcardsReviewed.isAcceptableOrUnknown(
              data['flashcards_reviewed']!, _flashcardsReviewedMeta));
    }
    if (data.containsKey('ai_chat_messages')) {
      context.handle(
          _aiChatMessagesMeta,
          aiChatMessages.isAcceptableOrUnknown(
              data['ai_chat_messages']!, _aiChatMessagesMeta));
    }
    if (data.containsKey('topics_studied')) {
      context.handle(
          _topicsStudiedMeta,
          topicsStudied.isAcceptableOrUnknown(
              data['topics_studied']!, _topicsStudiedMeta));
    }
    if (data.containsKey('goal_met')) {
      context.handle(_goalMetMeta,
          goalMet.isAcceptableOrUnknown(data['goal_met']!, _goalMetMeta));
    }
    if (data.containsKey('streak_day')) {
      context.handle(_streakDayMeta,
          streakDay.isAcceptableOrUnknown(data['streak_day']!, _streakDayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyAnalytic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyAnalytic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      studyMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}study_minutes'])!,
      quizzesCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quizzes_completed'])!,
      flashcardsReviewed: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}flashcards_reviewed'])!,
      aiChatMessages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ai_chat_messages'])!,
      topicsStudied: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}topics_studied'])!,
      goalMet: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}goal_met'])!,
      streakDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak_day'])!,
    );
  }

  @override
  $DailyAnalyticsTable createAlias(String alias) {
    return $DailyAnalyticsTable(attachedDatabase, alias);
  }
}

class DailyAnalytic extends DataClass implements Insertable<DailyAnalytic> {
  final String id;
  final String userId;
  final String date;
  final int studyMinutes;
  final int quizzesCompleted;
  final int flashcardsReviewed;
  final int aiChatMessages;
  final int topicsStudied;
  final bool goalMet;
  final int streakDay;
  const DailyAnalytic(
      {required this.id,
      required this.userId,
      required this.date,
      required this.studyMinutes,
      required this.quizzesCompleted,
      required this.flashcardsReviewed,
      required this.aiChatMessages,
      required this.topicsStudied,
      required this.goalMet,
      required this.streakDay});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['date'] = Variable<String>(date);
    map['study_minutes'] = Variable<int>(studyMinutes);
    map['quizzes_completed'] = Variable<int>(quizzesCompleted);
    map['flashcards_reviewed'] = Variable<int>(flashcardsReviewed);
    map['ai_chat_messages'] = Variable<int>(aiChatMessages);
    map['topics_studied'] = Variable<int>(topicsStudied);
    map['goal_met'] = Variable<bool>(goalMet);
    map['streak_day'] = Variable<int>(streakDay);
    return map;
  }

  DailyAnalyticsCompanion toCompanion(bool nullToAbsent) {
    return DailyAnalyticsCompanion(
      id: Value(id),
      userId: Value(userId),
      date: Value(date),
      studyMinutes: Value(studyMinutes),
      quizzesCompleted: Value(quizzesCompleted),
      flashcardsReviewed: Value(flashcardsReviewed),
      aiChatMessages: Value(aiChatMessages),
      topicsStudied: Value(topicsStudied),
      goalMet: Value(goalMet),
      streakDay: Value(streakDay),
    );
  }

  factory DailyAnalytic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyAnalytic(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      date: serializer.fromJson<String>(json['date']),
      studyMinutes: serializer.fromJson<int>(json['studyMinutes']),
      quizzesCompleted: serializer.fromJson<int>(json['quizzesCompleted']),
      flashcardsReviewed: serializer.fromJson<int>(json['flashcardsReviewed']),
      aiChatMessages: serializer.fromJson<int>(json['aiChatMessages']),
      topicsStudied: serializer.fromJson<int>(json['topicsStudied']),
      goalMet: serializer.fromJson<bool>(json['goalMet']),
      streakDay: serializer.fromJson<int>(json['streakDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'date': serializer.toJson<String>(date),
      'studyMinutes': serializer.toJson<int>(studyMinutes),
      'quizzesCompleted': serializer.toJson<int>(quizzesCompleted),
      'flashcardsReviewed': serializer.toJson<int>(flashcardsReviewed),
      'aiChatMessages': serializer.toJson<int>(aiChatMessages),
      'topicsStudied': serializer.toJson<int>(topicsStudied),
      'goalMet': serializer.toJson<bool>(goalMet),
      'streakDay': serializer.toJson<int>(streakDay),
    };
  }

  DailyAnalytic copyWith(
          {String? id,
          String? userId,
          String? date,
          int? studyMinutes,
          int? quizzesCompleted,
          int? flashcardsReviewed,
          int? aiChatMessages,
          int? topicsStudied,
          bool? goalMet,
          int? streakDay}) =>
      DailyAnalytic(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        studyMinutes: studyMinutes ?? this.studyMinutes,
        quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
        flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
        aiChatMessages: aiChatMessages ?? this.aiChatMessages,
        topicsStudied: topicsStudied ?? this.topicsStudied,
        goalMet: goalMet ?? this.goalMet,
        streakDay: streakDay ?? this.streakDay,
      );
  DailyAnalytic copyWithCompanion(DailyAnalyticsCompanion data) {
    return DailyAnalytic(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      date: data.date.present ? data.date.value : this.date,
      studyMinutes: data.studyMinutes.present
          ? data.studyMinutes.value
          : this.studyMinutes,
      quizzesCompleted: data.quizzesCompleted.present
          ? data.quizzesCompleted.value
          : this.quizzesCompleted,
      flashcardsReviewed: data.flashcardsReviewed.present
          ? data.flashcardsReviewed.value
          : this.flashcardsReviewed,
      aiChatMessages: data.aiChatMessages.present
          ? data.aiChatMessages.value
          : this.aiChatMessages,
      topicsStudied: data.topicsStudied.present
          ? data.topicsStudied.value
          : this.topicsStudied,
      goalMet: data.goalMet.present ? data.goalMet.value : this.goalMet,
      streakDay: data.streakDay.present ? data.streakDay.value : this.streakDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyAnalytic(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('studyMinutes: $studyMinutes, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('flashcardsReviewed: $flashcardsReviewed, ')
          ..write('aiChatMessages: $aiChatMessages, ')
          ..write('topicsStudied: $topicsStudied, ')
          ..write('goalMet: $goalMet, ')
          ..write('streakDay: $streakDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      date,
      studyMinutes,
      quizzesCompleted,
      flashcardsReviewed,
      aiChatMessages,
      topicsStudied,
      goalMet,
      streakDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyAnalytic &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.date == this.date &&
          other.studyMinutes == this.studyMinutes &&
          other.quizzesCompleted == this.quizzesCompleted &&
          other.flashcardsReviewed == this.flashcardsReviewed &&
          other.aiChatMessages == this.aiChatMessages &&
          other.topicsStudied == this.topicsStudied &&
          other.goalMet == this.goalMet &&
          other.streakDay == this.streakDay);
}

class DailyAnalyticsCompanion extends UpdateCompanion<DailyAnalytic> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> date;
  final Value<int> studyMinutes;
  final Value<int> quizzesCompleted;
  final Value<int> flashcardsReviewed;
  final Value<int> aiChatMessages;
  final Value<int> topicsStudied;
  final Value<bool> goalMet;
  final Value<int> streakDay;
  final Value<int> rowid;
  const DailyAnalyticsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.date = const Value.absent(),
    this.studyMinutes = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.flashcardsReviewed = const Value.absent(),
    this.aiChatMessages = const Value.absent(),
    this.topicsStudied = const Value.absent(),
    this.goalMet = const Value.absent(),
    this.streakDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyAnalyticsCompanion.insert({
    required String id,
    required String userId,
    required String date,
    this.studyMinutes = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.flashcardsReviewed = const Value.absent(),
    this.aiChatMessages = const Value.absent(),
    this.topicsStudied = const Value.absent(),
    this.goalMet = const Value.absent(),
    this.streakDay = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        date = Value(date);
  static Insertable<DailyAnalytic> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? date,
    Expression<int>? studyMinutes,
    Expression<int>? quizzesCompleted,
    Expression<int>? flashcardsReviewed,
    Expression<int>? aiChatMessages,
    Expression<int>? topicsStudied,
    Expression<bool>? goalMet,
    Expression<int>? streakDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (date != null) 'date': date,
      if (studyMinutes != null) 'study_minutes': studyMinutes,
      if (quizzesCompleted != null) 'quizzes_completed': quizzesCompleted,
      if (flashcardsReviewed != null) 'flashcards_reviewed': flashcardsReviewed,
      if (aiChatMessages != null) 'ai_chat_messages': aiChatMessages,
      if (topicsStudied != null) 'topics_studied': topicsStudied,
      if (goalMet != null) 'goal_met': goalMet,
      if (streakDay != null) 'streak_day': streakDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyAnalyticsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? date,
      Value<int>? studyMinutes,
      Value<int>? quizzesCompleted,
      Value<int>? flashcardsReviewed,
      Value<int>? aiChatMessages,
      Value<int>? topicsStudied,
      Value<bool>? goalMet,
      Value<int>? streakDay,
      Value<int>? rowid}) {
    return DailyAnalyticsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      aiChatMessages: aiChatMessages ?? this.aiChatMessages,
      topicsStudied: topicsStudied ?? this.topicsStudied,
      goalMet: goalMet ?? this.goalMet,
      streakDay: streakDay ?? this.streakDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (studyMinutes.present) {
      map['study_minutes'] = Variable<int>(studyMinutes.value);
    }
    if (quizzesCompleted.present) {
      map['quizzes_completed'] = Variable<int>(quizzesCompleted.value);
    }
    if (flashcardsReviewed.present) {
      map['flashcards_reviewed'] = Variable<int>(flashcardsReviewed.value);
    }
    if (aiChatMessages.present) {
      map['ai_chat_messages'] = Variable<int>(aiChatMessages.value);
    }
    if (topicsStudied.present) {
      map['topics_studied'] = Variable<int>(topicsStudied.value);
    }
    if (goalMet.present) {
      map['goal_met'] = Variable<bool>(goalMet.value);
    }
    if (streakDay.present) {
      map['streak_day'] = Variable<int>(streakDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyAnalyticsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('date: $date, ')
          ..write('studyMinutes: $studyMinutes, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('flashcardsReviewed: $flashcardsReviewed, ')
          ..write('aiChatMessages: $aiChatMessages, ')
          ..write('topicsStudied: $topicsStudied, ')
          ..write('goalMet: $goalMet, ')
          ..write('streakDay: $streakDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SemestersTable semesters = $SemestersTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $TopicsTable topics = $TopicsTable(this);
  late final $MicroConceptsTable microConcepts = $MicroConceptsTable(this);
  late final $ConceptDependenciesTable conceptDependencies =
      $ConceptDependenciesTable(this);
  late final $StudyDnaEntriesTable studyDnaEntries =
      $StudyDnaEntriesTable(this);
  late final $LearningTimelineEntriesTable learningTimelineEntries =
      $LearningTimelineEntriesTable(this);
  late final $LearningResourcesTable learningResources =
      $LearningResourcesTable(this);
  late final $ResourceChunksTable resourceChunks = $ResourceChunksTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $QuizzesTable quizzes = $QuizzesTable(this);
  late final $QuizQuestionsTable quizQuestions = $QuizQuestionsTable(this);
  late final $QuizAttemptsTable quizAttempts = $QuizAttemptsTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $StudySessionsTable studySessions = $StudySessionsTable(this);
  late final $DailyAnalyticsTable dailyAnalytics = $DailyAnalyticsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        semesters,
        subjects,
        units,
        topics,
        microConcepts,
        conceptDependencies,
        studyDnaEntries,
        learningTimelineEntries,
        learningResources,
        resourceChunks,
        flashcards,
        quizzes,
        quizQuestions,
        quizAttempts,
        conversations,
        messages,
        studySessions,
        dailyAnalytics
      ];
}

typedef $$SemestersTableCreateCompanionBuilder = SemestersCompanion Function({
  required String id,
  required String userId,
  required String name,
  Value<String?> description,
  required int number,
  required DateTime startDate,
  required DateTime endDate,
  Value<bool> isActive,
  Value<bool> isArchived,
  Value<double> overallProgress,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$SemestersTableUpdateCompanionBuilder = SemestersCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String?> description,
  Value<int> number,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<bool> isActive,
  Value<bool> isArchived,
  Value<double> overallProgress,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$SemestersTableFilterComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SemestersTableOrderingComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SemestersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SemestersTable> {
  $$SemestersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<double> get overallProgress => $composableBuilder(
      column: $table.overallProgress, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SemestersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SemestersTable,
    Semester,
    $$SemestersTableFilterComposer,
    $$SemestersTableOrderingComposer,
    $$SemestersTableAnnotationComposer,
    $$SemestersTableCreateCompanionBuilder,
    $$SemestersTableUpdateCompanionBuilder,
    (Semester, BaseReferences<_$AppDatabase, $SemestersTable, Semester>),
    Semester,
    PrefetchHooks Function()> {
  $$SemestersTableTableManager(_$AppDatabase db, $SemestersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SemestersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SemestersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SemestersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<double> overallProgress = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SemestersCompanion(
            id: id,
            userId: userId,
            name: name,
            description: description,
            number: number,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            isArchived: isArchived,
            overallProgress: overallProgress,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String name,
            Value<String?> description = const Value.absent(),
            required int number,
            required DateTime startDate,
            required DateTime endDate,
            Value<bool> isActive = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<double> overallProgress = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SemestersCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            description: description,
            number: number,
            startDate: startDate,
            endDate: endDate,
            isActive: isActive,
            isArchived: isArchived,
            overallProgress: overallProgress,
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

typedef $$SemestersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SemestersTable,
    Semester,
    $$SemestersTableFilterComposer,
    $$SemestersTableOrderingComposer,
    $$SemestersTableAnnotationComposer,
    $$SemestersTableCreateCompanionBuilder,
    $$SemestersTableUpdateCompanionBuilder,
    (Semester, BaseReferences<_$AppDatabase, $SemestersTable, Semester>),
    Semester,
    PrefetchHooks Function()>;
typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  required String id,
  required String semesterId,
  required String userId,
  required String name,
  Value<String?> description,
  Value<String?> code,
  Value<int> colorIndex,
  Value<String?> iconName,
  Value<double> masteryScore,
  Value<int> totalStudyMinutes,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<String> id,
  Value<String> semesterId,
  Value<String> userId,
  Value<String> name,
  Value<String?> description,
  Value<String?> code,
  Value<int> colorIndex,
  Value<String?> iconName,
  Value<double> masteryScore,
  Value<int> totalStudyMinutes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get semesterId => $composableBuilder(
      column: $table.semesterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorIndex => $composableBuilder(
      column: $table.colorIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get semesterId => $composableBuilder(
      column: $table.semesterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorIndex => $composableBuilder(
      column: $table.colorIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get semesterId => $composableBuilder(
      column: $table.semesterId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get colorIndex => $composableBuilder(
      column: $table.colorIndex, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => column);

  GeneratedColumn<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
    Subject,
    PrefetchHooks Function()> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> semesterId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<int> colorIndex = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<int> totalStudyMinutes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            semesterId: semesterId,
            userId: userId,
            name: name,
            description: description,
            code: code,
            colorIndex: colorIndex,
            iconName: iconName,
            masteryScore: masteryScore,
            totalStudyMinutes: totalStudyMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String semesterId,
            required String userId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> code = const Value.absent(),
            Value<int> colorIndex = const Value.absent(),
            Value<String?> iconName = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<int> totalStudyMinutes = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            semesterId: semesterId,
            userId: userId,
            name: name,
            description: description,
            code: code,
            colorIndex: colorIndex,
            iconName: iconName,
            masteryScore: masteryScore,
            totalStudyMinutes: totalStudyMinutes,
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

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, BaseReferences<_$AppDatabase, $SubjectsTable, Subject>),
    Subject,
    PrefetchHooks Function()>;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  required String id,
  required String subjectId,
  required String userId,
  required String name,
  Value<String?> description,
  Value<int> sortOrder,
  Value<double> masteryScore,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<String> subjectId,
  Value<String> userId,
  Value<String> name,
  Value<String?> description,
  Value<int> sortOrder,
  Value<double> masteryScore,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
    Unit,
    PrefetchHooks Function()> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion(
            id: id,
            subjectId: subjectId,
            userId: userId,
            name: name,
            description: description,
            sortOrder: sortOrder,
            masteryScore: masteryScore,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String subjectId,
            required String userId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            id: id,
            subjectId: subjectId,
            userId: userId,
            name: name,
            description: description,
            sortOrder: sortOrder,
            masteryScore: masteryScore,
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

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
    Unit,
    PrefetchHooks Function()>;
typedef $$TopicsTableCreateCompanionBuilder = TopicsCompanion Function({
  required String id,
  required String unitId,
  required String subjectId,
  required String userId,
  required String title,
  Value<String?> description,
  Value<String> status,
  Value<double> masteryScore,
  Value<int> weaknessFlag,
  Value<bool> isAIProcessed,
  Value<String> conceptTagsJson,
  Value<String> learningObjectivesJson,
  Value<int> totalStudyMinutes,
  Value<int> quizAttempts,
  Value<double> averageQuizScore,
  Value<int> flashcardCount,
  Value<int> chatMessageCount,
  Value<DateTime?> lastStudiedAt,
  Value<DateTime?> nextRevisionDue,
  Value<int> sortOrder,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$TopicsTableUpdateCompanionBuilder = TopicsCompanion Function({
  Value<String> id,
  Value<String> unitId,
  Value<String> subjectId,
  Value<String> userId,
  Value<String> title,
  Value<String?> description,
  Value<String> status,
  Value<double> masteryScore,
  Value<int> weaknessFlag,
  Value<bool> isAIProcessed,
  Value<String> conceptTagsJson,
  Value<String> learningObjectivesJson,
  Value<int> totalStudyMinutes,
  Value<int> quizAttempts,
  Value<double> averageQuizScore,
  Value<int> flashcardCount,
  Value<int> chatMessageCount,
  Value<DateTime?> lastStudiedAt,
  Value<DateTime?> nextRevisionDue,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$TopicsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weaknessFlag => $composableBuilder(
      column: $table.weaknessFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAIProcessed => $composableBuilder(
      column: $table.isAIProcessed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conceptTagsJson => $composableBuilder(
      column: $table.conceptTagsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get learningObjectivesJson => $composableBuilder(
      column: $table.learningObjectivesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quizAttempts => $composableBuilder(
      column: $table.quizAttempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averageQuizScore => $composableBuilder(
      column: $table.averageQuizScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flashcardCount => $composableBuilder(
      column: $table.flashcardCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chatMessageCount => $composableBuilder(
      column: $table.chatMessageCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weaknessFlag => $composableBuilder(
      column: $table.weaknessFlag,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAIProcessed => $composableBuilder(
      column: $table.isAIProcessed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conceptTagsJson => $composableBuilder(
      column: $table.conceptTagsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get learningObjectivesJson => $composableBuilder(
      column: $table.learningObjectivesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quizAttempts => $composableBuilder(
      column: $table.quizAttempts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averageQuizScore => $composableBuilder(
      column: $table.averageQuizScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flashcardCount => $composableBuilder(
      column: $table.flashcardCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chatMessageCount => $composableBuilder(
      column: $table.chatMessageCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => column);

  GeneratedColumn<int> get weaknessFlag => $composableBuilder(
      column: $table.weaknessFlag, builder: (column) => column);

  GeneratedColumn<bool> get isAIProcessed => $composableBuilder(
      column: $table.isAIProcessed, builder: (column) => column);

  GeneratedColumn<String> get conceptTagsJson => $composableBuilder(
      column: $table.conceptTagsJson, builder: (column) => column);

  GeneratedColumn<String> get learningObjectivesJson => $composableBuilder(
      column: $table.learningObjectivesJson, builder: (column) => column);

  GeneratedColumn<int> get totalStudyMinutes => $composableBuilder(
      column: $table.totalStudyMinutes, builder: (column) => column);

  GeneratedColumn<int> get quizAttempts => $composableBuilder(
      column: $table.quizAttempts, builder: (column) => column);

  GeneratedColumn<double> get averageQuizScore => $composableBuilder(
      column: $table.averageQuizScore, builder: (column) => column);

  GeneratedColumn<int> get flashcardCount => $composableBuilder(
      column: $table.flashcardCount, builder: (column) => column);

  GeneratedColumn<int> get chatMessageCount => $composableBuilder(
      column: $table.chatMessageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TopicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TopicsTable,
    Topic,
    $$TopicsTableFilterComposer,
    $$TopicsTableOrderingComposer,
    $$TopicsTableAnnotationComposer,
    $$TopicsTableCreateCompanionBuilder,
    $$TopicsTableUpdateCompanionBuilder,
    (Topic, BaseReferences<_$AppDatabase, $TopicsTable, Topic>),
    Topic,
    PrefetchHooks Function()> {
  $$TopicsTableTableManager(_$AppDatabase db, $TopicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<int> weaknessFlag = const Value.absent(),
            Value<bool> isAIProcessed = const Value.absent(),
            Value<String> conceptTagsJson = const Value.absent(),
            Value<String> learningObjectivesJson = const Value.absent(),
            Value<int> totalStudyMinutes = const Value.absent(),
            Value<int> quizAttempts = const Value.absent(),
            Value<double> averageQuizScore = const Value.absent(),
            Value<int> flashcardCount = const Value.absent(),
            Value<int> chatMessageCount = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<DateTime?> nextRevisionDue = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicsCompanion(
            id: id,
            unitId: unitId,
            subjectId: subjectId,
            userId: userId,
            title: title,
            description: description,
            status: status,
            masteryScore: masteryScore,
            weaknessFlag: weaknessFlag,
            isAIProcessed: isAIProcessed,
            conceptTagsJson: conceptTagsJson,
            learningObjectivesJson: learningObjectivesJson,
            totalStudyMinutes: totalStudyMinutes,
            quizAttempts: quizAttempts,
            averageQuizScore: averageQuizScore,
            flashcardCount: flashcardCount,
            chatMessageCount: chatMessageCount,
            lastStudiedAt: lastStudiedAt,
            nextRevisionDue: nextRevisionDue,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String unitId,
            required String subjectId,
            required String userId,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<int> weaknessFlag = const Value.absent(),
            Value<bool> isAIProcessed = const Value.absent(),
            Value<String> conceptTagsJson = const Value.absent(),
            Value<String> learningObjectivesJson = const Value.absent(),
            Value<int> totalStudyMinutes = const Value.absent(),
            Value<int> quizAttempts = const Value.absent(),
            Value<double> averageQuizScore = const Value.absent(),
            Value<int> flashcardCount = const Value.absent(),
            Value<int> chatMessageCount = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<DateTime?> nextRevisionDue = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TopicsCompanion.insert(
            id: id,
            unitId: unitId,
            subjectId: subjectId,
            userId: userId,
            title: title,
            description: description,
            status: status,
            masteryScore: masteryScore,
            weaknessFlag: weaknessFlag,
            isAIProcessed: isAIProcessed,
            conceptTagsJson: conceptTagsJson,
            learningObjectivesJson: learningObjectivesJson,
            totalStudyMinutes: totalStudyMinutes,
            quizAttempts: quizAttempts,
            averageQuizScore: averageQuizScore,
            flashcardCount: flashcardCount,
            chatMessageCount: chatMessageCount,
            lastStudiedAt: lastStudiedAt,
            nextRevisionDue: nextRevisionDue,
            sortOrder: sortOrder,
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

typedef $$TopicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TopicsTable,
    Topic,
    $$TopicsTableFilterComposer,
    $$TopicsTableOrderingComposer,
    $$TopicsTableAnnotationComposer,
    $$TopicsTableCreateCompanionBuilder,
    $$TopicsTableUpdateCompanionBuilder,
    (Topic, BaseReferences<_$AppDatabase, $TopicsTable, Topic>),
    Topic,
    PrefetchHooks Function()>;
typedef $$MicroConceptsTableCreateCompanionBuilder = MicroConceptsCompanion
    Function({
  required String id,
  required String topicId,
  required String subjectId,
  required String name,
  Value<String?> description,
  Value<String> keyFormulasJson,
  Value<double> masteryScore,
  Value<double> confidenceScore,
  Value<double> stabilityFactor,
  Value<double> forgettingProbability,
  Value<int> revisionCount,
  Value<double> quizAccuracy,
  Value<int> estimatedStudyMinutes,
  Value<int> estimatedRevisionMinutes,
  Value<DateTime?> lastStudiedAt,
  Value<DateTime?> nextRevisionDue,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$MicroConceptsTableUpdateCompanionBuilder = MicroConceptsCompanion
    Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> subjectId,
  Value<String> name,
  Value<String?> description,
  Value<String> keyFormulasJson,
  Value<double> masteryScore,
  Value<double> confidenceScore,
  Value<double> stabilityFactor,
  Value<double> forgettingProbability,
  Value<int> revisionCount,
  Value<double> quizAccuracy,
  Value<int> estimatedStudyMinutes,
  Value<int> estimatedRevisionMinutes,
  Value<DateTime?> lastStudiedAt,
  Value<DateTime?> nextRevisionDue,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});

class $$MicroConceptsTableFilterComposer
    extends Composer<_$AppDatabase, $MicroConceptsTable> {
  $$MicroConceptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyFormulasJson => $composableBuilder(
      column: $table.keyFormulasJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stabilityFactor => $composableBuilder(
      column: $table.stabilityFactor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get forgettingProbability => $composableBuilder(
      column: $table.forgettingProbability,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get revisionCount => $composableBuilder(
      column: $table.revisionCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quizAccuracy => $composableBuilder(
      column: $table.quizAccuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedStudyMinutes => $composableBuilder(
      column: $table.estimatedStudyMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedRevisionMinutes => $composableBuilder(
      column: $table.estimatedRevisionMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MicroConceptsTableOrderingComposer
    extends Composer<_$AppDatabase, $MicroConceptsTable> {
  $$MicroConceptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyFormulasJson => $composableBuilder(
      column: $table.keyFormulasJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stabilityFactor => $composableBuilder(
      column: $table.stabilityFactor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get forgettingProbability => $composableBuilder(
      column: $table.forgettingProbability,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get revisionCount => $composableBuilder(
      column: $table.revisionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quizAccuracy => $composableBuilder(
      column: $table.quizAccuracy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedStudyMinutes => $composableBuilder(
      column: $table.estimatedStudyMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedRevisionMinutes => $composableBuilder(
      column: $table.estimatedRevisionMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MicroConceptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MicroConceptsTable> {
  $$MicroConceptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get keyFormulasJson => $composableBuilder(
      column: $table.keyFormulasJson, builder: (column) => column);

  GeneratedColumn<double> get masteryScore => $composableBuilder(
      column: $table.masteryScore, builder: (column) => column);

  GeneratedColumn<double> get confidenceScore => $composableBuilder(
      column: $table.confidenceScore, builder: (column) => column);

  GeneratedColumn<double> get stabilityFactor => $composableBuilder(
      column: $table.stabilityFactor, builder: (column) => column);

  GeneratedColumn<double> get forgettingProbability => $composableBuilder(
      column: $table.forgettingProbability, builder: (column) => column);

  GeneratedColumn<int> get revisionCount => $composableBuilder(
      column: $table.revisionCount, builder: (column) => column);

  GeneratedColumn<double> get quizAccuracy => $composableBuilder(
      column: $table.quizAccuracy, builder: (column) => column);

  GeneratedColumn<int> get estimatedStudyMinutes => $composableBuilder(
      column: $table.estimatedStudyMinutes, builder: (column) => column);

  GeneratedColumn<int> get estimatedRevisionMinutes => $composableBuilder(
      column: $table.estimatedRevisionMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStudiedAt => $composableBuilder(
      column: $table.lastStudiedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRevisionDue => $composableBuilder(
      column: $table.nextRevisionDue, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MicroConceptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MicroConceptsTable,
    MicroConceptEntry,
    $$MicroConceptsTableFilterComposer,
    $$MicroConceptsTableOrderingComposer,
    $$MicroConceptsTableAnnotationComposer,
    $$MicroConceptsTableCreateCompanionBuilder,
    $$MicroConceptsTableUpdateCompanionBuilder,
    (
      MicroConceptEntry,
      BaseReferences<_$AppDatabase, $MicroConceptsTable, MicroConceptEntry>
    ),
    MicroConceptEntry,
    PrefetchHooks Function()> {
  $$MicroConceptsTableTableManager(_$AppDatabase db, $MicroConceptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MicroConceptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MicroConceptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MicroConceptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> subjectId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> keyFormulasJson = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<double> confidenceScore = const Value.absent(),
            Value<double> stabilityFactor = const Value.absent(),
            Value<double> forgettingProbability = const Value.absent(),
            Value<int> revisionCount = const Value.absent(),
            Value<double> quizAccuracy = const Value.absent(),
            Value<int> estimatedStudyMinutes = const Value.absent(),
            Value<int> estimatedRevisionMinutes = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<DateTime?> nextRevisionDue = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MicroConceptsCompanion(
            id: id,
            topicId: topicId,
            subjectId: subjectId,
            name: name,
            description: description,
            keyFormulasJson: keyFormulasJson,
            masteryScore: masteryScore,
            confidenceScore: confidenceScore,
            stabilityFactor: stabilityFactor,
            forgettingProbability: forgettingProbability,
            revisionCount: revisionCount,
            quizAccuracy: quizAccuracy,
            estimatedStudyMinutes: estimatedStudyMinutes,
            estimatedRevisionMinutes: estimatedRevisionMinutes,
            lastStudiedAt: lastStudiedAt,
            nextRevisionDue: nextRevisionDue,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String topicId,
            required String subjectId,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String> keyFormulasJson = const Value.absent(),
            Value<double> masteryScore = const Value.absent(),
            Value<double> confidenceScore = const Value.absent(),
            Value<double> stabilityFactor = const Value.absent(),
            Value<double> forgettingProbability = const Value.absent(),
            Value<int> revisionCount = const Value.absent(),
            Value<double> quizAccuracy = const Value.absent(),
            Value<int> estimatedStudyMinutes = const Value.absent(),
            Value<int> estimatedRevisionMinutes = const Value.absent(),
            Value<DateTime?> lastStudiedAt = const Value.absent(),
            Value<DateTime?> nextRevisionDue = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MicroConceptsCompanion.insert(
            id: id,
            topicId: topicId,
            subjectId: subjectId,
            name: name,
            description: description,
            keyFormulasJson: keyFormulasJson,
            masteryScore: masteryScore,
            confidenceScore: confidenceScore,
            stabilityFactor: stabilityFactor,
            forgettingProbability: forgettingProbability,
            revisionCount: revisionCount,
            quizAccuracy: quizAccuracy,
            estimatedStudyMinutes: estimatedStudyMinutes,
            estimatedRevisionMinutes: estimatedRevisionMinutes,
            lastStudiedAt: lastStudiedAt,
            nextRevisionDue: nextRevisionDue,
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

typedef $$MicroConceptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MicroConceptsTable,
    MicroConceptEntry,
    $$MicroConceptsTableFilterComposer,
    $$MicroConceptsTableOrderingComposer,
    $$MicroConceptsTableAnnotationComposer,
    $$MicroConceptsTableCreateCompanionBuilder,
    $$MicroConceptsTableUpdateCompanionBuilder,
    (
      MicroConceptEntry,
      BaseReferences<_$AppDatabase, $MicroConceptsTable, MicroConceptEntry>
    ),
    MicroConceptEntry,
    PrefetchHooks Function()>;
typedef $$ConceptDependenciesTableCreateCompanionBuilder
    = ConceptDependenciesCompanion Function({
  required String id,
  required String sourceConceptId,
  required String targetConceptId,
  Value<String> dependencyType,
  Value<double> strength,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ConceptDependenciesTableUpdateCompanionBuilder
    = ConceptDependenciesCompanion Function({
  Value<String> id,
  Value<String> sourceConceptId,
  Value<String> targetConceptId,
  Value<String> dependencyType,
  Value<double> strength,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ConceptDependenciesTableFilterComposer
    extends Composer<_$AppDatabase, $ConceptDependenciesTable> {
  $$ConceptDependenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceConceptId => $composableBuilder(
      column: $table.sourceConceptId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetConceptId => $composableBuilder(
      column: $table.targetConceptId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependencyType => $composableBuilder(
      column: $table.dependencyType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ConceptDependenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConceptDependenciesTable> {
  $$ConceptDependenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceConceptId => $composableBuilder(
      column: $table.sourceConceptId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetConceptId => $composableBuilder(
      column: $table.targetConceptId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependencyType => $composableBuilder(
      column: $table.dependencyType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ConceptDependenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConceptDependenciesTable> {
  $$ConceptDependenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceConceptId => $composableBuilder(
      column: $table.sourceConceptId, builder: (column) => column);

  GeneratedColumn<String> get targetConceptId => $composableBuilder(
      column: $table.targetConceptId, builder: (column) => column);

  GeneratedColumn<String> get dependencyType => $composableBuilder(
      column: $table.dependencyType, builder: (column) => column);

  GeneratedColumn<double> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ConceptDependenciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConceptDependenciesTable,
    ConceptDependencyEntry,
    $$ConceptDependenciesTableFilterComposer,
    $$ConceptDependenciesTableOrderingComposer,
    $$ConceptDependenciesTableAnnotationComposer,
    $$ConceptDependenciesTableCreateCompanionBuilder,
    $$ConceptDependenciesTableUpdateCompanionBuilder,
    (
      ConceptDependencyEntry,
      BaseReferences<_$AppDatabase, $ConceptDependenciesTable,
          ConceptDependencyEntry>
    ),
    ConceptDependencyEntry,
    PrefetchHooks Function()> {
  $$ConceptDependenciesTableTableManager(
      _$AppDatabase db, $ConceptDependenciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConceptDependenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConceptDependenciesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConceptDependenciesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sourceConceptId = const Value.absent(),
            Value<String> targetConceptId = const Value.absent(),
            Value<String> dependencyType = const Value.absent(),
            Value<double> strength = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConceptDependenciesCompanion(
            id: id,
            sourceConceptId: sourceConceptId,
            targetConceptId: targetConceptId,
            dependencyType: dependencyType,
            strength: strength,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sourceConceptId,
            required String targetConceptId,
            Value<String> dependencyType = const Value.absent(),
            Value<double> strength = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConceptDependenciesCompanion.insert(
            id: id,
            sourceConceptId: sourceConceptId,
            targetConceptId: targetConceptId,
            dependencyType: dependencyType,
            strength: strength,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConceptDependenciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConceptDependenciesTable,
    ConceptDependencyEntry,
    $$ConceptDependenciesTableFilterComposer,
    $$ConceptDependenciesTableOrderingComposer,
    $$ConceptDependenciesTableAnnotationComposer,
    $$ConceptDependenciesTableCreateCompanionBuilder,
    $$ConceptDependenciesTableUpdateCompanionBuilder,
    (
      ConceptDependencyEntry,
      BaseReferences<_$AppDatabase, $ConceptDependenciesTable,
          ConceptDependencyEntry>
    ),
    ConceptDependencyEntry,
    PrefetchHooks Function()>;
typedef $$StudyDnaEntriesTableCreateCompanionBuilder = StudyDnaEntriesCompanion
    Function({
  required String userId,
  required String sensoryProfileJson,
  required String pedagogicalProfileJson,
  required String temporalProfileJson,
  required String retentionProfileJson,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$StudyDnaEntriesTableUpdateCompanionBuilder = StudyDnaEntriesCompanion
    Function({
  Value<String> userId,
  Value<String> sensoryProfileJson,
  Value<String> pedagogicalProfileJson,
  Value<String> temporalProfileJson,
  Value<String> retentionProfileJson,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$StudyDnaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $StudyDnaEntriesTable> {
  $$StudyDnaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sensoryProfileJson => $composableBuilder(
      column: $table.sensoryProfileJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedagogicalProfileJson => $composableBuilder(
      column: $table.pedagogicalProfileJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get temporalProfileJson => $composableBuilder(
      column: $table.temporalProfileJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get retentionProfileJson => $composableBuilder(
      column: $table.retentionProfileJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$StudyDnaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyDnaEntriesTable> {
  $$StudyDnaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sensoryProfileJson => $composableBuilder(
      column: $table.sensoryProfileJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedagogicalProfileJson => $composableBuilder(
      column: $table.pedagogicalProfileJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get temporalProfileJson => $composableBuilder(
      column: $table.temporalProfileJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get retentionProfileJson => $composableBuilder(
      column: $table.retentionProfileJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StudyDnaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyDnaEntriesTable> {
  $$StudyDnaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sensoryProfileJson => $composableBuilder(
      column: $table.sensoryProfileJson, builder: (column) => column);

  GeneratedColumn<String> get pedagogicalProfileJson => $composableBuilder(
      column: $table.pedagogicalProfileJson, builder: (column) => column);

  GeneratedColumn<String> get temporalProfileJson => $composableBuilder(
      column: $table.temporalProfileJson, builder: (column) => column);

  GeneratedColumn<String> get retentionProfileJson => $composableBuilder(
      column: $table.retentionProfileJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudyDnaEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudyDnaEntriesTable,
    StudyDnaEntry,
    $$StudyDnaEntriesTableFilterComposer,
    $$StudyDnaEntriesTableOrderingComposer,
    $$StudyDnaEntriesTableAnnotationComposer,
    $$StudyDnaEntriesTableCreateCompanionBuilder,
    $$StudyDnaEntriesTableUpdateCompanionBuilder,
    (
      StudyDnaEntry,
      BaseReferences<_$AppDatabase, $StudyDnaEntriesTable, StudyDnaEntry>
    ),
    StudyDnaEntry,
    PrefetchHooks Function()> {
  $$StudyDnaEntriesTableTableManager(
      _$AppDatabase db, $StudyDnaEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyDnaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyDnaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyDnaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> sensoryProfileJson = const Value.absent(),
            Value<String> pedagogicalProfileJson = const Value.absent(),
            Value<String> temporalProfileJson = const Value.absent(),
            Value<String> retentionProfileJson = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyDnaEntriesCompanion(
            userId: userId,
            sensoryProfileJson: sensoryProfileJson,
            pedagogicalProfileJson: pedagogicalProfileJson,
            temporalProfileJson: temporalProfileJson,
            retentionProfileJson: retentionProfileJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String sensoryProfileJson,
            required String pedagogicalProfileJson,
            required String temporalProfileJson,
            required String retentionProfileJson,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              StudyDnaEntriesCompanion.insert(
            userId: userId,
            sensoryProfileJson: sensoryProfileJson,
            pedagogicalProfileJson: pedagogicalProfileJson,
            temporalProfileJson: temporalProfileJson,
            retentionProfileJson: retentionProfileJson,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudyDnaEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudyDnaEntriesTable,
    StudyDnaEntry,
    $$StudyDnaEntriesTableFilterComposer,
    $$StudyDnaEntriesTableOrderingComposer,
    $$StudyDnaEntriesTableAnnotationComposer,
    $$StudyDnaEntriesTableCreateCompanionBuilder,
    $$StudyDnaEntriesTableUpdateCompanionBuilder,
    (
      StudyDnaEntry,
      BaseReferences<_$AppDatabase, $StudyDnaEntriesTable, StudyDnaEntry>
    ),
    StudyDnaEntry,
    PrefetchHooks Function()>;
typedef $$LearningTimelineEntriesTableCreateCompanionBuilder
    = LearningTimelineEntriesCompanion Function({
  required String id,
  required String userId,
  Value<String?> conceptId,
  Value<String?> topicId,
  required String eventType,
  Value<double> deltaMastery,
  Value<double> currentMastery,
  required String title,
  required String description,
  Value<String> payloadJson,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $$LearningTimelineEntriesTableUpdateCompanionBuilder
    = LearningTimelineEntriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> conceptId,
  Value<String?> topicId,
  Value<String> eventType,
  Value<double> deltaMastery,
  Value<double> currentMastery,
  Value<String> title,
  Value<String> description,
  Value<String> payloadJson,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

class $$LearningTimelineEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LearningTimelineEntriesTable> {
  $$LearningTimelineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conceptId => $composableBuilder(
      column: $table.conceptId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get deltaMastery => $composableBuilder(
      column: $table.deltaMastery, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentMastery => $composableBuilder(
      column: $table.currentMastery,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$LearningTimelineEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningTimelineEntriesTable> {
  $$LearningTimelineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conceptId => $composableBuilder(
      column: $table.conceptId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get deltaMastery => $composableBuilder(
      column: $table.deltaMastery,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentMastery => $composableBuilder(
      column: $table.currentMastery,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$LearningTimelineEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningTimelineEntriesTable> {
  $$LearningTimelineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get conceptId =>
      $composableBuilder(column: $table.conceptId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<double> get deltaMastery => $composableBuilder(
      column: $table.deltaMastery, builder: (column) => column);

  GeneratedColumn<double> get currentMastery => $composableBuilder(
      column: $table.currentMastery, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$LearningTimelineEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearningTimelineEntriesTable,
    TimelineEntry,
    $$LearningTimelineEntriesTableFilterComposer,
    $$LearningTimelineEntriesTableOrderingComposer,
    $$LearningTimelineEntriesTableAnnotationComposer,
    $$LearningTimelineEntriesTableCreateCompanionBuilder,
    $$LearningTimelineEntriesTableUpdateCompanionBuilder,
    (
      TimelineEntry,
      BaseReferences<_$AppDatabase, $LearningTimelineEntriesTable,
          TimelineEntry>
    ),
    TimelineEntry,
    PrefetchHooks Function()> {
  $$LearningTimelineEntriesTableTableManager(
      _$AppDatabase db, $LearningTimelineEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningTimelineEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningTimelineEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningTimelineEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> conceptId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<double> deltaMastery = const Value.absent(),
            Value<double> currentMastery = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningTimelineEntriesCompanion(
            id: id,
            userId: userId,
            conceptId: conceptId,
            topicId: topicId,
            eventType: eventType,
            deltaMastery: deltaMastery,
            currentMastery: currentMastery,
            title: title,
            description: description,
            payloadJson: payloadJson,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> conceptId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            required String eventType,
            Value<double> deltaMastery = const Value.absent(),
            Value<double> currentMastery = const Value.absent(),
            required String title,
            required String description,
            Value<String> payloadJson = const Value.absent(),
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningTimelineEntriesCompanion.insert(
            id: id,
            userId: userId,
            conceptId: conceptId,
            topicId: topicId,
            eventType: eventType,
            deltaMastery: deltaMastery,
            currentMastery: currentMastery,
            title: title,
            description: description,
            payloadJson: payloadJson,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LearningTimelineEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LearningTimelineEntriesTable,
        TimelineEntry,
        $$LearningTimelineEntriesTableFilterComposer,
        $$LearningTimelineEntriesTableOrderingComposer,
        $$LearningTimelineEntriesTableAnnotationComposer,
        $$LearningTimelineEntriesTableCreateCompanionBuilder,
        $$LearningTimelineEntriesTableUpdateCompanionBuilder,
        (
          TimelineEntry,
          BaseReferences<_$AppDatabase, $LearningTimelineEntriesTable,
              TimelineEntry>
        ),
        TimelineEntry,
        PrefetchHooks Function()>;
typedef $$LearningResourcesTableCreateCompanionBuilder
    = LearningResourcesCompanion Function({
  required String id,
  required String topicId,
  required String userId,
  required String name,
  required String type,
  Value<String?> localPath,
  Value<String?> cloudUrl,
  Value<String?> youtubeUrl,
  Value<String?> extractedText,
  Value<int?> pageCount,
  Value<int> chunkCount,
  Value<bool> isProcessed,
  Value<String> processingStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LearningResourcesTableUpdateCompanionBuilder
    = LearningResourcesCompanion Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> userId,
  Value<String> name,
  Value<String> type,
  Value<String?> localPath,
  Value<String?> cloudUrl,
  Value<String?> youtubeUrl,
  Value<String?> extractedText,
  Value<int?> pageCount,
  Value<int> chunkCount,
  Value<bool> isProcessed,
  Value<String> processingStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$LearningResourcesTableFilterComposer
    extends Composer<_$AppDatabase, $LearningResourcesTable> {
  $$LearningResourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cloudUrl => $composableBuilder(
      column: $table.cloudUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedText => $composableBuilder(
      column: $table.extractedText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chunkCount => $composableBuilder(
      column: $table.chunkCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get processingStatus => $composableBuilder(
      column: $table.processingStatus,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LearningResourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $LearningResourcesTable> {
  $$LearningResourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cloudUrl => $composableBuilder(
      column: $table.cloudUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedText => $composableBuilder(
      column: $table.extractedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chunkCount => $composableBuilder(
      column: $table.chunkCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get processingStatus => $composableBuilder(
      column: $table.processingStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LearningResourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LearningResourcesTable> {
  $$LearningResourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get cloudUrl =>
      $composableBuilder(column: $table.cloudUrl, builder: (column) => column);

  GeneratedColumn<String> get youtubeUrl => $composableBuilder(
      column: $table.youtubeUrl, builder: (column) => column);

  GeneratedColumn<String> get extractedText => $composableBuilder(
      column: $table.extractedText, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get chunkCount => $composableBuilder(
      column: $table.chunkCount, builder: (column) => column);

  GeneratedColumn<bool> get isProcessed => $composableBuilder(
      column: $table.isProcessed, builder: (column) => column);

  GeneratedColumn<String> get processingStatus => $composableBuilder(
      column: $table.processingStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LearningResourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LearningResourcesTable,
    LearningResource,
    $$LearningResourcesTableFilterComposer,
    $$LearningResourcesTableOrderingComposer,
    $$LearningResourcesTableAnnotationComposer,
    $$LearningResourcesTableCreateCompanionBuilder,
    $$LearningResourcesTableUpdateCompanionBuilder,
    (
      LearningResource,
      BaseReferences<_$AppDatabase, $LearningResourcesTable, LearningResource>
    ),
    LearningResource,
    PrefetchHooks Function()> {
  $$LearningResourcesTableTableManager(
      _$AppDatabase db, $LearningResourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LearningResourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LearningResourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LearningResourcesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String?> cloudUrl = const Value.absent(),
            Value<String?> youtubeUrl = const Value.absent(),
            Value<String?> extractedText = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<int> chunkCount = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<String> processingStatus = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningResourcesCompanion(
            id: id,
            topicId: topicId,
            userId: userId,
            name: name,
            type: type,
            localPath: localPath,
            cloudUrl: cloudUrl,
            youtubeUrl: youtubeUrl,
            extractedText: extractedText,
            pageCount: pageCount,
            chunkCount: chunkCount,
            isProcessed: isProcessed,
            processingStatus: processingStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String topicId,
            required String userId,
            required String name,
            required String type,
            Value<String?> localPath = const Value.absent(),
            Value<String?> cloudUrl = const Value.absent(),
            Value<String?> youtubeUrl = const Value.absent(),
            Value<String?> extractedText = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
            Value<int> chunkCount = const Value.absent(),
            Value<bool> isProcessed = const Value.absent(),
            Value<String> processingStatus = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LearningResourcesCompanion.insert(
            id: id,
            topicId: topicId,
            userId: userId,
            name: name,
            type: type,
            localPath: localPath,
            cloudUrl: cloudUrl,
            youtubeUrl: youtubeUrl,
            extractedText: extractedText,
            pageCount: pageCount,
            chunkCount: chunkCount,
            isProcessed: isProcessed,
            processingStatus: processingStatus,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LearningResourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LearningResourcesTable,
    LearningResource,
    $$LearningResourcesTableFilterComposer,
    $$LearningResourcesTableOrderingComposer,
    $$LearningResourcesTableAnnotationComposer,
    $$LearningResourcesTableCreateCompanionBuilder,
    $$LearningResourcesTableUpdateCompanionBuilder,
    (
      LearningResource,
      BaseReferences<_$AppDatabase, $LearningResourcesTable, LearningResource>
    ),
    LearningResource,
    PrefetchHooks Function()>;
typedef $$ResourceChunksTableCreateCompanionBuilder = ResourceChunksCompanion
    Function({
  required String id,
  required String resourceId,
  required String topicId,
  required String content,
  required int chunkIndex,
  required int tokenCount,
  Value<String?> embeddingJson,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ResourceChunksTableUpdateCompanionBuilder = ResourceChunksCompanion
    Function({
  Value<String> id,
  Value<String> resourceId,
  Value<String> topicId,
  Value<String> content,
  Value<int> chunkIndex,
  Value<int> tokenCount,
  Value<String?> embeddingJson,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ResourceChunksTableFilterComposer
    extends Composer<_$AppDatabase, $ResourceChunksTable> {
  $$ResourceChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get embeddingJson => $composableBuilder(
      column: $table.embeddingJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ResourceChunksTableOrderingComposer
    extends Composer<_$AppDatabase, $ResourceChunksTable> {
  $$ResourceChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get embeddingJson => $composableBuilder(
      column: $table.embeddingJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ResourceChunksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResourceChunksTable> {
  $$ResourceChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get resourceId => $composableBuilder(
      column: $table.resourceId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex, builder: (column) => column);

  GeneratedColumn<int> get tokenCount => $composableBuilder(
      column: $table.tokenCount, builder: (column) => column);

  GeneratedColumn<String> get embeddingJson => $composableBuilder(
      column: $table.embeddingJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ResourceChunksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResourceChunksTable,
    ResourceChunk,
    $$ResourceChunksTableFilterComposer,
    $$ResourceChunksTableOrderingComposer,
    $$ResourceChunksTableAnnotationComposer,
    $$ResourceChunksTableCreateCompanionBuilder,
    $$ResourceChunksTableUpdateCompanionBuilder,
    (
      ResourceChunk,
      BaseReferences<_$AppDatabase, $ResourceChunksTable, ResourceChunk>
    ),
    ResourceChunk,
    PrefetchHooks Function()> {
  $$ResourceChunksTableTableManager(
      _$AppDatabase db, $ResourceChunksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResourceChunksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResourceChunksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResourceChunksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> resourceId = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> chunkIndex = const Value.absent(),
            Value<int> tokenCount = const Value.absent(),
            Value<String?> embeddingJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResourceChunksCompanion(
            id: id,
            resourceId: resourceId,
            topicId: topicId,
            content: content,
            chunkIndex: chunkIndex,
            tokenCount: tokenCount,
            embeddingJson: embeddingJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String resourceId,
            required String topicId,
            required String content,
            required int chunkIndex,
            required int tokenCount,
            Value<String?> embeddingJson = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ResourceChunksCompanion.insert(
            id: id,
            resourceId: resourceId,
            topicId: topicId,
            content: content,
            chunkIndex: chunkIndex,
            tokenCount: tokenCount,
            embeddingJson: embeddingJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ResourceChunksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResourceChunksTable,
    ResourceChunk,
    $$ResourceChunksTableFilterComposer,
    $$ResourceChunksTableOrderingComposer,
    $$ResourceChunksTableAnnotationComposer,
    $$ResourceChunksTableCreateCompanionBuilder,
    $$ResourceChunksTableUpdateCompanionBuilder,
    (
      ResourceChunk,
      BaseReferences<_$AppDatabase, $ResourceChunksTable, ResourceChunk>
    ),
    ResourceChunk,
    PrefetchHooks Function()>;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  required String id,
  required String topicId,
  required String userId,
  required String front,
  required String back,
  Value<String?> hint,
  Value<bool> isAIGenerated,
  Value<int> repetitions,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<DateTime?> nextReviewDue,
  Value<DateTime?> lastReviewedAt,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> userId,
  Value<String> front,
  Value<String> back,
  Value<String?> hint,
  Value<bool> isAIGenerated,
  Value<int> repetitions,
  Value<double> easeFactor,
  Value<int> intervalDays,
  Value<DateTime?> nextReviewDue,
  Value<DateTime?> lastReviewedAt,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAIGenerated => $composableBuilder(
      column: $table.isAIGenerated, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReviewDue => $composableBuilder(
      column: $table.nextReviewDue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAIGenerated => $composableBuilder(
      column: $table.isAIGenerated,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReviewDue => $composableBuilder(
      column: $table.nextReviewDue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<bool> get isAIGenerated => $composableBuilder(
      column: $table.isAIGenerated, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
      column: $table.repetitions, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReviewDue => $composableBuilder(
      column: $table.nextReviewDue, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt => $composableBuilder(
      column: $table.lastReviewedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FlashcardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard>),
    Flashcard,
    PrefetchHooks Function()> {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<bool> isAIGenerated = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> nextReviewDue = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardsCompanion(
            id: id,
            topicId: topicId,
            userId: userId,
            front: front,
            back: back,
            hint: hint,
            isAIGenerated: isAIGenerated,
            repetitions: repetitions,
            easeFactor: easeFactor,
            intervalDays: intervalDays,
            nextReviewDue: nextReviewDue,
            lastReviewedAt: lastReviewedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String topicId,
            required String userId,
            required String front,
            required String back,
            Value<String?> hint = const Value.absent(),
            Value<bool> isAIGenerated = const Value.absent(),
            Value<int> repetitions = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> nextReviewDue = const Value.absent(),
            Value<DateTime?> lastReviewedAt = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FlashcardsCompanion.insert(
            id: id,
            topicId: topicId,
            userId: userId,
            front: front,
            back: back,
            hint: hint,
            isAIGenerated: isAIGenerated,
            repetitions: repetitions,
            easeFactor: easeFactor,
            intervalDays: intervalDays,
            nextReviewDue: nextReviewDue,
            lastReviewedAt: lastReviewedAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FlashcardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard>),
    Flashcard,
    PrefetchHooks Function()>;
typedef $$QuizzesTableCreateCompanionBuilder = QuizzesCompanion Function({
  required String id,
  required String topicId,
  required String userId,
  required String title,
  Value<String> type,
  Value<String> difficulty,
  required int questionCount,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$QuizzesTableUpdateCompanionBuilder = QuizzesCompanion Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> userId,
  Value<String> title,
  Value<String> type,
  Value<String> difficulty,
  Value<int> questionCount,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$QuizzesTableFilterComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$QuizzesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionCount => $composableBuilder(
      column: $table.questionCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$QuizzesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizzesTable> {
  $$QuizzesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get questionCount => $composableBuilder(
      column: $table.questionCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$QuizzesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizzesTable,
    Quizze,
    $$QuizzesTableFilterComposer,
    $$QuizzesTableOrderingComposer,
    $$QuizzesTableAnnotationComposer,
    $$QuizzesTableCreateCompanionBuilder,
    $$QuizzesTableUpdateCompanionBuilder,
    (Quizze, BaseReferences<_$AppDatabase, $QuizzesTable, Quizze>),
    Quizze,
    PrefetchHooks Function()> {
  $$QuizzesTableTableManager(_$AppDatabase db, $QuizzesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizzesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizzesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizzesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> topicId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> questionCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizzesCompanion(
            id: id,
            topicId: topicId,
            userId: userId,
            title: title,
            type: type,
            difficulty: difficulty,
            questionCount: questionCount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String topicId,
            required String userId,
            required String title,
            Value<String> type = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            required int questionCount,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizzesCompanion.insert(
            id: id,
            topicId: topicId,
            userId: userId,
            title: title,
            type: type,
            difficulty: difficulty,
            questionCount: questionCount,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizzesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizzesTable,
    Quizze,
    $$QuizzesTableFilterComposer,
    $$QuizzesTableOrderingComposer,
    $$QuizzesTableAnnotationComposer,
    $$QuizzesTableCreateCompanionBuilder,
    $$QuizzesTableUpdateCompanionBuilder,
    (Quizze, BaseReferences<_$AppDatabase, $QuizzesTable, Quizze>),
    Quizze,
    PrefetchHooks Function()>;
typedef $$QuizQuestionsTableCreateCompanionBuilder = QuizQuestionsCompanion
    Function({
  required String id,
  required String quizId,
  required String question,
  required String type,
  Value<String> optionsJson,
  required String correctAnswer,
  Value<String?> explanation,
  Value<String> difficulty,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$QuizQuestionsTableUpdateCompanionBuilder = QuizQuestionsCompanion
    Function({
  Value<String> id,
  Value<String> quizId,
  Value<String> question,
  Value<String> type,
  Value<String> optionsJson,
  Value<String> correctAnswer,
  Value<String?> explanation,
  Value<String> difficulty,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$QuizQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quizId => $composableBuilder(
      column: $table.quizId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$QuizQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quizId => $composableBuilder(
      column: $table.quizId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$QuizQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizQuestionsTable> {
  $$QuizQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quizId =>
      $composableBuilder(column: $table.quizId, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
      column: $table.correctAnswer, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$QuizQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizQuestionsTable,
    QuizQuestion,
    $$QuizQuestionsTableFilterComposer,
    $$QuizQuestionsTableOrderingComposer,
    $$QuizQuestionsTableAnnotationComposer,
    $$QuizQuestionsTableCreateCompanionBuilder,
    $$QuizQuestionsTableUpdateCompanionBuilder,
    (
      QuizQuestion,
      BaseReferences<_$AppDatabase, $QuizQuestionsTable, QuizQuestion>
    ),
    QuizQuestion,
    PrefetchHooks Function()> {
  $$QuizQuestionsTableTableManager(_$AppDatabase db, $QuizQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> quizId = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<String> correctAnswer = const Value.absent(),
            Value<String?> explanation = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizQuestionsCompanion(
            id: id,
            quizId: quizId,
            question: question,
            type: type,
            optionsJson: optionsJson,
            correctAnswer: correctAnswer,
            explanation: explanation,
            difficulty: difficulty,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String quizId,
            required String question,
            required String type,
            Value<String> optionsJson = const Value.absent(),
            required String correctAnswer,
            Value<String?> explanation = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizQuestionsCompanion.insert(
            id: id,
            quizId: quizId,
            question: question,
            type: type,
            optionsJson: optionsJson,
            correctAnswer: correctAnswer,
            explanation: explanation,
            difficulty: difficulty,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizQuestionsTable,
    QuizQuestion,
    $$QuizQuestionsTableFilterComposer,
    $$QuizQuestionsTableOrderingComposer,
    $$QuizQuestionsTableAnnotationComposer,
    $$QuizQuestionsTableCreateCompanionBuilder,
    $$QuizQuestionsTableUpdateCompanionBuilder,
    (
      QuizQuestion,
      BaseReferences<_$AppDatabase, $QuizQuestionsTable, QuizQuestion>
    ),
    QuizQuestion,
    PrefetchHooks Function()>;
typedef $$QuizAttemptsTableCreateCompanionBuilder = QuizAttemptsCompanion
    Function({
  required String id,
  required String quizId,
  required String userId,
  required double score,
  required int correctCount,
  required int totalQuestions,
  required int durationSeconds,
  Value<String> answersJson,
  required DateTime completedAt,
  Value<int> rowid,
});
typedef $$QuizAttemptsTableUpdateCompanionBuilder = QuizAttemptsCompanion
    Function({
  Value<String> id,
  Value<String> quizId,
  Value<String> userId,
  Value<double> score,
  Value<int> correctCount,
  Value<int> totalQuestions,
  Value<int> durationSeconds,
  Value<String> answersJson,
  Value<DateTime> completedAt,
  Value<int> rowid,
});

class $$QuizAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quizId => $composableBuilder(
      column: $table.quizId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$QuizAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quizId => $composableBuilder(
      column: $table.quizId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctCount => $composableBuilder(
      column: $table.correctCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$QuizAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get quizId =>
      $composableBuilder(column: $table.quizId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get correctCount => $composableBuilder(
      column: $table.correctCount, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
      column: $table.totalQuestions, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$QuizAttemptsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuizAttemptsTable,
    QuizAttempt,
    $$QuizAttemptsTableFilterComposer,
    $$QuizAttemptsTableOrderingComposer,
    $$QuizAttemptsTableAnnotationComposer,
    $$QuizAttemptsTableCreateCompanionBuilder,
    $$QuizAttemptsTableUpdateCompanionBuilder,
    (
      QuizAttempt,
      BaseReferences<_$AppDatabase, $QuizAttemptsTable, QuizAttempt>
    ),
    QuizAttempt,
    PrefetchHooks Function()> {
  $$QuizAttemptsTableTableManager(_$AppDatabase db, $QuizAttemptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> quizId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<int> correctCount = const Value.absent(),
            Value<int> totalQuestions = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<String> answersJson = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizAttemptsCompanion(
            id: id,
            quizId: quizId,
            userId: userId,
            score: score,
            correctCount: correctCount,
            totalQuestions: totalQuestions,
            durationSeconds: durationSeconds,
            answersJson: answersJson,
            completedAt: completedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String quizId,
            required String userId,
            required double score,
            required int correctCount,
            required int totalQuestions,
            required int durationSeconds,
            Value<String> answersJson = const Value.absent(),
            required DateTime completedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuizAttemptsCompanion.insert(
            id: id,
            quizId: quizId,
            userId: userId,
            score: score,
            correctCount: correctCount,
            totalQuestions: totalQuestions,
            durationSeconds: durationSeconds,
            answersJson: answersJson,
            completedAt: completedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuizAttemptsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuizAttemptsTable,
    QuizAttempt,
    $$QuizAttemptsTableFilterComposer,
    $$QuizAttemptsTableOrderingComposer,
    $$QuizAttemptsTableAnnotationComposer,
    $$QuizAttemptsTableCreateCompanionBuilder,
    $$QuizAttemptsTableUpdateCompanionBuilder,
    (
      QuizAttempt,
      BaseReferences<_$AppDatabase, $QuizAttemptsTable, QuizAttempt>
    ),
    QuizAttempt,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String id,
  required String userId,
  required String title,
  Value<String> contextType,
  Value<String?> contextId,
  Value<int> messageCount,
  required DateTime createdAt,
  Value<DateTime?> lastMessageAt,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String> contextType,
  Value<String?> contextId,
  Value<int> messageCount,
  Value<DateTime> createdAt,
  Value<DateTime?> lastMessageAt,
  Value<int> rowid,
});

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextType => $composableBuilder(
      column: $table.contextType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => ColumnFilters(column));
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextType => $composableBuilder(
      column: $table.contextType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageCount => $composableBuilder(
      column: $table.messageCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get contextType => $composableBuilder(
      column: $table.contextType, builder: (column) => column);

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
      column: $table.lastMessageAt, builder: (column) => column);
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> contextType = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            userId: userId,
            title: title,
            contextType: contextType,
            contextId: contextId,
            messageCount: messageCount,
            createdAt: createdAt,
            lastMessageAt: lastMessageAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            Value<String> contextType = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> lastMessageAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            contextType: contextType,
            contextId: contextId,
            messageCount: messageCount,
            createdAt: createdAt,
            lastMessageAt: lastMessageAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (
      Conversation,
      BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>
    ),
    Conversation,
    PrefetchHooks Function()>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String conversationId,
  required String role,
  required String content,
  Value<String> sourceChunkIdsJson,
  Value<int> promptTokens,
  Value<int> completionTokens,
  Value<String?> aiProvider,
  Value<String?> aiModel,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<String> sourceChunkIdsJson,
  Value<int> promptTokens,
  Value<int> completionTokens,
  Value<String?> aiProvider,
  Value<String?> aiModel,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceChunkIdsJson => $composableBuilder(
      column: $table.sourceChunkIdsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiProvider => $composableBuilder(
      column: $table.aiProvider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiModel => $composableBuilder(
      column: $table.aiModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationId => $composableBuilder(
      column: $table.conversationId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceChunkIdsJson => $composableBuilder(
      column: $table.sourceChunkIdsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiProvider => $composableBuilder(
      column: $table.aiProvider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiModel => $composableBuilder(
      column: $table.aiModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
      column: $table.conversationId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get sourceChunkIdsJson => $composableBuilder(
      column: $table.sourceChunkIdsJson, builder: (column) => column);

  GeneratedColumn<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens, builder: (column) => column);

  GeneratedColumn<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens, builder: (column) => column);

  GeneratedColumn<String> get aiProvider => $composableBuilder(
      column: $table.aiProvider, builder: (column) => column);

  GeneratedColumn<String> get aiModel =>
      $composableBuilder(column: $table.aiModel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> sourceChunkIdsJson = const Value.absent(),
            Value<int> promptTokens = const Value.absent(),
            Value<int> completionTokens = const Value.absent(),
            Value<String?> aiProvider = const Value.absent(),
            Value<String?> aiModel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            sourceChunkIdsJson: sourceChunkIdsJson,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            aiProvider: aiProvider,
            aiModel: aiModel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String content,
            Value<String> sourceChunkIdsJson = const Value.absent(),
            Value<int> promptTokens = const Value.absent(),
            Value<int> completionTokens = const Value.absent(),
            Value<String?> aiProvider = const Value.absent(),
            Value<String?> aiModel = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            sourceChunkIdsJson: sourceChunkIdsJson,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
            aiProvider: aiProvider,
            aiModel: aiModel,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
    Message,
    PrefetchHooks Function()>;
typedef $$StudySessionsTableCreateCompanionBuilder = StudySessionsCompanion
    Function({
  required String id,
  required String userId,
  Value<String?> topicId,
  Value<String?> subjectId,
  required String sessionType,
  required int durationMinutes,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});
typedef $$StudySessionsTableUpdateCompanionBuilder = StudySessionsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String?> topicId,
  Value<String?> subjectId,
  Value<String> sessionType,
  Value<int> durationMinutes,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> rowid,
});

class $$StudySessionsTableFilterComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));
}

class $$StudySessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId => $composableBuilder(
      column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectId => $composableBuilder(
      column: $table.subjectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));
}

class $$StudySessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudySessionsTable> {
  $$StudySessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);
}

class $$StudySessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (
      StudySession,
      BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>
    ),
    StudySession,
    PrefetchHooks Function()> {
  $$StudySessionsTableTableManager(_$AppDatabase db, $StudySessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudySessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudySessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudySessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> topicId = const Value.absent(),
            Value<String?> subjectId = const Value.absent(),
            Value<String> sessionType = const Value.absent(),
            Value<int> durationMinutes = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion(
            id: id,
            userId: userId,
            topicId: topicId,
            subjectId: subjectId,
            sessionType: sessionType,
            durationMinutes: durationMinutes,
            startedAt: startedAt,
            endedAt: endedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            Value<String?> topicId = const Value.absent(),
            Value<String?> subjectId = const Value.absent(),
            required String sessionType,
            required int durationMinutes,
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StudySessionsCompanion.insert(
            id: id,
            userId: userId,
            topicId: topicId,
            subjectId: subjectId,
            sessionType: sessionType,
            durationMinutes: durationMinutes,
            startedAt: startedAt,
            endedAt: endedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudySessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudySessionsTable,
    StudySession,
    $$StudySessionsTableFilterComposer,
    $$StudySessionsTableOrderingComposer,
    $$StudySessionsTableAnnotationComposer,
    $$StudySessionsTableCreateCompanionBuilder,
    $$StudySessionsTableUpdateCompanionBuilder,
    (
      StudySession,
      BaseReferences<_$AppDatabase, $StudySessionsTable, StudySession>
    ),
    StudySession,
    PrefetchHooks Function()>;
typedef $$DailyAnalyticsTableCreateCompanionBuilder = DailyAnalyticsCompanion
    Function({
  required String id,
  required String userId,
  required String date,
  Value<int> studyMinutes,
  Value<int> quizzesCompleted,
  Value<int> flashcardsReviewed,
  Value<int> aiChatMessages,
  Value<int> topicsStudied,
  Value<bool> goalMet,
  Value<int> streakDay,
  Value<int> rowid,
});
typedef $$DailyAnalyticsTableUpdateCompanionBuilder = DailyAnalyticsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> date,
  Value<int> studyMinutes,
  Value<int> quizzesCompleted,
  Value<int> flashcardsReviewed,
  Value<int> aiChatMessages,
  Value<int> topicsStudied,
  Value<bool> goalMet,
  Value<int> streakDay,
  Value<int> rowid,
});

class $$DailyAnalyticsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyAnalyticsTable> {
  $$DailyAnalyticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get studyMinutes => $composableBuilder(
      column: $table.studyMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quizzesCompleted => $composableBuilder(
      column: $table.quizzesCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flashcardsReviewed => $composableBuilder(
      column: $table.flashcardsReviewed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get aiChatMessages => $composableBuilder(
      column: $table.aiChatMessages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get topicsStudied => $composableBuilder(
      column: $table.topicsStudied, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get goalMet => $composableBuilder(
      column: $table.goalMet, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streakDay => $composableBuilder(
      column: $table.streakDay, builder: (column) => ColumnFilters(column));
}

class $$DailyAnalyticsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyAnalyticsTable> {
  $$DailyAnalyticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get studyMinutes => $composableBuilder(
      column: $table.studyMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quizzesCompleted => $composableBuilder(
      column: $table.quizzesCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flashcardsReviewed => $composableBuilder(
      column: $table.flashcardsReviewed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get aiChatMessages => $composableBuilder(
      column: $table.aiChatMessages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get topicsStudied => $composableBuilder(
      column: $table.topicsStudied,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get goalMet => $composableBuilder(
      column: $table.goalMet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streakDay => $composableBuilder(
      column: $table.streakDay, builder: (column) => ColumnOrderings(column));
}

class $$DailyAnalyticsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyAnalyticsTable> {
  $$DailyAnalyticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get studyMinutes => $composableBuilder(
      column: $table.studyMinutes, builder: (column) => column);

  GeneratedColumn<int> get quizzesCompleted => $composableBuilder(
      column: $table.quizzesCompleted, builder: (column) => column);

  GeneratedColumn<int> get flashcardsReviewed => $composableBuilder(
      column: $table.flashcardsReviewed, builder: (column) => column);

  GeneratedColumn<int> get aiChatMessages => $composableBuilder(
      column: $table.aiChatMessages, builder: (column) => column);

  GeneratedColumn<int> get topicsStudied => $composableBuilder(
      column: $table.topicsStudied, builder: (column) => column);

  GeneratedColumn<bool> get goalMet =>
      $composableBuilder(column: $table.goalMet, builder: (column) => column);

  GeneratedColumn<int> get streakDay =>
      $composableBuilder(column: $table.streakDay, builder: (column) => column);
}

class $$DailyAnalyticsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyAnalyticsTable,
    DailyAnalytic,
    $$DailyAnalyticsTableFilterComposer,
    $$DailyAnalyticsTableOrderingComposer,
    $$DailyAnalyticsTableAnnotationComposer,
    $$DailyAnalyticsTableCreateCompanionBuilder,
    $$DailyAnalyticsTableUpdateCompanionBuilder,
    (
      DailyAnalytic,
      BaseReferences<_$AppDatabase, $DailyAnalyticsTable, DailyAnalytic>
    ),
    DailyAnalytic,
    PrefetchHooks Function()> {
  $$DailyAnalyticsTableTableManager(
      _$AppDatabase db, $DailyAnalyticsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyAnalyticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyAnalyticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyAnalyticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<int> studyMinutes = const Value.absent(),
            Value<int> quizzesCompleted = const Value.absent(),
            Value<int> flashcardsReviewed = const Value.absent(),
            Value<int> aiChatMessages = const Value.absent(),
            Value<int> topicsStudied = const Value.absent(),
            Value<bool> goalMet = const Value.absent(),
            Value<int> streakDay = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyAnalyticsCompanion(
            id: id,
            userId: userId,
            date: date,
            studyMinutes: studyMinutes,
            quizzesCompleted: quizzesCompleted,
            flashcardsReviewed: flashcardsReviewed,
            aiChatMessages: aiChatMessages,
            topicsStudied: topicsStudied,
            goalMet: goalMet,
            streakDay: streakDay,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String date,
            Value<int> studyMinutes = const Value.absent(),
            Value<int> quizzesCompleted = const Value.absent(),
            Value<int> flashcardsReviewed = const Value.absent(),
            Value<int> aiChatMessages = const Value.absent(),
            Value<int> topicsStudied = const Value.absent(),
            Value<bool> goalMet = const Value.absent(),
            Value<int> streakDay = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyAnalyticsCompanion.insert(
            id: id,
            userId: userId,
            date: date,
            studyMinutes: studyMinutes,
            quizzesCompleted: quizzesCompleted,
            flashcardsReviewed: flashcardsReviewed,
            aiChatMessages: aiChatMessages,
            topicsStudied: topicsStudied,
            goalMet: goalMet,
            streakDay: streakDay,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyAnalyticsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyAnalyticsTable,
    DailyAnalytic,
    $$DailyAnalyticsTableFilterComposer,
    $$DailyAnalyticsTableOrderingComposer,
    $$DailyAnalyticsTableAnnotationComposer,
    $$DailyAnalyticsTableCreateCompanionBuilder,
    $$DailyAnalyticsTableUpdateCompanionBuilder,
    (
      DailyAnalytic,
      BaseReferences<_$AppDatabase, $DailyAnalyticsTable, DailyAnalytic>
    ),
    DailyAnalytic,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SemestersTableTableManager get semesters =>
      $$SemestersTableTableManager(_db, _db.semesters);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$TopicsTableTableManager get topics =>
      $$TopicsTableTableManager(_db, _db.topics);
  $$MicroConceptsTableTableManager get microConcepts =>
      $$MicroConceptsTableTableManager(_db, _db.microConcepts);
  $$ConceptDependenciesTableTableManager get conceptDependencies =>
      $$ConceptDependenciesTableTableManager(_db, _db.conceptDependencies);
  $$StudyDnaEntriesTableTableManager get studyDnaEntries =>
      $$StudyDnaEntriesTableTableManager(_db, _db.studyDnaEntries);
  $$LearningTimelineEntriesTableTableManager get learningTimelineEntries =>
      $$LearningTimelineEntriesTableTableManager(
          _db, _db.learningTimelineEntries);
  $$LearningResourcesTableTableManager get learningResources =>
      $$LearningResourcesTableTableManager(_db, _db.learningResources);
  $$ResourceChunksTableTableManager get resourceChunks =>
      $$ResourceChunksTableTableManager(_db, _db.resourceChunks);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$QuizzesTableTableManager get quizzes =>
      $$QuizzesTableTableManager(_db, _db.quizzes);
  $$QuizQuestionsTableTableManager get quizQuestions =>
      $$QuizQuestionsTableTableManager(_db, _db.quizQuestions);
  $$QuizAttemptsTableTableManager get quizAttempts =>
      $$QuizAttemptsTableTableManager(_db, _db.quizAttempts);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$StudySessionsTableTableManager get studySessions =>
      $$StudySessionsTableTableManager(_db, _db.studySessions);
  $$DailyAnalyticsTableTableManager get dailyAnalytics =>
      $$DailyAnalyticsTableTableManager(_db, _db.dailyAnalytics);
}
