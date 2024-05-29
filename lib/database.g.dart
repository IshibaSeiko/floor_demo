// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PersonDao? _personDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Person` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `nickname` TEXT, `age` INTEGER, `gender` TEXT, `createAt` INTEGER NOT NULL, `updateAt` INTEGER, `profileImage` BLOB)');
        await database.execute(
            'CREATE INDEX `index_Person_name_nickname_age_gender_createAt_updateAt_profileImage` ON `Person` (`name`, `nickname`, `age`, `gender`, `createAt`, `updateAt`, `profileImage`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PersonDao get personDao {
    return _personDaoInstance ??= _$PersonDao(database, changeListener);
  }
}

class _$PersonDao extends PersonDao {
  _$PersonDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _personInsertionAdapter = InsertionAdapter(
            database,
            'Person',
            (Person item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'nickname': item.nickname,
                  'age': item.age,
                  'gender': _genderConverter.encode(item.gender),
                  'createAt': _nonNullDateTimeConverter.encode(item.createAt),
                  'updateAt': _dateTimeConverter.encode(item.updateAt),
                  'profileImage': item.profileImage
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Person> _personInsertionAdapter;

  @override
  Stream<List<Person>> findAllPeople() {
    return _queryAdapter.queryListStream('SELECT * FROM Person',
        mapper: (Map<String, Object?> row) => Person(
            id: row['id'] as int?,
            name: row['name'] as String,
            nickname: row['nickname'] as String?,
            age: row['age'] as int?,
            gender: _genderConverter.decode(row['gender'] as String?),
            createAt: _nonNullDateTimeConverter.decode(row['createAt'] as int),
            updateAt: _dateTimeConverter.decode(row['updateAt'] as int?),
            profileImage: row['profileImage'] as Uint8List?),
        queryableName: 'Person',
        isView: false);
  }

  @override
  Stream<List<String>> findAllPeopleName() {
    return _queryAdapter.queryListStream('SELECT name FROM Person',
        mapper: (Map<String, Object?> row) => row.values.first as String,
        queryableName: 'Person',
        isView: false);
  }

  @override
  Stream<Person?> findPersonById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Person WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Person(
            id: row['id'] as int?,
            name: row['name'] as String,
            nickname: row['nickname'] as String?,
            age: row['age'] as int?,
            gender: _genderConverter.decode(row['gender'] as String?),
            createAt: _nonNullDateTimeConverter.decode(row['createAt'] as int),
            updateAt: _dateTimeConverter.decode(row['updateAt'] as int?),
            profileImage: row['profileImage'] as Uint8List?),
        arguments: [id],
        queryableName: 'Person',
        isView: false);
  }

  @override
  Future<void> insertPerson(Person person) async {
    await _personInsertionAdapter.insert(person, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _genderConverter = GenderConverter();
final _dateTimeConverter = DateTimeConverter();
final _nonNullDateTimeConverter = NonNullDateTimeConverter();
