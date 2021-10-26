import 'package:flutter/material.dart';

AppBar header() {
  return AppBar(
    title: const Text(
      "FlutterShare",
      style: TextStyle(
        color: Colors.white,
        fontFamily: "Signatra",
        fontSize: 50.0,
      ),
    ),
    centerTitle: true,
  );
}
