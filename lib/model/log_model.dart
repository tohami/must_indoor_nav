import 'dart:ui';

class LogModel {
  double startX  ;
  double endX ;
  double startY  ;
  double endY ;



  LogModel(this.startX , this.startY , this.endX , this.endY);

  LogModel.fromJson(Map<String, dynamic> json) {
    startX = json['startX'];
    startY = json['startY'];
    endX = json['endX'];
    endY = json['endY'] ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['startX'] = this.startX;
    data['startY'] = this.startY;
    data['endX'] = this.endX;
    data['endY'] = this.endY;
    return data;
  }

   Offset get start => Offset(startX , startY) ;
   Offset get end => Offset(endX , endY) ;
}