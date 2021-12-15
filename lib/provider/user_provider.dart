import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/requests.dart';

class UserProvider extends ChangeNotifier {
  User _user = User.empty();

  final SharedPreferences prefs;
  UserProvider(this.prefs) {
    String? initialUser = prefs.getString("currentUser");
    if (initialUser != null && initialUser != "") {
      _user = User.fromJson(initialUser);
      notifyListeners();
    }
  }

  User get user => _user;

  register(String username, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await postReq("auth/register",
          {"username": username, "email": email, "password": password});
      if (response.statusCode == 200) {
        User user = User.fromJson(response.body);
        _user = user;
        await prefs.setString("currentUser", response.body);
        notifyListeners();
      } else {
        _user = User.empty();
        notifyListeners();
      }
      return response;
    } catch (e) {
      return Response("error", 500);
    }
  }

  login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response =
          await postReq("auth/login", {"email": email, "password": password});

      if (response.statusCode == 200) {
        User user = User.fromJson(response.body);
        _user = user;
        await prefs.setString("currentUser", response.body);
        notifyListeners();
      } else {
        _user = User.empty();
        notifyListeners();
      }
      return response;
    } catch (e) {
      return Response("error", 500);
    }
  }

  relogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await postReq(
          "auth/login", {"email": user.email, "password": user.password});

      if (response.statusCode == 200) {
        User user = User.fromJson(response.body);
        _user = user;
        await prefs.setString("currentUser", response.body);
        notifyListeners();
      } else {
        _user = User.empty();
        notifyListeners();
      }
      return response;
    } catch (e) {
      return Response("error", 500);
    }
  }

  logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var response = await postReq("auth/logout", {
        "email": user.email,
        "password": user.password,
        "userID": user.id,
      });
      if (response.statusCode == 200) {
        _user = User.empty();
        await prefs.setString("currentUser", "");
        notifyListeners();
      }
      return response;
    } catch (e) {
      return Response("error", 500);
    }
  }
}

Future followUser(User targeted, User user) async {
  try {
    var response = await putReq("users/" + targeted.id + "/follow",
        {"email": user.email, "password": user.password, "userID": user.id});
    return response;
  } catch (e) {
    return Response("error", 500);
  }
}

Future unfollowUser(User targeted, User user) async {
  try {
    var response = await putReq("users/" + targeted.id + "/unfollow",
        {"email": user.email, "password": user.password, "userID": user.id});
    return response;
  } catch (e) {
    return Response("error", 500);
  }
}

Future<String?> uploadProfilePic(String filepath, User user) async {
  var request =
      MultipartRequest('POST', Uri.parse(baseurl + "users/profilePic"));
  request.fields['email'] = user.email;
  request.fields['password'] = user.password;
  request.fields['userID'] = user.id;

  request.files.add(await MultipartFile.fromPath('image', filepath));
  var res = await request.send();
  return res.reasonPhrase;
}

Future<String?> uploadCoverPic(String filepath, User user) async {
  var request = MultipartRequest('POST', Uri.parse(baseurl + "users/coverPic"));
  request.fields['email'] = user.email;
  request.fields['password'] = user.password;
  request.fields['userID'] = user.id;

  request.files.add(await MultipartFile.fromPath('image', filepath));
  var res = await request.send();
  return res.reasonPhrase;
}

Future<List<User>> getUsers(int pageSize, int page) async {
  try {
    var response = await postReq("users", {"limit": pageSize, "page": page});
    if (response.statusCode == 200) {
      List<User> users = [];
      List<dynamic> json = jsonDecode(response.body);
      json.forEach((element) {
        users.add(User.fromJson(jsonEncode(element)));
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

Future<User> getUser(String userID) async {
  try {
    var response = await getReq("users/" + userID);
    if (response.statusCode == 200) {
      User user = User.fromJson(response.body);
      return user;
    } else {
      print(response.body);
      return User.empty();
    }
  } catch (e) {
    return User.empty();
  }
}
