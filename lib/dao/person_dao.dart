import 'package:floor/floor.dart';
import 'package:floor_demo/entity/person.dart';

@dao
abstract class PersonDao {
  @Query('SELECT * FROM Person')
  Stream<List<Person>> findAllPeople();

  @Query('SELECT name FROM Person')
  Stream<List<String>> findAllPeopleName();

  @Query('SELECT * FROM Person WHERE id = :id')
  Stream<Person?> findPersonById(int id);

  @Query('SELECT id FROM Person WHERE name = :name')
  Future<int?> findPersonIdByName(String name);

  @insert
  Future<void> insertPerson(Person person);
}
