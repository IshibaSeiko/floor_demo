import 'dart:typed_data';

import 'package:floor/floor.dart';

enum Gender {
  male,
  female,
  other,
}

@Entity(indices: [
  Index(value: [
    'name',
    'nickname',
    'age',
    'gender',
    'createAt',
    'updateAt',
    'profileImage',
  ])
])
class Person {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  @primaryKey
  final String name;
  final String? nickname;
  final int? age;
  final Gender? gender;
  final DateTime createAt;
  final DateTime? updateAt;
  final Uint8List? profileImage;

  Person(
      {this.id,
      required this.name,
      required this.nickname,
      required this.age,
      required this.gender,
      required this.createAt,
      required this.updateAt,
      required this.profileImage});
}

class GenderConverter extends TypeConverter<Gender?, String?> {
  @override
  Gender? decode(String? databaseValue) {
    return databaseValue == null ? null : Gender.values.byName(databaseValue);
  }

  @override
  String? encode(Gender? value) {
    return value?.name;
  }
}

class DateTimeConverter extends TypeConverter<DateTime?, int?> {
  @override
  DateTime? decode(int? databaseValue) {
    return databaseValue == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int? encode(DateTime? value) {
    return value?.millisecondsSinceEpoch;
  }
}

class NonNullDateTimeConverter extends TypeConverter<DateTime, int> {
  @override
  DateTime decode(int databaseValue) {
    return DateTime.fromMillisecondsSinceEpoch(databaseValue);
  }

  @override
  int encode(DateTime value) {
    return value.millisecondsSinceEpoch;
  }
}
