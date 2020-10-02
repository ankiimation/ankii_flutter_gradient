import 'dart:async';

import 'package:flutter/material.dart';

class IncreaseSlider extends StatefulWidget {
  final double min;
  final double max;
  final double interval;
  final Function(double) onUpdate;

  IncreaseSlider(
      {this.min = 0, this.max = 100, this.interval = 1, this.onUpdate});

  @override
  _IncreaseSliderState createState() => _IncreaseSliderState();
}

class _IncreaseSliderState extends State<IncreaseSlider> {
  double currentValue = 0;
  double dx = 0;
  Timer timer;

  @override
  Widget build(BuildContext context) {
    double width = 300;
    double height = 50;
    double indicatorWidth = height;

    return Stack(
      children: [
        Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height),
              gradient: LinearGradient(colors: [Colors.red, Colors.blue])),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.remove,
                color: Colors.white,
              ),
              Icon(
                Icons.add,
                color: Colors.white,
              )
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: (DragUpdateDetails d) {
            // print(d.delta.dx);
            setState(() {
              dx += d.delta.dx;
            });
            timer?.cancel();
            // print(dx.floor());
            timer = Timer.periodic(
                Duration(
                    milliseconds: (300 / 2 - (dx.floor()).abs() + 1).floor()),
                (timer) {
              setState(() {
                if (dx < 0 && currentValue > widget.min) {
                  currentValue -= widget.interval;
                } else if (dx > 0 && currentValue < widget.max) {
                  currentValue += widget.interval;
                }
              });
              if (widget.onUpdate != null) {
                widget.onUpdate(currentValue);
              }
            });
          },
          onHorizontalDragEnd: (DragEndDetails d) {
            setState(() {
              dx = 0;
            });
            timer?.cancel();
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            margin: EdgeInsets.only(
                left: (width / 2 - indicatorWidth / 2 + dx) < 0
                    ? 0
                    : (width / 2 - indicatorWidth / 2 + dx) >
                            width - indicatorWidth
                        ? width - indicatorWidth
                        : (width / 2 - indicatorWidth / 2 + dx)),
            width: indicatorWidth,
            height: height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height),
                border: Border.all(color: Colors.white, width: 3)),
          ),
        ),
      ],
    );
  }
}
