import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/ui/ui_shortcuts.dart';
import '../provider/post_provider.dart';

var postTextFieldController = TextEditingController();

class AddPost extends HookWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;
    var post = useState(Post.empty());

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ZoomDrawer.of(context)!.open();
              },
              icon: Icon(Icons.menu)),
          title: Text("Add Post"),
        ),
        body: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: postTextFieldController,
                    style: TextStyle(fontSize: 20),
                    onChanged: (value) {
                      post.value = Post(
                          id: "",
                          userID: user.id,
                          desc: value,
                          createdAt: 'now',
                          img: '',
                          updatedAt: 'now',
                          likes: [],
                          comments: []);
                    },
                    maxLines: 15,
                    decoration: const InputDecoration(
                        hintText:
                            "What's on your mind? (You can write markdown)",
                        hintStyle: TextStyle(fontSize: 20)),
                  ),
                ),
                SizedBox(height: 30),
                StyledButton("Post", () async {
                  var res = await addPost(post.value, user);
                  showSnackBar(
                      context,
                      res.id != null
                          ? "Post added successfully"
                          : "Error while adding post");
                  post.value = Post.empty();
                  postTextFieldController.clear();
                }),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Preview",
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                post.value.desc != ""
                    ? PostPreview(
                        user: user,
                        post: post.value,
                        showCase: true,
                        userProvider: userProvider,
                      )
                    : Text("")
              ],
            ),
          ],
        ));
  }
}
