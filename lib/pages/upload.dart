import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/widgets/progress.dart';
import "package:image/image.dart" as Img;
import 'package:uuid/uuid.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:geocoding/geocoding.dart";

import 'home.dart';

class Upload extends StatefulWidget {
  const Upload({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  ///-----------------------------VARIABLES------------------------*/
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  PickedFile? file;
  File? fileType;
  bool isUploading = false;
  String postId = const Uuid().v4();

  ///--------------------------FUNTIONS---------------------------*/
  ///
  // HANDLETAKEPHOTO
  handleTakePhoto() async {
    Navigator.pop(context);
    PickedFile file = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    ) as PickedFile;
    setState(() {
      // this.fileType = File(file.path);
      this.file = file;
    });
  }

  //HANDLECHOOSEFROMGALLERY
  handleChooseFromGellery() async {
    Navigator.pop(context);
    PickedFile file = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery) as PickedFile;

    setState(() {
      // this.fileType = File(file.path);
      this.file = file;
    });
  }

//SELECTIMAGE
  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: const Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: const Text("Image from Gallery"),
                onPressed: handleChooseFromGellery,
              ),
              SimpleDialogOption(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

//COMPRESSIMAGE
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Img.Image imageFile =
        Img.decodeImage(File(file!.path).readAsBytesSync()) as Img.Image;

    final compressedImageFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Img.encodeJpg(imageFile, quality: 85));

    setState(() {
      fileType = compressedImageFile;
    });
  }

//UPLOADIMAGE
  Future<String> uploadImage(imageFile) async {
    UploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    TaskSnapshot storageSnap = await uploadTask;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    return downloadUrl;
  }

  // CREATE POST IN FIRESTORE
  createPostInFirestore({
    required String mediaUrl,
    required String location,
    required String description,
  }) {
    postRef.doc(widget.currentUser.id).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

//HANDLE SUMBIT
  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(fileType);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      fileType = null;
      file = null;
      postId = const Uuid().v4();
      isUploading = false;
    });
  }

  ///-----------------------------------------------------*/
  /// BUILD SPLASH SCREEN */
  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ElevatedButton(
              onPressed: () => selectImage(context),
              child: const Text(
                "Upload Image",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ),
                  ),
                  primary: Colors.deepOrange),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      fileType = null;
      file = null;
    });
  }

  /// BUILD UPLOAD FORM  */
  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: const Text(
          "Caption Post",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: const Text(
              "Post",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : const Text(""),
          SizedBox(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(
                          File(file!.path),
                        ),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                widget.currentUser.photoUrl,
              ),
            ),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: const InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.pin_drop, color: Colors.orange, size: 35.0),
            title: SizedBox(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: "Where was this photo taken",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.my_location, color: Colors.white),
              onPressed: getUserLocation,
              label: const Text(
                "User Current Location",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                primary: Colors.blue,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// GET USER LOCATION FUNCTION  */

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];
    String completeAddress =
        'COMPLETE ADDRESS: ${placemark.subThoroughfare} ${placemark.thoroughfare} ${placemark.subLocality} ${placemark.locality} ${placemark.subAdministrativeArea} ${placemark.administrativeArea} ${placemark.postalCode} ${placemark.country}';

    print(completeAddress);

    String formattedAddress = '${placemark.locality} ${placemark.country}';

    locationController.text = formattedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
