import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/user_provider.dart';

class EditProfile extends StatefulWidget {
  UserProvider userProvider;
  EditProfile({Key? key, required this.userProvider}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _imageFile = null;
  final ImagePicker _picker = ImagePicker();
  var methodTabIndex = 0;
  var profileTabIndex = 0;
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    User user = widget.userProvider.user;
    return Column(
      children: [
        uploading ? LinearProgressIndicator() : Container(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CupertinoSlidingSegmentedControl(
                    groupValue: profileTabIndex,
                    children: {
                      0: Text("Profile Picture"),
                      1: Text("Cover Picture")
                    },
                    onValueChanged: (int? i) {
                      setState(() {
                        profileTabIndex = i!;
                      });
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                profileTabIndex == 0
                    ? "Update Profile Picture"
                    : "Update Cover Picture",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: CupertinoSlidingSegmentedControl(
                    groupValue: methodTabIndex,
                    children: {0: Text("Gallery"), 1: Text("Camera")},
                    onValueChanged: (int? i) {
                      setState(() {
                        methodTabIndex = i!;
                      });
                    }),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final pickedFile = await _picker.pickImage(
                              source: methodTabIndex == 0
                                  ? ImageSource.gallery
                                  : ImageSource.camera);

                          setState(() {
                            _imageFile = File(pickedFile!.path);
                          });
                        } catch (e) {
                          print("Image picker error " + e.toString());
                        }
                      },
                      icon: Icon(methodTabIndex != 0
                          ? Icons.camera_alt
                          : Icons.cloud_upload_rounded),
                      label: Text(methodTabIndex != 0
                          ? "Take a photo"
                          : "Select a Photo")),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          backgroundColor: _imageFile == null
                              ? MaterialStateProperty.all<Color>(Colors.grey)
                              : MaterialStateProperty.all<Color>(Colors.blue)),
                      onPressed: () async {
                        if (_imageFile != null) {
                          setState(() {
                            uploading = true;
                          });
                          profileTabIndex == 0
                              ? await uploadProfilePic(_imageFile!.path, user)
                              : await uploadCoverPic(_imageFile!.path, user);
                          setState(() {
                            uploading = false;
                            widget.userProvider.relogin();
                            Navigator.of(context).pop();
                          });
                        }
                      },
                      icon: Icon(Icons.upload),
                      label: Text("Upload")),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Center(
                child: Column(children: [
                  Text(
                    _imageFile == null
                        ? "No Image is picked"
                        : "An Image is Picked",
                    style: TextStyle(fontSize: 16),
                  ),
                  _imageFile != null
                      ? Image.file(
                          _imageFile!,
                          width: 200,
                        )
                      : Container()
                ]),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Edit Profile"),
          leading: IconButton(
              onPressed: () {
                ZoomDrawer.of(context)!.open();
              },
              icon: Icon(Icons.menu)),
        ),
        body: EditProfile(
          userProvider: userProvider,
        ));
  }
}
