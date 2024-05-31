import 'package:floor/floor.dart';
import 'package:floor_demo/entity/pet.dart';

@dao
abstract class PetDao {
  @Query('SELECT * FROM petWithOwnerView WHERE owner = :id')
  Future<PetWithOwner?> getPetWithPerson(int id);
  @insert
  Future<void> insertPet(Pet pet);
}
