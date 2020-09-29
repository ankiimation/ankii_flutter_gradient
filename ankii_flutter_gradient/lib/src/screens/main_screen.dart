import 'dart:async';

import 'package:ankii_flutter_gradient/src/global/theme/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:rxdart/rxdart.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _type = 0;
  List<Color> colors = [Colors.red, Colors.blue];

  // SUB WIDGETS
  Widget gradientCard() {
    double width = MediaQuery.of(context).size.width;
    double height = width * 0.6;
    Gradient gradient = _type == 0 ? LinearGradient(colors: [...colors]) : RadialGradient(colors: [...colors]);
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: height,
      width: width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: gradient),
      alignment: Alignment.center,
    );
  }

  Widget _typeSwitcherButton({int index = 0, String text = ''}) {
    Gradient gradient = _type == 0 ? LinearGradient(colors: [...colors]) : RadialGradient(colors: [...colors]);
    return InkWell(
      onTap: () {
        setState(() {
          if (_type != index) {
            _type = index;
          }
        });
      },
      child: Card(
          elevation: _type == index ? 0 : 5,
          child: Container(
              width: 100,
              decoration:
                  BoxDecoration(gradient: _type == index ? gradient : null, borderRadius: BorderRadius.circular(3)),
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              child: Text(
                text,
                style: TextStyle(color: _type == index ? Colors.white : null),
              ))),
    );
  }

  Widget typeSwitcher() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _typeSwitcherButton(text: 'Linear', index: 0),
          _typeSwitcherButton(text: 'Radial', index: 1),
        ],
      ),
    );
  }

  Widget _linerOptionCard(Widget child) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child:
            Card(elevation: 5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), child: child));
  }

  Widget linearOption() {
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

  Widget _colorsList() {
    return Container(
      child: Column(children: [
        ...colors.asMap().map((index, value) => MapEntry(index, __colorListItem(index))).values.toList(),
        InkWell(
          onTap: () {
            setState(() {
              colors.add(colors.last);
            });
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
      child: ExpansionTile(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Card(
                elevation: 0,
                color: colors[index],
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              '#${colors[index].value.toRadixString(16).substring(2)}',
              style: TextStyle(color: PRIMARY_COLOR),
            )
          ],
        ),
        children: [
          SlidePicker(
            pickerColor: colors[index],
            displayThumbColor: false,
            showLabel: false,
            showIndicator: false,
            onColorChanged: (newColor) {
              setState(() {
                colors[index] = newColor;
              });
            },
          )
        ],
      ),
    );
  }

  Widget radialOption() {
    return Container(
      child: Text('Radial'),
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
    return Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        appBar: AppBar(),
        body: Column(
          children: [
            Container(margin: EdgeInsets.all(10), child: gradientCard()),
            Expanded(
                child: ListView(
              children: [
                typeSwitcher(),
                SizedBox(
                  height: 20,
                ),
                _type == 0 ? linearOption() : radialOption()
              ],
            ))
          ],
        ));
  }
}
