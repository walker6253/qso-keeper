// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContactRecordsTable extends ContactRecords
    with TableInfo<$ContactRecordsTable, ContactRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateEpochDayMeta = const VerificationMeta(
    'dateEpochDay',
  );
  @override
  late final GeneratedColumn<int> dateEpochDay = GeneratedColumn<int>(
    'date_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _callsignMeta = const VerificationMeta(
    'callsign',
  );
  @override
  late final GeneratedColumn<String> callsign = GeneratedColumn<String>(
    'callsign',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMHzMeta = const VerificationMeta(
    'frequencyMHz',
  );
  @override
  late final GeneratedColumn<double> frequencyMHz = GeneratedColumn<double>(
    'frequency_m_hz',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _rstSentMeta = const VerificationMeta(
    'rstSent',
  );
  @override
  late final GeneratedColumn<String> rstSent = GeneratedColumn<String>(
    'rst_sent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rstReceivedMeta = const VerificationMeta(
    'rstReceived',
  );
  @override
  late final GeneratedColumn<String> rstReceived = GeneratedColumn<String>(
    'rst_received',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerTxMeta = const VerificationMeta(
    'powerTx',
  );
  @override
  late final GeneratedColumn<String> powerTx = GeneratedColumn<String>(
    'power_tx',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _powerRxMeta = const VerificationMeta(
    'powerRx',
  );
  @override
  late final GeneratedColumn<String> powerRx = GeneratedColumn<String>(
    'power_rx',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dateEpochDay,
    callsign,
    frequencyMHz,
    mode,
    rstSent,
    rstReceived,
    powerTx,
    powerRx,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date_epoch_day')) {
      context.handle(
        _dateEpochDayMeta,
        dateEpochDay.isAcceptableOrUnknown(
          data['date_epoch_day']!,
          _dateEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEpochDayMeta);
    }
    if (data.containsKey('callsign')) {
      context.handle(
        _callsignMeta,
        callsign.isAcceptableOrUnknown(data['callsign']!, _callsignMeta),
      );
    } else if (isInserting) {
      context.missing(_callsignMeta);
    }
    if (data.containsKey('frequency_m_hz')) {
      context.handle(
        _frequencyMHzMeta,
        frequencyMHz.isAcceptableOrUnknown(
          data['frequency_m_hz']!,
          _frequencyMHzMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyMHzMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('rst_sent')) {
      context.handle(
        _rstSentMeta,
        rstSent.isAcceptableOrUnknown(data['rst_sent']!, _rstSentMeta),
      );
    } else if (isInserting) {
      context.missing(_rstSentMeta);
    }
    if (data.containsKey('rst_received')) {
      context.handle(
        _rstReceivedMeta,
        rstReceived.isAcceptableOrUnknown(
          data['rst_received']!,
          _rstReceivedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rstReceivedMeta);
    }
    if (data.containsKey('power_tx')) {
      context.handle(
        _powerTxMeta,
        powerTx.isAcceptableOrUnknown(data['power_tx']!, _powerTxMeta),
      );
    } else if (isInserting) {
      context.missing(_powerTxMeta);
    }
    if (data.containsKey('power_rx')) {
      context.handle(
        _powerRxMeta,
        powerRx.isAcceptableOrUnknown(data['power_rx']!, _powerRxMeta),
      );
    } else if (isInserting) {
      context.missing(_powerRxMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
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
  ContactRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dateEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_epoch_day'],
      )!,
      callsign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}callsign'],
      )!,
      frequencyMHz: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frequency_m_hz'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      rstSent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rst_sent'],
      )!,
      rstReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rst_received'],
      )!,
      powerTx: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power_tx'],
      )!,
      powerRx: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}power_rx'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ContactRecordsTable createAlias(String alias) {
    return $ContactRecordsTable(attachedDatabase, alias);
  }
}

class ContactRecord extends DataClass implements Insertable<ContactRecord> {
  final int id;
  final int dateEpochDay;
  final String callsign;
  final double frequencyMHz;
  final String mode;
  final String rstSent;
  final String rstReceived;
  final String powerTx;
  final String powerRx;
  final String notes;
  final int createdAt;
  const ContactRecord({
    required this.id,
    required this.dateEpochDay,
    required this.callsign,
    required this.frequencyMHz,
    required this.mode,
    required this.rstSent,
    required this.rstReceived,
    required this.powerTx,
    required this.powerRx,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date_epoch_day'] = Variable<int>(dateEpochDay);
    map['callsign'] = Variable<String>(callsign);
    map['frequency_m_hz'] = Variable<double>(frequencyMHz);
    map['mode'] = Variable<String>(mode);
    map['rst_sent'] = Variable<String>(rstSent);
    map['rst_received'] = Variable<String>(rstReceived);
    map['power_tx'] = Variable<String>(powerTx);
    map['power_rx'] = Variable<String>(powerRx);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ContactRecordsCompanion toCompanion(bool nullToAbsent) {
    return ContactRecordsCompanion(
      id: Value(id),
      dateEpochDay: Value(dateEpochDay),
      callsign: Value(callsign),
      frequencyMHz: Value(frequencyMHz),
      mode: Value(mode),
      rstSent: Value(rstSent),
      rstReceived: Value(rstReceived),
      powerTx: Value(powerTx),
      powerRx: Value(powerRx),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory ContactRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactRecord(
      id: serializer.fromJson<int>(json['id']),
      dateEpochDay: serializer.fromJson<int>(json['dateEpochDay']),
      callsign: serializer.fromJson<String>(json['callsign']),
      frequencyMHz: serializer.fromJson<double>(json['frequencyMHz']),
      mode: serializer.fromJson<String>(json['mode']),
      rstSent: serializer.fromJson<String>(json['rstSent']),
      rstReceived: serializer.fromJson<String>(json['rstReceived']),
      powerTx: serializer.fromJson<String>(json['powerTx']),
      powerRx: serializer.fromJson<String>(json['powerRx']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dateEpochDay': serializer.toJson<int>(dateEpochDay),
      'callsign': serializer.toJson<String>(callsign),
      'frequencyMHz': serializer.toJson<double>(frequencyMHz),
      'mode': serializer.toJson<String>(mode),
      'rstSent': serializer.toJson<String>(rstSent),
      'rstReceived': serializer.toJson<String>(rstReceived),
      'powerTx': serializer.toJson<String>(powerTx),
      'powerRx': serializer.toJson<String>(powerRx),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ContactRecord copyWith({
    int? id,
    int? dateEpochDay,
    String? callsign,
    double? frequencyMHz,
    String? mode,
    String? rstSent,
    String? rstReceived,
    String? powerTx,
    String? powerRx,
    String? notes,
    int? createdAt,
  }) => ContactRecord(
    id: id ?? this.id,
    dateEpochDay: dateEpochDay ?? this.dateEpochDay,
    callsign: callsign ?? this.callsign,
    frequencyMHz: frequencyMHz ?? this.frequencyMHz,
    mode: mode ?? this.mode,
    rstSent: rstSent ?? this.rstSent,
    rstReceived: rstReceived ?? this.rstReceived,
    powerTx: powerTx ?? this.powerTx,
    powerRx: powerRx ?? this.powerRx,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  ContactRecord copyWithCompanion(ContactRecordsCompanion data) {
    return ContactRecord(
      id: data.id.present ? data.id.value : this.id,
      dateEpochDay: data.dateEpochDay.present
          ? data.dateEpochDay.value
          : this.dateEpochDay,
      callsign: data.callsign.present ? data.callsign.value : this.callsign,
      frequencyMHz: data.frequencyMHz.present
          ? data.frequencyMHz.value
          : this.frequencyMHz,
      mode: data.mode.present ? data.mode.value : this.mode,
      rstSent: data.rstSent.present ? data.rstSent.value : this.rstSent,
      rstReceived: data.rstReceived.present
          ? data.rstReceived.value
          : this.rstReceived,
      powerTx: data.powerTx.present ? data.powerTx.value : this.powerTx,
      powerRx: data.powerRx.present ? data.powerRx.value : this.powerRx,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactRecord(')
          ..write('id: $id, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('callsign: $callsign, ')
          ..write('frequencyMHz: $frequencyMHz, ')
          ..write('mode: $mode, ')
          ..write('rstSent: $rstSent, ')
          ..write('rstReceived: $rstReceived, ')
          ..write('powerTx: $powerTx, ')
          ..write('powerRx: $powerRx, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dateEpochDay,
    callsign,
    frequencyMHz,
    mode,
    rstSent,
    rstReceived,
    powerTx,
    powerRx,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactRecord &&
          other.id == this.id &&
          other.dateEpochDay == this.dateEpochDay &&
          other.callsign == this.callsign &&
          other.frequencyMHz == this.frequencyMHz &&
          other.mode == this.mode &&
          other.rstSent == this.rstSent &&
          other.rstReceived == this.rstReceived &&
          other.powerTx == this.powerTx &&
          other.powerRx == this.powerRx &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ContactRecordsCompanion extends UpdateCompanion<ContactRecord> {
  final Value<int> id;
  final Value<int> dateEpochDay;
  final Value<String> callsign;
  final Value<double> frequencyMHz;
  final Value<String> mode;
  final Value<String> rstSent;
  final Value<String> rstReceived;
  final Value<String> powerTx;
  final Value<String> powerRx;
  final Value<String> notes;
  final Value<int> createdAt;
  const ContactRecordsCompanion({
    this.id = const Value.absent(),
    this.dateEpochDay = const Value.absent(),
    this.callsign = const Value.absent(),
    this.frequencyMHz = const Value.absent(),
    this.mode = const Value.absent(),
    this.rstSent = const Value.absent(),
    this.rstReceived = const Value.absent(),
    this.powerTx = const Value.absent(),
    this.powerRx = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContactRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int dateEpochDay,
    required String callsign,
    required double frequencyMHz,
    required String mode,
    required String rstSent,
    required String rstReceived,
    required String powerTx,
    required String powerRx,
    required String notes,
    required int createdAt,
  }) : dateEpochDay = Value(dateEpochDay),
       callsign = Value(callsign),
       frequencyMHz = Value(frequencyMHz),
       mode = Value(mode),
       rstSent = Value(rstSent),
       rstReceived = Value(rstReceived),
       powerTx = Value(powerTx),
       powerRx = Value(powerRx),
       notes = Value(notes),
       createdAt = Value(createdAt);
  static Insertable<ContactRecord> custom({
    Expression<int>? id,
    Expression<int>? dateEpochDay,
    Expression<String>? callsign,
    Expression<double>? frequencyMHz,
    Expression<String>? mode,
    Expression<String>? rstSent,
    Expression<String>? rstReceived,
    Expression<String>? powerTx,
    Expression<String>? powerRx,
    Expression<String>? notes,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dateEpochDay != null) 'date_epoch_day': dateEpochDay,
      if (callsign != null) 'callsign': callsign,
      if (frequencyMHz != null) 'frequency_m_hz': frequencyMHz,
      if (mode != null) 'mode': mode,
      if (rstSent != null) 'rst_sent': rstSent,
      if (rstReceived != null) 'rst_received': rstReceived,
      if (powerTx != null) 'power_tx': powerTx,
      if (powerRx != null) 'power_rx': powerRx,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContactRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? dateEpochDay,
    Value<String>? callsign,
    Value<double>? frequencyMHz,
    Value<String>? mode,
    Value<String>? rstSent,
    Value<String>? rstReceived,
    Value<String>? powerTx,
    Value<String>? powerRx,
    Value<String>? notes,
    Value<int>? createdAt,
  }) {
    return ContactRecordsCompanion(
      id: id ?? this.id,
      dateEpochDay: dateEpochDay ?? this.dateEpochDay,
      callsign: callsign ?? this.callsign,
      frequencyMHz: frequencyMHz ?? this.frequencyMHz,
      mode: mode ?? this.mode,
      rstSent: rstSent ?? this.rstSent,
      rstReceived: rstReceived ?? this.rstReceived,
      powerTx: powerTx ?? this.powerTx,
      powerRx: powerRx ?? this.powerRx,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dateEpochDay.present) {
      map['date_epoch_day'] = Variable<int>(dateEpochDay.value);
    }
    if (callsign.present) {
      map['callsign'] = Variable<String>(callsign.value);
    }
    if (frequencyMHz.present) {
      map['frequency_m_hz'] = Variable<double>(frequencyMHz.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (rstSent.present) {
      map['rst_sent'] = Variable<String>(rstSent.value);
    }
    if (rstReceived.present) {
      map['rst_received'] = Variable<String>(rstReceived.value);
    }
    if (powerTx.present) {
      map['power_tx'] = Variable<String>(powerTx.value);
    }
    if (powerRx.present) {
      map['power_rx'] = Variable<String>(powerRx.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactRecordsCompanion(')
          ..write('id: $id, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('callsign: $callsign, ')
          ..write('frequencyMHz: $frequencyMHz, ')
          ..write('mode: $mode, ')
          ..write('rstSent: $rstSent, ')
          ..write('rstReceived: $rstReceived, ')
          ..write('powerTx: $powerTx, ')
          ..write('powerRx: $powerRx, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateEpochDayMeta = const VerificationMeta(
    'dateEpochDay',
  );
  @override
  late final GeneratedColumn<int> dateEpochDay = GeneratedColumn<int>(
    'date_epoch_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gridSquareMeta = const VerificationMeta(
    'gridSquare',
  );
  @override
  late final GeneratedColumn<String> gridSquare = GeneratedColumn<String>(
    'grid_square',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dateEpochDay,
    latitude,
    longitude,
    gridSquare,
    address,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_epoch_day')) {
      context.handle(
        _dateEpochDayMeta,
        dateEpochDay.isAcceptableOrUnknown(
          data['date_epoch_day']!,
          _dateEpochDayMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('grid_square')) {
      context.handle(
        _gridSquareMeta,
        gridSquare.isAcceptableOrUnknown(data['grid_square']!, _gridSquareMeta),
      );
    } else if (isInserting) {
      context.missing(_gridSquareMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateEpochDay};
  @override
  DailyLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLogData(
      dateEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date_epoch_day'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      gridSquare: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grid_square'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLogData extends DataClass implements Insertable<DailyLogData> {
  final int dateEpochDay;
  final double latitude;
  final double longitude;
  final String gridSquare;
  final String address;
  const DailyLogData({
    required this.dateEpochDay,
    required this.latitude,
    required this.longitude,
    required this.gridSquare,
    required this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_epoch_day'] = Variable<int>(dateEpochDay);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['grid_square'] = Variable<String>(gridSquare);
    map['address'] = Variable<String>(address);
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      dateEpochDay: Value(dateEpochDay),
      latitude: Value(latitude),
      longitude: Value(longitude),
      gridSquare: Value(gridSquare),
      address: Value(address),
    );
  }

  factory DailyLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLogData(
      dateEpochDay: serializer.fromJson<int>(json['dateEpochDay']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      gridSquare: serializer.fromJson<String>(json['gridSquare']),
      address: serializer.fromJson<String>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateEpochDay': serializer.toJson<int>(dateEpochDay),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'gridSquare': serializer.toJson<String>(gridSquare),
      'address': serializer.toJson<String>(address),
    };
  }

  DailyLogData copyWith({
    int? dateEpochDay,
    double? latitude,
    double? longitude,
    String? gridSquare,
    String? address,
  }) => DailyLogData(
    dateEpochDay: dateEpochDay ?? this.dateEpochDay,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    gridSquare: gridSquare ?? this.gridSquare,
    address: address ?? this.address,
  );
  DailyLogData copyWithCompanion(DailyLogsCompanion data) {
    return DailyLogData(
      dateEpochDay: data.dateEpochDay.present
          ? data.dateEpochDay.value
          : this.dateEpochDay,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      gridSquare: data.gridSquare.present
          ? data.gridSquare.value
          : this.gridSquare,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogData(')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gridSquare: $gridSquare, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dateEpochDay, latitude, longitude, gridSquare, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLogData &&
          other.dateEpochDay == this.dateEpochDay &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.gridSquare == this.gridSquare &&
          other.address == this.address);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLogData> {
  final Value<int> dateEpochDay;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> gridSquare;
  final Value<String> address;
  const DailyLogsCompanion({
    this.dateEpochDay = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.gridSquare = const Value.absent(),
    this.address = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    this.dateEpochDay = const Value.absent(),
    required double latitude,
    required double longitude,
    required String gridSquare,
    required String address,
  }) : latitude = Value(latitude),
       longitude = Value(longitude),
       gridSquare = Value(gridSquare),
       address = Value(address);
  static Insertable<DailyLogData> custom({
    Expression<int>? dateEpochDay,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? gridSquare,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (dateEpochDay != null) 'date_epoch_day': dateEpochDay,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (gridSquare != null) 'grid_square': gridSquare,
      if (address != null) 'address': address,
    });
  }

  DailyLogsCompanion copyWith({
    Value<int>? dateEpochDay,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? gridSquare,
    Value<String>? address,
  }) {
    return DailyLogsCompanion(
      dateEpochDay: dateEpochDay ?? this.dateEpochDay,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gridSquare: gridSquare ?? this.gridSquare,
      address: address ?? this.address,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateEpochDay.present) {
      map['date_epoch_day'] = Variable<int>(dateEpochDay.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (gridSquare.present) {
      map['grid_square'] = Variable<String>(gridSquare.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('gridSquare: $gridSquare, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactRecordsTable contactRecords = $ContactRecordsTable(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final ContactDao contactDao = ContactDao(this as AppDatabase);
  late final DailyLogDao dailyLogDao = DailyLogDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contactRecords,
    dailyLogs,
  ];
}

typedef $$ContactRecordsTableCreateCompanionBuilder =
    ContactRecordsCompanion Function({
      Value<int> id,
      required int dateEpochDay,
      required String callsign,
      required double frequencyMHz,
      required String mode,
      required String rstSent,
      required String rstReceived,
      required String powerTx,
      required String powerRx,
      required String notes,
      required int createdAt,
    });
typedef $$ContactRecordsTableUpdateCompanionBuilder =
    ContactRecordsCompanion Function({
      Value<int> id,
      Value<int> dateEpochDay,
      Value<String> callsign,
      Value<double> frequencyMHz,
      Value<String> mode,
      Value<String> rstSent,
      Value<String> rstReceived,
      Value<String> powerTx,
      Value<String> powerRx,
      Value<String> notes,
      Value<int> createdAt,
    });

class $$ContactRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactRecordsTable> {
  $$ContactRecordsTableFilterComposer({
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

  ColumnFilters<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get callsign => $composableBuilder(
    column: $table.callsign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frequencyMHz => $composableBuilder(
    column: $table.frequencyMHz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rstSent => $composableBuilder(
    column: $table.rstSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rstReceived => $composableBuilder(
    column: $table.rstReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get powerTx => $composableBuilder(
    column: $table.powerTx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get powerRx => $composableBuilder(
    column: $table.powerRx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactRecordsTable> {
  $$ContactRecordsTableOrderingComposer({
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

  ColumnOrderings<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get callsign => $composableBuilder(
    column: $table.callsign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frequencyMHz => $composableBuilder(
    column: $table.frequencyMHz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rstSent => $composableBuilder(
    column: $table.rstSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rstReceived => $composableBuilder(
    column: $table.rstReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get powerTx => $composableBuilder(
    column: $table.powerTx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get powerRx => $composableBuilder(
    column: $table.powerRx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactRecordsTable> {
  $$ContactRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get callsign =>
      $composableBuilder(column: $table.callsign, builder: (column) => column);

  GeneratedColumn<double> get frequencyMHz => $composableBuilder(
    column: $table.frequencyMHz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get rstSent =>
      $composableBuilder(column: $table.rstSent, builder: (column) => column);

  GeneratedColumn<String> get rstReceived => $composableBuilder(
    column: $table.rstReceived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get powerTx =>
      $composableBuilder(column: $table.powerTx, builder: (column) => column);

  GeneratedColumn<String> get powerRx =>
      $composableBuilder(column: $table.powerRx, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ContactRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactRecordsTable,
          ContactRecord,
          $$ContactRecordsTableFilterComposer,
          $$ContactRecordsTableOrderingComposer,
          $$ContactRecordsTableAnnotationComposer,
          $$ContactRecordsTableCreateCompanionBuilder,
          $$ContactRecordsTableUpdateCompanionBuilder,
          (
            ContactRecord,
            BaseReferences<_$AppDatabase, $ContactRecordsTable, ContactRecord>,
          ),
          ContactRecord,
          PrefetchHooks Function()
        > {
  $$ContactRecordsTableTableManager(
    _$AppDatabase db,
    $ContactRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dateEpochDay = const Value.absent(),
                Value<String> callsign = const Value.absent(),
                Value<double> frequencyMHz = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> rstSent = const Value.absent(),
                Value<String> rstReceived = const Value.absent(),
                Value<String> powerTx = const Value.absent(),
                Value<String> powerRx = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ContactRecordsCompanion(
                id: id,
                dateEpochDay: dateEpochDay,
                callsign: callsign,
                frequencyMHz: frequencyMHz,
                mode: mode,
                rstSent: rstSent,
                rstReceived: rstReceived,
                powerTx: powerTx,
                powerRx: powerRx,
                notes: notes,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int dateEpochDay,
                required String callsign,
                required double frequencyMHz,
                required String mode,
                required String rstSent,
                required String rstReceived,
                required String powerTx,
                required String powerRx,
                required String notes,
                required int createdAt,
              }) => ContactRecordsCompanion.insert(
                id: id,
                dateEpochDay: dateEpochDay,
                callsign: callsign,
                frequencyMHz: frequencyMHz,
                mode: mode,
                rstSent: rstSent,
                rstReceived: rstReceived,
                powerTx: powerTx,
                powerRx: powerRx,
                notes: notes,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactRecordsTable,
      ContactRecord,
      $$ContactRecordsTableFilterComposer,
      $$ContactRecordsTableOrderingComposer,
      $$ContactRecordsTableAnnotationComposer,
      $$ContactRecordsTableCreateCompanionBuilder,
      $$ContactRecordsTableUpdateCompanionBuilder,
      (
        ContactRecord,
        BaseReferences<_$AppDatabase, $ContactRecordsTable, ContactRecord>,
      ),
      ContactRecord,
      PrefetchHooks Function()
    >;
typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> dateEpochDay,
      required double latitude,
      required double longitude,
      required String gridSquare,
      required String address,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<int> dateEpochDay,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> gridSquare,
      Value<String> address,
    });

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gridSquare => $composableBuilder(
    column: $table.gridSquare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gridSquare => $composableBuilder(
    column: $table.gridSquare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get gridSquare => $composableBuilder(
    column: $table.gridSquare,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogsTable,
          DailyLogData,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (
            DailyLogData,
            BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLogData>,
          ),
          DailyLogData,
          PrefetchHooks Function()
        > {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> dateEpochDay = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> gridSquare = const Value.absent(),
                Value<String> address = const Value.absent(),
              }) => DailyLogsCompanion(
                dateEpochDay: dateEpochDay,
                latitude: latitude,
                longitude: longitude,
                gridSquare: gridSquare,
                address: address,
              ),
          createCompanionCallback:
              ({
                Value<int> dateEpochDay = const Value.absent(),
                required double latitude,
                required double longitude,
                required String gridSquare,
                required String address,
              }) => DailyLogsCompanion.insert(
                dateEpochDay: dateEpochDay,
                latitude: latitude,
                longitude: longitude,
                gridSquare: gridSquare,
                address: address,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogsTable,
      DailyLogData,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (
        DailyLogData,
        BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLogData>,
      ),
      DailyLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactRecordsTableTableManager get contactRecords =>
      $$ContactRecordsTableTableManager(_db, _db.contactRecords);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
}
