import 'package:flutter/cupertino.dart';

class LocationModel {
  String id  ;
  String title  ;
  int type ;
  double x  ;
  double y ;

  LocationModel(this.id, this.title, this.x, this.y);

  LocationModel.fromJson(String id , Map<String, dynamic> json) {
    this.id = id;
    title = json['title'];
    x = json['x'];
    y = json['y'];
    type = json['type'] ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['x'] = this.x;
    data['y'] = this.y;
    data['type'] = this.type;
    return data;
  }
  Offset get offset => Offset(x, y) ;
}