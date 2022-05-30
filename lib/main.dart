// Firebase ile çalışma
// sahte data ile çalışıp, listview oluşturmak gerekiyor.
// ancak bir hata var bulamadım.
// sonuç olarak bu kod hatalı.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Anket"),
        ),
        body: const SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget{
  const SurveyList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}

class SurveyListState extends State{
  final firebaseInstance = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<dynamic>(
      stream: firebaseInstance.collection("dilanketi").snapshots(),
      builder: (context, snapshot){
        if (!snapshot.hasData){
          return const LinearProgressIndicator();
        } else {
          return buildBody(context, snapshot.data?.documents);
        }
      },
    );
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return  ListView (
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map<Widget>((data) => buildListItem(context, data)).toList(),
    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Anket.fromSnapshot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0)
          ),
        child: ListTile(
          title: Text(row.isim),
          trailing: Text(row.oy.toString()),
          onTap: () => firebaseInstance.runTransaction((transaction) async{
            final freshSnapshot = await transaction.get(row.reference); // snapshot
            final fresh = Anket.fromSnapshot(freshSnapshot); // anket
            transaction.update((row.reference), {"oy" : fresh.oy +1});
          }),
          ),
        )
      );
  }
}

class Anket{
  String isim;
  int oy;
  DocumentReference reference;

  Anket.fromMap(Map<String, dynamic> map, {required this.reference})
    : assert (map["isim"] != null), assert (map["oy"] != null),
      isim = map["isim"], oy = map["oy"];

  Anket.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data as Map<String, dynamic>, reference:snapshot.reference);
}

// Sahte data map formatında gelecek
final sahteSnapshot = [
  {"isim":"C#", "oy":3},
  {"isim":"Java", "oy":4},
  {"isim":"Dart", "oy":5},
  {"isim":"C++", "oy":7},
  {"isim":"Python", "oy":90},
  {"isim":"Perl", "oy":2},
];