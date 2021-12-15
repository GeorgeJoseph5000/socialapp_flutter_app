import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/current_screen_provider.dart';
import 'package:socialapp/provider/post_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/edit_profile.dart';
import 'package:socialapp/ui/ui_shortcuts.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class Profile extends StatefulWidget {
  User user;
  UserProvider userProvider;

  Profile(this.user, this.userProvider, {Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Widget> children = [
    Container(
      width: 200,
      height: 200,
      color: Colors.blue,
    )
  ];
  bool following = false;
  bool follower = false;

  @override
  void initState() {
    following = widget.userProvider.user.followings.contains(widget.user.id);
    follower = widget.userProvider.user.followers.contains(widget.user.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool notMyProfile = false;
    UserProvider userProvider;
    CurrentScreenProvider currentScreenProvider;
    var refreshFunction;
    var editFunction;
    try {
      userProvider = Provider.of<UserProvider>(context);

      currentScreenProvider = Provider.of<CurrentScreenProvider>(context);
      refreshFunction = () async {
        await userProvider.relogin();
      };
      editFunction = () {
        if (!notMyProfile) {
          currentScreenProvider.changeIndex(1);
        }
      };
    } catch (e) {
      refreshFunction = () async {
        User u = await getUser(widget.user.id);
        print(u.profilePic);
        setState(() {
          widget.user = u;
        });
      };
      editFunction = () {};
      notMyProfile = true;
    }

    List followings = [];
    widget.user.followings.forEach((userID) async {
      followings.add(FutureBuilder<User>(
          future: getUser(userID),
          builder: (context, snapshot) {
            try {
              return GestureDetector(
                onTap: () {
                  try {
                    snapshot.data! != widget.userProvider.user
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                Profile(snapshot.data!, widget.userProvider)))
                        : print("no");
                  } catch (e) {}
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: snapshot.data!.profilePic,
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            snapshot.data!.username,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } catch (e) {
              return Container();
            }
          }));
    });

    List followers = [];
    widget.user.followers.forEach((userID) async {
      followers.add(FutureBuilder<User>(
          future: getUser(userID),
          builder: (context, snapshot) {
            try {
              return GestureDetector(
                onTap: () {
                  try {
                    snapshot.data! != widget.userProvider.user
                        ? Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                Profile(snapshot.data!, widget.userProvider)))
                        : print("no");
                  } catch (e) {}
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: snapshot.data!.profilePic,
                        height: 200,
                        width: 200,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            snapshot.data!.username,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            } catch (e) {
              return Container();
            }
          }));
    });

    return Scaffold(
        appBar: notMyProfile
            ? AppBar(
                title: Text(widget.user.username + "'s Profile"),
                actions: [
                    ElevatedButton.icon(
                        onPressed: () async {
                          if (!notMyProfile) return editFunction();
                          if (following) {
                            Response res = await unfollowUser(
                                widget.user, widget.userProvider.user);
                            setState(() {
                              following = false;
                              widget.userProvider.relogin();
                            });
                          } else {
                            Response res = await followUser(
                                widget.user, widget.userProvider.user);
                            setState(() {
                              following = true;
                              widget.userProvider.relogin();
                            });
                          }
                        },
                        icon: Icon(
                            following ? Icons.close_outlined : Icons.check),
                        label: Text(following ? "Unfollow" : "Follow"))
                  ])
            : AppBar(
                title: Text("Your Profile"),
                leading: IconButton(
                    onPressed: () {
                      ZoomDrawer.of(context)!.open();
                    },
                    icon: Icon(Icons.menu)),
                actions: [
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return EditProfile(
                                  userProvider: widget.userProvider);
                            });
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
        body: RefreshIndicator(
          onRefresh: refreshFunction,
          child: ListView(children: [
            Column(
              children: [
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.user.coverPic),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                          alignment: Alignment.center,
                          color: Colors.grey.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(1000),
                                      child: CachedNetworkImage(
                                          width: 200,
                                          height: 200,
                                          imageUrl: widget.user.profilePic,
                                          placeholder: (context, url) =>
                                              Container(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error)),
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                                Text(widget.user.username,
                                    style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
                notMyProfile
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all<Size>(
                                    Size.fromHeight(40)),
                                backgroundColor: follower
                                    ? MaterialStateProperty.all<Color>(
                                        Colors.blueGrey)
                                    : MaterialStateProperty.all<Color>(
                                        Colors.blue)),
                            onPressed: () {},
                            child: Text(
                              follower ? "Follows you" : "Don't follow you",
                              style: TextStyle(fontSize: 30),
                            )),
                      )
                    : Text(""),
                SizedBox(
                  height: 20,
                ),
                widget.user.followers.length != 0 ||
                        widget.user.followings.length != 0
                    ? ConstrainedBox(
                        constraints: new BoxConstraints.loose(
                            new Size(double.infinity, 300)),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Row(
                              children: [
                                widget.user.followers.length != 0
                                    ? Column(
                                        children: [
                                          Text("Followers",
                                              style: TextStyle(
                                                fontSize: 40,
                                              )),
                                          ConstrainedBox(
                                            constraints:
                                                new BoxConstraints.loose(
                                                    new Size(250, 250)),
                                            child: Swiper(
                                              viewportFraction: 0.8,
                                              scale: 0.9,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return followers[index];
                                              },
                                              itemHeight: 250,
                                              itemWidth: 200,
                                              itemCount: followers.length,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(""),
                                widget.user.followings.length != 0
                                    ? Column(
                                        children: [
                                          Text("Following",
                                              style: TextStyle(
                                                fontSize: 40,
                                              )),
                                          ConstrainedBox(
                                            constraints:
                                                new BoxConstraints.loose(
                                                    new Size(250, 250)),
                                            child: Swiper(
                                              viewportFraction: 0.8,
                                              scale: 0.9,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return followings[index];
                                              },
                                              itemHeight: 250,
                                              itemWidth: 200,
                                              itemCount: followings.length,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(""),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Text(""),
                SizedBox(
                  height: 20,
                ),
                FutureBuilder<List<Post>>(
                    future: getMyPosts(widget.user),
                    builder: (context, posts) {
                      try {
                        List<Widget> postCards = [];
                        posts.data!.forEach((post) => postCards.add(PostPreview(
                              user: widget.user,
                              post: post,
                              userProvider: widget.userProvider,
                            )));
                        return Column(children: postCards);
                      } catch (e) {
                        return Container();
                      }
                    })
              ],
            ),
          ]),
        ));
  }
}
