import 'dart:async';
import 'dart:typed_data';

import 'package:floor/floor.dart';
import 'package:floor_demo/dao/pet_dao.dart';
import 'package:floor_demo/entity/pet.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/person_dao.dart';
import 'entity/person.dart';

part 'database.g.dart';

@TypeConverters([
  GenderConverter,
  DateTimeConverter,
  NonNullDateTimeConverter,
])
@Database(version: 2, entities: [
  Person,
  Pet,
], views: [
  PetWithOwner
])
abstract class AppDatabase extends FloorDatabase {
  PersonDao get personDao;
  PetDao get petDao;
}
