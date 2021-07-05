import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:indoor_map_app/model/location_model.dart';
import 'package:indoor_map_app/model/log_model.dart';
import 'package:indoor_map_app/model/map_object.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:rxdart/rxdart.dart';

import 'map/zoom_container.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<LocationModel> locations = List();

  List<MapObject> mapObjects = List();
  List<LogModel> allPaths = List() ;
  List<LogModel> visiblePath = List();
  LocationModel selectedQr;
  LocationModel selectedSearch;

  final searchController = FloatingSearchBarController();

  final BehaviorSubject<List<LocationModel>> searchResultSupject =
      BehaviorSubject.seeded([]);

  final CollectionReference locationsRef =
      FirebaseFirestore.instance.collection('locations');

  final CollectionReference pathsRef =
      FirebaseFirestore.instance.collection('logs');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData() ;
  }

  void loadData() async {
    this.locations.clear();
    this.mapObjects.clear();
    this.allPaths.clear() ;
    var pathsData = await pathsRef.get();
    var locationsData = await locationsRef.get();
    locationsData.docs.forEach((element) {
      var locationModel = LocationModel.fromJson(element.id, element.data());
      locations.add(locationModel);
      if (locationModel.type == 1) {
        mapObjects.add(MapObject(
            child: Container(
              child: Icon(
                Icons.place,
                color: Colors.green,
              ),
            ),
            offset: Offset(locationModel.x, locationModel.y),
            size: Size(10, 10),
            title: locationModel.title));
      } else {
        mapObjects.add(MapObject(
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: locationModel.id != selectedQr?.id
                      ? Colors.black
                      : Colors.blue),
              child: Icon(Icons.qr_code,
                  color: locationModel.id != selectedQr?.id
                      ? Colors.white
                      : Colors.green),
            ),
            offset: Offset(locationModel.x, locationModel.y),
            size: Size(8, 8),
            title: locationModel.title));
      }
    });
    selectedQr = locations.last;
    allPaths.addAll(pathsData.docs?.map((e) => LogModel.fromJson(e.data())));
    setState(() {});
  }

  void updateDirections({LocationModel from , LocationModel to}) {
    if(from != null && to != null){
      print("calculating routes from ${from.offset} to ${to.offset}") ;
      List<LogModel> logs = [...allPaths] ;
      List<LogModel> path = [] ;
      // get the nearst point to from
      var firstLog = logs.reduce((value, element) {
        //nearest to from
        var valDistance = min((value.start - from.offset).distance , (value.end - from.offset).distance);
        var elementDistance = min((element.start - from.offset).distance , (element.end - from.offset).distance);
        return valDistance > elementDistance ? element : value ;
      });
      print("first Log is ${firstLog.start.dx} ${firstLog.end.dx}") ;
      path.add(firstLog);
      logs.remove(firstLog) ;
      //walk
      Offset edge = (firstLog.start - to.offset).distance < (firstLog.end - to.offset).distance? firstLog.start : firstLog.end;
      print("new Edge is ${edge.dx}") ;
      while(true){
        print(allPaths.where((element) {
          return element.start == edge || element.end == edge ;
        }).length);
        var nextLog = allPaths.where((element) {
          return element.start == edge || element.end == edge ;
        }).reduce((value, element) {
          //nearest to from
          var valDistance = value.start == edge ? (value.end - edge).distance : (value.start - edge).distance;
          var elementDistance = value.start == edge ? (element.end - edge).distance :(element.start - edge).distance ;
          print("val distance ${valDistance}");
          print("element distance ${elementDistance}");
          return valDistance > elementDistance ? element : value ;
        });
        var newEdge = nextLog.start == edge ? nextLog.end : nextLog.start ;
        print(nextLog.start.dx);
        print(edge.dx);
        print(nextLog.start == edge);
        print("new Edge is ${newEdge.dx}") ;
        //getting far from our target
        print((newEdge - to.offset).distance ) ;
        print((edge - to.offset).distance ) ;
        if((newEdge - to.offset).distance > (edge - to.offset).distance){
          print("new Edge is far from destination ") ;
          break ;
        }else {
          path.add(nextLog) ;
          edge = newEdge ;
          print("next Log is ${nextLog.start.dx} ${nextLog.end.dx}") ;
        }
      }
      visiblePath.clear() ;
      visiblePath.addAll(path) ;
      setState(() {
      });
    }
  }

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
          selectedQr =
              LocationModel.fromJson(location.id, location.data());
          setState(() {});
          if(selectedSearch != null)
            updateDirections(from: selectedQr , to: selectedSearch) ;

          Fluttertoast.showToast(
              msg: selectedQr.x.toString(),
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
          ZoomContainer(
              zoomLevel: 1,
              // selectedLocation: locations.firstWhere((element) => element.offset.dx == selectedQrSnapshot?.data?.x && element.offset.dy == selectedQrSnapshot?.data?.y , orElse: ()=>null),
              imageProvider: Image.asset("assets/map.png").image,
              objects: mapObjects ,
          route: visiblePath),
          buildFloatingSearchBar(context),
          Positioned(
              bottom: 0,
              left: 0,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(searchController.query),
                ),
              ))
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
      controller: searchController,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) async {
        // Call your model, bloc, controller here.
        if (query.length == 0) return;
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
          showIfClosed: true,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 5.0,
            child: StreamBuilder<List<LocationModel>>(
                stream: searchResultSupject,
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snapshot?.data?.map((location) {
                          return GestureDetector(
                            onTap: () {
                              searchController.close();
                              searchController.query = location.title;
                              selectedSearch = location ;
                              setState(() {
                              });
                              if(selectedQr != null){
                                updateDirections(from: selectedQr , to: selectedSearch);
                              }
                            },
                            child: Container(
                              color: Colors.white10,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 16),
                              height: 40,
                              child: Text(
                                location.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          );
                        })?.toList()??[],
                  );
                }),
          ),
        );
      },
    );
  }
}
