import 'package:flutter/material.dart';

class FadePageRoute extends MaterialPageRoute {
  final route;
  FadePageRoute({required WidgetBuilder this.route, RouteSettings? settings})
      : super(builder: route, settings: settings);

  // OPTIONAL IF YOU WISH TO HAVE SOME EXTRA ANIMATION WHILE ROUTING
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
