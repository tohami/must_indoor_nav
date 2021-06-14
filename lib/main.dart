import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'my_app.dart';

void main() async{
  //this is a commit from android
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


