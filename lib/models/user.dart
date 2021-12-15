import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String profilePic;
  final String coverPic;
  final List followers;
  final List followings;
  final bool isAdmin;
  final String createdAt;
  final String updatedAt;
  final bool isEmpty;

  User(
      {required this.id,
      required this.username,
      required this.email,
      required this.password,
      required this.coverPic,
      required this.createdAt,
      required this.followers,
      required this.followings,
      required this.isAdmin,
      required this.profilePic,
      required this.updatedAt,
      required this.isEmpty});

  factory User.fromJson(String res) {
    Map<String, dynamic> json = jsonDecode(res);
    return User(
        id: json['_id'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
        coverPic: json['coverPic'],
        createdAt: json['createdAt'],
        followers: json['followers'],
        followings: json['followings'],
        isAdmin: json['isAdmin'],
        profilePic: json['profilePic'],
        updatedAt: json['updatedAt'],
        isEmpty: false);
  }

  factory User.empty() {
    return User(
        id: "",
        username: "",
        email: "",
        password: "",
        coverPic: "",
        createdAt: "",
        isAdmin: false,
        profilePic: "",
        updatedAt: "",
        isEmpty: true,
        followers: [],
        followings: []);
  }
}
