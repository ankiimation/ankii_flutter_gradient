import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:ankii_flutter_gradient/src/helpers/string_helper.dart';
import 'package:ankii_flutter_gradient/src/services/wallpaper_service.dart';
import 'package:ankii_flutter_gradient/src/widgets/circular_slider.dart';
import 'package:ankii_flutter_gradient/src/widgets/increase_slider.dart';
import 'package:ankii_flutter_gradient/src/widgets/no_glowable_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reorderables/reorderables.dart';
import 'package:share/share.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

import '../helpers/gradient_helper.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _type = 0;
  List<AnKiiGradientColor> gradientColors = [
    AnKiiGradientColor(color: Colors.red, stop: 0),
    AnKiiGradientColor(color: Colors.blue, stop: 1)
  ];
  double degreeValue = 180;
  Alignment begin = Alignment.topCenter;
  Alignment end = Alignment.bottomCenter;
  bool viewFull = false;
  bool _randomLoading = false;
  int currentColorIndex = 0;
  Color itemColor = Colors.white;

  // SUB WIDGETS
  Widget gradientCard() {
    double width = MediaQuery.of(context).size.width;
    double height = 150;
    double padding = 10;
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end,
          )
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()]);

    return Card(
      elevation: viewFull ? 0 : 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(padding),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    gradient: SweepGradient(
                      center: FractionalOffset.center,
                      startAngle: 0,
                      endAngle: degreeValue * 2 * pi / 360,
                      colors: <Color>[
                        ...gradientColors.map((e) => e.color).toList()
                      ],
                      stops: <double>[
                        ...gradientColors.map((e) => e.stop).toList()
                      ],
                    ),
                    border: Border.all(color: itemColor, width: 2)),
                child: Center(
                    child: Text(
                  'Swipe',
                  style: TextStyle(color: itemColor),
                )),
              ),
            ),
            SizedBox(
              width: padding,
            ),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    gradient: gradient.scale(0.5),
                    border: Border.all(color: itemColor, width: 2)),
                child: Center(
                    child: Text(
                  'Scale x2',
                  style: TextStyle(color: itemColor),
                )),
              ),
            ),
            SizedBox(
              width: padding,
            ),
            Expanded(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                decoration: BoxDecoration(
                    border: Border.all(color: itemColor, width: 2)),
                child: Center(
                    child: Text(
                  'Transparent',
                  style: TextStyle(color: itemColor),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _typeSwitcherButton({int index = 0, String text = ''}) {
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()])
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()]);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_type != index) {
            _type = index;
          }
        });
      },
      child: Container(
          width: 100,
          decoration: BoxDecoration(
              border: Border.all(color: itemColor, width: 2),
              color: _type != index ? Colors.transparent : itemColor,
              borderRadius: BorderRadius.circular(5)),
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Text(
            text,
            style: TextStyle(
                color: _type != index ? itemColor : gradientColors[0].color),
          )),
    );
  }

  Widget typeSwitcher() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _typeSwitcherButton(text: 'Linear', index: 0),
          SizedBox(
            width: 10,
          ),
          _typeSwitcherButton(text: 'Radial', index: 1),
          SizedBox(
            width: 10,
          ),
          _typeSwitcherButton(text: 'Swipe', index: 2),
        ],
      ),
    );
  }

  Widget _linerOptionCard(Widget child) {
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end)
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()]);
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.width),
            padding: EdgeInsets.all(10),
            child: child));
  }

  Widget linearOption() {
    return Container(
      padding: EdgeInsets.only(bottom: 100),
      child: _linerOptionCard(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _degreesSlider(),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stopViewer(),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifyingStopSlider(),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [_colorsList(), _addColorButton()],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifying()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addColorButton() {
    return InkWell(
      onTap: () {
        addColor();
      },
      child: Container(
        alignment: Alignment.center,
        height: 70,
        width: 70,
        child: Icon(
          FontAwesomeIcons.plusCircle,
          color: itemColor,
        ),
      ),
    );
  }

  Widget _stopViewer() {
    double width = MediaQuery.of(context).size.width * 0.7;
    var gradient = LinearGradient(
        colors: [...gradientColors.map((e) => e.color).toList()],
        stops: [...gradientColors.map((e) => e.stop).toList()]);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      height: 50,
      width: width,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: itemColor, width: 2)
          // boxShadow: [BoxShadow(color: itemColor, blurRadius: 5)]
          ),
      child: Stack(
        children: [
          ...gradientColors
              .asMap()
              .map((index, data) => MapEntry(index,
                  __stopViewerIndicator(index, max: width, percent: data.stop)))
              .values
              .toList(),
        ],
      ),
    );
  }

  Widget __stopViewerIndicator(int index,
      {double max = 1, double percent = 1}) {
    double width = 20;
    double padding = 10;
    return GestureDetector(
      onTapDown: (d) {
        setState(() {
          currentColorIndex = index;
        });
      },
      onHorizontalDragStart: (d) {
        setState(() {
          currentColorIndex = index;
        });
      },
      onHorizontalDragUpdate: (d) {
        double toIncrease = 0.01;
        if (d.delta.dx > 0 &&
            (gradientColors[index].stop + toIncrease < maxStop(index))) {
          setState(() {
            gradientColors[index].stop += toIncrease;
          });
        } else if (d.delta.dx < 0 &&
            (gradientColors[index].stop - toIncrease > minStop(index))) {
          setState(() {
            gradientColors[index].stop -= toIncrease;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(
            left: max * percent > width + padding
                ? max * percent - width - padding
                : max * percent),
        height: 50,
        width: width,
        decoration: BoxDecoration(
            color: gradientColors[index].color,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: itemColor, width: currentColorIndex == index ? 4 : 2)),
      ),
    );
  }

  Widget _degreesSlider() {
    return Container(
        width: 200,
        height: 200,
        child: SingleCircularSlider(
          360,
          degreeValue.toInt(),
          onSelectionChange: (a, b, c) {
            if (b == 0)
              degreeValue = 1;
            else
              degreeValue = b.toDouble();
            var alignmentTemp =
                GradientHelper.calcGradientAlignment(degreeValue);
            setState(() {
              begin = alignmentTemp.begin;
              end = alignmentTemp.end;
            });
          },
          child: Center(
              child: Text(
            '${degreeValue.floor()}°',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: itemColor),
          )),
        ));
  }

  Widget _colorsList() {
    return Container(
      child: ReorderableWrap(
          alignment: WrapAlignment.center,
          onReorder: (int oldIndex, int newIndex) {
            onReorder(oldIndex, newIndex);
          },
          children: [
            ...gradientColors
                .map((e) => e.color)
                .toList()
                .asMap()
                .map((index, value) => MapEntry(index, __colorListItem(index)))
                .values
                .toList(),
          ]),
    );
  }

  Widget __colorListItem(int index) {
    double width = 70;
    double height = width;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                currentColorIndex = index;
              });
            },
            child: Container(
              padding: currentColorIndex != index ? EdgeInsets.all(5) : null,
              child: Container(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: itemColor,
                          width: currentColorIndex == index ? 4 : 2)),
                  color: gradientColors[index].color,
                  child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: itemColor),
                      )),
                ),
              ),
            ),
          ),
          gradientColors.length <= 2
              ? Container()
              : Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    child: MaterialButton(
                      onPressed: () {
                        removeColor(index);
                      },
                      shape: CircleBorder(),
                      color: itemColor,
                      padding: EdgeInsets.all(0),
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _colorModifying() {
    if (currentColorIndex > gradientColors.length - 1) {
      currentColorIndex = gradientColors.length - 1;
    }
    return Container(
      child: SlidePicker(
        pickerColor: gradientColors[currentColorIndex].color,
        displayThumbColor: false,
        showLabel: false,
        showIndicator: false,
        sliderTextStyle: TextStyle(color: itemColor),
        onColorChanged: (newColor) {
          setState(() {
            gradientColors[currentColorIndex].color = newColor;
          });
        },
      ),
    );
  }

  Widget _colorModifyingStopSlider() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'STOP',
            style: TextStyle(fontWeight: FontWeight.bold, color: itemColor),
          ),
          Expanded(
            flex: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: gradientColors[currentColorIndex].color,
                inactiveTrackColor:
                    gradientColors[currentColorIndex].color.withOpacity(0.5),
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 7.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                thumbColor: Colors.white,
                overlayColor:
                    gradientColors[currentColorIndex].color.withOpacity(0.5),
                tickMarkShape: RoundSliderTickMarkShape(),
                activeTickMarkColor: gradientColors[currentColorIndex].color,
                inactiveTickMarkColor: gradientColors[currentColorIndex].color,
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                valueIndicatorColor: gradientColors[currentColorIndex].color,
              ),
              child: Slider(
                value: gradientColors[currentColorIndex].stop,

                min: currentColorIndex == 0
                    ? 0
                    : (gradientColors[currentColorIndex - 1].stop + 0.01),
                max: currentColorIndex == gradientColors.length - 1
                    ? 1
                    : (gradientColors[currentColorIndex + 1].stop - 0.01),
                onChanged: (value) {
                  setState(() {
                    gradientColors[currentColorIndex].stop = value;
                  });
                },
                // inactiveColor: PRIMARY_COLOR.withOpacity(0.01),
                // activeColor: PRIMARY_COLOR,
              ),
            ),
          ),
          Text(
            '${(gradientColors[currentColorIndex].stop * 100).toStringAsFixed(2)}%',
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, color: itemColor),
          )
        ],
      ),
    );
  }

  Widget radialOption() {
    return Container(
      padding: EdgeInsets.only(bottom: 100),
      child: _linerOptionCard(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stopViewer(),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifyingStopSlider(),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [_colorsList(), _addColorButton()],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifying()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sweepOption() {
    return Container(
      padding: EdgeInsets.only(bottom: 100),
      child: _linerOptionCard(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sweepEndSlider(),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _stopViewer(),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifyingStopSlider(),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [_colorsList(), _addColorButton()],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  _colorModifying()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double sweepEndValue = pi / 180;

  Widget _sweepEndSlider() {
    return Container(
        child: IncreaseSlider(
      min: 1 * 2 * pi / 360,
      max: double.maxFinite,
      interval: pi / 180,
      onUpdate: (value) {
        if (value > pi / 180)
          setState(() {
            sweepEndValue = value;
          });
      },
    ));
  }

  //MAIN WIDGET
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var gradientColor in gradientColors) {
      gradientColor.color = _generateRandomColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end)
        : _type == 1
            ? RadialGradient(
                colors: [...gradientColors.map((e) => e.color).toList()],
                stops: [...gradientColors.map((e) => e.stop).toList()])
            : SweepGradient(
                colors: [...gradientColors.map((e) => e.color).toList()],
                stops: [
                  ...gradientColors.map((e) => e.stop).toList(),
                ],
                center: FractionalOffset(0.5, 0.5),
                startAngle: 0,
                endAngle: sweepEndValue,
              );
    return Scaffold(
        backgroundColor: gradientColors[0].color,
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     setState(() {
        //       viewFull = !viewFull;
        //     });
        //   },
        //   elevation: viewFull ? 0 : 10,
        //   child: Container(
        //       width: double.maxFinite,
        //       height: double.maxFinite,
        //       decoration: BoxDecoration(
        //           border: Border.all(color: Colors.white, width: 3),
        //           borderRadius: BorderRadius.circular(100),
        //           gradient: gradient),
        //       child: Icon(Icons.remove_red_eye)),
        // ),
        body: Stack(
          children: [
            Container(
              // decoration: BoxDecoration(
              //     image: DecorationImage(
              //         image: AssetImage("assets/transparent.jpg"),
              //         fit: BoxFit.fill)),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: double.maxFinite,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: gradientColors[0].color, gradient: gradient),
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: viewFull
                  ? SizedBox()
                  : Column(
                      children: [
                        Expanded(
                            child: NoGrowScrollView(
                          child: ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).padding.top + 20,
                              ),
                              Text(
                                '#GRADiiENT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: itemColor),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              typeSwitcher(),
                              SizedBox(
                                height: 30,
                              ),
                              // gradientCard(),
                              SizedBox(
                                height: 30,
                              ),
                              _type == 0
                                  ? linearOption()
                                  : _type == 1 ? radialOption() : sweepOption(),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10, bottom: 10),
                    width: 50,
                    height: 50,
                    child: MaterialButton(
                      onPressed: () {
                        random();
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        decoration: BoxDecoration(
                            gradient: gradient,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: itemColor, width: 2)),
                        child: _randomLoading
                            ? SpinKitDualRing(
                                color: itemColor,
                                duration: Duration(milliseconds: 500),
                              )
                            : Icon(
                                FontAwesomeIcons.dice,
                                color: itemColor,
                              ),
                      ),
                      padding: EdgeInsets.all(0),
                      shape: CircleBorder(),
                    ),
                  ),
                  Wrap(
                    // mainAxisSize: MainAxisSize.min,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        width: 50,
                        height: 50,
                        child: MaterialButton(
                          onPressed: () async {
                            showSetWallpaperDialog();
                          },
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: itemColor, width: 2)),
                            child: settingWallpaperDialogShowing
                                ? SpinKitDualRing(color: itemColor)
                                : Icon(
                                    FontAwesomeIcons.image,
                                    color: itemColor,
                                  ),
                          ),
                          padding: EdgeInsets.all(0),
                          shape: CircleBorder(),
                        ),
                      ),
                      // Container(
                      //   margin: EdgeInsets.only(right: 10, bottom: 10),
                      //   width: 50,
                      //   height: 50,
                      //   child: MaterialButton(
                      //     onPressed: () {
                      //       setState(() {
                      //         viewFull = !viewFull;
                      //       });
                      //     },
                      //     child: Container(
                      //       width: double.maxFinite,
                      //       height: double.maxFinite,
                      //       decoration: BoxDecoration(
                      //           gradient: gradient,
                      //           borderRadius: BorderRadius.circular(100),
                      //           border: Border.all(color: itemColor, width: 2)),
                      //       child: viewFull
                      //           ? SpinKitDualRing(color: itemColor)
                      //           : Icon(
                      //               FontAwesomeIcons.save,
                      //               color: itemColor,
                      //             ),
                      //     ),
                      //     padding: EdgeInsets.all(0),
                      //     shape: CircleBorder(),
                      //   ),
                      // ),
                      Container(
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        width: 50,
                        height: 50,
                        child: MaterialButton(
                          onPressed: () {
                            viewCode();
                          },
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: itemColor, width: 2)),
                            child: Icon(
                              FontAwesomeIcons.code,
                              color: itemColor,
                            ),
                          ),
                          padding: EdgeInsets.all(0),
                          shape: CircleBorder(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10, bottom: 10),
                        width: 50,
                        height: 50,
                        child: MaterialButton(
                          onPressed: () {
                            setState(() {
                              viewFull = !viewFull;
                            });
                          },
                          child: Container(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: itemColor, width: 2)),
                            child: Icon(
                              viewFull
                                  ? FontAwesomeIcons.slidersH
                                  : FontAwesomeIcons.eye,
                              color: itemColor,
                            ),
                          ),
                          padding: EdgeInsets.all(0),
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void onChangeStop() {}

  void random() {
    if (!_randomLoading) {
      int length = Random().nextInt(5 - 2 + 1) + 2;
      sweepEndValue =
          (Random().nextInt((360 * 2 * pi / 360 - pi / 180 + 1).floor()) +
                  pi / 180)
              .toDouble();
      List<Color> colors =
          List<Color>.generate(length, (index) => _generateRandomColor());
      List<double> stops = _impliedStops(length);
      gradientColors.clear();
      for (int i = 0; i < colors.length; i++) {
        gradientColors
            .add(AnKiiGradientColor(stop: stops[i], color: colors[i]));
      }
      degreeValue = Random().nextInt(360).toDouble();
      var alignment =
          GradientHelper.calcGradientAlignment(degreeValue.toDouble());
      setState(() {
        begin = alignment.begin;
        end = alignment.end;
        currentColorIndex = gradientColors.length - 1;
      });

      if (!viewFull) {
        setState(() {
          _randomLoading = true;
          viewFull = true;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            _randomLoading = false;
            viewFull = false;
          });
        });
      }
    }
  }

  void removeColor(int index) {
    setState(() {
      gradientColors.removeAt(index);
      gradientColors.last.stop = 1;
      currentColorIndex = gradientColors.length - 1;
    });
  }

  void addColor() {
    List<double> stops = _impliedStops(gradientColors.length);

    // gradientColors.map((e) => e.stop).followedBy(stops);
    setState(() {
      // gradientColors.last.stop =
      //     (1 + gradientColors[gradientColors.length - 2].stop) / 2;
      gradientColors
          .add(AnKiiGradientColor(stop: 1, color: _generateRandomColor()));
      var stops = _impliedStops(gradientColors.length);
      gradientColors.asMap().forEach((index, value) {
        value.stop = stops[index];
      });

      currentColorIndex = gradientColors.length - 1;
    });
  }

  onReorder(int oldIndex, int newIndex) {
    print('$oldIndex - $newIndex');
    var oldTempColor = gradientColors[oldIndex].color;
    var newTempColor = gradientColors[newIndex].color;
    gradientColors[oldIndex].color = newTempColor;
    gradientColors[newIndex].color = oldTempColor;
    setState(() {
      currentColorIndex = newIndex;
    });
  }

  void viewCode() {
    bool copied = false;
    int codeTypeIndex = 0;
    showDialog(
        context: context,
        child: AlertDialog(
          content: StatefulBuilder(builder: (context, stateSetter) {
            var html = genCode(
                gradientType:
                    _type == 0 ? GradientType.linear : GradientType.radial,
                codeType: codeTypeIndex == 0
                    ? CodeGenType.flutter
                    : codeTypeIndex == 1
                        ? CodeGenType.css
                        : codeTypeIndex == 2
                            ? CodeGenType.android
                            : codeTypeIndex == 3
                                ? CodeGenType.ios
                                : CodeGenType.reactNative);
            var result = html.withOutHtmlTag();
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NoGrowScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            __viewCodeButton(
                                onPressed: () {
                                  stateSetter(() {
                                    codeTypeIndex = 0;
                                  });
                                },
                                selected: codeTypeIndex == 0,
                                text: 'Flutter'),
                            __viewCodeButton(
                                onPressed: () {
                                  stateSetter(() {
                                    codeTypeIndex = 1;
                                  });
                                },
                                selected: codeTypeIndex == 1,
                                text: 'CSS'),
                            __viewCodeButton(
                                onPressed: () {
                                  stateSetter(() {
                                    codeTypeIndex = 2;
                                  });
                                },
                                selected: codeTypeIndex == 2,
                                text: 'Android'),
                            __viewCodeButton(
                                onPressed: () {
                                  stateSetter(() {
                                    codeTypeIndex = 3;
                                  });
                                },
                                selected: codeTypeIndex == 3,
                                text: 'iOS'),
                            __viewCodeButton(
                                onPressed: () {
                                  stateSetter(() {
                                    codeTypeIndex = 4;
                                  });
                                },
                                selected: codeTypeIndex == 4,
                                text: 'React Native')
                          ],
                        ),
                      ),
                    ),
                    Html(
                      data: html,
                      style: {
                        "h2": Style(color: Colors.cyan),
                        "em": Style(color: Colors.lightBlue)
                      },
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          copied
                              ? Column(
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.check,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    Text(
                                      'Copied!',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  ],
                                )
                              : IconButton(
                                  icon: Icon(FontAwesomeIcons.copy),
                                  onPressed: () async {
                                    await Clipboard.setData(
                                        ClipboardData(text: result));
                                    stateSetter(() {
                                      copied = true;
                                    });
                                  }),
                          IconButton(
                              icon: Icon(FontAwesomeIcons.shareAlt),
                              onPressed: () {
                                Share.share(result);
                              }),
                        ])
                  ],
                ),
              ),
            );
          }),
        ));
  }

  Widget __viewCodeButton(
      {Function onPressed, bool selected = false, String text}) {
    return FlatButton(
      onPressed: onPressed,
      child: Text(
        '$text',
        style: TextStyle(
            fontWeight: selected ? FontWeight.bold : null,
            color: selected ? gradientColors[0].color : Colors.black26),
      ),
    );
  }

  bool settingWallpaperDialogShowing = false;
  bool setHomeWallpaper = true;
  bool setLockWallpaper = true;
  bool saveImage = true;

  showSetWallpaperDialog() async {
    bool settingWallpaper = false;
    bool isSuccessfully;
    setState(() {
      settingWallpaperDialogShowing = true;
    });
    await showDialog(
        context: context,
        barrierDismissible: false,
        child: AlertDialog(
          title: Text('Set Wallpaper'),
          content: StatefulBuilder(builder: (context, stateSetter) {
            return Container(
              child: isSuccessfully != null
                  ? Icon(
                      FontAwesomeIcons.check,
                      color: Colors.green,
                      size: 50,
                    )
                  : settingWallpaper
                      ? Container(
                          width: 100,
                          height: 100,
                          child:
                              SpinKitDualRing(color: gradientColors[0].color))
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: saveImage,
                                      activeColor: gradientColors[0].color,
                                      onChanged: (value) {
                                        stateSetter(() {
                                          saveImage = value;
                                        });
                                      }),
                                  Expanded(
                                      child: Text(
                                          'Save image${saveImage ? '\n(0/GRADiiENT/Wallpapers/)' : ''}'))
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                      value: setHomeWallpaper,
                                      activeColor: gradientColors[0].color,
                                      onChanged: (value) {
                                        stateSetter(() {
                                          setHomeWallpaper = value;
                                        });
                                      }),
                                  Expanded(
                                      child:
                                          Text('Set as Home Screen Wallpaper'))
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                      value: setLockWallpaper,
                                      activeColor: gradientColors[0].color,
                                      onChanged: (value) {
                                        stateSetter(() {
                                          setLockWallpaper = value;
                                        });
                                      }),
                                  Expanded(
                                      child:
                                          Text('Set as Lock Screen Wallpaper'))
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  !setHomeWallpaper && !setLockWallpaper
                                      ? Container()
                                      : FlatButton(
                                          child: Text(
                                            'Set',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: gradientColors[0].color,
                                                fontSize: 20),
                                          ),
                                          onPressed: () async {
                                            stateSetter(() {
                                              settingWallpaper = true;
                                            });
                                            await _setWallpaper(
                                                homeScreen: setHomeWallpaper,
                                                lockScreen: setLockWallpaper,
                                                save: saveImage);
                                            stateSetter(() {
                                              isSuccessfully = true;
                                            });
                                            Future.delayed(Duration(seconds: 2),
                                                () {
                                              stateSetter(() {
                                                Navigator.pop(context);
                                              });
                                            });
                                          },
                                        ),
                                  FlatButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
            );
          }),
        ));
    setState(() {
      settingWallpaperDialogShowing = false;
    });
  }

  _setWallpaper(
      {bool save = true,
      bool homeScreen = true,
      bool lockScreen = true}) async {
    //GRADIENT
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end)
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()]);

    // IMAGE SIZE
    double imageWidth = 2160;
    double imageHeight = 3840;

    //DRAW WITH CANVAS
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    Paint paint = Paint();
    paint.shader = gradient.createShader(Rect.fromCenter(
        center: Offset(imageWidth / 2, imageHeight / 2),
        width: imageWidth,
        height: imageHeight));
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(imageWidth / 2, imageHeight / 2),
            width: imageWidth,
            height: imageHeight),
        paint);

    ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(imageWidth.floor(), imageHeight.floor());

    //SAVE
    String fileName =
        (DateTime.now()).toIso8601String().replaceAll(".", "") + ".png";
    // "${gradient.colors.map((e) => e.value).toList()}_${gradient.stops.map((e) => e.toStringAsFixed(2)).toList()}_${begin}_${end}.png";
    var resultPath = await WallpaperService.save(
        (await image.toByteData(format: ui.ImageByteFormat.png)),
        fileName: fileName);
    // SET WALLPAPER
    int setWallpaperFor = homeScreen && lockScreen
        ? WallpaperManager.BOTH_SCREENS
        : homeScreen && !lockScreen
            ? WallpaperManager.HOME_SCREEN
            : WallpaperManager.LOCK_SCREEN;
    await WallpaperManager.setWallpaperFromFile(resultPath, setWallpaperFor);
    File tempFile = File(resultPath);
    if (save) {
      await __saveWallpaper(tempFile, fileName);
    }
    //delete temp file
    await tempFile.delete(recursive: true);
  }

  __saveWallpaper(File file, String fileName) async {
    var permission = Permission.storage;
    var permissionStatus = await permission.status;
    if (permissionStatus.isGranted) {
      Directory directory =
          Directory("/storage/emulated/0/GRADiiEnt/Wallpapers/");
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      (await file.copy(directory.path + fileName)).create();
      return;
    } else if (permissionStatus.isPermanentlyDenied) {
      //HANDLE PERMANENTLY;
    } else {
      await permission.request();
      permissionStatus = await permission.status;
      if (permissionStatus.isGranted) {
        Directory directory =
            Directory("/storage/emulated/0/GRADiiEnt/Wallpapers/");
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }
        (await file.copy(directory.path + fileName)).create();
        return;
      }
    }
  }

  List<double> _impliedStops(int length) {
    final double separation = 1.0 / (length - 1);
    return List<double>.generate(
      length,
      (int index) => index * separation,
      growable: false,
    );
  }

  double maxStop(int index) {
    // min: currentColorIndex == 0
    //     ? 0
    //     : (gradientColors[currentColorIndex - 1].stop + 0.01),
    double max = index == gradientColors.length - 1
        ? 1
        : (gradientColors[index + 1].stop - 0.01);
    return max;
  }

  double minStop(int index) {
    double min = index == 0 ? 0 : (gradientColors[index - 1].stop + 0.01);
    return min;
  }

  double genWidth(int index, {double maxWidth}) {
    double toSubtract = 0;
    for (int i = 0; i < index; i++) {
      toSubtract += gradientColors[i].stop * maxWidth;
    }
    for (int i = index + 1; i < gradientColors.length; i++) {
      toSubtract += gradientColors[i].stop * maxWidth;
    }
    print(toSubtract);
    return maxWidth - toSubtract;
  }

  Color _generateRandomColor() {
    return Color.fromRGBO(
        Random().nextInt(250), Random().nextInt(250), Random().nextInt(250), 1);
  }

  String genCode(
      {CodeGenType codeType = CodeGenType.flutter,
      GradientType gradientType = GradientType.linear}) {
    String flutterLinearResult = "<h2>LinearGradient</h2><p>("
        "</p><p><em>colors</em>: <strong>${gradientColors.map((e) => e.color).toList()}</strong>,"
        "</p><p><em>stops</em>: <strong>${gradientColors.map((e) => e.stop).toList()}</strong>,"
        "</p><p><em>begin</em>: <strong>$begin</strong>,"
        "</p><p><em>end</em>: <strong>$end</strong>"
        "</p><p>)</p>";
    String flutterRadialResult = "<h2>RadialGradient</h2><p>("
        "</p><p><em>colors</em>: <strong>${gradientColors.map((e) => e.color).toList()}</strong>,"
        "</p><p><em>stops</em>: <strong>${gradientColors.map((e) => e.stop).toList()}</strong>,"
        "</p><p>)</p>";

    //CSS
    var colorsString = "";
    gradientColors.forEach((element) {
      colorsString +=
          "<p></p><i>rgba</i>(${element.color.red},${element.color.green},${element.color.blue},${element.color.opacity}) ${element.stop * 100}%, ";
    });
    String cssResultLinear =
        "<p></p><b>background:</b> rgb(${gradientColors[0].color.red},${gradientColors[0].color.green},${gradientColors[0].color.blue});"
        "<p></p><b>background: <em>linear-gradient</em><br><br>(${degreeValue}deg, "
        "${colorsString});";
    String cssResultRadial =
        "<p></p><b>background:</b> rgb(${gradientColors[0].color.red},${gradientColors[0].color.green},${gradientColors[0].color.blue});"
        "<p></p><b>background:<em>radial-gradient</em><br><br>(circle, "
        "${colorsString});";
    if (gradientType == GradientType.linear) {
      if (codeType == CodeGenType.flutter) {
        return flutterLinearResult;
      }
      if (codeType == CodeGenType.css) {
        return cssResultLinear;
      }
      if (codeType == CodeGenType.android) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
      if (codeType == CodeGenType.ios) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
      if (codeType == CodeGenType.reactNative) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
    } else {
      if (codeType == CodeGenType.flutter) {
        return flutterRadialResult;
      }
      if (codeType == CodeGenType.css) {
        return cssResultRadial;
      }
      if (codeType == CodeGenType.android) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
      if (codeType == CodeGenType.ios) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
      if (codeType == CodeGenType.reactNative) {
        return "(っ◔◡◔)っ ♥ Updating ♥";
      }
    }
    return flutterLinearResult;
  }
}

enum CodeGenType {
  flutter,
  css,
  android,
  ios,
  reactNative,
}
enum GradientType { linear, radial }

class AnKiiGradientColor {
  double stop;
  Color color;

  AnKiiGradientColor({this.stop, this.color});
}
