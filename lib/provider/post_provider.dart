import 'dart:convert';
import 'dart:ffi';

import 'package:http/http.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/requests.dart';

addPost(Post post, User user) async {
  try {
    var response = await postReq("posts", {
      "email": user.email,
      "password": user.password,
      "userID": user.id,
      "desc": post.desc
    });
    return Post.fromJson(response.body);
  } catch (e) {
    return Response("error", 500);
  }
}

Future<List<Post>> getMyPosts(User user) async {
  try {
    var response = await postReq("posts/myposts", {"userID": user.id});

    List<Post> posts = [];
    List<dynamic> json = jsonDecode(response.body);
    json.forEach((element) {
      posts.add(Post.fromJson(jsonEncode(element)));
    });
    return posts;
  } catch (e) {
    return [];
  }
}

Future likePost(User user, Post post) async {
  try {
    var response = await putReq("posts/" + post.id + "/like",
        {"email": user.email, "password": user.password, "userID": user.id});
    return response;
  } catch (e) {
    return Response("error", 500);
  }
}

Future<List<Post>> getTimeline(User user, int pageSize, int page) async {
  try {
    var response = await postReq("posts/timeline", {
      "limit": pageSize,
      "page": page,
      "userID": user.id,
      "email": user.email,
      "password": user.password
    });
    if (response.statusCode == 200) {
      List<Post> users = [];
      List<dynamic> json = jsonDecode(response.body);
      json.forEach((element) {
        users.add(Post.fromJson(jsonEncode(element)));
      });
      return users;
    } else {
      print(response.body);
      return [];
    }
  } catch (e) {
    print(e);
    return [];
  }
}

Future commentPost(User user, Post post, String comment) async {
  try {
    var response = await putReq("posts/" + post.id + "/comment", {
      "email": user.email,
      "password": user.password,
      "userID": user.id,
      "comment": comment
    });
    return response;
  } catch (e) {
    return Response("error", 500);
  }
}
