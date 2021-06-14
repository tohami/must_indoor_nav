import 'package:flutter/material.dart';
import 'package:indoor_map_app/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 5)).then((value) => {
      Navigator.of(context)
          .pushReplacementNamed('/home'),
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown,
      child: Image.asset('assets/icons/ic_splash.png'),
    );
  }
}
