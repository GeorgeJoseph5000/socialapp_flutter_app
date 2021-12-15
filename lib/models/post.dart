import 'dart:convert';

class Post {
  final String id;
  final String userID;
  final String desc;
  final String img;
  final List likes;
  final List comments;
  final String createdAt;
  final String updatedAt;

  Post(
      {required this.id,
      required this.userID,
      required this.desc,
      required this.img,
      required this.likes,
      required this.comments,
      required this.createdAt,
      required this.updatedAt});

  factory Post.fromJson(String res) {
    Map<String, dynamic> json = jsonDecode(res);
    return Post(
      id: json['_id'],
      userID: json['userID'],
      desc: json['desc'],
      img: json['img'],
      createdAt: json['createdAt'],
      likes: json['likes'],
      comments: json['comments'],
      updatedAt: json['updatedAt'],
    );
  }
  factory Post.empty() {
    return Post(
      id: "",
      userID: "",
      desc: "",
      img: "",
      createdAt: "",
      likes: [],
      comments: [],
      updatedAt: ""
    );
  }
}
