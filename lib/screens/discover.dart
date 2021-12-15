import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/profile.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  static const _pageSize = 10;

  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await getUsers(_pageSize, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 2;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    User user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              ZoomDrawer.of(context)!.open();
            },
            icon: Icon(Icons.menu)),
        title: Text("Discover"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: PagedListView<int, User>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<User>(
              itemBuilder: (context, item, index) {
            if (item.email == userProvider.user.email) return Text("");
            return DiscoverItem(userProvider: userProvider, item: item);
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class DiscoverItem extends StatefulWidget {
  final User item;
  final UserProvider userProvider;

  const DiscoverItem({Key? key, required this.item, required this.userProvider})
      : super(key: key);

  @override
  _DiscoverItemState createState() => _DiscoverItemState();
}

class _DiscoverItemState extends State<DiscoverItem> {
  @override
  Widget build(BuildContext context) {
    var following =
        widget.userProvider.user.followings.contains(widget.item.id);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Profile(widget.item, widget.userProvider)));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border(
                  top: BorderSide(
                      color: Colors.black, width: 1, style: BorderStyle.solid),
                  bottom: BorderSide(
                      color: Colors.black, width: 1, style: BorderStyle.solid),
                  right: BorderSide(
                      color: Colors.black, width: 1, style: BorderStyle.solid),
                  left: BorderSide(
                      color: Colors.black,
                      width: 1,
                      style: BorderStyle.solid))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: CachedNetworkImage(
                      imageUrl: widget.item.profilePic,
                      width: 70,
                      height: 70,
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: [
                      Text(widget.item.username),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: following
                                  ? MaterialStateProperty.all<Color>(Colors.red)
                                  : MaterialStateProperty.all<Color>(
                                      Colors.blue)),
                          onPressed: () async {
                            if (following) {
                              Response res = await unfollowUser(
                                  widget.item, widget.userProvider.user);
                              setState(() {
                                widget.userProvider.relogin();
                              });
                            } else {
                              Response res = await followUser(
                                  widget.item, widget.userProvider.user);
                              setState(() {
                                widget.userProvider.relogin();
                              });
                            }
                          },
                          child: Text(following ? "Unfollow" : "Follow"))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
