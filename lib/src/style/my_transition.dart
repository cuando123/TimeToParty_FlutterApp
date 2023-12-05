import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> buildMyTransition<T>({
  required Widget child,
  required Color color,
  Decoration? decoration,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _MySlideTransition(
        animation: animation,
        decoration: decoration ?? BoxDecoration(color: color),
        child: child,
      );
    },
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    transitionDuration: const Duration(milliseconds: 400),
  );
}

class _MySlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final Decoration? decoration;

  const _MySlideTransition({
    required this.child,
    required this.animation,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), // You can adjust these as needed
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }
}


