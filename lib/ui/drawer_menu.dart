import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/current_screen_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/edit_profile.dart';
import 'package:socialapp/screens/profile.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    var currentScreenProvider = Provider.of<CurrentScreenProvider>(context);
    User user = userProvider.user;

    return Scaffold(
        backgroundColor: Colors.blue,
        body: ListView(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 100, 0, 30),
            child: GestureDetector(
              onTap: () {
                ZoomDrawer.of(context)!.close();
                currentScreenProvider.changeIndex(1);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1000),
                      child: CachedNetworkImage(
                          width: 100,
                          height: 100,
                          imageUrl: user.profilePic,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      user.username,
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () {
              ZoomDrawer.of(context)!.close();
              currentScreenProvider.changeIndex(0);
            },
            leading: Icon(Icons.home, color: Colors.white),
            title: Text(
              'Home',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              ZoomDrawer.of(context)!.close();
              currentScreenProvider.changeIndex(1);
            },
            leading: Icon(Icons.person, color: Colors.white),
            title: Text(
              'Profile',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: () {
              ZoomDrawer.of(context)!.close();
              currentScreenProvider.changeIndex(2);
            },
            leading: Icon(Icons.edit, color: Colors.white),
            title: Text(
              'Edit Profile',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.exit_to_app),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<OutlinedBorder>(
                        RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.white,
                              width: 2,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await userProvider.logout();
                    },
                    label: Text(
                      "Logout",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ]),
          ),
        ]));
  }
}
