import 'package:floor/floor.dart';
import 'package:floor_demo/entity/person.dart';
import 'package:flutter/foundation.dart';

@Entity(tableName: 'pets', indices: [
  Index(value: [
    'pet_name',
    'type',
  ])
])
class Pet {
  @primaryKey
  @ColumnInfo(name: 'pet_name')
  final String name;
  final String type;
  final int owner;

  Pet({
    required this.name,
    required this.type,
    required this.owner,
  });
}

@DatabaseView(
    'SELECT t.*, r.* FROM pets as t LEFT JOIN Person as r ON t.owner = r.id',
    viewName: 'petWithOwnerView')
class PetWithOwner {
  @ColumnInfo(name: 'pet_name')
  final String petName;
  final String type;
  final int owner;
  final int? id;
  final String name;
  final String? nickname;
  final int? age;
  final Gender? gender;
  final DateTime createAt;
  final DateTime? updateAt;
  final Uint8List? profileImage;

  PetWithOwner(
      {required this.petName,
      required this.type,
      required this.owner,
      required this.id,
      required this.name,
      required this.nickname,
      required this.age,
      required this.gender,
      required this.createAt,
      required this.updateAt,
      required this.profileImage});
}
