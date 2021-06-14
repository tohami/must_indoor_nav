import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indoor_map_app/model/location_model.dart';
import 'package:indoor_map_app/model/post_model.dart';
import 'package:indoor_map_app/services/posts_service.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference locationsRef = FirebaseFirestore.instance.collection('locations');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Posts"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
        //show qr scanner  ;
          String cameraScanResult = await scanner.scan();
          print("==============================================================") ;
          print(cameraScanResult) ;
          DocumentSnapshot location = await locationsRef.doc(cameraScanResult).get() ;
          LocationModel locationData = LocationModel.fromJson(location.id, location.data()) ;
          print(locationData.toJson()) ;
          Fluttertoast.showToast(
              msg: locationData.title,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        },
        child: Icon(Icons.qr_code_scanner),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: locationsRef.snapshots(),
          builder: (context, snapshot) {
            List<LocationModel> locations = snapshot.data.docs.map((e) => LocationModel.fromJson(e.id,  e.data())).toList() ;
            return ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(12),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locations[index].title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text("" + locations[index].x.toString() +" " + locations[index].y.toString()),
                        ],
                      ),
                    ),
                  );
                });
          }
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
