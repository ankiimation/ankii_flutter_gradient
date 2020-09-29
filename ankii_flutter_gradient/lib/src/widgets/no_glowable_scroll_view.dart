import 'package:flutter/material.dart';

class NoGrowScrollView extends StatelessWidget {
  final Widget child;

  NoGrowScrollView({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification ovs) {
            ovs.disallowGlow();
            return;
          },
          child: child),
    );
  }
}
