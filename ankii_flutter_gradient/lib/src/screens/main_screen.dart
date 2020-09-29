import 'package:ankii_flutter_gradient/src/global/theme/global_theme.dart';
import 'package:ankii_flutter_gradient/src/widgets/no_glowable_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../global/theme/global_theme.dart';
import '../global/theme/global_theme.dart';
import '../global/theme/global_theme.dart';
import '../global/theme/global_theme.dart';
import '../global/theme/global_theme.dart';
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
            style: TextStyle(color: _type == index ? Colors.white : null),
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
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(padding: EdgeInsets.all(10), child: child)));
  }

  Widget linearOption() {
    return Container(
      child: Column(
        children: [
          _linerOptionCard(
            Column(
              children: [_degreesSlider(), _colorsList()],
            ),
          )
        ],
      ),
    );
  }

  Widget _degreesSlider() {
    return Container(
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
        selectionColor: PRIMARY_COLOR.withOpacity(0.5),
        baseColor: PRIMARY_COLOR.withOpacity(0.2),
        handlerColor: PRIMARY_COLOR,
        child: Center(
            child: Text(
          '${degreeValue}°',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        )),
      ),
    );
  }

  Widget _colorsList() {
    return Container(
      child: Column(children: [
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
            width: double.infinity,
            child: Icon(
              Icons.add,
              color: PRIMARY_COLOR,
            ),
          ),
        )
      ]),
    );
  }

  Widget __colorListItem(int index) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Row(
        children: [
          Expanded(
            child: ExpansionTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: Card(
                      elevation: 0,
                      color: gradientColors[index].color,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '#${gradientColors[index].color.value.toRadixString(16).substring(2)}',
                    style: TextStyle(color: PRIMARY_COLOR),
                  )
                ],
              ),
              children: [
                SlidePicker(
                  pickerColor: gradientColors[index].color,
                  displayThumbColor: false,
                  showLabel: false,
                  showIndicator: false,
                  onColorChanged: (newColor) {
                    setState(() {
                      gradientColors[index].color = newColor;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'STOP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: gradientColors[index].color,
                        inactiveTrackColor:
                            gradientColors[index].color.withOpacity(0.5),
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 7.0,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        thumbColor: Colors.white,
                        overlayColor:
                            gradientColors[index].color.withOpacity(0.5),
                        tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor: gradientColors[index].color,
                        inactiveTickMarkColor: gradientColors[index].color,
                        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                        valueIndicatorColor: gradientColors[index].color,
                      ),
                      child: Slider(
                        value: gradientColors[index].stop,
                        onChanged: (value) {
                          setState(() {
                            gradientColors[index].stop = value;
                          });
                        },
                        // inactiveColor: PRIMARY_COLOR.withOpacity(0.2),
                        // activeColor: PRIMARY_COLOR,
                      ),
                    ),
                    Text(
                      '${(gradientColors[index].stop * 100).toStringAsFixed(2)}%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
          ),
          gradientColors.length <= 2
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    if (gradientColors.length > 2) {
                      removeColor(index);
                    }
                  },
                )
        ],
      ),
    );
  }

  Widget radialOption() {
    return Container(
      child: Column(
        children: [
          _linerOptionCard(
            Column(
              children: [_colorsList()],
            ),
          )
        ],
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
        backgroundColor: BACKGROUND_COLOR,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              viewFull = !viewFull;
            });
          },
          elevation: viewFull ? 0 : 10,
          child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(100),
                  gradient: gradient),
              child: Icon(Icons.remove_red_eye)),
        ),
        body: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: double.maxFinite,
          width: double.maxFinite,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(gradient: viewFull ? gradient : null),
          child: viewFull
              ? null
              : Column(
                  children: [
                    Expanded(
                        child: NoGrowScrollView(
                      child: ListView(
                        children: [
                          Container(
                              margin: EdgeInsets.all(10),
                              child: gradientCard()),
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
        ));
  }

  void onChangeStop() {}

  void removeColor(int index) {
    setState(() {
      gradientColors.removeAt(index);
      gradientColors.last.stop = 1;
    });
  }

  void addColor() {
    List<double> stops = _impliedStops();

    // gradientColors.map((e) => e.stop).followedBy(stops);
    setState(() {
      gradientColors.last.stop =
          (1 + gradientColors[gradientColors.length - 2].stop) / 2;
      gradientColors
          .add(AnKiiGradientColor(stop: 1, color: gradientColors.last.color));
    });
  }

  List<double> _impliedStops() {
    final double separation = 1.0 / (gradientColors.length - 1);
    return List<double>.generate(
      gradientColors.length,
      (int index) => index * separation,
      growable: false,
    );
  }
}

class AnKiiGradientColor {
  double stop;
  Color color;

  AnKiiGradientColor({this.stop, this.color});
}
