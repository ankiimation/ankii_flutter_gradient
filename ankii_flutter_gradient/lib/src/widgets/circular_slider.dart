import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

//TODO: this widget copy and modifying from https://github.com/davidanaya/flutter-circular-slider
//TODO: Thank you so much. Contact me if i'm wrong to do that: ankiimation@gmail.com ;)
/// Returns a widget which displays a circle to be used as a slider.
///
/// Required arguments are position and divisions to set the initial selection.
/// onSelectionChange is a callback function which returns new values as the user
/// changes the interval.
/// The rest of the params are used to change the look and feel.
///
///     SingleCircularSlider(5, 10, onSelectionChange: () => {});
class SingleCircularSlider extends StatefulWidget {
  /// the selection will be values between 0..divisions; max value is 300
  final int divisions;

  /// the initial value in the selection
  final int position;

  /// the number of primary sectors to be painted
  /// will be painted using selectionColor
  final int primarySectors;

  /// the number of secondary sectors to be painted
  /// will be painted using baseColor
  final int secondarySectors;

  /// an optional widget that would be mounted inside the circle
  final Widget child;

  /// height of the canvas, default at 220
  final double height;

  /// width of the canvas, default at 220
  final double width;

  /// color of the base circle and sections
  final Color baseColor;

  /// color of the selection
  final Color selectionColor;

  /// color of the handlers
  final Color handlerColor;

  /// callback function when init and end change
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionChange;

  /// callback function when init and end finish
  /// (int init, int end) => void
  final SelectionChanged<int> onSelectionEnd;

  /// outter radius for the handlers
  final double handlerOutterRadius;

  /// if true will paint a rounded cap in the selection slider start
  final bool showRoundedCapInSelection;

  /// if true an extra handler ring will be displayed in the handler
  final bool showHandlerOutter;

  /// stroke width for the slider, defaults at 12.0
  final double sliderStrokeWidth;

  /// if true, the onSelectionChange will also return the number of laps in the slider
  /// otherwise, everytime the user completes a full lap, the selection restarts from 0
  final bool shouldCountLaps;

  SingleCircularSlider(
    this.divisions,
    this.position, {
    this.height,
    this.width,
    this.child,
    this.primarySectors,
    this.secondarySectors,
    this.baseColor,
    this.selectionColor,
    this.handlerColor,
    this.onSelectionChange,
    this.onSelectionEnd,
    this.handlerOutterRadius,
    this.showRoundedCapInSelection,
    this.showHandlerOutter,
    this.sliderStrokeWidth,
    this.shouldCountLaps,
  })  : assert(position >= 0 && position <= divisions,
            'init has to be > 0 and < divisions value'),
        assert(divisions >= 0, 'divisions has to be > 0 and <= 300');

  @override
  _SingleCircularSliderState createState() => _SingleCircularSliderState();
}

class _SingleCircularSliderState extends State<SingleCircularSlider> {
  int _end;

  @override
  void initState() {
    super.initState();
    _end = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.height ?? 220,
        width: widget.width ?? 220,
        child: CircularSliderPaint(
          mode: CircularSliderMode.singleHandler,
          init: 0,
          end: _end,
          divisions: widget.divisions,
          primarySectors: widget.primarySectors ?? 0,
          secondarySectors: widget.secondarySectors ?? 0,
          child: widget.child,
          onSelectionChange: (newInit, newEnd, laps) {
            if (widget.onSelectionChange != null) {
              widget.onSelectionChange(newInit, newEnd, laps);
            }
            setState(() {
              _end = newEnd;
            });
          },
          onSelectionEnd: (newInit, newEnd, laps) {
            if (widget.onSelectionEnd != null) {
              widget.onSelectionEnd(newInit, newEnd, laps);
            }
          },
          sliderStrokeWidth: widget.sliderStrokeWidth ?? 12.0,
          baseColor: widget.baseColor ?? Color.fromRGBO(255, 255, 255, 0.1),
          selectionColor:
              widget.selectionColor ?? Color.fromRGBO(255, 255, 255, 0.3),
          handlerColor: widget.handlerColor ?? Colors.white,
          handlerOutterRadius: widget.handlerOutterRadius ?? 12.0,
          showRoundedCapInSelection: widget.showRoundedCapInSelection ?? false,
          showHandlerOutter: widget.showHandlerOutter ?? true,
          shouldCountLaps: widget.shouldCountLaps ?? false,
        ));
  }
}

enum CircularSliderMode { singleHandler, doubleHandler }

enum SlidingState { none, endIsBiggerThanStart, endIsSmallerThanStart }

typedef SelectionChanged<T> = void Function(T a, T b, T c);

class CircularSliderPaint extends StatefulWidget {
  final CircularSliderMode mode;
  final int init;
  final int end;
  final int divisions;
  final int primarySectors;
  final int secondarySectors;
  final SelectionChanged<int> onSelectionChange;
  final SelectionChanged<int> onSelectionEnd;
  final Color baseColor;
  final Color selectionColor;
  final Color handlerColor;
  final double handlerOutterRadius;
  final Widget child;
  final bool showRoundedCapInSelection;
  final bool showHandlerOutter;
  final double sliderStrokeWidth;
  final bool shouldCountLaps;

  CircularSliderPaint({
    @required this.mode,
    @required this.divisions,
    @required this.init,
    @required this.end,
    this.child,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.onSelectionChange,
    @required this.onSelectionEnd,
    @required this.baseColor,
    @required this.selectionColor,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.showRoundedCapInSelection,
    @required this.showHandlerOutter,
    @required this.sliderStrokeWidth,
    @required this.shouldCountLaps,
  });

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSliderPaint> {
  bool _isInitHandlerSelected = false;
  bool _isEndHandlerSelected = false;

  SliderPainter _painter;

  /// start angle in radians where we need to locate the init handler
  double _startAngle;

  /// end angle in radians where we need to locate the end handler
  double _endAngle;

  /// the absolute angle in radians representing the selection
  double _sweepAngle;

  /// in case we have a double slider and we want to move the whole selection by clicking in the slider
  /// this will capture the position in the selection relative to the initial handler
  /// that way we will be able to keep the selection constant when moving
  int _differenceFromInitPoint;

  /// will store the number of full laps (2pi radians) as part of the selection
  int _laps = 0;

  /// will be used to calculate in the next movement if we need to increase or decrease _laps
  SlidingState _slidingState = SlidingState.none;

  bool get isDoubleHandler => widget.mode == CircularSliderMode.doubleHandler;

  bool get isSingleHandler => widget.mode == CircularSliderMode.singleHandler;

  bool get isBothHandlersSelected =>
      _isEndHandlerSelected && _isInitHandlerSelected;

  bool get isNoHandlersSelected =>
      !_isEndHandlerSelected && !_isInitHandlerSelected;

  @override
  void initState() {
    super.initState();
    _calculatePaintData();
  }

  // we need to update this widget both with gesture detector but
  // also when the parent widget rebuilds itself
  @override
  void didUpdateWidget(CircularSliderPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.init != widget.init || oldWidget.end != widget.end) {
      _calculatePaintData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<CustomPanGestureRecognizer>(
          () => CustomPanGestureRecognizer(
            onPanDown: _onPanDown,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
          (CustomPanGestureRecognizer instance) {},
        ),
      },
      child: CustomPaint(
        painter: BasePainter(
          baseColor: widget.baseColor,
          selectionColor: widget.selectionColor,
          primarySectors: widget.primarySectors,
          secondarySectors: widget.secondarySectors,
          sliderStrokeWidth: widget.sliderStrokeWidth,
        ),
        foregroundPainter: _painter,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: widget.child,
        ),
      ),
    );
  }

  void _calculatePaintData() {
    var initPercent = isDoubleHandler
        ? _valueToPercentage(widget.init, widget.divisions)
        : 0.0;
    var endPercent = _valueToPercentage(widget.end, widget.divisions);
    var sweep = _getSweepAngle(initPercent, endPercent);

    var previousStartAngle = _startAngle;
    var previousEndAngle = _endAngle;

    _startAngle = isDoubleHandler ? _percentageToRadians(initPercent) : 0.0;
    _endAngle = _percentageToRadians(endPercent);
    _sweepAngle = _percentageToRadians(sweep.abs());

    // update full laps if need be
    if (widget.shouldCountLaps) {
      var newSlidingState = _calculateSlidingState(_startAngle, _endAngle);
      if (isSingleHandler) {
        _laps = _calculateLapsForsSingleHandler(
            _endAngle, previousEndAngle, _slidingState, _laps);
        _slidingState = newSlidingState;
      } else {
        // is double handler
        if (newSlidingState != _slidingState) {
          _laps = _calculateLapsForDoubleHandler(
              _startAngle,
              _endAngle,
              previousStartAngle,
              previousEndAngle,
              _slidingState,
              newSlidingState,
              _laps);
          _slidingState = newSlidingState;
        }
      }
    }

    _painter = SliderPainter(
      mode: widget.mode,
      startAngle: _startAngle,
      endAngle: _endAngle,
      sweepAngle: _sweepAngle,
      selectionColor: widget.selectionColor,
      handlerColor: widget.handlerColor,
      handlerOutterRadius: widget.handlerOutterRadius,
      showRoundedCapInSelection: widget.showRoundedCapInSelection,
      showHandlerOutter: widget.showHandlerOutter,
      sliderStrokeWidth: widget.sliderStrokeWidth,
    );
  }

  int _calculateLapsForsSingleHandler(
      double end, double prevEnd, SlidingState slidingState, int laps) {
    if (slidingState != SlidingState.none) {
      if (_radiansWasModuloed(end, prevEnd)) {
        var lapIncrement = end < prevEnd ? 1 : -1;
        var newLaps = laps + lapIncrement;
        return newLaps < 0 ? 0 : newLaps;
      }
    }
    return laps;
  }

  int _calculateLapsForDoubleHandler(
      double start,
      double end,
      double prevStart,
      double prevEnd,
      SlidingState slidingState,
      SlidingState newSlidingState,
      int laps) {
    if (slidingState != SlidingState.none) {
      if (!_radiansWasModuloed(start, prevStart) &&
          !_radiansWasModuloed(end, prevEnd)) {
        var lapIncrement =
            newSlidingState == SlidingState.endIsBiggerThanStart ? 1 : -1;
        var newLaps = laps + lapIncrement;
        return newLaps < 0 ? 0 : newLaps;
      }
    }
    return laps;
  }

  SlidingState _calculateSlidingState(double start, double end) {
    return end > start
        ? SlidingState.endIsBiggerThanStart
        : SlidingState.endIsSmallerThanStart;
  }

  void _onPanUpdate(Offset details) {
    if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
      return;
    }
    if (_painter.center == null) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);

    _isInitHandlerSelected = false;
    _isEndHandlerSelected = false;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details);

    var angle = _coordinatesToRadians(_painter.center, position);
    var percentage = _radiansToPercentage(angle);
    var newValue = _percentageToValue(percentage, widget.divisions);

    if (isBothHandlersSelected) {
      var newValueInit =
          (newValue - _differenceFromInitPoint) % widget.divisions;
      if (newValueInit != widget.init) {
        var newValueEnd =
            (widget.end + (newValueInit - widget.init)) % widget.divisions;
        widget.onSelectionChange(newValueInit, newValueEnd, _laps);
        if (isPanEnd) {
          widget.onSelectionEnd(newValueInit, newValueEnd, _laps);
        }
      }
      return;
    }

    // isDoubleHandler but one handler was selected
    if (_isInitHandlerSelected) {
      widget.onSelectionChange(newValue, widget.end, _laps);
      if (isPanEnd) {
        widget.onSelectionEnd(newValue, widget.end, _laps);
      }
    } else {
      widget.onSelectionChange(widget.init, newValue, _laps);
      if (isPanEnd) {
        widget.onSelectionEnd(widget.init, newValue, _laps);
      }
    }
  }

  bool _onPanDown(Offset details) {
    if (_painter == null) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject();
    var position = renderBox.globalToLocal(details);

    if (position == null) {
      return false;
    }

    if (isSingleHandler) {
      if (_isPointAlongCircle(position, _painter.center, _painter.radius)) {
        _isEndHandlerSelected = true;
        _onPanUpdate(details);
      }
    } else {
      _isInitHandlerSelected = _isPointInsideCircle(
          position, _painter.initHandler, widget.handlerOutterRadius);

      if (!_isInitHandlerSelected) {
        _isEndHandlerSelected = _isPointInsideCircle(
            position, _painter.endHandler, widget.handlerOutterRadius);
      }

      if (isNoHandlersSelected) {
        // we check if the user pressed in the selection in a double handler slider
        // that means the user wants to move the selection as a whole
        if (_isPointAlongCircle(position, _painter.center, _painter.radius)) {
          var angle = _coordinatesToRadians(_painter.center, position);
          if (_isAngleInsideRadiansSelection(angle, _startAngle, _sweepAngle)) {
            _isEndHandlerSelected = true;
            _isInitHandlerSelected = true;
            var positionPercentage = _radiansToPercentage(angle);

            // no need to account for negative values, that will be sorted out in the onPanUpdate
            _differenceFromInitPoint =
                _percentageToValue(positionPercentage, widget.divisions) -
                    widget.init;
          }
        }
      }
    }
    return _isInitHandlerSelected || _isEndHandlerSelected;
  }
}

class SliderPainter extends CustomPainter {
  CircularSliderMode mode;
  double startAngle;
  double endAngle;
  double sweepAngle;
  Color selectionColor;
  Color handlerColor;
  double handlerOutterRadius;
  bool showRoundedCapInSelection;
  bool showHandlerOutter;
  double sliderStrokeWidth;

  Offset initHandler;
  Offset endHandler;
  Offset center;
  double radius;

  SliderPainter({
    @required this.mode,
    @required this.startAngle,
    @required this.endAngle,
    @required this.sweepAngle,
    @required this.selectionColor,
    @required this.handlerColor,
    @required this.handlerOutterRadius,
    @required this.showRoundedCapInSelection,
    @required this.showHandlerOutter,
    @required this.sliderStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint progress = _getPaint(color: selectionColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - sliderStrokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi / 2 + startAngle, sweepAngle, false, progress);

    Paint handler = _getPaint(color: handlerColor, style: PaintingStyle.fill);
    Paint handlerOutter = _getPaint(color: handlerColor, width: 2.0);

    // draw handlers
    if (mode == CircularSliderMode.doubleHandler) {
      initHandler = _radiansToCoordinates(center, -pi / 2 + startAngle, radius);
      canvas.drawCircle(initHandler, 8.0, handler);
      canvas.drawCircle(initHandler, handlerOutterRadius, handlerOutter);
    }

    endHandler = _radiansToCoordinates(center, -pi / 2 + endAngle, radius);
    canvas.drawCircle(endHandler, 8.0, handler);
    if (showHandlerOutter) {
      canvas.drawCircle(endHandler, handlerOutterRadius, handlerOutter);
    }
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap =
            showRoundedCapInSelection ? StrokeCap.round : StrokeCap.butt
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CustomPanGestureRecognizer extends OneSequenceGestureRecognizer {
  final Function onPanDown;
  final Function onPanUpdate;
  final Function onPanEnd;

  CustomPanGestureRecognizer({
    @required this.onPanDown,
    @required this.onPanUpdate,
    @required this.onPanEnd,
  });

  @override
  void addPointer(PointerEvent event) {
    if (onPanDown(event.position)) {
      startTrackingPointer(event.pointer);
      resolve(GestureDisposition.accepted);
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      onPanUpdate(event.position);
    }
    if (event is PointerUpEvent) {
      onPanEnd(event.position);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'customPan';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}

class BasePainter extends CustomPainter {
  Color baseColor;
  Color selectionColor;
  int primarySectors;
  int secondarySectors;
  double sliderStrokeWidth;

  Offset center;
  double radius;

  BasePainter({
    @required this.baseColor,
    @required this.selectionColor,
    @required this.primarySectors,
    @required this.secondarySectors,
    @required this.sliderStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint base = _getPaint(color: baseColor);

    center = Offset(size.width / 2, size.height / 2);
    radius = min(size.width / 2, size.height / 2) - sliderStrokeWidth;
    // we need this in the parent to calculate if the user clicks on the circumference

    assert(radius > 0);

    canvas.drawCircle(center, radius, base);

    if (primarySectors > 0) {
      _paintSectors(primarySectors, 8.0, selectionColor, canvas);
    }

    if (secondarySectors > 0) {
      _paintSectors(secondarySectors, 6.0, baseColor, canvas);
    }
  }

  void _paintSectors(
      int sectors, double radiusPadding, Color color, Canvas canvas) {
    Paint section = _getPaint(color: color, width: 2.0);

    var endSectors = _getSectionsCoordinatesInCircle(
        center, radius + radiusPadding, sectors);
    var initSectors = _getSectionsCoordinatesInCircle(
        center, radius - radiusPadding, sectors);
    _paintLines(canvas, initSectors, endSectors, section);
  }

  void _paintLines(
      Canvas canvas, List<Offset> inits, List<Offset> ends, Paint section) {
    assert(inits.length == ends.length && inits.length > 0);

    for (var i = 0; i < inits.length; i++) {
      canvas.drawLine(inits[i], ends[i], section);
    }
  }

  Paint _getPaint({@required Color color, double width, PaintingStyle style}) =>
      Paint()
        ..color = color
        ..strokeCap = StrokeCap.round
        ..style = style ?? PaintingStyle.stroke
        ..strokeWidth = width ?? sliderStrokeWidth;

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

//UTILS
double _percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);

double _radiansToPercentage(double radians) {
  var normalized = radians < 0 ? -radians : 2 * pi - radians;
  var percentage = ((100 * normalized) / (2 * pi));
  // TODO we have an inconsistency of pi/2 in terms of percentage and radians
  return (percentage + 25) % 100;
}

double _coordinatesToRadians(Offset center, Offset coords) {
  var a = coords.dx - center.dx;
  var b = center.dy - coords.dy;
  return atan2(b, a);
}

Offset _radiansToCoordinates(Offset center, double radians, double radius) {
  var dx = center.dx + radius * cos(radians);
  var dy = center.dy + radius * sin(radians);
  return Offset(dx, dy);
}

double _valueToPercentage(int time, int intervals) => (time / intervals) * 100;

int _percentageToValue(double percentage, int intervals) =>
    ((percentage * intervals) / 100).round();

bool _isPointInsideCircle(Offset point, Offset center, double rradius) {
  var radius = rradius * 1.2;
  return point.dx < (center.dx + radius) &&
      point.dx > (center.dx - radius) &&
      point.dy < (center.dy + radius) &&
      point.dy > (center.dy - radius);
}

bool _isPointAlongCircle(Offset point, Offset center, double radius) {
  // distance is root(sqr(x2 - x1) + sqr(y2 - y1))
  // i.e., (7,8) and (3,2) -> 7.21
  var d1 = pow(point.dx - center.dx, 2);
  var d2 = pow(point.dy - center.dy, 2);
  var distance = sqrt(d1 + d2);
  return (distance - radius).abs() < 10;
}

double _getSweepAngle(double init, double end) {
  if (end > init) {
    return end - init;
  }
  return (100 - init + end).abs();
}

List<Offset> _getSectionsCoordinatesInCircle(
    Offset center, double radius, int sections) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi / 2) + (intervalAngle * i);
    return _radiansToCoordinates(center, radians, radius);
  }).toList();
}

bool _isAngleInsideRadiansSelection(double angle, double start, double sweep) {
  var normalized = angle > pi / 2 ? 5 * pi / 2 - angle : pi / 2 - angle;
  var end = (start + sweep) % (2 * pi);
  return end > start
      ? normalized > start && normalized < end
      : normalized > start || normalized < end;
}

// this is not 100% accurate but it works
// we just want to see if a value changed drastically its value
bool _radiansWasModuloed(double current, double previous) {
  return (previous - current).abs() > (3 * pi / 2);
}
