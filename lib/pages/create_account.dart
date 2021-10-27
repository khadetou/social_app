import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socialapp/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  // final _scafoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String? username;

  submit() {
    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username!"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        titleText: "Set up your profile",
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 25),
            child: Center(
              child: Text(
                "Create a username",
                style: TextStyle(fontSize: 25.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: TextFormField(
                validator: (val) {
                  if (val!.trim().length < 3 || val.isEmpty) {
                    return "Username too short";
                  } else if (val.trim().length > 12) {
                    return "Username too long";
                  } else {
                    return null;
                  }
                },
                onSaved: (val) => username = val,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                    labelStyle: TextStyle(
                      fontSize: 15.0,
                    ),
                    hintText: "Must be at least 3 characters"),
              ),
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Container(
              width: 200.0,
              height: 35.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: const Center(
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
