import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:http/http.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/provider/post_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'package:socialapp/screens/profile.dart';
import 'package:socialapp/ui/ui_shortcuts.dart';

class Home extends StatefulWidget {
  final UserProvider userProvider;
  Home({required this.userProvider});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const _pageSize = 10;

  final PagingController<int, Post> _pagingController =
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
      final newItems =
          await getTimeline(widget.userProvider.user, _pageSize, pageKey);
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
        title: Text("Home"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _pagingController.refresh();
        },
        child: PagedListView<int, Post>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, item, index) {
            return PostPreview(
                user: user, post: item, userProvider: userProvider);
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
