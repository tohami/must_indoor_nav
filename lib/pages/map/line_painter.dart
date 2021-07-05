import 'dart:ui';

import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Offset end;
  final Offset start;

  LinePainter(this.start, this.end);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(start, end, paint);
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}