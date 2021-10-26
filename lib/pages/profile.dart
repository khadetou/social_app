import 'package:flutter/material.dart';
import 'package:socialapp/widgets/header.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        titleText: "Profile",
      ),
      body: const Text("Profile"),
    );
  }
}
