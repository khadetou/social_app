import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/data/data.dart';
import "package:cloud_firestore/cloud_firestore.dart";

final GoogleSignIn googleSignIn = GoogleSignIn();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isAuth = false;
  var firestoreDb = FirebaseFirestore.instance.collection("users").snapshots();

  @override
  void initState() {
    super.initState();
    //Detects if user signs in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) {
        // ignore: avoid_print
        print("Error signing in: $err");
      },
    );

    //ReAuthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      // ignore: avoid_print
      print("Error signing in: $err");
    });
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
    }
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  Widget buildAuthScreen() {
    return ElevatedButton(
      onPressed: logout,
      child: const Text("Logout"),
    );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "FlutterShare",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Images.googleSignIn),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("FireStore app"),
    //   ),
    //   body: StreamBuilder(
    //     stream: firestoreDb,
    //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       print(snapshot);
    //       if (!snapshot.hasData) {
    //         return const CircularProgressIndicator();
    //       } else {
    //         return ListView.builder(
    //           itemCount: snapshot.data!.docs.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return Text(snapshot.data!.docs[index]["firstname"]);
    //           },
    //         );
    //       }
    //     },
    //   ),
    // );

    return _isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
