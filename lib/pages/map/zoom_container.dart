import 'package:flutter/material.dart';
import 'package:indoor_map_app/model/location_model.dart';
import 'package:indoor_map_app/model/map_object.dart';

import 'image_viewport.dart';

class ZoomContainerState extends State<ZoomContainer> {
  double _zoomLevel;
  ImageProvider _imageProvider;
  List<MapObject> _objects;
  Offset _setectedQrOffset ;

  @override
  void initState() {
    super.initState();
    _zoomLevel = widget.zoomLevel;
    _imageProvider = widget.imageProvider;
    _objects = widget.objects;
    _setectedQrOffset = widget.selectedQrOffset;
  }

  @override
  void didUpdateWidget(ZoomContainer oldWidget){
    super.didUpdateWidget(oldWidget);
    if(widget.imageProvider != _imageProvider) _imageProvider = widget.imageProvider;
    if(widget.selectedQrOffset != _setectedQrOffset ) _setectedQrOffset = widget.selectedQrOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ImageViewport(
          zoomLevel: _zoomLevel,
          imageProvider: _imageProvider,
          objects: _objects,
          selectedQrOffset: _setectedQrOffset,
        ),
        Row(
          children: <Widget>[
            IconButton(
              color: Colors.red,
              icon: Icon(Icons.zoom_in),
              onPressed: () {
                setState(() {
                  _zoomLevel = _zoomLevel * 2;
                });
              },
            ),
            SizedBox(
              width: 5,
            ),
            IconButton(
              color: Colors.red,
              icon: Icon(Icons.zoom_out),
              onPressed: () {
                setState(() {
                  _zoomLevel = _zoomLevel / 2;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ZoomContainer extends StatefulWidget {
  final double zoomLevel;
  final ImageProvider imageProvider;
  final List<MapObject> objects;

  Offset selectedQrOffset;

  ZoomContainer({
    this.zoomLevel = 1,
    @required this.imageProvider,
    this.objects = const [],
    this.selectedQrOffset
  });

  @override
  State<StatefulWidget> createState() => ZoomContainerState();
}
