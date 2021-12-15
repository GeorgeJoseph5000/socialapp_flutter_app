import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/post_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class Comments extends StatefulWidget {
  final User user;
  final Post post;
  final UserProvider userProvider;

  Comments(
      {required this.user, required this.post, required this.userProvider});

  @override
  _CommentsState createState() => _CommentsState();
}

var controller = TextEditingController();

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    List comments = this.widget.post.comments;

    List<Widget> tiles = [];
    comments.forEach((commentPackage) async {
      tiles.add(FutureBuilder<User>(
          future: getUser(commentPackage['userID']),
          builder: (context, snapshot) {
            try {
              return ListTile(
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: CachedNetworkImage(
                        width: 50,
                        height: 50,
                        imageUrl: snapshot.data!.profilePic)),
                title: Text(snapshot.data!.username),
                subtitle: MarkdownBody(
                  data: commentPackage['comment'].toString(),
                  onTapLink: (text, url, title) {
                    launch(url!);
                  },
                ),
                onTap: () {
                  snapshot.data!.id != this.widget.user.id
                      ? Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              Profile(snapshot.data!, widget.userProvider)))
                      : print("no");
                },
                trailing: Text(timeago.format(
                    DateTime.parse(commentPackage['time'].toString()),
                    locale: 'en_short')),
              );
            } catch (e) {
              return Container();
            }
          }));
    });

    return Scaffold(
        appBar: AppBar(
          title: Text("Comments"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(child: ListView(children: tiles)),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  new Flexible(
                      child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                        hintText: "Write a comment (You can write markdown)",
                        hintStyle: TextStyle(fontSize: 20)),
                  )),
                  IconButton(
                      onPressed: () {
                        commentPost(this.widget.user, this.widget.post,
                            controller.value.text);
                        setState(() {
                          this.widget.post.comments.add({
                            "userID": this.widget.user.id,
                            "comment": controller.value.text,
                            "time": DateTime.now()
                          });
                        });

                        controller.clear();
                      },
                      icon: Icon(Icons.send))
                ],
              ),
            ),
          ],
        ));
  }
}
