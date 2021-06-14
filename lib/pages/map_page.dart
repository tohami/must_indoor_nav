import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indoor_map_app/model/location_model.dart';
import 'package:indoor_map_app/model/map_object.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:rxdart/rxdart.dart';

import 'map/zoom_container.dart';

class MapPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final BehaviorSubject<LocationModel> selectedQrSubject =
      BehaviorSubject.seeded(null);

  final BehaviorSubject<List<LocationModel>> searchResultSupject =
      BehaviorSubject.seeded([]);

  final CollectionReference locationsRef =
      FirebaseFirestore.instance.collection('locations');

  MapPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Move the map"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //show qr scanner  ;
          String cameraScanResult = await scanner.scan();
          DocumentSnapshot location =
              await locationsRef.doc(cameraScanResult).get();
          LocationModel locationData =
              LocationModel.fromJson(location.id, location.data());
          selectedQrSubject.add(locationData);
          Fluttertoast.showToast(
              msg: locationData.x.toString(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        },
        child: Icon(Icons.qr_code_scanner),
      ),
      body: Stack(
        children: [
          StreamBuilder<LocationModel>(
              stream: selectedQrSubject.stream,
              builder: (context, selectedQrSnapshot) {
                return Center(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: locationsRef.snapshots(),
                      builder: (context, snapshot) {
                        List<MapObject> locations = snapshot.data.docs.map((e) {
                          var locationModel =
                              LocationModel.fromJson(e.id, e.data());
                          if (locationModel.type == 1) {
                            return MapObject(
                                child: Container(
                                  child: Icon(
                                    Icons.place,
                                    color: Colors.green,
                                  ),
                                ),
                                offset:
                                    Offset(locationModel.x, locationModel.y),
                                size: Size(10, 10),
                                title: locationModel.title);
                          } else {
                            return MapObject(
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: locationModel.id !=
                                              selectedQrSnapshot?.data?.id
                                          ? Colors.black
                                          : Colors.blue),
                                  child: Icon(Icons.qr_code,
                                      color: locationModel.id !=
                                              selectedQrSnapshot?.data?.id
                                          ? Colors.white
                                          : Colors.green),
                                ),
                                offset:
                                    Offset(locationModel.x, locationModel.y),
                                size: Size(8, 8),
                                title: locationModel.title);
                          }
                        }).toList();

                        return ZoomContainer(
                            zoomLevel: 4,
                            selectedQrOffset: selectedQrSnapshot.data != null
                                ? Offset(selectedQrSnapshot.data.x,
                                    selectedQrSnapshot.data.y)
                                : Offset(0, 0),
                            imageProvider: Image.asset("assets/map.png").image,
                            objects: locations);
                      }),
                );
              }),
          buildFloatingSearchBar(context),
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) async {
        // Call your model, bloc, controller here.
        final strFrontCode = query.substring(0, query.length - 1);
        final strEndCode = query.characters.last;
        final limit =
            strFrontCode + String.fromCharCode(strEndCode.codeUnitAt(0) + 1);
        var querySnapshot = await locationsRef
            .where("type", isEqualTo: 1)
            .where('title', isGreaterThanOrEqualTo: query)
            .where('title', isLessThan: limit)
            .get();

        List<LocationModel> locations = querySnapshot.docs.map((e) {
          return LocationModel.fromJson(e.id, e.data());
        }).toList();
        searchResultSupject.add(locations);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: StreamBuilder<List<LocationModel>>(
              stream: searchResultSupject,
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: snapshot?.data?.map((location) {
                    return Container(
                      color: Colors.white10,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 16),
                      height: 40,child: Text(
                      location.title ,
                      style: TextStyle(
                        fontWeight: FontWeight.bold ,
                        fontSize: 16
                      ),
                    ),);
                  })?.toList()??Container(),
                );
              }
            ),
          ),
        );
      },
    );
  }
}
