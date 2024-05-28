import 'dart:io';
import 'dart:typed_data';

import 'package:floor/floor.dart';

enum Gender {
  male,
  female,
  other,
}

@entity
class Person {
  @primaryKey
  final int id;
  final String name;
  final String? nickname;
  final int? age;
  final Gender? gender;
  final DateTime createAt;
  final DateTime? updateAt;
  final File? profileImage;

  Person(
      {required this.id,
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

class FileConverter extends TypeConverter<File?, Uint8List?> {
  @override
  File? decode(Uint8List? databaseValue) {
    final file = databaseValue == null ? null : File.fromRawPath(databaseValue);
    return file;
  }

  @override
  Uint8List? encode(File? value) {
    return value?.readAsBytesSync();
  }
}
