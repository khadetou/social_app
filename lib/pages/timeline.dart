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
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          // final List<Text> children = snapshot.data!.docs
          //     .map((doc) => Text(doc["username"]))
          //     .toList();
          return SizedBox(
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return Text(snapshot.data!.docs[index]["username"]);
              },
            ),
          );
        },
      ),
    );
  }
}
