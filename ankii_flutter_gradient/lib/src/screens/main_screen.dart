import 'dart:math';

import 'package:ankii_flutter_gradient/src/widgets/no_glowable_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  int degreeValue = 0;
  Alignment begin = Alignment.topCenter;
  Alignment end = Alignment.bottomCenter;
  bool viewFull = false;
  bool _randomLoading = false;
  int currentColorIndex = 0;
  Color itemColor = Colors.white;

  // SUB WIDGETS
  Widget gradientCard() {
    double width = MediaQuery.of(context).size.width;
    double height = width;

    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end)
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
            borderRadius: BorderRadius.circular(10),
            gradient: viewFull ? null : gradient),
        alignment: Alignment.center,
      ),
    );
  }

  Widget _typeSwitcherButton({int index = 0, String text = ''}) {
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()])
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()]);
    return MaterialButton(
      onPressed: () {
        setState(() {
          if (_type != index) {
            _type = index;
          }
        });
      },
      elevation: _type == index ? 0 : 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: Colors.white,
      padding: EdgeInsets.all(0),
      child: Container(
          width: 100,
          decoration: BoxDecoration(
              gradient: _type == index ? gradient : null,
              borderRadius: BorderRadius.circular(5)),
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Text(
            text,
            style: TextStyle(color: _type == index ? itemColor : null),
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
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            _degreesSlider(),
            Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  _stopViewer(),
                  _colorModiifyingStopSlider(),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(flex: 1, child: _colorsList()),
                  Expanded(flex: 2, child: _colorModifying())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopViewer() {
    double width = 300;
    var gradient = LinearGradient(
        colors: [...gradientColors.map((e) => e.color).toList()],
        stops: [...gradientColors.map((e) => e.stop).toList()]);
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(vertical: 2),
      height: 50,
      width: width,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: itemColor, blurRadius: 5)]),
      child: Stack(
        children: [
          ...gradientColors
              .asMap()
              .map((index, data) => MapEntry(index,
                  __stopViewerIndicator(index, max: width, percent: data.stop)))
              .values
              .toList()
        ],
      ),
    );
  }

  Widget __stopViewerIndicator(int index,
      {double max = 1, double percent = 1}) {
    double width = 20;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentColorIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(
            left:
                max * percent > width ? max * percent - width : max * percent),
        height: 50,
        width: width,
        decoration: BoxDecoration(
            color: gradientColors[index].color,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: itemColor, width: currentColorIndex == index ? 5 : 2)),
      ),
    );
  }

  Widget _degreesSlider() {
    return Container(
      width: 200,
      height: 200,
      child: SingleCircularSlider(
        180,
        degreeValue ~/ 2,
        onSelectionChange: (a, b, c) {
          degreeValue = b * 2;
          var alignments =
              GradientHelper.calcGradientAlignment(degreeValue.toDouble());
          setState(() {
            begin = alignments.begin;
            end = alignments.end;
          });
        },
        selectionColor: itemColor.withOpacity(0.5),
        baseColor: itemColor.withOpacity(0.2),
        handlerColor: itemColor,
        child: Center(
            child: Text(
          '${degreeValue}°',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: itemColor),
        )),
      ),
    );
  }

  Widget _colorsList() {
    return Container(
      child: Wrap(alignment: WrapAlignment.center, children: [
        ...gradientColors
            .map((e) => e.color)
            .toList()
            .asMap()
            .map((index, value) => MapEntry(index, __colorListItem(index)))
            .values
            .toList(),
        InkWell(
          onTap: () {
            addColor();
          },
          child: Container(
            padding: EdgeInsets.all(5),
            alignment: Alignment.center,
            width: 50,
            height: 50,
            child: Icon(
              Icons.add,
              color: itemColor,
            ),
          ),
        )
      ]),
    );
  }

  Widget __colorListItem(int index) {
    double width = 50;
    double height = width;
    return InkWell(
      onTap: () {
        setState(() {
          currentColorIndex = index;
        });
      },
      child: Container(
        width: width,
        height: height,
        padding: currentColorIndex == index ? EdgeInsets.all(5) : null,
        child: Container(
          child: Card(
            elevation: currentColorIndex == index ? 0 : 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color: itemColor,
                    width: currentColorIndex == index ? 5 : 3)),
            color: gradientColors[index].color,
            child: Container(
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: itemColor),
                )),
          ),
        ),
      ),
    );
  }

  Widget _colorModifying() {
    if (currentColorIndex > gradientColors.length - 1) {
      currentColorIndex = gradientColors.length - 1;
    }
    return Container(
      child: Column(
        children: [
          SlidePicker(
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
        ],
      ),
    );
  }

  Widget _colorModiifyingStopSlider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            'STOP',
            style: TextStyle(fontWeight: FontWeight.bold, color: itemColor),
          ),
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
                  : gradientColors[currentColorIndex - 1].stop,
              max: currentColorIndex == gradientColors.length - 1
                  ? 1
                  : gradientColors[currentColorIndex + 1].stop,
              onChanged: (value) {
                setState(() {
                  gradientColors[currentColorIndex].stop = value;
                });
              },
              // inactiveColor: PRIMARY_COLOR.withOpacity(0.2),
              // activeColor: PRIMARY_COLOR,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '${(gradientColors[currentColorIndex].stop * 100).toStringAsFixed(2)}%',
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.bold, color: itemColor),
          ),
        )
      ],
    );
  }

  Widget radialOption() {
    return Container(
      padding: EdgeInsets.only(bottom: 100),
      child: _linerOptionCard(
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            _stopViewer(),
            _colorModiifyingStopSlider(),
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(flex: 1, child: _colorsList()),
                  Expanded(flex: 2, child: _colorModifying())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //MAIN WIDGET
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // gradient = LinearGradient(colors: colors);
  }

  @override
  Widget build(BuildContext context) {
    Gradient gradient = _type == 0
        ? LinearGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()],
            begin: begin,
            end: end)
        : RadialGradient(
            colors: [...gradientColors.map((e) => e.color).toList()],
            stops: [...gradientColors.map((e) => e.stop).toList()]);
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
            AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              height: double.maxFinite,
              width: double.maxFinite,
              decoration: BoxDecoration(gradient: gradient),
              child: AnimatedSwitcher(
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
                                  height: MediaQuery.of(context).padding.top,
                                ),
                                // Container(
                                //     margin: EdgeInsets.all(10),
                                //     child: gradientCard()),
                                typeSwitcher(),
                                SizedBox(
                                  height: 20,
                                ),
                                _type == 0 ? linearOption() : radialOption(),
                                SizedBox(
                                  height: 20,
                                )
                              ],
                            ),
                          ))
                        ],
                      ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
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
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                              ? FontAwesomeIcons.eyeSlash
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
            ),
          ],
        ));
  }

  void onChangeStop() {}

  void random() {
    if (!_randomLoading) {
      int length = Random().nextInt(5 - 2 + 1) + 2;
      List<Color> colors =
          List<Color>.generate(length, (index) => _generateRandomColor());
      List<double> stops = _impliedStops(length);
      gradientColors.clear();
      for (int i = 0; i < colors.length; i++) {
        gradientColors
            .add(AnKiiGradientColor(stop: stops[i], color: colors[i]));
      }
      degreeValue = Random().nextInt(360);
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

  List<double> _impliedStops(int length) {
    final double separation = 1.0 / (length - 1);
    return List<double>.generate(
      length,
      (int index) => index * separation,
      growable: false,
    );
  }

  Color _generateRandomColor() {
    return Color.fromRGBO(
        Random().nextInt(250), Random().nextInt(250), Random().nextInt(250), 1);
  }
}

class AnKiiGradientColor {
  double stop;
  Color color;

  AnKiiGradientColor({this.stop, this.color});
}
