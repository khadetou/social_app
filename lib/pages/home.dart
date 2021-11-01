// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:socialapp/data/data.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/activity_feed.dart';
import 'package:socialapp/pages/create_account.dart';
import 'package:socialapp/pages/profile.dart';
import 'package:socialapp/pages/search.dart';
// import 'package:socialapp/pages/timeline.dart';
import 'package:socialapp/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

final userRef = FirebaseFirestore.instance.collection("users");

final postRef = FirebaseFirestore.instance.collection("posts");
final DateTime timestamp = DateTime.now();
User? currentUser;
final Reference storageRef = FirebaseStorage.instance.ref();

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isAuth = false;
  PageController? pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController();
    //Detects if user signs in
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) {
        print("Error signing in: $err");
      },
    );

    //ReAuthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print("Error signing in: $err");
    });
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      createUser();
      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
    }
  }

  //Create user in firestore
  createUser() async {
    //1°) Check if user exists in users collextion in database according to their id.
    final GoogleSignInAccount? user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.doc(user!.id).get();
    if (!doc.exists) {
      // 2°) If the user doesn't exist, then we want to take them to the create account page.
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateAccount(),
        ),
      );
      //3°)get username from create account, use it to make new document in users collection.

      userRef.doc(user.id).set(
        {
          "id": user.id,
          "username": username,
          "photoUrl": user.photoUrl,
          "email": user.email,
          "displayName": user.displayName,
          "bio": "",
          "timestamp": timestamp
        },
      );
      doc = await userRef.doc(user.id).get();
    }
    currentUser = User.fromDocument(doc);
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController!.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          // TimeLine(),
          ElevatedButton(onPressed: logout, child: const Text("Log out")),
          const ActivityFeed(),
          Upload(
            currentUser: currentUser as User,
          ),
          const Search(),
          const Profile()
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera, size: 35.0),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
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
    return _isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
