import 'dart:io';

import 'package:floor_demo/dao/person_dao.dart';
import 'package:floor_demo/database.dart';
import 'package:floor_demo/entity/person.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database =
      await $FloorAppDatabase.databaseBuilder('flutter_database.db').build();
  final dao = database.personDao;
  runApp(FloorApp(
    dao: dao,
  ));
}

class FloorApp extends StatelessWidget {
  final PersonDao dao;
  const FloorApp({super.key, required this.dao});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Demo',
      home: FriendsWidget(
        dao: dao,
      ),
    );
  }
}

class FriendsWidget extends StatelessWidget {
  final PersonDao dao;
  const FriendsWidget({super.key, required this.dao});

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
                      builder: (_) => AddPersonWidget(dao: dao),
                    ),
                  );
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: SafeArea(
          child: StreamBuilder<List<Person>>(
              stream: dao.findAllPeople(),
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
                                  dao: dao, person: persons[index])));
                        },
                      );
                    });
              }),
        ));
  }
}

class AddPersonWidget extends StatefulWidget {
  final PersonDao dao;
  const AddPersonWidget({super.key, required this.dao});

  @override
  State<AddPersonWidget> createState() => _AddPersonWidgetState();
}

class _AddPersonWidgetState extends State<AddPersonWidget> {
  final nameEditingController = TextEditingController();
  final nicknameEditingController = TextEditingController();
  final ageEditingController = TextEditingController();
  final genderEditingController = TextEditingController();
  File? profileImage;

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
          FilledButton.tonal(
            onPressed: () {
              widget.dao.insertPerson(Person(
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
  final PersonDao dao;
  final Person person;

  const PersonDetailWidget(
      {super.key, required this.dao, required this.person});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yy-M-d h:m:s');
    const valueTextStyle = TextStyle(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name),
      ),
      body: Column(children: [
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
      ]),
    );
  }
}
