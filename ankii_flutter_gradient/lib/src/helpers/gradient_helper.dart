import 'dart:math';
import 'package:flutter/material.dart';


class AnKiiDegreeAlignment{
  final Alignment begin;
  final Alignment end;

  AnKiiDegreeAlignment(this.begin, this.end);
}

class GradientHelper {
  static AnKiiDegreeAlignment calcGradientAlignment(double degree) {

    Alignment start = Alignment(0, -1);
    double xEnd;
    double yEnd;

    double degreeTemp = degree.abs();
    final double radian = (degreeTemp * pi) / 180;
    if (degreeTemp < 90) {
      xEnd = sin((pi / 2) - radian);
      yEnd = sin(radian);
    } else if (degreeTemp > 90) {
      xEnd = sin(radian - (pi / 2));
      yEnd = sin((pi / 2) - (radian - (pi / 2)));
    } else {
      xEnd = 0;
      yEnd = 1;
    }
    if (degree >= 90) {
      final Alignment end = Alignment(yEnd, xEnd);
      start = Alignment(end.x * -1, end.y * -1);

      return AnKiiDegreeAlignment(start, end);
    } else {
      final Alignment end = Alignment(yEnd, -xEnd);
      start = Alignment(-end.x, -end.y);

      return AnKiiDegreeAlignment(start, end);
    }
  }
}
