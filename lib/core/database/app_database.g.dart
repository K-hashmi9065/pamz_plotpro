// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mobileNoMeta = const VerificationMeta(
    'mobileNo',
  );
  @override
  late final GeneratedColumn<String> mobileNo = GeneratedColumn<String>(
    'mobile_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberTypeMeta = const VerificationMeta(
    'memberType',
  );
  @override
  late final GeneratedColumn<String> memberType = GeneratedColumn<String>(
    'member_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedEntityIdMeta = const VerificationMeta(
    'linkedEntityId',
  );
  @override
  late final GeneratedColumn<String> linkedEntityId = GeneratedColumn<String>(
    'linked_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    mobileNo,
    username,
    email,
    passwordHash,
    salt,
    role,
    memberType,
    linkedEntityId,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
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
    }
    if (data.containsKey('mobile_no')) {
      context.handle(
        _mobileNoMeta,
        mobileNo.isAcceptableOrUnknown(data['mobile_no']!, _mobileNoMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('member_type')) {
      context.handle(
        _memberTypeMeta,
        memberType.isAcceptableOrUnknown(data['member_type']!, _memberTypeMeta),
      );
    }
    if (data.containsKey('linked_entity_id')) {
      context.handle(
        _linkedEntityIdMeta,
        linkedEntityId.isAcceptableOrUnknown(
          data['linked_entity_id']!,
          _linkedEntityIdMeta,
        ),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      mobileNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile_no'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      memberType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_type'],
      ),
      linkedEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_entity_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;

  /// Display name of the user.
  final String name;

  /// Mobile number used as login identifier.
  final String mobileNo;

  /// Legacy field kept for compatibility; mirrors mobileNo for new accounts.
  final String username;
  final String email;
  final String passwordHash;

  /// Per-user random salt (hex string) for SHA-256 password hashing.
  final String salt;
  final String role;

  /// Sub-type for member role: 'customerBuyer' | 'investor' | 'landowner'. Null for admin.
  final String? memberType;

  /// FK to Buyers/Investors/Landowners table depending on memberType.
  final String? linkedEntityId;
  final bool isActive;
  final DateTime createdAt;
  const User({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.salt,
    required this.role,
    this.memberType,
    this.linkedEntityId,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['mobile_no'] = Variable<String>(mobileNo);
    map['username'] = Variable<String>(username);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || memberType != null) {
      map['member_type'] = Variable<String>(memberType);
    }
    if (!nullToAbsent || linkedEntityId != null) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      mobileNo: Value(mobileNo),
      username: Value(username),
      email: Value(email),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      role: Value(role),
      memberType: memberType == null && nullToAbsent
          ? const Value.absent()
          : Value(memberType),
      linkedEntityId: linkedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedEntityId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mobileNo: serializer.fromJson<String>(json['mobileNo']),
      username: serializer.fromJson<String>(json['username']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      role: serializer.fromJson<String>(json['role']),
      memberType: serializer.fromJson<String?>(json['memberType']),
      linkedEntityId: serializer.fromJson<String?>(json['linkedEntityId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mobileNo': serializer.toJson<String>(mobileNo),
      'username': serializer.toJson<String>(username),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'role': serializer.toJson<String>(role),
      'memberType': serializer.toJson<String?>(memberType),
      'linkedEntityId': serializer.toJson<String?>(linkedEntityId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? mobileNo,
    String? username,
    String? email,
    String? passwordHash,
    String? salt,
    String? role,
    Value<String?> memberType = const Value.absent(),
    Value<String?> linkedEntityId = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    mobileNo: mobileNo ?? this.mobileNo,
    username: username ?? this.username,
    email: email ?? this.email,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    role: role ?? this.role,
    memberType: memberType.present ? memberType.value : this.memberType,
    linkedEntityId: linkedEntityId.present
        ? linkedEntityId.value
        : this.linkedEntityId,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mobileNo: data.mobileNo.present ? data.mobileNo.value : this.mobileNo,
      username: data.username.present ? data.username.value : this.username,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      role: data.role.present ? data.role.value : this.role,
      memberType: data.memberType.present
          ? data.memberType.value
          : this.memberType,
      linkedEntityId: data.linkedEntityId.present
          ? data.linkedEntityId.value
          : this.linkedEntityId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('role: $role, ')
          ..write('memberType: $memberType, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mobileNo,
    username,
    email,
    passwordHash,
    salt,
    role,
    memberType,
    linkedEntityId,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.mobileNo == this.mobileNo &&
          other.username == this.username &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.role == this.role &&
          other.memberType == this.memberType &&
          other.linkedEntityId == this.linkedEntityId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> mobileNo;
  final Value<String> username;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<String> role;
  final Value<String?> memberType;
  final Value<String?> linkedEntityId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.role = const Value.absent(),
    this.memberType = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.mobileNo = const Value.absent(),
    this.username = const Value.absent(),
    this.email = const Value.absent(),
    required String passwordHash,
    this.salt = const Value.absent(),
    required String role,
    this.memberType = const Value.absent(),
    this.linkedEntityId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       passwordHash = Value(passwordHash),
       role = Value(role);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mobileNo,
    Expression<String>? username,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<String>? role,
    Expression<String>? memberType,
    Expression<String>? linkedEntityId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mobileNo != null) 'mobile_no': mobileNo,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (role != null) 'role': role,
      if (memberType != null) 'member_type': memberType,
      if (linkedEntityId != null) 'linked_entity_id': linkedEntityId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? mobileNo,
    Value<String>? username,
    Value<String>? email,
    Value<String>? passwordHash,
    Value<String>? salt,
    Value<String>? role,
    Value<String?>? memberType,
    Value<String?>? linkedEntityId,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      role: role ?? this.role,
      memberType: memberType ?? this.memberType,
      linkedEntityId: linkedEntityId ?? this.linkedEntityId,
      isActive: isActive ?? this.isActive,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mobileNo.present) {
      map['mobile_no'] = Variable<String>(mobileNo.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (memberType.present) {
      map['member_type'] = Variable<String>(memberType.value);
    }
    if (linkedEntityId.present) {
      map['linked_entity_id'] = Variable<String>(linkedEntityId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mobileNo: $mobileNo, ')
          ..write('username: $username, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('role: $role, ')
          ..write('memberType: $memberType, ')
          ..write('linkedEntityId: $linkedEntityId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LandownersTable extends Landowners
    with TableInfo<$LandownersTable, Landowner> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LandownersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    address,
    pan,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'landowners';
  @override
  VerificationContext validateIntegrity(
    Insertable<Landowner> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Landowner map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Landowner(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LandownersTable createAlias(String alias) {
    return $LandownersTable(attachedDatabase, alias);
  }
}

class Landowner extends DataClass implements Insertable<Landowner> {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? pan;
  final DateTime createdAt;
  const Landowner({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.pan,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LandownersCompanion toCompanion(bool nullToAbsent) {
    return LandownersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      createdAt: Value(createdAt),
    );
  }

  factory Landowner.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Landowner(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      pan: serializer.fromJson<String?>(json['pan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'pan': serializer.toJson<String?>(pan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Landowner copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    DateTime? createdAt,
  }) => Landowner(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    pan: pan.present ? pan.value : this.pan,
    createdAt: createdAt ?? this.createdAt,
  );
  Landowner copyWithCompanion(LandownersCompanion data) {
    return Landowner(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      pan: data.pan.present ? data.pan.value : this.pan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Landowner(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('pan: $pan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, address, pan, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Landowner &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.pan == this.pan &&
          other.createdAt == this.createdAt);
}

class LandownersCompanion extends UpdateCompanion<Landowner> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> pan;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LandownersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.pan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LandownersCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.pan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone);
  static Insertable<Landowner> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? pan,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (pan != null) 'pan': pan,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LandownersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? pan,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return LandownersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      pan: pan ?? this.pan,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
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
    return (StringBuffer('LandownersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('pan: $pan, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _landownerIdMeta = const VerificationMeta(
    'landownerId',
  );
  @override
  late final GeneratedColumn<String> landownerId = GeneratedColumn<String>(
    'landowner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES landowners (id)',
    ),
  );
  static const VerificationMeta _landAreaSqFtMeta = const VerificationMeta(
    'landAreaSqFt',
  );
  @override
  late final GeneratedColumn<double> landAreaSqFt = GeneratedColumn<double>(
    'land_area_sq_ft',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _measurementUnitMeta = const VerificationMeta(
    'measurementUnit',
  );
  @override
  late final GeneratedColumn<String> measurementUnit = GeneratedColumn<String>(
    'measurement_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Kattha'),
  );
  static const VerificationMeta _displayAreaMeta = const VerificationMeta(
    'displayArea',
  );
  @override
  late final GeneratedColumn<double> displayArea = GeneratedColumn<double>(
    'display_area',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kattaValueMeta = const VerificationMeta(
    'kattaValue',
  );
  @override
  late final GeneratedColumn<double> kattaValue = GeneratedColumn<double>(
    'katta_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dhurValueMeta = const VerificationMeta(
    'dhurValue',
  );
  @override
  late final GeneratedColumn<double> dhurValue = GeneratedColumn<double>(
    'dhur_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthFtMeta = const VerificationMeta(
    'lengthFt',
  );
  @override
  late final GeneratedColumn<double> lengthFt = GeneratedColumn<double>(
    'length_ft',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthInMeta = const VerificationMeta(
    'lengthIn',
  );
  @override
  late final GeneratedColumn<double> lengthIn = GeneratedColumn<double>(
    'length_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breadthFtMeta = const VerificationMeta(
    'breadthFt',
  );
  @override
  late final GeneratedColumn<double> breadthFt = GeneratedColumn<double>(
    'breadth_ft',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breadthInMeta = const VerificationMeta(
    'breadthIn',
  );
  @override
  late final GeneratedColumn<double> breadthIn = GeneratedColumn<double>(
    'breadth_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _actualCostMeta = const VerificationMeta(
    'actualCost',
  );
  @override
  late final GeneratedColumn<double> actualCost = GeneratedColumn<double>(
    'actual_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    description,
    location,
    status,
    landownerId,
    landAreaSqFt,
    measurementUnit,
    displayArea,
    kattaValue,
    dhurValue,
    lengthFt,
    lengthIn,
    breadthFt,
    breadthIn,
    purchasePrice,
    actualCost,
    createdAt,
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
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('landowner_id')) {
      context.handle(
        _landownerIdMeta,
        landownerId.isAcceptableOrUnknown(
          data['landowner_id']!,
          _landownerIdMeta,
        ),
      );
    }
    if (data.containsKey('land_area_sq_ft')) {
      context.handle(
        _landAreaSqFtMeta,
        landAreaSqFt.isAcceptableOrUnknown(
          data['land_area_sq_ft']!,
          _landAreaSqFtMeta,
        ),
      );
    }
    if (data.containsKey('measurement_unit')) {
      context.handle(
        _measurementUnitMeta,
        measurementUnit.isAcceptableOrUnknown(
          data['measurement_unit']!,
          _measurementUnitMeta,
        ),
      );
    }
    if (data.containsKey('display_area')) {
      context.handle(
        _displayAreaMeta,
        displayArea.isAcceptableOrUnknown(
          data['display_area']!,
          _displayAreaMeta,
        ),
      );
    }
    if (data.containsKey('katta_value')) {
      context.handle(
        _kattaValueMeta,
        kattaValue.isAcceptableOrUnknown(data['katta_value']!, _kattaValueMeta),
      );
    }
    if (data.containsKey('dhur_value')) {
      context.handle(
        _dhurValueMeta,
        dhurValue.isAcceptableOrUnknown(data['dhur_value']!, _dhurValueMeta),
      );
    }
    if (data.containsKey('length_ft')) {
      context.handle(
        _lengthFtMeta,
        lengthFt.isAcceptableOrUnknown(data['length_ft']!, _lengthFtMeta),
      );
    }
    if (data.containsKey('length_in')) {
      context.handle(
        _lengthInMeta,
        lengthIn.isAcceptableOrUnknown(data['length_in']!, _lengthInMeta),
      );
    }
    if (data.containsKey('breadth_ft')) {
      context.handle(
        _breadthFtMeta,
        breadthFt.isAcceptableOrUnknown(data['breadth_ft']!, _breadthFtMeta),
      );
    }
    if (data.containsKey('breadth_in')) {
      context.handle(
        _breadthInMeta,
        breadthIn.isAcceptableOrUnknown(data['breadth_in']!, _breadthInMeta),
      );
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('actual_cost')) {
      context.handle(
        _actualCostMeta,
        actualCost.isAcceptableOrUnknown(data['actual_cost']!, _actualCostMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
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
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      landownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}landowner_id'],
      ),
      landAreaSqFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}land_area_sq_ft'],
      )!,
      measurementUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_unit'],
      )!,
      displayArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}display_area'],
      ),
      kattaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}katta_value'],
      ),
      dhurValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dhur_value'],
      ),
      lengthFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_ft'],
      ),
      lengthIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_in'],
      ),
      breadthFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breadth_ft'],
      ),
      breadthIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breadth_in'],
      ),
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      )!,
      actualCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}actual_cost'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final String code;
  final String name;
  final String? description;
  final String location;
  final String status;
  final String? landownerId;
  final double landAreaSqFt;
  final String measurementUnit;
  final double? displayArea;
  final double? kattaValue;
  final double? dhurValue;
  final double? lengthFt;
  final double? lengthIn;
  final double? breadthFt;
  final double? breadthIn;
  final double purchasePrice;
  final double actualCost;
  final DateTime createdAt;
  const Project({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.location,
    required this.status,
    this.landownerId,
    required this.landAreaSqFt,
    required this.measurementUnit,
    this.displayArea,
    this.kattaValue,
    this.dhurValue,
    this.lengthFt,
    this.lengthIn,
    this.breadthFt,
    this.breadthIn,
    required this.purchasePrice,
    required this.actualCost,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['location'] = Variable<String>(location);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || landownerId != null) {
      map['landowner_id'] = Variable<String>(landownerId);
    }
    map['land_area_sq_ft'] = Variable<double>(landAreaSqFt);
    map['measurement_unit'] = Variable<String>(measurementUnit);
    if (!nullToAbsent || displayArea != null) {
      map['display_area'] = Variable<double>(displayArea);
    }
    if (!nullToAbsent || kattaValue != null) {
      map['katta_value'] = Variable<double>(kattaValue);
    }
    if (!nullToAbsent || dhurValue != null) {
      map['dhur_value'] = Variable<double>(dhurValue);
    }
    if (!nullToAbsent || lengthFt != null) {
      map['length_ft'] = Variable<double>(lengthFt);
    }
    if (!nullToAbsent || lengthIn != null) {
      map['length_in'] = Variable<double>(lengthIn);
    }
    if (!nullToAbsent || breadthFt != null) {
      map['breadth_ft'] = Variable<double>(breadthFt);
    }
    if (!nullToAbsent || breadthIn != null) {
      map['breadth_in'] = Variable<double>(breadthIn);
    }
    map['purchase_price'] = Variable<double>(purchasePrice);
    map['actual_cost'] = Variable<double>(actualCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      location: Value(location),
      status: Value(status),
      landownerId: landownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(landownerId),
      landAreaSqFt: Value(landAreaSqFt),
      measurementUnit: Value(measurementUnit),
      displayArea: displayArea == null && nullToAbsent
          ? const Value.absent()
          : Value(displayArea),
      kattaValue: kattaValue == null && nullToAbsent
          ? const Value.absent()
          : Value(kattaValue),
      dhurValue: dhurValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dhurValue),
      lengthFt: lengthFt == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthFt),
      lengthIn: lengthIn == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthIn),
      breadthFt: breadthFt == null && nullToAbsent
          ? const Value.absent()
          : Value(breadthFt),
      breadthIn: breadthIn == null && nullToAbsent
          ? const Value.absent()
          : Value(breadthIn),
      purchasePrice: Value(purchasePrice),
      actualCost: Value(actualCost),
      createdAt: Value(createdAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      location: serializer.fromJson<String>(json['location']),
      status: serializer.fromJson<String>(json['status']),
      landownerId: serializer.fromJson<String?>(json['landownerId']),
      landAreaSqFt: serializer.fromJson<double>(json['landAreaSqFt']),
      measurementUnit: serializer.fromJson<String>(json['measurementUnit']),
      displayArea: serializer.fromJson<double?>(json['displayArea']),
      kattaValue: serializer.fromJson<double?>(json['kattaValue']),
      dhurValue: serializer.fromJson<double?>(json['dhurValue']),
      lengthFt: serializer.fromJson<double?>(json['lengthFt']),
      lengthIn: serializer.fromJson<double?>(json['lengthIn']),
      breadthFt: serializer.fromJson<double?>(json['breadthFt']),
      breadthIn: serializer.fromJson<double?>(json['breadthIn']),
      purchasePrice: serializer.fromJson<double>(json['purchasePrice']),
      actualCost: serializer.fromJson<double>(json['actualCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'location': serializer.toJson<String>(location),
      'status': serializer.toJson<String>(status),
      'landownerId': serializer.toJson<String?>(landownerId),
      'landAreaSqFt': serializer.toJson<double>(landAreaSqFt),
      'measurementUnit': serializer.toJson<String>(measurementUnit),
      'displayArea': serializer.toJson<double?>(displayArea),
      'kattaValue': serializer.toJson<double?>(kattaValue),
      'dhurValue': serializer.toJson<double?>(dhurValue),
      'lengthFt': serializer.toJson<double?>(lengthFt),
      'lengthIn': serializer.toJson<double?>(lengthIn),
      'breadthFt': serializer.toJson<double?>(breadthFt),
      'breadthIn': serializer.toJson<double?>(breadthIn),
      'purchasePrice': serializer.toJson<double>(purchasePrice),
      'actualCost': serializer.toJson<double>(actualCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Project copyWith({
    String? id,
    String? code,
    String? name,
    Value<String?> description = const Value.absent(),
    String? location,
    String? status,
    Value<String?> landownerId = const Value.absent(),
    double? landAreaSqFt,
    String? measurementUnit,
    Value<double?> displayArea = const Value.absent(),
    Value<double?> kattaValue = const Value.absent(),
    Value<double?> dhurValue = const Value.absent(),
    Value<double?> lengthFt = const Value.absent(),
    Value<double?> lengthIn = const Value.absent(),
    Value<double?> breadthFt = const Value.absent(),
    Value<double?> breadthIn = const Value.absent(),
    double? purchasePrice,
    double? actualCost,
    DateTime? createdAt,
  }) => Project(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    location: location ?? this.location,
    status: status ?? this.status,
    landownerId: landownerId.present ? landownerId.value : this.landownerId,
    landAreaSqFt: landAreaSqFt ?? this.landAreaSqFt,
    measurementUnit: measurementUnit ?? this.measurementUnit,
    displayArea: displayArea.present ? displayArea.value : this.displayArea,
    kattaValue: kattaValue.present ? kattaValue.value : this.kattaValue,
    dhurValue: dhurValue.present ? dhurValue.value : this.dhurValue,
    lengthFt: lengthFt.present ? lengthFt.value : this.lengthFt,
    lengthIn: lengthIn.present ? lengthIn.value : this.lengthIn,
    breadthFt: breadthFt.present ? breadthFt.value : this.breadthFt,
    breadthIn: breadthIn.present ? breadthIn.value : this.breadthIn,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    actualCost: actualCost ?? this.actualCost,
    createdAt: createdAt ?? this.createdAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      location: data.location.present ? data.location.value : this.location,
      status: data.status.present ? data.status.value : this.status,
      landownerId: data.landownerId.present
          ? data.landownerId.value
          : this.landownerId,
      landAreaSqFt: data.landAreaSqFt.present
          ? data.landAreaSqFt.value
          : this.landAreaSqFt,
      measurementUnit: data.measurementUnit.present
          ? data.measurementUnit.value
          : this.measurementUnit,
      displayArea: data.displayArea.present
          ? data.displayArea.value
          : this.displayArea,
      kattaValue: data.kattaValue.present
          ? data.kattaValue.value
          : this.kattaValue,
      dhurValue: data.dhurValue.present ? data.dhurValue.value : this.dhurValue,
      lengthFt: data.lengthFt.present ? data.lengthFt.value : this.lengthFt,
      lengthIn: data.lengthIn.present ? data.lengthIn.value : this.lengthIn,
      breadthFt: data.breadthFt.present ? data.breadthFt.value : this.breadthFt,
      breadthIn: data.breadthIn.present ? data.breadthIn.value : this.breadthIn,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      actualCost: data.actualCost.present
          ? data.actualCost.value
          : this.actualCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('landownerId: $landownerId, ')
          ..write('landAreaSqFt: $landAreaSqFt, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('displayArea: $displayArea, ')
          ..write('kattaValue: $kattaValue, ')
          ..write('dhurValue: $dhurValue, ')
          ..write('lengthFt: $lengthFt, ')
          ..write('lengthIn: $lengthIn, ')
          ..write('breadthFt: $breadthFt, ')
          ..write('breadthIn: $breadthIn, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('actualCost: $actualCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    description,
    location,
    status,
    landownerId,
    landAreaSqFt,
    measurementUnit,
    displayArea,
    kattaValue,
    dhurValue,
    lengthFt,
    lengthIn,
    breadthFt,
    breadthIn,
    purchasePrice,
    actualCost,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.description == this.description &&
          other.location == this.location &&
          other.status == this.status &&
          other.landownerId == this.landownerId &&
          other.landAreaSqFt == this.landAreaSqFt &&
          other.measurementUnit == this.measurementUnit &&
          other.displayArea == this.displayArea &&
          other.kattaValue == this.kattaValue &&
          other.dhurValue == this.dhurValue &&
          other.lengthFt == this.lengthFt &&
          other.lengthIn == this.lengthIn &&
          other.breadthFt == this.breadthFt &&
          other.breadthIn == this.breadthIn &&
          other.purchasePrice == this.purchasePrice &&
          other.actualCost == this.actualCost &&
          other.createdAt == this.createdAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> location;
  final Value<String> status;
  final Value<String?> landownerId;
  final Value<double> landAreaSqFt;
  final Value<String> measurementUnit;
  final Value<double?> displayArea;
  final Value<double?> kattaValue;
  final Value<double?> dhurValue;
  final Value<double?> lengthFt;
  final Value<double?> lengthIn;
  final Value<double?> breadthFt;
  final Value<double?> breadthIn;
  final Value<double> purchasePrice;
  final Value<double> actualCost;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.location = const Value.absent(),
    this.status = const Value.absent(),
    this.landownerId = const Value.absent(),
    this.landAreaSqFt = const Value.absent(),
    this.measurementUnit = const Value.absent(),
    this.displayArea = const Value.absent(),
    this.kattaValue = const Value.absent(),
    this.dhurValue = const Value.absent(),
    this.lengthFt = const Value.absent(),
    this.lengthIn = const Value.absent(),
    this.breadthFt = const Value.absent(),
    this.breadthIn = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.actualCost = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.description = const Value.absent(),
    required String location,
    required String status,
    this.landownerId = const Value.absent(),
    this.landAreaSqFt = const Value.absent(),
    this.measurementUnit = const Value.absent(),
    this.displayArea = const Value.absent(),
    this.kattaValue = const Value.absent(),
    this.dhurValue = const Value.absent(),
    this.lengthFt = const Value.absent(),
    this.lengthIn = const Value.absent(),
    this.breadthFt = const Value.absent(),
    this.breadthIn = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.actualCost = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       location = Value(location),
       status = Value(status);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? location,
    Expression<String>? status,
    Expression<String>? landownerId,
    Expression<double>? landAreaSqFt,
    Expression<String>? measurementUnit,
    Expression<double>? displayArea,
    Expression<double>? kattaValue,
    Expression<double>? dhurValue,
    Expression<double>? lengthFt,
    Expression<double>? lengthIn,
    Expression<double>? breadthFt,
    Expression<double>? breadthIn,
    Expression<double>? purchasePrice,
    Expression<double>? actualCost,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
      if (landownerId != null) 'landowner_id': landownerId,
      if (landAreaSqFt != null) 'land_area_sq_ft': landAreaSqFt,
      if (measurementUnit != null) 'measurement_unit': measurementUnit,
      if (displayArea != null) 'display_area': displayArea,
      if (kattaValue != null) 'katta_value': kattaValue,
      if (dhurValue != null) 'dhur_value': dhurValue,
      if (lengthFt != null) 'length_ft': lengthFt,
      if (lengthIn != null) 'length_in': lengthIn,
      if (breadthFt != null) 'breadth_ft': breadthFt,
      if (breadthIn != null) 'breadth_in': breadthIn,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (actualCost != null) 'actual_cost': actualCost,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? location,
    Value<String>? status,
    Value<String?>? landownerId,
    Value<double>? landAreaSqFt,
    Value<String>? measurementUnit,
    Value<double?>? displayArea,
    Value<double?>? kattaValue,
    Value<double?>? dhurValue,
    Value<double?>? lengthFt,
    Value<double?>? lengthIn,
    Value<double?>? breadthFt,
    Value<double?>? breadthIn,
    Value<double>? purchasePrice,
    Value<double>? actualCost,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      landownerId: landownerId ?? this.landownerId,
      landAreaSqFt: landAreaSqFt ?? this.landAreaSqFt,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      displayArea: displayArea ?? this.displayArea,
      kattaValue: kattaValue ?? this.kattaValue,
      dhurValue: dhurValue ?? this.dhurValue,
      lengthFt: lengthFt ?? this.lengthFt,
      lengthIn: lengthIn ?? this.lengthIn,
      breadthFt: breadthFt ?? this.breadthFt,
      breadthIn: breadthIn ?? this.breadthIn,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      actualCost: actualCost ?? this.actualCost,
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (landownerId.present) {
      map['landowner_id'] = Variable<String>(landownerId.value);
    }
    if (landAreaSqFt.present) {
      map['land_area_sq_ft'] = Variable<double>(landAreaSqFt.value);
    }
    if (measurementUnit.present) {
      map['measurement_unit'] = Variable<String>(measurementUnit.value);
    }
    if (displayArea.present) {
      map['display_area'] = Variable<double>(displayArea.value);
    }
    if (kattaValue.present) {
      map['katta_value'] = Variable<double>(kattaValue.value);
    }
    if (dhurValue.present) {
      map['dhur_value'] = Variable<double>(dhurValue.value);
    }
    if (lengthFt.present) {
      map['length_ft'] = Variable<double>(lengthFt.value);
    }
    if (lengthIn.present) {
      map['length_in'] = Variable<double>(lengthIn.value);
    }
    if (breadthFt.present) {
      map['breadth_ft'] = Variable<double>(breadthFt.value);
    }
    if (breadthIn.present) {
      map['breadth_in'] = Variable<double>(breadthIn.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (actualCost.present) {
      map['actual_cost'] = Variable<double>(actualCost.value);
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
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('landownerId: $landownerId, ')
          ..write('landAreaSqFt: $landAreaSqFt, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('displayArea: $displayArea, ')
          ..write('kattaValue: $kattaValue, ')
          ..write('dhurValue: $dhurValue, ')
          ..write('lengthFt: $lengthFt, ')
          ..write('lengthIn: $lengthIn, ')
          ..write('breadthFt: $breadthFt, ')
          ..write('breadthIn: $breadthIn, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('actualCost: $actualCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseAgreementsTable extends PurchaseAgreements
    with TableInfo<$PurchaseAgreementsTable, PurchaseAgreement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseAgreementsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _landownerIdMeta = const VerificationMeta(
    'landownerId',
  );
  @override
  late final GeneratedColumn<String> landownerId = GeneratedColumn<String>(
    'landowner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES landowners (id)',
    ),
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agreementDateMeta = const VerificationMeta(
    'agreementDate',
  );
  @override
  late final GeneratedColumn<DateTime> agreementDate =
      GeneratedColumn<DateTime>(
        'agreement_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    landownerId,
    totalPrice,
    agreementDate,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_agreements';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseAgreement> instance, {
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
    if (data.containsKey('landowner_id')) {
      context.handle(
        _landownerIdMeta,
        landownerId.isAcceptableOrUnknown(
          data['landowner_id']!,
          _landownerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_landownerIdMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('agreement_date')) {
      context.handle(
        _agreementDateMeta,
        agreementDate.isAcceptableOrUnknown(
          data['agreement_date']!,
          _agreementDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_agreementDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseAgreement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseAgreement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      landownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}landowner_id'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
      agreementDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}agreement_date'],
      )!,
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
  $PurchaseAgreementsTable createAlias(String alias) {
    return $PurchaseAgreementsTable(attachedDatabase, alias);
  }
}

class PurchaseAgreement extends DataClass
    implements Insertable<PurchaseAgreement> {
  final String id;
  final String projectId;
  final String landownerId;
  final double totalPrice;
  final DateTime agreementDate;
  final String status;
  final DateTime createdAt;
  const PurchaseAgreement({
    required this.id,
    required this.projectId,
    required this.landownerId,
    required this.totalPrice,
    required this.agreementDate,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['landowner_id'] = Variable<String>(landownerId);
    map['total_price'] = Variable<double>(totalPrice);
    map['agreement_date'] = Variable<DateTime>(agreementDate);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseAgreementsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseAgreementsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      landownerId: Value(landownerId),
      totalPrice: Value(totalPrice),
      agreementDate: Value(agreementDate),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseAgreement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseAgreement(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      landownerId: serializer.fromJson<String>(json['landownerId']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      agreementDate: serializer.fromJson<DateTime>(json['agreementDate']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'landownerId': serializer.toJson<String>(landownerId),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'agreementDate': serializer.toJson<DateTime>(agreementDate),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseAgreement copyWith({
    String? id,
    String? projectId,
    String? landownerId,
    double? totalPrice,
    DateTime? agreementDate,
    String? status,
    DateTime? createdAt,
  }) => PurchaseAgreement(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    landownerId: landownerId ?? this.landownerId,
    totalPrice: totalPrice ?? this.totalPrice,
    agreementDate: agreementDate ?? this.agreementDate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  PurchaseAgreement copyWithCompanion(PurchaseAgreementsCompanion data) {
    return PurchaseAgreement(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      landownerId: data.landownerId.present
          ? data.landownerId.value
          : this.landownerId,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      agreementDate: data.agreementDate.present
          ? data.agreementDate.value
          : this.agreementDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseAgreement(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('landownerId: $landownerId, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('agreementDate: $agreementDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    landownerId,
    totalPrice,
    agreementDate,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseAgreement &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.landownerId == this.landownerId &&
          other.totalPrice == this.totalPrice &&
          other.agreementDate == this.agreementDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class PurchaseAgreementsCompanion extends UpdateCompanion<PurchaseAgreement> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> landownerId;
  final Value<double> totalPrice;
  final Value<DateTime> agreementDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseAgreementsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.landownerId = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.agreementDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseAgreementsCompanion.insert({
    required String id,
    required String projectId,
    required String landownerId,
    required double totalPrice,
    required DateTime agreementDate,
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       landownerId = Value(landownerId),
       totalPrice = Value(totalPrice),
       agreementDate = Value(agreementDate),
       status = Value(status);
  static Insertable<PurchaseAgreement> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? landownerId,
    Expression<double>? totalPrice,
    Expression<DateTime>? agreementDate,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (landownerId != null) 'landowner_id': landownerId,
      if (totalPrice != null) 'total_price': totalPrice,
      if (agreementDate != null) 'agreement_date': agreementDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseAgreementsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? landownerId,
    Value<double>? totalPrice,
    Value<DateTime>? agreementDate,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PurchaseAgreementsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      landownerId: landownerId ?? this.landownerId,
      totalPrice: totalPrice ?? this.totalPrice,
      agreementDate: agreementDate ?? this.agreementDate,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (landownerId.present) {
      map['landowner_id'] = Variable<String>(landownerId.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (agreementDate.present) {
      map['agreement_date'] = Variable<DateTime>(agreementDate.value);
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
    return (StringBuffer('PurchaseAgreementsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('landownerId: $landownerId, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('agreementDate: $agreementDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestorsTable extends Investors
    with TableInfo<$InvestorsTable, Investor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    pan,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Investor> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Investor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Investor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvestorsTable createAlias(String alias) {
    return $InvestorsTable(attachedDatabase, alias);
  }
}

class Investor extends DataClass implements Insertable<Investor> {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? pan;
  final DateTime createdAt;
  const Investor({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.pan,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvestorsCompanion toCompanion(bool nullToAbsent) {
    return InvestorsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      createdAt: Value(createdAt),
    );
  }

  factory Investor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Investor(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      pan: serializer.fromJson<String?>(json['pan']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'pan': serializer.toJson<String?>(pan),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Investor copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> email = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    DateTime? createdAt,
  }) => Investor(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email.present ? email.value : this.email,
    pan: pan.present ? pan.value : this.pan,
    createdAt: createdAt ?? this.createdAt,
  );
  Investor copyWithCompanion(InvestorsCompanion data) {
    return Investor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      pan: data.pan.present ? data.pan.value : this.pan,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Investor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pan: $pan, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, email, pan, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Investor &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.pan == this.pan &&
          other.createdAt == this.createdAt);
}

class InvestorsCompanion extends UpdateCompanion<Investor> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String?> pan;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InvestorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.pan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestorsCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.email = const Value.absent(),
    this.pan = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone);
  static Insertable<Investor> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? pan,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (pan != null) 'pan': pan,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestorsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? email,
    Value<String?>? pan,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InvestorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pan: pan ?? this.pan,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
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
    return (StringBuffer('InvestorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pan: $pan, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectInvestorsTable extends ProjectInvestors
    with TableInfo<$ProjectInvestorsTable, ProjectInvestor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectInvestorsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _investorIdMeta = const VerificationMeta(
    'investorId',
  );
  @override
  late final GeneratedColumn<String> investorId = GeneratedColumn<String>(
    'investor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investors (id)',
    ),
  );
  static const VerificationMeta _investedAmountMeta = const VerificationMeta(
    'investedAmount',
  );
  @override
  late final GeneratedColumn<double> investedAmount = GeneratedColumn<double>(
    'invested_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownershipPercentMeta = const VerificationMeta(
    'ownershipPercent',
  );
  @override
  late final GeneratedColumn<double> ownershipPercent = GeneratedColumn<double>(
    'ownership_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownershipMethodMeta = const VerificationMeta(
    'ownershipMethod',
  );
  @override
  late final GeneratedColumn<String> ownershipMethod = GeneratedColumn<String>(
    'ownership_method',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    investorId,
    investedAmount,
    ownershipPercent,
    ownershipMethod,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_investors';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectInvestor> instance, {
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
    if (data.containsKey('investor_id')) {
      context.handle(
        _investorIdMeta,
        investorId.isAcceptableOrUnknown(data['investor_id']!, _investorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_investorIdMeta);
    }
    if (data.containsKey('invested_amount')) {
      context.handle(
        _investedAmountMeta,
        investedAmount.isAcceptableOrUnknown(
          data['invested_amount']!,
          _investedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_investedAmountMeta);
    }
    if (data.containsKey('ownership_percent')) {
      context.handle(
        _ownershipPercentMeta,
        ownershipPercent.isAcceptableOrUnknown(
          data['ownership_percent']!,
          _ownershipPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownershipPercentMeta);
    }
    if (data.containsKey('ownership_method')) {
      context.handle(
        _ownershipMethodMeta,
        ownershipMethod.isAcceptableOrUnknown(
          data['ownership_method']!,
          _ownershipMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownershipMethodMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectInvestor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectInvestor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      investorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investor_id'],
      )!,
      investedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}invested_amount'],
      )!,
      ownershipPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ownership_percent'],
      )!,
      ownershipMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_method'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProjectInvestorsTable createAlias(String alias) {
    return $ProjectInvestorsTable(attachedDatabase, alias);
  }
}

class ProjectInvestor extends DataClass implements Insertable<ProjectInvestor> {
  final String id;
  final String projectId;
  final String investorId;
  final double investedAmount;
  final double ownershipPercent;
  final String ownershipMethod;
  final DateTime createdAt;
  const ProjectInvestor({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.investedAmount,
    required this.ownershipPercent,
    required this.ownershipMethod,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['investor_id'] = Variable<String>(investorId);
    map['invested_amount'] = Variable<double>(investedAmount);
    map['ownership_percent'] = Variable<double>(ownershipPercent);
    map['ownership_method'] = Variable<String>(ownershipMethod);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProjectInvestorsCompanion toCompanion(bool nullToAbsent) {
    return ProjectInvestorsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      investorId: Value(investorId),
      investedAmount: Value(investedAmount),
      ownershipPercent: Value(ownershipPercent),
      ownershipMethod: Value(ownershipMethod),
      createdAt: Value(createdAt),
    );
  }

  factory ProjectInvestor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectInvestor(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      investorId: serializer.fromJson<String>(json['investorId']),
      investedAmount: serializer.fromJson<double>(json['investedAmount']),
      ownershipPercent: serializer.fromJson<double>(json['ownershipPercent']),
      ownershipMethod: serializer.fromJson<String>(json['ownershipMethod']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'investorId': serializer.toJson<String>(investorId),
      'investedAmount': serializer.toJson<double>(investedAmount),
      'ownershipPercent': serializer.toJson<double>(ownershipPercent),
      'ownershipMethod': serializer.toJson<String>(ownershipMethod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProjectInvestor copyWith({
    String? id,
    String? projectId,
    String? investorId,
    double? investedAmount,
    double? ownershipPercent,
    String? ownershipMethod,
    DateTime? createdAt,
  }) => ProjectInvestor(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    investorId: investorId ?? this.investorId,
    investedAmount: investedAmount ?? this.investedAmount,
    ownershipPercent: ownershipPercent ?? this.ownershipPercent,
    ownershipMethod: ownershipMethod ?? this.ownershipMethod,
    createdAt: createdAt ?? this.createdAt,
  );
  ProjectInvestor copyWithCompanion(ProjectInvestorsCompanion data) {
    return ProjectInvestor(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      investorId: data.investorId.present
          ? data.investorId.value
          : this.investorId,
      investedAmount: data.investedAmount.present
          ? data.investedAmount.value
          : this.investedAmount,
      ownershipPercent: data.ownershipPercent.present
          ? data.ownershipPercent.value
          : this.ownershipPercent,
      ownershipMethod: data.ownershipMethod.present
          ? data.ownershipMethod.value
          : this.ownershipMethod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectInvestor(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('investorId: $investorId, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('ownershipPercent: $ownershipPercent, ')
          ..write('ownershipMethod: $ownershipMethod, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    investorId,
    investedAmount,
    ownershipPercent,
    ownershipMethod,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectInvestor &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.investorId == this.investorId &&
          other.investedAmount == this.investedAmount &&
          other.ownershipPercent == this.ownershipPercent &&
          other.ownershipMethod == this.ownershipMethod &&
          other.createdAt == this.createdAt);
}

class ProjectInvestorsCompanion extends UpdateCompanion<ProjectInvestor> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> investorId;
  final Value<double> investedAmount;
  final Value<double> ownershipPercent;
  final Value<String> ownershipMethod;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProjectInvestorsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.investorId = const Value.absent(),
    this.investedAmount = const Value.absent(),
    this.ownershipPercent = const Value.absent(),
    this.ownershipMethod = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectInvestorsCompanion.insert({
    required String id,
    required String projectId,
    required String investorId,
    required double investedAmount,
    required double ownershipPercent,
    required String ownershipMethod,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       investorId = Value(investorId),
       investedAmount = Value(investedAmount),
       ownershipPercent = Value(ownershipPercent),
       ownershipMethod = Value(ownershipMethod);
  static Insertable<ProjectInvestor> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? investorId,
    Expression<double>? investedAmount,
    Expression<double>? ownershipPercent,
    Expression<String>? ownershipMethod,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (investorId != null) 'investor_id': investorId,
      if (investedAmount != null) 'invested_amount': investedAmount,
      if (ownershipPercent != null) 'ownership_percent': ownershipPercent,
      if (ownershipMethod != null) 'ownership_method': ownershipMethod,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectInvestorsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? investorId,
    Value<double>? investedAmount,
    Value<double>? ownershipPercent,
    Value<String>? ownershipMethod,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProjectInvestorsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      investorId: investorId ?? this.investorId,
      investedAmount: investedAmount ?? this.investedAmount,
      ownershipPercent: ownershipPercent ?? this.ownershipPercent,
      ownershipMethod: ownershipMethod ?? this.ownershipMethod,
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
    if (investorId.present) {
      map['investor_id'] = Variable<String>(investorId.value);
    }
    if (investedAmount.present) {
      map['invested_amount'] = Variable<double>(investedAmount.value);
    }
    if (ownershipPercent.present) {
      map['ownership_percent'] = Variable<double>(ownershipPercent.value);
    }
    if (ownershipMethod.present) {
      map['ownership_method'] = Variable<String>(ownershipMethod.value);
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
    return (StringBuffer('ProjectInvestorsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('investorId: $investorId, ')
          ..write('investedAmount: $investedAmount, ')
          ..write('ownershipPercent: $ownershipPercent, ')
          ..write('ownershipMethod: $ownershipMethod, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expenseDateMeta = const VerificationMeta(
    'expenseDate',
  );
  @override
  late final GeneratedColumn<DateTime> expenseDate = GeneratedColumn<DateTime>(
    'expense_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vendorMeta = const VerificationMeta('vendor');
  @override
  late final GeneratedColumn<String> vendor = GeneratedColumn<String>(
    'vendor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCapitalizedMeta = const VerificationMeta(
    'isCapitalized',
  );
  @override
  late final GeneratedColumn<bool> isCapitalized = GeneratedColumn<bool>(
    'is_capitalized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_capitalized" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    category,
    amount,
    expenseDate,
    vendor,
    isCapitalized,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('expense_date')) {
      context.handle(
        _expenseDateMeta,
        expenseDate.isAcceptableOrUnknown(
          data['expense_date']!,
          _expenseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseDateMeta);
    }
    if (data.containsKey('vendor')) {
      context.handle(
        _vendorMeta,
        vendor.isAcceptableOrUnknown(data['vendor']!, _vendorMeta),
      );
    }
    if (data.containsKey('is_capitalized')) {
      context.handle(
        _isCapitalizedMeta,
        isCapitalized.isAcceptableOrUnknown(
          data['is_capitalized']!,
          _isCapitalizedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      expenseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expense_date'],
      )!,
      vendor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vendor'],
      ),
      isCapitalized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_capitalized'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final String id;
  final String projectId;
  final String category;
  final double amount;
  final DateTime expenseDate;
  final String? vendor;
  final bool isCapitalized;
  final String? notes;
  final DateTime createdAt;
  const Expense({
    required this.id,
    required this.projectId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.vendor,
    required this.isCapitalized,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['expense_date'] = Variable<DateTime>(expenseDate);
    if (!nullToAbsent || vendor != null) {
      map['vendor'] = Variable<String>(vendor);
    }
    map['is_capitalized'] = Variable<bool>(isCapitalized);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      category: Value(category),
      amount: Value(amount),
      expenseDate: Value(expenseDate),
      vendor: vendor == null && nullToAbsent
          ? const Value.absent()
          : Value(vendor),
      isCapitalized: Value(isCapitalized),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      expenseDate: serializer.fromJson<DateTime>(json['expenseDate']),
      vendor: serializer.fromJson<String?>(json['vendor']),
      isCapitalized: serializer.fromJson<bool>(json['isCapitalized']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'expenseDate': serializer.toJson<DateTime>(expenseDate),
      'vendor': serializer.toJson<String?>(vendor),
      'isCapitalized': serializer.toJson<bool>(isCapitalized),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Expense copyWith({
    String? id,
    String? projectId,
    String? category,
    double? amount,
    DateTime? expenseDate,
    Value<String?> vendor = const Value.absent(),
    bool? isCapitalized,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Expense(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    expenseDate: expenseDate ?? this.expenseDate,
    vendor: vendor.present ? vendor.value : this.vendor,
    isCapitalized: isCapitalized ?? this.isCapitalized,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      expenseDate: data.expenseDate.present
          ? data.expenseDate.value
          : this.expenseDate,
      vendor: data.vendor.present ? data.vendor.value : this.vendor,
      isCapitalized: data.isCapitalized.present
          ? data.isCapitalized.value
          : this.isCapitalized,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('vendor: $vendor, ')
          ..write('isCapitalized: $isCapitalized, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    category,
    amount,
    expenseDate,
    vendor,
    isCapitalized,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.expenseDate == this.expenseDate &&
          other.vendor == this.vendor &&
          other.isCapitalized == this.isCapitalized &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> expenseDate;
  final Value<String?> vendor;
  final Value<bool> isCapitalized;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.expenseDate = const Value.absent(),
    this.vendor = const Value.absent(),
    this.isCapitalized = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String projectId,
    required String category,
    required double amount,
    required DateTime expenseDate,
    this.vendor = const Value.absent(),
    this.isCapitalized = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       category = Value(category),
       amount = Value(amount),
       expenseDate = Value(expenseDate);
  static Insertable<Expense> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? expenseDate,
    Expression<String>? vendor,
    Expression<bool>? isCapitalized,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (expenseDate != null) 'expense_date': expenseDate,
      if (vendor != null) 'vendor': vendor,
      if (isCapitalized != null) 'is_capitalized': isCapitalized,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? category,
    Value<double>? amount,
    Value<DateTime>? expenseDate,
    Value<String?>? vendor,
    Value<bool>? isCapitalized,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      vendor: vendor ?? this.vendor,
      isCapitalized: isCapitalized ?? this.isCapitalized,
      notes: notes ?? this.notes,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (expenseDate.present) {
      map['expense_date'] = Variable<DateTime>(expenseDate.value);
    }
    if (vendor.present) {
      map['vendor'] = Variable<String>(vendor.value);
    }
    if (isCapitalized.present) {
      map['is_capitalized'] = Variable<bool>(isCapitalized.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('expenseDate: $expenseDate, ')
          ..write('vendor: $vendor, ')
          ..write('isCapitalized: $isCapitalized, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlotsTable extends Plots with TableInfo<$PlotsTable, Plot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlotsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _plotNumberMeta = const VerificationMeta(
    'plotNumber',
  );
  @override
  late final GeneratedColumn<String> plotNumber = GeneratedColumn<String>(
    'plot_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaSqFtMeta = const VerificationMeta(
    'areaSqFt',
  );
  @override
  late final GeneratedColumn<double> areaSqFt = GeneratedColumn<double>(
    'area_sq_ft',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measurementUnitMeta = const VerificationMeta(
    'measurementUnit',
  );
  @override
  late final GeneratedColumn<String> measurementUnit = GeneratedColumn<String>(
    'measurement_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Kattha'),
  );
  static const VerificationMeta _displayAreaMeta = const VerificationMeta(
    'displayArea',
  );
  @override
  late final GeneratedColumn<double> displayArea = GeneratedColumn<double>(
    'display_area',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kattaValueMeta = const VerificationMeta(
    'kattaValue',
  );
  @override
  late final GeneratedColumn<double> kattaValue = GeneratedColumn<double>(
    'katta_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dhurValueMeta = const VerificationMeta(
    'dhurValue',
  );
  @override
  late final GeneratedColumn<double> dhurValue = GeneratedColumn<double>(
    'dhur_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthFtMeta = const VerificationMeta(
    'lengthFt',
  );
  @override
  late final GeneratedColumn<double> lengthFt = GeneratedColumn<double>(
    'length_ft',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lengthInMeta = const VerificationMeta(
    'lengthIn',
  );
  @override
  late final GeneratedColumn<double> lengthIn = GeneratedColumn<double>(
    'length_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breadthFtMeta = const VerificationMeta(
    'breadthFt',
  );
  @override
  late final GeneratedColumn<double> breadthFt = GeneratedColumn<double>(
    'breadth_ft',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breadthInMeta = const VerificationMeta(
    'breadthIn',
  );
  @override
  late final GeneratedColumn<double> breadthIn = GeneratedColumn<double>(
    'breadth_in',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allocatedCostMeta = const VerificationMeta(
    'allocatedCost',
  );
  @override
  late final GeneratedColumn<double> allocatedCost = GeneratedColumn<double>(
    'allocated_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _expectedPriceMeta = const VerificationMeta(
    'expectedPrice',
  );
  @override
  late final GeneratedColumn<double> expectedPrice = GeneratedColumn<double>(
    'expected_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    plotNumber,
    areaSqFt,
    measurementUnit,
    displayArea,
    kattaValue,
    dhurValue,
    lengthFt,
    lengthIn,
    breadthFt,
    breadthIn,
    allocatedCost,
    expectedPrice,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plots';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plot> instance, {
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
    if (data.containsKey('plot_number')) {
      context.handle(
        _plotNumberMeta,
        plotNumber.isAcceptableOrUnknown(data['plot_number']!, _plotNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_plotNumberMeta);
    }
    if (data.containsKey('area_sq_ft')) {
      context.handle(
        _areaSqFtMeta,
        areaSqFt.isAcceptableOrUnknown(data['area_sq_ft']!, _areaSqFtMeta),
      );
    } else if (isInserting) {
      context.missing(_areaSqFtMeta);
    }
    if (data.containsKey('measurement_unit')) {
      context.handle(
        _measurementUnitMeta,
        measurementUnit.isAcceptableOrUnknown(
          data['measurement_unit']!,
          _measurementUnitMeta,
        ),
      );
    }
    if (data.containsKey('display_area')) {
      context.handle(
        _displayAreaMeta,
        displayArea.isAcceptableOrUnknown(
          data['display_area']!,
          _displayAreaMeta,
        ),
      );
    }
    if (data.containsKey('katta_value')) {
      context.handle(
        _kattaValueMeta,
        kattaValue.isAcceptableOrUnknown(data['katta_value']!, _kattaValueMeta),
      );
    }
    if (data.containsKey('dhur_value')) {
      context.handle(
        _dhurValueMeta,
        dhurValue.isAcceptableOrUnknown(data['dhur_value']!, _dhurValueMeta),
      );
    }
    if (data.containsKey('length_ft')) {
      context.handle(
        _lengthFtMeta,
        lengthFt.isAcceptableOrUnknown(data['length_ft']!, _lengthFtMeta),
      );
    }
    if (data.containsKey('length_in')) {
      context.handle(
        _lengthInMeta,
        lengthIn.isAcceptableOrUnknown(data['length_in']!, _lengthInMeta),
      );
    }
    if (data.containsKey('breadth_ft')) {
      context.handle(
        _breadthFtMeta,
        breadthFt.isAcceptableOrUnknown(data['breadth_ft']!, _breadthFtMeta),
      );
    }
    if (data.containsKey('breadth_in')) {
      context.handle(
        _breadthInMeta,
        breadthIn.isAcceptableOrUnknown(data['breadth_in']!, _breadthInMeta),
      );
    }
    if (data.containsKey('allocated_cost')) {
      context.handle(
        _allocatedCostMeta,
        allocatedCost.isAcceptableOrUnknown(
          data['allocated_cost']!,
          _allocatedCostMeta,
        ),
      );
    }
    if (data.containsKey('expected_price')) {
      context.handle(
        _expectedPriceMeta,
        expectedPrice.isAcceptableOrUnknown(
          data['expected_price']!,
          _expectedPriceMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      plotNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plot_number'],
      )!,
      areaSqFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area_sq_ft'],
      )!,
      measurementUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_unit'],
      )!,
      displayArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}display_area'],
      ),
      kattaValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}katta_value'],
      ),
      dhurValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dhur_value'],
      ),
      lengthFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_ft'],
      ),
      lengthIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}length_in'],
      ),
      breadthFt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breadth_ft'],
      ),
      breadthIn: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}breadth_in'],
      ),
      allocatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}allocated_cost'],
      )!,
      expectedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_price'],
      )!,
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
  $PlotsTable createAlias(String alias) {
    return $PlotsTable(attachedDatabase, alias);
  }
}

class Plot extends DataClass implements Insertable<Plot> {
  final String id;
  final String projectId;
  final String plotNumber;
  final double areaSqFt;
  final String measurementUnit;
  final double? displayArea;
  final double? kattaValue;
  final double? dhurValue;
  final double? lengthFt;
  final double? lengthIn;
  final double? breadthFt;
  final double? breadthIn;
  final double allocatedCost;
  final double expectedPrice;
  final String status;
  final DateTime createdAt;
  const Plot({
    required this.id,
    required this.projectId,
    required this.plotNumber,
    required this.areaSqFt,
    required this.measurementUnit,
    this.displayArea,
    this.kattaValue,
    this.dhurValue,
    this.lengthFt,
    this.lengthIn,
    this.breadthFt,
    this.breadthIn,
    required this.allocatedCost,
    required this.expectedPrice,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['plot_number'] = Variable<String>(plotNumber);
    map['area_sq_ft'] = Variable<double>(areaSqFt);
    map['measurement_unit'] = Variable<String>(measurementUnit);
    if (!nullToAbsent || displayArea != null) {
      map['display_area'] = Variable<double>(displayArea);
    }
    if (!nullToAbsent || kattaValue != null) {
      map['katta_value'] = Variable<double>(kattaValue);
    }
    if (!nullToAbsent || dhurValue != null) {
      map['dhur_value'] = Variable<double>(dhurValue);
    }
    if (!nullToAbsent || lengthFt != null) {
      map['length_ft'] = Variable<double>(lengthFt);
    }
    if (!nullToAbsent || lengthIn != null) {
      map['length_in'] = Variable<double>(lengthIn);
    }
    if (!nullToAbsent || breadthFt != null) {
      map['breadth_ft'] = Variable<double>(breadthFt);
    }
    if (!nullToAbsent || breadthIn != null) {
      map['breadth_in'] = Variable<double>(breadthIn);
    }
    map['allocated_cost'] = Variable<double>(allocatedCost);
    map['expected_price'] = Variable<double>(expectedPrice);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlotsCompanion toCompanion(bool nullToAbsent) {
    return PlotsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      plotNumber: Value(plotNumber),
      areaSqFt: Value(areaSqFt),
      measurementUnit: Value(measurementUnit),
      displayArea: displayArea == null && nullToAbsent
          ? const Value.absent()
          : Value(displayArea),
      kattaValue: kattaValue == null && nullToAbsent
          ? const Value.absent()
          : Value(kattaValue),
      dhurValue: dhurValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dhurValue),
      lengthFt: lengthFt == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthFt),
      lengthIn: lengthIn == null && nullToAbsent
          ? const Value.absent()
          : Value(lengthIn),
      breadthFt: breadthFt == null && nullToAbsent
          ? const Value.absent()
          : Value(breadthFt),
      breadthIn: breadthIn == null && nullToAbsent
          ? const Value.absent()
          : Value(breadthIn),
      allocatedCost: Value(allocatedCost),
      expectedPrice: Value(expectedPrice),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Plot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plot(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      plotNumber: serializer.fromJson<String>(json['plotNumber']),
      areaSqFt: serializer.fromJson<double>(json['areaSqFt']),
      measurementUnit: serializer.fromJson<String>(json['measurementUnit']),
      displayArea: serializer.fromJson<double?>(json['displayArea']),
      kattaValue: serializer.fromJson<double?>(json['kattaValue']),
      dhurValue: serializer.fromJson<double?>(json['dhurValue']),
      lengthFt: serializer.fromJson<double?>(json['lengthFt']),
      lengthIn: serializer.fromJson<double?>(json['lengthIn']),
      breadthFt: serializer.fromJson<double?>(json['breadthFt']),
      breadthIn: serializer.fromJson<double?>(json['breadthIn']),
      allocatedCost: serializer.fromJson<double>(json['allocatedCost']),
      expectedPrice: serializer.fromJson<double>(json['expectedPrice']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'plotNumber': serializer.toJson<String>(plotNumber),
      'areaSqFt': serializer.toJson<double>(areaSqFt),
      'measurementUnit': serializer.toJson<String>(measurementUnit),
      'displayArea': serializer.toJson<double?>(displayArea),
      'kattaValue': serializer.toJson<double?>(kattaValue),
      'dhurValue': serializer.toJson<double?>(dhurValue),
      'lengthFt': serializer.toJson<double?>(lengthFt),
      'lengthIn': serializer.toJson<double?>(lengthIn),
      'breadthFt': serializer.toJson<double?>(breadthFt),
      'breadthIn': serializer.toJson<double?>(breadthIn),
      'allocatedCost': serializer.toJson<double>(allocatedCost),
      'expectedPrice': serializer.toJson<double>(expectedPrice),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Plot copyWith({
    String? id,
    String? projectId,
    String? plotNumber,
    double? areaSqFt,
    String? measurementUnit,
    Value<double?> displayArea = const Value.absent(),
    Value<double?> kattaValue = const Value.absent(),
    Value<double?> dhurValue = const Value.absent(),
    Value<double?> lengthFt = const Value.absent(),
    Value<double?> lengthIn = const Value.absent(),
    Value<double?> breadthFt = const Value.absent(),
    Value<double?> breadthIn = const Value.absent(),
    double? allocatedCost,
    double? expectedPrice,
    String? status,
    DateTime? createdAt,
  }) => Plot(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    plotNumber: plotNumber ?? this.plotNumber,
    areaSqFt: areaSqFt ?? this.areaSqFt,
    measurementUnit: measurementUnit ?? this.measurementUnit,
    displayArea: displayArea.present ? displayArea.value : this.displayArea,
    kattaValue: kattaValue.present ? kattaValue.value : this.kattaValue,
    dhurValue: dhurValue.present ? dhurValue.value : this.dhurValue,
    lengthFt: lengthFt.present ? lengthFt.value : this.lengthFt,
    lengthIn: lengthIn.present ? lengthIn.value : this.lengthIn,
    breadthFt: breadthFt.present ? breadthFt.value : this.breadthFt,
    breadthIn: breadthIn.present ? breadthIn.value : this.breadthIn,
    allocatedCost: allocatedCost ?? this.allocatedCost,
    expectedPrice: expectedPrice ?? this.expectedPrice,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Plot copyWithCompanion(PlotsCompanion data) {
    return Plot(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      plotNumber: data.plotNumber.present
          ? data.plotNumber.value
          : this.plotNumber,
      areaSqFt: data.areaSqFt.present ? data.areaSqFt.value : this.areaSqFt,
      measurementUnit: data.measurementUnit.present
          ? data.measurementUnit.value
          : this.measurementUnit,
      displayArea: data.displayArea.present
          ? data.displayArea.value
          : this.displayArea,
      kattaValue: data.kattaValue.present
          ? data.kattaValue.value
          : this.kattaValue,
      dhurValue: data.dhurValue.present ? data.dhurValue.value : this.dhurValue,
      lengthFt: data.lengthFt.present ? data.lengthFt.value : this.lengthFt,
      lengthIn: data.lengthIn.present ? data.lengthIn.value : this.lengthIn,
      breadthFt: data.breadthFt.present ? data.breadthFt.value : this.breadthFt,
      breadthIn: data.breadthIn.present ? data.breadthIn.value : this.breadthIn,
      allocatedCost: data.allocatedCost.present
          ? data.allocatedCost.value
          : this.allocatedCost,
      expectedPrice: data.expectedPrice.present
          ? data.expectedPrice.value
          : this.expectedPrice,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plot(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('plotNumber: $plotNumber, ')
          ..write('areaSqFt: $areaSqFt, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('displayArea: $displayArea, ')
          ..write('kattaValue: $kattaValue, ')
          ..write('dhurValue: $dhurValue, ')
          ..write('lengthFt: $lengthFt, ')
          ..write('lengthIn: $lengthIn, ')
          ..write('breadthFt: $breadthFt, ')
          ..write('breadthIn: $breadthIn, ')
          ..write('allocatedCost: $allocatedCost, ')
          ..write('expectedPrice: $expectedPrice, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    plotNumber,
    areaSqFt,
    measurementUnit,
    displayArea,
    kattaValue,
    dhurValue,
    lengthFt,
    lengthIn,
    breadthFt,
    breadthIn,
    allocatedCost,
    expectedPrice,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plot &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.plotNumber == this.plotNumber &&
          other.areaSqFt == this.areaSqFt &&
          other.measurementUnit == this.measurementUnit &&
          other.displayArea == this.displayArea &&
          other.kattaValue == this.kattaValue &&
          other.dhurValue == this.dhurValue &&
          other.lengthFt == this.lengthFt &&
          other.lengthIn == this.lengthIn &&
          other.breadthFt == this.breadthFt &&
          other.breadthIn == this.breadthIn &&
          other.allocatedCost == this.allocatedCost &&
          other.expectedPrice == this.expectedPrice &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class PlotsCompanion extends UpdateCompanion<Plot> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> plotNumber;
  final Value<double> areaSqFt;
  final Value<String> measurementUnit;
  final Value<double?> displayArea;
  final Value<double?> kattaValue;
  final Value<double?> dhurValue;
  final Value<double?> lengthFt;
  final Value<double?> lengthIn;
  final Value<double?> breadthFt;
  final Value<double?> breadthIn;
  final Value<double> allocatedCost;
  final Value<double> expectedPrice;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlotsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.plotNumber = const Value.absent(),
    this.areaSqFt = const Value.absent(),
    this.measurementUnit = const Value.absent(),
    this.displayArea = const Value.absent(),
    this.kattaValue = const Value.absent(),
    this.dhurValue = const Value.absent(),
    this.lengthFt = const Value.absent(),
    this.lengthIn = const Value.absent(),
    this.breadthFt = const Value.absent(),
    this.breadthIn = const Value.absent(),
    this.allocatedCost = const Value.absent(),
    this.expectedPrice = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlotsCompanion.insert({
    required String id,
    required String projectId,
    required String plotNumber,
    required double areaSqFt,
    this.measurementUnit = const Value.absent(),
    this.displayArea = const Value.absent(),
    this.kattaValue = const Value.absent(),
    this.dhurValue = const Value.absent(),
    this.lengthFt = const Value.absent(),
    this.lengthIn = const Value.absent(),
    this.breadthFt = const Value.absent(),
    this.breadthIn = const Value.absent(),
    this.allocatedCost = const Value.absent(),
    this.expectedPrice = const Value.absent(),
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       plotNumber = Value(plotNumber),
       areaSqFt = Value(areaSqFt),
       status = Value(status);
  static Insertable<Plot> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? plotNumber,
    Expression<double>? areaSqFt,
    Expression<String>? measurementUnit,
    Expression<double>? displayArea,
    Expression<double>? kattaValue,
    Expression<double>? dhurValue,
    Expression<double>? lengthFt,
    Expression<double>? lengthIn,
    Expression<double>? breadthFt,
    Expression<double>? breadthIn,
    Expression<double>? allocatedCost,
    Expression<double>? expectedPrice,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (plotNumber != null) 'plot_number': plotNumber,
      if (areaSqFt != null) 'area_sq_ft': areaSqFt,
      if (measurementUnit != null) 'measurement_unit': measurementUnit,
      if (displayArea != null) 'display_area': displayArea,
      if (kattaValue != null) 'katta_value': kattaValue,
      if (dhurValue != null) 'dhur_value': dhurValue,
      if (lengthFt != null) 'length_ft': lengthFt,
      if (lengthIn != null) 'length_in': lengthIn,
      if (breadthFt != null) 'breadth_ft': breadthFt,
      if (breadthIn != null) 'breadth_in': breadthIn,
      if (allocatedCost != null) 'allocated_cost': allocatedCost,
      if (expectedPrice != null) 'expected_price': expectedPrice,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlotsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? plotNumber,
    Value<double>? areaSqFt,
    Value<String>? measurementUnit,
    Value<double?>? displayArea,
    Value<double?>? kattaValue,
    Value<double?>? dhurValue,
    Value<double?>? lengthFt,
    Value<double?>? lengthIn,
    Value<double?>? breadthFt,
    Value<double?>? breadthIn,
    Value<double>? allocatedCost,
    Value<double>? expectedPrice,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlotsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      plotNumber: plotNumber ?? this.plotNumber,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      displayArea: displayArea ?? this.displayArea,
      kattaValue: kattaValue ?? this.kattaValue,
      dhurValue: dhurValue ?? this.dhurValue,
      lengthFt: lengthFt ?? this.lengthFt,
      lengthIn: lengthIn ?? this.lengthIn,
      breadthFt: breadthFt ?? this.breadthFt,
      breadthIn: breadthIn ?? this.breadthIn,
      allocatedCost: allocatedCost ?? this.allocatedCost,
      expectedPrice: expectedPrice ?? this.expectedPrice,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (plotNumber.present) {
      map['plot_number'] = Variable<String>(plotNumber.value);
    }
    if (areaSqFt.present) {
      map['area_sq_ft'] = Variable<double>(areaSqFt.value);
    }
    if (measurementUnit.present) {
      map['measurement_unit'] = Variable<String>(measurementUnit.value);
    }
    if (displayArea.present) {
      map['display_area'] = Variable<double>(displayArea.value);
    }
    if (kattaValue.present) {
      map['katta_value'] = Variable<double>(kattaValue.value);
    }
    if (dhurValue.present) {
      map['dhur_value'] = Variable<double>(dhurValue.value);
    }
    if (lengthFt.present) {
      map['length_ft'] = Variable<double>(lengthFt.value);
    }
    if (lengthIn.present) {
      map['length_in'] = Variable<double>(lengthIn.value);
    }
    if (breadthFt.present) {
      map['breadth_ft'] = Variable<double>(breadthFt.value);
    }
    if (breadthIn.present) {
      map['breadth_in'] = Variable<double>(breadthIn.value);
    }
    if (allocatedCost.present) {
      map['allocated_cost'] = Variable<double>(allocatedCost.value);
    }
    if (expectedPrice.present) {
      map['expected_price'] = Variable<double>(expectedPrice.value);
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
    return (StringBuffer('PlotsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('plotNumber: $plotNumber, ')
          ..write('areaSqFt: $areaSqFt, ')
          ..write('measurementUnit: $measurementUnit, ')
          ..write('displayArea: $displayArea, ')
          ..write('kattaValue: $kattaValue, ')
          ..write('dhurValue: $dhurValue, ')
          ..write('lengthFt: $lengthFt, ')
          ..write('lengthIn: $lengthIn, ')
          ..write('breadthFt: $breadthFt, ')
          ..write('breadthIn: $breadthIn, ')
          ..write('allocatedCost: $allocatedCost, ')
          ..write('expectedPrice: $expectedPrice, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuyersTable extends Buyers with TableInfo<$BuyersTable, Buyer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuyersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aadharMeta = const VerificationMeta('aadhar');
  @override
  late final GeneratedColumn<String> aadhar = GeneratedColumn<String>(
    'aadhar',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    pan,
    aadhar,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buyers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Buyer> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('aadhar')) {
      context.handle(
        _aadharMeta,
        aadhar.isAcceptableOrUnknown(data['aadhar']!, _aadharMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Buyer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Buyer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      aadhar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aadhar'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BuyersTable createAlias(String alias) {
    return $BuyersTable(attachedDatabase, alias);
  }
}

class Buyer extends DataClass implements Insertable<Buyer> {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? pan;
  final String? aadhar;
  final DateTime createdAt;
  const Buyer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.pan,
    this.aadhar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    if (!nullToAbsent || aadhar != null) {
      map['aadhar'] = Variable<String>(aadhar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BuyersCompanion toCompanion(bool nullToAbsent) {
    return BuyersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      aadhar: aadhar == null && nullToAbsent
          ? const Value.absent()
          : Value(aadhar),
      createdAt: Value(createdAt),
    );
  }

  factory Buyer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Buyer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      pan: serializer.fromJson<String?>(json['pan']),
      aadhar: serializer.fromJson<String?>(json['aadhar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'email': serializer.toJson<String?>(email),
      'pan': serializer.toJson<String?>(pan),
      'aadhar': serializer.toJson<String?>(aadhar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Buyer copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> email = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    Value<String?> aadhar = const Value.absent(),
    DateTime? createdAt,
  }) => Buyer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email.present ? email.value : this.email,
    pan: pan.present ? pan.value : this.pan,
    aadhar: aadhar.present ? aadhar.value : this.aadhar,
    createdAt: createdAt ?? this.createdAt,
  );
  Buyer copyWithCompanion(BuyersCompanion data) {
    return Buyer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      pan: data.pan.present ? data.pan.value : this.pan,
      aadhar: data.aadhar.present ? data.aadhar.value : this.aadhar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Buyer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pan: $pan, ')
          ..write('aadhar: $aadhar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, pan, aadhar, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Buyer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.pan == this.pan &&
          other.aadhar == this.aadhar &&
          other.createdAt == this.createdAt);
}

class BuyersCompanion extends UpdateCompanion<Buyer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> email;
  final Value<String?> pan;
  final Value<String?> aadhar;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BuyersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.pan = const Value.absent(),
    this.aadhar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuyersCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.email = const Value.absent(),
    this.pan = const Value.absent(),
    this.aadhar = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone);
  static Insertable<Buyer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? pan,
    Expression<String>? aadhar,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (pan != null) 'pan': pan,
      if (aadhar != null) 'aadhar': aadhar,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuyersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? email,
    Value<String?>? pan,
    Value<String?>? aadhar,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BuyersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      pan: pan ?? this.pan,
      aadhar: aadhar ?? this.aadhar,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (aadhar.present) {
      map['aadhar'] = Variable<String>(aadhar.value);
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
    return (StringBuffer('BuyersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('pan: $pan, ')
          ..write('aadhar: $aadhar, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _buyerIdMeta = const VerificationMeta(
    'buyerId',
  );
  @override
  late final GeneratedColumn<String> buyerId = GeneratedColumn<String>(
    'buyer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buyers (id)',
    ),
  );
  static const VerificationMeta _saleTypeMeta = const VerificationMeta(
    'saleType',
  );
  @override
  late final GeneratedColumn<String> saleType = GeneratedColumn<String>(
    'sale_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agreedPriceMeta = const VerificationMeta(
    'agreedPrice',
  );
  @override
  late final GeneratedColumn<double> agreedPrice = GeneratedColumn<double>(
    'agreed_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleExpensesMeta = const VerificationMeta(
    'saleExpenses',
  );
  @override
  late final GeneratedColumn<double> saleExpenses = GeneratedColumn<double>(
    'sale_expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _circleRateValueMeta = const VerificationMeta(
    'circleRateValue',
  );
  @override
  late final GeneratedColumn<double> circleRateValue = GeneratedColumn<double>(
    'circle_rate_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
    'sale_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    buyerId,
    saleType,
    agreedPrice,
    saleExpenses,
    circleRateValue,
    saleDate,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
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
    if (data.containsKey('buyer_id')) {
      context.handle(
        _buyerIdMeta,
        buyerId.isAcceptableOrUnknown(data['buyer_id']!, _buyerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buyerIdMeta);
    }
    if (data.containsKey('sale_type')) {
      context.handle(
        _saleTypeMeta,
        saleType.isAcceptableOrUnknown(data['sale_type']!, _saleTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_saleTypeMeta);
    }
    if (data.containsKey('agreed_price')) {
      context.handle(
        _agreedPriceMeta,
        agreedPrice.isAcceptableOrUnknown(
          data['agreed_price']!,
          _agreedPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_agreedPriceMeta);
    }
    if (data.containsKey('sale_expenses')) {
      context.handle(
        _saleExpensesMeta,
        saleExpenses.isAcceptableOrUnknown(
          data['sale_expenses']!,
          _saleExpensesMeta,
        ),
      );
    }
    if (data.containsKey('circle_rate_value')) {
      context.handle(
        _circleRateValueMeta,
        circleRateValue.isAcceptableOrUnknown(
          data['circle_rate_value']!,
          _circleRateValueMeta,
        ),
      );
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      buyerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_id'],
      )!,
      saleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_type'],
      )!,
      agreedPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}agreed_price'],
      )!,
      saleExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_expenses'],
      )!,
      circleRateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}circle_rate_value'],
      ),
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sale_date'],
      )!,
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
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final String id;
  final String projectId;
  final String buyerId;
  final String saleType;
  final double agreedPrice;
  final double saleExpenses;
  final double? circleRateValue;
  final DateTime saleDate;
  final String status;
  final DateTime createdAt;
  const Sale({
    required this.id,
    required this.projectId,
    required this.buyerId,
    required this.saleType,
    required this.agreedPrice,
    required this.saleExpenses,
    this.circleRateValue,
    required this.saleDate,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['buyer_id'] = Variable<String>(buyerId);
    map['sale_type'] = Variable<String>(saleType);
    map['agreed_price'] = Variable<double>(agreedPrice);
    map['sale_expenses'] = Variable<double>(saleExpenses);
    if (!nullToAbsent || circleRateValue != null) {
      map['circle_rate_value'] = Variable<double>(circleRateValue);
    }
    map['sale_date'] = Variable<DateTime>(saleDate);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      buyerId: Value(buyerId),
      saleType: Value(saleType),
      agreedPrice: Value(agreedPrice),
      saleExpenses: Value(saleExpenses),
      circleRateValue: circleRateValue == null && nullToAbsent
          ? const Value.absent()
          : Value(circleRateValue),
      saleDate: Value(saleDate),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      buyerId: serializer.fromJson<String>(json['buyerId']),
      saleType: serializer.fromJson<String>(json['saleType']),
      agreedPrice: serializer.fromJson<double>(json['agreedPrice']),
      saleExpenses: serializer.fromJson<double>(json['saleExpenses']),
      circleRateValue: serializer.fromJson<double?>(json['circleRateValue']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'buyerId': serializer.toJson<String>(buyerId),
      'saleType': serializer.toJson<String>(saleType),
      'agreedPrice': serializer.toJson<double>(agreedPrice),
      'saleExpenses': serializer.toJson<double>(saleExpenses),
      'circleRateValue': serializer.toJson<double?>(circleRateValue),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sale copyWith({
    String? id,
    String? projectId,
    String? buyerId,
    String? saleType,
    double? agreedPrice,
    double? saleExpenses,
    Value<double?> circleRateValue = const Value.absent(),
    DateTime? saleDate,
    String? status,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    buyerId: buyerId ?? this.buyerId,
    saleType: saleType ?? this.saleType,
    agreedPrice: agreedPrice ?? this.agreedPrice,
    saleExpenses: saleExpenses ?? this.saleExpenses,
    circleRateValue: circleRateValue.present
        ? circleRateValue.value
        : this.circleRateValue,
    saleDate: saleDate ?? this.saleDate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      buyerId: data.buyerId.present ? data.buyerId.value : this.buyerId,
      saleType: data.saleType.present ? data.saleType.value : this.saleType,
      agreedPrice: data.agreedPrice.present
          ? data.agreedPrice.value
          : this.agreedPrice,
      saleExpenses: data.saleExpenses.present
          ? data.saleExpenses.value
          : this.saleExpenses,
      circleRateValue: data.circleRateValue.present
          ? data.circleRateValue.value
          : this.circleRateValue,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('buyerId: $buyerId, ')
          ..write('saleType: $saleType, ')
          ..write('agreedPrice: $agreedPrice, ')
          ..write('saleExpenses: $saleExpenses, ')
          ..write('circleRateValue: $circleRateValue, ')
          ..write('saleDate: $saleDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    buyerId,
    saleType,
    agreedPrice,
    saleExpenses,
    circleRateValue,
    saleDate,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.buyerId == this.buyerId &&
          other.saleType == this.saleType &&
          other.agreedPrice == this.agreedPrice &&
          other.saleExpenses == this.saleExpenses &&
          other.circleRateValue == this.circleRateValue &&
          other.saleDate == this.saleDate &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> buyerId;
  final Value<String> saleType;
  final Value<double> agreedPrice;
  final Value<double> saleExpenses;
  final Value<double?> circleRateValue;
  final Value<DateTime> saleDate;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.buyerId = const Value.absent(),
    this.saleType = const Value.absent(),
    this.agreedPrice = const Value.absent(),
    this.saleExpenses = const Value.absent(),
    this.circleRateValue = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required String projectId,
    required String buyerId,
    required String saleType,
    required double agreedPrice,
    this.saleExpenses = const Value.absent(),
    this.circleRateValue = const Value.absent(),
    required DateTime saleDate,
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       buyerId = Value(buyerId),
       saleType = Value(saleType),
       agreedPrice = Value(agreedPrice),
       saleDate = Value(saleDate),
       status = Value(status);
  static Insertable<Sale> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? buyerId,
    Expression<String>? saleType,
    Expression<double>? agreedPrice,
    Expression<double>? saleExpenses,
    Expression<double>? circleRateValue,
    Expression<DateTime>? saleDate,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (buyerId != null) 'buyer_id': buyerId,
      if (saleType != null) 'sale_type': saleType,
      if (agreedPrice != null) 'agreed_price': agreedPrice,
      if (saleExpenses != null) 'sale_expenses': saleExpenses,
      if (circleRateValue != null) 'circle_rate_value': circleRateValue,
      if (saleDate != null) 'sale_date': saleDate,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? buyerId,
    Value<String>? saleType,
    Value<double>? agreedPrice,
    Value<double>? saleExpenses,
    Value<double?>? circleRateValue,
    Value<DateTime>? saleDate,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      buyerId: buyerId ?? this.buyerId,
      saleType: saleType ?? this.saleType,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      saleExpenses: saleExpenses ?? this.saleExpenses,
      circleRateValue: circleRateValue ?? this.circleRateValue,
      saleDate: saleDate ?? this.saleDate,
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
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (buyerId.present) {
      map['buyer_id'] = Variable<String>(buyerId.value);
    }
    if (saleType.present) {
      map['sale_type'] = Variable<String>(saleType.value);
    }
    if (agreedPrice.present) {
      map['agreed_price'] = Variable<double>(agreedPrice.value);
    }
    if (saleExpenses.present) {
      map['sale_expenses'] = Variable<double>(saleExpenses.value);
    }
    if (circleRateValue.present) {
      map['circle_rate_value'] = Variable<double>(circleRateValue.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
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
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('buyerId: $buyerId, ')
          ..write('saleType: $saleType, ')
          ..write('agreedPrice: $agreedPrice, ')
          ..write('saleExpenses: $saleExpenses, ')
          ..write('circleRateValue: $circleRateValue, ')
          ..write('saleDate: $saleDate, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentsTable extends Installments
    with TableInfo<$InstallmentsTable, Installment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _purchaseAgreementIdMeta =
      const VerificationMeta('purchaseAgreementId');
  @override
  late final GeneratedColumn<String> purchaseAgreementId =
      GeneratedColumn<String>(
        'purchase_agreement_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_agreements (id)',
        ),
      );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAmountMeta = const VerificationMeta(
    'dueAmount',
  );
  @override
  late final GeneratedColumn<double> dueAmount = GeneratedColumn<double>(
    'due_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    purchaseAgreementId,
    installmentNumber,
    dueDate,
    dueAmount,
    paidAmount,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Installment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    }
    if (data.containsKey('purchase_agreement_id')) {
      context.handle(
        _purchaseAgreementIdMeta,
        purchaseAgreementId.isAcceptableOrUnknown(
          data['purchase_agreement_id']!,
          _purchaseAgreementIdMeta,
        ),
      );
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentNumberMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('due_amount')) {
      context.handle(
        _dueAmountMeta,
        dueAmount.isAcceptableOrUnknown(data['due_amount']!, _dueAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Installment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Installment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_id'],
      ),
      purchaseAgreementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_agreement_id'],
      ),
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      dueAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}due_amount'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
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
  $InstallmentsTable createAlias(String alias) {
    return $InstallmentsTable(attachedDatabase, alias);
  }
}

class Installment extends DataClass implements Insertable<Installment> {
  final String id;
  final String? saleId;
  final String? purchaseAgreementId;
  final int installmentNumber;
  final DateTime dueDate;
  final double dueAmount;
  final double paidAmount;
  final String status;
  final DateTime createdAt;
  const Installment({
    required this.id,
    this.saleId,
    this.purchaseAgreementId,
    required this.installmentNumber,
    required this.dueDate,
    required this.dueAmount,
    required this.paidAmount,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<String>(saleId);
    }
    if (!nullToAbsent || purchaseAgreementId != null) {
      map['purchase_agreement_id'] = Variable<String>(purchaseAgreementId);
    }
    map['installment_number'] = Variable<int>(installmentNumber);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['due_amount'] = Variable<double>(dueAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InstallmentsCompanion toCompanion(bool nullToAbsent) {
    return InstallmentsCompanion(
      id: Value(id),
      saleId: saleId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleId),
      purchaseAgreementId: purchaseAgreementId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseAgreementId),
      installmentNumber: Value(installmentNumber),
      dueDate: Value(dueDate),
      dueAmount: Value(dueAmount),
      paidAmount: Value(paidAmount),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory Installment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Installment(
      id: serializer.fromJson<String>(json['id']),
      saleId: serializer.fromJson<String?>(json['saleId']),
      purchaseAgreementId: serializer.fromJson<String?>(
        json['purchaseAgreementId'],
      ),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      dueAmount: serializer.fromJson<double>(json['dueAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleId': serializer.toJson<String?>(saleId),
      'purchaseAgreementId': serializer.toJson<String?>(purchaseAgreementId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'dueAmount': serializer.toJson<double>(dueAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Installment copyWith({
    String? id,
    Value<String?> saleId = const Value.absent(),
    Value<String?> purchaseAgreementId = const Value.absent(),
    int? installmentNumber,
    DateTime? dueDate,
    double? dueAmount,
    double? paidAmount,
    String? status,
    DateTime? createdAt,
  }) => Installment(
    id: id ?? this.id,
    saleId: saleId.present ? saleId.value : this.saleId,
    purchaseAgreementId: purchaseAgreementId.present
        ? purchaseAgreementId.value
        : this.purchaseAgreementId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    dueDate: dueDate ?? this.dueDate,
    dueAmount: dueAmount ?? this.dueAmount,
    paidAmount: paidAmount ?? this.paidAmount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  Installment copyWithCompanion(InstallmentsCompanion data) {
    return Installment(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      purchaseAgreementId: data.purchaseAgreementId.present
          ? data.purchaseAgreementId.value
          : this.purchaseAgreementId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      dueAmount: data.dueAmount.present ? data.dueAmount.value : this.dueAmount,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Installment(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('purchaseAgreementId: $purchaseAgreementId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueAmount: $dueAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    purchaseAgreementId,
    installmentNumber,
    dueDate,
    dueAmount,
    paidAmount,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Installment &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.purchaseAgreementId == this.purchaseAgreementId &&
          other.installmentNumber == this.installmentNumber &&
          other.dueDate == this.dueDate &&
          other.dueAmount == this.dueAmount &&
          other.paidAmount == this.paidAmount &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class InstallmentsCompanion extends UpdateCompanion<Installment> {
  final Value<String> id;
  final Value<String?> saleId;
  final Value<String?> purchaseAgreementId;
  final Value<int> installmentNumber;
  final Value<DateTime> dueDate;
  final Value<double> dueAmount;
  final Value<double> paidAmount;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const InstallmentsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.purchaseAgreementId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.dueAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentsCompanion.insert({
    required String id,
    this.saleId = const Value.absent(),
    this.purchaseAgreementId = const Value.absent(),
    required int installmentNumber,
    required DateTime dueDate,
    required double dueAmount,
    this.paidAmount = const Value.absent(),
    required String status,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       installmentNumber = Value(installmentNumber),
       dueDate = Value(dueDate),
       dueAmount = Value(dueAmount),
       status = Value(status);
  static Insertable<Installment> custom({
    Expression<String>? id,
    Expression<String>? saleId,
    Expression<String>? purchaseAgreementId,
    Expression<int>? installmentNumber,
    Expression<DateTime>? dueDate,
    Expression<double>? dueAmount,
    Expression<double>? paidAmount,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (purchaseAgreementId != null)
        'purchase_agreement_id': purchaseAgreementId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (dueDate != null) 'due_date': dueDate,
      if (dueAmount != null) 'due_amount': dueAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentsCompanion copyWith({
    Value<String>? id,
    Value<String?>? saleId,
    Value<String?>? purchaseAgreementId,
    Value<int>? installmentNumber,
    Value<DateTime>? dueDate,
    Value<double>? dueAmount,
    Value<double>? paidAmount,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return InstallmentsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      purchaseAgreementId: purchaseAgreementId ?? this.purchaseAgreementId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      dueAmount: dueAmount ?? this.dueAmount,
      paidAmount: paidAmount ?? this.paidAmount,
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
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (purchaseAgreementId.present) {
      map['purchase_agreement_id'] = Variable<String>(
        purchaseAgreementId.value,
      );
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (dueAmount.present) {
      map['due_amount'] = Variable<double>(dueAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
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
    return (StringBuffer('InstallmentsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('purchaseAgreementId: $purchaseAgreementId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('dueAmount: $dueAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _installmentIdMeta = const VerificationMeta(
    'installmentId',
  );
  @override
  late final GeneratedColumn<String> installmentId = GeneratedColumn<String>(
    'installment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES installments (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVoidedMeta = const VerificationMeta(
    'isVoided',
  );
  @override
  late final GeneratedColumn<bool> isVoided = GeneratedColumn<bool>(
    'is_voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    installmentId,
    amount,
    paymentDate,
    paymentMethod,
    referenceNumber,
    receiptPath,
    isVoided,
    voidReason,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
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
    if (data.containsKey('installment_id')) {
      context.handle(
        _installmentIdMeta,
        installmentId.isAcceptableOrUnknown(
          data['installment_id']!,
          _installmentIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('is_voided')) {
      context.handle(
        _isVoidedMeta,
        isVoided.isAcceptableOrUnknown(data['is_voided']!, _isVoidedMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      installmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installment_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      isVoided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_voided'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final String projectId;
  final String? installmentId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? referenceNumber;
  final String? receiptPath;
  final bool isVoided;
  final String? voidReason;
  final String createdBy;
  final DateTime createdAt;
  const Transaction({
    required this.id,
    required this.projectId,
    this.installmentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.receiptPath,
    required this.isVoided,
    this.voidReason,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    if (!nullToAbsent || installmentId != null) {
      map['installment_id'] = Variable<String>(installmentId);
    }
    map['amount'] = Variable<double>(amount);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    map['is_voided'] = Variable<bool>(isVoided);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      installmentId: installmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentId),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      paymentMethod: Value(paymentMethod),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      isVoided: Value(isVoided),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      installmentId: serializer.fromJson<String?>(json['installmentId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      isVoided: serializer.fromJson<bool>(json['isVoided']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'installmentId': serializer.toJson<String?>(installmentId),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'isVoided': serializer.toJson<bool>(isVoided),
      'voidReason': serializer.toJson<String?>(voidReason),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? projectId,
    Value<String?> installmentId = const Value.absent(),
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    Value<String?> referenceNumber = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
    bool? isVoided,
    Value<String?> voidReason = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => Transaction(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    installmentId: installmentId.present
        ? installmentId.value
        : this.installmentId,
    amount: amount ?? this.amount,
    paymentDate: paymentDate ?? this.paymentDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    referenceNumber: referenceNumber.present
        ? referenceNumber.value
        : this.referenceNumber,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    isVoided: isVoided ?? this.isVoided,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      installmentId: data.installmentId.present
          ? data.installmentId.value
          : this.installmentId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      isVoided: data.isVoided.present ? data.isVoided.value : this.isVoided,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('installmentId: $installmentId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    installmentId,
    amount,
    paymentDate,
    paymentMethod,
    referenceNumber,
    receiptPath,
    isVoided,
    voidReason,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.installmentId == this.installmentId &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.paymentMethod == this.paymentMethod &&
          other.referenceNumber == this.referenceNumber &&
          other.receiptPath == this.receiptPath &&
          other.isVoided == this.isVoided &&
          other.voidReason == this.voidReason &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String?> installmentId;
  final Value<double> amount;
  final Value<DateTime> paymentDate;
  final Value<String> paymentMethod;
  final Value<String?> referenceNumber;
  final Value<String?> receiptPath;
  final Value<bool> isVoided;
  final Value<String?> voidReason;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.installmentId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String projectId,
    this.installmentId = const Value.absent(),
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    this.referenceNumber = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.isVoided = const Value.absent(),
    this.voidReason = const Value.absent(),
    required String createdBy,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       amount = Value(amount),
       paymentDate = Value(paymentDate),
       paymentMethod = Value(paymentMethod),
       createdBy = Value(createdBy);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? installmentId,
    Expression<double>? amount,
    Expression<DateTime>? paymentDate,
    Expression<String>? paymentMethod,
    Expression<String>? referenceNumber,
    Expression<String>? receiptPath,
    Expression<bool>? isVoided,
    Expression<String>? voidReason,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (installmentId != null) 'installment_id': installmentId,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (isVoided != null) 'is_voided': isVoided,
      if (voidReason != null) 'void_reason': voidReason,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String?>? installmentId,
    Value<double>? amount,
    Value<DateTime>? paymentDate,
    Value<String>? paymentMethod,
    Value<String?>? referenceNumber,
    Value<String?>? receiptPath,
    Value<bool>? isVoided,
    Value<String?>? voidReason,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      installmentId: installmentId ?? this.installmentId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      receiptPath: receiptPath ?? this.receiptPath,
      isVoided: isVoided ?? this.isVoided,
      voidReason: voidReason ?? this.voidReason,
      createdBy: createdBy ?? this.createdBy,
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
    if (installmentId.present) {
      map['installment_id'] = Variable<String>(installmentId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (isVoided.present) {
      map['is_voided'] = Variable<bool>(isVoided.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
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
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('installmentId: $installmentId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('isVoided: $isVoided, ')
          ..write('voidReason: $voidReason, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DistributionsTable extends Distributions
    with TableInfo<$DistributionsTable, Distribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistributionsTable(this.attachedDatabase, [this._alias]);
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
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _investorIdMeta = const VerificationMeta(
    'investorId',
  );
  @override
  late final GeneratedColumn<String> investorId = GeneratedColumn<String>(
    'investor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES investors (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distributionDateMeta = const VerificationMeta(
    'distributionDate',
  );
  @override
  late final GeneratedColumn<DateTime> distributionDate =
      GeneratedColumn<DateTime>(
        'distribution_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    investorId,
    amount,
    distributionDate,
    notes,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'distributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Distribution> instance, {
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
    if (data.containsKey('investor_id')) {
      context.handle(
        _investorIdMeta,
        investorId.isAcceptableOrUnknown(data['investor_id']!, _investorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_investorIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('distribution_date')) {
      context.handle(
        _distributionDateMeta,
        distributionDate.isAcceptableOrUnknown(
          data['distribution_date']!,
          _distributionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distributionDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Distribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Distribution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      investorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}investor_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      distributionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}distribution_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DistributionsTable createAlias(String alias) {
    return $DistributionsTable(attachedDatabase, alias);
  }
}

class Distribution extends DataClass implements Insertable<Distribution> {
  final String id;
  final String projectId;
  final String investorId;
  final double amount;
  final DateTime distributionDate;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  const Distribution({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.amount,
    required this.distributionDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['investor_id'] = Variable<String>(investorId);
    map['amount'] = Variable<double>(amount);
    map['distribution_date'] = Variable<DateTime>(distributionDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DistributionsCompanion toCompanion(bool nullToAbsent) {
    return DistributionsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      investorId: Value(investorId),
      amount: Value(amount),
      distributionDate: Value(distributionDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Distribution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Distribution(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      investorId: serializer.fromJson<String>(json['investorId']),
      amount: serializer.fromJson<double>(json['amount']),
      distributionDate: serializer.fromJson<DateTime>(json['distributionDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'investorId': serializer.toJson<String>(investorId),
      'amount': serializer.toJson<double>(amount),
      'distributionDate': serializer.toJson<DateTime>(distributionDate),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Distribution copyWith({
    String? id,
    String? projectId,
    String? investorId,
    double? amount,
    DateTime? distributionDate,
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
  }) => Distribution(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    investorId: investorId ?? this.investorId,
    amount: amount ?? this.amount,
    distributionDate: distributionDate ?? this.distributionDate,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Distribution copyWithCompanion(DistributionsCompanion data) {
    return Distribution(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      investorId: data.investorId.present
          ? data.investorId.value
          : this.investorId,
      amount: data.amount.present ? data.amount.value : this.amount,
      distributionDate: data.distributionDate.present
          ? data.distributionDate.value
          : this.distributionDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Distribution(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('investorId: $investorId, ')
          ..write('amount: $amount, ')
          ..write('distributionDate: $distributionDate, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    investorId,
    amount,
    distributionDate,
    notes,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Distribution &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.investorId == this.investorId &&
          other.amount == this.amount &&
          other.distributionDate == this.distributionDate &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class DistributionsCompanion extends UpdateCompanion<Distribution> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> investorId;
  final Value<double> amount;
  final Value<DateTime> distributionDate;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DistributionsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.investorId = const Value.absent(),
    this.amount = const Value.absent(),
    this.distributionDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DistributionsCompanion.insert({
    required String id,
    required String projectId,
    required String investorId,
    required double amount,
    required DateTime distributionDate,
    this.notes = const Value.absent(),
    required String createdBy,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       investorId = Value(investorId),
       amount = Value(amount),
       distributionDate = Value(distributionDate),
       createdBy = Value(createdBy);
  static Insertable<Distribution> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? investorId,
    Expression<double>? amount,
    Expression<DateTime>? distributionDate,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (investorId != null) 'investor_id': investorId,
      if (amount != null) 'amount': amount,
      if (distributionDate != null) 'distribution_date': distributionDate,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DistributionsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? investorId,
    Value<double>? amount,
    Value<DateTime>? distributionDate,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DistributionsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      investorId: investorId ?? this.investorId,
      amount: amount ?? this.amount,
      distributionDate: distributionDate ?? this.distributionDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
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
    if (investorId.present) {
      map['investor_id'] = Variable<String>(investorId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (distributionDate.present) {
      map['distribution_date'] = Variable<DateTime>(distributionDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
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
    return (StringBuffer('DistributionsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('investorId: $investorId, ')
          ..write('amount: $amount, ')
          ..write('distributionDate: $distributionDate, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    action,
    entityType,
    entityId,
    details,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
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
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    } else if (isInserting) {
      context.missing(_detailsMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final String userId;
  final String action;
  final String entityType;
  final String entityId;
  final String details;
  final DateTime timestamp;
  const AuditLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.details,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['action'] = Variable<String>(action);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['details'] = Variable<String>(details);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      action: Value(action),
      entityType: Value(entityType),
      entityId: Value(entityId),
      details: Value(details),
      timestamp: Value(timestamp),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      action: serializer.fromJson<String>(json['action']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      details: serializer.fromJson<String>(json['details']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'action': serializer.toJson<String>(action),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'details': serializer.toJson<String>(details),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  AuditLog copyWith({
    String? id,
    String? userId,
    String? action,
    String? entityType,
    String? entityId,
    String? details,
    DateTime? timestamp,
  }) => AuditLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    details: details ?? this.details,
    timestamp: timestamp ?? this.timestamp,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      details: data.details.present ? data.details.value : this.details,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('details: $details, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, action, entityType, entityId, details, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.details == this.details &&
          other.timestamp == this.timestamp);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> action;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> details;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.details = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required String userId,
    required String action,
    required String entityType,
    required String entityId,
    required String details,
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       action = Value(action),
       entityType = Value(entityType),
       entityId = Value(entityId),
       details = Value(details);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? action,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? details,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (details != null) 'details': details,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? action,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? details,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      details: details ?? this.details,
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
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
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
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('details: $details, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $LandownersTable landowners = $LandownersTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $PurchaseAgreementsTable purchaseAgreements =
      $PurchaseAgreementsTable(this);
  late final $InvestorsTable investors = $InvestorsTable(this);
  late final $ProjectInvestorsTable projectInvestors = $ProjectInvestorsTable(
    this,
  );
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $PlotsTable plots = $PlotsTable(this);
  late final $BuyersTable buyers = $BuyersTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $InstallmentsTable installments = $InstallmentsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $DistributionsTable distributions = $DistributionsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    landowners,
    projects,
    purchaseAgreements,
    investors,
    projectInvestors,
    expenses,
    plots,
    buyers,
    sales,
    installments,
    transactions,
    distributions,
    auditLogs,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      Value<String> name,
      Value<String> mobileNo,
      Value<String> username,
      Value<String> email,
      required String passwordHash,
      Value<String> salt,
      required String role,
      Value<String?> memberType,
      Value<String?> linkedEntityId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> mobileNo,
      Value<String> username,
      Value<String> email,
      Value<String> passwordHash,
      Value<String> salt,
      Value<String> role,
      Value<String?> memberType,
      Value<String?> linkedEntityId,
      Value<bool> isActive,
      Value<DateTime> createdAt,
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
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
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
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobileNo => $composableBuilder(
    column: $table.mobileNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mobileNo =>
      $composableBuilder(column: $table.mobileNo, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedEntityId => $composableBuilder(
    column: $table.linkedEntityId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> memberType = const Value.absent(),
                Value<String?> linkedEntityId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                mobileNo: mobileNo,
                username: username,
                email: email,
                passwordHash: passwordHash,
                salt: salt,
                role: role,
                memberType: memberType,
                linkedEntityId: linkedEntityId,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String> mobileNo = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> email = const Value.absent(),
                required String passwordHash,
                Value<String> salt = const Value.absent(),
                required String role,
                Value<String?> memberType = const Value.absent(),
                Value<String?> linkedEntityId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                mobileNo: mobileNo,
                username: username,
                email: email,
                passwordHash: passwordHash,
                salt: salt,
                role: role,
                memberType: memberType,
                linkedEntityId: linkedEntityId,
                isActive: isActive,
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

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$LandownersTableCreateCompanionBuilder =
    LandownersCompanion Function({
      required String id,
      required String name,
      required String phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> pan,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$LandownersTableUpdateCompanionBuilder =
    LandownersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> pan,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$LandownersTableReferences
    extends BaseReferences<_$AppDatabase, $LandownersTable, Landowner> {
  $$LandownersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: $_aliasNameGenerator(db.landowners.id, db.projects.landownerId),
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.landownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseAgreementsTable, List<PurchaseAgreement>>
  _purchaseAgreementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseAgreements,
        aliasName: $_aliasNameGenerator(
          db.landowners.id,
          db.purchaseAgreements.landownerId,
        ),
      );

  $$PurchaseAgreementsTableProcessedTableManager get purchaseAgreementsRefs {
    final manager = $$PurchaseAgreementsTableTableManager(
      $_db,
      $_db.purchaseAgreements,
    ).filter((f) => f.landownerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseAgreementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LandownersTableFilterComposer
    extends Composer<_$AppDatabase, $LandownersTable> {
  $$LandownersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.landownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseAgreementsRefs(
    Expression<bool> Function($$PurchaseAgreementsTableFilterComposer f) f,
  ) {
    final $$PurchaseAgreementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseAgreements,
      getReferencedColumn: (t) => t.landownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseAgreementsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseAgreements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LandownersTableOrderingComposer
    extends Composer<_$AppDatabase, $LandownersTable> {
  $$LandownersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LandownersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LandownersTable> {
  $$LandownersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.landownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchaseAgreementsRefs<T extends Object>(
    Expression<T> Function($$PurchaseAgreementsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseAgreementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseAgreements,
          getReferencedColumn: (t) => t.landownerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseAgreementsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseAgreements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$LandownersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LandownersTable,
          Landowner,
          $$LandownersTableFilterComposer,
          $$LandownersTableOrderingComposer,
          $$LandownersTableAnnotationComposer,
          $$LandownersTableCreateCompanionBuilder,
          $$LandownersTableUpdateCompanionBuilder,
          (Landowner, $$LandownersTableReferences),
          Landowner,
          PrefetchHooks Function({
            bool projectsRefs,
            bool purchaseAgreementsRefs,
          })
        > {
  $$LandownersTableTableManager(_$AppDatabase db, $LandownersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LandownersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LandownersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LandownersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LandownersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                pan: pan,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LandownersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                address: address,
                pan: pan,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LandownersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectsRefs = false, purchaseAgreementsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectsRefs) db.projects,
                    if (purchaseAgreementsRefs) db.purchaseAgreements,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectsRefs)
                        await $_getPrefetchedData<
                          Landowner,
                          $LandownersTable,
                          Project
                        >(
                          currentTable: table,
                          referencedTable: $$LandownersTableReferences
                              ._projectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LandownersTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.landownerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (purchaseAgreementsRefs)
                        await $_getPrefetchedData<
                          Landowner,
                          $LandownersTable,
                          PurchaseAgreement
                        >(
                          currentTable: table,
                          referencedTable: $$LandownersTableReferences
                              ._purchaseAgreementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LandownersTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseAgreementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.landownerId == item.id,
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

typedef $$LandownersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LandownersTable,
      Landowner,
      $$LandownersTableFilterComposer,
      $$LandownersTableOrderingComposer,
      $$LandownersTableAnnotationComposer,
      $$LandownersTableCreateCompanionBuilder,
      $$LandownersTableUpdateCompanionBuilder,
      (Landowner, $$LandownersTableReferences),
      Landowner,
      PrefetchHooks Function({bool projectsRefs, bool purchaseAgreementsRefs})
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String code,
      required String name,
      Value<String?> description,
      required String location,
      required String status,
      Value<String?> landownerId,
      Value<double> landAreaSqFt,
      Value<String> measurementUnit,
      Value<double?> displayArea,
      Value<double?> kattaValue,
      Value<double?> dhurValue,
      Value<double?> lengthFt,
      Value<double?> lengthIn,
      Value<double?> breadthFt,
      Value<double?> breadthIn,
      Value<double> purchasePrice,
      Value<double> actualCost,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> name,
      Value<String?> description,
      Value<String> location,
      Value<String> status,
      Value<String?> landownerId,
      Value<double> landAreaSqFt,
      Value<String> measurementUnit,
      Value<double?> displayArea,
      Value<double?> kattaValue,
      Value<double?> dhurValue,
      Value<double?> lengthFt,
      Value<double?> lengthIn,
      Value<double?> breadthFt,
      Value<double?> breadthIn,
      Value<double> purchasePrice,
      Value<double> actualCost,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LandownersTable _landownerIdTable(_$AppDatabase db) =>
      db.landowners.createAlias(
        $_aliasNameGenerator(db.projects.landownerId, db.landowners.id),
      );

  $$LandownersTableProcessedTableManager? get landownerId {
    final $_column = $_itemColumn<String>('landowner_id');
    if ($_column == null) return null;
    final manager = $$LandownersTableTableManager(
      $_db,
      $_db.landowners,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_landownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseAgreementsTable, List<PurchaseAgreement>>
  _purchaseAgreementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.purchaseAgreements,
        aliasName: $_aliasNameGenerator(
          db.projects.id,
          db.purchaseAgreements.projectId,
        ),
      );

  $$PurchaseAgreementsTableProcessedTableManager get purchaseAgreementsRefs {
    final manager = $$PurchaseAgreementsTableTableManager(
      $_db,
      $_db.purchaseAgreements,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseAgreementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProjectInvestorsTable, List<ProjectInvestor>>
  _projectInvestorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectInvestors,
    aliasName: $_aliasNameGenerator(
      db.projects.id,
      db.projectInvestors.projectId,
    ),
  );

  $$ProjectInvestorsTableProcessedTableManager get projectInvestorsRefs {
    final manager = $$ProjectInvestorsTableTableManager(
      $_db,
      $_db.projectInvestors,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _projectInvestorsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.projects.id, db.expenses.projectId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlotsTable, List<Plot>> _plotsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.plots,
    aliasName: $_aliasNameGenerator(db.projects.id, db.plots.projectId),
  );

  $$PlotsTableProcessedTableManager get plotsRefs {
    final manager = $$PlotsTableTableManager(
      $_db,
      $_db.plots,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_plotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: $_aliasNameGenerator(db.projects.id, db.sales.projectId),
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(db.projects.id, db.transactions.projectId),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DistributionsTable, List<Distribution>>
  _distributionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.distributions,
    aliasName: $_aliasNameGenerator(db.projects.id, db.distributions.projectId),
  );

  $$DistributionsTableProcessedTableManager get distributionsRefs {
    final manager = $$DistributionsTableTableManager(
      $_db,
      $_db.distributions,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_distributionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get landAreaSqFt => $composableBuilder(
    column: $table.landAreaSqFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dhurValue => $composableBuilder(
    column: $table.dhurValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthFt => $composableBuilder(
    column: $table.lengthFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthIn => $composableBuilder(
    column: $table.lengthIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breadthFt => $composableBuilder(
    column: $table.breadthFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breadthIn => $composableBuilder(
    column: $table.breadthIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get actualCost => $composableBuilder(
    column: $table.actualCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LandownersTableFilterComposer get landownerId {
    final $$LandownersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableFilterComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseAgreementsRefs(
    Expression<bool> Function($$PurchaseAgreementsTableFilterComposer f) f,
  ) {
    final $$PurchaseAgreementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseAgreements,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseAgreementsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseAgreements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> projectInvestorsRefs(
    Expression<bool> Function($$ProjectInvestorsTableFilterComposer f) f,
  ) {
    final $$ProjectInvestorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectInvestors,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectInvestorsTableFilterComposer(
            $db: $db,
            $table: $db.projectInvestors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> plotsRefs(
    Expression<bool> Function($$PlotsTableFilterComposer f) f,
  ) {
    final $$PlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableFilterComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> distributionsRefs(
    Expression<bool> Function($$DistributionsTableFilterComposer f) f,
  ) {
    final $$DistributionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distributions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistributionsTableFilterComposer(
            $db: $db,
            $table: $db.distributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get landAreaSqFt => $composableBuilder(
    column: $table.landAreaSqFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dhurValue => $composableBuilder(
    column: $table.dhurValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthFt => $composableBuilder(
    column: $table.lengthFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthIn => $composableBuilder(
    column: $table.lengthIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breadthFt => $composableBuilder(
    column: $table.breadthFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breadthIn => $composableBuilder(
    column: $table.breadthIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get actualCost => $composableBuilder(
    column: $table.actualCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LandownersTableOrderingComposer get landownerId {
    final $$LandownersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableOrderingComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
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

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get landAreaSqFt => $composableBuilder(
    column: $table.landAreaSqFt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dhurValue =>
      $composableBuilder(column: $table.dhurValue, builder: (column) => column);

  GeneratedColumn<double> get lengthFt =>
      $composableBuilder(column: $table.lengthFt, builder: (column) => column);

  GeneratedColumn<double> get lengthIn =>
      $composableBuilder(column: $table.lengthIn, builder: (column) => column);

  GeneratedColumn<double> get breadthFt =>
      $composableBuilder(column: $table.breadthFt, builder: (column) => column);

  GeneratedColumn<double> get breadthIn =>
      $composableBuilder(column: $table.breadthIn, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get actualCost => $composableBuilder(
    column: $table.actualCost,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$LandownersTableAnnotationComposer get landownerId {
    final $$LandownersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableAnnotationComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseAgreementsRefs<T extends Object>(
    Expression<T> Function($$PurchaseAgreementsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseAgreementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.purchaseAgreements,
          getReferencedColumn: (t) => t.projectId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseAgreementsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseAgreements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> projectInvestorsRefs<T extends Object>(
    Expression<T> Function($$ProjectInvestorsTableAnnotationComposer a) f,
  ) {
    final $$ProjectInvestorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectInvestors,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectInvestorsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectInvestors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> plotsRefs<T extends Object>(
    Expression<T> Function($$PlotsTableAnnotationComposer a) f,
  ) {
    final $$PlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.plots,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.plots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> distributionsRefs<T extends Object>(
    Expression<T> Function($$DistributionsTableAnnotationComposer a) f,
  ) {
    final $$DistributionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distributions,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistributionsTableAnnotationComposer(
            $db: $db,
            $table: $db.distributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({
            bool landownerId,
            bool purchaseAgreementsRefs,
            bool projectInvestorsRefs,
            bool expensesRefs,
            bool plotsRefs,
            bool salesRefs,
            bool transactionsRefs,
            bool distributionsRefs,
          })
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
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> landownerId = const Value.absent(),
                Value<double> landAreaSqFt = const Value.absent(),
                Value<String> measurementUnit = const Value.absent(),
                Value<double?> displayArea = const Value.absent(),
                Value<double?> kattaValue = const Value.absent(),
                Value<double?> dhurValue = const Value.absent(),
                Value<double?> lengthFt = const Value.absent(),
                Value<double?> lengthIn = const Value.absent(),
                Value<double?> breadthFt = const Value.absent(),
                Value<double?> breadthIn = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> actualCost = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                code: code,
                name: name,
                description: description,
                location: location,
                status: status,
                landownerId: landownerId,
                landAreaSqFt: landAreaSqFt,
                measurementUnit: measurementUnit,
                displayArea: displayArea,
                kattaValue: kattaValue,
                dhurValue: dhurValue,
                lengthFt: lengthFt,
                lengthIn: lengthIn,
                breadthFt: breadthFt,
                breadthIn: breadthIn,
                purchasePrice: purchasePrice,
                actualCost: actualCost,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                Value<String?> description = const Value.absent(),
                required String location,
                required String status,
                Value<String?> landownerId = const Value.absent(),
                Value<double> landAreaSqFt = const Value.absent(),
                Value<String> measurementUnit = const Value.absent(),
                Value<double?> displayArea = const Value.absent(),
                Value<double?> kattaValue = const Value.absent(),
                Value<double?> dhurValue = const Value.absent(),
                Value<double?> lengthFt = const Value.absent(),
                Value<double?> lengthIn = const Value.absent(),
                Value<double?> breadthFt = const Value.absent(),
                Value<double?> breadthIn = const Value.absent(),
                Value<double> purchasePrice = const Value.absent(),
                Value<double> actualCost = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                code: code,
                name: name,
                description: description,
                location: location,
                status: status,
                landownerId: landownerId,
                landAreaSqFt: landAreaSqFt,
                measurementUnit: measurementUnit,
                displayArea: displayArea,
                kattaValue: kattaValue,
                dhurValue: dhurValue,
                lengthFt: lengthFt,
                lengthIn: lengthIn,
                breadthFt: breadthFt,
                breadthIn: breadthIn,
                purchasePrice: purchasePrice,
                actualCost: actualCost,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                landownerId = false,
                purchaseAgreementsRefs = false,
                projectInvestorsRefs = false,
                expensesRefs = false,
                plotsRefs = false,
                salesRefs = false,
                transactionsRefs = false,
                distributionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseAgreementsRefs) db.purchaseAgreements,
                    if (projectInvestorsRefs) db.projectInvestors,
                    if (expensesRefs) db.expenses,
                    if (plotsRefs) db.plots,
                    if (salesRefs) db.sales,
                    if (transactionsRefs) db.transactions,
                    if (distributionsRefs) db.distributions,
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
                        if (landownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.landownerId,
                                    referencedTable: $$ProjectsTableReferences
                                        ._landownerIdTable(db),
                                    referencedColumn: $$ProjectsTableReferences
                                        ._landownerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseAgreementsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          PurchaseAgreement
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._purchaseAgreementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseAgreementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (projectInvestorsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          ProjectInvestor
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._projectInvestorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectInvestorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (plotsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Plot
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._plotsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).plotsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (salesRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Sale
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).salesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (distributionsRefs)
                        await $_getPrefetchedData<
                          Project,
                          $ProjectsTable,
                          Distribution
                        >(
                          currentTable: table,
                          referencedTable: $$ProjectsTableReferences
                              ._distributionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).distributionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.projectId == item.id,
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
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({
        bool landownerId,
        bool purchaseAgreementsRefs,
        bool projectInvestorsRefs,
        bool expensesRefs,
        bool plotsRefs,
        bool salesRefs,
        bool transactionsRefs,
        bool distributionsRefs,
      })
    >;
typedef $$PurchaseAgreementsTableCreateCompanionBuilder =
    PurchaseAgreementsCompanion Function({
      required String id,
      required String projectId,
      required String landownerId,
      required double totalPrice,
      required DateTime agreementDate,
      required String status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PurchaseAgreementsTableUpdateCompanionBuilder =
    PurchaseAgreementsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> landownerId,
      Value<double> totalPrice,
      Value<DateTime> agreementDate,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PurchaseAgreementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchaseAgreementsTable,
          PurchaseAgreement
        > {
  $$PurchaseAgreementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.purchaseAgreements.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LandownersTable _landownerIdTable(_$AppDatabase db) =>
      db.landowners.createAlias(
        $_aliasNameGenerator(
          db.purchaseAgreements.landownerId,
          db.landowners.id,
        ),
      );

  $$LandownersTableProcessedTableManager get landownerId {
    final $_column = $_itemColumn<String>('landowner_id')!;

    final manager = $$LandownersTableTableManager(
      $_db,
      $_db.landowners,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_landownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InstallmentsTable, List<Installment>>
  _installmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.installments,
    aliasName: $_aliasNameGenerator(
      db.purchaseAgreements.id,
      db.installments.purchaseAgreementId,
    ),
  );

  $$InstallmentsTableProcessedTableManager get installmentsRefs {
    final manager = $$InstallmentsTableTableManager($_db, $_db.installments)
        .filter(
          (f) =>
              f.purchaseAgreementId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_installmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseAgreementsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseAgreementsTable> {
  $$PurchaseAgreementsTableFilterComposer({
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

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get agreementDate => $composableBuilder(
    column: $table.agreementDate,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LandownersTableFilterComposer get landownerId {
    final $$LandownersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableFilterComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentsRefs(
    Expression<bool> Function($$InstallmentsTableFilterComposer f) f,
  ) {
    final $$InstallmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.purchaseAgreementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableFilterComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseAgreementsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseAgreementsTable> {
  $$PurchaseAgreementsTableOrderingComposer({
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

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get agreementDate => $composableBuilder(
    column: $table.agreementDate,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LandownersTableOrderingComposer get landownerId {
    final $$LandownersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableOrderingComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseAgreementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseAgreementsTable> {
  $$PurchaseAgreementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get agreementDate => $composableBuilder(
    column: $table.agreementDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LandownersTableAnnotationComposer get landownerId {
    final $$LandownersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.landownerId,
      referencedTable: $db.landowners,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LandownersTableAnnotationComposer(
            $db: $db,
            $table: $db.landowners,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> installmentsRefs<T extends Object>(
    Expression<T> Function($$InstallmentsTableAnnotationComposer a) f,
  ) {
    final $$InstallmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.purchaseAgreementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseAgreementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseAgreementsTable,
          PurchaseAgreement,
          $$PurchaseAgreementsTableFilterComposer,
          $$PurchaseAgreementsTableOrderingComposer,
          $$PurchaseAgreementsTableAnnotationComposer,
          $$PurchaseAgreementsTableCreateCompanionBuilder,
          $$PurchaseAgreementsTableUpdateCompanionBuilder,
          (PurchaseAgreement, $$PurchaseAgreementsTableReferences),
          PurchaseAgreement,
          PrefetchHooks Function({
            bool projectId,
            bool landownerId,
            bool installmentsRefs,
          })
        > {
  $$PurchaseAgreementsTableTableManager(
    _$AppDatabase db,
    $PurchaseAgreementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseAgreementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseAgreementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseAgreementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> landownerId = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<DateTime> agreementDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseAgreementsCompanion(
                id: id,
                projectId: projectId,
                landownerId: landownerId,
                totalPrice: totalPrice,
                agreementDate: agreementDate,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String landownerId,
                required double totalPrice,
                required DateTime agreementDate,
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseAgreementsCompanion.insert(
                id: id,
                projectId: projectId,
                landownerId: landownerId,
                totalPrice: totalPrice,
                agreementDate: agreementDate,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchaseAgreementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                landownerId = false,
                installmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentsRefs) db.installments,
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable:
                                        $$PurchaseAgreementsTableReferences
                                            ._projectIdTable(db),
                                    referencedColumn:
                                        $$PurchaseAgreementsTableReferences
                                            ._projectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (landownerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.landownerId,
                                    referencedTable:
                                        $$PurchaseAgreementsTableReferences
                                            ._landownerIdTable(db),
                                    referencedColumn:
                                        $$PurchaseAgreementsTableReferences
                                            ._landownerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentsRefs)
                        await $_getPrefetchedData<
                          PurchaseAgreement,
                          $PurchaseAgreementsTable,
                          Installment
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseAgreementsTableReferences
                              ._installmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseAgreementsTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseAgreementId == item.id,
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

typedef $$PurchaseAgreementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseAgreementsTable,
      PurchaseAgreement,
      $$PurchaseAgreementsTableFilterComposer,
      $$PurchaseAgreementsTableOrderingComposer,
      $$PurchaseAgreementsTableAnnotationComposer,
      $$PurchaseAgreementsTableCreateCompanionBuilder,
      $$PurchaseAgreementsTableUpdateCompanionBuilder,
      (PurchaseAgreement, $$PurchaseAgreementsTableReferences),
      PurchaseAgreement,
      PrefetchHooks Function({
        bool projectId,
        bool landownerId,
        bool installmentsRefs,
      })
    >;
typedef $$InvestorsTableCreateCompanionBuilder =
    InvestorsCompanion Function({
      required String id,
      required String name,
      required String phone,
      Value<String?> email,
      Value<String?> pan,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InvestorsTableUpdateCompanionBuilder =
    InvestorsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> email,
      Value<String?> pan,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InvestorsTableReferences
    extends BaseReferences<_$AppDatabase, $InvestorsTable, Investor> {
  $$InvestorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectInvestorsTable, List<ProjectInvestor>>
  _projectInvestorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.projectInvestors,
    aliasName: $_aliasNameGenerator(
      db.investors.id,
      db.projectInvestors.investorId,
    ),
  );

  $$ProjectInvestorsTableProcessedTableManager get projectInvestorsRefs {
    final manager = $$ProjectInvestorsTableTableManager(
      $_db,
      $_db.projectInvestors,
    ).filter((f) => f.investorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _projectInvestorsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DistributionsTable, List<Distribution>>
  _distributionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.distributions,
    aliasName: $_aliasNameGenerator(
      db.investors.id,
      db.distributions.investorId,
    ),
  );

  $$DistributionsTableProcessedTableManager get distributionsRefs {
    final manager = $$DistributionsTableTableManager(
      $_db,
      $_db.distributions,
    ).filter((f) => f.investorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_distributionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvestorsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectInvestorsRefs(
    Expression<bool> Function($$ProjectInvestorsTableFilterComposer f) f,
  ) {
    final $$ProjectInvestorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectInvestors,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectInvestorsTableFilterComposer(
            $db: $db,
            $table: $db.projectInvestors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> distributionsRefs(
    Expression<bool> Function($$DistributionsTableFilterComposer f) f,
  ) {
    final $$DistributionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distributions,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistributionsTableFilterComposer(
            $db: $db,
            $table: $db.distributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestorsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InvestorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestorsTable> {
  $$InvestorsTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> projectInvestorsRefs<T extends Object>(
    Expression<T> Function($$ProjectInvestorsTableAnnotationComposer a) f,
  ) {
    final $$ProjectInvestorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectInvestors,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectInvestorsTableAnnotationComposer(
            $db: $db,
            $table: $db.projectInvestors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> distributionsRefs<T extends Object>(
    Expression<T> Function($$DistributionsTableAnnotationComposer a) f,
  ) {
    final $$DistributionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.distributions,
      getReferencedColumn: (t) => t.investorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DistributionsTableAnnotationComposer(
            $db: $db,
            $table: $db.distributions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvestorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestorsTable,
          Investor,
          $$InvestorsTableFilterComposer,
          $$InvestorsTableOrderingComposer,
          $$InvestorsTableAnnotationComposer,
          $$InvestorsTableCreateCompanionBuilder,
          $$InvestorsTableUpdateCompanionBuilder,
          (Investor, $$InvestorsTableReferences),
          Investor,
          PrefetchHooks Function({
            bool projectInvestorsRefs,
            bool distributionsRefs,
          })
        > {
  $$InvestorsTableTableManager(_$AppDatabase db, $InvestorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestorsCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                pan: pan,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                Value<String?> email = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InvestorsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                pan: pan,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvestorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectInvestorsRefs = false, distributionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (projectInvestorsRefs) db.projectInvestors,
                    if (distributionsRefs) db.distributions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (projectInvestorsRefs)
                        await $_getPrefetchedData<
                          Investor,
                          $InvestorsTable,
                          ProjectInvestor
                        >(
                          currentTable: table,
                          referencedTable: $$InvestorsTableReferences
                              ._projectInvestorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestorsTableReferences(
                                db,
                                table,
                                p0,
                              ).projectInvestorsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.investorId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (distributionsRefs)
                        await $_getPrefetchedData<
                          Investor,
                          $InvestorsTable,
                          Distribution
                        >(
                          currentTable: table,
                          referencedTable: $$InvestorsTableReferences
                              ._distributionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvestorsTableReferences(
                                db,
                                table,
                                p0,
                              ).distributionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.investorId == item.id,
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

typedef $$InvestorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestorsTable,
      Investor,
      $$InvestorsTableFilterComposer,
      $$InvestorsTableOrderingComposer,
      $$InvestorsTableAnnotationComposer,
      $$InvestorsTableCreateCompanionBuilder,
      $$InvestorsTableUpdateCompanionBuilder,
      (Investor, $$InvestorsTableReferences),
      Investor,
      PrefetchHooks Function({
        bool projectInvestorsRefs,
        bool distributionsRefs,
      })
    >;
typedef $$ProjectInvestorsTableCreateCompanionBuilder =
    ProjectInvestorsCompanion Function({
      required String id,
      required String projectId,
      required String investorId,
      required double investedAmount,
      required double ownershipPercent,
      required String ownershipMethod,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ProjectInvestorsTableUpdateCompanionBuilder =
    ProjectInvestorsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> investorId,
      Value<double> investedAmount,
      Value<double> ownershipPercent,
      Value<String> ownershipMethod,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ProjectInvestorsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProjectInvestorsTable, ProjectInvestor> {
  $$ProjectInvestorsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.projectInvestors.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestorsTable _investorIdTable(_$AppDatabase db) =>
      db.investors.createAlias(
        $_aliasNameGenerator(db.projectInvestors.investorId, db.investors.id),
      );

  $$InvestorsTableProcessedTableManager get investorId {
    final $_column = $_itemColumn<String>('investor_id')!;

    final manager = $$InvestorsTableTableManager(
      $_db,
      $_db.investors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProjectInvestorsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectInvestorsTable> {
  $$ProjectInvestorsTableFilterComposer({
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

  ColumnFilters<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ownershipPercent => $composableBuilder(
    column: $table.ownershipPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownershipMethod => $composableBuilder(
    column: $table.ownershipMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableFilterComposer get investorId {
    final $$InvestorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableFilterComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectInvestorsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectInvestorsTable> {
  $$ProjectInvestorsTableOrderingComposer({
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

  ColumnOrderings<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ownershipPercent => $composableBuilder(
    column: $table.ownershipPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownershipMethod => $composableBuilder(
    column: $table.ownershipMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableOrderingComposer get investorId {
    final $$InvestorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableOrderingComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectInvestorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectInvestorsTable> {
  $$ProjectInvestorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get investedAmount => $composableBuilder(
    column: $table.investedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ownershipPercent => $composableBuilder(
    column: $table.ownershipPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownershipMethod => $composableBuilder(
    column: $table.ownershipMethod,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableAnnotationComposer get investorId {
    final $$InvestorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableAnnotationComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectInvestorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectInvestorsTable,
          ProjectInvestor,
          $$ProjectInvestorsTableFilterComposer,
          $$ProjectInvestorsTableOrderingComposer,
          $$ProjectInvestorsTableAnnotationComposer,
          $$ProjectInvestorsTableCreateCompanionBuilder,
          $$ProjectInvestorsTableUpdateCompanionBuilder,
          (ProjectInvestor, $$ProjectInvestorsTableReferences),
          ProjectInvestor,
          PrefetchHooks Function({bool projectId, bool investorId})
        > {
  $$ProjectInvestorsTableTableManager(
    _$AppDatabase db,
    $ProjectInvestorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectInvestorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectInvestorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectInvestorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> investorId = const Value.absent(),
                Value<double> investedAmount = const Value.absent(),
                Value<double> ownershipPercent = const Value.absent(),
                Value<String> ownershipMethod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectInvestorsCompanion(
                id: id,
                projectId: projectId,
                investorId: investorId,
                investedAmount: investedAmount,
                ownershipPercent: ownershipPercent,
                ownershipMethod: ownershipMethod,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String investorId,
                required double investedAmount,
                required double ownershipPercent,
                required String ownershipMethod,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectInvestorsCompanion.insert(
                id: id,
                projectId: projectId,
                investorId: investorId,
                investedAmount: investedAmount,
                ownershipPercent: ownershipPercent,
                ownershipMethod: ownershipMethod,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectInvestorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, investorId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable:
                                    $$ProjectInvestorsTableReferences
                                        ._projectIdTable(db),
                                referencedColumn:
                                    $$ProjectInvestorsTableReferences
                                        ._projectIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (investorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investorId,
                                referencedTable:
                                    $$ProjectInvestorsTableReferences
                                        ._investorIdTable(db),
                                referencedColumn:
                                    $$ProjectInvestorsTableReferences
                                        ._investorIdTable(db)
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

typedef $$ProjectInvestorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectInvestorsTable,
      ProjectInvestor,
      $$ProjectInvestorsTableFilterComposer,
      $$ProjectInvestorsTableOrderingComposer,
      $$ProjectInvestorsTableAnnotationComposer,
      $$ProjectInvestorsTableCreateCompanionBuilder,
      $$ProjectInvestorsTableUpdateCompanionBuilder,
      (ProjectInvestor, $$ProjectInvestorsTableReferences),
      ProjectInvestor,
      PrefetchHooks Function({bool projectId, bool investorId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      required String id,
      required String projectId,
      required String category,
      required double amount,
      required DateTime expenseDate,
      Value<String?> vendor,
      Value<bool> isCapitalized,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> category,
      Value<double> amount,
      Value<DateTime> expenseDate,
      Value<String?> vendor,
      Value<bool> isCapitalized,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.expenses.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vendor => $composableBuilder(
    column: $table.vendor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCapitalized => $composableBuilder(
    column: $table.isCapitalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vendor => $composableBuilder(
    column: $table.vendor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCapitalized => $composableBuilder(
    column: $table.isCapitalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get expenseDate => $composableBuilder(
    column: $table.expenseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vendor =>
      $composableBuilder(column: $table.vendor, builder: (column) => column);

  GeneratedColumn<bool> get isCapitalized => $composableBuilder(
    column: $table.isCapitalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool projectId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> expenseDate = const Value.absent(),
                Value<String?> vendor = const Value.absent(),
                Value<bool> isCapitalized = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                projectId: projectId,
                category: category,
                amount: amount,
                expenseDate: expenseDate,
                vendor: vendor,
                isCapitalized: isCapitalized,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String category,
                required double amount,
                required DateTime expenseDate,
                Value<String?> vendor = const Value.absent(),
                Value<bool> isCapitalized = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                projectId: projectId,
                category: category,
                amount: amount,
                expenseDate: expenseDate,
                vendor: vendor,
                isCapitalized: isCapitalized,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$ExpensesTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._projectIdTable(db)
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

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$PlotsTableCreateCompanionBuilder =
    PlotsCompanion Function({
      required String id,
      required String projectId,
      required String plotNumber,
      required double areaSqFt,
      Value<String> measurementUnit,
      Value<double?> displayArea,
      Value<double?> kattaValue,
      Value<double?> dhurValue,
      Value<double?> lengthFt,
      Value<double?> lengthIn,
      Value<double?> breadthFt,
      Value<double?> breadthIn,
      Value<double> allocatedCost,
      Value<double> expectedPrice,
      required String status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PlotsTableUpdateCompanionBuilder =
    PlotsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> plotNumber,
      Value<double> areaSqFt,
      Value<String> measurementUnit,
      Value<double?> displayArea,
      Value<double?> kattaValue,
      Value<double?> dhurValue,
      Value<double?> lengthFt,
      Value<double?> lengthIn,
      Value<double?> breadthFt,
      Value<double?> breadthIn,
      Value<double> allocatedCost,
      Value<double> expectedPrice,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlotsTableReferences
    extends BaseReferences<_$AppDatabase, $PlotsTable, Plot> {
  $$PlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.plots.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlotsTableFilterComposer extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableFilterComposer({
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

  ColumnFilters<String> get plotNumber => $composableBuilder(
    column: $table.plotNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get areaSqFt => $composableBuilder(
    column: $table.areaSqFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dhurValue => $composableBuilder(
    column: $table.dhurValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthFt => $composableBuilder(
    column: $table.lengthFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lengthIn => $composableBuilder(
    column: $table.lengthIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breadthFt => $composableBuilder(
    column: $table.breadthFt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get breadthIn => $composableBuilder(
    column: $table.breadthIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get allocatedCost => $composableBuilder(
    column: $table.allocatedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedPrice => $composableBuilder(
    column: $table.expectedPrice,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableOrderingComposer({
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

  ColumnOrderings<String> get plotNumber => $composableBuilder(
    column: $table.plotNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get areaSqFt => $composableBuilder(
    column: $table.areaSqFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dhurValue => $composableBuilder(
    column: $table.dhurValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthFt => $composableBuilder(
    column: $table.lengthFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lengthIn => $composableBuilder(
    column: $table.lengthIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breadthFt => $composableBuilder(
    column: $table.breadthFt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get breadthIn => $composableBuilder(
    column: $table.breadthIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get allocatedCost => $composableBuilder(
    column: $table.allocatedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedPrice => $composableBuilder(
    column: $table.expectedPrice,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlotsTable> {
  $$PlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get plotNumber => $composableBuilder(
    column: $table.plotNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get areaSqFt =>
      $composableBuilder(column: $table.areaSqFt, builder: (column) => column);

  GeneratedColumn<String> get measurementUnit => $composableBuilder(
    column: $table.measurementUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get displayArea => $composableBuilder(
    column: $table.displayArea,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kattaValue => $composableBuilder(
    column: $table.kattaValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dhurValue =>
      $composableBuilder(column: $table.dhurValue, builder: (column) => column);

  GeneratedColumn<double> get lengthFt =>
      $composableBuilder(column: $table.lengthFt, builder: (column) => column);

  GeneratedColumn<double> get lengthIn =>
      $composableBuilder(column: $table.lengthIn, builder: (column) => column);

  GeneratedColumn<double> get breadthFt =>
      $composableBuilder(column: $table.breadthFt, builder: (column) => column);

  GeneratedColumn<double> get breadthIn =>
      $composableBuilder(column: $table.breadthIn, builder: (column) => column);

  GeneratedColumn<double> get allocatedCost => $composableBuilder(
    column: $table.allocatedCost,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedPrice => $composableBuilder(
    column: $table.expectedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlotsTable,
          Plot,
          $$PlotsTableFilterComposer,
          $$PlotsTableOrderingComposer,
          $$PlotsTableAnnotationComposer,
          $$PlotsTableCreateCompanionBuilder,
          $$PlotsTableUpdateCompanionBuilder,
          (Plot, $$PlotsTableReferences),
          Plot,
          PrefetchHooks Function({bool projectId})
        > {
  $$PlotsTableTableManager(_$AppDatabase db, $PlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> plotNumber = const Value.absent(),
                Value<double> areaSqFt = const Value.absent(),
                Value<String> measurementUnit = const Value.absent(),
                Value<double?> displayArea = const Value.absent(),
                Value<double?> kattaValue = const Value.absent(),
                Value<double?> dhurValue = const Value.absent(),
                Value<double?> lengthFt = const Value.absent(),
                Value<double?> lengthIn = const Value.absent(),
                Value<double?> breadthFt = const Value.absent(),
                Value<double?> breadthIn = const Value.absent(),
                Value<double> allocatedCost = const Value.absent(),
                Value<double> expectedPrice = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotsCompanion(
                id: id,
                projectId: projectId,
                plotNumber: plotNumber,
                areaSqFt: areaSqFt,
                measurementUnit: measurementUnit,
                displayArea: displayArea,
                kattaValue: kattaValue,
                dhurValue: dhurValue,
                lengthFt: lengthFt,
                lengthIn: lengthIn,
                breadthFt: breadthFt,
                breadthIn: breadthIn,
                allocatedCost: allocatedCost,
                expectedPrice: expectedPrice,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String plotNumber,
                required double areaSqFt,
                Value<String> measurementUnit = const Value.absent(),
                Value<double?> displayArea = const Value.absent(),
                Value<double?> kattaValue = const Value.absent(),
                Value<double?> dhurValue = const Value.absent(),
                Value<double?> lengthFt = const Value.absent(),
                Value<double?> lengthIn = const Value.absent(),
                Value<double?> breadthFt = const Value.absent(),
                Value<double?> breadthIn = const Value.absent(),
                Value<double> allocatedCost = const Value.absent(),
                Value<double> expectedPrice = const Value.absent(),
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlotsCompanion.insert(
                id: id,
                projectId: projectId,
                plotNumber: plotNumber,
                areaSqFt: areaSqFt,
                measurementUnit: measurementUnit,
                displayArea: displayArea,
                kattaValue: kattaValue,
                dhurValue: dhurValue,
                lengthFt: lengthFt,
                lengthIn: lengthIn,
                breadthFt: breadthFt,
                breadthIn: breadthIn,
                allocatedCost: allocatedCost,
                expectedPrice: expectedPrice,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PlotsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$PlotsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$PlotsTableReferences
                                    ._projectIdTable(db)
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

typedef $$PlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlotsTable,
      Plot,
      $$PlotsTableFilterComposer,
      $$PlotsTableOrderingComposer,
      $$PlotsTableAnnotationComposer,
      $$PlotsTableCreateCompanionBuilder,
      $$PlotsTableUpdateCompanionBuilder,
      (Plot, $$PlotsTableReferences),
      Plot,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$BuyersTableCreateCompanionBuilder =
    BuyersCompanion Function({
      required String id,
      required String name,
      required String phone,
      Value<String?> email,
      Value<String?> pan,
      Value<String?> aadhar,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$BuyersTableUpdateCompanionBuilder =
    BuyersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> email,
      Value<String?> pan,
      Value<String?> aadhar,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BuyersTableReferences
    extends BaseReferences<_$AppDatabase, $BuyersTable, Buyer> {
  $$BuyersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: $_aliasNameGenerator(db.buyers.id, db.sales.buyerId),
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.buyerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BuyersTableFilterComposer
    extends Composer<_$AppDatabase, $BuyersTable> {
  $$BuyersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aadhar => $composableBuilder(
    column: $table.aadhar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.buyerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuyersTableOrderingComposer
    extends Composer<_$AppDatabase, $BuyersTable> {
  $$BuyersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aadhar => $composableBuilder(
    column: $table.aadhar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuyersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuyersTable> {
  $$BuyersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get aadhar =>
      $composableBuilder(column: $table.aadhar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.buyerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuyersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuyersTable,
          Buyer,
          $$BuyersTableFilterComposer,
          $$BuyersTableOrderingComposer,
          $$BuyersTableAnnotationComposer,
          $$BuyersTableCreateCompanionBuilder,
          $$BuyersTableUpdateCompanionBuilder,
          (Buyer, $$BuyersTableReferences),
          Buyer,
          PrefetchHooks Function({bool salesRefs})
        > {
  $$BuyersTableTableManager(_$AppDatabase db, $BuyersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuyersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuyersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuyersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> aadhar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuyersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                pan: pan,
                aadhar: aadhar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                Value<String?> email = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> aadhar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuyersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                pan: pan,
                aadhar: aadhar,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BuyersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({salesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (salesRefs) db.sales],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesRefs)
                    await $_getPrefetchedData<Buyer, $BuyersTable, Sale>(
                      currentTable: table,
                      referencedTable: $$BuyersTableReferences._salesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$BuyersTableReferences(db, table, p0).salesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.buyerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BuyersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuyersTable,
      Buyer,
      $$BuyersTableFilterComposer,
      $$BuyersTableOrderingComposer,
      $$BuyersTableAnnotationComposer,
      $$BuyersTableCreateCompanionBuilder,
      $$BuyersTableUpdateCompanionBuilder,
      (Buyer, $$BuyersTableReferences),
      Buyer,
      PrefetchHooks Function({bool salesRefs})
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      required String id,
      required String projectId,
      required String buyerId,
      required String saleType,
      required double agreedPrice,
      Value<double> saleExpenses,
      Value<double?> circleRateValue,
      required DateTime saleDate,
      required String status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> buyerId,
      Value<String> saleType,
      Value<double> agreedPrice,
      Value<double> saleExpenses,
      Value<double?> circleRateValue,
      Value<DateTime> saleDate,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, Sale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.sales.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BuyersTable _buyerIdTable(_$AppDatabase db) => db.buyers.createAlias(
    $_aliasNameGenerator(db.sales.buyerId, db.buyers.id),
  );

  $$BuyersTableProcessedTableManager get buyerId {
    final $_column = $_itemColumn<String>('buyer_id')!;

    final manager = $$BuyersTableTableManager(
      $_db,
      $_db.buyers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buyerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InstallmentsTable, List<Installment>>
  _installmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.installments,
    aliasName: $_aliasNameGenerator(db.sales.id, db.installments.saleId),
  );

  $$InstallmentsTableProcessedTableManager get installmentsRefs {
    final manager = $$InstallmentsTableTableManager(
      $_db,
      $_db.installments,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_installmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
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

  ColumnFilters<String> get saleType => $composableBuilder(
    column: $table.saleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get agreedPrice => $composableBuilder(
    column: $table.agreedPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saleExpenses => $composableBuilder(
    column: $table.saleExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get circleRateValue => $composableBuilder(
    column: $table.circleRateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
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

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableFilterComposer get buyerId {
    final $$BuyersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableFilterComposer(
            $db: $db,
            $table: $db.buyers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentsRefs(
    Expression<bool> Function($$InstallmentsTableFilterComposer f) f,
  ) {
    final $$InstallmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableFilterComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
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

  ColumnOrderings<String> get saleType => $composableBuilder(
    column: $table.saleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get agreedPrice => $composableBuilder(
    column: $table.agreedPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saleExpenses => $composableBuilder(
    column: $table.saleExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get circleRateValue => $composableBuilder(
    column: $table.circleRateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
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

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableOrderingComposer get buyerId {
    final $$BuyersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableOrderingComposer(
            $db: $db,
            $table: $db.buyers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleType =>
      $composableBuilder(column: $table.saleType, builder: (column) => column);

  GeneratedColumn<double> get agreedPrice => $composableBuilder(
    column: $table.agreedPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saleExpenses => $composableBuilder(
    column: $table.saleExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<double> get circleRateValue => $composableBuilder(
    column: $table.circleRateValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BuyersTableAnnotationComposer get buyerId {
    final $$BuyersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buyerId,
      referencedTable: $db.buyers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuyersTableAnnotationComposer(
            $db: $db,
            $table: $db.buyers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> installmentsRefs<T extends Object>(
    Expression<T> Function($$InstallmentsTableAnnotationComposer a) f,
  ) {
    final $$InstallmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, $$SalesTableReferences),
          Sale,
          PrefetchHooks Function({
            bool projectId,
            bool buyerId,
            bool installmentsRefs,
          })
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> buyerId = const Value.absent(),
                Value<String> saleType = const Value.absent(),
                Value<double> agreedPrice = const Value.absent(),
                Value<double> saleExpenses = const Value.absent(),
                Value<double?> circleRateValue = const Value.absent(),
                Value<DateTime> saleDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                projectId: projectId,
                buyerId: buyerId,
                saleType: saleType,
                agreedPrice: agreedPrice,
                saleExpenses: saleExpenses,
                circleRateValue: circleRateValue,
                saleDate: saleDate,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String buyerId,
                required String saleType,
                required double agreedPrice,
                Value<double> saleExpenses = const Value.absent(),
                Value<double?> circleRateValue = const Value.absent(),
                required DateTime saleDate,
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                projectId: projectId,
                buyerId: buyerId,
                saleType: saleType,
                agreedPrice: agreedPrice,
                saleExpenses: saleExpenses,
                circleRateValue: circleRateValue,
                saleDate: saleDate,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({projectId = false, buyerId = false, installmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentsRefs) db.installments,
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
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$SalesTableReferences
                                        ._projectIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._projectIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (buyerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.buyerId,
                                    referencedTable: $$SalesTableReferences
                                        ._buyerIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._buyerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentsRefs)
                        await $_getPrefetchedData<
                          Sale,
                          $SalesTable,
                          Installment
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._installmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
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

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, $$SalesTableReferences),
      Sale,
      PrefetchHooks Function({
        bool projectId,
        bool buyerId,
        bool installmentsRefs,
      })
    >;
typedef $$InstallmentsTableCreateCompanionBuilder =
    InstallmentsCompanion Function({
      required String id,
      Value<String?> saleId,
      Value<String?> purchaseAgreementId,
      required int installmentNumber,
      required DateTime dueDate,
      required double dueAmount,
      Value<double> paidAmount,
      required String status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$InstallmentsTableUpdateCompanionBuilder =
    InstallmentsCompanion Function({
      Value<String> id,
      Value<String?> saleId,
      Value<String?> purchaseAgreementId,
      Value<int> installmentNumber,
      Value<DateTime> dueDate,
      Value<double> dueAmount,
      Value<double> paidAmount,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$InstallmentsTableReferences
    extends BaseReferences<_$AppDatabase, $InstallmentsTable, Installment> {
  $$InstallmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales.createAlias(
    $_aliasNameGenerator(db.installments.saleId, db.sales.id),
  );

  $$SalesTableProcessedTableManager? get saleId {
    final $_column = $_itemColumn<String>('sale_id');
    if ($_column == null) return null;
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PurchaseAgreementsTable _purchaseAgreementIdTable(_$AppDatabase db) =>
      db.purchaseAgreements.createAlias(
        $_aliasNameGenerator(
          db.installments.purchaseAgreementId,
          db.purchaseAgreements.id,
        ),
      );

  $$PurchaseAgreementsTableProcessedTableManager? get purchaseAgreementId {
    final $_column = $_itemColumn<String>('purchase_agreement_id');
    if ($_column == null) return null;
    final manager = $$PurchaseAgreementsTableTableManager(
      $_db,
      $_db.purchaseAgreements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseAgreementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: $_aliasNameGenerator(
      db.installments.id,
      db.transactions.installmentId,
    ),
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.installmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstallmentsTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableFilterComposer({
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

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dueAmount => $composableBuilder(
    column: $table.dueAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
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

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseAgreementsTableFilterComposer get purchaseAgreementId {
    final $$PurchaseAgreementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseAgreementId,
      referencedTable: $db.purchaseAgreements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseAgreementsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseAgreements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.installmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableOrderingComposer({
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

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dueAmount => $composableBuilder(
    column: $table.dueAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
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

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseAgreementsTableOrderingComposer get purchaseAgreementId {
    final $$PurchaseAgreementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseAgreementId,
      referencedTable: $db.purchaseAgreements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseAgreementsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseAgreements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstallmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentsTable> {
  $$InstallmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get dueAmount =>
      $composableBuilder(column: $table.dueAmount, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseAgreementsTableAnnotationComposer get purchaseAgreementId {
    final $$PurchaseAgreementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.purchaseAgreementId,
          referencedTable: $db.purchaseAgreements,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PurchaseAgreementsTableAnnotationComposer(
                $db: $db,
                $table: $db.purchaseAgreements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.installmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallmentsTable,
          Installment,
          $$InstallmentsTableFilterComposer,
          $$InstallmentsTableOrderingComposer,
          $$InstallmentsTableAnnotationComposer,
          $$InstallmentsTableCreateCompanionBuilder,
          $$InstallmentsTableUpdateCompanionBuilder,
          (Installment, $$InstallmentsTableReferences),
          Installment,
          PrefetchHooks Function({
            bool saleId,
            bool purchaseAgreementId,
            bool transactionsRefs,
          })
        > {
  $$InstallmentsTableTableManager(_$AppDatabase db, $InstallmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> saleId = const Value.absent(),
                Value<String?> purchaseAgreementId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<double> dueAmount = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsCompanion(
                id: id,
                saleId: saleId,
                purchaseAgreementId: purchaseAgreementId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                dueAmount: dueAmount,
                paidAmount: paidAmount,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> saleId = const Value.absent(),
                Value<String?> purchaseAgreementId = const Value.absent(),
                required int installmentNumber,
                required DateTime dueDate,
                required double dueAmount,
                Value<double> paidAmount = const Value.absent(),
                required String status,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsCompanion.insert(
                id: id,
                saleId: saleId,
                purchaseAgreementId: purchaseAgreementId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                dueAmount: dueAmount,
                paidAmount: paidAmount,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstallmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                saleId = false,
                purchaseAgreementId = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
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
                        if (saleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.saleId,
                                    referencedTable:
                                        $$InstallmentsTableReferences
                                            ._saleIdTable(db),
                                    referencedColumn:
                                        $$InstallmentsTableReferences
                                            ._saleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (purchaseAgreementId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.purchaseAgreementId,
                                    referencedTable:
                                        $$InstallmentsTableReferences
                                            ._purchaseAgreementIdTable(db),
                                    referencedColumn:
                                        $$InstallmentsTableReferences
                                            ._purchaseAgreementIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Installment,
                          $InstallmentsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$InstallmentsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.installmentId == item.id,
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

typedef $$InstallmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallmentsTable,
      Installment,
      $$InstallmentsTableFilterComposer,
      $$InstallmentsTableOrderingComposer,
      $$InstallmentsTableAnnotationComposer,
      $$InstallmentsTableCreateCompanionBuilder,
      $$InstallmentsTableUpdateCompanionBuilder,
      (Installment, $$InstallmentsTableReferences),
      Installment,
      PrefetchHooks Function({
        bool saleId,
        bool purchaseAgreementId,
        bool transactionsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String projectId,
      Value<String?> installmentId,
      required double amount,
      required DateTime paymentDate,
      required String paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> receiptPath,
      Value<bool> isVoided,
      Value<String?> voidReason,
      required String createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String?> installmentId,
      Value<double> amount,
      Value<DateTime> paymentDate,
      Value<String> paymentMethod,
      Value<String?> referenceNumber,
      Value<String?> receiptPath,
      Value<bool> isVoided,
      Value<String?> voidReason,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$AppDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.transactions.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InstallmentsTable _installmentIdTable(_$AppDatabase db) =>
      db.installments.createAlias(
        $_aliasNameGenerator(db.transactions.installmentId, db.installments.id),
      );

  $$InstallmentsTableProcessedTableManager? get installmentId {
    final $_column = $_itemColumn<String>('installment_id');
    if ($_column == null) return null;
    final manager = $$InstallmentsTableTableManager(
      $_db,
      $_db.installments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_installmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsTableFilterComposer get installmentId {
    final $$InstallmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installmentId,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableFilterComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVoided => $composableBuilder(
    column: $table.isVoided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsTableOrderingComposer get installmentId {
    final $$InstallmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installmentId,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableOrderingComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isVoided =>
      $composableBuilder(column: $table.isVoided, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsTableAnnotationComposer get installmentId {
    final $$InstallmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.installmentId,
      referencedTable: $db.installments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.installments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({bool projectId, bool installmentId})
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String?> installmentId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                projectId: projectId,
                installmentId: installmentId,
                amount: amount,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                receiptPath: receiptPath,
                isVoided: isVoided,
                voidReason: voidReason,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                Value<String?> installmentId = const Value.absent(),
                required double amount,
                required DateTime paymentDate,
                required String paymentMethod,
                Value<String?> referenceNumber = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<bool> isVoided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                required String createdBy,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                projectId: projectId,
                installmentId: installmentId,
                amount: amount,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                referenceNumber: referenceNumber,
                receiptPath: receiptPath,
                isVoided: isVoided,
                voidReason: voidReason,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, installmentId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$TransactionsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (installmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.installmentId,
                                referencedTable: $$TransactionsTableReferences
                                    ._installmentIdTable(db),
                                referencedColumn: $$TransactionsTableReferences
                                    ._installmentIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({bool projectId, bool installmentId})
    >;
typedef $$DistributionsTableCreateCompanionBuilder =
    DistributionsCompanion Function({
      required String id,
      required String projectId,
      required String investorId,
      required double amount,
      required DateTime distributionDate,
      Value<String?> notes,
      required String createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DistributionsTableUpdateCompanionBuilder =
    DistributionsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> investorId,
      Value<double> amount,
      Value<DateTime> distributionDate,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DistributionsTableReferences
    extends BaseReferences<_$AppDatabase, $DistributionsTable, Distribution> {
  $$DistributionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProjectsTable _projectIdTable(_$AppDatabase db) =>
      db.projects.createAlias(
        $_aliasNameGenerator(db.distributions.projectId, db.projects.id),
      );

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvestorsTable _investorIdTable(_$AppDatabase db) =>
      db.investors.createAlias(
        $_aliasNameGenerator(db.distributions.investorId, db.investors.id),
      );

  $$InvestorsTableProcessedTableManager get investorId {
    final $_column = $_itemColumn<String>('investor_id')!;

    final manager = $$InvestorsTableTableManager(
      $_db,
      $_db.investors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_investorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DistributionsTableFilterComposer
    extends Composer<_$AppDatabase, $DistributionsTable> {
  $$DistributionsTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get distributionDate => $composableBuilder(
    column: $table.distributionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableFilterComposer get investorId {
    final $$InvestorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableFilterComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DistributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DistributionsTable> {
  $$DistributionsTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get distributionDate => $composableBuilder(
    column: $table.distributionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableOrderingComposer get investorId {
    final $$InvestorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableOrderingComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DistributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DistributionsTable> {
  $$DistributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get distributionDate => $composableBuilder(
    column: $table.distributionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvestorsTableAnnotationComposer get investorId {
    final $$InvestorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.investorId,
      referencedTable: $db.investors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestorsTableAnnotationComposer(
            $db: $db,
            $table: $db.investors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DistributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DistributionsTable,
          Distribution,
          $$DistributionsTableFilterComposer,
          $$DistributionsTableOrderingComposer,
          $$DistributionsTableAnnotationComposer,
          $$DistributionsTableCreateCompanionBuilder,
          $$DistributionsTableUpdateCompanionBuilder,
          (Distribution, $$DistributionsTableReferences),
          Distribution,
          PrefetchHooks Function({bool projectId, bool investorId})
        > {
  $$DistributionsTableTableManager(_$AppDatabase db, $DistributionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistributionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> investorId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> distributionDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DistributionsCompanion(
                id: id,
                projectId: projectId,
                investorId: investorId,
                amount: amount,
                distributionDate: distributionDate,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String investorId,
                required double amount,
                required DateTime distributionDate,
                Value<String?> notes = const Value.absent(),
                required String createdBy,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DistributionsCompanion.insert(
                id: id,
                projectId: projectId,
                investorId: investorId,
                amount: amount,
                distributionDate: distributionDate,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DistributionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false, investorId = false}) {
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
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$DistributionsTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$DistributionsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (investorId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.investorId,
                                referencedTable: $$DistributionsTableReferences
                                    ._investorIdTable(db),
                                referencedColumn: $$DistributionsTableReferences
                                    ._investorIdTable(db)
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

typedef $$DistributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DistributionsTable,
      Distribution,
      $$DistributionsTableFilterComposer,
      $$DistributionsTableOrderingComposer,
      $$DistributionsTableAnnotationComposer,
      $$DistributionsTableCreateCompanionBuilder,
      $$DistributionsTableUpdateCompanionBuilder,
      (Distribution, $$DistributionsTableReferences),
      Distribution,
      PrefetchHooks Function({bool projectId, bool investorId})
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      required String id,
      required String userId,
      required String action,
      required String entityType,
      required String entityId,
      required String details,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> action,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> details,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
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

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
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

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
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

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                details: details,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String action,
                required String entityType,
                required String entityId,
                required String details,
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                userId: userId,
                action: action,
                entityType: entityType,
                entityId: entityId,
                details: details,
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

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$LandownersTableTableManager get landowners =>
      $$LandownersTableTableManager(_db, _db.landowners);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$PurchaseAgreementsTableTableManager get purchaseAgreements =>
      $$PurchaseAgreementsTableTableManager(_db, _db.purchaseAgreements);
  $$InvestorsTableTableManager get investors =>
      $$InvestorsTableTableManager(_db, _db.investors);
  $$ProjectInvestorsTableTableManager get projectInvestors =>
      $$ProjectInvestorsTableTableManager(_db, _db.projectInvestors);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$PlotsTableTableManager get plots =>
      $$PlotsTableTableManager(_db, _db.plots);
  $$BuyersTableTableManager get buyers =>
      $$BuyersTableTableManager(_db, _db.buyers);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$InstallmentsTableTableManager get installments =>
      $$InstallmentsTableTableManager(_db, _db.installments);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$DistributionsTableTableManager get distributions =>
      $$DistributionsTableTableManager(_db, _db.distributions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
