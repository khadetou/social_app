import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/widgets/header.dart';
import 'package:socialapp/widgets/progress.dart';
import "package:cloud_firestore/cloud_firestore.dart";

final userRef = FirebaseFirestore.instance.collection("users");

class TimeLine extends StatefulWidget {
  const TimeLine({Key? key}) : super(key: key);

  @override
  _TimeLineState createState() => _TimeLineState();
}

class _TimeLineState extends State<TimeLine> {
  var firestoreDb = FirebaseFirestore.instance.collection("users").snapshots();
  @override
  void initState() {
    // getUsers();
    getUserById();
    super.initState();
  }

//BEST APPROCH USING THE ASYNC AWAIT
  getUserById() async {
    const String id = "Lg3xPylFz9J0rz5xAS97";

    final DocumentSnapshot doc = await userRef.doc(id).get();
    print(doc.data());
    print(doc.exists);
  }

  // getUserById() {
  //   const String id = "Lg3xPylFz9J0rz5xAS97";

  //   userRef.doc(id).get().then(
  //     (DocumentSnapshot doc) {
  //       print(doc.data());
  //       print(doc.exists);
  //       print(doc.id);
  //     },
  //   );
  // }

  // getUsers() {
  //   userRef.get().then(
  //     (QuerySnapshot snapshot) {
  //       for (var doc in snapshot.docs) {
  //         print(doc.data());
  //         print(doc.exists);
  //         print(doc.id);
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: StreamBuilder(
        stream: firestoreDb,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: Text(
                  snapshot.data!.docs[index]["username"],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
