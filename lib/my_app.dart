
import 'package:flutter/material.dart';
import 'package:indoor_map_app/pages/map_page.dart';
import 'package:indoor_map_app/pages/post_details_page.dart';
import 'package:indoor_map_app/pages/splash_page.dart';

import 'pages/home_page.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: SplashPage(),
      initialRoute: '/',
      routes: {
        '/': (context) => MapPage(),
        "/home" : (context) => HomePage(title: "Home",) ,
        "/post": (context) => PostDetailsPage(),
        "/map": (context) => MapPage(),
      },
    );
  }
}
