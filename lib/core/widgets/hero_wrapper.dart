import 'package:flutter/material.dart';

class HeroWrapper extends StatelessWidget {
  const HeroWrapper({
    super.key,
    required this.tag,
    required this.child,
    this.transitionDuration,
  });

  final Object tag;
  final Widget child;
  final Duration? transitionDuration;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (
            BuildContext flightContext,
            Animation<double> animation,
            HeroFlightDirection flightDirection,
            BuildContext fromHeroContext,
            BuildContext toHeroContext,
          ) {
            return DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: toHeroContext.widget,
            );
          },
      child: child,
    );
  }
}
