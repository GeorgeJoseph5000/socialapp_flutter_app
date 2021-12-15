// ignore_for_file: file_names

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/current_screen_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/authenticate.dart';
import 'package:socialapp/screens/edit_profile.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:socialapp/ui/drawer_menu.dart';

import 'add_post.dart';
import 'discover.dart';
import 'home.dart';

class Wrapper extends HookWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentScreenProvider = Provider.of<CurrentScreenProvider>(context);
    var userProvider = Provider.of<UserProvider>(context);
    final _drawerController = ZoomDrawerController();
    User user = userProvider.user;
    var widgetList = [
      defaultTabController(user, userProvider),
      Profile(user, userProvider),
      EditProfilePage(),
    ];
    return userProvider.user.isEmpty
        ? const Authenticate()
        : ZoomDrawer(
            controller: _drawerController,
            style: DrawerStyle.DefaultStyle,
            borderRadius: 24.0,
            showShadow: true,
            backgroundColor: Colors.white24,
            slideWidth: MediaQuery.of(context).size.width * .46,
            openCurve: Curves.fastOutSlowIn,
            closeCurve: Curves.bounceIn,
            menuScreen: DrawerMenu(),
            mainScreen: widgetList[currentScreenProvider.index],
          );
  }
}

defaultTabController(User user, UserProvider userProvider) {
  return DefaultTabController(
    length: 4,
    child: Scaffold(
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.explore, title: 'Discover'),
          TabItem(icon: Icons.add, title: 'Post'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
      ),
      body: TabBarView(children: [
        Home(userProvider: userProvider),
        Discover(),
        AddPost(),
        Profile(user, userProvider),
      ]),
    ),
  );
}
