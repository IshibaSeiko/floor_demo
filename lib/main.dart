import 'dart:io';

import 'package:floor_demo/dao/person_dao.dart';
import 'package:floor_demo/database.dart';
import 'package:floor_demo/entity/person.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
          child: StreamBuilder<List<String>>(
              stream: dao.findAllPeopleName(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return Container();
                final nameList = snapshot.requireData;
                return ListView.builder(
                    itemCount: nameList.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(nameList[index]),
                        onTap: () {},
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
                  gender: Gender.values.byName(genderEditingController.text),
                  createAt: DateTime.now(),
                  updateAt: null,
                  profileImage: profileImage));
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      )),
    );
  }
}
