import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/post_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/comments.dart';
import 'package:socialapp/screens/likes.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class StyledButton extends StatelessWidget {
  StyledButton(this.text, this.action);
  final String text;
  final dynamic action;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      onPressed: action,
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

showSnackBar(context, text) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: TextStyle(fontSize: 18))));
}

class PostPreview extends StatefulWidget {
  final User user;
  final Post post;
  final UserProvider userProvider;
  bool showCase;

  PostPreview(
      {required this.user,
      required this.post,
      required this.userProvider,
      this.showCase = false});

  @override
  _PostPreviewState createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {
  @override
  Widget build(BuildContext context) {
    Color likeBtnColor = !this.widget.showCase
        ? this.widget.post.likes.contains(this.widget.user.id) == true
            ? Colors.blue
            : Colors.black
        : Colors.black;

    return FutureBuilder<User>(
        future: getUser(widget.post.userID),
        builder: (context, snapshot) {
          try {
            User postUser = snapshot.data!;
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      widget.post.userID != widget.user.id
                          ? Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  Profile(postUser, widget.userProvider)))
                          : print("no");
                    },
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: CachedNetworkImage(
                              width: 50,
                              height: 50,
                              imageUrl: postUser.profilePic,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error)),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            postUser.username,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(!widget.showCase
                              ? timeago.format(
                                  DateTime.parse(this.widget.post.createdAt),
                                  locale: 'en_short')
                              : widget.post.createdAt),
                        ],
                      ),
                    ]),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: MarkdownBody(
                          data: widget.post.desc,
                          onTapLink: (text, url, title) {
                            launch(url!);
                          })),
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: GestureDetector(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.thumb_up,
                                  color: likeBtnColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Like",
                                    style: TextStyle(color: likeBtnColor))
                              ],
                            ),
                            onTap: () async {
                              if (this.widget.showCase) return;
                              Response res = await likePost(
                                  this.widget.user, this.widget.post);
                              if (res.body.contains("unliked")) {
                                setState(() {
                                  likeBtnColor = Colors.black;
                                  this
                                      .widget
                                      .post
                                      .likes
                                      .remove(this.widget.user.id);
                                });
                              } else {
                                setState(() {
                                  likeBtnColor = Colors.blue;
                                  this
                                      .widget
                                      .post
                                      .likes
                                      .add(this.widget.user.id);
                                });
                              }
                            },
                          )),
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: GestureDetector(
                            child: Row(
                              children: [
                                Icon(Icons.comment),
                                SizedBox(
                                  width: 10,
                                ),
                                Text("Comment")
                              ],
                            ),
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => Comments(
                                            user: this.widget.user,
                                            post: this.widget.post,
                                            userProvider: widget.userProvider,
                                          )));
                              setState(() {});
                            },
                          )),
                    ],
                  ),
                  Row(
                    children: [
                      this.widget.post.likes.length != 0
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Likes(
                                            user: this.widget.user,
                                            post: this.widget.post,
                                            userProvider: widget.userProvider,
                                          )));
                                },
                                child: Text(
                                  this.widget.post.likes.length.toString() +
                                      " Like" +
                                      (this.widget.post.likes.length == 1
                                          ? ""
                                          : "s"),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Text(""),
                      this.widget.post.comments.length != 0
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                              child: GestureDetector(
                                onTap: () {},
                                child: Text(
                                  this.widget.post.comments.length.toString() +
                                      " Comment" +
                                      (this.widget.post.comments.length == 1
                                          ? ""
                                          : "s"),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          : Text(""),
                    ],
                  )
                ],
              ),
            );
          } catch (e) {
            return Container();
          }
        });
  }
}
