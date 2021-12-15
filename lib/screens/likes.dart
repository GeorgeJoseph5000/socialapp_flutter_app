import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/profile.dart';

class Likes extends StatelessWidget {
  final User user;
  final Post post;
  final UserProvider userProvider;

  const Likes(
      {required this.user, required this.post, required this.userProvider});

  @override
  Widget build(BuildContext context) {
    List<Widget> tiles = [];
    post.likes.forEach((userID) async {
      tiles.add(FutureBuilder<User>(
          future: getUser(userID),
          builder: (context, snapshot) {
            try {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: CachedNetworkImage(
                            imageUrl: snapshot.data!.profilePic)),
                    title: Text(snapshot.data!.username),
                    onTap: () {
                      snapshot.data!.id != user.id
                          ? Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Profile(snapshot.data!, userProvider)))
                          : print("no");
                    }),
              );
            } catch (e) {
              return CircularProgressIndicator();
            }
          }));
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Likes"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView(children: tiles),
      ),
    );
  }
}
