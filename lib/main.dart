import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialapp/provider/current_screen_provider.dart';
import 'package:socialapp/provider/user_provider.dart';
import 'screens/wrapper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Media',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            try {
              if (snapshot.hasData) {
                return ChangeNotifierProvider(
                  create: (context) => UserProvider(snapshot.data!),
                  child: ChangeNotifierProvider(
                      create: (context) => CurrentScreenProvider(),
                      builder: (context, snapshot) {
                        return const Wrapper();
                      }),
                );
              } else {
                return const Scaffold();
              }
            } catch (e) {
              return const Scaffold();
            }
          }),
    );
  }
}
