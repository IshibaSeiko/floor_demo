import 'dart:io';

import 'package:floor/floor.dart';
import 'package:floor_demo/dao/person_dao.dart';
import 'package:floor_demo/dao/pet_dao.dart';
import 'package:floor_demo/database.dart';
import 'package:floor_demo/entity/person.dart';
import 'package:floor_demo/entity/pet.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final migration1to2 = Migration(1, 2, (database) async {
    await database.execute(
        ('CREATE TABLE pets (pet_name TEXT PRIMARY KEY, type TEXT, owner INTEGER)'));
    await database.execute(
        'CREATE VIEW petWithOwnerView AS SELECT t.*, r.* FROM pets t LEFT JOIN Person r ON t.owner = r.id');
  });

  final database = await $FloorAppDatabase
      .databaseBuilder('flutter_database.db')
      .addMigrations([migration1to2]).build();

  final personDao = database.personDao;
  final petDao = database.petDao;
  runApp(FloorApp(
    personDao: personDao,
    petDao: petDao,
  ));
}

class FloorApp extends StatelessWidget {
  final PersonDao personDao;
  final PetDao petDao;
  const FloorApp({
    super.key,
    required this.personDao,
    required this.petDao,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Demo',
      home: FriendsWidget(
        personDao: personDao,
        petDao: petDao,
      ),
    );
  }
}

class FriendsWidget extends StatelessWidget {
  final PersonDao personDao;
  final PetDao petDao;
  const FriendsWidget({
    super.key,
    required this.personDao,
    required this.petDao,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddPersonWidget(
                        personDao: personDao,
                        petDao: petDao,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<List<Person>>(
              stream: personDao.findAllPeople(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return Container();
                final persons = snapshot.requireData;
                return ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(persons[index].name),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => PersonDetailWidget(
                                  petDao: petDao, person: persons[index])));
                        },
                      );
                    });
              }),
        ));
  }
}

class AddPersonWidget extends StatefulWidget {
  final PersonDao personDao;
  final PetDao petDao;
  const AddPersonWidget({
    super.key,
    required this.personDao,
    required this.petDao,
  });

  @override
  State<AddPersonWidget> createState() => _AddPersonWidgetState();
}

class _AddPersonWidgetState extends State<AddPersonWidget> {
  final nameEditingController = TextEditingController();
  final nicknameEditingController = TextEditingController();
  final ageEditingController = TextEditingController();
  final genderEditingController = TextEditingController();
  File? profileImage;

  final petNameEditingController = TextEditingController();
  final petTypeEditingController = TextEditingController();

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    if (mounted) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
    profileImage = File(pickedFile.path);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Person'),
      ),
      body: Form(
          child: Column(
        children: [
          if (profileImage != null) Image.file(profileImage!),
          OutlinedButton(
              onPressed: () async {
                getImage();
              },
              child: const Text('Choose a profile image')),
          TextField(
            controller: nameEditingController,
            decoration: const InputDecoration(hintText: 'name *'),
          ),
          TextField(
            controller: nicknameEditingController,
            decoration: const InputDecoration(hintText: 'nickname'),
          ),
          TextField(
            controller: ageEditingController,
            decoration: const InputDecoration(hintText: 'age'),
          ),
          TextField(
            controller: genderEditingController,
            decoration:
                const InputDecoration(hintText: 'male , female or other'),
          ),
          const Divider(),
          TextField(
            controller: petNameEditingController,
            decoration: const InputDecoration(hintText: "pet's name *"),
          ),
          TextField(
            controller: petTypeEditingController,
            decoration: const InputDecoration(hintText: "pet's type *"),
          ),
          FilledButton.tonal(
            onPressed: () async {
              widget.personDao.insertPerson(Person(
                  name: nameEditingController.text,
                  nickname: nicknameEditingController.text.isEmpty
                      ? null
                      : nicknameEditingController.text,
                  age: int.tryParse(ageEditingController.text),
                  gender: genderEditingController.text.isEmpty
                      ? null
                      : Gender.values.byName(genderEditingController.text),
                  createAt: DateTime.now(),
                  updateAt: null,
                  profileImage: profileImage?.readAsBytesSync()));

              final personId = await widget.personDao
                  .findPersonIdByName(nameEditingController.text);
              if (personId != null) {
                widget.petDao.insertPet(Pet(
                    name: petNameEditingController.text,
                    type: petTypeEditingController.text,
                    owner: personId));
              }

              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      )),
    );
  }
}

class PersonDetailWidget extends StatelessWidget {
  final PetDao petDao;
  final Person person;

  const PersonDetailWidget(
      {super.key, required this.petDao, required this.person});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yy-M-d h:m:s');
    const valueTextStyle = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
      ),
      body: FutureBuilder(
          future: petDao.getPetWithPerson(person.id!),
          builder: (context, snapshot) {
            return ListView(children: [
              Row(
                children: [
                  const Text('name: '),
                  Text(
                    person.name,
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('nickname: '),
                  Text(
                    person.nickname ?? 'NULL',
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('age: '),
                  Text(
                    person.age != null ? person.age.toString() : 'NULL',
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('gender: '),
                  Text(
                    person.gender != null ? person.gender.toString() : 'NULL',
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('createAt: '),
                  Text(
                    formatter.format(person.createAt),
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('updateAt: '),
                  Text(
                    person.updateAt != null
                        ? formatter.format(person.updateAt!)
                        : 'NULL',
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('profileImage'),
                  if (person.profileImage != null)
                    Image.memory(
                      person.profileImage!,
                      width: 200,
                    )
                ],
              ),
              Row(
                children: [
                  const Text("pet's name: "),
                  Text(
                    snapshot.data == null ? '' : snapshot.data!.petName,
                    style: valueTextStyle,
                  ),
                ],
              ),
              Row(
                children: [
                  const Text("pet's type: "),
                  Text(
                    snapshot.data == null ? '' : snapshot.data!.type,
                    style: valueTextStyle,
                  ),
                ],
              ),
            ]);
          }),
    );
  }
}
