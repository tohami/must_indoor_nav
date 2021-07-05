import 'package:flutter/material.dart';
import 'package:indoor_map_app/model/location_model.dart';
import 'package:indoor_map_app/model/log_model.dart';
import 'package:indoor_map_app/model/map_object.dart';

import 'image_viewport.dart';

class ZoomContainerState extends State<ZoomContainer> {
  double _zoomLevel;
  ImageProvider _imageProvider;
  List<MapObject> _objects;
  List<LogModel> _routes;

  @override
  void initState() {
    super.initState();
    _zoomLevel = widget.zoomLevel;
    _imageProvider = widget.imageProvider;
    _objects = widget.objects;
    _routes = widget.route;
  }

  @override
  void didUpdateWidget(ZoomContainer oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.imageProvider != _imageProvider) _imageProvider = widget.imageProvider;
    if(widget.route != _routes ) _routes = widget.route;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Center(
            child: ImageViewport(
              zoomLevel: _zoomLevel,
              imageProvider: _imageProvider,
              objects: _objects,
              route: _routes,
            ),
          ),
          Positioned(
            top: 60,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 5,
                ),
                Card(
                  child: IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.zoom_in),
                    onPressed: () {
                      setState(() {
                        _zoomLevel = _zoomLevel * 2;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Card(
                  child: IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.zoom_out),
                    onPressed: () {
                      setState(() {
                        _zoomLevel = _zoomLevel / 2;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomContainer extends StatefulWidget {
  final double zoomLevel;
  final ImageProvider imageProvider;
  final List<MapObject> objects;
  final List<LogModel> route ;
  ZoomContainer({
    this.zoomLevel = 1,
    @required this.imageProvider,
    this.objects = const [], this.route
  });

  @override
  State<StatefulWidget> createState() => ZoomContainerState();
}
