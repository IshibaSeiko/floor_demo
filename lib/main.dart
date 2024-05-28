import 'package:floor_demo/dao/person_dao.dart';
import 'package:floor_demo/database.dart';
import 'package:flutter/material.dart';

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
          actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add))],
        ),
        body: SafeArea(
          child: StreamBuilder(
              stream: dao.findAllPeopleName(),
              builder: (_, snapshot) {
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
